//
//  NewConversationViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: ((SearchResult) -> Void)?
    
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width / 4, y: (view.height - 200)/2 , width: view.width/2, height: 200)
    }
    
    func setupUI() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewConversationTableViewCell.self, forCellReuseIdentifier: NewConversationTableViewCell.identifier)
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissView))
        
        searchBar.becomeFirstResponder()
        
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
}


//MARK: - Search bar delegate
extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        results.removeAll()
        loadingSpinner.show(in: view)
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String){
        // Checking users array contain firebase data
        
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers { [weak self](result) in
                guard let self = self else {return}
                switch result {
                case .success(let userCol):
                    self.hasFetched = true
                    self.users = userCol
                    self.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users")
                }
            }
        }
    }
    
    func filterUsers(with term: String){
        guard let currentUserEmail = UserDefaults.standard.string(forKey: .userEmailKey), hasFetched else {
            return
        }
        
        let safeCurrentUserEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        self.loadingSpinner.dismiss()
        let results: [SearchResult] = self.users.filter({
            guard let email = $0["safe_email"], email != safeCurrentUserEmail else {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["safe_email"],let name = $0["name"] else {
                return nil
            }
            return SearchResult(name: name, email: email)
        })
        
        self.results = results
        
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        }else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}


//MARK: - TableView Delegate
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier, for: indexPath) as! NewConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

struct SearchResult {
    let name: String
    let email: String
}
