//
//  ListingsViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class ListingsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    
    let testNames = [
        "Data Structures – A Pseudocode Approach with C, Brooks/Cole",
        "The C Programming Language, 2nd edition",
        "Distributed Systems: Concepts And Design, 5th edition",
        "Thomas’ Calculus, Early Transcendentals, Multivariable, 13th Edition with MyMathLab",
        "Linear Algebra with Applications, 7th edition"
    ]
    let testPrices = ["40", "50", "33.99", "49", "183.34"]
    let testSellers = ["vjoshi", "dctaylor", "tshih", "datkinson", "aamer"]
    
    var selectedBook: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        table.dataSource = self
        table.delegate = self
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListingDetailViewController
        destinationVC.title = selectedBook
    }

}

extension ListingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "listingCell") as! ListingTableViewCell
        
        cell.nameLabel.text = testNames[indexPath.row]
        cell.sellerLabel.text = "Price: $" + testPrices[indexPath.row]
        cell.priceLabel.text = "Seller: " + testSellers[indexPath.row]
        
        return cell
    }
    
}

extension ListingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = testNames[indexPath.row]
        table.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "listingsToDetailSegue", sender: self)
    }
    
}
