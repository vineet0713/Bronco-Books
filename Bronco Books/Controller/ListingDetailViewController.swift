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
        
        // allows these Labels to expand to 2 lines (only for very long text)
        titleLabel.numberOfLines = 2
        subtitleLabel.numberOfLines = 2
        authorsLabel.numberOfLines = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        // this is to prevent code from being called when the ImageDetailViewController pops back!
        guard previousViewController != nil else {
            return
        }
        
        let userEmail = UserDefaults.standard.string(forKey: Constants.UserEmailKey)!
        let userDisplayName = UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
        userPostedListing = (userEmail == displayListing.seller.email) && (userDisplayName == displayListing.seller.displayName)
        
        setUIComponents(enabled: true)
        setupLabelsAndButtons()
        finishImagesDownload(finished: false)
        retrieveImagesFromFirebase(counter: 0)
        
        previousViewController = nil
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
        
        priceLabel.text = getFormattedPrice(from: displayListing.price)
        
        let date = Date(timeIntervalSince1970: TimeInterval(exactly: displayListing.epochTimePosted)!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        listingPostedDateLabel.text = "Posted: " + dateFormatter.string(from: date)
        
        let buyerExists = (displayListing.buyer != nil)
        let listingNotPurchased = (displayListing.purchaseConfirmed == false)
        buyOrRemoveButton.setTitle(buyerExists ? "Confirm" : (userPostedListing ? (displayListing.onSale ? "Remove" : "Sell") : "Buy"), for: .normal)
        buyOrRemoveButton.isEnabled = (buyerExists == false || listingNotPurchased)
        contactOrEditButton.setTitle((userPostedListing && buyerExists == false && listingNotPurchased) ? "Edit Listing" : "Contact", for: .normal)
    }
    
    func getFormattedPrice(from price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: price as NSNumber)!
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
    
    func contact(seller: Bool) {
        let actionSheet = UIAlertController(title: "Choose Contact Method", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: Constants.ContactEmail, style: .default, handler: { (action) in
            self.contactWithEmail(seller: seller)
        }))
        actionSheet.addAction(UIAlertAction(title: Constants.ContactPhoneNumber, style: .default, handler: { (action) in
            self.composeTextMessage(seller, shouldRemoveListing: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func contactWithEmail(seller: Bool) {
        let actionSheet = UIAlertController(title: "Choose Email Template", message: nil, preferredStyle: .actionSheet)
        
        for option in (seller ? Constants.EmailSellerOptions : Constants.EmailBuyerOptions) {
            actionSheet.addAction(UIAlertAction(title: option, style: .default, handler: { (action) in
                self.composeEmail(with: option, seller)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func composeEmail(with contactOption: String, _ seller: Bool) {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Mail Not Available", message: "This device does not support functionality for sending an email.")
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Question About Listing on Bronco Books.")
        
        let recipient = seller ? displayListing.seller : displayListing.buyer!
        let recipientEmail = recipient.email
        let recipientName = getFirstName(from: recipient.displayName)
        
        let emailBody = seller ? Constants.SellerEmailBodies[contactOption]! : Constants.BuyerEmailBodies[contactOption]!
        let senderName = getFirstName(from: UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!)
        
        mail.setToRecipients([recipientEmail])
        mail.setMessageBody("\(Constants.EmailGreeting) \(recipientName),\n\n\(emailBody)\n\n\(Constants.EmailClosing),\n\(senderName)", isHTML: false)
        
        if #available(iOS 11.0, *) {
            mail.setPreferredSendingEmailAddress(UserDefaults.standard.string(forKey: Constants.UserEmailKey)!)
        }
        
        present(mail, animated: true)
    }
    
    func composeTextMessage(_ seller: Bool, shouldRemoveListing: Bool) {
        let recipient = seller ? displayListing.seller : displayListing.buyer!
        let messageString = Constants.MessagingPath + recipient.phoneNumber
        guard let messageURL = URL(string: messageString) else {
            showAlert(title: "Messaging Not Available", message: "This device does not support functionality for sending a text message.")
            return
        }
        
        var completion: ((Bool) -> Void)?
        if shouldRemoveListing {
            completion = { (success) in
                guard success else {
                    return
                }
                let successTitle = "Sale Pending"
                let successMessage = "This sale is now pending. The seller will have to confirm the purchase."
                self.removeListingFromSale(newOnSaleValue: false, setBuyer: true, successTitle, successMessage)
            }
        }
        
        UIApplication.shared.open(messageURL, options: [:], completionHandler: completion)
    }
    
    func finishImagesDownload(finished: Bool) {
        imageDownloadFinished = finished
        if userPostedListing {
            contactOrEditButton.isEnabled = finished
        }
    }
    
    // MARK: - Prompt Functions
    
    func promptRemoveListing() {
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
            
            self.removeListingFromSale(newOnSaleValue: !(self.displayListing.onSale), setBuyer: false, successTitle, successMessage)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func promptBuyListing() {
        let payment = displayListing.paymentMethod
        switch payment {
        case Constants.PaymentMethods.ApplePay:
            let seller = displayListing.seller.displayName
            
            let promptTitle = "Confirm Purchase"
            let promptMessage = "Do you want to buy this listing with Apple Pay? You will be redirected to the Messages app to send the payment to the seller (\(seller)) using Apple Pay Cash."
            
            let alert = UIAlertController(title: promptTitle, message: promptMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.composeTextMessage(true, shouldRemoveListing: true)
            }))
            self.present(alert, animated: true, completion: nil)
        case Constants.PaymentMethods.Cash,
             Constants.PaymentMethods.Check:
            // Cash or Check
            let paymentMethod = displayListing.paymentMethod.lowercased()
            let seller = displayListing.seller.displayName
            
            let promptTitle = "Confirm Purchase"
            let promptMessage = "Do you want to buy this listing with \(paymentMethod)? The purchase will be pending until the seller (\(seller)) confirms the sale."
            
            let alert = UIAlertController(title: promptTitle, message: promptMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                let successTitle = "Sale Pending"
                let successMessage = "This sale is now pending. The seller will have to confirm the purchase."
                self.removeListingFromSale(newOnSaleValue: false, setBuyer: true, successTitle, successMessage)
            }))
            self.present(alert, animated: true, completion: nil)
        default:
            // Google Pay or an invalid value (which would be a database issue)
            let alertTitle = "Incompatible Payment Method"
            let alertMessage = "\(payment) is incompatible with this device. Please contact the seller to request to change the payment method."
            showAlert(title: alertTitle, message: alertMessage)
        }
    }
    
    func promptConfirmPurchase(with buyerToPurchase: User) {
        let buyer = buyerToPurchase.displayName
        let method = displayListing.paymentMethod.lowercased()
        let amount = getFormattedPrice(from: displayListing.price)
        let message = "Do you want to confirm this purchase? This will confirm that \(buyer) has already used \(method) to pay you \(amount)."
        
        let alert = UIAlertController(title: "Confirm Purchase", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.setPurchaseConfirmed()
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    // this function is used either to remove a listing from sale, or to put a listing back up for sale
    func removeListingFromSale(newOnSaleValue: Bool, setBuyer: Bool, _ successTitle: String, _ successMessage: String) {
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
                if error != nil {
                    self.setUIComponents(enabled: true)
                }
                
                if setBuyer && error == nil {
                    self.setBuyer(successTitle, successMessage)
                } else {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: handler))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setBuyer(_ successTitle: String, _ successMessage: String) {
        let userDisplayName = UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
        let userEmail = UserDefaults.standard.string(forKey: Constants.UserEmailKey)!
        let userPhoneNumber = UserDefaults.standard.string(forKey: Constants.UserPhoneNumberKey)!
        let buyerDict = User(email: userEmail, displayName: userDisplayName, phoneNumber: userPhoneNumber).getDictionary()
        
        let databaseReferenceBuyer = databaseReferenceListings.child(displayListing.id!).child(Constants.ListingKeys.Buyer)
        databaseReferenceBuyer.setValue(buyerDict) { (error, databaseReference) in
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
    
    func setPurchaseConfirmed() {
        let databaseReferencePurchaseConfirmed = databaseReferenceListings.child(displayListing.id!).child(Constants.ListingKeys.PurchaseConfirmed)
        databaseReferencePurchaseConfirmed.setValue(true) { (error, databaseReference) in
            var title = "Update Failed"
            var message = "There was an error in updating the listing. Sorry about that!"
            var handler: ((UIAlertAction) -> Void)? = nil
            if error == nil {
                title = "Purchase Completed"
                message = "This listing has now been purchased!"
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
        if let validBuyer = displayListing.buyer {
            promptConfirmPurchase(with: validBuyer)
        } else if userPostedListing {
            promptRemoveListing()
        } else {
            promptBuyListing()
        }
    }
    
    @IBAction func contactOrEditTapped(_ sender: Any) {
        if displayListing.buyer != nil {
            contact(seller: false)
        } else if userPostedListing {
            self.performSegue(withIdentifier: "listingDetailToFieldsSegue", sender: self)
        } else {
            contact(seller: true)
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
