//
//  LocationDataSource.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit

class LocationDataSource: NSObject, UITableViewDataSource {
    
    private var parseClient = ParseClient.shared
    private(set) var studentLocations = [StudentLocation]()
    
    // MARK: Update the Data
    
    public func updateData() {
        parseClient.getLastPostedLocations() { (studentLocations, error) in
            guard let studentLocations = studentLocations, error == nil else {
                self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdateError)
                return
            }
            
            self.studentLocations = studentLocations
            self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdated)
        }
    }
    
    // MARK: Notifications
    
    private func sendNotification(notificationName: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil)
    }
    
    // MARK: Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studentLocation = studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        
        cell.imageView?.image = #imageLiteral(resourceName: "Pin")
        cell.textLabel?.text = ("\(studentLocation.firstName) \(studentLocation.lastName)")
        
        var detailText = ""
        if let url = studentLocation.url {
            detailText = url.absoluteString
        }
        
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
    
    // MARK: Shared Instance
    
    static var shared: LocationDataSource {
        get {
            struct Singleton {
                static var sharedInstance = LocationDataSource()
            }
            return Singleton.sharedInstance
        }
    }
}
