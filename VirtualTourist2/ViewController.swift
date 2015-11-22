//
//  ViewController.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/22/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    var pins = [MKPointAnnotation]()
    var currentPin = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    func reload() {
    }
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            
            //display alert with error message
            let alert = UIAlertController(title: "Map Loading Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    //Map Delegate Functions
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("In viewForAnnotation")
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = MKPinAnnotationView.purplePinColor()
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        print("In didSelectAnnotationView")
    }
    
    // Long Press Gesture Action
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
        let point = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(point , toCoordinateFromView: mapView)
        
        switch (sender.state) {
        case .Began:
            print("Began")
            print(coordinate)
            let pin = MKPointAnnotation()
            currentPin = pin
            currentPin.coordinate = coordinate
            mapView.addAnnotation(currentPin)
        case .Changed:
            print("Changed")
            print(coordinate)
            currentPin.coordinate = coordinate
        case .Ended:
            print("Ended")
            currentPin.coordinate = coordinate
            pins.append(currentPin)
        default:
            print(sender.state)
            return
        }
    }


}

