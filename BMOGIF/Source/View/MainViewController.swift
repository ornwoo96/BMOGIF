//
//  ViewController.swift
//  BMOGIF
//
//  Created by 김동우 on 2023/02/21.
//

import UIKit

class MainViewController: UIViewController {
    
    private lazy var imageView: GIFImageView2 = {
        let imageView = GIFImageView2()
        imageView.backgroundColor = .green
        
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageData()
        view.backgroundColor = .blue
        setupImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupImageData() {
        let stringUrl = "https://media2.giphy.com/media/RbDKaczqWovIugyJmW/giphy-preview.gif?cid=ca3b938e91xg4nstx0frpmwk5l29h4ocyqio13kmnt111v3e&rid=giphy-preview.gif&ct=g"
        
        Task {
            let image = try await ImageCacheManager.shared.imageLoad(stringUrl)
            
            self.imageView.setupGIFImage(data: image,
                                         size: CGSize(width: 100, height: 100),
                                         contentMode: UIView.ContentMode.scaleAspectFill) {
                self.imageView.startAnimating()
                self.imageView.startAnimation()
            }
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
}

