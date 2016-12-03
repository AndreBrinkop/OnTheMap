//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by André Brinkop on 01.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    static let signUpUrl = URL(string: "https://www.udacity.com/account/auth#!/signup")!
    
    // Mark: Constants
    struct RequestConstants {
        
        // MARK: Headers
        static let headerFields = [
            "Accept" : "application/json",
            "Content-Type" : "application/json"
        ]
        
        // MARK: URLs
        static let apiScheme = "https"
        static let apiHost = "www.udacity.com"
        static let apiPath = "/api"
    }
    
    // MARK: Methods
    struct Methods {
        static let login = "/session"
        static let userData = "/users/<user_id>"
    }
    
    // MARK: Userdata
    struct User {
        var userId : String
        var firstName : String
        var lastName : String
    }
    
}
