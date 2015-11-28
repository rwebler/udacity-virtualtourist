//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist2
//
//  Created by Rodrigo Webler on 11/23/15.
//  Copyright © 2015 Rodrigo Webler. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    func load(photo: Viewable) {
        print(photo)
        imageView.image = photo.thumbnail
    }
    
}
