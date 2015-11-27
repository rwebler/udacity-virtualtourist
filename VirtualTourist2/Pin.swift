//
//  Pin.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/27/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import CoreData

class Pin: NSManagedObject {
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let PageNumber = "pageNumber"
        static let Photos = "photos"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var pageNumber: Int64
    @NSManaged var photos: [Photo]
    
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
        pageNumber = dictionary[Keys.PageNumber] as! Int64
    }
}