//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: Properties
    
    private let dataSource = LocationDataSource.shared
    private let overwritePromtMessage = "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?"
    
    // MARK: Actions
    
    @IBAction func logout() {
        self.dismiss(animated: true) {
            UdacityClient.shared.logout() { error in
                guard error == nil else {
                    print("Error while logging out:", error!)
                    return
                }
            }
        }
    }
    
    @IBAction func addLocation() {
        if dataSource.isRefreshing {
            return
        }
        if dataSource.didUserAlreadyPostLocation {
            displayOverwritePromt()
            return
        }
        performSegue(withIdentifier: "postLocation", sender: nil)
    }
    
    @IBAction func refreshLocations() {
        dataSource.updateData()
    }
    
    // MARK: Overwrite Promt
    
    private func displayOverwritePromt() {
        let alertController = UIAlertController(title: "", message: overwritePromtMessage, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: { action in
            self.performSegue(withIdentifier: "postLocation", sender: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }
    
}
