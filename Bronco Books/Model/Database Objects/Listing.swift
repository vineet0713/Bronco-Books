//
//  Listing.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/31/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

class Listing {
    
    // MARK: - Stored Properties
    
    let textbook: Textbook
    let seller: User
    let price: Double
    let paymentMethod: String
    let epochTimePosted: Int
    
    var buyer: User?
    var onSale: Bool
    
    var id: String?
    
    // MARK: - Constructors
    
    init(textbook: Textbook, seller: User, price: Double, paymentMethod: String, epochTimePosted: Int, onSale: Bool) {
        self.textbook = textbook
        self.seller = seller
        self.price = price
        self.paymentMethod = paymentMethod
        self.epochTimePosted = epochTimePosted
        self.onSale = onSale
    }
    
    init(dict: [String : Any?]) {
        let textbookDict = dict[Constants.ListingKeys.Textbook] as! [String : Any]
        self.textbook = Textbook(dict: textbookDict)
        
        let sellerDict = dict[Constants.ListingKeys.Seller] as! [String : Any]
        self.seller = User(dict: sellerDict)
        
        self.price = dict[Constants.ListingKeys.Price] as! Double
        self.paymentMethod = dict[Constants.ListingKeys.PaymentMethod] as! String
        self.epochTimePosted = dict[Constants.ListingKeys.EpochTimePosted] as! Int
        
        self.onSale = dict[Constants.ListingKeys.OnSale] as! Bool
    }
    
    // MARK: - Member Functions
    
    func getDictionary() -> [String : Any?] {
        let dict: [String : Any?] = [
            Constants.ListingKeys.Textbook : self.textbook.getDictionary(),
            Constants.ListingKeys.Seller : self.seller.getDictionary(),
            Constants.ListingKeys.Price : self.price,
            Constants.ListingKeys.PaymentMethod : self.paymentMethod,
            Constants.ListingKeys.EpochTimePosted : self.epochTimePosted,
            Constants.ListingKeys.Buyer : self.buyer,
            Constants.ListingKeys.OnSale : self.onSale,
            Constants.ListingKeys.ID : self.id
        ]
        
        return dict
    }
    
    func setBuyer(buyer: User) {
        self.buyer = buyer
        self.onSale = false
    }
    
    func removeFromSale() {
        self.onSale = false
    }
    
    func setOnSale() {
        self.onSale = true
    }
    
    func setId(id: String) {
        self.id = id
    }
    
}
