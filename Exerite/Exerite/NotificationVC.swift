//
//  NotificationVC.swift
//  Exerite
//
//  Created by Om on 04/07/24.
//

import UIKit
import UserNotifications
import Foundation


struct NotificationData: Codable {
    let identifier: String
    let title: String
    let body: String
    let date: Date
}

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications: [NotificationData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "ExerciseTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ExerciseTableCell")
        loadNotifications()
        scheduleNotification(at: 14, minute: 55, title: "Exerite", body: "Welcome OnBoard!")
        
        notifcation()
    }

    func notifcation() {
        
        let title = "Exerite"
        let body = "Welcome OnBoard!"
        
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let identifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    let notificationData = NotificationData(identifier: identifier, title: title, body: body, date: Date())
                    self.notifications.append(notificationData)
                    self.saveNotifications()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    
    func scheduleNotification(at hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                let notificationData = NotificationData(identifier: identifier, title: title, body: body, date: Calendar.current.date(from: dateComponents)!)
                self.notifications.append(notificationData)
                self.saveNotifications()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                   
                }
            }
        }
    }
    
    
    func saveNotifications() {
           let encoder = JSONEncoder()
           if let encoded = try? encoder.encode(notifications) {
               UserDefaults.standard.set(encoded, forKey: "notifications")
           }
       }
       
       func loadNotifications() {
           if let savedNotifications = UserDefaults.standard.object(forKey: "notifications") as? Data {
               let decoder = JSONDecoder()
               if let loadedNotifications = try? decoder.decode([NotificationData].self, from: savedNotifications) {
                   notifications = loadedNotifications
                   if notifications.isEmpty {
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
           }
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableCell", for: indexPath) as! ExerciseTableCell
        let notification = notifications[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateStr = dateFormatter.string(from: notification.date)
        
        cell.lblTitle.text = notification.body
        cell.lblSubTitle.text = dateStr
        
        return cell
    }

}

