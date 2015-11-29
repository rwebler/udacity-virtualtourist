//
//  ImageCache.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/27/15 over a file by Jason @ Udacity on 1/31/15
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            deleteImageWithIdentifier(identifier)
            
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImageJPEGRepresentation(image!, 0.9)!
        data.writeToFile(path, atomically: true)
    }
    
    //MARK: - Deleting images
    func deleteImageWithIdentifier(identifier: String) {
        let path = pathForIdentifier(identifier)

        inMemoryCache.removeObjectForKey(path)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch _ {}
    }

    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}