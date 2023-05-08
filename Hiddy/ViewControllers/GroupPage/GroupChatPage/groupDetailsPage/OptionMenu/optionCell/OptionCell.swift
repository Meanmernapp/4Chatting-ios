//
//  OptionCell.swift
//  Hiddy
//
//  Created by APPLE on 27/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class OptionCell: UITableViewCell {
    @IBOutlet var menuLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        menuLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
