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
