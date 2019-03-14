//
//  GoogleBooksConvenience.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/15/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

extension GoogleBooksClient {
    
    func getBookInformation(from barcode: String, completionHandler: @escaping (_ bookFields: [String : Any]?, _ errorDescription: String?)->Void) {
        let methodParameters: [String : Any] = [
            GoogleBooksParameterKeys.Query : GoogleBooksParameterValues.ISBN + barcode
        ]
        
        let url = googlebooksURLFromParameters(methodParameters)
        print("About to make a GET request on this url: \(url)")
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                completionHandler(nil, "Your request returned a status code other than 2xx.")
                return
            }
            
            guard let data = data else {
                completionHandler(nil, "No data was returned.")
                return
            }
            
            var parsedResult: [String:Any]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
            } catch {
                completionHandler(nil, "Could not parse the data as JSON.")
                return
            }
            
            guard let itemsArray = parsedResult[GoogleBooksResponseKeys.Items] as? [[String : Any]] else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.Items).")
                return
            }
            
            guard itemsArray.count > 0 else {
                completionHandler(nil, "No items were returned.")
                return
            }
            let item = itemsArray[0]
            
            guard let volume = item[GoogleBooksResponseKeys.VolumeInfo] as? [String : Any] else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.VolumeInfo).")
                return
            }
            
            var textbookDictionary: [String : Any] = [:]
            
            guard let title = volume[GoogleBooksResponseKeys.Title] as? String else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.Title).")
                return
            }
            textbookDictionary[Constants.TextbookKeys.Title] = title
            
            guard let subtitle = volume[GoogleBooksResponseKeys.Subtitle] as? String else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.Subtitle).")
                return
            }
            textbookDictionary[Constants.TextbookKeys.Subtitle] = subtitle
            
            guard let authors = volume[GoogleBooksResponseKeys.Authors] as? [String] else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.Authors).")
                return
            }
            textbookDictionary[Constants.TextbookKeys.Authors] = authors
            
            guard let publisher = volume[GoogleBooksResponseKeys.Publisher] as? String else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.Publisher).")
                return
            }
            textbookDictionary[Constants.TextbookKeys.Publisher] = publisher
            
            guard let publishedDate = volume[GoogleBooksResponseKeys.PublishedDate] as? String else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.PublishedDate).")
                return
            }
            textbookDictionary[Constants.TextbookKeys.PublishedDate] = publishedDate
            
            guard let languageId = volume[GoogleBooksResponseKeys.Language] as? String else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.Language).")
                return
            }
            let locale = NSLocale(localeIdentifier: languageId)
            let language = locale.displayName(forKey: NSLocale.Key.identifier, value: languageId)
            textbookDictionary[Constants.TextbookKeys.Language] = language
            
            guard let pages = volume[GoogleBooksResponseKeys.Pages] as? Int else {
                completionHandler(nil, "Could not find the key \(GoogleBooksResponseKeys.Pages).")
                return
            }
            textbookDictionary[Constants.TextbookKeys.Pages] = pages
            
            completionHandler(textbookDictionary, nil)
        }
        
        task.resume()
    }
    
}
