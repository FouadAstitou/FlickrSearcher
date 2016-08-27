//
//  PhotosViewController.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

// Global variable for holding a search term.
var searchTerm: String!

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
    var store: PhotoStore!
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: { (nil) in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.searchTextField.becomeFirstResponder()
            
        })
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let photo = photoDataSource.flickrPhotos[indexPath.row]
        
        // Download the image data
        store.fetchImageForPhoto(photo) { (result) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                
                // The indexpath for the photo might have changed between the time the request started and finished, so find the most recent indeaxpath
                let photoIndex = self.photoDataSource.flickrPhotos.indexOf(photo)!
                let photoIndexPath = NSIndexPath(forRow: photoIndex, inSection: 0)
                
                // When the request finishes, only update the cell if it's still visible
                if let cell = collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(photo.image)
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
            
            store.fetchPhotosForSearchTerm() {
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
