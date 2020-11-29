//
//  ChatViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 22/11/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension MessageKind {
    var MessageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    var avatarUrl: String
    var senderId: String
    var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    public let otherUserEmail: String
    private let conversationId: String?
    public static var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var messages = [Message]()
    
    private var selfSender: Sender {
        let safeEmail = DatabaseManager.safeEmail(email:  UserDefaults.standard.string(forKey: .userEmailKey) ?? "")
        return Sender(avatarUrl: "", senderId: safeEmail, displayName: "Albert")
    }
    
    init(with email: String, id: String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let convId = conversationId {
            listenForMessages(id: convId, shouldScrollToBottom: true)
        }
    }
    
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self](result) in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if(shouldScrollToBottom){
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(_):
                print("Error getting message for this conversation")
            }
        }
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        setupInputBarButton()
    }
    
    private func setupInputBarButton() {
        let button = InputBarButtonItem()
        
        button.setSize(CGSize(width: 34, height: 34), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self](_) in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo",
                                            style: .default,
                                            handler: { [weak self](_) in
                                                self?.presentPhotoAttachmentSheet()
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Video",
                                            style: .default,
                                            handler: { [weak self](_) in
                                                
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Audio",
                                            style: .default,
                                            handler: { [weak self](_) in
                                                
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}


//MARK: - MessagesDataSource,MessagesDisplayDelegate,MessagesLayoutDelegate
extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let imageMessage = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let mediaItem):
            guard let imageUrl = mediaItem.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
}

//MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let mediaItem):
            guard let imageUrl = mediaItem.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}


//MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        let message = Message(sender: selfSender, messageId: generateMessageId(), sentDate: Date(), kind: .text(text))
        
        if isNewConversation {
            DatabaseManager.shared.createNewConversation(with: otherUserEmail,name: self.title ?? "User", firstMessage: message) { [weak self](isSuccess) in
                if isSuccess {
                    print("Messages sent")
                    self?.isNewConversation = false
                } else {
                    print("Failed send message")
                }
            }
        }else {
            guard let convId = self.conversationId, let name = self.title else {
                return
            }
            
            DatabaseManager.shared.sendMessage(to: convId,otherUserEmail: otherUserEmail, name: name, message: message) { (isSuccess) in
                if isSuccess {
                } else {
                    print("Failed send message")
                }
            }
        }
    }
    
    private func generateMessageId() -> String {
        // Date, current user email, recepeint email
        let currentUserEmail = selfSender.senderId
        let dateString = Self.dateFormatter.string(from: Date())
        
        let newIdentifier = "\(otherUserEmail)_\(DatabaseManager.safeEmail(email :currentUserEmail))_\(dateString)"
        
        return newIdentifier
    }
    
}

//MARK: - Media attachment
extension ChatViewController {
    private func presentPhotoAttachmentSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Choose from",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self](_) in
                                                let picker = UIImagePickerController()
                                                picker.sourceType = .camera
                                                picker.delegate = self
                                                picker.allowsEditing = true
                                                self?.present(picker, animated: true, completion: {
                                                    
                                                })
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Library",
                                            style: .default,
                                            handler: { [weak self](_) in
                                                let picker = UIImagePickerController()
                                                picker.sourceType = .photoLibrary
                                                picker.delegate = self
                                                picker.allowsEditing = true
                                                self?.present(picker, animated: true, completion: {
                                                    
                                                })
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
}

//MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let imageData = image.pngData(),
              let safeConversationId = conversationId,
              let safeTitle = title
        else {
            return
        }
        
        let fileName = "photo_message_" + generateMessageId()
        
        let convertedFileName = fileName.replacingOccurrences(of: " ", with: "-") + ".png"
        
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: convertedFileName) { [weak self](result) in
            
            guard let self = self else {return}
            switch result {
            case .success(let imageUrl):
                print("Upload message response")
                
                guard let url = URL(string: imageUrl),
                      let placeholder = UIImage(systemName: "person") else {
                    return
                }
                
                let imageMedia = Media(url: url,
                                       image: nil,
                                       placeholderImage: placeholder,
                                       size: .zero)
                
                let message = Message(sender: self.selfSender,
                                      messageId: self.generateMessageId(),
                                      sentDate: Date(),
                                      kind: .photo(imageMedia))
                
                DatabaseManager.shared.sendMessage(to: safeConversationId, otherUserEmail: self.otherUserEmail, name: safeTitle, message: message) { (isSuccess) in
                    if(isSuccess){
                        
                    }else {
                        
                    }
                }
            case .failure(_):
                print("Error uploading image")
            }
        }
    }
}
