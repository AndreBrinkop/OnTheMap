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

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    var activeTextField: UITextField?
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
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
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text, text != "" else {
            textField.resignFirstResponder()
            return false
        }
        
        let nextTag = textField.tag + 1;
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            activeTextField?.resignFirstResponder()
            activeTextField = nil
            loginUsingEmailAndPassword()
        }
        return false

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    // MARK: KeyboardNotifications
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    var viewShiftValue: CGFloat = 0.0
    
    func keyboardWillShow(notification: NSNotification) {
        shiftKeyboardBack()
        
        if let localActiveTextFieldFrame = activeTextField?.frame {
            
            let globalActiveTextFieldFrame = activeTextField?.superview?.convert(localActiveTextFieldFrame, to: view)
            let activeTextFieldMaxY = globalActiveTextFieldFrame!.maxY
            
            let keyboardMinY = view.frame.maxY - getKeyboardHeight(notification: notification)
            
            if activeTextFieldMaxY > keyboardMinY {

                viewShiftValue = getKeyboardHeight(notification: notification)
                viewShiftValue = viewShiftValue - (view.frame.maxY - activeTextFieldMaxY)
                view.frame.origin.y -= viewShiftValue
            }
        }
    }
    
    func keyboardWillHide() {
        shiftKeyboardBack()
    }
    
    private func shiftKeyboardBack() {
        if viewShiftValue != 0.0 {
            view.frame.origin.y += viewShiftValue
            viewShiftValue = 0.0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
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

