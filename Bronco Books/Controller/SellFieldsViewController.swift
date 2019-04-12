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
    
    var cancelButton: UIBarButtonItem!
    var postButton: UIBarButtonItem!
    
    var fieldsFromBarcodeScan: [String : Any]?
    var listingToPost: Listing?
    
    var publishDate: Date? = nil
    var listingPrice: Double? = nil
    var selectedPaymentMethod: String!
    
    let longDateFormatter = DateFormatter()
    let shortDateFormatter = DateFormatter()
    var longDateUsed: Bool!
    
    var imagesToUpload: [UIImage] = []
    var imageController: UIImagePickerController!
    
    var uploadProgressView: UIProgressView!
    
    var listingToEdit: Listing!
    
    var confirmAlertTitle: String!
    var confirmAlertMessage: String!
    
    var imagesIndicesToRemove = Set<Int>()
    var photosWereRemoved: Bool!
    var imageStartIndex: Int!
    
    var editingMode: Bool!
    
    var uploadedImages: [UIImage] = []
    
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
    @IBOutlet weak var setPriceButton: UIButton!
    
    @IBOutlet weak var paymentMethodPicker: UIPickerView!
    
    @IBOutlet weak var uploadPhotosButton: UIButton!
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
        
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        postButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(post))
        self.navigationItem.rightBarButtonItem = postButton
        
        imageController = UIImagePickerController()
        imageController.delegate = self
        
        paymentMethodPicker.dataSource = self
        paymentMethodPicker.delegate = self
        
        longDateFormatter.dateFormat = Constants.LongDateFormat
        shortDateFormatter.dateFormat = Constants.ShortDateFormat
        
        setupProgressBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // this is to prevent code from being called when the UIImagePickerController dismisses!
        guard let presentingViewController = previousViewController else {
            return
        }
        
        self.tabBarController?.tabBar.isHidden = true
        setUIComponents(enabled: true)
        
        imagesIndicesToRemove.removeAll()
        photosWereRemoved = false
        imageStartIndex = imagesToUpload.count
        
        editingMode = (presentingViewController == "ListingDetailViewController")
        if editingMode {
            fillFieldsOfListingToEdit()
        } else {
            autoFillTextbookFields()
        }
        setPostUpdateUI()
        
        publishDate = nil
        listingPrice = nil
        
        previousViewController = nil
    }
    
    // MARK: - Helper Functions
    
    func setupProgressBar() {
        uploadProgressView = UIProgressView(progressViewStyle: .bar)
        uploadProgressView.center = self.view.center
        uploadProgressView.trackTintColor = UIColor.lightGray
        uploadProgressView.tintColor = UIColor.blue
        uploadProgressView.isHidden = true
        // uploadProgressView.transform = uploadProgressView.transform.scaledBy(x: 2.25, y: 10)
        uploadProgressView.transform = uploadProgressView.transform.scaledBy(x: 1.5, y: 10)
        self.view.addSubview(uploadProgressView)
    }
    
    func autoFillTextbookFields() {
        guard let textbookFields = fieldsFromBarcodeScan else {
            return
        }
        
        titleField.text! = textbookFields[Constants.TextbookKeys.Title] as! String
        subtitleField.text = textbookFields[Constants.TextbookKeys.Subtitle] as? String
        authorsField.text! = (textbookFields[Constants.TextbookKeys.Authors] as! [String]).joined(separator: ", ")
        publisherField.text = textbookFields[Constants.TextbookKeys.Publisher] as? String
        publishedDateField.text = textbookFields[Constants.TextbookKeys.PublishedDate] as? String
        languageField.text = textbookFields[Constants.TextbookKeys.Language] as? String
        // do not fill editionField because Google Books API doesn't provide edition!
        if let pagesInt = textbookFields[Constants.TextbookKeys.Pages] as? Int {
            pagesField.text = String(pagesInt)
        } else {
            pagesField.text = nil
        }
        // do not fill bindingField because Google Books API doesn't provide binding!
    }
    
    func fillFieldsOfListingToEdit() {
        titleField.text! = listingToEdit.textbook.title
        subtitleField.text! = listingToEdit.textbook.subtitle
        authorsField.text! = (listingToEdit.textbook.authors).joined(separator: ", ")
        publisherField.text! = listingToEdit.textbook.publisher
        publishedDateField.text! = listingToEdit.textbook.publishedDate
        languageField.text! = listingToEdit.textbook.language
        editionField.text! = listingToEdit.textbook.edition
        pagesField.text! = String(listingToEdit.textbook.pages)
        bindingField.text! = listingToEdit.textbook.binding
        priceField.text! = String(listingToEdit.price)
    }
    
    func setUIComponents(enabled: Bool) {
        navigationItem.hidesBackButton = !enabled
        postButton.isEnabled = enabled
        setPriceButton.isEnabled = enabled
        uploadPhotosButton.isEnabled = enabled
        
        titleField.isEnabled = enabled
        subtitleField.isEnabled = enabled
        authorsField.isEnabled = enabled
        publisherField.isEnabled = enabled
        publishedDateField.isEnabled = enabled
        languageField.isEnabled = enabled
        editionField.isEnabled = enabled
        pagesField.isEnabled = enabled
        bindingField.isEnabled = enabled
        priceField.isEnabled = enabled
        
        paymentMethodPicker.isUserInteractionEnabled = enabled
        postListingPhotosCollection.isUserInteractionEnabled = enabled
    }
    
    func setPostUpdateUI() {
        if editingMode {
            self.title = "Edit Listing"
            postButton.title = "Update"
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = cancelButton
            
            confirmAlertTitle = "Confirm Update"
            confirmAlertMessage = "Do you want to update this listing with your changes?"
            
            selectedPaymentMethod = listingToEdit.paymentMethod
            let selectedIndex = Constants.PaymentMethods.List.firstIndex(of: selectedPaymentMethod)!
            paymentMethodPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
        } else {
            self.title = "Confirm Listing"
            postButton.title = "Post"
            self.navigationItem.hidesBackButton = false
            self.navigationItem.leftBarButtonItem = nil
            
            confirmAlertTitle = "Confirm Listing"
            confirmAlertMessage = "Do you want to post this listing for sale?"
            
            selectedPaymentMethod = Constants.PaymentMethods.Dummy
        }
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
        bindingField.text = ""
        priceField.text = ""
        imagesToUpload.removeAll()
        postListingPhotosCollection.reloadData()
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
        
        if selectedPaymentMethod == Constants.PaymentMethods.Dummy {
            return Constants.IncompleteFieldError.PaymentMethod
        }
        
        return nil
    }
    
    func removeSelectedPhotos() {
        var imagesRemoved = 0
        for indexToRemove in imagesIndicesToRemove.sorted() {
            imagesToUpload.remove(at: (indexToRemove - imagesRemoved))
            imagesRemoved += 1
        }
        imagesIndicesToRemove.removeAll()
        photosWereRemoved = true
        uploadPhotosButton.setTitle("Upload Photos", for: .normal)
        postListingPhotosCollection.reloadData()
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
            Constants.UserKeys.DisplayName : UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!,
            Constants.UserKeys.PhoneNumber : UserDefaults.standard.string(forKey: Constants.UserPhoneNumberKey)!
        ]
        
        let epochTimeSeconds = Int(NSDate().timeIntervalSince1970)
        
        var onSale = true
        if editingMode {
            onSale = listingToEdit.onSale
        }
        
        listingToPost = Listing(textbook: Textbook(dict: textbookDictionary), seller: User(dict: sellerDictionary), price: listingPrice!, paymentMethod: selectedPaymentMethod, epochTimePosted: epochTimeSeconds, onSale: onSale)
        
        addListingToFirebase(listingToAdd: listingToPost!.getDictionary())
    }
    
    func addListingToFirebase(listingToAdd: [String : Any?]) {
        let listingReference = editingMode ? databaseReferenceListings.child(listingToEdit.id!) : databaseReferenceListings.childByAutoId()
        listingReference.setValue(listingToAdd) { (error, databaseReference) in
            if error == nil {
                let key = databaseReference.key!
                if self.imagesToUpload.count > 0 {
                    // Cases to deal with:
                    //      1. The user removed images (and may have added images), so call remove
                    //      2. The user didn't add or remove any images, so don't call delete or add
                    //      3. The user only added images (and did not remove any images), so only call add
                    if self.photosWereRemoved {
                        // Case 1
                        DispatchQueue.main.async {
                            self.uploadProgressView.setProgress(Float(1) / Float(self.imagesToUpload.count + 2), animated: true)
                        }
                        self.deletePhotosFromFirebase(listingKey: key, photoIndex: 0)
                    } else if self.imageStartIndex == self.imagesToUpload.count {
                        // Case 2
                        DispatchQueue.main.async {
                            self.uploadProgressView.setProgress(1, animated: true)
                        }
                        self.uploadCompleted(with: self.imagesToUpload.count)
                    } else {
                        // Case 3
                        DispatchQueue.main.async {
                            self.uploadProgressView.setProgress(Float(1) / Float(self.imagesToUpload.count + 1), animated: true)
                        }
                        self.addPhotosToFirebase(listingKey: key, photoIndex: self.imageStartIndex, successfulUploads: self.imageStartIndex)
                    }
                } else if self.photosWereRemoved {
                    DispatchQueue.main.async {
                        self.uploadProgressView.setProgress(Float(1) / Float(2), animated: true)
                    }
                    self.deletePhotosFromFirebase(listingKey: key, photoIndex: 0)
                } else {
                    DispatchQueue.main.async {
                        self.uploadProgressView.setProgress(1, animated: true)
                    }
                    self.uploadCompleted(with: 0)
                }
            } else {
                DispatchQueue.main.async {
                    self.uploadProgressView.isHidden = true
                    self.setUIComponents(enabled: true)
                    self.showAlert(title: "Post Failed", message: "There was an error in posting the listing. Sorry about that!")
                }
            }
        }
    }
    
    func deletePhotosFromFirebase(listingKey: String, photoIndex: Int) {
        let fileName = "\(listingKey)_\(photoIndex).jpeg"
        let imageReference = storageReferenceImages.child(fileName)
        
        imageReference.delete { (error) in
            if error == nil && photoIndex + 1 < Constants.MaximumPhotoUpload {
                self.deletePhotosFromFirebase(listingKey: listingKey, photoIndex: photoIndex + 1)
            } else {
                DispatchQueue.main.async {
                    self.uploadProgressView.setProgress(Float(2) / Float(self.imagesToUpload.count + 2), animated: true)
                }
                if self.imagesToUpload.count > 0 {
                    self.addPhotosToFirebase(listingKey: listingKey, photoIndex: 0, successfulUploads: 0)
                } else {
                    self.uploadCompleted(with: 0)
                }
            }
        }
    }
    
    func addPhotosToFirebase(listingKey: String, photoIndex: Int, successfulUploads: Int) {
        let fileName = "\(listingKey)_\(photoIndex).jpeg"
        let imageReference = storageReferenceImages.child(fileName)
        
        let imageData = imagesToUpload[photoIndex].jpegData(compressionQuality: CGFloat(Constants.UploadCompressionQuality))
        
        let imageMetadata = StorageMetadata()
        imageMetadata.contentType = "image/jpeg"
        
        let uploadTask = imageReference.putData(imageData!, metadata: imageMetadata) { (metadata, error) in
            let newPhotoIndex = photoIndex + 1
            let newSuccessfulUploads = (metadata != nil) ? (successfulUploads + 1) : (successfulUploads)
            
            DispatchQueue.main.async {
                self.uploadProgressView.setProgress(Float(newPhotoIndex + 1) / Float(self.imagesToUpload.count + 1), animated: true)
            }
            
            if newPhotoIndex == self.imagesToUpload.count {
                self.uploadCompleted(with: newSuccessfulUploads)
            } else {
                self.addPhotosToFirebase(listingKey: listingKey, photoIndex: newPhotoIndex, successfulUploads: newSuccessfulUploads)
            }
        }
        
        uploadTask.resume()
    }
    
    func uploadCompleted(with successfulUploads: Int) {
        let postedTitle = editingMode ? "Listing Updated" : "Listing Posted"
        
        var postedMessage = "Your listing was successfully "
        postedMessage += (editingMode ? "updated" : "posted")
        if successfulUploads < imagesToUpload.count {
            postedMessage += ", but the images failed to upload"
        }
        postedMessage += "."
        
        DispatchQueue.main.async {
            self.uploadProgressView.isHidden = true
            self.uploadedImages = self.imagesToUpload
            self.clearFields()
            let alert = UIAlertController(title: postedTitle, message: postedMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default Action"), style: .default, handler: { (action) in
                if self.editingMode {
                    self.listingToPost!.setId(id: self.listingToEdit.id!)
                    self.performSegue(withIdentifier: "unwindToListingDetail", sender: self)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func setPriceTapped(_ sender: Any) {
        priceField.resignFirstResponder()
    }
    
    @IBAction func uploadPhotosTapped(_ sender: Any) {
        if imagesIndicesToRemove.count > 0 {
            let alert = UIAlertController(title: "Remove Selected Photos", message: "Are you sure you want to remove the selected photos?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.removeSelectedPhotos()
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard imagesToUpload.count < Constants.MaximumPhotoUpload else {
            showAlert(title: "Upload Limit Reached", message: "You can upload a maximum of \(Constants.MaximumPhotoUpload) images.")
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Unavailable", message: "Unable to detect a camera for this device.")
            return
        }
        
        imageController.sourceType = UIImagePickerController.SourceType.camera
        self.present(imageController, animated: true, completion: nil)
    }
    
    // MARK: - Objective-C Exposed Functions
    
    @objc func cancel() {
        let alert = UIAlertController(title: "Cancel Editing", message: "Are you sure you want to cancel editing? Your changes will not be saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func post() {
        // dismisses the keyboard without worrying about what is the first responder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if let errorMessage = fieldsAreIncomplete() {
            showAlert(title: "Incomplete Listing", message: errorMessage)
            return
        }
        
        let alert = UIAlertController(title: confirmAlertTitle, message: confirmAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.setUIComponents(enabled: false)
            self.uploadProgressView.setProgress(0, animated: true)
            self.uploadProgressView.isHidden = false
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
        return Constants.PaymentMethods.List.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.PaymentMethods.List[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPaymentMethod = Constants.PaymentMethods.List[row]
    }
    
}

// MARK: - Extension for UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension SellFieldsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imagesToUpload.append(image)
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
        return imagesToUpload.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postListingPhotoCell", for: indexPath) as! UploadedPhotoCollectionViewCell
        
        cell.imageView.image = imagesToUpload[indexPath.row]
        
        // decides whether to blur the photo (if the user has tapped the photo)
        if imagesIndicesToRemove.contains(indexPath.row) {
            cell.visualEffectView.isHidden = false
            cell.visualEffectView.effect = UIBlurEffect(style: .prominent)
        } else {
            cell.visualEffectView.isHidden = true
            cell.visualEffectView.effect = nil
        }
        
        return cell
    }
 
}

// MARK: - Extension for UICollectionViewDelegate

extension SellFieldsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        if imagesIndicesToRemove.contains(selectedIndex) {
            imagesIndicesToRemove.remove(selectedIndex)
        } else {
            imagesIndicesToRemove.insert(selectedIndex)
        }
        
        let buttonTitle = (imagesIndicesToRemove.isEmpty) ? "Upload Photos" : "Remove Selected"
        uploadPhotosButton.setTitle(buttonTitle, for: .normal)
        postListingPhotosCollection.reloadItems(at: [indexPath])
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
