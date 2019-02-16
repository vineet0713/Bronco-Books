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
        self.email = dict[Constants.UserKeys.Email] as! String
        self.displayName = dict[Constants.UserKeys.DisplayName] as! String
    }
    
    // MARK: - Member Function
    
    func getDictionary() -> [String : Any] {
        let dict: [String : Any] = [
            Constants.UserKeys.Email : self.email,
            Constants.UserKeys.DisplayName : self.displayName
        ]
        
        return dict
    }
    
}
