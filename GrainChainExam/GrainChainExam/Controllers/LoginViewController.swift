//
//  FirstViewController.swift
//  GrainChainExam
//
//  Created by Raúl Torres on 18/10/18.
//  Copyright © 2018 Raúl Torres. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let srv = Services()
    
    @IBOutlet weak var scrollView: AutoKeyboardScrollView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBAction func loginBtnAction(_ sender: Any) {
        checkTextfiels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       setUpScrollView()
    }
    
    private func setUpScrollView() {
        for view in scrollView.subviews {
            if view.isKind(of: UITextField.self)  || view.isKind(of: UIButton.self) {
                scrollView.contentView.addSubview(view)
            }
        }
    }
    
    private func checkTextfiels(){
        
        self.showLoader(true)
        
        if let username = usernameTF.text, let password = passwordTF.text {
            saveUser(username: username, password: password)
        } else {
            self.showLoader(true)
            self.showAlert(message: "Please enter username and password")
        }
    }
    
    private func saveUser(username: String, password: String) {
        
        
        srv.apiCall(username: username, password: password) { (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                //                self.showToastErrorConection()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                //                self.showToastErrorConection()
                return
            }
            
            let decoder = JSONDecoder()
            
            if let jResponse = try? decoder.decode(JResponse.self, from: data) {
                //                print(jResponse.body.auth.user)
                let userInfo = jResponse.body.auth.user
                
                let userToSave = ["name": userInfo.name,
                                  "lastname": userInfo.lastname,
                                  "email": userInfo.email,
                                  "address": userInfo.address]
                
                UserDefaults.standard.set(userToSave, forKey: "savedUser")
                
                DispatchQueue.main.async {
                    self.showLoader(false)
                    self.performSegue(withIdentifier: "TabViewSegue", sender: nil)
                }
            }
            
            if let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) {
                let JString = errorMessage.errorMessage
                let data = JString.data(using: .utf8)!

            
                if let message = try? decoder.decode(ErrorM.self, from: data) {
                    self.showLoader(false)
                    self.showAlert(message: message.body.errorMessage)
                }
            }
        }
    }
}

//MARK: - TEXTFIELD DELEGATE
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            
            if textField.returnKeyType == .done {
                checkTextfiels()
            } else {
                nextField.becomeFirstResponder()
            }
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
    }
}
