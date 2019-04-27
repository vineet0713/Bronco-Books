//
//  StartSellViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

// Credit for icon image used in this tab bar item:
// Icons made by https://www.freepik.com/ from https://www.flaticon.com/ is licensed by http://creativecommons.org/licenses/by/3.0/

import UIKit

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
            destinationVC.previousViewController = "StartSellViewController"
            destinationVC.fieldsFromBarcodeScan = nil
        }
    }
    
}
