//
//  ListingDetailViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class ListingDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var listing: Listing!
    
    // MARK: - IBOutlets
    
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = listing.textbook.title
    }
    
}
