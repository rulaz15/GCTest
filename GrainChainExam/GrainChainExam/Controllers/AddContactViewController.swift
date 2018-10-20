//
//  SecondViewController.swift
//  GrainChainExam
//
//  Created by Raúl Torres on 18/10/18.
//  Copyright © 2018 Raúl Torres. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController, UINavigationControllerDelegate {
    
    private enum FormError : Error {
        case incompleteForm
        case invalidName
        case invalidAge
        case invalidPhone
    }
    
    lazy var userLabel : UILabel = {
        let label = UILabel()
        if let username = UserDefaults.standard.value(forKey: "savedUser") as? [String:String]{
            let name = username["name"]! + " " + username["lastname"]!
            label.text = name
        }
        return label
    }()
    
    let val = Validation()
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var scrollView: AutoKeyboardScrollView!
    @IBOutlet weak var newContactIamgeView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    
    
    @IBAction func addImageBtnAction(_ sender: UIButton) {
        let alertV = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let imagesBtn = UIAlertAction(title: "Gallery", style: .default) { (_) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertV.addAction(cameraBtn)
        alertV.addAction(imagesBtn)
        alertV.addAction(cancelBtn)
        self.present(alertV, animated: true, completion: nil)
    }
    
    @IBAction func saveContactBtnAction(_ sender: UIButton) {
        do {
            try trySaveContact()
            saveContact()
        } catch FormError.incompleteForm {
            self.showAlert(message: "Please fill all the information.")
        } catch FormError.invalidName {
            self.showAlert(message: "Name or Last name fiels are invalid. (At least 3 characters, no especial characters)")
        } catch FormError.invalidAge {
            self.showAlert(message: "Age is invalid")
        } catch FormError.invalidPhone {
            self.showAlert(message: "Phone number is invalid. (10 digits exaclty)")
        } catch {
            print("unknown error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let leftNavBarBtn = UIBarButtonItem(customView: userLabel)
        self.navigationItem.leftBarButtonItem = leftNavBarBtn
        
        setUpScrollView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    private func setUpScrollView() {
        for view in scrollView.subviews {
            if view.isKind(of: UITextField.self)  || view.isKind(of: UIButton.self) || view.isKind(of: UIStackView.self){
                scrollView.contentView.addSubview(view)
            }
        }
    }
    
    //MARK: - CHECK FORM
    private func trySaveContact() throws {
        if (nameTF.text?.isEmpty)! || (lastNameTF.text?.isEmpty)! || (ageTF.text?.isEmpty)! || ((phoneTF.text?.isEmpty)!) {
            throw FormError.incompleteForm
        }
        
        if !val.isValidName(str: nameTF.text!) || !val.isValidName(str: lastNameTF.text!) {
            throw FormError.invalidName
        }
        
        if !val.isValidAge(str: ageTF.text!) || Int(ageTF.text!)! == 000  {
            throw FormError.invalidAge
        }
        
        if !val.isValidPhone(str: phoneTF.text!) {
            throw FormError.invalidPhone
        }
    }
    
    private func saveContact() {
        var contactImage : Any
        
        if newContactIamgeView.image != UIImage(named: "userImg.png") {
            contactImage = newContactIamgeView.image!
        } else {
            contactImage = "https://api.adorable.io/avatars/\(Contacts.contacts.count+1)/"
        }
        
        let newContact = ContactModel(imageStr: contactImage, name: nameTF.text!, lastName: lastNameTF.text!, age: ageTF.text!, phone: phoneTF.text!)
        Contacts.contacts.append(newContact)
        
        self.showAlert(title: "Success", message: "User saved", btnHandler: { (_) in
            self.tabBarController?.selectedIndex = 0
        })
    }
}

//MARK: - IMAGE PICKER
extension AddContactViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        newContactIamgeView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
