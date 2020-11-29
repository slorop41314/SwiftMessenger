//
//  PhotoViewerViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {
    
    private let url: URL
    
    private let imageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        view.addSubview(imageView)
        
        imageView.sd_setImage(with: url, completed: nil)
    }
    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds
    }

}
