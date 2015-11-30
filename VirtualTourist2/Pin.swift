//
//  Pin.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/27/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject {
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let PageNumber = "pageNumber"
        static let Photos = "photos"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var pageNumber: NSNumber
    @NSManaged var photos: [Photo]
    @NSManaged var trip: Trip?
    var maxPhotos: Int?
    
    // Standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // The two argument init method
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }
    
    func loadPhotos() {
        let finder = FlickrFinder.sharedInstance()
        finder.search(self) {
            success, dict, error in
            if (success) {
                if let dictionary = dict {
                    dispatch_async(dispatch_get_main_queue(), {
                        let photo = Photo(dictionary: dictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                        photo.pin = self
                    })
                }
            } else {
                print(error)
            }
        }
    }
    
    func loadNewPage() {
        let newPageNumber: Int64 = pageNumber.longLongValue + 1
        pageNumber = NSNumber(longLong: newPageNumber)
        for photo in photos {
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(photo)
        }
        do {
            try CoreDataStackManager.sharedInstance().managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not delete \(error), \(error.userInfo)")
        }
        loadPhotos()
    }
    
    var coordinate: CLLocationCoordinate2D? {
        
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
}