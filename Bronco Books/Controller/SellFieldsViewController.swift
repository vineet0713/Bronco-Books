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
    
    var listingToPost: Listing?
    
    let preferredPaymentMethods = ["[Select Preferred Payment Method]", "Apple Pay", "Cash", "Check"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // The delegates of all UITextFields are set in Storyboard!
        
        paymentMethodPicker.dataSource = self
        paymentMethodPicker.delegate = self
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Post", message: "Do you want to post this listing for sale?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let sampleTextbook = Textbook(title: "sampletitle", titleLong: "sampletitle very very very long", authors: ["author1", "author2"], datePublished: "2/1/2019", publisher: "Puffin", language: "French", edition: "3rd", format: "sampleformat", pages: 239, binding: "hardcover")
            self.listingToPost = Listing(seller: "vjoshi", price: 29.49, textbook: sampleTextbook, preferredPaymentMethod: "Cash")
            
            self.addListingToFirebase(listingToAdd: self.listingToPost!.getDictionary())
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setPriceTapped(_ sender: Any) {
        let priceEntered = priceField.text
        if priceEntered?.isEmpty == false && priceEntered?.prefix(1) != "$" {
            priceField.text = "$" + priceEntered!
        }
        // also make sure price is in proper format (Ex. "9.9" should be changed to "9.90")
        priceField.resignFirstResponder()
    }
    
    @IBAction func uploadPhotosTapped(_ sender: Any) {
        
    }
    
    func showAlert(title: String, message: String, action: String = "OK", actionHandler: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(action, comment: "Default action"), style: .`default`, handler: actionHandler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addFirebaseKey() {
        let databaseReference = Database.database().reference()
        databaseReference.child("testkey").setValue("my iOS key!")
    }
    
    func readFirebaseData() {
        let databaseReference = Database.database().reference()
        databaseReference.child("testkey").observeSingleEvent(of: .value) { (snapshot) in
            // this closure runs when the data is run
            // the DatabaseSnapshot 'snapshot' contains the results of the database call
            let value = snapshot.value as! String
            print(value)
        }
    }
    
    func updateFirebaseValues() {
        let updates = [
            "listings":"NEW array of Listing objects",
            "testkey":"MY NEW IOS TEST KEY!",
            "users":"NEW array of User objects (with listings bought/sold, etc.)"
        ]
        
        // if a key/value in 'updates' isn't in Firebase, it will automatically be added!
        let databaseReference = Database.database().reference()
        databaseReference.updateChildValues(updates)
    }
    
    func removeFirebaseValue() {
        let databaseReference = Database.database().reference()
        databaseReference.child("testkey").removeValue()
    }
    
    func addListingToFirebase(listingToAdd: [String : Any]) {
        let databaseReferenceListings = Database.database().reference().child("listings")
        databaseReferenceListings.childByAutoId().setValue(listingToAdd) { (error, databaseReference) in
            if error == nil {
                // performs UI updates on the Main Thread
                DispatchQueue.main.async {
                    let title = "Listing Posted"
                    let message = "Your listing was successfully posted!"
                    self.showAlert(title: title, message: message, actionHandler: { (alert) in
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            } else {
                // performs UI updates on the Main Thread
                DispatchQueue.main.async {
                    let title = "Post Failed"
                    let message = "There was an error in posting the listing. Sorry about that!"
                    self.showAlert(title: title, message: message, actionHandler: { (alert) in
                        // do nothing
                    })
                }
            }
        }
        // databaseReferenceListings.child("LISTING NAME?").setValue(listingToAdd)
    }
    
    func readListingsFromFirebase() {
        let databaseReferenceListings = Database.database().reference().child("listings")
        databaseReferenceListings.observeSingleEvent(of: .value) { (snapshot) in
            let listingArray = snapshot.value as! [String : Any]
            print(listingArray)
        }
    }
    
}

extension SellFieldsViewController: UITextFieldDelegate {
    
    // MARK: Keyboard Notification functions
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        /*if bottomEditing {
            // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
            self.view.frame.origin.y = self.getKeyboardHeight(notification) * -1
        }*/
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        /*if bottomEditing {
            // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
            self.view.frame.origin.y = 0
        }*/
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue  // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false*/
        
        textField.resignFirstResponder()
        return true
    }
    
}

extension SellFieldsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return preferredPaymentMethods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return preferredPaymentMethods[row]
    }
    
}

/*extension SellFieldsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
    
}*/
