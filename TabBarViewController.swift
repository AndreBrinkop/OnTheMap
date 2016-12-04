//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
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
        
    }
    
    @IBAction func refreshLocations() {
        
    }
    
}
