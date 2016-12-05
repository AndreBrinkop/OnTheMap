//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by André Brinkop on 01.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin

class UdacityClient {
    
    // MARK: Properties
    private(set) var userData: UdacityUser?
    private(set) var sessionId: String?
    private(set) var facebookToken: String?
    
    // MARK: API Methods
    
    func loginUsingEmailAndPassword(email: String, password: String, completionHandler: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        facebookToken = nil
        
        let loginMethodErrorMessage = "Invalid Email or Password."
        let httpBody = [
            JSONBodyKeys.udacity : [
                JSONBodyKeys.username : email,
                JSONBodyKeys.password : password
            ]
        ]
        
        login(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody as [String : AnyObject]?, completionHandler: completionHandler)
    }
    
    func loginUsingFacebook(completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        guard let accessToken = FacebookCore.AccessToken.current?.authenticationToken else {
            completionHandler(false, HTTPClient.createError(domain: "loginUsingFacebook", error: "You are not logged into Facebook"))
            return
        }
        
        facebookToken = accessToken
        
        let loginMethodErrorMessage = "Could not log in using Facebook. Ensure your Facebook account is connected with your Udacity account."
        let httpBody = [
            JSONBodyKeys.facebook : [
                JSONBodyKeys.facebookToken : accessToken
            ]
        ]
        
        login(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody as [String : AnyObject]?, completionHandler: completionHandler)
    }
    
    func logout(completionHandler: @escaping (_ error: Error?) -> ()) {
        let url = buildUrl(withPathExtension: Methods.session)

        var headerFields = [String : String]()
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            headerFields["X-XSRF-TOKEN"] = xsrfCookie.value
        }
        
        HTTPClient.deleteRequest(url: url, headerFields: headerFields) { data, error in
            let data = self.formatData(data: data)
            let parsedResult = HTTPClient.parseData(data: data)
            
            guard error == nil else {
                completionHandler(error)
                return
            }
            
            guard parsedResult.error == nil, parsedResult.parsedData != nil else {
                completionHandler(parsedResult.error)
                return
            }
            
            // logout successful
            self.sessionId = nil
            
            // facebook logout
            if self.facebookToken != nil  {
                self.logoutFacebook()
            }
            
            completionHandler(nil)
        }
    }
    
    // MARK: Login Helper Methods
    
    private func login(loginMethodErrorMessage: String, httpBody: [String : AnyObject]?, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        getSessionAndUserId(loginMethodErrorMessage: loginMethodErrorMessage, httpBody: httpBody) { userId, error in
            
            func executeCompletionHandler(success: Bool, error: Error?) {
                DispatchQueue.main.async {
                    completionHandler(success, error)
                }
            }
            
            guard let userId = userId, error == nil else {
                executeCompletionHandler(success: false, error: error)
                return
            }
            
            self.getUserData(userId: userId) { userName, error in
                
                guard let userName = userName, error == nil else {
                    executeCompletionHandler(success: false, error: error)
                    return
                }
                
                self.userData = UdacityUser(userId: userId, firstName: userName.0, lastName: userName.1)
                executeCompletionHandler(success: true, error: nil)
            }
            
        }
    }
    
    private func getSessionAndUserId(loginMethodErrorMessage: String, httpBody: [String : AnyObject]?, completionHandler: @escaping (_ userId: String?, _ error: Error?) -> Void) {
        
        let url = buildUrl(withPathExtension: Methods.session)
        
        HTTPClient.postRequest(url: url, headerFields: RequestConstants.headerFields, httpBody: httpBody, completionHandler: {data, error in
            
            let data = self.formatData(data: data)
            let parsedResult = HTTPClient.parseData(data: data)
            
            guard parsedResult.error == nil, let parsedData = parsedResult.parsedData else {
                let nsError = error as? NSError
                
                if nsError != nil && nsError!.domain == "httpResponseCode" {
                    completionHandler(nil, HTTPClient.createError(domain: "getUserId", error: loginMethodErrorMessage))
                } else {
                    completionHandler(nil, HTTPClient.createError(domain: "getUserId", error: "\(error!.localizedDescription)"))
                }
                completionHandler(nil, error)
                return
            }
            
            // parse session id
            let successfullySetSessionId = self.parseAndSetSessionId(parsedData: parsedData)
            guard successfullySetSessionId == true else {
                completionHandler(nil, HTTPClient.createError(domain: "parseSessionId", error: "Internal API Error."))
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
    
    private func parseAndSetSessionId(parsedData : [String : AnyObject]) -> Bool {
        guard let session = parsedData[JSONResponseKeys.session], let sessionId = session[JSONResponseKeys.sessionId] as? String else {
            return false
        }
        self.sessionId = sessionId
        return true
    }
    
    private func parseUserId(parsedData : [String : AnyObject]) -> String? {
        guard let account = parsedData[JSONResponseKeys.account], let userId = account[JSONResponseKeys.userId] as? String else {
            return nil
        }
        return userId
    }
    
    private func getUserData(userId: String, completionHandler: @escaping ((_ userName: (String, String)?, _ error: Error?) -> Void)) {
        let method = HTTPClient.substituteKeyInMethod(Methods.userData, key: URLKeys.userId, value: userId)
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
        guard let user = parsedData[JSONResponseKeys.user], let firstName = user[JSONResponseKeys.firstname] as? String, let lastName = user[JSONResponseKeys.lastname] as? String else {
            return nil
        }
        return (firstName, lastName)
    }
    
    // MARK: Logout Helper Methods
    
    private func logoutFacebook() {
        let loginManager = LoginManager()
        loginManager.logOut()
        facebookToken = nil
    }
    
    // MARK: Build API Request URL
    
    private func buildUrl(parameters: [String:AnyObject]? = nil, withPathExtension: String? = nil) -> URL {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = RequestConstants.apiScheme
        urlComponents.host = RequestConstants.apiHost
        urlComponents.path = RequestConstants.apiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            if urlComponents.queryItems == nil {
                urlComponents.queryItems = [URLQueryItem]()
            }
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
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
