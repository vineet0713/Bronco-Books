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
    static let PaymentMethods = ["[Choose Payment Method]", "Apple Pay", "Cash", "Check"]
    
    // Publish Date Format
    static let LongDateFormat = "yyyy-mm-dd"
    static let ShortDateFormat = "yyyy"
    
    // Refresh Time Interval for ML Kit
    static let TimeInterval = 1.0
    
    // Compression Quality for Stored Images to Firebase
    static let UploadCompressionQuality = 0.1
    
    // Maximum Number of Uploadable Photos
    static let MaximumPhotoUpload = 4
    
    // Maximum File Size to Download (currently set to 1 MB)
    static let MaximumFileSize = 1 * 1024 * 1024;
    
    struct ListingKeys {
        static let Textbook = "textbook"
        static let Seller = "seller"
        static let Price = "price"
        static let PaymentMethod = "paymentMethod"
        static let EpochTimePosted = "epochTimePosted"
        static let Buyer = "buyer"
        static let OnSale = "onSale"
        static let ID = "id"
    }
    
    struct UserKeys {
        static let Email = "email"
        static let DisplayName = "displayName"
    }
    
    struct TextbookKeys {
        static let Title = "title"
        static let Subtitle = "subtitle"
        static let Authors = "authors"
        static let Publisher = "publisher"
        static let PublishedDate = "publishedDate"
        static let Language = "language"
        static let Edition = "edition"
        static let Pages = "pages"
        static let Binding = "binding"
    }
    
    struct IncompleteFieldError {
        static let Title = "Please enter a title for your textbook."
        static let Authors = "Please enter 1 or more authors for your textbook."
        static let PublishedDate = "Please enter a publish date in the format '\(LongDateFormat)' for your textbook."
        static let Pages = "Please enter the number of pages in your textbook."
        static let Price = "Please enter a valid price for your listing."
        static let PaymentMethod = "Please enter a payment method for your listing."
    }
    
}
