//
//  FlickrFinder.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/22/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "8c9cf6597e14d1cca163d920fa22ade7"
let EXTRAS = "url_s"
let TAGS = "travel,vacation,holiday"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let PER_PAGE = 30

class FlickrFinder {
    
    var page: NSNumber
    
    init (page: NSNumber?) {
        self.page = page ?? NSNumber(longLong: 1)
    }
    
    var photos = [Viewable]()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func search(coordinate: CLLocationCoordinate2D, completionHandler: (success: Bool, photos: [Viewable]?, error: String?) -> Void) {
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "lat": coordinate.latitude,
            "lon": coordinate.longitude,
            "tags": TAGS,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "page": String(page.longLongValue),
            "per_page": PER_PAGE
        ]
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments as! [String : AnyObject])
        print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) {
            (data: NSData?,  response: NSURLResponse?, downloadError: NSError?) in
            if let error = downloadError {
                print("Could not complete the request \(error)")
                completionHandler(success: false, photos: nil, error: "Could not complete the request \(error)")
            } else {
                /* 5 - Success! Parse the data */
                do {
                    let parsedResult: AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                    if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                        if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {

                            print("\(photoArray.count) photos")
                            for photoDictionary in photoArray {
                                /* 7 - Get the image url and id */
                                let imageUrlString = photoDictionary["url_s"] as? String
                                let imageId = photoDictionary["id"] as? String
                                let imageURL = NSURL(string: imageUrlString!)
                                
                                /* 8 - If an image exists at the url, set the image */
                                if let imageData = NSData(contentsOfURL: imageURL!) {
                                    let dictionary:[String: AnyObject] = [Photo.Keys.PhotoId: imageId!, Photo.Keys.Path: imageUrlString!]
                                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                    photo.thumbnail = UIImage(data: imageData)
                                    self.photos.append(photo)
                                    dispatch_async(dispatch_get_main_queue(), {
                                        completionHandler(success: true, photos: self.photos, error: nil)
                                    })
                                } else {
                                    print("\(imageUrlString!) is not a valid image")
                                }
                            }
                        } else {
                            print("Can't find key 'photo' in \(photosDictionary)")
                            completionHandler(success: false, photos: nil, error: "Cant find key 'photo' in \(photosDictionary)")
                        }
                    } else {
                        print("Can't find key 'photos' in \(parsedResult)")
                        completionHandler(success: false, photos: nil, error: "Cant find key 'photos' in \(parsedResult)")
                    }
                } catch {
                    print("Can't parse JSON from \(data)")
                    completionHandler(success: false, photos: nil, error: "Cant parse JSON from \(data)")
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}
