//
//  FlickrAPI.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import Foundation

// Endpoint to hit on the Flickr Api.
enum Method: String {
    case Search = "flickr.photos.search"
}

enum PhotosResult {
    case Success([FlickrPhoto])
    case Failure(ErrorType)
}

enum FlickrError: ErrorType {
    case InvalidJSONData
}


struct FlickrAPI {
    
    // Base URL to use for constructing the completed URL.
    private static let baseURLString = "https://api.flickr.com/services/rest"
   
    // The APIKey to use when constructing the URL.
    private static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    // Date formatter
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    // Build up the flickrURL for a specific endpoint.
    private static func flickrURL(method method: Method, parameters: [String: String]?) -> NSURL {
        
        let components = NSURLComponents(string: baseURLString)!
        var queryItems = [NSURLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": APIKey,
        ]
        
        for (key, value) in baseParams {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems
        print(components.URL!)
        
        return components.URL!
    }
    
    // Method that returns a url with the specific endpoint: .search.
    static func photosForSearchTermURL() -> NSURL {
        return flickrURL(method: .Search, parameters: ["extras": "url_q,url_h,date_taken"])
    }
    
    // Covert an NSData instance to basic foundation objects.
    static func photosFromJSONData(data: NSData) -> PhotosResult {
        
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let
                jsonDictionary = jsonObject as? [NSObject:AnyObject],
                photos = jsonDictionary["photos"] as? [String:AnyObject],
                photosArray = photos["photo"] as? [[String:AnyObject]] else {
                    
                    // The JSON structure doesn't match our expectations
                    return .Failure(FlickrError.InvalidJSONData)
            }
            
            var finalPhotos = [FlickrPhoto]()
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                // We weren't able to parse any of the photos.
                // Maybe the JSON format for photos has changed.
                return .Failure(FlickrError.InvalidJSONData)
            }
            return .Success(finalPhotos)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    // Parse a JSON dictionary into a FlickrPhoto instance.
    static func photoFromJSONObject(json: [String : AnyObject]) -> FlickrPhoto? {
        guard let
            photoID = json["id"] as? String,
            title = json["title"] as? String,
            dateString = json["datetaken"] as? String,
            thumbnailURLString = json["url_q"] as? String,
            thumbnailURL = NSURL(string: thumbnailURLString),
            photoURLString = json["url_h"] as? String,
            photoURL = NSURL(string: photoURLString),
            dateTaken = dateFormatter.dateFromString(dateString) else {
                
                // Don't have enough information to construct a Photo
                return nil
        }
        
        return FlickrPhoto(title: title, photoID: photoID, remoteThumbnailURL: thumbnailURL, remotePhotoURL: photoURL, dateTaken: dateTaken)
    }
    
    
}
