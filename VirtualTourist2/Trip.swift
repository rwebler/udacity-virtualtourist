//
//  Trip.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/29/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import CoreData

class Trip: NSManagedObject {
    struct Keys {
        static let Name = "name"
        static let Pins = "pins"
    }
    
    @NSManaged var name: String
    @NSManaged var pins: [Pin]
    
    // Standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // The two argument init method
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Trip", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        name = dictionary[Keys.Name] as! String
    }
}
