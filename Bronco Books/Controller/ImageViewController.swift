//
//  ImageViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/14/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

/*
 This class is only to test the functionality of ML Kit by displaying the matched image from ScanBarcodeViewController.
*/

class ImageViewController: UIViewController {
    
    // MARK: - Property
    
    var image: UIImage?
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = image
    }
    
}
