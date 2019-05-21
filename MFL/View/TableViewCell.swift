//
//  TableViewCell.swift
//  MFL
//
//  Created by Bahadir Altun on 22.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var filmImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
