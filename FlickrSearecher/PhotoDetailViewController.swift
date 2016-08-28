//
//  PhotoDetailViewController.swift
//  FlickrSearecher
//
//  Created by Supervisor on 28-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit
import Social

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
    
    // MARK: - configureView
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
    
    // MARK: - showShareOptions
    @IBAction func showShareOptions(sender: AnyObject) {
        
        // Configure an action sheet to show the sharing options.
        let actionSheet = UIAlertController(title: "Share this photo", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.Default) { (action) -> Void in
            // Check if sharing to Twitter is possible.
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterComposeVC.addImage(self.imageView.image)
                self.presentViewController(twitterComposeVC, animated: true, completion: nil)
            }
            else {
                self.showAlert("Flickr Searcher", message: "You are not logged in to your Twitter account.")
            }
        }
        
        // Configure a new action to share on Facebook.
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (action) -> Void in
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                
                let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookComposeVC.addImage(self.imageView.image)
                self.presentViewController(facebookComposeVC, animated: true, completion: nil)
                
            }
            else {
                self.showAlert("Flickr Searcher", message: "You are not logged in to your facebook account.")
            }
        }
        
        // Configure a new action to show the UIActivityViewController
        let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.Default) { (action) -> Void in
            let activityViewController = UIActivityViewController(activityItems: [self.imageView.image!], applicationActivities: nil)
            
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            
        }
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(moreAction)
        actionSheet.addAction(dismissAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
        print("share pressed")
    }
}
