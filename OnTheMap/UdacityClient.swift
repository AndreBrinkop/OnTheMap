//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by André Brinkop on 01.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

class UdacityClient {
    
    // MARK: Properties
    var userData: User?
    
    // MARK: API Methods
    
    func loginUsingEmailAndPassword(email: String, password: String, completionHandler: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        
        let loginMethodErrorMessage = "Invalid Email or Password."
        let httpBody = [
            "udacity" : [
                "username" : email,
                "password" : password
            ]
        ]
        
        login(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody as [String : AnyObject]?, completionHandler: completionHandler)
    }
    
    func loginUsingFacebook(accessToken: String, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        let loginMethodErrorMessage = "Could not log in using Facebook. Ensure your Facebook account is connected with your Udacity account."
        let httpBody = [
            "facebook_mobile" : [
                "access_token" : accessToken
            ]
        ]
        
        login(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody as [String : AnyObject]?, completionHandler: completionHandler)
    }
    
    // MARK: Login Helper Methods
    
    private func login(loginMethodErrorMessage: String, httpBody: [String : AnyObject]?, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        getUserId(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody) { userId, error in
            
            guard let userId = userId, error == nil else {
                completionHandler(false, error)
                return
            }
            
            self.getUserData(userId: userId) { userName, error in
                
                guard let userName = userName, error == nil else {
                    completionHandler(false, error)
                    return
                }
                
                self.userData = User(userId: userId, firstName: userName.0, lastName: userName.1)
                completionHandler(true, nil)
            }
            
        }
    }
    
    private func getUserId(loginMethodErrorMessage: String, httpBody: [String : AnyObject]?, completionHandler: @escaping (_ userId: String?, _ error: Error?) -> Void) {
        
        let url = buildUrl(withPathExtension: Methods.login)
        
        HTTPClient.postRequest(url: url, headerFields: RequestConstants.headerFields, httpBody: httpBody, completionHandler: {data, error in
            
            let data = self.formatData(data: data)
            let parsedResult = HTTPClient.parseData(data: data)
            
            guard parsedResult.error == nil, let parsedData = parsedResult.parsedData else {
                let nsError = error as? NSError
                
                if nsError != nil && nsError!.domain == "httpResponseCode" {
                    completionHandler(nil, HTTPClient.createError(domain: "login", error: loginMethodErrorMessage))
                } else {
                    completionHandler(nil, HTTPClient.createError(domain: "login", error: "\(error!.localizedDescription)"))
                }
                completionHandler(nil, error)
                return
            }
            
            // parse user id
            guard let userId = self.parseUserId(parsedData: parsedData) else {
                completionHandler(nil, HTTPClient.createError(domain: "parseUserId", error: "Internal API Error."))
                return
            }
            
            completionHandler(userId, nil)
            
        })
    }
    
    private func parseUserId(parsedData : [String : AnyObject]) -> String? {
        guard let account = parsedData["account"], let userId = account["key"] as? String else {
            return nil
        }
        return userId
    }
    
    private func getUserData(userId: String, completionHandler: @escaping ((_ userName: (String, String)?, _ error: Error?) -> Void)) {
        let method = HTTPClient.substituteKeyInMethod(Methods.userData, key: "user_id", value: userId)
        let url = buildUrl(withPathExtension: method)
        
        HTTPClient.getRequest(url: url, headerFields: RequestConstants.headerFields, completionHandler: {data, error in
            
            let data = self.formatData(data: data)
            let parsedResult = HTTPClient.parseData(data: data)
            
            guard let parsedData = parsedResult.parsedData, parsedResult.error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let userName = self.parseUserData(parsedData: parsedData)
            completionHandler(userName, nil)
        })
    }
    
    private func parseUserData(parsedData : [String : AnyObject]) -> (String, String)? {
        guard let user = parsedData["user"], let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
            return nil
        }
        return (firstName, lastName)
    }
    
    // MARK: Build API Request URL
    
    private func buildUrl(parameters: [String:AnyObject]? = nil, withPathExtension: String? = nil) -> URL {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = RequestConstants.apiScheme
        urlComponents.host = RequestConstants.apiHost
        urlComponents.path = RequestConstants.apiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems!.append(queryItem)
            }
        }
        
        return urlComponents.url!
    }
    
    // MARK: Helper Methods
    
    // Prepare Response Data for Parser
    private func formatData(data: Data?) -> Data? {
        
        guard data != nil else {
            return nil
        }
        
        let range = Range(uncheckedBounds: (5, data!.count))
        let newData = data?.subdata(in: range)
        
        return newData
    }
    
    // MARK: Shared Instance
    
    static var shared: UdacityClient {
        get {
            struct Singleton {
                static var sharedInstance = UdacityClient()
            }
            return Singleton.sharedInstance
        }
    }
}
