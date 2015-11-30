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

    func search(pin: Pin, completionHandler: (success: Bool, dict:[String: AnyObject]?, error: String?) -> Void) {
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "lat": pin.coordinate!.latitude,
            "lon": pin.coordinate!.longitude,
            "tags": TAGS,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "page": String(pin.pageNumber.longLongValue),
            "per_page": PER_PAGE
        ]
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments as! [String : AnyObject])
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) {
            (data: NSData?,  response: NSURLResponse?, downloadError: NSError?) in
            if let error = downloadError {
                print("Could not complete the request \(error)")
                completionHandler(success: false, dict: nil, error: "Could not complete the request \(error)")
            } else {
                /* 5 - Success! Parse the data */
                do {
                    let parsedResult: AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                    if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                        if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                            pin.maxPhotos = photoArray.count
                            for photoDictionary in photoArray {
                                /* 7 - Get the image url and id */
                                let imageUrlString = photoDictionary["url_s"] as? String
                                let imageId = photoDictionary["id"] as? String
                                let dictionary:[String: AnyObject] = [Photo.Keys.PhotoId: imageId!, Photo.Keys.Path: imageUrlString!]
                                completionHandler(success: true, dict: dictionary, error: nil)
                            }
                        } else {
                            print("Can't find key 'photo' in \(photosDictionary)")
                            completionHandler(success: false, dict: nil, error: "Cant find key 'photo' in \(photosDictionary)")
                        }
                    } else {
                        print("Can't find key 'photos' in \(parsedResult)")
                        completionHandler(success: false, dict: nil, error: "Cant find key 'photos' in \(parsedResult)")
                    }
                } catch {
                    print("Can't parse JSON from \(data)")
                    completionHandler(success: false, dict: nil, error: "Cant parse JSON from \(data)")
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
    }
    
    // MARK: - Task method to download images
    
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: filePath)
        
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(imageData: nil, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
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
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrFinder {
        
        struct Singleton {
            static var sharedInstance = FlickrFinder()
        }
        
        return Singleton.sharedInstance
    }
}
