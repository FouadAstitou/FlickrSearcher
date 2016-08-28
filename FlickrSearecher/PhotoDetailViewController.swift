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
    
    var flickrPhoto: FlickrPhoto!
    var photoStore: PhotoStore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoStore.fetchLargeImageForPhoto(flickrPhoto) { (result) -> Void in
            switch result {
            case let .Success(image):
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.imageView.image = image
                }
            case let .Failure(error):
                print(" Error fetching detail image for photo: \(error)")
            }
            
        }

    }
    
    override func viewWillAppear(animated: Bool) {
      configureView()
    }
    
    func configureView() {
        photoIDLabel.text = flickrPhoto.photoID
        photoTitleLabel.text = flickrPhoto.title ?? "No title available"
        dateTakenLabel.text = flickrPhoto.dateTaken ?? "No date available"
    }
    
    @IBAction func shareTapped(sender: AnyObject) {
        print("share pressed")

    }

    
}
