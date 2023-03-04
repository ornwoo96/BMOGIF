//
//  ViewController.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/02/21.
//

import UIKit

class MainViewController: UIViewController {
    private lazy var imageView: BMOGIFImageView = {
        let imageView = BMOGIFImageView()
        imageView.backgroundColor = .green
        
        return imageView
    }()
    
    private var isStopAnimation = false
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(stopButtonDidTap), for: .touchUpInside)
        button.titleLabel?.text = "STOP"
        button.titleLabel?.textColor = .brown
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageData()
        view.backgroundColor = .blue
        setupImageView()
        setupStopButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupImageData() {
        let stringUrl = "https://media0.giphy.com/media/xT1XGzXhVgWRLN1Cco/giphy-preview.gif?cid=ca3b938ed8wuc7353a2wq3hwvnf6cacyz824reiz263j031v&rid=giphy-preview.gif&ct=g"
        
        self.imageView.setupGIFImage(name: "cats",
                                     cacheKey: stringUrl,
                                     size: CGSize(width: 100, height: 100),
                                     loopCount: 0,
                                     contentMode: UIView.ContentMode.scaleAspectFill,
                                     level: .highLevel,
                                     isResizing: true) {
            
            self.imageView.startAnimation()
        }
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.maxX),
            imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.maxX)
        ])
    }
    
    private func setupStopButton() {
        view.addSubview(stopButton)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            stopButton.widthAnchor.constraint(equalToConstant: 100),
            stopButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func stopButtonDidTap() {
        if isStopAnimation {
            imageView.startAnimation()
            isStopAnimation = false
        } else {
            imageView.stopAnimation()
            isStopAnimation = true
        }
    }
}

