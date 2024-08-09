//
//  SubExerciseVC.swift
//  Exerite
//
//  Created by Om on 23/03/24.
//

import UIKit

class SubExerciseVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    
    var exerciseSubcategories = [ExerciseSubcategory]()
    var filteredExerciseSubcategories = [ExerciseSubcategory]()
    var dietItems = [DietItem]()
    var filteredDietItems = [DietItem]()
    var exerciseCategory = ExerciseCategory(id: 0, name: "")
    var isFromExercise = true
    var selectedIndex = [Int]()
    var category: DietCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblCategory.text = isFromExercise ? exerciseCategory.name : category?.name
        
        tableView.register(UINib(nibName: "ExerciseTableCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableCell")
        txtSearch.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnAdd.isHidden = false
        
        if isFromExercise {
            lblCategory.text = "Workouts"
            filteredExerciseSubcategories = ExerciseSubcategoryDatabase.shared.getCategoryWiseExercises(categoryID: exerciseCategory.id)
        } else {
            lblCategory.text = "Diet"
            fetchDietItemsFromDatabase()
        }
        tableView.reloadData()
    }
    
    @IBAction func btnAdd(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addWorkoutVC = storyboard.instantiateViewController(withIdentifier: "AddWorkoutVC") as? AddWorkoutVC {
            if isFromExercise {
                addWorkoutVC.categoryID = exerciseCategory.id
            }
            addWorkoutVC.isFromDiet = !isFromExercise
            addWorkoutVC.dietCategoryID = category
            navigationController?.pushViewController(addWorkoutVC, animated: true)
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromExercise {
            return filteredExerciseSubcategories.count
        } else {
            return filteredDietItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableCell", for: indexPath) as! ExerciseTableCell
        
        if isFromExercise {
            let subcategory = filteredExerciseSubcategories[indexPath.row]
            cell.lblTitle.text = subcategory.name
            cell.lblSubTitle.text = "\(subcategory.duration) mins"
            
            if subcategory.isSelected {
                cell.viewCircle.backgroundColor = .systemGreen
            } else {
                cell.viewCircle.backgroundColor = .systemCyan
            }
        } else {
            let dietItem = filteredDietItems[indexPath.row]
            cell.lblTitle.text = dietItem.name
            cell.lblSubTitle.text = "\(dietItem.calories) Kcal"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedId = 0
        if isFromExercise {
            let selectedExercise = filteredExerciseSubcategories[indexPath.row]
            selectedId = selectedExercise.id
        } else {
            let selectedDiet = filteredDietItems[indexPath.row]
            selectedId = selectedDiet.id
            
        }
        if let cell = tableView.cellForRow(at: indexPath) as? ExerciseTableCell {
            if let index = selectedIndex.firstIndex(of: indexPath.row) {
                cell.viewCircle.backgroundColor = .systemCyan
                ExerciseSubcategoryDatabase.shared.updateSelectedExercise(exerciseID: selectedId, isSelected: false)
                selectedIndex.remove(at: index)
            } else {
                cell.viewCircle.backgroundColor = .systemGreen
                ExerciseSubcategoryDatabase.shared.updateSelectedExercise(exerciseID: selectedId, isSelected: true)
                selectedIndex.append(indexPath.row)
            }
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isFromExercise else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            self.deleteDietItem(at: indexPath)
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let selectedDiet = self.filteredDietItems[indexPath.row]
            self.editDietItem(with: selectedDiet)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
        
    func fetchDietItemsFromDatabase() {
        
        dietItems = DatabaseManager.shared.getItems(forCategory: category!)
        filteredDietItems = dietItems.filter { !$0.isDeleted }
        tableView.reloadData()
    }
    
    func deleteDietItem(at indexPath: IndexPath) {
        let dietItem = filteredDietItems[indexPath.row]
        DatabaseManager.shared.deleteDiet(id: dietItem.id)
        filteredDietItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func editDietItem(with dietItem: DietItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addWorkoutVC = storyboard.instantiateViewController(withIdentifier: "AddWorkoutVC") as? AddWorkoutVC {
            addWorkoutVC.isFromDiet = true
            addWorkoutVC.dietCategoryID = dietItem.category
            addWorkoutVC.dietItem = dietItem
            navigationController?.pushViewController(addWorkoutVC, animated: true)
        }
    }
        
    private func toggleExerciseSelection(_ exercise: ExerciseSubcategory, at indexPath: IndexPath) {
        let selectedId = exercise.id
        if let cell = tableView.cellForRow(at: indexPath) as? ExerciseTableCell {
            if let index = selectedIndex.firstIndex(of: indexPath.row) {
                cell.viewCircle.backgroundColor = .systemCyan
                ExerciseSubcategoryDatabase.shared.updateSelectedExercise(exerciseID: selectedId, isSelected: false)
                selectedIndex.remove(at: index)
            } else {
                cell.viewCircle.backgroundColor = .systemGreen
                ExerciseSubcategoryDatabase.shared.updateSelectedExercise(exerciseID: selectedId, isSelected: true)
                selectedIndex.append(indexPath.row)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if isFromExercise {
            filteredExerciseSubcategories = exerciseSubcategories.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        } else {
            filteredDietItems = dietItems.filter { !$0.isDeleted && $0.name.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
        
        return true
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 20)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
