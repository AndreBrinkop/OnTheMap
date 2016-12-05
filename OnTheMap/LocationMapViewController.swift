//
//  LocationMapViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

class LocationMapViewController: LocationViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loadingOverlayView: UIView!
    
    // MARK: Map View Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        
        if pinView == nil {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView.canShowCallout = true
            annotationView.pinTintColor = getPinColor()
            
            pinView = annotationView
        }
        else {
            pinView!.annotation = annotation
        }
        
        pinView!.rightCalloutAccessoryView = nil
        
        if let subtitle = annotation.subtitle {
            if subtitle != nil {
                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            }
        }
        
        return pinView
    }
    
    // MARK: Map View Helper
    
    private var getPinColorCallCounter = 0
    private var availablePinColors: [UIColor] = [.red, .green, .blue, .purple, .black, .orange, .brown, .magenta]
    
    private func getPinColor() -> UIColor {
        let pinColor = availablePinColors[getPinColorCallCounter % availablePinColors.count]
        getPinColorCallCounter += 1
        return pinColor
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                openUrl(url: URL(string: toOpen)!)
            }
        }
    }
    
    // MARK: Data Source Update
    
    override func updateUI() {
        
        var annotations = [MKPointAnnotation]()
        
        for studentLocation in locationDataSource.studentLocations {
            let annotation = MKPointAnnotation()
            annotation.title = studentLocation.fullName
            annotation.subtitle = studentLocation.url?.absoluteString
            annotation.coordinate = studentLocation.coordinate
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async {
            // Update map annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
    }
    
    // MARK: Loading Spinner

    override func showLoadingSpinner() {
        loadingOverlayView.isHidden = false
    }
    
    override func hideLoadingSpinner() {
        loadingOverlayView.isHidden = true
    }


}
