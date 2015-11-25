//
//  PhotoAlbumViewController.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/22/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!

    var pinCenterCoordinate: CLLocationCoordinate2D?
    var photos: [Photo]?
    var screenSize: CGRect!
    var side: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let center = pinCenterCoordinate {
            mapView.setCenterCoordinate(center, animated: true)
            mapView.setRegion(MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = center
            mapView.addAnnotation(pin)
        }

        let finder = FlickrFinder()
        finder.search(self.pinCenterCoordinate!) {
            success, photos, error in
            
            if (success) {
                // Update the collection on the main thread
                print ("\(finder.photos.count) thumbs")
                dispatch_async(dispatch_get_main_queue()) {
                    self.photos = finder.photos
                    self.collectionView!.reloadData()
                }
            } else {
                print(error)
            }
        }

        screenSize = UIScreen.mainScreen().bounds
        side = screenSize.width / 4

        collectionView!.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView!.reloadData()
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> Photo {
        return photos![indexPath.row]
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("In numberOfItemsInSection")
        if let photos = photos {
            return photos.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        print("In cellForItemAtIndexPath")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("thumbnail", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 0.5

        let photo = photos![indexPath.row]
        
        // Send data to cell
        cell.load(photo)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {
        print("In didSelectItemAtIndexPath")
    }
    
    
    // DelegateFlowLayout

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return CGSize(width: side, height: side)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsZero
    }
}