//
//  PhotosViewController.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

// Global variable for holding a search term.
var searchTerm: String?

// Global variable to hold an instance of Reachability.
var reachability: Reachability?

enum TextFieldPlaceHolderText: String {
    case Search = "Search"
    case Searching = "Searching..."
}

class PhotosViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchTextField: UITextField!
    
    // MARK: - Properties
    let photoDataSource = PhotoDataSource()
    let photoStore = PhotoStore()
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "flickr.png")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if the device is connected to the internet.
        checkForReachability()
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
    
    // MARK - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPhoto" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems()?.first {
                
                let flickrPhoto = photoDataSource.flickrPhotos[selectedIndexPath.row]
                
                let destinationVC = segue.destinationViewController as! PhotoDetailViewController
                destinationVC.flickrPhoto = flickrPhoto
                destinationVC.photoStore = photoStore
            }
        }
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
}

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let flickrPhoto = photoDataSource.flickrPhotos[indexPath.row]
        
        // Download the image data for a thumbnail.
        photoStore.fetchImageForPhoto(flickrPhoto,thumbnail: true) { (result) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                
                // The indexpath for the photo might have changed between the time the request started and finished, so find the most recent indeaxpath
                let photoIndex = self.photoDataSource.flickrPhotos.indexOf(flickrPhoto)!
                let photoIndexPath = NSIndexPath(forRow: photoIndex, inSection: 0)
                
                // When the request finishes, only update the cell if it's still visible
                if let cell = collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(flickrPhoto.image)
                }
            }
        }
    }
}

extension PhotosViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text!.isEmpty {
            self.showAlert("S😉rry", message: "No search term detected, please enter a search term.")
            return false
        }
        else {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            textField.addSubview(activityIndicator)
            activityIndicator.frame = textField.bounds
            activityIndicator.startAnimating()
            
            textField.placeholder = TextFieldPlaceHolderText.Searching.rawValue
            
            searchTerm = textField.text!
            
            photoStore.fetchPhotosForSearchTerm() {
                (photosResult) -> Void in
                
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    
                    switch photosResult {
                        
                    case let .Success(photos):
                        if photos.count == 0 {
                            self.showAlert("S😞rry", message: "No images found matching your search for: \(searchTerm), please try again.")
                        }
                        activityIndicator.removeFromSuperview()
                        textField.placeholder = TextFieldPlaceHolderText.Search.rawValue
                        
                        self.photoDataSource.flickrPhotos = photos
                        print("Successfully found \(photos.count) recent photos.")
                        
                    case let .Failure(error):
                        self.checkForReachability()
                        activityIndicator.removeFromSuperview()
                        textField.placeholder = TextFieldPlaceHolderText.Search.rawValue
                        self.photoDataSource.flickrPhotos.removeAll()
                        print("Error fetching photo's for search term \(error)")
                    }
                    self.collectionView.reloadSections(NSIndexSet(index: 0))
                }
                
            }
            textField.text = nil
            textField.resignFirstResponder()
            self.collectionView?.backgroundColor = UIColor.whiteColor()
            
            return true
        }
    }
}
