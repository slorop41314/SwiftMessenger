//
//  NewConversationCell.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 29/11/20.
//

import Foundation
import SDWebImage

class NewConversationTableViewCell: UITableViewCell {
    
    static let identifier = "NewConversationTableViewCell"
    
    private let userImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 20
        image.layer.masksToBounds = true
        return image
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        usernameLabel.frame = CGRect(x: userImageView.right + 12, y:(contentView.height - 10) / 2, width: contentView.width - 20 - userImageView.width, height: contentView.height - 10)
        
    }
    
    public func configure(with model: SearchResult) {
        self.usernameLabel.text = model.name
        
        let path = "images/\(model.email)_profile_picture.png"
        
        StorageManager.shared.downloadUrl(for: path) { [weak self](result) in
            switch result {
            case .success(let url):
                self?.userImageView.sd_setImage(with: url, completed: nil)
            case .failure(_):
                print("error getting image ")
            }
        }
        
       
    }
}
