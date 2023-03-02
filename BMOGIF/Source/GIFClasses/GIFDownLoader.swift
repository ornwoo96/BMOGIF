//
//  GIFDownLoader.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/03/02.
//

import UIKit

class GIFDownloader {
    static func downloadGIF(from url: URL,
                            completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            if response?.mimeType == "image/gif" {
                completion(data)
            } else {
                completion(nil)
            }
        }.resume()
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
