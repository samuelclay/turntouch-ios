//
//  TTURLRequest.swift
//  Turn Touch iOS
//
//  Created by David Sinclair on 2020-06-17.
//  Copyright © 2020 Turn Touch. All rights reserved.
//

import Foundation

/// Class to send a remote request.
class TTURLRequest {
    enum RequestError: Error {
        case invalidURL
        case invalidResponse
        case missingData
        case invalidJSON
    }
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    typealias CompletionHandler = (Result<Any, Error>) -> Void
    
    class func send(_ url: String, json: [String : Any], method: Method = .post, completionHandler: CompletionHandler? = nil) {
        guard let url = URL(string: url) else {
            completionHandler?(.failure(RequestError.invalidURL))
            return
        }
        
        send(url, json: json, method: method, completionHandler: completionHandler)
    }
    
    class func send(_ url: URL, json: [String : Any], method: Method = .post, completionHandler: CompletionHandler? = nil) {
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler?(.failure(error))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                completionHandler?(.failure(RequestError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completionHandler?(.failure(RequestError.missingData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                
                completionHandler?(.success(json))
            } catch {
                completionHandler?(.failure(error))
            }
        }
        
        task.resume()
    }
}
