//
//  StartSellViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class StartSellViewController: UIViewController {
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func scanTapped(_ sender: Any) {
        showAlert(title: "Nonexistent Feature", message: "Barcode scanning is not implemented yet. Stay tuned!")
    }
    
    @IBAction func enterManuallyTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "scanToFieldsSegue", sender: self)
    }
    
    // MARK: - Helper Function
    
    func showAlert(title: String, message: String, action: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(action, comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
