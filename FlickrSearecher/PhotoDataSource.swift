//
//  PhotoDataSource.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    //MARK: - Properties
    // Array to store the Flickr Photos
    var flickrPhotos = [FlickrPhoto]()
    
    // An instance of photoStore.
    var photoStore = PhotoStore()
    
    // MARK: - numberOfItemsInSection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
    
    // MARK: - cellForItemAtIndexPath
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let identifier = "FlickrCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let photo = flickrPhotos[indexPath.item]
        cell.updateWithImage(photo.image)
        print(indexPath.item)
        // If you get close to the end of the collection, fetch more photo's.
        if indexPath.item == flickrPhotos.count - 20 {
           
            print("Detected the end of the collection")
            
            // Fetch the next batch of photos.
            photoStore.fetchPhotosForSearchTerm() {
                (photosResult) -> Void in
                
                // Calls the mainthread to update the UI.
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    switch photosResult {
                    case let .Success(photos):
                        print("Successfully found \(photos.count) recent photos.")
                        self.flickrPhotos.appendContentsOf(photos)
                    case let .Failure(error):
                        self.flickrPhotos.removeAll()
                        print("Error fetching more photos for search term \(error)")
                    }
                    collectionView.reloadSections(NSIndexSet(index: 0))
                }
            }
            
        }
        return cell
    }
}

