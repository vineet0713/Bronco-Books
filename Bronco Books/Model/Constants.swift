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
    static let UserPhoneNumberKey = "phoneNumber"
    
    // ASCII Values for Zero/Nine Digits
    static let AsciiForDigitZero: UInt8 = 48
    static let AsciiForDigitNine: UInt8 = 57
    
    // Firebase Realtime Database
    static let ListingPathString = "listings"
    
    // Preferred Payment Methods
    struct PaymentMethods {
        static let Dummy = "[Choose Payment Method]"
        static let ApplePay = "Apple Pay"
        static let Cash = "Cash"
        static let Check = "Check"
        static let List = [Dummy, ApplePay, Cash, Check]
    }
    
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
    static let MaximumFileSize = 1 * 1024 * 1024
    
    // Contacting Options
    static let ContactEmail = "Email"
    static let ContactPhoneNumber = "Text Message"
    
    // Email Template
    static let EmailGreeting = "Hello"
    static let EmailClosing = "Thanks"
    
    // Emailing Seller
    static let EmailSellerOptions = ["More Images", "Discuss Price", "Change Payment Method", "Custom"]
    static let SellerEmailBodies = [
        EmailSellerOptions[0] : "Can you please post more images of the textbook? I would like to get a better idea of the textbook's condition.",
        EmailSellerOptions[1] : "Would you be willing to sell this textbook at a price of $ ?",
        EmailSellerOptions[2] : "Would you be willing to accept the payment for this textbook through ?",
        EmailSellerOptions[3] : ""
    ]
    
    // Emailing Buyer
    static let EmailBuyerOptions = ["Discuss Exchange Location", "Option2", "Option3", "Custom"]
    static let BuyerEmailBodies = [
        EmailBuyerOptions[0] : "Where do you want to meet to exchange this textbook and complete the purchase?",
        EmailBuyerOptions[1] : "Body2",
        EmailBuyerOptions[2] : "Body3",
        EmailBuyerOptions[3] : ""
    ]
    
    // Messaging
    static let CountryCode = "+1"
    static let MessagingPath = "sms:" + CountryCode
    
    // contains all field names for Listing object
    struct ListingKeys {
        static let Textbook = "textbook"
        static let Seller = "seller"
        static let Price = "price"
        static let PaymentMethod = "paymentMethod"
        static let EpochTimePosted = "epochTimePosted"
        static let Buyer = "buyer"
        static let OnSale = "onSale"
        static let PurchaseConfirmed = "purchaseConfirmed"
        static let ID = "id"
    }
    
    // contains all field names for User object
    struct UserKeys {
        static let Email = "email"
        static let DisplayName = "displayName"
        static let PhoneNumber = "phoneNumber"
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
