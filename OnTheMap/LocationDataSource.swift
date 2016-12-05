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
    private(set) var knownObjectId: String? = nil
    var didUserAlreadyPostLocation: Bool { return knownObjectId != nil }
    private(set) var isRefreshing = false
    
    let userData = UdacityClient.shared.userData!
    
    // MARK: Initialization
    
    override init() {
        super.init()
        updateData()
    }
    
    // MARK: Update the Data
    
    public func updateData() {
        self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdateStarted)
        isRefreshing = true
        
        if didUserAlreadyPostLocation {
            // Do not need to check again
            updateStudentLocations()
            return
        }
        
        // Check if userId already posted location
        parseClient.getLastPostedLocationOfUser(userId: userData.userId) { studentLocation, error in
            guard error == nil else {
                self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdateFailed)
                return
            }
            
            self.knownObjectId = studentLocation?.objectId
            
            // Get last posted Locations of all Users
            self.updateStudentLocations()
        }
    }
    
    private func updateStudentLocations() {
        // Get last posted Locations of all Users
        self.parseClient.getLastPostedLocations() { (studentLocations, error) in
            self.isRefreshing = false
            
            guard let studentLocations = studentLocations, error == nil else {
                self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdateFailed)
                return
            }
            
            self.studentLocations = studentLocations
            self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdateCompleted)
        }
    }
    
    // MARK: Notifications
    
    private func sendNotification(notificationName: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil)
        }
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studentLocation = studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        
        cell.imageView?.image = #imageLiteral(resourceName: "Pin")
        cell.textLabel?.text = studentLocation.fullName
        
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
