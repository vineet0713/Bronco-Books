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

import MessageUI

class ListingDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReferenceListings: DatabaseReference!
    var storageReferenceImages: StorageReference!
    
    var displayListing: Listing!
    var userPostedListing: Bool!
    
    var retrievedImages: [UIImage] = []
    var selectedImageIndex: Int!
    
    var previousViewController: String?
    
    var imageDownloadFinished: Bool!
    
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
        
        self.tabBarController?.tabBar.isHidden = false
        
        // this is to prevent code from being called when the ImageDetailViewController pops back!
        if previousViewController != nil {
            let userEmail = UserDefaults.standard.string(forKey: Constants.UserEmailKey)!
            let userDisplayName = UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
            userPostedListing = (userEmail == displayListing.seller.email) && (userDisplayName == displayListing.seller.displayName)
            
            setUIComponents(enabled: true)
            setupLabelsAndButtons()
            finishImagesDownload(finished: false)
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
        } else if let destinationVC = segue.destination as? SellFieldsViewController {
            destinationVC.previousViewController = "ListingDetailViewController"
            destinationVC.listingToEdit = displayListing
            destinationVC.imagesToUpload = retrievedImages
        }
    }
    
    // MARK: - Helper Functions
    
    func setUIComponents(enabled: Bool) {
        navigationItem.hidesBackButton = !enabled
        buyOrRemoveButton.isEnabled = enabled
        contactOrEditButton.isEnabled = enabled
        
        titleLabel.isEnabled = enabled
        subtitleLabel.isEnabled = enabled
        authorsLabel.isEnabled = enabled
        publisherLabel.isEnabled = enabled
        publishedDateLabel.isEnabled = enabled
        languageLabel.isEnabled = enabled
        editionLabel.isEnabled = enabled
        pagesLabel.isEnabled = enabled
        bindingLabel.isEnabled = enabled
        paymentMethodLabel.isEnabled = enabled
        priceLabel.isEnabled = enabled
        listingPostedDateLabel.isEnabled = enabled
        
        displayListingPhotosCollection.isUserInteractionEnabled = enabled
    }
    
    func setupLabelsAndButtons() {
        titleLabel.text = displayListing.textbook.title
        subtitleLabel.text = displayListing.textbook.subtitle
        
        let authors = displayListing.textbook.authors
        if authors.count == 1 {
            authorsLabel.text = "Author: " + authors[0]
        } else {
            authorsLabel.text = "Authors: " + authors.joined(separator: ", ")
        }
        
        publisherLabel.text = (displayListing.textbook.publisher == "") ? ("") : ("Publisher: " + displayListing.textbook.publisher)
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
        
        buyOrRemoveButton.setTitle(userPostedListing ? (displayListing.onSale ? "Remove" : "Sell") : "Buy", for: .normal)
        contactOrEditButton.setTitle(userPostedListing ? "Edit Listing" : "Contact", for: .normal)
    }
    
    func getFirstName(from fullName: String) -> String {
        var firstName = ""
        
        for char in fullName {
            if char == " " {
                break
            }
            firstName.append(char)
        }
        
        return firstName
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func contactSeller() {
        let actionSheet = UIAlertController(title: "Choose Message Type", message: "Select from the following templates:", preferredStyle: .actionSheet)
        
        for option in Constants.ContactSellerOptions {
            actionSheet.addAction(UIAlertAction(title: option, style: .default, handler: { (action) in
                self.composeEmail(with: option)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func composeEmail(with contactOption: String) {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Mail Not Available", message: "This device does not support functionality for sending an email.")
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Question About Listing on Bronco Books.")
        mail.setToRecipients([displayListing.seller.email])
        
        let sellerName = getFirstName(from: displayListing.seller.displayName)
        let emailBody = Constants.ContactSellerEmailBodies[contactOption]!
        let userName = getFirstName(from: UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!)
        mail.setMessageBody("\(Constants.EmailGreeting) \(sellerName),\n\n\(emailBody)\n\n\(Constants.EmailClosing),\n\(userName)", isHTML: false)
        
        if #available(iOS 11.0, *) {
            mail.setPreferredSendingEmailAddress(UserDefaults.standard.string(forKey: Constants.UserEmailKey)!)
        }
        
        present(mail, animated: true)
    }
    
    func finishImagesDownload(finished: Bool) {
        imageDownloadFinished = finished
        if userPostedListing {
            contactOrEditButton.isEnabled = finished
        }
    }
    
    // MARK: - Backend Functions
    
    func retrieveImagesFromFirebase(counter: Int) {
        let fileName = displayListing.id! + "_\(counter).jpeg"
        let fileReference = storageReferenceImages.child(fileName)
        fileReference.getData(maxSize: Int64(Constants.MaximumFileSize)) { (data, error) in
            guard let imageData = data else {
                // no more images for this listing
                self.finishImagesDownload(finished: true)
                return
            }
            
            self.retrievedImages.append(UIImage(data: imageData)!)
            DispatchQueue.main.async {
                self.displayListingPhotosCollection.reloadData()
            }
            
            if counter + 1 == Constants.MaximumPhotoUpload {
                self.finishImagesDownload(finished: true)
            } else {
                self.retrieveImagesFromFirebase(counter: counter + 1)
            }
        }
    }
    
    func removeListingFromSale(newOnSaleValue: Bool, _ successTitle: String, _ successMessage: String) {
        let databaseReferenceOnSale = databaseReferenceListings.child(displayListing.id!).child(Constants.ListingKeys.OnSale)
        databaseReferenceOnSale.setValue(newOnSaleValue) { (error, databaseReference) in
            var title = "Update Failed"
            var message = "There was an error in updating the listing. Sorry about that!"
            var handler: ((UIAlertAction) -> Void)? = nil
            if error == nil {
                title = successTitle
                message = successMessage
                handler = { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            DispatchQueue.main.async {
                if (error != nil) {
                    self.setUIComponents(enabled: true)
                }
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: handler))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func buyOrRemoveTapped(_ sender: Any) {
        if userPostedListing {
            let alertTitle = displayListing.onSale ? "Confirm Removal" : "Confirm Sell"
            var alertMessage = "Are you sure that you want to "
            alertMessage += (displayListing.onSale ? "remove this listing from sale?" : "post this listing back for sale?")
            
            // remove the listing (set 'onSale' to false) from Firebase and go back to ListingsViewController
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.setUIComponents(enabled: false)
                
                let successTitle = self.displayListing.onSale ? "Listing Removed" : "Listing On Sale"
                var successMessage = "This listing is "
                successMessage += (self.displayListing.onSale ? "no longer up for sale." : "back up for sale!")
                
                self.removeListingFromSale(newOnSaleValue: !(self.displayListing.onSale), successTitle, successMessage)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // TODO: Buy the listing!
            showAlert(title: "Nonexistent Feature", message: "The functionality to buy a listing has not been implemented yet. Stay tuned!")
        }
    }
    
    @IBAction func contactOrEditTapped(_ sender: Any) {
        if userPostedListing {
            self.performSegue(withIdentifier: "listingDetailToFieldsSegue", sender: self)
        } else {
            contactSeller()
        }
    }
    
    // Unwind Segue (to let SellFieldsViewController pass the updated Listing/images to this ViewController after editing)
    @IBAction func unwindFromSellFields(_ sender: UIStoryboardSegue) {
        guard let sourceVC = sender.source as? SellFieldsViewController else {
            return
        }
        
        displayListing = sourceVC.listingToPost
        setupLabelsAndButtons()
        
        retrievedImages = sourceVC.uploadedImages
        DispatchQueue.main.async {
            self.displayListingPhotosCollection.reloadData()
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
        guard imageDownloadFinished else {
            return
        }
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

// MARK: - Extension for MFMailComposeViewControllerDelegate

extension ListingDetailViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
