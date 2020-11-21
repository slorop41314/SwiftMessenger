//
//  AuthServices.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 20/11/20.
//

import Firebase

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?)
}

class AuthServices: AuthServiceProtocol {
    
    let fbAuth = FirebaseAuth.Auth.auth()
    
    func login(email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        fbAuth.createUser(withEmail: email, password: password, completion: completion)
    }
    
    
}
