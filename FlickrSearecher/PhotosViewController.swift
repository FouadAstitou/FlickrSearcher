//
//  PhotosViewController.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    let photoDataSource = PhotoDataSource()
    var store: PhotoStore!
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let photo = photoDataSource.flickrPhotos[indexPath.row]
        
        // Download the image data
        store.fetchImageForPhoto(photo) { (result) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                
                // The indexpath for the photo might have changed between the time the request started and finished, so find the most recent indeaxpath
                let photoIndex = self.photoDataSource.flickrPhotos.indexOf(photo)!
                let photoIndexPath = NSIndexPath(forRow: photoIndex, inSection: 0)
                
                // When the request finishes, only update the cell if it's still visible
                if let cell = collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(photo.image)
                }
            }
        }
    }
}