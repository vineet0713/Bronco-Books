//
//  Textbook.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/31/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

class Textbook {
    
    let title: String
    let titleLong: String
    let authors: [String]
    let datePublished: String
    let publisher: String
    let language: String
    let edition: String
    let format: String
    let pages: Int
    let binding: String
    
    init(title: String, titleLong: String, authors: [String], datePublished: String, publisher: String, language: String, edition: String, format: String, pages: Int, binding: String) {
        self.title = title
        self.titleLong = titleLong
        self.authors = authors
        self.datePublished = datePublished
        self.publisher = publisher
        self.language = language
        self.edition = edition
        self.format = format
        self.pages = pages
        self.binding = binding
    }
    
    init(dict: [String : Any]) {
        self.title = dict["title"] as! String
        self.titleLong = dict["titleLong"] as! String
        self.authors = dict["authors"] as! [String]
        self.datePublished = dict["datePublished"] as! String
        self.publisher = dict["publisher"] as! String
        self.language = dict["language"] as! String
        self.edition = dict["edition"] as! String
        self.format = dict["format"] as! String
        self.pages = dict["pages"] as! Int
        self.binding = dict["binding"] as! String
    }
    
    func getDictionary() -> [String : Any] {
        let dict: [String : Any] = [
            "title" : self.title,
            "titleLong" : self.titleLong,
            "authors" : self.authors,
            "datePublished": self.datePublished,
            "publisher" : self.publisher,
            "language" : self.language,
            "edition" : self.edition,
            "format" : self.format,
            "pages" : self.pages,
            "binding" : self.binding
        ]
        
        return dict
    }
    
}
