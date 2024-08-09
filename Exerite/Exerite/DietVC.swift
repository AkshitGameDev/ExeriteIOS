//
//  HomeVC.swift
//  Exerite
//
//  Created by Priyanka on 20/03/24.
//

import UIKit

class DietVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var filteredCategories: [DietCategory] = []
    private let databaseManager = DatabaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "HomeTableCell", bundle: nil), forCellReuseIdentifier: "HomeTableCell")
        tableView.reloadData()
        fetchCategories()
    }
        
    private func fetchCategories() {
        
        self.filteredCategories = databaseManager.fetchDietCategories()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableCell
        cell.imgView.image = UIImage(named: filteredCategories[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let subExerciseVC = storyboard.instantiateViewController(withIdentifier: "SubExerciseVC") as? SubExerciseVC {
            subExerciseVC.isFromExercise = false
            subExerciseVC.category = filteredCategories[indexPath.row]
            subExerciseVC.dietItems = databaseManager.getItems(forCategory: filteredCategories[indexPath.row])
            navigationController?.pushViewController(subExerciseVC, animated: true)
        }
    }
    
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if searchText.isEmpty {
            fetchCategories()
        } else {
            filteredCategories = filteredCategories.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            tableView.reloadData()
        }
        
        return true
    }
}
