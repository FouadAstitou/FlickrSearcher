//
//  FlickrPhoto.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class FlickrPhoto {
    
    let title: String
    let remoteThumbnailURL: NSURL
    let remotePhotoURL: NSURL
    let photoID: String
    let dateTaken: NSDate
    var image: UIImage?
    
    init(title: String, photoID: String, remoteThumbnailURL: NSURL, remotePhotoURL: NSURL, dateTaken: NSDate) {
        self.title = title
        self.photoID = photoID
        self.remotePhotoURL = remotePhotoURL
        self.remoteThumbnailURL = remoteThumbnailURL
        self.dateTaken = dateTaken
    }
}

// Extension to be able to use the indexof(_:) method on the flickrPhotos array.
extension FlickrPhoto: Equatable {}

// Custom operators have to be declared outside of the type decleration.
func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
    // Two photos are the same if they have the samephotoID
    return lhs.photoID == rhs.photoID
}