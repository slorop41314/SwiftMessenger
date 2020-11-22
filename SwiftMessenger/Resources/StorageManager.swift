//
//  StorageManager.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 22/11/20.
//

import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias uploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload picture to firebase storage, returning imageUrl String in the completion
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metadata, err) in
            if let error = err {
                completion(.failure(error))
                return
            }
            
             self.storage.child("images/\(fileName)").downloadURL { (url, err) in
                if let error = err {
                    completion(.failure(error))
                    return
                }
                
                guard let url = url else { return }
                
                completion(.success(url.absoluteString))
                print("Download url complete")
            }
        }
    }
}
