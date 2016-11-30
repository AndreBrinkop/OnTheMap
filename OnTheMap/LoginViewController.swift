//
//  ViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 29.11.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {

    // MARK: Properties
    
    var backgroundGradient: CAGradientLayer?

    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient!.frame = self.view.bounds
    }
    
    // MARK: Facebook Login
    
    @IBAction func loginUsingFacebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success: //(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
            }
        }
    }
    
    // MARK: Gradient Background
    
    func configureBackground() {
        view.backgroundColor = Color.defaultColor
        backgroundGradient = CAGradientLayer()
        let colorTopBottom = Color.defaultColor.cgColor
        let colorMiddle = Color.lightColor.cgColor
        
        backgroundGradient!.colors = [colorTopBottom, colorMiddle, colorMiddle, colorTopBottom]
        backgroundGradient!.locations = [0.0, 0.3, 0.7, 1.0]
        backgroundGradient!.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient!, at: 0)
    }


}

