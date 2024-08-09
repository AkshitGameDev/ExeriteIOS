//
//  HomeVC.swift
//  Exerite
//
//  Created by Manan on 20/03/24.
//

import UIKit

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgUser: UIImageView!
    
    private let model = HomeModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        tableView.register(UINib(nibName: "HomeTableCell", bundle: nil), forCellReuseIdentifier: "HomeTableCell")
        tableView.reloadData()
        
     
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableCell
        
        let menuItem = model.menuItems[indexPath.row]
        cell.lblTitle.text = menuItem.title
        cell.imgView.image = UIImage(named: menuItem.title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate
                else {
                  return
                }
        let tabBarController = sceneDelegate.window?.rootViewController as? UITabBarController
        tabBarController?.selectedIndex = indexPath.row + 1
        print("Selected: \(model.menuItems[indexPath.row].title)")
    }
}
