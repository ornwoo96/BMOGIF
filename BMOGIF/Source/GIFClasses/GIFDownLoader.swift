//
//  GIFDownLoader.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/03/02.
//

import UIKit

enum NetworkError: Error {
    case invalidResponse
    case noData
}

internal class GIFDownloader {
    static func fetchImageData(_ url: String) async throws -> Data {
        guard let stringToURL = URL(string: url) else {
            return Data()
        }
        
        let (data, response) = try await URLSession.shared.data(from: stringToURL)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            return Data()
        }
        
        return data
    }
    
    static func fetchImageData(from url: String,
                               completion: @escaping (Result<Data, Error>) -> Void) {
        guard let stringToURL = URL(string: url) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: stringToURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    static func getGIFData(named name: String,
                    completion: @escaping (Data?) -> Void) {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif") else {
            completion(nil)
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            completion(data)
        } catch {
            completion(nil)
        }
    }
}
