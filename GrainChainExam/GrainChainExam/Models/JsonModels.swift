//
//  JsonModels.swift
//  GrainChainExam
//
//  Created by Raúl Torres on 18/10/18.
//  Copyright © 2018 Raúl Torres. All rights reserved.
//

import Foundation

//MARK:- USER SUCCESS
struct JResponse : Decodable {
    
    struct UserInfo : Decodable {
        let name : String
        let lastname : String
        let email : String
        let address : String
    }
    
    struct User : Decodable {
        let user: UserInfo
        let accesToken : String
        
        private enum CodingKeys: String, CodingKey {
            case accesToken = "access_token"
            case user
        }
    }
    
    struct Body : Decodable {
        let status : String
        let auth : User
    }
    
    let statusCode : Int
    let body : Body
}

//MARK: - MESSAGE ERROR
struct ErrorMessage: Decodable {
    let errorMessage : String
}

struct ErrorM: Codable {
    
    struct Body : Codable {
        let errorMessage : String
    }
    
    let statusCode: Int
    let body: Body
}
