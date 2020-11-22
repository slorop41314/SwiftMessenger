//
//  ViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        }
    }
    
    //MARK: - Setup UI
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.register
    }

}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
    
}

