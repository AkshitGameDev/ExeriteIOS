//
//  JournalVC.swift
//  Exerite
//
//  Created by Manan on 26/03/24.
//

import UIKit

class JournalVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, JournalCollCellDelegate {

    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var journalData: [JournalModel] = []
    var filteredData: [JournalModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let cellNib = UINib(nibName: "JournalCollCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "JournalCollCell")
        
    }

    override func viewWillAppear(_ animated: Bool) {
        let databaseManager = DatabaseManager()
        journalData = databaseManager.getAllJournals()
        
        filteredData = journalData
        collectionView.reloadData()

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = (collectionView.frame.width / 2) - 10
        return CGSize(width: itemWidth, height: itemWidth)
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JournalCollCell", for: indexPath) as! JournalCollCell
        
        cell.delegate = self
        cell.tag = indexPath.item

        if indexPath.item == 0 {
            cell.viewAdd.isHidden = false
            cell.viewJournal.isHidden = true
        } else {
            cell.viewAdd.isHidden = true
            cell.viewJournal.isHidden = false
            let journal = filteredData[indexPath.item - 1]
            cell.lblTitle.text = journal.title
            cell.txtDescription.text = journal.description
        }
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let addJournalVC = storyboard?.instantiateViewController(withIdentifier: "AddJournalVC") as! AddJournalVC
        if indexPath.item != 0 {
            addJournalVC.journalModel = filteredData[indexPath.item - 1]
        }
        navigationController?.pushViewController(addJournalVC, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let searchText = searchText, !searchText.isEmpty {
            filteredData = journalData.filter { journal in
                return journal.title.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredData = journalData
        }
        collectionView.reloadData()
        return true
    }
    
    func deleteJournal(at index: Int) {
        let journal = filteredData[index - 1]
        
        let alert = UIAlertController(title: "Delete Journal", message: "Are you sure you want to delete this journal?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let databaseManager = DatabaseManager()
            databaseManager.deleteJournal(id: journal.id)
            
            self.journalData.removeAll { $0.id == journal.id }
            self.filteredData.removeAll { $0.id == journal.id }
            
            self.collectionView.reloadData()
        }))
        present(alert, animated: true, completion: nil)

    }
}
