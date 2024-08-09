//
//  JournalCollCell.swift
//  Exerite
//
//  Created by Manan on 26/03/24.
//

import UIKit

protocol JournalCollCellDelegate: AnyObject {
    func deleteJournal(at index: Int)
}
class JournalCollCell: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    
    @IBOutlet weak var viewAdd: UIView!
    @IBOutlet weak var viewJournal: UIView!

    @IBOutlet weak var viewTop: UIView!

    @IBOutlet weak var btnDelete: UIButton!

    weak var delegate: JournalCollCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewAdd.layer.cornerRadius = 30
        viewJournal.layer.cornerRadius = 30
        
        viewTop.layer.cornerRadius = 20
        viewTop.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewTop.layer.masksToBounds = true

        btnDelete.addTarget(self, action: #selector(btnDeleteTapped), for: .touchUpInside)

    }
    
    @objc func btnDeleteTapped() {
           delegate?.deleteJournal(at: self.tag)
    }


}
