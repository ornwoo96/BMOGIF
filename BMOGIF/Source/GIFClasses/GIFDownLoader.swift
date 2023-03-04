//
//  GIFDownLoader.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/03/02.
//

import UIKit

enum GIFDownLoaderError: Error {
    case invalidResponse
    case noData
    case invalidURL
    case failedRequest
}

internal class GIFDownloader {
    static func fetchImageData(_ url: String) async throws -> Data {
        guard let stringToURL = URL(string: url) else {
            throw GIFDownLoaderError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: stringToURL)
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                throw GIFDownLoaderError.invalidResponse
            }
            
            return data
        } catch {
            throw GIFDownLoaderError.failedRequest
        }
    }
    
    static func getDataFromAsset(named fileName: String) throws -> Data? {
        guard let asset = NSDataAsset(name: fileName) else {
            throw GIFDownLoaderError.noData
        }
        
        return asset.data
    }
    
}
