//
//  PhotoDetailViewController.swift
//  FlickrSearecher
//
//  Created by Supervisor on 28-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    @IBOutlet var photoIDLabel: UILabel!
    @IBOutlet var photoTitleLabel: UILabel!
    @IBOutlet var dateTakenLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    // Date formatter
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    var flickrPhoto: FlickrPhoto!{
        didSet {
            navigationItem.title = flickrPhoto.title
        }
    }

    var photoStore: PhotoStore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        photoTitleLabel.text = flickrPhoto.title

    }
    
    override func viewWillAppear(animated: Bool) {
        photoIDLabel.text = flickrPhoto.photoID
        photoTitleLabel.text = flickrPhoto.title
        dateTakenLabel.text = flickrPhoto.dateTaken
        imageView.image = flickrPhoto.image
    }
    
    
}
