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
                              size: CGSize,
                              loopCount: Int = 0,
                              contentMode: UIView.ContentMode = .scaleAspectFill,
                              level: GIFFrameReduceLevel = .highLevel,
                              isResizing: Bool = false,
                              animationOnReady: (() -> Void)? = nil) {
        guard let url = URL(string: url) else { return }
        animator.delegate = self
        GIFDownloader.downloadGIF(from: url) { [weak self] gifData in
            guard let data = gifData else { return }
            self?.animator.setupForAnimation(data: data,
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
                              size: CGSize,
                              loopCount: Int = 0,
                              contentMode: UIView.ContentMode,
                              level: GIFFrameReduceLevel = .highLevel,
                              isResizing: Bool = false,
                              animationOnReady: (() -> Void)? = nil) {
        animator.delegate = self
        GIFDownloader.getGIFData(named: name) { [weak self] gifData in
            guard let data = gifData else { return }
            self?.animator.setupForAnimation(data: data,
                                             size: size,
                                             loopCount: loopCount,
                                             contentMode: contentMode,
                                             level: level,
                                             isResizing: isResizing,
                                             cacheKey: cacheKey,
                                             animationOnReady: animationOnReady)
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
        self.animator.stopAnimation()
        self.image = nil
        self.animator.clear()
    }
    
    private func setupImage(image: UIImage) {
        
    }
}

extension BMOGIFImageView: GIFAnimatorImageUpdateDelegate {
    func animationImageUpdate(_ image: CGImage) {
        DispatchQueue.main.async { [weak self] in
            self?.image = UIImage(cgImage: image)
        }
    }
}
