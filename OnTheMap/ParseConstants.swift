//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

extension ParseClient {
    
    // Mark: Constants
    struct RequestConstants {
        
        // MARK: ParameterKeys
        struct ParameterKeys {
            static let limit = "limit"
            static let order = "order"
            static let query = "where"
            static let uniqueKey = "uniqueKey"
        }
        
        // MARK: ParameterValues
        struct ParameterValues {
            static let limit = 100
            static let mostRecent = "-updatedAt"
        }
        
        // MARK: Headers
        struct HeaderKeys {
            static let appId = "X-Parse-Application-Id"
            static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
        
        struct HeaderValues {
            static let appId = "X-Parse-REST-API-Key"
            static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
        
        // MARK: URLs
        static let apiScheme = "https"
        static let apiHost = "parse.udacity.com"
        static let apiPath = "/parse/classes"
    }
    
    // MARK: Methods
    struct Methods {
        static let location = "/StudentLocation"
    }
    
    // MARK: Notifications
    struct Notifications {
        static let locationsUpdated = "LocationsUpdated"
        static let locationsUpdateError = "LocationsUpdateError"
    }
}

