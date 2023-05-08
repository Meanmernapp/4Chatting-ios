//
//  ContactPickerTableViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 09/06/21.
//  Copyright © 2021 HITASOFT. All rights reserved.
//

import UIKit

class ContactPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        self.headerLabel.config(color:.black, size: 17, align: .left, text: EMPTY_STRING)
        self.mobileNumberLabel.config(color:.black, size: 16, align: .left, text: EMPTY_STRING)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
