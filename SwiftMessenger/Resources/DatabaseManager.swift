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
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser){
        
        database.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ])
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
//    let avatarUrl: String
}
