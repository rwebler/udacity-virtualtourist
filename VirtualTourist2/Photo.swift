//
//  Photo.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/27/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import CoreData
import UIKit

// MARK: - Shared Image Cache

struct Caches {
    static let imageCache = ImageCache()
}

class Photo: NSManagedObject {
    struct Keys {
        static let PhotoId = "photoId"
        static let Path = "path"
    }
    
    @NSManaged var photoId: String
    @NSManaged var path: String
    @NSManaged var pin: Pin?
    
    // Standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        if let imageData = NSData(contentsOfFile: path) {
            thumbnail = UIImage(data: imageData)
        } else {
            print("\(path) is not a valid image string")
        }
    }
    
    // The two argument init method
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        photoId = dictionary[Keys.PhotoId] as! String
        path = Caches.imageCache.pathForIdentifier(dictionary[Keys.Path] as! String)
    }
    
    var thumbnail: UIImage? {
        
        get {
            return Caches.imageCache.imageWithPath(path)
        }
        
        set {
            Caches.imageCache.storeImage(newValue, withPath: path)
        }
    }
    
    override func prepareForDeletion() {
        
        //Delete the associated image file when the Photo managed object is deleted.
        Caches.imageCache.deleteImageWithPath(path)
    }
}

func == (lhs: Photo, rhs: Photo) -> Bool {
    return lhs.photoId == rhs.photoId
}