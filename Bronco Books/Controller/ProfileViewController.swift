//
//  ProfileViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/25/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

// Credit for icon image used in this tab bar item:
// Icons made by https://www.freepik.com/ from https://www.flaticon.com/ is licensed by http://creativecommons.org/licenses/by/3.0/

import UIKit

import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var logoutButton: UIBarButtonItem!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var profileListingArray: [Listing] = []
    var selectedProfileListing: Listing?
    
    var userDisplayName: String!
    var userEmail: String!
    var userPhoneNumber: String!
    
    let normalGreen = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1)
    
    // MARK - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var profileListingsTable: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = logoutButton
        
        profileListingsTable.dataSource = self
        profileListingsTable.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.profileListingsTable.center
        activityIndicator.hidesWhenStopped = true
        
        profileListingsTable.backgroundView = activityIndicator
        profileListingsTable.tableFooterView = UIView(frame: .zero)
        
        userDisplayName = UserDefaults.standard.string(forKey: Constants.UserDisplayNameKey)!
        userEmail = UserDefaults.standard.string(forKey: Constants.UserEmailKey)!
        userPhoneNumber = UserDefaults.standard.string(forKey: Constants.UserPhoneNumberKey)!
        
        setProfileLabels()
        
        setupChildAddedObserver()
        setupChildChangedObserver()
    }
    
    func setupChildAddedObserver() {
        let databaseReferenceListings = Database.database().reference().child(Constants.ListingPathString)
        
        let emailKey = Constants.ListingKeys.Seller + "/" + Constants.UserKeys.Email
        let referenceEmailQuery = databaseReferenceListings.queryOrdered(byChild: emailKey).queryEqual(toValue: self.userEmail)
        
        referenceEmailQuery.observe(.childAdded) { (snapshot) in
            self.startActivityIndicator()
            
            guard let listingDictionary = snapshot.value as? [String : Any?] else {
                // there is a problem in the database!
                self.stopActivityIndicator()
                return
            }
            
            let listing = Listing(dict: listingDictionary)
            listing.setId(id: snapshot.key)
            self.profileListingArray.insert(listing, at: 0)
            
            DispatchQueue.main.async {
                self.profileListingsTable.reloadData()
            }
            
            self.stopActivityIndicator()
        }
    }
    
    func setupChildChangedObserver() {
        let databaseReferenceListings = Database.database().reference().child(Constants.ListingPathString)
        
        let emailKey = Constants.ListingKeys.Seller + "/" + Constants.UserKeys.Email
        let referenceEmailQuery = databaseReferenceListings.queryOrdered(byChild: emailKey).queryEqual(toValue: self.userEmail)
        
        referenceEmailQuery.observe(.childChanged) { (snapshot) in
            self.startActivityIndicator()
            
            guard let listingDictionary = snapshot.value as? [String : Any?] else {
                // there is a problem in the database!
                self.stopActivityIndicator()
                return
            }
            
            let changedListing = Listing(dict: listingDictionary)
            changedListing.setId(id: snapshot.key)
            
            // instead of blindly adding listing, first check if it exists in listingArray (if it does, then update it)
            var found = false
            for index in 0..<self.profileListingArray.count {
                if self.profileListingArray[index].id == changedListing.id {
                    // if listing exists already in listingArray, then update it
                    self.profileListingArray[index] = changedListing
                    found = true
                    break
                }
            }
            if found == false {
                self.profileListingArray.insert(changedListing, at: 0)
            }
            
            DispatchQueue.main.async {
                self.profileListingsTable.reloadData()
            }
            
            self.stopActivityIndicator()
        }
    }
    
    // MARK: - Helper Functions
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setProfileLabels() {
        nameLabel.text = "Name: " + userDisplayName
        emailLabel.text = "Email: " + userEmail
        phoneNumberLabel.text = "Phone Number: " + getFormattedNumber(from: userPhoneNumber)
    }
    
    func getFormattedNumber(from numberString: String) -> String {
        var formattedNumber = "("
        for digit in numberString {
            formattedNumber.append(digit)
            if formattedNumber.count == 4 {
                formattedNumber.append(")-")
            } else if formattedNumber.count == 9 {
                formattedNumber.append("-")
            }
        }
        return formattedNumber
    }
    
    // MARK: - Objective-C Exposed Function
    
    @objc func logout() {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            GIDSignIn.sharedInstance().signOut()
            
            UserDefaults.standard.set(nil, forKey: Constants.UserEmailKey)
            UserDefaults.standard.set(nil, forKey: Constants.UserDisplayNameKey)
            UserDefaults.standard.set(nil, forKey: Constants.UserPhoneNumberKey)
            UserDefaults.standard.synchronize()
            
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListingDetailViewController
        destinationVC.previousViewController = "ProfileViewController"
        destinationVC.displayListing = selectedProfileListing!
    }
    
}

// MARK: - Extension for UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileListingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileListingsTable.dequeueReusableCell(withIdentifier: "profileListingCell") as! ProfileListingTableViewCell
        
        let listing = profileListingArray[indexPath.row]
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedPrice = formatter.string(from: listing.price as NSNumber)!
        
        let date = Date(timeIntervalSince1970: TimeInterval(exactly: listing.epochTimePosted)!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        
        let listingStatus: String
        let statusColor: UIColor
        
        if listing.onSale {
            listingStatus = "On Sale"
            statusColor = .blue
        } else if let listingBuyer = listing.buyer {
            listingStatus = (listing.purchaseConfirmed ? "Bought by " : "Purchase Requested from ") + listingBuyer.displayName
            statusColor = listing.purchaseConfirmed ? normalGreen : .orange
        } else {
            listingStatus = "Removed From Sale"
            statusColor = .red
        }
        
        cell.titleLabel.text = listing.textbook.title
        cell.priceLabel.text = "Price: \(formattedPrice) (Preferred: " + listing.paymentMethod + ")"
        cell.datePostedLabel.text = "Posted: " + dateFormatter.string(from: date)
        cell.statusLabel.text = listingStatus
        cell.statusLabel.textColor = statusColor
        
        return cell
    }
    
}

// MARK: - Extension for UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProfileListing = profileListingArray[indexPath.row]
        profileListingsTable.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "profileToListingDetailSegue", sender: self)
    }
    
}
