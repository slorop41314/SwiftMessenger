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
            if let error = err {
                completion(false)
                return
            }
            completion(true)
            
        }
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    
    var avatarFileName : String {
        return "\(safeEmail)_profile_picture.png"
    }
//    let avatarUrl: String
}
