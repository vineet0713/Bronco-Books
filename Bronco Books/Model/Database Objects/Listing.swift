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
    let preferredPaymentMethod: String
    let epochTimePosted: Int
    
    var buyer: User?
    var onSale: Bool
    
    var id: String?
    
    // MARK: - Constructors
    
    init(textbook: Textbook, seller: User, price: Double, preferredPaymentMethod: String, epochTimePosted: Int) {
        self.textbook = textbook
        self.seller = seller
        self.price = price
        self.preferredPaymentMethod = preferredPaymentMethod
        self.epochTimePosted = epochTimePosted
        
        self.onSale = true
    }
    
    init(dict: [String : Any?]) {
        let textbookDict = dict["textbook"] as! [String : Any]
        self.textbook = Textbook(dict: textbookDict)
        
        let sellerDict = dict["seller"] as! [String : Any]
        self.seller = User(dict: sellerDict)
        
        self.price = dict["price"] as! Double
        self.preferredPaymentMethod = dict["preferredPaymentMethod"] as! String
        self.epochTimePosted = dict["epochTimePosted"] as! Int
        
        self.onSale = true
    }
    
    // MARK: - Member Functions
    
    func getDictionary() -> [String : Any?] {
        let dict: [String : Any?] = [
            "textbook" : self.textbook.getDictionary(),
            "seller" : self.seller.getDictionary(),
            "price" : self.price,
            "preferredPaymentMethod" : self.preferredPaymentMethod,
            "epochTimePosted" : self.epochTimePosted,
            "buyer" : self.buyer,
            "onSale": self.onSale,
            "id" : self.id
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
