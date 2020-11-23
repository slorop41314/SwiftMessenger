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
