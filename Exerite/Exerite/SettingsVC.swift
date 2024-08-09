//
//  SettingsVC.swift
//  Exerite
//
//  Created by Priyanka on 24/03/24.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userName = UserDefaults.standard.string(forKey: "LoggedInUsername")
        let userId = UserDefaults.standard.integer(forKey: "LoggedInUserId")
        lblUserName.text = "Hey, \(userName ?? "")!"

        if let imageData = DatabaseManager().fetchProfileImageData(forUserID: userId) {
            if let image = UIImage(data: imageData) {
                imgUser.image = image
            }
        }
    }
    
    @IBAction func btnEditProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
            navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
    
    @IBAction func btnLogout(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            let loginNaigationController = storyboard.instantiateViewController(withIdentifier: "LoginNaigationController")
            sceneDelegate.window?.rootViewController = loginNaigationController
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            UserDefaults.standard.removeObject(forKey: "LoggedInUserId")
            UserDefaults.standard.removeObject(forKey: "LoggedInUsername")
            UserDefaults.standard.synchronize()
        }
    }

}
