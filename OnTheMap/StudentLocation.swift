//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct StudentLocation {
    
    // MARK: Initialization
    
    init(dict: [String : AnyObject]) {
        // mandatory fields
        latitude = dict[ParseClient.JSONResponseKeys.latitude] as! Float
        longitude = dict[ParseClient.JSONResponseKeys.longitude] as! Float
        objectId = dict[ParseClient.JSONResponseKeys.objectId] as! String?

        // optional fields
        firstName = ParseClient.DefaultValues.firstName
        lastName = ParseClient.DefaultValues.lastName
        id = ParseClient.DefaultValues.key
        
        if let parsedFirstName = dict[ParseClient.JSONResponseKeys.firstName] as? String {
            firstName = parsedFirstName
        }
        if let parsedLastName = dict[ParseClient.JSONResponseKeys.lastName] as? String {
            lastName = parsedLastName
        }
        if let parsedKey = dict[ParseClient.JSONResponseKeys.key] as? String {
            id = parsedKey
        }
        if let parsedUrl = dict[ParseClient.JSONResponseKeys.url] as? String {
            // check if URL is valid
            if let urlObject = URL(string: parsedUrl), UIApplication.shared.canOpenURL(urlObject)
            {
                url = urlObject
            }
        }
    }
    
    init(udacityUser: UdacityUser, location: CLLocationCoordinate2D, url: URL?, objectId: String?) {
        id = udacityUser.userId
        firstName = udacityUser.firstName
        lastName = udacityUser.lastName
        
        latitude = Float(location.latitude)
        longitude = Float(location.longitude)
        
        self.url = url
        self.objectId = objectId
    }
    
    // MARK: Properties
    
    var id: String
    var objectId: String?
    var firstName: String
    var lastName: String
    var fullName: String { return "\(firstName) \(lastName)" }
    
    var url: URL?
    var latitude: Float
    var longitude: Float
    var coordinate: CLLocationCoordinate2D {
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: lat, longitude: long)}
}
