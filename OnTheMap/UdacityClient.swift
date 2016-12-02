//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by André Brinkop on 01.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

class UdacityClient {
    
    // MARK: API Methods
    
    func loginUsingEmailAndPassword(email: String, password: String, completionHandler: @escaping ((_ userId: String?, _ error: Error?) -> Void)) {
        
        let loginMethodErrorMessage = "Invalid Email or Password."
        let httpBody = [
            "udacity" : [
                "username" : email,
                "password" : password
            ]
        ]
        
        login(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody as [String : AnyObject]?, completionHandler: completionHandler)
    }
    
    func loginUsingFacebook(accessToken: String, completionHandler: @escaping (_ userId: String?, _ error: Error?) -> Void) {
        
        let loginMethodErrorMessage = "Could not log in using Facebook. Ensure your Facebook account is connected with your Udacity account."
        let httpBody = [
            "facebook_mobile" : [
                "access_token" : accessToken
            ]
        ]
        
        login(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody as [String : AnyObject]?, completionHandler: completionHandler)
    }
    
    private func login(loginMethodErrorMessage: String, httpBody: [String : AnyObject]?, completionHandler: @escaping (_ userId: String?, _ error: Error?) -> Void) {
        
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
            
            self.parseUserId(loginMethodErrorMessage: loginMethodErrorMessage, parsedData: parsedData, error: error, completionHandler: completionHandler)
            
        })
    }
    
    private func parseUserId(loginMethodErrorMessage: String, parsedData : [String : AnyObject]?, error: Error?, completionHandler: @escaping (_ userId: String?, _ error: Error?) -> Void) {
        
        guard error == nil, let parsedData = parsedData else {
            completionHandler(nil, error)
            return
        }
        
        guard let account = parsedData["account"], let userId = account["key"] as? String else {
            completionHandler(nil, HTTPClient.createError(domain: "parseUserId", error: "Internal API Error."))
            return
        }
        
        DispatchQueue.main.async {
            completionHandler(userId, nil)
        }
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
    
    // MARK: Prepare Response Data for Parser
    
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
