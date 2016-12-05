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
    
    
    // MARK: State Properties
    
    private enum InputState { case locationInput, urlInput }
    private var currentInputState: InputState = .locationInput
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        cancelButton.titleLabel?.textColor = Color.darkDefaultColor
        studyingLabel.textColor = Color.defaultColor
        
        topView.backgroundColor = Color.white
        middleView.backgroundColor = Color.defaultColor
        bottomView.backgroundColor = Color.white
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirm() {
    }
}
