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
    
    internal func setupGIFImageFrames(level: GIFFrameReduceLevel = .highLevel,
                                      animationOnReady: (() -> Void)? = nil) {
        guard let imageSource = self.imageSource else {
            return
        }
        
        if isCached {
            guard let cgImages = GIFImageCache.shared.getGIFImages(forKey: self.cacheKey) else {
                return
            }
            
            self.animationFrames = cgImages
            return
        }
        
        let frames = convertCGImageSourceToGIFFrameArray(source: imageSource)
        let levelFrames = getLevelFrame(level: level, frames: frames)
        self.animationFrames = levelFrames
        
        saveCacheImageFrames(frames: levelFrames)
        animationOnReady?()
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
    
    private func convertCGImageSourceToGIFFrameArray(source: CGImageSource) -> [GIFFrame] {
        let frameCount = CGImageSourceGetCount(source)
        var frameProperties: [GIFFrame] = []
        
        for i in 0..<frameCount {
            guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                return []
            }
            
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any] else {
                return []
            }
            
            if isResizing {
                guard let resizeImage = resize(image) else { return [] }
                
                frameProperties.append(
                    GIFFrame(image: resizeImage,
                             duration: applyMinimumDelayTime(properties))
                )
            }
            
            frameProperties.append(
                GIFFrame(image: image,
                         duration: applyMinimumDelayTime(properties))
            )
        }
        
        return frameProperties
    }
    
    private func saveCacheImageFrames(frames: [GIFFrame]) {
        GIFImageCache.shared.addGIFImages(frames, forKey: self.cacheKey)
        isCached = true
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
    
    private func resize(_ cgImage: CGImage) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(Int(self.imageSize.width), Int(self.imageSize.height))
        ]
        
        guard let imageSource = CGImageSourceCreateWithDataProvider(cgImage.dataProvider!, nil)
            else {
            return nil
        }
        
        guard let thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }
        
        return thumbnailImage
    }
    
    func convertCGImageToImageSource(from cgImage: CGImage) -> CGImageSource? {
        guard let dataProvider = cgImage.dataProvider else {
            return nil
        }
        
        return CGImageSourceCreateWithDataProvider(dataProvider, nil)
    }
}
