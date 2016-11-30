//
//  LoginButton.swift
//  OnTheMap
//
//  Created by André Brinkop on 29.11.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class LoginButton: UIButton {

    // MARK: Constants

    let titleLabelColor = UIColor.white
    
    let cornerRadius: CGFloat = 5.0
    let titleLabelFontSize: CGFloat = 17.0

    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        styleLoginButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLoginButton()
    }
    
    private func styleLoginButton() {
        backgroundColor = Color.defaultColor
        setTitleColor(titleLabelColor, for: UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: titleLabelFontSize)
        layer.cornerRadius = cornerRadius

    }
    

    // MARK: Tracking
    
    override func beginTracking(_ touch: UITouch, with withEvent: UIEvent?) -> Bool {
        backgroundColor = Color.darkColor
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        backgroundColor = Color.defaultColor
    }
    
    override func cancelTracking(with event: UIEvent?) {
        backgroundColor = Color.defaultColor
    }
    


}
