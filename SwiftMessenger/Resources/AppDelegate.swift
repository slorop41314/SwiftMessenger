//
//  AppDelegate.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 19/11/20.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            return
        }
        
        guard let email = user.profile.email,let firstName = user.profile.givenName,let lastName = user.profile.familyName else {return}
        
        DatabaseManager.shared.didEmailAlreadyUsed(with: email) { isUsed in
            if !isUsed {
                let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                //TODO: - Inserting to database
                
                if(user.profile.hasImage){
                    guard let url = user.profile.imageURL(withDimension: 200) else {return}
                    
                    URLSession.shared.dataTask(with: url) { (data, _, _) in
                        guard let data = data else {return}
                        DatabaseManager.shared.insertUser(with: chatUser) { (success) in
                            if success {
                                let fileName = chatUser.avatarFileName
                                
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                    case .failure(let error):
                                        break
                                    }
                                }
                            }
                        }
                    }.resume()
                }
            }
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { (res, err) in
            if let error = err {
                print("Sign in with google error", error.localizedDescription)
                return
            }
            
            
            UserDefaults.standard.setValue(email , forKey: .userEmailKey)
            UserDefaults.standard.setValue("\(firstName) \(lastName)" , forKey: .userNameKey)
            
            NotificationCenter.default.post(name: .didGoogleLoginNotification, object: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user disconnect")
    }
    
}




