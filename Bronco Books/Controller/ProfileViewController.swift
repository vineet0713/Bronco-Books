//
//  ProfileViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/25/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            GIDSignIn.sharedInstance().signOut()
            
            UserDefaults.standard.set(nil, forKey: Constants.UserEmailKey)
            UserDefaults.standard.set(nil, forKey: Constants.UserDisplayNameKey)
            UserDefaults.standard.synchronize()
            
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
