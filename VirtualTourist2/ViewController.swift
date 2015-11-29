//
//  ViewController.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/22/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var deleteLabel: UILabel?

    var pins = [MKPointAnnotation]()
    var currentPin = MKPointAnnotation()
    var mapProperties: MapProperties?
    var arePinsEditable = false
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    //Extra entity: Trip, a set of related Pins
    var currentTrip: Trip? {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        //currently fetching only the 'Default' trip
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Default")
        do {
            if let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Trip] {
                if fetchResults.count > 0 {
                    let trip = fetchResults[0]
                    return trip
                } else {
                    let trip = Trip(dictionary: [Trip.Keys.Name: "Default"], context: sharedContext)
                    try sharedContext.save()
                    return trip
                }
            }
        } catch let error as NSError  {
            print("Could not fetch/save \(error), \(error.userInfo)")
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        if let data = NSUserDefaults.standardUserDefaults().objectForKey(MapProperties.Keys.MapProperties) as? NSData {
            mapProperties = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? MapProperties
            print(mapProperties!.latitude)
            let center = CLLocationCoordinate2D(latitude: mapProperties!.latitude, longitude: mapProperties!.longitude)
            mapView.setCenterCoordinate(center, animated: true)
            mapView.setRegion(MKCoordinateRegionMake(center, MKCoordinateSpanMake(mapProperties!.latitudeDelta, mapProperties!.longitudeDelta)), animated: true)
        } else {
            //set to current map properties
            let center = mapView.centerCoordinate
            let span = mapView.region.span
            mapProperties = MapProperties(latitude: center.latitude, longitude: center.longitude, latitudeDelta: span.latitudeDelta, longitudeDelta: span.longitudeDelta)
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
        
        if let trip = self.currentTrip {
            for pin in trip.pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = pin.coordinate!
                
                print(annotation)
                
                pins.append(annotation)
            }
        }
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
            sender.title = "Edit"
        } else {
            view.frame.origin.y -= deleteLabel!.frame.height
            sender.title = "Done"
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
            if let pin = selectPinByCoordinate(view.annotation!.coordinate) {
                do {
                    sharedContext.deleteObject(pin)
                    mapView.removeAnnotation(view.annotation!)
                    try sharedContext.save()
                } catch let error as NSError  {
                    print("Could not delete \(error), \(error.userInfo)")
                }
            }
        } else {
            performSegueWithIdentifier("displayPhotoAlbum", sender: view)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("In regionDidChangeAnimated")
        if let mapProperties = mapProperties {
            mapProperties.change(mapView)
            let data = NSKeyedArchiver.archivedDataWithRootObject(mapProperties)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: MapProperties.Keys.MapProperties)
            print(mapProperties.latitude)
        }
        
    }
    
    func getMapViewCoordinateFromPoint(point: CGPoint) -> CLLocationCoordinate2D {
        return mapView.convertPoint(point, toCoordinateFromView: mapView)
    }
    
    // Long Press Gesture Action
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        if !arePinsEditable {
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
                
                let dictionary: [String: AnyObject] = [
                    Pin.Keys.Latitude: coordinate.latitude,
                    Pin.Keys.Longitude: coordinate.longitude
                ]
                
                let pin = Pin(dictionary: dictionary, context: sharedContext)
                
                do {
                    try sharedContext.save()
                    pins.append(currentPin)
                    pin.loadPhotos()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            default:
                print(sender.state)
                return
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "displayPhotoAlbum") {
            let photoAlbumVC = segue.destinationViewController as! PhotoAlbumViewController
            let view = sender as! MKAnnotationView
            if let pin = selectPinByCoordinate(view.annotation!.coordinate) {
                photoAlbumVC.pin = pin
                
                let backItem = UIBarButtonItem()
                backItem.title = "Back to map"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    func selectPinByCoordinate(coordinate: CLLocationCoordinate2D) -> Pin? {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let filter = NSPredicate(format:"abs(latitude - %f) < 0.0001 AND abs(longitude - %f) < 0.0001", coordinate.latitude, coordinate.longitude)
        print(filter)
        fetchRequest.predicate = filter
        
        do {
            if let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Pin] {
                print(fetchResults.count)
                let pin = fetchResults[0]
                return pin
            }
        } catch let error as NSError  {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }

}

