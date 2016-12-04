//
//  ParseClient.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

class ParseClient {
    
    func getLastPostedLocations(completionHandler: ([StudentLocation]?, Error?) -> ()) {
        let parameters = [
            ParameterKeys.limit: ParameterValues.limit as AnyObject,
            ParameterKeys.order: ParameterValues.mostRecent as AnyObject
        ]
        
        let url = buildUrl(parameters: parameters, withPathExtension: Methods.location)

        let headerFields = [
            HeaderKeys.appId : HeaderValues.appId,
            HeaderKeys.apiKey : HeaderValues.apiKey
        ]
        
        HTTPClient.getRequest(url: url, headerFields: headerFields) { data, error in
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            // TODO parsing
        }
        
    }
    
    // MARK: Build API Request URL
    
    private func buildUrl(parameters: [String:AnyObject]? = nil, withPathExtension: String? = nil) -> URL {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = urlConstants.apiScheme
        urlComponents.host = urlConstants.apiHost
        urlComponents.path = urlConstants.apiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            for (key, value) in parameters {
                if urlComponents.queryItems == nil {
                    urlComponents.queryItems = [URLQueryItem]()
                }
                
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems!.append(queryItem)
            }
        }
        
        return urlComponents.url!
    }
    
    // MARK: Shared Instance
    
    static var shared: ParseClient {
        get {
            struct Singleton {
                static var sharedInstance = ParseClient()
            }
            return Singleton.sharedInstance
        }
    }
}
