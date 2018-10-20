//
//  Validation.swift
//
//

import Foundation

struct Validation {
    
    func isValidAge(str: String) -> Bool {
        let regEx = "[0-9]{1,3}"
        let test =  NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: str)
    }
    
    func isValidPhone(str: String) -> Bool {
        let regEx = "[0-9]{10}"
        let test =  NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: str)
    }
    
    func isValidName(str: String) -> Bool {
        let regEx = "[A-Za-z]{3,}"
        let test =  NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: str)
    }
}
