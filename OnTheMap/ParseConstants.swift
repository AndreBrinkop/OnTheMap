//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

extension ParseClient {
        
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
        static let apiKey = "X-Parse-REST-API-Key"
    }
    
    struct HeaderValues {
        static let appId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // MARK: URLs
    struct urlConstants {
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
        static let locationsUpdateStarted = "LocationsUpdateStarted"
        static let locationsUpdated = "LocationsUpdateSuccessful"
        static let locationsUpdateError = "LocationsUpdateError"
    }
}

