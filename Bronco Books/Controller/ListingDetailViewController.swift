//
//  ListingDetailViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

import FirebaseStorage
import FirebaseDatabase

class ListingDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReferenceListings: DatabaseReference!
    var storageReferenceImages: StorageReference!
    
    var displayListing: Listing!
    var userPostedListing: Bool!
    
    var retrievedImages: [UIImage] = []
    var selectedImageIndex: Int!
    
    var previousViewController: String?
    
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
        
        databaseReferenceListings = Database.database().reference().child("listings")
        storageReferenceImages = Storage.storage().reference().child("images")
        
        displayListingPhotosCollection.dataSource = self
        
        // This is for UICollectionViewDelegateFlowLayout (which inherits from UICollectionViewDelegate!)
        displayListingPhotosCollection.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // this is to prevent code from being called when the ImageDetailViewController pops back!
        if previousViewController != nil {
            let userEmail = UserDefaults.standard.string(forKey: Constants.UserEmailKey)!
            let userDisplayName = UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
            userPostedListing = (userEmail == displayListing.seller.email) && (userDisplayName == displayListing.seller.displayName)
            
            setupLabelsAndButtons()
            retrieveImagesFromFirebase(counter: 0)
            
            previousViewController = nil
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ImageDetailViewController {
            destinationVC.photos = retrievedImages
            destinationVC.selectedIndex = selectedImageIndex
        }
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
    
    func retrieveImagesFromFirebase(counter: Int) {
        let fileName = displayListing.id! + "_\(counter).jpeg"
        let fileReference = storageReferenceImages.child(fileName)
        fileReference.getData(maxSize: Int64(Constants.MaximumFileSize)) { (data, error) in
            guard let imageData = data else {
                // no more images for this listing
                return
            }
            self.retrievedImages.append(UIImage(data: imageData)!)
            DispatchQueue.main.async {
                // self.noImagesLabel.isHidden = true
                self.displayListingPhotosCollection.reloadData()
            }
            self.retrieveImagesFromFirebase(counter: counter + 1)
        }
    }
    
    func removeListingFromSale() {
        let databaseReferenceOnSale = databaseReferenceListings.child(displayListing.id!).child(Constants.ListingKeys.OnSale)
        databaseReferenceOnSale.setValue(false) { (error, databaseReference) in
            var title = "Update Failed"
            var message = "There was an error in updating the listing. Sorry about that!"
            var handler: ((UIAlertAction) -> Void)? = nil
            if error == nil {
                title = "Listing Removed"
                message = "This listing is no longer up for sale."
                handler = { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: handler))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func buyOrRemoveTapped(_ sender: Any) {
        if userPostedListing {
            // remove the listing (set 'onSale' to false) from Firebase and go back to ListingsViewController
            let alert = UIAlertController(title: "Confirm Removal", message: "Are you sure that you want to remove this listing from sale?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.removeListingFromSale()
            }))
            self.present(alert, animated: true, completion: nil)
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

// MARK: - Extension for UICollectionViewDelegate

extension ListingDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageIndex = indexPath.row
        self.performSegue(withIdentifier: "listingDetailToImageSegue", sender: self)
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
