//
//  AddJournalVC.swift
//  Exerite
//
//  Created by Om on 26/03/24.
//

import UIKit

class AddJournalVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    var journalModel: JournalModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if journalModel != nil {
            txtTitle.text = journalModel?.title
            txtDescription.text = journalModel?.description
            txtDescription.textColor = UIColor.black
        }
        
        txtDescription.layer.cornerRadius = 10
        txtDescription.layer.borderWidth = 1
        txtDescription.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func btnDone(_ sender: UIButton) {
        guard let title = txtTitle.text, !title.isEmpty else {
            Utilities.showAlert(from: self, withMessage: "Please enter a title.")
            return
        }
        
        guard let description = txtDescription.text, !description.isEmpty, description != " Write here" else {
            Utilities.showAlert(from: self, withMessage: "Please enter a description.")
            return
        }
        
        let databaseManager = DatabaseManager()
        if journalModel == nil {
            databaseManager.insertJournal(title: title, description: description)
        } else {
            databaseManager.updateJournal(id: journalModel?.id ?? 0, newTitle: title, newDescription: description)
        }
        navigationController?.popViewController(animated: true) 

    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == " Write here" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = " Write here"
            textView.textColor = UIColor.lightGray
        }
    }

}
