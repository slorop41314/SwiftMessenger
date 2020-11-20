//
//  RegisterViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let avatarImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "person")
        imgView.tintColor = .gray
        imgView.contentMode = .scaleAspectFit
        
        return imgView
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Email Address..."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        
        return textField
    }()
    
    private let firstNameField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "First name"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        
        return textField
    }()
    
    private let lastNameField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Last name"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Password"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - Setup view
    
    func setupUI() {
        setupNavigationBar()
        setupBody()
    }
    
    func setupNavigationBar() {
        title = "Register"
        view.backgroundColor = .white
    }
    
    func setupBody() {
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        registerButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(avatarImageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        avatarImageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeAvatar))
        
        avatarImageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        avatarImageView.frame = CGRect(x: (scrollView.width - size)/2, y: 40, width: size, height: size)
        firstNameField.frame = CGRect(x: 30, y: avatarImageView.bottom + 16, width: scrollView.width - 60, height: 45)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 16, width: scrollView.width - 60, height: 45)
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 16, width: scrollView.width - 60, height: 45)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 16, width: scrollView.width - 60, height: 45)
        registerButton.frame = CGRect(x: 30, y: passwordField.bottom + 32, width: scrollView.width - 60, height: 45)
    }
    
    @objc func onLoginButtonTapped() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text,let email = emailField.text, let password = passwordField.text,!firstName.isEmpty,!lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            callErrorAlert()
            return
        }
    }
    
    private func callErrorAlert() {
        let alert = UIAlertController(title: "Whoops", message: "Please fill all field to register", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapChangeAvatar() {
        print("Change avatar")
    }
    
}


//MARK: - TextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        
        else if textField == lastNameField {
            emailField.becomeFirstResponder()
        }
        
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        
        else if textField == passwordField {
            onLoginButtonTapped()
        }
        
        return true
    }
}
