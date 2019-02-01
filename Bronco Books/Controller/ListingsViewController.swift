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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listingsTable: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var listingArray: [Listing] = []
    
    var selectedListing: Listing?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
    func loadData() {
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            // To show the activity indicator, even when connection speed is fast!
            // sleep(1)
            
            let databaseReferenceListings = Database.database().reference().child("listings")
            databaseReferenceListings.observeSingleEvent(of: .value) { (snapshot) in
                guard let listings = snapshot.value as? [String : Any] else {
                    // either there are no listings, or there is a problem in the database!
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                self.listingArray.removeAll()
                for (_, value) in listings {
                    let listingDictionary = value as! [String : Any]
                    self.listingArray.append(Listing(dict: listingDictionary))
                }
                
                DispatchQueue.main.async {
                    self.listingsTable.separatorStyle = .singleLine
                    self.listingsTable.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListingDetailViewController
        destinationVC.listing = selectedListing!
    }

}

extension ListingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listingsTable.dequeueReusableCell(withIdentifier: "listingCell") as! ListingTableViewCell
        let listing = listingArray[indexPath.row]
        
        cell.titleLabel.text = listing.textbook.title
        cell.sellerLabel.text = "Price: $" + String(listing.price) + " (Preferred: " + listing.preferredPaymentMethod + ")"
        cell.priceLabel.text = "Seller: " + listing.seller
        
        return cell
    }
    
}

extension ListingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedListing = listingArray[indexPath.row]
        listingsTable.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "listingsToDetailSegue", sender: self)
    }
    
}
