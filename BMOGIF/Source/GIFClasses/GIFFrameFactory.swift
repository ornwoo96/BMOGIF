//
//  GIFFrameFactory.swift
//  DynamicGIF
//
//  Created by 김동우 on 2023/02/06.
//

import UIKit

internal enum GIFError: Error {
    case noImages
}

public enum GIFFrameReduceLevel {
    case highLevel
    case middleLevel
    case lowLevel
}

internal class GIFFrameFactory {
    internal var animationFrames: [GIFFrame] = []
    private var imageSource: CGImageSource?
    private var imageSize: CGSize
    private var contentMode: UIView.ContentMode
    internal var totalFrameCount: Int?
    private var isResizing: Bool = false
    internal var isCached: Bool = false
    private var cacheKey: String = ""
    
    init(data: Data,
         size: CGSize,
         contentMode: UIView.ContentMode = .scaleAspectFill,
         isResizing: Bool = false,
         cacheKey: String) {
        self.cacheKey = cacheKey
        let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse] as CFDictionary
        self.imageSource = CGImageSourceCreateWithData(data as CFData, options) ?? CGImageSourceCreateIncremental(options)
        self.imageSize = size
        self.contentMode = contentMode
        self.isResizing = isResizing
    }
    
    internal func clearFactory() {
        self.animationFrames = []
        self.imageSource = nil
        self.totalFrameCount = 0
        self.isResizing = false
    }
    
    internal func setupGIFImageFrames(level: GIFFrameReduceLevel,
                                      animationOnReady: (() -> Void)? = nil) {
        guard let imageSource = self.imageSource else {
            return
        }
        
        if isResizing {
            let resizedFrames = resize(size: self.imageSize)
            let convertFramesArray = getCGImagesForKeyWithCaching(key: self.cacheKey,
                                                                  source: resizedFrames)
            self.animationFrames = getLevelFrame(level: level, frames: convertFramesArray)
            
            animationOnReady?()
        } else {
            let frames = getCGImagesForKeyWithCaching(key: self.cacheKey,
                                                      source: imageSource)
            self.animationFrames = getLevelFrame(level: level, frames: frames)
            
            animationOnReady?()
        }
    }
    
    private func getLevelFrame(level: GIFFrameReduceLevel,
                               frames: [GIFFrame]) -> [GIFFrame] {
        switch level {
        case .highLevel:
            return frames
        case .middleLevel:
            return reduceFrames(GIFFrames: frames, level: 2)
        case .lowLevel:
            return reduceFrames(GIFFrames: frames, level: 3)
        }
    }
    
    private func getCGImagesForKeyWithCaching(key: String,
                                              source: CGImageSource) -> [GIFFrame] {
        if isCached {
            guard let cgImages = GIFImageCache.shared.getGIFImages(forKey: key) else {
                return []
            }
            
            return cgImages
        } else {
            return convertCGImageSourceToGIFFrameArray(source: source)
        }
    }
    
    private func convertCGImageSourceToGIFFrameArray(source: CGImageSource) -> [GIFFrame] {
        let frameCount = CGImageSourceGetCount(source)
        var frameProperties: [GIFFrame] = []
        
        for i in 0..<frameCount {
            guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any] else {
                return []
            }
            
            frameProperties.append(
                GIFFrame(image: image,
                         duration: applyMinimumDelayTime(properties))
            )
        }
        
        GIFImageCache.shared.addGIFImages(frameProperties,
                                          forKey: self.cacheKey)
        
        isCached = true
        
        return frameProperties
    }
    
    private func applyMinimumDelayTime(_ properties: [String: Any]) -> Double {
        var duration = 0.1

        if let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
            duration = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double ?? 0.1
        }
        
        if duration < 0.1 {
            return 0.1
        }
        
        return duration
    }
    
    private func reduceFrames(GIFFrames: [GIFFrame],
                              level: Int) -> [GIFFrame] {
        let frameCount = GIFFrames.count
        let reducedFrameCount = max(frameCount/level, 1)
        
        var reducedFrameProperties: [GIFFrame] = []
        
        for i in 0..<reducedFrameCount {
            var gifFrame = GIFFrame.empty
            let originalFrameIndex = i * level
            
            gifFrame.image = GIFFrames[originalFrameIndex].image
            gifFrame.duration = GIFFrames[originalFrameIndex].duration * Double(level)
            
            reducedFrameProperties.append(gifFrame)
        }
        
        totalFrameCount = reducedFrameProperties.count
        
        return reducedFrameProperties
    }
    
    private func resize(size: CGSize) -> CGImageSource {
        guard let imageSource = self.imageSource else {
            return UIImage().cgImage as! CGImageSource
        }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(Int(size.width), Int(size.height))
        ]
        
        let resizedImageSource = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        
        return resizedImageSource as! CGImageSource
    }
}
