//
//  GIFImageCache.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/02/28.
//

import UIKit

internal class GIFImageCache {
    internal static let shared = GIFImageCache()

    private let cache = NSCache<NSString, GIFImageCacheItem>()

    internal func addGIFImages(_ images: [GIFFrame], forKey key: String) {
        let item = GIFImageCacheItem(images: images)
        cache.setObject(item, forKey: key as NSString)
    }
    
    internal func getGIFImages(forKey key: String) -> [GIFFrame]? {
        guard let item = cache.object(forKey: key as NSString) else { return nil }
        return item.images
    }
}
