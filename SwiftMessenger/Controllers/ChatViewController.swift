//
//  ChatViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 22/11/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView

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

class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    public let otherUserEmail: String
    public static var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var messages = [Message]()
    
    private var selfSender: Sender = Sender(avatarUrl: "", senderId: UserDefaults.standard.string(forKey: .userEmailKey) ?? "", displayName: "Albert")
    
    init(with email: String) {
        self.otherUserEmail = email
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
    }
    
    //MARK: - Setup UI
    func setupUI() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        
    }
}

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
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        let message = Message(sender: selfSender, messageId: generateMessageId(), sentDate: Date(), kind: .text(text))
        
        if isNewConversation {
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message) { (isSuccess) in
                if isSuccess {
                    print("Messages sent")
                } else {
                    print("Failed send message")
                }
            }
        }else {
            
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

