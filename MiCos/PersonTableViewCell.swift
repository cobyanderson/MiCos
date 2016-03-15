//
//  PersonTableViewCell.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 3/9/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    

    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
