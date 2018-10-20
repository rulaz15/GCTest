//
//  ContactModel.swift
//  GrainChainExam
//
//  Created by Raúl Torres on 18/10/18.
//  Copyright © 2018 Raúl Torres. All rights reserved.
//

import Foundation

public class Contacts {
    static var contacts = [ContactModel]()
}

class ContactModel {
    var imageStr : Any
    var name: String
    var lastName: String
    var age: String
    var phone: String
    
    init(imageStr: Any, name: String, lastName: String, age: String, phone: String) {
        self.imageStr = imageStr
        self.name = name
        self.lastName = lastName
        self.age = age
        self.phone = phone
    }
}
