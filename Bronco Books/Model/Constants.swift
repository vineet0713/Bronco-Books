//
//  Constants.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/2/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

struct Constants {
    
    // Authentication
    static let ValidEmailSuffix = "@scu.edu"
    
    // UserDefaults
    static let UserEmailKey = "email"
    static let UserDisplayNameKey = "displayName"
    
    // Firebase Realtime Database
    static let ListingPathString = "listings"
    
    // Preferred Payment Methods
    static let PreferredPaymentMethods = ["[Preferred Payment Method]", "Apple Pay", "Cash", "Check"]
    
    // Publish Date Format
    static let DateFormat = "mm-dd-yyyy"
    
    // Refresh Time Interval for ML Kit
    static let TimeInterval = 2.0
    
}
