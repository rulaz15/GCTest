//
//  ContactsTableViewController.swift
//  GrainChainExam
//
//  Created by Raúl Torres on 18/10/18.
//  Copyright © 2018 Raúl Torres. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {

    let names = ["Marina", "Murtagh", "Dareia", "Shelly", "Alexandra", "Alice", "Nicolas", "Mia", "Savannah", "Pablo", "Zaria", "Dylan"]
    let lastNames = ["Arden", "Avery", "Brando", "Burton", "Cooper", "Gable", "Grant", "Lane", "Jordan", "Reese", "Tyson", "Hendrix"]
    
    var filteredContacts = [ContactModel]()
    var isSearching = false
    
    lazy var searchBar:UISearchBar = UISearchBar()

    lazy var userLabel : UILabel = {
        let label = UILabel()
        if let username = UserDefaults.standard.value(forKey: "savedUser") as? [String:String]{
            let name = username["name"]! + " " + username["lastname"]!
            label.text = name
        }
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        for i in 1...10 {
            Contacts.contacts.append(generateUser(num: i))
        }
        setUpNavBar()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    private func setUpNavBar() {
        
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        
        self.navigationItem.titleView = searchBar
        let leftNavBarBtn = UIBarButtonItem(customView: userLabel)
        self.navigationItem.leftBarButtonItem = leftNavBarBtn
    }
    
    private func generateUser(num: Int) -> ContactModel {
        
        return ContactModel(imageStr: "https://api.adorable.io/avatars/\(num)/", name: names.randomElement()!, lastName: lastNames.randomElement()!, age: String(Int.random(in: 15...50)), phone: String(Int.random(in: 1111111111...9999999999)))
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSearching {
            return filteredContacts.count
        } else {
            return Contacts.contacts.count //contacts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ContactTableViewCell", owner: self, options: nil)?.first as! ContactTableViewCell

        cell.contact = isSearching ? filteredContacts[indexPath.row] : Contacts.contacts[indexPath.row]

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.showAlert(message: "Delete this contact?", btnTitle: "Delete", btnStyle: .destructive,btnHandler: { (_) in
                
                if self.isSearching {
                    let selectedContact = self.filteredContacts[indexPath.row]
                    Contacts.contacts.removeAll(where: {$0.name == selectedContact.name && $0.lastName == selectedContact.lastName && $0.age == selectedContact.age && selectedContact.phone == selectedContact.phone})
                    self.filteredContacts.remove(at: indexPath.row)
                } else {
                    Contacts.contacts.remove(at: indexPath.row)
                }
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, action2: UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
    }
}

// MARK: - SEARCHBAR DELEGATE
extension ContactsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || (searchBar.text?.isEmpty)! {
            isSearching = false
            
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            let prefix = searchBar.text!
            filteredContacts = Contacts.contacts.filter({$0.name.hasPrefix(prefix)})
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
