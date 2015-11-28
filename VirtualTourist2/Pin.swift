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
    var finder: FlickrFinder?
    
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
        finder = FlickrFinder(page: pageNumber)
        finder!.search(coordinate!) {
            success, photos, error in
            
            if (success) {
                // Update the collection on the main thread
                print ("\(self.finder!.photos.count) thumbs")
                dispatch_async(dispatch_get_main_queue()) {
                    var loadedPhotos = self.finder!.photos
                    if self.finder!.photos.count < PER_PAGE {
                        let placeholder = Placeholder()
                        for _ in self.finder!.photos.count...PER_PAGE {
                            loadedPhotos.append(placeholder)
                        }
                    }
                    self.photos = loadedPhotos as! [Photo]
                }
            } else {
                print(error)
            }
        }
    }
    
    var coordinate: CLLocationCoordinate2D? {
        
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
}