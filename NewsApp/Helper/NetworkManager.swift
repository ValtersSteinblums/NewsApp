//
//  NetworkManager.swift
//  NewsApp
//
//  Created by valters.steinblums on 25/08/2022.
//

import Foundation


class NetworkManager {
    
    static var apiKey = "5ae2470e968e40c99c3819b7d42f7d94"
    static var searchResult = "apple"
    
    static func fetchData(completion: @escaping([Article]) -> ()) {
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=\(searchResult)&from=2022-08-13&to=2022-08-24&sortBy=popularity&apiKey=\(apiKey)") else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        URLSession(configuration: config).dataTask(with: request) { data, response, error in
            guard error == nil else {
                print((error?.localizedDescription)!)
                return
            }
            
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            do {
                let jsonData = try JSONDecoder().decode(NewsItem.self, from: data)
                completion(jsonData.articles ?? [])
            } catch {
                print("ERROR:::", error)
            }
        }.resume()
    }
    
}
