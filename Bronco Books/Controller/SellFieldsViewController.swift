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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Post", message: "Do you want to post this listing for sale?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.updateFirebaseValues()
            // performs UI updates on the Main Thread
            DispatchQueue.main.async {
                let title = "Nonexistent Feature"
                let message = "Posting listings is not implemented yet. Stay tuned!"
                self.showAlert(title: title, message: message, actionHandler: { (alert) in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
    
}
