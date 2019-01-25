//
//  LoginViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        UserDefaults.standard.set("test_username", forKey: "loggedIn")
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: "loginToHomeSegue", sender: self)
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
