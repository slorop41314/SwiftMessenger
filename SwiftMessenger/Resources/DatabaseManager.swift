//
//  DatabaseManager.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 21/11/20.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
}

//MARK: - Account Manager

extension DatabaseManager {
    /// Checking user email is existed
    public func didEmailAlreadyUsed(with email: String, completion: @escaping((Bool) -> Void)){
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot, _) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
                
            }
            completion(true)
        }
        
    }
    
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping ((Bool) -> Void)){
        database.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ]) { (err, _) in
            if let _ = err {
                completion(false)
                return
            }
            /*
             [
             [
             "name" : "",
             "safe_email" : ""
             ]
             ]
             */
            
            self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // Append to user dictionary
                    usersCollection.append(["name" : user.firstName + " " + user.lastName,
                                            "safe_email" : user.safeEmail])
                    
                    self.database.child("users").setValue(usersCollection) { (err, ref) in
                        if let _ = err {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                    
                }else {
                    // Create dictionary
                    let newCollection : [[String: String]] = [
                        [
                            "name" : user.firstName + " " + user.lastName,
                            "safe_email" : user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection) { (err, ref) in
                        if let _ = err {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public enum DatabaseErrors: Error {
        case failedToFetch
    }
}


//MARK: - Chats
extension DatabaseManager {
    
    /// Create new chats with other user email and first message
    public func createNewConversation(with otherEmail: String, firstMessage: Message, completion: @escaping ((Bool) -> Void)){
        guard let email = UserDefaults.standard.string(forKey: .userEmailKey) else {return}
        let safeEmail = DatabaseManager.safeEmail(email: email)
        
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard var userNode = snapshot.value as?[String: Any] else {
                completion(false)
                return
            }
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            let conversationId =  "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String : Any] = [
                "id" : conversationId,
                "other_user_email" : otherEmail,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                    
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
            }else {
                userNode["conversations"] = [
                    newConversationData
                ]
            }
            
            
            ref.setValue(userNode) { [weak self](err, _) in
                guard let self = self else {return}
                if let error = err {
                    completion(false)
                    return
                }
                
                self.finishCreatingConversation(conversationId: conversationId, firstMessage: firstMessage, completion: completion)
            }
        }
    }
    
    private func finishCreatingConversation(conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.string(forKey: .userEmailKey) else {
            completion(false)
            return
            
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        let collectionMessage: [String: Any] = [
            "id" : firstMessage.messageId,
            "type" : firstMessage.kind.MessageKindString,
            "content" : message,
            "date" : dateString,
            "sender_email": DatabaseManager.safeEmail(email: currentUserEmail),
            "is_read" : false
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationId)").setValue(value) { (err, _) in
            if let error = err {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /// Fetch and return all conversation
    public func getAllConversation(for email: String, completion: @escaping ((Result<String, Error>) -> Void)) {
        
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    public func sendMessage(to conversation: String, message: String, completion: @escaping (Bool) -> Void) {
        
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        DatabaseManager.safeEmail(email: emailAddress)
    }
    
    var avatarFileName : String {
        return "\(safeEmail)_profile_picture.png"
    }
    //    let avatarUrl: String
}
