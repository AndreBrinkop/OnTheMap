//
//  ViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 29.11.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
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
    
    @IBAction func facebookLoginButton(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success: //(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! ", FacebookCore.AccessToken.current!)
            }
        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        UdacityClient.shared.login(username: "username", password: "password") { data, error in
            if error == nil {
                print("Logged in!")
            } else {
                print("Could not log in!")
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
    }
    
    // MARK: Gradient Background
    
    func configureBackground() {
        view.backgroundColor = Color.defaultColor
        backgroundGradient = CAGradientLayer()
        let edgeColor = Color.defaultColor.cgColor
        let middleColor = Color.lightColor.cgColor
        
        backgroundGradient!.colors = [edgeColor, middleColor, middleColor, edgeColor]
        backgroundGradient!.locations = [0.0, 0.3, 0.7, 1.0]
        backgroundGradient!.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient!, at: 0)
    }


}

