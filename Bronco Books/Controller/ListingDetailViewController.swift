//
//  ListingDetailViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

import FirebaseStorage

class ListingDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var storageReferenceImages: StorageReference!
    
    var displayListing: Listing!
    var userPostedListing: Bool!
    
    var retrievedImages: [UIImage] = []
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var bindingLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var listingPostedDateLabel: UILabel!
    
    @IBOutlet weak var buyOrRemoveButton: UIButton!
    @IBOutlet weak var contactOrEditButton: UIButton!
    
    @IBOutlet weak var displayListingPhotosCollection: UICollectionView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        storageReferenceImages = Storage.storage().reference().child("images")
        
        displayListingPhotosCollection.dataSource = self
        
        // This is for UICollectionViewDelegateFlowLayout (which inherits from UICollectionViewDelegate!)
        displayListingPhotosCollection.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userEmail = UserDefaults.standard.string(forKey: Constants.UserEmailKey)!
        let userDisplayName = UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
        userPostedListing = (userEmail == displayListing.seller.email) && (userDisplayName == displayListing.seller.displayName)
        
        setupLabelsAndButtons()
        retrieveImagesFromFirebase()
    }
    
    // MARK: - Helper Functions
    
    func setupLabelsAndButtons() {
        titleLabel.text = displayListing.textbook.title
        subtitleLabel.text = displayListing.textbook.subtitle
        
        let authors = displayListing.textbook.authors
        if authors.count == 1 {
            authorsLabel.text = "Author: " + authors[0]
        } else {
            authorsLabel.text = "Authors: " + authors.joined(separator: ", ")
        }
        
        publisherLabel.text = "Publisher: " + displayListing.textbook.publisher
        publishedDateLabel.text = displayListing.textbook.publishedDate
        languageLabel.text = displayListing.textbook.language
        
        if displayListing.textbook.edition != "" {
            editionLabel.text = "\(displayListing.textbook.edition) edition"
        } else {
            editionLabel.text = ""
        }
        
        pagesLabel.text = "\(displayListing.textbook.pages) pages"
        
        if displayListing.textbook.binding != "" {
            bindingLabel.text = displayListing.textbook.binding
        } else {
            bindingLabel.text = ""
        }
        
        paymentMethodLabel.text = displayListing.paymentMethod
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        priceLabel.text = formatter.string(from: displayListing.price as NSNumber)!
        
        let date = Date(timeIntervalSince1970: TimeInterval(exactly: displayListing.epochTimePosted)!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        listingPostedDateLabel.text = "Posted: " + dateFormatter.string(from: date)
        
        buyOrRemoveButton.setTitle(userPostedListing ? "Remove" : "Buy", for: .normal)
        contactOrEditButton.setTitle(userPostedListing ? "Edit Listing" : "Contact", for: .normal)
    }
    
    // MARK: - Backend Functions
    
    func retrieveImagesFromFirebase() {
        // TODO
    }
    
    // MARK: - IBActions
    
    @IBAction func buyOrRemoveTapped(_ sender: Any) {
        if userPostedListing {
            // TODO: Remove the listing from Firebase and go back to ListingsViewController
        } else {
            // TODO: Buy the listing!
        }
    }
    
    @IBAction func contactOrEditTapped(_ sender: Any) {
        if userPostedListing {
            // TODO: Edit the listing by going to SellFieldsViewController
        } else {
            // TODO: Contact the seller by composing a new message in Mail app
        }
    }
    
}

// MARK: - Extension for UICollectionViewDataSource

extension ListingDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return retrievedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailListingPhotoCell", for: indexPath) as! RetrievedPhotoCollectionViewCell
        
        cell.imageView.image = retrievedImages[indexPath.row]
        
        return cell
    }
    
}

// MARK: - Extension for UICollectionViewDelegateFlowLayout

extension ListingDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let cellsPerRow: CGFloat = 2
        
        return CGSize(width: (width - 10) / (cellsPerRow + 1), height: (width - 10) / (cellsPerRow + 1))
    }
    
}
