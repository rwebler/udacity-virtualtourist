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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let latitude = defaults.doubleForKey("latitude") as? Double {
            if let longitude = defaults.doubleForKey("longitude") as? Double {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapView.setCenterCoordinate(coordinate, animated: true)
                if let latitudeDelta = defaults.doubleForKey("latitudeDelta") as? Double {
                    if let longitudeDelta = defaults.doubleForKey("longitudeDelta") as? Double {
                        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
                        let region = MKCoordinateRegionMake(coordinate, span)
                        mapView.setRegion(region, animated: true)
                    }
                }
            }
        }
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
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("In regionDidChangeAnimated")
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(mapView.centerCoordinate.latitude, forKey: "latitude")
        defaults.setDouble(mapView.centerCoordinate.longitude, forKey: "longitude")
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        defaults.setDouble(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
    }
    
    func getMapViewCoordinateFromPoint(point: CGPoint) -> CLLocationCoordinate2D {
        return mapView.convertPoint(point, toCoordinateFromView: mapView)
    }
    
    // Long Press Gesture Action
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
        let coordinate = getMapViewCoordinateFromPoint(sender.locationInView(mapView))
        
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

