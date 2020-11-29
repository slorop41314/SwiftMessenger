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

