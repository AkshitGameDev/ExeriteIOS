//
//  SettingsVC.swift
//  Exerite
//
//  Created by Priyanka on 24/03/24.
//

import UIKit
import SQLite3

class EditProfileVC: UIViewController {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!

    var db: OpaquePointer?
    var userId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loggedInUserId = UserDefaults.standard.value(forKey: "LoggedInUserId") as? Int {
            let userData = DatabaseManager().getUserByUserId(userId: loggedInUserId)
            txtUserName.text = userData?.username ?? ""
            txtEmail.text = userData?.email ?? ""
        }
        
        userId = UserDefaults.standard.integer(forKey: "LoggedInUserId")

        if let imageData = DatabaseManager().fetchProfileImageData(forUserID: userId) {
            if let image = UIImage(data: imageData) {
                imgUser.image = image
            }
        }
        dismissKeyboardOnTap()

    }

    func openDatabase() -> OpaquePointer? {
        let fileURL = DatabaseManager().getDatabasePath()
        
        if sqlite3_open(fileURL, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        }
        return db
    }


    func validateInputs() -> Bool {

        guard let username = txtUserName.text, !username.isEmpty else {
            showAlert(message: "Please enter a username.")
            return false
        }
        guard let email = txtEmail.text, !email.isEmpty else {
            showAlert(message: "Please enter an email address.")
            return false
        }

        return true
    }

    @IBAction func btnSave(_ sender: UIButton) {
        if validateInputs() {
            saveDataToDatabase()
        }
    }
    
    @IBAction func btnUploadImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func saveDataToDatabase() {
        guard let db = openDatabase() else { return }

        let username = txtUserName.text ?? ""
        let email = txtEmail.text ?? ""
        let image = imgUser.image

        if let imageData = image?.pngData() {
            let updateQuery = "UPDATE UserLogin SET username = ?, email = ?, profile_image = ? WHERE user_id = ?"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare(db, updateQuery, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 2, (email as NSString).utf8String, -1, nil)
                
                let imageDataPtr = (imageData as NSData).bytes
                sqlite3_bind_blob(stmt, 3, imageDataPtr, Int32(imageData.count), nil)
                
                sqlite3_bind_int(stmt, 4, Int32(userId))
                
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("Profile updated successfully.")
                    if txtUserName.text != "" {
                        UserDefaults.standard.set(username, forKey: "LoggedInUsername")
                    }
                } else {
                    print("Failed to update profile.")
                }
                
                self.navigationController?.popViewController(animated: true)

                
                sqlite3_finalize(stmt)
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error preparing statement: \(errorMessage)")
            }
        }
        sqlite3_close(db)

    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

}
extension EditProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgUser.image = pickedImage 
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
