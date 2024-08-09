//
//  AddWorkoutVC.swift
//  Exerite
//
//  Created by Om on 27/03/24.
//

import UIKit

class AddWorkoutVC: UIViewController {
    
    @IBOutlet weak var txtDiet: UITextField!
    @IBOutlet weak var txtKCal: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    
    var categoryID: Int = 0
    var dietCategoryID: DietCategory?
    var dietItem: DietItem?
    var isFromDiet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()
        
        if  isFromDiet {
            if dietItem != nil {
                lblTitle.text = "Edit Diet"
                txtDiet.text = dietItem?.name
                txtKCal.text = "\(dietItem?.calories ?? 0)"
            } else {
                lblTitle.text = "Add Diet"
                txtDiet.placeholder = "Please enter diet name."
                txtKCal.placeholder = "Please enter Kcal."
            }
        } else {
            lblTitle.text = "Add Workout"
            txtDiet.placeholder = "Please enter exercise name."
            txtKCal.placeholder = "Please enter a valid time."
        }
    }
    
    @IBAction func btnDone(_ sender: UIButton) {
        guard let name = txtDiet.text, !name.isEmpty else {
            showAlert(message: isFromDiet ? "Please enter diet name" : "Please enter exercise name.")
            return
        }
        
        guard let timeStr = txtKCal.text, !timeStr.isEmpty, let time = Int(timeStr) else {
            showAlert(message: isFromDiet ? "Please enter Kcal.": "Please enter a valid time.")
            return
        }
        
        if let categoryId = dietCategoryID, isFromDiet {
            let id = generateUniqueID()
            if let dietItem = dietItem {
                DatabaseManager.shared.updateDiet(id: dietItem.id, newTitle: name, newDescription: timeStr)
            } else {
                let dietItem = DietItem(id: id, name: name, category: categoryId, calories: time, isDeleted: false)
                DatabaseManager.shared.insertDietItem(item: dietItem)
            }
        } else {
            let id = generateUniqueID()
            let exerciseSubcategory = ExerciseSubcategory(id: id, name: name, categoryID: categoryID, duration: time, isSelected: false)
            
            ExerciseSubcategoryDatabase.shared.insert(exerciseSubcategory: exerciseSubcategory)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func generateUniqueID() -> Int {
        return Int(UUID().uuidString.hashValue)
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

