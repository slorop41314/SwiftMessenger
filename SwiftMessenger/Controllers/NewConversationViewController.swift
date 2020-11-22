//
//  NewConversationViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let loadingSpinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search users..."
        return search
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        return table
    }()
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No results..."
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    //MARK: - Setup UI
    
    func setupUI() {
        searchBar.delegate = self
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissView))
        
        searchBar.becomeFirstResponder()
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
