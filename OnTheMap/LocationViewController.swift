//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import SafariServices
import UIKit

class LocationViewController: UIViewController {
    
    // MARK: Properties
    
    internal let locationDataSource = LocationDataSource.shared
    
    // MARK: Initialization
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeDataSourceNotifications()
        
        if locationDataSource.isRefreshing {
            showLoadingSpinner()
        } else {
            hideLoadingSpinner()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromDataSourceNotifications()
    }
    
    // MARK: Data Source Notifications
    
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
    
    func didUpdateDataSource() {
        hideLoadingSpinner()
    }
    
    // MARK: Loading Spinner

    func showLoadingSpinner() {
        preconditionFailure("This method must be overridden")
    }
    
    func hideLoadingSpinner() {
        preconditionFailure("This method must be overridden")
    }
    
    // MARK: Open URL
    func openUrl(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
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
