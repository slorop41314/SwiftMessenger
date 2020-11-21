//
//  ProfileViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

private let cellIdentifier = "profileCell"

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let data = ["Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let confirmationAlert = UIAlertController(title: "Are you sure want to logout", message: "", preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { [weak self] _ in
            guard let self = self else {return}
            
            LoginManager().logOut()
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                
                nav.modalPresentationStyle = .fullScreen
                
                self.present(nav, animated: true)
                
            }catch {
                
            }
            
        }))
        
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        present(confirmationAlert, animated: true)
        
        
    }
    
}
