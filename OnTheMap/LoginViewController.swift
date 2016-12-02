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

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    var activeTextField: UITextField?
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
    
    // MARK: Facebook Login
    
    @IBAction func loginUsingFacebook() {
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
    
    @IBAction func loginUsingUsernameAndPassword() {
        
        UdacityClient.shared.login(username: "username", password: "password") { data, error in
            if error == nil {
                print("Logged in!")
            } else {
                print("Could not log in!")
            }
        }
    }
    
    @IBAction func signUpForNewAccount() {
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1;
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
            loginUsingUsernameAndPassword()
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
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        let middleColor = Color.lightColor.cgColor
        
        backgroundGradient!.colors = [edgeColor, middleColor, middleColor, edgeColor]
        backgroundGradient!.locations = [0.0, 0.3, 0.7, 1.0]
        backgroundGradient!.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient!, at: 0)
    }


}

