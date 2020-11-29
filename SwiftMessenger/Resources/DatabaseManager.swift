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

extension DatabaseManager {
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child(path).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
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
    public func createNewConversation(with otherEmail: String,name: String, firstMessage: Message, completion: @escaping ((Bool) -> Void)){
        guard let email = UserDefaults.standard.string(forKey: .userEmailKey),
              let currentName = UserDefaults.standard.string(forKey: .userNameKey)
              else {return}
        let safeEmail = DatabaseManager.safeEmail(email: email)
        
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { [weak self] (snapshot) in
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
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                    
                ]
            ]
            
            let recepientNewConversation: [String : Any] = [
                "id" : conversationId,
                "other_user_email" : safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                    
                ]
            ]
            self?.database.child("\(otherEmail)/conversations").observeSingleEvent(of: .value) { [weak self](snapshot) in
                
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(recepientNewConversation)
                    
                    self?.database.child("\(otherEmail)/conversations").setValue(conversations)
                } else {
                    self?.database.child("\(otherEmail)/conversations").setValue([recepientNewConversation])
                }
            }
            
            
            // Update current user conversaton data
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
                
                self.finishCreatingConversation(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
            }
        }
    }
    
    private func finishCreatingConversation(name: String,conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        
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
            "is_read" : false,
            "name" : name
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
    public func getAllConversation(for email: String, completion: @escaping ((Result<[Conversation], Error>) -> Void)) {
        database.child("\(email)/conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { (dictionary) in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let sent = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObj = LatestMessage(date: sent, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObj)
            }
            
            completion(.success(conversations))
        }
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap { (dictionary) in
                guard let name = dictionary["name"] as? String,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let date = ChatViewController.dateFormatter.date(from: dateString)
                else {
                    return nil
                }
                let sender = Sender(avatarUrl: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
            }
            
            completion(.success(messages))
        }
    }
    
    public func sendMessage(to conversationId: String,otherUserEmail: String, name: String, message: Message, completion: @escaping (Bool) -> Void) {
                
        // Add new messages
        
        
        // Update sender latest message
        
        // Update recepient latest message
        
        
        self.database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { [weak self](snapshot) in
            guard let self = self else {return}
            guard var currentMsg = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            var newMessageContent = ""
            switch message.kind {
            case .text(let messageText):
                newMessageContent = messageText
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
        
            let currentSafeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
            
            let messageDate = message.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            let newMessageEntry: [String: Any] = [
                "id" : message.messageId,
                "type" : message.kind.MessageKindString,
                "content" : newMessageContent,
                "date" : dateString,
                "sender_email": currentSafeEmail,
                "is_read" : false,
                "name" : name
            ]
            
            currentMsg.append(newMessageEntry)
            
            self.database.child("\(conversationId)/messages").setValue(currentMsg) { [weak self](err, _) in
                if let error = err {
                    completion(false)
                    return
                }
                
                self?.database.child("\(currentSafeEmail)/conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard var currentUserConversation = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                        let updatedValue: [String: Any] = [
                            "date": dateString,
                            "is_read": false,
                            "message": newMessageEntry
                        ]
                    
                    for conversation in currentUserConversation {
                        if let currConversationId = conversation["id"] as? String, currConversationId == conversationId {
                            targetConversation = conversation
                            break
                        }
                        position += 1
                    }
                    
                    
                    guard var safeTargetConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    
                    safeTargetConversation["latestMessage"] = updatedValue
                    currentUserConversation[position] = safeTargetConversation
                    
                    self?.database.child("\(currentSafeEmail)/conversations").setValue(currentUserConversation, withCompletionBlock: { (err, _) in
                        if let error = err {
                            completion(false)
                            return
                        }
                        
                        self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                            guard var otherUserConversation = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            var otherTargetConversation: [String: Any]?
                            
                            var otherPosition = 0
                            
                            for conversation in otherUserConversation {
                                if let currConversationId = conversation["id"] as? String, currConversationId == conversationId {
                                    otherTargetConversation = conversation
                                    break
                                }
                                otherPosition += 1
                            }
                            
                            
                            guard var safeOtherTargetConversation = otherTargetConversation else {
                                completion(false)
                                return
                            }
                            
                            safeOtherTargetConversation["latestMessage"] = updatedValue
                            otherUserConversation[position] = safeOtherTargetConversation
                            
                            self?.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversation, withCompletionBlock: { (err, _) in
                                if let error = err {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                        })
                    })
                })
            }
        }
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
