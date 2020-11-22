//
//  LoginViewController.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let loadingSpinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logoImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "logo")
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
    
    private let loginButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return button
    }()
    
    
    private let fbLoginButton: FBLoginButton = {
        let btn = FBLoginButton()
        btn.permissions = ["email","public_profile"]
        return btn
    }()
    
    private let googleLoginButton: GIDSignInButton = {
        let btn = GIDSignInButton()
        return btn
    }()
    
    private var googleLoginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupObserver()
    }
    
    deinit {
        if let _ = googleLoginObserver {
            NotificationCenter.default.removeObserver(googleLoginObserver as Any)
        }
    }
    
    func setupObserver() {
        googleLoginObserver = NotificationCenter.default.addObserver(forName: .didGoogleLoginNotification, object: nil, queue: .main) {[weak self] notif in
            guard let self = self else {return}
            
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    //MARK: - Setup view
    
    func setupUI() {
        setupNavigationBar()
        setupBody()
    }
    
    func setupNavigationBar() {
        title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
    }
    
    func setupBody() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fbLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        logoImageView.frame = CGRect(x: (scrollView.width - size)/2, y: 40, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: logoImageView.bottom + 16, width: scrollView.width - 60, height: 45)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 16, width: scrollView.width - 60, height: 45)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 32, width: scrollView.width - 60, height: 45)
        
        
        fbLoginButton.center = scrollView.center
        fbLoginButton.frame = CGRect(x: 30, y: loginButton.bottom + 16, width: scrollView.width - 60, height: 45)
        
        googleLoginButton.center = scrollView.center
        googleLoginButton.frame = CGRect(x: 30, y: fbLoginButton.bottom + 16, width: scrollView.width - 60, height: 45)
    }
    
    @objc func onLoginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            callErrorAlert(message: "Please fill all field to login")
            return
        }
        loadingSpinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self](authResult, err) in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                self.loadingSpinner.dismiss(animated: true)
            }
            
            if let error = err {
                print(error.localizedDescription)
                return
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
    
}


//MARK: - TextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        
        else if textField == passwordField {
            onLoginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController : LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Error login to faceboook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start { (_, result, err) in
            
            guard let result = result as? [String: Any] else {
                if let error = err {
                    self.callErrorAlert(message: error.localizedDescription)
                }
                return
            }
            
            guard let email = result["email"] as? String, let name = result["name"] as? String else {
                return
            }
            
            let nameComponents = name.components(separatedBy: " ")
            
            guard nameComponents.count == 2 else {return}
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.didEmailAlreadyUsed(with: email) { isUsed in
                if !isUsed {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with : credential) { [weak self](authResult, err) in
                guard let self = self else {return}
                if let error = err {
                    self.callErrorAlert(message: error.localizedDescription)
                    return
                }
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            
            
        }
        
        
        
    }
}
