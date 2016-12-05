//
//  CustomTextFieldDelegateViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 05.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class TextFieldDelegateViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    internal var activeTextField: UITextField?
    private var textFieldPlaceholder = [UITextField: String]()
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dismiss keyboard if user tapped outside of the active text field
        let gestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text, !text.isEmpty else {
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
            textFieldInputComplete()
        }
        return false
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // if text field is edited for the first time store placeholder text from storyboard
        if !textFieldPlaceholder.keys.contains(textField) {
            textFieldPlaceholder[textField] = textField.text
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField.text == textFieldPlaceholder[textField] {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        
        if textField.text == "", let placeholder = textFieldPlaceholder[textField] {
            textField.text = placeholder
        }
    }
    
    // MARK: Keyboard Handling
    
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
    
    func dismissKeyboard() {
        activeTextField?.resignFirstResponder()
    }

    // MARK: Custom Action
    
    public func textFieldInputComplete() {
        // Overwrite
    }


}
