//
//  ProfileViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/25/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            UserDefaults.standard.set(nil, forKey: "loggedIn")
            UserDefaults.standard.synchronize()
            
            self.performSegue(withIdentifier: "profileToLoginSegue", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
