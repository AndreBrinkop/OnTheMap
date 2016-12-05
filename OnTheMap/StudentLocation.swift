//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocation {
    var id: String
    var objectId: String
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
