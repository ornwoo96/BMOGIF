//
//  GIfImageCacheItem.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/02/28.
//

import UIKit

internal class GIFImageCacheItem {
    let images: [GIFFrame]
    let metadata: [String: Any]

    init(images: [GIFFrame], metadata: [String: Any] = [:]) {
        self.images = images
        self.metadata = metadata
    }
}
