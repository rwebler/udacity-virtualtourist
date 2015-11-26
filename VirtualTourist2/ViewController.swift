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
    var deleteLabel: UILabel?

    var pins = [MKPointAnnotation]()
    var currentPin = MKPointAnnotation()
    var mapProperties: MapProperties?
    var arePinsEditable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        if let data = NSUserDefaults.standardUserDefaults().objectForKey(MapProperties.Keys.MapProperties) as? NSData {
            mapProperties = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? MapProperties
            print(mapProperties!.latitude)
            let center = CLLocationCoordinate2D(latitude: mapProperties!.latitude, longitude: mapProperties!.longitude)
            mapView.setCenterCoordinate(center, animated: true)
            mapView.setRegion(MKCoordinateRegionMake(center, MKCoordinateSpanMake(mapProperties!.latitudeDelta, mapProperties!.longitudeDelta)), animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        deleteLabel = UILabel(frame: CGRectMake(0, 0, view.frame.width, 55))
        deleteLabel!.center = CGPointMake(view.frame.width / 2, view.frame.height + (deleteLabel!.frame.height) / 2)
        deleteLabel!.textAlignment = NSTextAlignment.Center
        deleteLabel!.text = "Select pin to delete it"
        deleteLabel!.textColor = UIColor.whiteColor()
        deleteLabel!.backgroundColor = UIColor.redColor()
        self.view.addSubview(deleteLabel!)
        print(deleteLabel!.frame.origin.y)
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
    
    @IBAction func togglePinEditing(sender: UIBarButtonItem) {
        if (arePinsEditable) {
            view.frame.origin.y += deleteLabel!.frame.height
        } else {
            view.frame.origin.y -= deleteLabel!.frame.height
        }
        arePinsEditable = !arePinsEditable
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
        if arePinsEditable {
            
        } else {
            performSegueWithIdentifier("displayPhotoAlbum", sender: view)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("In regionDidChangeAnimated")
        mapProperties!.change(mapView)
        let data = NSKeyedArchiver.archivedDataWithRootObject(mapProperties!)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: MapProperties.Keys.MapProperties)
        print(mapProperties!.latitude)
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "displayPhotoAlbum") {
            let photoAlbumVC = segue.destinationViewController as! PhotoAlbumViewController
            let pin = sender as! MKAnnotationView
            photoAlbumVC.pinCenterCoordinate = getMapViewCoordinateFromPoint(pin.center)
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back to map"
            navigationItem.backBarButtonItem = backItem
        }
    }

}

