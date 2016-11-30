//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by André Brinkop on 29.11.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FacebookCore.SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FacebookCore.SDKApplicationDelegate.shared.application(app, open: url, options: options)
        return handled
    }


}

