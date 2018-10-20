//
//  WebServices.swift
//  GrainChainExam
//
//  Created by Raúl Torres on 18/10/18.
//  Copyright © 2018 Raúl Torres. All rights reserved.
//

import Foundation

class Services {
    
    let getUserApi = "https://kdmldkvxoe.execute-api.us-west-2.amazonaws.com/test"
//    let username = "harvx_190878"
//    let password = "supersecretpassword"
    
    func apiCall(username: String, password: String, handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let url = URL(string: getUserApi) else { return }
        
        var request = URLRequest(url: url)

        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        let json = "{\"username\": \"\(username)\", \"password\": \"\(password)\"}"
        
        let jsonData = json.data(using: .utf8)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request, completionHandler: handler)
        task.resume()
    }
}
