//
//  SellFieldsViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit
import Foundation

import FirebaseDatabase
import FirebaseStorage

class SellFieldsViewController: UIViewController {
    
    // MARK: - Properties
    
    var databaseReferenceListings: DatabaseReference!
    var storageReferenceImages: StorageReference!
    
    var previousViewController: String?
    
    var postButton: UIBarButtonItem!
    
    var fieldsFromBarcodeScan: [String : Any]?
    var listingToPost: Listing?
    
    var publishDate: Date? = nil
    var listingPrice: Double? = nil
    var selectedPaymentMethod: String!
    
    let longDateFormatter = DateFormatter()
    let shortDateFormatter = DateFormatter()
    var longDateUsed: Bool!
    
    var uploadedImages: [UIImage] = []
    var imageController: UIImagePickerController!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var subtitleField: UITextField!
    @IBOutlet weak var authorsField: UITextField!
    @IBOutlet weak var publisherField: UITextField!
    @IBOutlet weak var publishedDateField: UITextField!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var editionField: UITextField!
    @IBOutlet weak var pagesField: UITextField!
    @IBOutlet weak var bindingField: UITextField!
    
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var paymentMethodPicker: UIPickerView!
    
    @IBOutlet weak var postListingPhotosCollection: UICollectionView!
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        databaseReferenceListings = Database.database().reference().child("listings")
        storageReferenceImages = Storage.storage().reference().child("images")
        
        // The delegates of all UITextFields are set in Main.storyboard!
        
        postListingPhotosCollection.dataSource = self
        
        // This is for UICollectionViewDelegateFlowLayout (which inherits from UICollectionViewDelegate!)
        postListingPhotosCollection.delegate = self
        
        self.title = "Confirm Listing"
        
        postButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(post))
        self.navigationItem.rightBarButtonItem = postButton
        
        imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerController.SourceType.camera
        
        paymentMethodPicker.dataSource = self
        paymentMethodPicker.delegate = self
        
        longDateFormatter.dateFormat = Constants.LongDateFormat
        shortDateFormatter.dateFormat = Constants.ShortDateFormat
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // this is to prevent code from being called when the UIImagePickerController dismisses!
        if previousViewController != nil {
            self.tabBarController?.tabBar.isHidden = true
            self.postButton.isEnabled = true
            
            autoFillTextbookFields()
            
            publishDate = nil
            listingPrice = nil
            selectedPaymentMethod = Constants.PaymentMethods[0]
            
            previousViewController = nil
        }
    }
    
    // MARK: - Helper Functions
    
    func autoFillTextbookFields() {
        guard let textbookFields = fieldsFromBarcodeScan else {
            return
        }
        
        titleField.text! = textbookFields[Constants.TextbookKeys.Title] as! String
        subtitleField.text! = textbookFields[Constants.TextbookKeys.Subtitle] as! String
        authorsField.text! = (textbookFields[Constants.TextbookKeys.Authors] as! [String]).joined(separator: ", ")
        publisherField.text! = textbookFields[Constants.TextbookKeys.Publisher] as! String
        publishedDateField.text! = textbookFields[Constants.TextbookKeys.PublishedDate] as! String
        languageField.text! = textbookFields[Constants.TextbookKeys.Language] as! String
        // do not fill editionField because Google Books API doesn't provide edition!
        pagesField.text! = String(textbookFields[Constants.TextbookKeys.Pages] as! Int)
        // do not fill bindingField because Google Books API doesn't provide binding!
    }
    
    func clearFields() {
        titleField.text = ""
        subtitleField.text = ""
        authorsField.text = ""
        publisherField.text = ""
        publishedDateField.text = ""
        languageField.text = ""
        editionField.text = ""
        pagesField.text = ""
        priceField.text = ""
        uploadedImages.removeAll()
    }
    
    func publishedDateIsValid() -> Bool {
        if Int(publishedDateField.text!.prefix(4)) == nil {
            return false
        }
        
        if let longDate = longDateFormatter.date(from: publishedDateField.text!) {
            publishDate = longDate
            longDateUsed = true
            return true
        } else if let shortDate = shortDateFormatter.date(from: publishedDateField.text!) {
            publishDate = shortDate
            longDateUsed = false
            return true
        } else {
            publishDate = nil
            return false
        }
    }
    
    func pagesAreValid() -> Bool {
        return (Int(pagesField.text!) != nil)
    }
    
    func priceIsValid() -> Bool {
        if let doublePrice = Double(priceField.text!) {
            listingPrice = doublePrice
            return true
        } else {
            listingPrice = nil
            return false
        }
    }
    
    func fieldsAreIncomplete() -> String? {
        if titleField.text?.isEmpty == true {
            return Constants.IncompleteFieldError.Title
        }
        
        if authorsField.text?.isEmpty == true {
            return Constants.IncompleteFieldError.Authors
        }
        
        if publishedDateIsValid() == false {
            return Constants.IncompleteFieldError.PublishedDate
        }
        
        if pagesAreValid() == false {
            return Constants.IncompleteFieldError.Pages
        }
        
        if priceIsValid() == false {
            return Constants.IncompleteFieldError.Price
        }
        
        if selectedPaymentMethod == Constants.PaymentMethods[0] {
            return Constants.IncompleteFieldError.PaymentMethod
        }
        
        return nil
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Backend Functions
    
    func generateListingToPost() {
        // converts comma-separated string into array of strings, then trims whitespace of each string in array
        let authorArray = authorsField.text!.components(separatedBy: ",")
        let authorArrayTrimmed = authorArray.map { (author) -> String in
            return author.trimmingCharacters(in: .whitespaces)
        }
        
        let textbookDictionary: [String : Any] = [
            Constants.TextbookKeys.Title : titleField.text!,
            Constants.TextbookKeys.Subtitle : subtitleField.text!,
            Constants.TextbookKeys.Authors : authorArrayTrimmed,
            Constants.TextbookKeys.Publisher : publisherField.text!,
            Constants.TextbookKeys.PublishedDate : (longDateUsed ? longDateFormatter : shortDateFormatter).string(from: publishDate!),
            Constants.TextbookKeys.Language : languageField.text!,
            Constants.TextbookKeys.Edition : editionField.text!,
            Constants.TextbookKeys.Pages : Int(pagesField.text!)!,
            Constants.TextbookKeys.Binding : bindingField.text!
        ]
        
        let sellerDictionary: [String : Any] = [
            Constants.UserKeys.Email : UserDefaults.standard.string(forKey: Constants.UserEmailKey)!,
            Constants.UserKeys.DisplayName : UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
        ]
        
        let epochTimeSeconds = Int(NSDate().timeIntervalSince1970)
        
        listingToPost = Listing(textbook: Textbook(dict: textbookDictionary), seller: User(dict: sellerDictionary), price: listingPrice!, paymentMethod: selectedPaymentMethod, epochTimePosted: epochTimeSeconds)
        
        addListingToFirebase(listingToAdd: listingToPost!.getDictionary())
    }
    
    func addListingToFirebase(listingToAdd: [String : Any?]) {
        databaseReferenceListings.childByAutoId().setValue(listingToAdd) { (error, databaseReference) in
            if error == nil {
                self.addPhotosToFirebase(listingKey: databaseReference.key!, photoIndex: 0, successfulUploads: 0)
            } else {
                DispatchQueue.main.async {
                    self.postButton.isEnabled = true
                    self.showAlert(title: "Post Failed", message: "There was an error in posting the listing. Sorry about that!")
                }
            }
        }
    }
    
    func addPhotosToFirebase(listingKey: String, photoIndex: Int, successfulUploads: Int) {
        let imageData = uploadedImages[photoIndex].jpegData(compressionQuality: CGFloat(Constants.UploadCompressionQuality))
        let fileName = "\(listingKey)_\(photoIndex).jpeg"
        
        let imageReference = storageReferenceImages.child(fileName)
        let uploadTask = imageReference.putData(imageData!, metadata: nil) { (metadata, error) in
            let newPhotoIndex = photoIndex + 1
            let newSuccessfulUploads = (metadata != nil) ? (successfulUploads + 1) : (successfulUploads)
            
            if newPhotoIndex == self.uploadedImages.count {
                // all photos have attempted to upload
                self.uploadCompleted(with: newSuccessfulUploads)
            } else {
                // there are still photos to be uploaded
                self.addPhotosToFirebase(listingKey: listingKey, photoIndex: newPhotoIndex, successfulUploads: newSuccessfulUploads)
            }
        }
        
        uploadTask.resume()
    }
    
    func uploadCompleted(with successfulUploads: Int) {
        var postedMessage = "Your listing was successfully posted"
        if successfulUploads < uploadedImages.count {
            postedMessage += ", but the images failed to upload"
        }
        postedMessage += "."
        
        DispatchQueue.main.async {
            self.clearFields()
            let alert = UIAlertController(title: "Listing Posted", message: postedMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default Action"), style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func setPriceTapped(_ sender: Any) {
        priceField.resignFirstResponder()
    }
    
    @IBAction func uploadPhotosTapped(_ sender: Any) {
        guard uploadedImages.count < Constants.MaximumPhotoUpload else {
            showAlert(title: "Upload Limit Exceeded", message: "You can upload a maximum of \(Constants.MaximumPhotoUpload) images.")
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Unavailable", message: "Unable to detect a camera for this device.")
            return
        }
        self.present(imageController, animated: true, completion: nil)
    }
    
    // MARK: - Objective-C Exposed Function
    
    @objc func post() {
        // dismisses the keyboard without worrying about what is the first responder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if let errorMessage = fieldsAreIncomplete() {
            showAlert(title: "Incomplete Listing", message: errorMessage)
            return
        }
        
        let alert = UIAlertController(title: "Confirm Post", message: "Do you want to post this listing for sale?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.postButton.isEnabled = false
            self.generateListingToPost()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Extension for UITextFieldDelegate

extension SellFieldsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Extension for UIPickerViewDataSource, UIPickerViewDelegate

extension SellFieldsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.PaymentMethods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.PaymentMethods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPaymentMethod = Constants.PaymentMethods[row]
    }
    
}

// MARK: - Extension for UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension SellFieldsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        uploadedImages.append(image)
        postListingPhotosCollection.reloadData()
        imageController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageController.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Extension for UICollectionViewDataSource

extension SellFieldsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploadedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postListingPhotoCell", for: indexPath) as! UploadedPhotoCollectionViewCell
        
        cell.imageView.image = uploadedImages[indexPath.row]
        
        return cell
    }
 
}

// MARK: - Extension for UICollectionViewDelegateFlowLayout

extension SellFieldsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let cellsPerRow: CGFloat = 2
        
        return CGSize(width: (width - 10) / (cellsPerRow + 1), height: (width - 10) / (cellsPerRow + 1))
    }
    
}
