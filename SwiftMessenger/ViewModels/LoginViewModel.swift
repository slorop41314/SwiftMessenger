//
//  LoginViewModel.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 20/11/20.
//

import Foundation

class LoginViewModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthServices()) {
        self.authService = authService
    }
    
}
