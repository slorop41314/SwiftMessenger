//
//  ViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import Firebase
import JGProgressHUD

class ConversationViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        return table
    }()
    
    private let emptyConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversation yet..."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let loadingSpinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatListCell")
        
        view.addSubview(tableView)
        view.addSubview(emptyConversationLabel)
        view.addSubview(loadingSpinner)
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    
    @objc func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            print(result)
            self?.createNewConversation(result: result)
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["safe_email"] else {return}
        let vc = ChatViewController(with: email)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Dummy cell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController(with: "abc")
        vc.title = "XX Name"
        vc.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

