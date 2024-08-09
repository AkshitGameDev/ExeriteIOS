//
//  LoginVC.swift
//  Exerite
//
//  Created by Akshit on 20/03/24.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        guard let email = txtEmail.text, !email.isEmpty else {
            Utilities.showAlert(from: self, withMessage: "Please enter your email.")
            return
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) {
            Utilities.showAlert(from: self, withMessage: "Please enter a valid email address.")
            return
        }
        
        guard let password = txtPassword.text, !password.isEmpty else {
            Utilities.showAlert(from: self, withMessage: "Please enter your password.")
            return
        }
        
        let dbManager = DatabaseManager()
        let isUserExists = dbManager.getUserByEmailAndPassword(email: email, password: password)
        
        if isUserExists {

            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController,
               let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarController
            }
        } else {
            Utilities.showAlert(from: self, withMessage: "Invalid email or password. Please try again.")
        }
    }
    
    @IBAction func btnSignup(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupVC") as? SignupVC {
            navigationController?.pushViewController(signupVC, animated: true)
        }
    }
    
    @IBAction func btnForgotPassword(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let forgotPasswordVC = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC {
            navigationController?.pushViewController(forgotPasswordVC, animated: true)
        }
    }
}
