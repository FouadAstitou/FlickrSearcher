//
//  PhotoDataSource.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    // Array to store the Flickr Photos
    var flickrPhotos = [FlickrPhoto]()
    
    // MARK: - numberOfItemsInSection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
    
    // MARK: - cellForItemAtIndexPath
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let identifier = "FlickrCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        
        return cell
    }
}
