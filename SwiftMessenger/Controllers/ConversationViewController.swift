//
//  ViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
        
    }
    
    private func validateAuth() {
        
        if Firebase.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }else {
//            let vc = LoginViewController()
//            let nav = UINavigationController(rootViewController: vc)
//            
//            nav.modalPresentationStyle = .fullScreen
//            present(nav, animated: false)
        }
    }

}

