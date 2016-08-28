//
//  PhotoStore.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum PhotoError: ErrorType {
    case ImageCreationError
}

class PhotoStore {
    
    // Compted property for NSURLSession.
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    // Fetch the photos from flickr using the user's search term.
    func fetchPhotosForSearchTerm(completion completion: (PhotosResult) -> Void) {
        
        let url = FlickrAPI.photosForSearchTermURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processPhotosForSearchTerm(data: data, error: error)
            completion(result)
        })
        task.resume()
    }
    
    // Process the JSON data that is returned from the webservice.
    func processPhotosForSearchTerm(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let jsonData = data else {
            return .Failure(error!)
        }
        
        return FlickrAPI.photosFromJSONData(jsonData)
    }
    
    // Download the image data from the webservice.
    func fetchImageForPhoto(flickrPhoto: FlickrPhoto, completion: (ImageResult) -> Void) {
        
        // If the image already exist don't download it again.
        if let image = flickrPhoto.image {
            completion(.Success(image))
            return
        }
        
        let photoURL = flickrPhoto.remoteThumbnailURL
        let request = NSURLRequest(URL: photoURL)
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .Success(image) = result {
              
                flickrPhoto.image = image
            }
            completion(result)
        }
        task.resume()
    }
    
    func fetchLargeImageForPhoto(flickrPhoto: FlickrPhoto, completion: (ImageResult) -> Void) {
        
        //        if let image = photo.image {
        //            completion(.Success(image))
        //            return
        //        }
        let photoURL = flickrPhoto.remotePhotoURL
        let request = NSURLRequest(URL: photoURL)
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .Success(image) = result {
                // compressing images to load faster (not working!)
                //                let imageData = UIImageJPEGRepresentation(image, 0.0)
                flickrPhoto.image = image //UIImage(data: imageData!)
            }
            completion(result)
        }
        task.resume()
    }

    
    // Process the data from the webservice into an image.
    func processImageRequest(data data: NSData?, error: NSError?) -> ImageResult {
        
        guard let
            imageData = data,
            image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .Failure(error!)
                }
                else {
                    return .Failure(PhotoError.ImageCreationError)
                }
        }
        
        return .Success(image)
    }
    
}

