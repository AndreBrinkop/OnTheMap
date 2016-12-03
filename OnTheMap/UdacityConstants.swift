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
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
        static let facebook = "facebook_mobile"
        static let facebookToken = "access_token"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let userId = "user_id"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Account
        static let account = "account"
        static let userId = "key"
        
        // MARK: User
        static let user = "user"
        static let firstname = "first_name"
        static let lastname = "last_name"
    }

    
    // MARK: Userdata
    struct User {
        var userId : String
        var firstName : String
        var lastName : String
    }
    
}
