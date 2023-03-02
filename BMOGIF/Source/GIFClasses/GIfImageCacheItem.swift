//
//  GIfImageCacheItem.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/02/28.
//

import UIKit

internal class GIFImageCacheItem {
    let images: [GIFFrame]

    init(images: [GIFFrame]) {
        self.images = images
    }
}
