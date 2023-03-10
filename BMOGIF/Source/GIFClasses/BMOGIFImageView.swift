//
//  GIFImageView.swift
//  DynamicGIF
//
//  Created by 김동우 on 2023/02/03.
//

import UIKit

public class BMOGIFImageView: UIImageView {
    private var animator = GIFAnimator()
    
    // Setup - GIF URL
    public func setupGIFImage(url: String,
                              cacheKey: String,
                              size: CGSize = CGSize(),
                              loopCount: Int = 0,
                              contentMode: UIView.ContentMode = .scaleAspectFill,
                              level: GIFFrameReduceLevel = .highLevel,
                              isResizing: Bool = false,
                              animationOnReady: (() -> Void)? = nil) {
        animator.delegate = self
        
        if animator.checkCachingStatus() {
            animator.setupCachedImages(animationOnReady: animationOnReady)
            return
        }
        
        Task {
            let image = try await GIFDownloader.fetchImageData(url)

            self.animator.setupForAnimation(data: image,
                                            size: size,
                                            loopCount: loopCount,
                                            contentMode: contentMode,
                                            level: level,
                                            isResizing: isResizing,
                                            cacheKey: cacheKey,
                                            animationOnReady: animationOnReady)
        }
    }
    
    // Setup - GIF Name
    public func setupGIFImage(name: String,
                              cacheKey: String,
                              size: CGSize = CGSize(),
                              loopCount: Int = 0,
                              contentMode: UIView.ContentMode = .scaleAspectFill,
                              level: GIFFrameReduceLevel = .highLevel,
                              isResizing: Bool = false,
                              animationOnReady: (() -> Void)? = nil) {
        animator.delegate = self
        
        if animator.checkCachingStatus() {
            animator.setupCachedImages(animationOnReady: animationOnReady)
            return
        }
        do {
            guard let data = try GIFDownloader.getDataFromAsset(named: name) else {
                return
            }
            
            self.animator.setupForAnimation(data: data,
                                            size: size,
                                            loopCount: loopCount,
                                            contentMode: contentMode,
                                            level: level,
                                            isResizing: isResizing,
                                            cacheKey: cacheKey,
                                            animationOnReady: animationOnReady)
        } catch {
            print("")
        }
    }
    
    // Setup - GIF Data
    public func setupGIFImage(data: Data,
                              cacheKey: String,
                              size: CGSize = CGSize(),
                              loopCount: Int = 0,
                              contentMode: UIView.ContentMode = .scaleAspectFill,
                              level: GIFFrameReduceLevel = .highLevel,
                              isResizing: Bool = false,
                              animationOnReady: (() -> Void)? = nil) {
        animator.delegate = self
        
        if animator.checkCachingStatus() {
            animator.setupCachedImages(animationOnReady: animationOnReady)
            return
        }
        
        animator.setupForAnimation(data: data,
                                   size: size,
                                   loopCount: loopCount,
                                   contentMode: contentMode,
                                   level: level,
                                   isResizing: isResizing,
                                   cacheKey: cacheKey,
                                   animationOnReady: animationOnReady)
    }
    
    public func startAnimation() {
        animator.startAnimation()
    }
    
    public func stopAnimation() {
        animator.stopAnimation()
    }
    
    public func clearImageView() {
        animator.stopAnimation()
        DispatchQueue.main.async { [weak self] in
            self?.image = nil
        }
        animator.clear()
    }
}

extension BMOGIFImageView: GIFAnimatorImageUpdateDelegate {
    func animationImageUpdate(_ image: CGImage) {
        DispatchQueue.main.async { [weak self] in
            self?.image = UIImage(cgImage: image)
        }
    }
}
