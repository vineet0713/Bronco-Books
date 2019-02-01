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
    @IBOutlet weak var table: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    
    /*let testNames = [
        "Data Structures – A Pseudocode Approach with C, Brooks/Cole",
        "The C Programming Language, 2nd edition",
        "Distributed Systems: Concepts And Design, 5th edition",
        "Thomas’ Calculus, Early Transcendentals, Multivariable, 13th Edition with MyMathLab",
        "Linear Algebra with Applications, 7th edition"
    ]
    let testPrices = ["40", "50", "33.99", "49", "183.34"]
    let testSellers = ["vjoshi", "dctaylor", "tshih", "datkinson", "aamer"]*/
    
    var listingArray: [Listing] = []
    
    // var selectedBook: String?
    
    var selectedListing: Listing?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        
        table.backgroundView = activityIndicator
        table.separatorStyle = .none
        
        table.dataSource = self
        table.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            // To show the activity indicator, even when connection speed is fast!
            sleep(1)
            
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
                    self.table.separatorStyle = .singleLine
                    self.table.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListingDetailViewController
        destinationVC.title = selectedListing?.textbook.title
    }

}

extension ListingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "listingCell") as! ListingTableViewCell
        
        cell.titleLabel.text = listingArray[indexPath.row].textbook.title
        cell.sellerLabel.text = "Price: $" + String(listingArray[indexPath.row].price)
        cell.priceLabel.text = "Seller: " + listingArray[indexPath.row].seller
        
        return cell
    }
    
}

extension ListingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedListing = listingArray[indexPath.row]
        table.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "listingsToDetailSegue", sender: self)
    }
    
}
