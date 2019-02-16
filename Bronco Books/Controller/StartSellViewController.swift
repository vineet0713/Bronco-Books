//
//  StartSellViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

import Firebase

class StartSellViewController: UIViewController {
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - IBActions
    
    @IBAction func scanTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "startSellToScanSegue", sender: self)
    }
    
    @IBAction func enterManuallyTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "startSellToFieldsSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SellFieldsViewController {
            destinationVC.fieldsFromBarcodeScan = nil
        }
    }
    
    // MARK: - Helper Function
    
    func showAlert(title: String, message: String, action: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(action, comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
