//
//  GoogleBooksClient.swift
//  Bronco Books
//
//  Created by Vineet Joshi on 2/15/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import Foundation

class GoogleBooksClient: NSObject {
    
    // MARK: - Shared Session
    
    var session = URLSession.shared
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> GoogleBooksClient {
        struct Singleton {
            static var sharedInstance = GoogleBooksClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Helper Function
    
    func googlebooksURLFromParameters(_ parameters: [String:Any]) -> URL {
        var components = URLComponents()
        components.scheme = GETRequestConstants.APIScheme
        components.host = GETRequestConstants.APIHost
        components.path = GETRequestConstants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
