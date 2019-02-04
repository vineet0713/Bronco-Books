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
    let seller: Seller
    let price: Double
    let preferredPaymentMethod: String
    let epochTimePosted: Int
    
    // MARK: - Constructors
    
    init(textbook: Textbook, seller: Seller, price: Double, preferredPaymentMethod: String, epochTimePosted: Int) {
        self.textbook = textbook
        self.seller = seller
        self.price = price
        self.preferredPaymentMethod = preferredPaymentMethod
        self.epochTimePosted = epochTimePosted
    }
    
    init(dict: [String : Any]) {
        let textbookDict = dict["textbook"] as! [String : Any]
        self.textbook = Textbook(dict: textbookDict)
        
        let sellerDict = dict["seller"] as! [String : Any]
        self.seller = Seller(dict: sellerDict)
        
        self.price = dict["price"] as! Double
        self.preferredPaymentMethod = dict["preferredPaymentMethod"] as! String
        self.epochTimePosted = dict["epochTimePosted"] as! Int
    }
    
    // MARK: - Member Function
    
    func getDictionary() -> [String : Any] {
        let dict: [String : Any] = [
            "textbook" : self.textbook.getDictionary(),
            "seller" : self.seller.getDictionary(),
            "price" : self.price,
            "preferredPaymentMethod" : self.preferredPaymentMethod,
            "epochTimePosted" : self.epochTimePosted
        ]
        
        return dict
    }
    
}
