//
//  LoginViewController.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/24/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK - IBOutlet
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    // MARK - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    // This is the earliest we could perform a segue!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.string(forKey: Constants.UserEmailKey) != nil {
            self.performSegue(withIdentifier: "loginToHomeSegue", sender: self)
        } else {
            googleSignInButton.isHidden = false
        }
    }
    
}
