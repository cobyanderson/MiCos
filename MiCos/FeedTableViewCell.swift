//
//  FeedTableViewCell.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 3/7/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var awarderLabel: UILabel!
    
    @IBOutlet weak var arcLabel: UILabel!

    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
