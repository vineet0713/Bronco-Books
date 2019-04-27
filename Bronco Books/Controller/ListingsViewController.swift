//
//  ListingsViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

// Credit for icon image used in this tab bar item:
// Icons made by https://www.flaticon.com/authors/google from https://www.flaticon.com/ is licensed by http://creativecommons.org/licenses/by/3.0/

import UIKit

import FirebaseDatabase

class ListingsViewController: UIViewController {
    
    // MARK: - Properties
    
    var activityIndicator: UIActivityIndicatorView!
    
    var filteredListings: [Listing] = []
    var searching: Bool = false
    var searchText: String = ""
    var selectedScope: Int = 0
    
    var listingArray: [Listing] = []
    var selectedListing: Listing?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listingsTable: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        
        listingsTable.dataSource = self
        listingsTable.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        
        listingsTable.backgroundView = activityIndicator
        listingsTable.tableFooterView = UIView(frame: .zero)
        
        startActivityIndicator()
        setupChildAddedObserver()
        setupChildChangedObserver()
    }
    
    // MARK: - Firebase Setup Functions
    
    func setupChildAddedObserver() {
        let databaseReferenceListings = Database.database().reference().child(Constants.ListingPathString)
        databaseReferenceListings.observe(.childAdded) { (snapshot) in
            self.startActivityIndicator()
            
            guard let listingDictionary = snapshot.value as? [String : Any?] else {
                // there is a problem in the database!
                self.stopActivityIndicator()
                return
            }
            
            let onSale = listingDictionary[Constants.ListingKeys.OnSale] as! Bool
            if onSale {
                let listing = Listing(dict: listingDictionary)
                listing.setId(id: snapshot.key)
                self.listingArray.insert(listing, at: 0)
                
                DispatchQueue.main.async {
                    if self.searching {
                        self.reloadSearchResults()
                    } else {
                        self.listingsTable.reloadData()
                    }
                }
            }
            
            self.stopActivityIndicator()
        }
    }
    
    func setupChildChangedObserver() {
        let databaseReferenceListings = Database.database().reference().child(Constants.ListingPathString)
        databaseReferenceListings.observe(.childChanged) { (snapshot) in
            self.startActivityIndicator()
            
            guard let listingDictionary = snapshot.value as? [String : Any?] else {
                // there is a problem in the database!
                self.stopActivityIndicator()
                return
            }
            
            let onSale = listingDictionary[Constants.ListingKeys.OnSale] as! Bool
            if onSale {
                let changedListing = Listing(dict: listingDictionary)
                changedListing.setId(id: snapshot.key)
                
                // instead of blindly adding listing, first check if it exists in listingArray (if it does, then update it)
                var found = false
                for index in 0..<self.listingArray.count {
                    if self.listingArray[index].id == changedListing.id {
                        // if listing exists already in listingArray, then update it
                        self.listingArray[index] = changedListing
                        found = true
                        break
                    }
                }
                if found == false {
                    self.listingArray.insert(changedListing, at: 0)
                }
            } else {
                let idToRemove = snapshot.key
                self.listingArray = self.listingArray.filter({ (listing) -> Bool in
                    return (listing.id != idToRemove)
                })
            }
            
            DispatchQueue.main.async {
                if self.searching {
                    self.reloadSearchResults()
                } else {
                    self.listingsTable.reloadData()
                }
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
    
    func reloadSearchResults() {
        let searchText = self.searchText.lowercased()
        filteredListings = listingArray.filter({ (listing) -> Bool in
            let comparator: String
            if self.selectedScope == 0 {
                comparator = listing.textbook.title.lowercased()
            } else if self.selectedScope == 1 {
                comparator = listing.textbook.authors.joined(separator: " ").lowercased()
            } else /* self.selectedScope is 2 */ {
                comparator = listing.seller.displayName.lowercased()
            }
            
            return (comparator.contains(searchText) || searchText.contains(comparator))
        })
        
        searching = true
        listingsTable.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListingDetailViewController
        destinationVC.previousViewController = "ListingsViewController"
        destinationVC.displayListing = selectedListing!
    }
    
}

// MARK: - Extension for UISearchBarDelegate

extension ListingsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
        
        searching = true
        listingsTable.separatorStyle = .none
        listingsTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        reloadSearchResults()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.selectedScope = selectedScope
        reloadSearchResults()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        
        filteredListings.removeAll()
        searchBar.text = ""
        searching = false
        listingsTable.separatorStyle = .singleLine
        listingsTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - Extension for UITableViewDataSource

extension ListingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            listingsTable.separatorStyle = (filteredListings.count == 0) ? .none : .singleLine
        } else {
            listingsTable.separatorStyle = (listingArray.count == 0) ? .none : .singleLine
        }
        
        return (searching ? filteredListings.count : listingArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listingsTable.dequeueReusableCell(withIdentifier: "listingCell") as! ListingTableViewCell
        
        let listing = (searching ? filteredListings[indexPath.row] : listingArray[indexPath.row])
        
        let authors = listing.textbook.authors
        let authorsText: String
        if authors.count == 1 {
            authorsText = "Author: " + authors[0]
        } else {
            authorsText = "Authors: " + authors.joined(separator: ", ")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedPrice = formatter.string(from: listing.price as NSNumber)!
        
        cell.titleLabel.text = listing.textbook.title
        cell.authorsLabel.text = authorsText
        cell.priceLabel.text = "Price: \(formattedPrice) (Preferred: " + listing.paymentMethod + ")"
        cell.sellerLabel.text = "Seller: " + listing.seller.displayName
        
        return cell
    }
    
}

// MARK: - Extension for UITableViewDelegate

extension ListingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedListing = (searching ? filteredListings[indexPath.row] : listingArray[indexPath.row])
        listingsTable.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "listingsToDetailSegue", sender: self)
    }
    
}
