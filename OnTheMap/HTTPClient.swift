//
//  HTTPClient.swift
//  OnTheMap
//
//  Created by André Brinkop on 01.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

class HTTPClient {
    
    // MARK: Properties
    
    static let session = URLSession.shared
    
    
    // MARK: Convenience Methods
    
    static func getRequest(url: URL, headerFields: [String : String]?, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        httpRequest(url: url, httpMethod: "GET", headerFields: headerFields, jsonBody: nil, completionHandler: completionHandler)
    }
    
    static func postRequest(url: URL, headerFields: [String : String]?, jsonBody: [String : AnyObject], completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        httpRequest(url: url, httpMethod: "POST", headerFields: headerFields, jsonBody: jsonBody, completionHandler: completionHandler)
    }
    
    // MARK: Request Method
    
    static func httpRequest(url: URL, httpMethod: String, headerFields: [String : String]?,  jsonBody: [String : AnyObject]?, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod
        
        
        if let headerFields = headerFields {
            for headerField in headerFields {
                request.addValue(headerField.value, forHTTPHeaderField: headerField.key)
            }
        }

        if let jsonBody = jsonBody {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
            } catch {
                completionHandler(nil, createError(domain: "httpRequest", error: "Can not parse JSON body"))
                return
            }
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            func sendError(error: String) {
                completionHandler(nil, createError(domain: "postRequest", error: error))
            }
            
            if let responseError = checkForError(data: data, response: response, error: error) {
                sendError(error: responseError)
                return
            }
            
            completionHandler(data, nil)
        }
        task.resume()
    }
    
    // MARK: Parse data
    
    static func parseData(data: Data?) -> (parsedData: [String: AnyObject]?, error: Error?) {
        guard let data = data else {
            return (parsedData: nil, error: createError(domain: "parseData", error: "No data to parse"))
        }
        
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            return (parsedData: parsedData, error: nil)
        } catch {
            return (parsedData: nil, error: createError(domain: "parseData", error: "Could not parse the data as JSON: '\(data)'"))
        }
    }
    
    // MARK: Check for Errors
    
    static private func checkForError(data: Data?, response: URLResponse?, error: Error?) -> String? {
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            return "There was an error with your request: \(error)"
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            return "Your request returned a status code other than 2xx!"
        }
        
        /* GUARD: Was there any data returned? */
        guard data != nil else {
            return "No data was returned by the request!"
        }
        
        return nil
    }
    
    static private func createError(domain: String, error: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: error]
        return NSError(domain: domain, code: 1, userInfo: userInfo)
    }
    
}
