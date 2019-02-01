//
//  Listing.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/31/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

class Listing {
    
    let seller: String
    let price: Double
    let textbook: Textbook
    
    init(seller: String, price: Double, textbook: Textbook) {
        self.seller = seller
        self.price = price
        self.textbook = textbook
    }
    
    init(dict: [String : Any]) {
        self.seller = dict["seller"] as! String
        self.price = dict["price"] as! Double
        let textbookDict = dict["textbook"] as! [String : Any]
        self.textbook = Textbook(dict: textbookDict)
    }
    
    func getDictionary() -> [String : Any] {
        let dict: [String : Any] = [
            "seller" : self.seller,
            "price" : self.price,
            "textbook" : self.textbook.getDictionary()
        ]
        
        return dict
    }
    
}
