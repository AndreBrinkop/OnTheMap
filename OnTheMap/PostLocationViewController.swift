//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 05.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import MapKit
import UIKit

class PostLocationViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet var cancelButton: UIButton!
    
    @IBOutlet var topView: UIView!
    @IBOutlet var middleView: UIView!
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var studyingLabel: UILabel!
    @IBOutlet var linkTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!

    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var confirmButton: CustomButton!
    let locationConfirmButtonText: String = "Find on the Map"
    let linkConfirmButtonText: String = "Submit"
    
    
    // MARK: State Properties
    
    private enum InputState { case locationInput, urlInput }
    private var currentInputState: InputState = .locationInput
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        studyingLabel.textColor = Color.defaultColor
        
        if currentInputState == .locationInput {
            cancelButton.titleLabel?.textColor = Color.darkDefaultColor
            topView.backgroundColor = Color.white
            studyingLabel.isHidden = false
            linkTextField.isHidden = true
            
            locationTextField.isHidden = false
            middleView.backgroundColor = Color.defaultColor
            
            bottomView.backgroundColor = Color.white
            confirmButton.setTitle(locationConfirmButtonText, for: .normal)
        }
        
        if currentInputState == .urlInput {
            cancelButton.titleLabel?.textColor = Color.white
            topView.backgroundColor = Color.defaultColor
            studyingLabel.isHidden = true
            linkTextField.isHidden = false

            locationTextField.isHidden = true
            middleView.backgroundColor = UIColor.clear
            
            bottomView.backgroundColor = Color.white.withAlphaComponent(0.5)
            confirmButton.setTitle(linkConfirmButtonText, for: .normal)
        }
        

    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirm() {
        
        // TODO
        if currentInputState == .locationInput {
            currentInputState = .urlInput
        } else {
            currentInputState = .locationInput
        }
        
        configureUI()
        
    }
}
