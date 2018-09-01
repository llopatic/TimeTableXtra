//
//  HomeworksTableViewCell.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 24/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class HomeworksTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var doneSwitch: UISwitch!
    
    // MARK: - Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
         // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
       
    }
    
}
