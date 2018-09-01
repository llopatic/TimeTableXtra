//
//  InfoTableViewCell.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 25/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var readSwitch: UISwitch!
    
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
