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
    
    // Contacting Seller
    static let EmailGreeting = "Hello"
    static let EmailClosing = "Thanks"
    static let ContactSellerOptions = ["More Images", "Discuss Price", "Change Payment Method", "Custom"]
    static let ContactSellerEmailBodies = [
        ContactSellerOptions[0] : "Can you please post more images of the textbook? I would like to get a better idea of the textbook's condition.",
        ContactSellerOptions[1] : "Is it possible to sell this textbook at a price of $ ?",
        ContactSellerOptions[2] : "Is it possible to change the payment method for this textbook to ?",
        ContactSellerOptions[3] : ""
    ]
    
    // contains all field names for Listing object
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
    
    // contains all field names for User object
    struct UserKeys {
        static let Email = "email"
        static let DisplayName = "displayName"
    }
    
    // contains all field names for Textbook object
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
    
    // contains all error messages for posting an incomplete Listing
    struct IncompleteFieldError {
        static let Title = "Please enter a title for your textbook."
        static let Authors = "Please enter 1 or more authors for your textbook."
        static let PublishedDate = "Please enter a publish date in the format '\(LongDateFormat)' for your textbook."
        static let Pages = "Please enter the number of pages in your textbook."
        static let Price = "Please enter a valid price for your listing."
        static let PaymentMethod = "Please enter a payment method for your listing."
    }
    
}
