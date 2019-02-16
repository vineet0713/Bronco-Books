//
//  GoogleBooksConstants.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/15/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

extension GoogleBooksClient {
    
    // MARK: - GETRequestConstants
    struct GETRequestConstants {
        static let APIScheme = "https"
        static let APIHost = "www.googleapis.com"
        static let APIPath = "/books/v1/volumes"
    }
    
    // MARK: - Parameter Keys
    struct GoogleBooksParameterKeys {
        static let Query = "q"
    }
    
    // MARK: - Parameter Values
    struct GoogleBooksParameterValues {
        static let ISBN = "isbn:" /* the ISBN barcode has to be appended to this parameter value */
    }
    
    // MARK: - Response Keys
    struct GoogleBooksResponseKeys {
        static let Items = "items"
        static let VolumeInfo = "volumeInfo"
        
        static let Title = "title"
        static let Subtitle = "subtitle"
        static let Authors = "authors"
        static let Publisher = "publisher"
        static let PublishedDate = "publishedDate"
        static let Language = "language"
        static let Pages = "pageCount"
    }
    
}
