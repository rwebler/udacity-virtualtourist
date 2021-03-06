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
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var replaceButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!

    var pin: Pin?
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let center = pin!.coordinate {
            mapView.setCenterCoordinate(center, animated: true)
            mapView.setRegion(MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = center
            mapView.addAnnotation(pin)
        }
        
        replaceButton.enabled = false
        replaceButton.hidden = false
        noImageLabel.hidden = true
    }
    
    // Layout the collection view
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView!.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView!.collectionViewLayout = layout
        
        collectionView!.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadImages()
    }
    
    func loadImages() {
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoAlbumCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        var image = UIImage(named: "Placeholder")
        
        cell.imageView!.image = nil
        
        if let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Photo {
            
            // Set the Photo
            cell.photo = photo
            
            if photo.thumbnail != nil {
                image = photo.thumbnail
            } else {
                // Start the task that will eventually download the image
                let task = FlickrFinder.sharedInstance().taskForImage(photo.path!) { data, error in
                    
                    if let error = error {
                        print("Download error: \(error.localizedDescription)")
                    }
                    
                    if let data = data {
                        // Create the image
                        let image = UIImage(data: data)
                        
                        // update the model, so that the information gets cached
                        photo.thumbnail = image
                        
                        // update the cell later, on the main thread
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.imageView!.image = image
                        }
                    }
                }
                
                // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
                cell.taskToCancelifCellIsReused = task
            }
        }
        
        cell.imageView!.image = image
    }
    
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        if sectionInfo.numberOfObjects == 0 {
            replaceButton.hidden = true
            noImageLabel.hidden = false
            
        } else if sectionInfo.numberOfObjects == pin!.maxPhotos! {
            do {
                try sharedContext.save()
                replaceButton.enabled = true
                replaceButton.hidden = false
                noImageLabel.hidden = true
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("thumbnail", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        
        if replaceButton.enabled {
            if let photo = cell.photo {
                do {
                    sharedContext.deleteObject(photo)
                    cell.removeFromSuperview()
                    pin?.maxPhotos = (pin?.maxPhotos)! - 1
                    try sharedContext.save()
                } catch let error as NSError  {
                    print("Could not delete \(error), \(error.userInfo)")
                }
            }
        }
        self.collectionView!.reloadData()
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    // The second method may be called multiple times, once for each Photo object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            // Here we are noting that a new Photo instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            // Here we are noting that a Photo instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            // A Photo instance has changed after being created. Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after an image is downloaded from Flickr
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    @IBAction func replaceImages(sender: UIButton) {
        pin!.loadNewPage()
        replaceButton.enabled = false
    }
}