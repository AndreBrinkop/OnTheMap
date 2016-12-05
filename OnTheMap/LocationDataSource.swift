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
    private(set) var didUserAlreadyPostLocation: Bool = false
    private(set) var isRefreshing = false
    
    private let udacityClient = UdacityClient.shared
    
    // MARK: Initialization
    
    override init() {
        super.init()
        updateData()
    }
    
    // MARK: Update the Data
    
    public func updateData() {
        self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdateStarted)
        isRefreshing = true
        
        // Check if userId already posted location
        parseClient.getLastPostedLocationOfUser(userId: udacityClient.userData!.userId) { studentLocation, error in
            guard error == nil else {
                self.sendNotification(notificationName: ParseClient.Notifications.locationsUpdateFailed)
                return
            }
            
            self.didUserAlreadyPostLocation = studentLocation != nil
            
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
