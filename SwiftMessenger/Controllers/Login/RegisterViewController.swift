//
//  RegisterViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    
    private let loadingSpinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let avatarImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "person.circle")
        imgView.tintColor = .gray
        imgView.contentMode = .scaleAspectFit
        imgView.layer.masksToBounds = true
        imgView.layer.borderWidth = 2
        imgView.layer.borderColor = UIColor.gray.cgColor
        
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
        
        avatarImageView.layer.cornerRadius = size / 2
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
        
        // Validate field
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text,let email = emailField.text, let password = passwordField.text,!firstName.isEmpty,!lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            callErrorAlert(message: "All field should not be empty")
            return
        }
        
        loadingSpinner.show(in: view)
        // Login user to firebase
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self](authResult, err) in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                self.loadingSpinner.dismiss(animated: true)
            }
            if let error = err {
                self.callErrorAlert(message: error.localizedDescription)
                return
            }
            let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
            
            DatabaseManager.shared.insertUser(with: chatUser) { (success) in
                if success {
                    guard let image = self.avatarImageView.image, let data = image.pngData() else {
                        return
                    }
                    
                    let fileName = chatUser.avatarFileName
                    
                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.setValue(authResult?.user.email , forKey: .userEmailKey)
                            UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                        case .failure(let error):
                            self.callErrorAlert(message: error.localizedDescription)
                        }
                    }
                }
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
            
        }
        
        
        
    }
    
    private func callErrorAlert(message: String) {
        let alert = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapChangeAvatar() {
        presentPhotoActionSheet()
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

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Select picture from", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] _ in
                                                self?.presentCamera()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: {[weak self] _ in
            self?.presentPhotoPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .camera
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        
        self.avatarImageView.image = selectedImage
    }
}
