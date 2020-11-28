//
//  ConversationTableViewCell.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 26/11/20.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 50
        image.layer.masksToBounds = true
        return image
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        usernameLabel.frame = CGRect(x: userImageView.right + 12, y: 12, width: contentView.width - 20 - userImageView.width, height: 12)
        userMessageLabel.frame = CGRect(x: userImageView.right + 12, y: 24, width: contentView.width - 20 - userImageView.width, height: (contentView.height / 2) - 24)
        
    }
    
    public func configure(with model: Conversation) {
        self.usernameLabel.text = model.name
        self.userMessageLabel.text = model.latestMessage.text
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        
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
