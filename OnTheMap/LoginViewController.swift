//
//  ViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 29.11.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import SafariServices
import FacebookLogin

class LoginViewController: TextFieldDelegateViewController {

    // MARK: Properties
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: CustomButton!
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
    
    // MARK: Login and Sign Up
    
    @IBAction func loginUsingEmailAndPassword() {
        
        guard let email = emailTextField.text, email != "" else {
            displayCouldNotLoginMessage(message: "Please enter your email address!")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            displayCouldNotLoginMessage(message: "Please enter your password!")
            return
        }
        
        loginButton.startSpinning()
        
        if let activeTextField = activeTextField {
            activeTextField.resignFirstResponder()
            self.activeTextField = nil
        }
        
        UdacityClient.shared.loginUsingEmailAndPassword(email: email, password: password) { success, error in
            self.handleLoginResponse(loginMethod: "Udacity", success: success, error: error)
        }
    }
    
    @IBAction func loginUsingFacebook() {

        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled facebook login.")
            case .success (_, _, let accessToken):
                print("Connected to Facebook. Token: \(accessToken.authenticationToken)")
                
                self.loginButton.startSpinning()
                
                UdacityClient.shared.loginUsingFacebook() { success, error in
                    self.handleLoginResponse(loginMethod: "Facebook", success: success, error: error)
                }
            }
        }
    }
    
    // MARK: Login Workflow
    
    func handleLoginResponse(loginMethod: String, success: Bool, error: Error?) {
        
        guard error == nil, let userData = UdacityClient.shared.userData else {
            self.displayCouldNotLoginMessage(message: "\(error!.localizedDescription)")
            print("Could not log in!", error!.localizedDescription)
            return
        }
        
        print("Logged in using \(loginMethod)! User ID: \(userData.userId), First Name: \"\(userData.firstName)\", Last Name: \"\(userData.lastName)\"")
        
        // reset UI
        emailTextField.text = ""
        passwordTextField.text = ""
        loginButton.stopSpinning()
        
        performSegue(withIdentifier: "loggedIn", sender: nil)
    }

    @IBAction func signUpForNewAccount() {
        let safariViewController = SFSafariViewController(url: UdacityClient.signUpUrl)
        self.present(safariViewController, animated: true, completion: nil)
    }

    // MARK: Alert
    
    func displayCouldNotLoginMessage(message: String) {
        let alertController = UIAlertController(title: "Could not log in!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        loginButton.stopSpinning()
    }
    
    // MARK: Text Field Handling
    
    override func textFieldInputComplete() {
        super.textFieldInputComplete()
        loginUsingEmailAndPassword()
    }
    
    // MARK: Gradient Background
    
    func configureBackground() {
        view.backgroundColor = Color.defaultColor
        backgroundGradient = CAGradientLayer()
        let edgeColor = Color.defaultColor.cgColor
        let middleColor = Color.lightDefaultColor.cgColor
        
        backgroundGradient!.colors = [edgeColor, middleColor, middleColor, edgeColor]
        backgroundGradient!.locations = [0.0, 0.3, 0.7, 1.0]
        backgroundGradient!.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient!, at: 0)
    }


}

