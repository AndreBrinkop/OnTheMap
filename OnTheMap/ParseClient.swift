//
//  ParseClient.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit

class ParseClient {
    
    // MARK: API Methods
    
    func getLastPostedLocations(completionHandler: @escaping ([StudentLocation]?, Error?) -> ()) {
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
            let parsedResult = HTTPClient.parseData(data: data)
            
            guard let parsedData = parsedResult.parsedData, parsedResult.error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard let studentLocations = self.parseStudentLocations(parsedData: parsedData) else {
                completionHandler(nil, HTTPClient.createError(domain: "parseStudentLocations", error: "Could not parse student locations."))
                return
            }
            
            completionHandler(studentLocations, nil)
        }
        
    }
    
    // MARK: Parser
    
    private func parseStudentLocations(parsedData: [String : AnyObject]) -> [StudentLocation]? {
        
        guard let results = parsedData[JSONResponseKeys.results] as? [AnyObject] else {
            return nil
        }
        
        var studentLocations = [StudentLocation]()
        for result in results {
            
            // mandatory fields
            guard let latitude = result[JSONResponseKeys.latitude] as? Float, let longitude = result[JSONResponseKeys.longitude] as? Float else {
                // invalid entry
                continue
            }
            
            var firstName = DefaultValues.firstName
            var lastName = DefaultValues.lastName
            var key = DefaultValues.key
            var url: URL?
            
            if let parsedFirstName = result[JSONResponseKeys.firstName] as? String {
                firstName = parsedFirstName
            }
            if let parsedLastName = result[JSONResponseKeys.lastName] as? String {
                lastName = parsedLastName
            }
            if let parsedKey = result[JSONResponseKeys.key] as? String {
                key = parsedKey
            }
            if let parsedUrl = result[JSONResponseKeys.url] as? String {
                // check if URL is valid
                if let urlObject = URL(string: parsedUrl), UIApplication.shared.canOpenURL(urlObject)
                {
                    url = urlObject
                }
            }

            studentLocations.append(StudentLocation(id: key, firstName: firstName, lastName: lastName, url: url, latitude: latitude, longitude: longitude))
        }
        
        return studentLocations.isEmpty ? nil : studentLocations
        
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
