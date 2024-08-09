//
//  ExerciseVC.swift
//  Exerite
//
//  Created by Om on 22/03/24.
//

import UIKit
import Foundation

class ExerciseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var exerciseTableView: UITableView!
    
    var exerciseCategories = [ExerciseCategory]()
    var selectedCategory: ExerciseCategory?
    var exerciseSubcategories = [ExerciseSubcategory]()
    
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseCategories = ExerciseModel().categories

        exerciseSubcategories = ExerciseSubcategoryDatabase.shared.getAllSelectedExercises()

       
        tableView.register(UINib(nibName: "ExerciseTableCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableCell")
        tableView.reloadData()
        
        exerciseTableView.register(UINib(nibName: "HomeTableCell", bundle: nil), forCellReuseIdentifier: "HomeTableCell")
        exerciseTableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadDataAndHandleNoData()
    }
    
    func reloadDataAndHandleNoData() {
        exerciseSubcategories = ExerciseSubcategoryDatabase.shared.getAllSelectedExercises()
        tableView.reloadData()
        
        if exerciseSubcategories.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No data found"
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = UIColor.lightGray
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return exerciseSubcategories.count
        } else {
            return exerciseCategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 90
        } else {
            return 140
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableCell", for: indexPath) as! ExerciseTableCell
            let subcategory = exerciseSubcategories[indexPath.row]
            cell.lblTitle.text = subcategory.name
            cell.lblSubTitle.text = "\(subcategory.duration) mins"
            cell.viewCircle.backgroundColor = UIColor.systemGreen
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableCell
            let exercise = exerciseCategories[indexPath.row]
            cell.lblTitle.text = exercise.name
            cell.imgView.image = UIImage(named: exercise.name)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == self.tableView
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let subcategory = exerciseSubcategories[indexPath.row]
            ExerciseSubcategoryDatabase.shared.updateSelectedExercise(exerciseID: subcategory.id, isSelected: false)
            exerciseSubcategories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            reloadDataAndHandleNoData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == exerciseTableView {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let subExerciseVC = storyboard.instantiateViewController(withIdentifier: "SubExerciseVC") as? SubExerciseVC {
                subExerciseVC.isFromExercise = true
                subExerciseVC.exerciseCategory = exerciseCategories[indexPath.row]
                subExerciseVC.exerciseSubcategories = ExerciseSubcategoryManager.shared.getSubcategories(forCategory:exerciseCategories[indexPath.row])
                navigationController?.pushViewController(subExerciseVC, animated: true)
            }
        }
    }
}
