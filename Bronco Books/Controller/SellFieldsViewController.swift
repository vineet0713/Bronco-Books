//
//  SellFieldsViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

import FirebaseDatabase

class SellFieldsViewController: UIViewController {
    
    // MARK: - Properties
    
    var listingToPost: Listing?
    
    var listingPrice: Double? = nil
    
    var selectedPaymentMethod: String!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLongField: UITextField!
    @IBOutlet weak var titleShortField: UITextField!
    @IBOutlet weak var authorsField: UITextField!
    @IBOutlet weak var publishDateField: UITextField!
    @IBOutlet weak var publisherField: UITextField!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var formatField: UITextField!
    @IBOutlet weak var editionField: UITextField!
    @IBOutlet weak var pagesField: UITextField!
    @IBOutlet weak var bindingField: UITextField!
    
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var paymentMethodPicker: UIPickerView!
    
    @IBOutlet weak var listingPhotosCollection: UICollectionView!
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // The delegates of all UITextFields are set in Main.storyboard!
        
        paymentMethodPicker.dataSource = self
        paymentMethodPicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedPaymentMethod = Constants.PreferredPaymentMethods[0]
    }
    
    // MARK: - Helper Functions
    
    func priceIsValid() -> Bool {
        if let doublePrice = Double(self.priceField.text!) {
            listingPrice = doublePrice
            return true
        } else {
            listingPrice = nil
            return false
        }
    }
    
    func fieldsAreIncomplete() -> String? {
        if titleLongField.text?.isEmpty == true && titleShortField.text?.isEmpty == true {
            return "Please enter a title for your textbook."
        }
        
        if authorsField.text?.isEmpty == true {
            return "Please enter 1 or more authors for your textbook."
        }
        
        if priceIsValid() == false {
            return "Please enter a valid price for your listing."
        }
        
        if selectedPaymentMethod == Constants.PreferredPaymentMethods[0] {
            return "Please enter a payment method for your listing."
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
        var title = titleShortField.text!
        var titleLong = titleLongField.text!
        if titleLong.isEmpty == false && title.isEmpty == true {
            title = titleLong
        } else if titleLong.isEmpty == true && title.isEmpty == false {
            titleLong = title
        } else if title.count > titleLong.count {
            title = titleLongField.text!
            titleLong = titleShortField.text!
        }
        
        let textbookDictionary: [String : Any] = [
            "title" : title,
            "titleLong" : titleLong,
            // converts comma-separated string into array of strings, then trims whitespace of each string in array
            "authors" : authorsField.text!.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "datePublished": publishDateField.text!,
            "publisher" : publisherField.text!,
            "language" : languageField.text!,
            "edition" : editionField.text!,
            "format" : formatField.text!,
            "pages" : ((pagesField.text?.isEmpty == false) ? Int(pagesField.text!)! : -1),
            "binding" : bindingField.text!
        ]
        
        let sellerDictionary: [String : Any] = [
            "email" : UserDefaults.standard.string(forKey: Constants.UserEmailKey)!,
            "displayName" : UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
        ]
        
        listingToPost = Listing(textbook: Textbook(dict: textbookDictionary), seller: Seller(dict: sellerDictionary), price: listingPrice!, preferredPaymentMethod: selectedPaymentMethod)
        
        addListingToFirebase(listingToAdd: listingToPost!.getDictionary())
    }
    
    func addListingToFirebase(listingToAdd: [String : Any]) {
        let databaseReferenceListings = Database.database().reference().child("listings")
        databaseReferenceListings.childByAutoId().setValue(listingToAdd) { (error, databaseReference) in
            if error == nil {
                // performs UI updates on the Main Thread
                DispatchQueue.main.async {
                    let title = "Listing Posted"
                    let message = "Your listing was successfully posted!"
                    
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default Action"), style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                // performs UI updates on the Main Thread
                DispatchQueue.main.async {
                    let title = "Post Failed"
                    let message = "There was an error in posting the listing. Sorry about that!"
                    self.showAlert(title: title, message: message)
                }
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTapped(_ sender: Any) {
        // dismisses the keyboard without worrying about what is the first responder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if let errorMessage = fieldsAreIncomplete() {
            showAlert(title: "Incomplete Listing", message: errorMessage)
            return
        }
        
        let alert = UIAlertController(title: "Confirm Post", message: "Do you want to post this listing for sale?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.generateListingToPost()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setPriceTapped(_ sender: Any) {
        priceField.resignFirstResponder()
    }
    
    @IBAction func uploadPhotosTapped(_ sender: Any) {
        
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
        return Constants.PreferredPaymentMethods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.PreferredPaymentMethods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPaymentMethod = Constants.PreferredPaymentMethods[row]
    }
    
}

// MARK: - Extension for UICollectionViewDataSource, UICollectionViewDelegate

/*extension SellFieldsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
 
}*/
