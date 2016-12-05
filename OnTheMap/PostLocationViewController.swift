//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 05.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import MapKit
import UIKit

class PostLocationViewController: TextFieldDelegateViewController {

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
    
    let locationTextFieldText: String = "Enter Your Location Here"
    let linkTextFieldText: String = "Enter a Link to Share Here"
    let locationConfirmButtonText: String = "Find on the Map"
    let linkConfirmButtonText: String = "Submit"
    
    let locationDataSource = LocationDataSource.shared
    var selectedLocation: CLLocationCoordinate2D?
    
    // MARK: State Properties
    
    private enum InputState { case locationInput, urlInput }
    private var currentInputState: InputState = .locationInput
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: UI Configuration
    
    private func configureUI() {
        studyingLabel.textColor = Color.defaultColor
        locationTextField.text = locationTextFieldText
        linkTextField.text = linkTextFieldText
        
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
    
    private func setCurrentInputState(state: InputState) {
        currentInputState = state
        configureUI()
        confirmButton.stopSpinning()
    }
    
    // MARK: Actions

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirm() {
        switch currentInputState {
        case .locationInput:
            searchLocation()
        case .urlInput:
            postLocation()
        }
    }
    
    func searchLocation() {
        guard !locationTextField.text!.isEmpty, locationTextField.text != locationTextFieldText else {
            displayErrorMessage(message: "Please enter a location!")
            return
        }

        self.showLoadingSpinner()
            
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.locationTextField.text!) { (results, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.displayErrorMessage(message: "Something went wrong while geocoding.")
                    return
                }
                guard let results = results, !results.isEmpty, let location = results[0].location else {
                    self.displayErrorMessage(message: "No location was found. Please enter something else.")
                    return
                }

                self.selectedLocation = location.coordinate
                self.setCurrentInputState(state: .urlInput)
                self.mapView.showAnnotations([MKPlacemark(placemark: results[0])], animated: true)
            }
        }
    }
    
    func postLocation() {
        guard !linkTextField.text!.isEmpty, linkTextField.text != linkTextFieldText else {
            displayErrorMessage(message: "Please enter a Link!")
            return
        }
        
        self.showLoadingSpinner()
        
        let link: URL? = URL(string: linkTextField.text!)
        
        guard let url = link, UIApplication.shared.canOpenURL(link!) else {
            displayErrorMessage(message: "Please enter a valid Link!\n(e.g. http://www.google.de)")
            return
        }
        
        let location = StudentLocation(id: locationDataSource.userData.userId, objectId: locationDataSource.knownObjectId, firstName: locationDataSource.userData.firstName, lastName: locationDataSource.userData.lastName, url: url, latitude: Float(selectedLocation!.latitude), longitude: Float(selectedLocation!.longitude))
        
        ParseClient.shared.postLocation(location: location) { (error: Error?) in
            guard error == nil else {
                self.displayErrorMessage(title: "Your Location Could not be Posted", message: error!.localizedDescription)
                return
            }
            
            self.locationDataSource.updateData()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // MARK: Text Field Handling
    
    override func textFieldInputComplete() {
        super.textFieldInputComplete()
        confirm()
    }
    
    // MARK: Loading Spinner
    
    func showLoadingSpinner() {
        confirmButton.startSpinning()
    }
    
    func hideLoadingSpinner() {
        confirmButton.stopSpinning()
    }
    
    // MARK: Helper
    
    func displayErrorMessage(title: String = "", message: String) {
        hideLoadingSpinner()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
