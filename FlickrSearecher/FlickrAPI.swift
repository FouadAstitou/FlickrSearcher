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

struct FlickrAPI {
    
    // Base URL to use for constructing the completed URL.
    private static let baseURLString = "https://api.flickr.com/services/rest"
   
    // The APIKey to use when constructing the URL.
    private static let APIKey = "a6d819499131071f158fd740860a5a88"
    
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
    
    static func searchResultPhotosURL() -> NSURL {
        return flickrURL(method: .Search, parameters: ["extras": "url_q,url_h,date_taken"])
    }

    
}
