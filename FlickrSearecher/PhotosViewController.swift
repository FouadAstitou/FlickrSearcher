//
//  PhotosViewController.swift
//  FlickrSearecher
//
//  Created by Supervisor on 27-08-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    let photoDataSource = PhotoDataSource()
    var store: PhotoStore!
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
    }
}
