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
    
    // MARK: Properties
    
    private let headerFields = [
        HeaderKeys.appId : HeaderValues.appId,
        HeaderKeys.apiKey : HeaderValues.apiKey,
        HeaderKeys.contentType : HeaderValues.contentType
    ]
    
    // MARK: API Methods
    
    func getLastPostedLocationOfUser(userId: String, completionHandler: @escaping (StudentLocation?, Error?) -> ()) {
        let parameters = [
            ParameterKeys.limit: ParameterValues.singleObjectLimit as AnyObject,
            ParameterKeys.query: "{\"\(ParameterKeys.uniqueKey)\": \"\(userId)\"}" as AnyObject
        ]
        
        getLocations(parameters: parameters, completionHandler: {studentLocations, error in
            guard let studentLocations = studentLocations, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard !studentLocations.isEmpty else {
                completionHandler(nil, error)
                return
            }

            completionHandler(studentLocations.first, nil)
        })
    }
    
    func getLastPostedLocations(completionHandler: @escaping ([StudentLocation]?, Error?) -> ()) {
        let parameters = [
            ParameterKeys.limit: ParameterValues.limit as AnyObject,
            ParameterKeys.order: ParameterValues.mostRecent as AnyObject
        ]
        
        getLocations(parameters: parameters, completionHandler: completionHandler)
    }
    
    func postLocation(location: StudentLocation, completionHandler: @escaping (Error?) -> ()) {
        let updateExistingLocation : Bool = location.objectId != nil
        
        var pathExtension = Methods.location
        if updateExistingLocation {
            pathExtension = HTTPClient.substituteKeyInMethod(Methods.updateLocation, key: URLKeys.objectId, value: location.objectId!)!
        }
        let url = buildUrl(parameters: nil, withPathExtension: pathExtension)
        
        var httpBody = [
            BodyKeys.firstName : location.firstName as AnyObject,
            BodyKeys.lastName : location.lastName as AnyObject,
            BodyKeys.latitude : location.coordinate.latitude as AnyObject,
            BodyKeys.longitude : location.coordinate.longitude as AnyObject,
            BodyKeys.key : location.id as AnyObject
        ]
        
        if let postedUrl = location.url?.absoluteString {
            httpBody[BodyKeys.url] = postedUrl as AnyObject
        }
        
        let requestCompletionHandler = { (data: Data?, error: Error?) in
            guard data != nil, error == nil else {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
        
        let httpMethod = updateExistingLocation ? "PUT" : "POST"
        
        HTTPClient.httpRequest(url: url, httpMethod: httpMethod, headerFields: headerFields, httpBody: httpBody, completionHandler: requestCompletionHandler)
    }
    
    // MARK: API Method Helper
    
    private func getLocations(parameters: [String : AnyObject], completionHandler: @escaping ([StudentLocation]?, Error?) -> ()) {
        let url = buildUrl(parameters: parameters, withPathExtension: Methods.location)
        
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
            guard result[JSONResponseKeys.latitude] as? Float != nil,
                result[JSONResponseKeys.longitude] as? Float != nil,
                result[JSONResponseKeys.objectId] as? String != nil
            else {
                // invalid entry
                continue
            }

            studentLocations.append(StudentLocation(dict: result as! [String : AnyObject]))
        }
        return studentLocations
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
