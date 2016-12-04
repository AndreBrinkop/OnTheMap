//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import SafariServices
import UIKit

class LocationTableViewController: UIViewController, UITableViewDelegate {
    
    // MARK: Properties
    
    private let dataSource = LocationDataSource.shared
    @IBOutlet var tableView: UITableView!

    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeDataSourceNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromDataSourceNotifications()
    }

    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = dataSource.studentLocations[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let url = studentLocation.url else {
            displayErrorMessage(message: "\(studentLocation.firstName) \(studentLocation.lastName) did not provide a (valid) URL!")
            return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    // MARK: Data Source Notifications

    static let locationsUpdateStarted = "LocationsUpdateStarted"
    static let locationsUpdated = "LocationsUpdateSuccessful"
    static let locationsUpdateError = "LocationsUpdateError"
    
    private func subscribeDataSourceNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showLoadingSpinner), name: NSNotification.Name(rawValue: ParseClient.Notifications.locationsUpdateStarted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateDataSource), name: NSNotification.Name(rawValue: ParseClient.Notifications.locationsUpdateCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayLocationUpdateErrorMessage), name: NSNotification.Name(rawValue: ParseClient.Notifications.locationsUpdateFailed), object: nil)
    }
    
    private func unsubscribeFromDataSourceNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ParseClient.Notifications.locationsUpdateStarted), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ParseClient.Notifications.locationsUpdateCompleted), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ParseClient.Notifications.locationsUpdateFailed), object: nil)
    }
    
    func didUpdateDataSource(success: Bool) {
        tableView.reloadData()
    }
    
    // MARK: Loading Spinner
    
    func showLoadingSpinner() {
        // TODO
    }
    
    func hideLoadingSpinner() {
        // TODO
    }
    
    // MARK: Show Error Message
    
    func displayLocationUpdateErrorMessage() {
        displayErrorMessage(message: "There was an error retrieving student data. Please check your network connection!")
    }
    
    func displayErrorMessage(message: String) {
        hideLoadingSpinner()
        let alertController = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    

}
