//
//  Textbook.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 1/31/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

class Textbook {
    
    // MARK: - Stored Properties
    
    let title: String
    let subtitle: String
    let authors: [String]
    let publisher: String
    let publishedDate: String
    let language: String
    let edition: String
    let pages: Int
    let binding: String
    
    // MARK: - Constructors
    
    init(title: String, subtitle: String, authors: [String], publisher: String, publishedDate: String, language: String, edition: String, pages: Int, binding: String) {
        self.title = title
        self.subtitle = subtitle
        self.authors = authors
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.language = language
        self.edition = edition
        self.pages = pages
        self.binding = binding
    }
    
    init(dict: [String : Any]) {
        self.title = dict[Constants.TextbookKeys.Title] as! String
        self.subtitle = dict[Constants.TextbookKeys.Subtitle] as! String
        self.authors = dict[Constants.TextbookKeys.Authors] as! [String]
        self.publisher = dict[Constants.TextbookKeys.Publisher] as! String
        self.publishedDate = dict[Constants.TextbookKeys.PublishedDate] as! String
        self.language = dict[Constants.TextbookKeys.Language] as! String
        self.edition = dict[Constants.TextbookKeys.Edition] as! String
        self.pages = dict[Constants.TextbookKeys.Pages] as! Int
        self.binding = dict[Constants.TextbookKeys.Binding] as! String
    }
    
    // MARK: - Member Function
    
    func getDictionary() -> [String : Any] {
        let dict: [String : Any] = [
            Constants.TextbookKeys.Title : self.title,
            Constants.TextbookKeys.Subtitle : self.subtitle,
            Constants.TextbookKeys.Authors : self.authors,
            Constants.TextbookKeys.Publisher : self.publisher,
            Constants.TextbookKeys.PublishedDate : self.publishedDate,
            Constants.TextbookKeys.Language : self.language,
            Constants.TextbookKeys.Edition : self.edition,
            Constants.TextbookKeys.Pages : self.pages,
            Constants.TextbookKeys.Binding : self.binding
        ]
        
        return dict
    }
    
}
