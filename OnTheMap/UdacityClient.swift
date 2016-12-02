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
    
    func login(username: String, password: String, completionHandler: @escaping ((_ parsedData: [String : AnyObject]?, _ error: Error?) -> Void)) {
        
        let url = buildUrl(withPathExtension: Methods.login)
        
        let jsonBody = [
            "udacity" : [
                "username" : username,
                "password" : password
            ]
        ]
        
        HTTPClient.postRequest(url: url, headerFields: RequestConstants.headerFields, jsonBody: jsonBody as [String : AnyObject], completionHandler: {data, error in
            
            let data = self.formatData(data: data)
            let parsedResult = HTTPClient.parseData(data: data)
            
            guard let parsedData = parsedResult.parsedData, parsedResult.error == nil else {
                completionHandler(nil, error)
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(parsedData, error)
            }
        })
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
