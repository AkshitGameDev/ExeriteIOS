//
//  ExerciseTableCell.swift
//  Exerite
//
//  Created by Om on 22/03/24.
//

import UIKit

class ExerciseTableCell: UITableViewCell {

    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewCircle.layer.cornerRadius = viewCircle.frame.height / 2
        viewContent.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
