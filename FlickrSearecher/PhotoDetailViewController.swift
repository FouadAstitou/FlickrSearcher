//
//  PhotoDetailViewController.swift
//  FlickrSearecher
//
//  Created by Supervisor on 28-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    
    @IBOutlet var photoTitleLabel: UILabel!
    @IBOutlet var photoIDLabel: UILabel!
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
        photoStore.fetchImageForPhoto(flickrPhoto, thumbnail: false) { (result) -> Void in
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
        self.checkForReachability()
        configureView()
    }
    
    // MARK: - checkForReachability
    func checkForReachability() {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        reachability!.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must be on the main thread, like this:
            NSOperationQueue.mainQueue().addOperationWithBlock({
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            })
            
        }
        
        reachability!.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must be on the main thread, like this:
            NSOperationQueue.mainQueue().addOperationWithBlock({
                print("Not reachable")
                
                self.showAlert("No Internet Connection", message: "Make sure your device is connected to the internet.")
            })
        }
        
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    
    func configureView() {
        photoIDLabel.text = flickrPhoto.photoID
        photoTitleLabel.text = flickrPhoto.title
        dateTakenLabel.text = flickrPhoto.dateTaken
    }
    
    // MARK: showAlert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: { (nil) in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func shareTapped(sender: AnyObject) {
        print("share pressed")

    }
}
