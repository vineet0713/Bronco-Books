//
//  ListingsViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

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
        listingsTable.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - Helper Function
    
    func loadData() {
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            // To show the activity indicator, even when connection speed is fast!
            // sleep(1)
            
            let databaseReferenceListings = Database.database().reference().child(Constants.ListingPathString)
            databaseReferenceListings.observeSingleEvent(of: .value) { (snapshot) in
                guard let listings = snapshot.value as? [String : Any] else {
                    // either there are no listings, or there is a problem in the database!
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                self.listingArray.removeAll()
                
                for (_, value) in listings {
                    let listingDictionary = value as! [String : Any]
                    let listing = Listing(dict: listingDictionary)
                    self.listingArray.append(listing)
                }
                
                DispatchQueue.main.async {
                    self.listingsTable.separatorStyle = .singleLine
                    self.listingsTable.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
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
        listingsTable.separatorStyle = (filteredListings.count == 0) ? .none : .singleLine
        listingsTable.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListingDetailViewController
        destinationVC.listing = selectedListing!
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
        cell.priceLabel.text = "Price: \(formattedPrice) (Preferred: " + listing.preferredPaymentMethod + ")"
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
