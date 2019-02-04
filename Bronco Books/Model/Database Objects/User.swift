//
//  Seller.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/3/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

class User {
    
    // MARK: - Stored Properties
    
    let email: String
    let displayName: String
    
    // MARK: - Constructors
    
    init(email: String, displayName: String) {
        self.email = email
        self.displayName = displayName
    }
    
    init(dict: [String : Any]) {
        self.email = dict["email"] as! String
        self.displayName = dict["displayName"] as! String
    }
    
    // MARK: - Member Function
    
    func getDictionary() -> [String : Any] {
        let dict: [String : Any] = [
            "email" : self.email,
            "displayName" : self.displayName
        ]
        
        return dict
    }
    
}
