//
//  ForgotPasswordVC.swift
//  Exerite
//
//  Created by Akshit on 24/03/24.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()
    }
    
    @IBAction func btnForgotPassword(_ sender: UIButton) {
        
        guard let email = txtEmail.text, !email.isEmpty else {
            Utilities.showAlert(from: self, withMessage: "Please enter your email.")
            return
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) {
            Utilities.showAlert(from: self, withMessage: "Please enter a valid email address.")
            return
        }
        
        Utilities.showAlert(from: self, withMessage: "Your password reset request has been submitted. You'll receive an email containing further instructions shortly") {
                self.navigationController?.popViewController(animated: true)
            }
    }
    
    @IBAction func btnAlreadyHaveAccount(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
