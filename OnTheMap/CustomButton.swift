//
//  LoginButton.swift
//  OnTheMap
//
//  Created by André Brinkop on 29.11.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    // MARK: Constants

    private let titleLabelColor = UIColor.white
    
    private let cornerRadius: CGFloat = 5.0
    private let titleLabelFontSize: CGFloat = 17.0
    
    // MARK: Properties
    
    private var activityIndicator: UIActivityIndicatorView!

    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }
    
    private func setUpButton() {
        
        // Styling
        backgroundColor = Color.defaultColor
        setTitleColor(titleLabelColor, for: UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: titleLabelFontSize)
        layer.cornerRadius = cornerRadius
        
        setUpActivityIndicator()
    }
    
    private func setUpActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        setActivityIndicatorPosition()
    }
    
    private func setActivityIndicatorPosition() {
        let xPositionConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yPositionConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.addConstraint(xPositionConstraint)
        self.addConstraint(yPositionConstraint)
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
    
    // MARK: Activity Indicator
    
    func startSpinning() {
        self.titleLabel?.layer.opacity = 0.0
        activityIndicator.startAnimating()
    }
    
    func stopSpinning() {
        self.titleLabel?.layer.opacity = 1.0
        activityIndicator.stopAnimating()
    }

}
