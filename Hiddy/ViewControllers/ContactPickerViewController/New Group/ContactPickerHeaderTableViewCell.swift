//
//  ContactPickerHeaderTableViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 09/06/21.
//  Copyright © 2021 HITASOFT. All rights reserved.
//

import UIKit

class ContactPickerHeaderTableViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configUI() {
        self.profileImageView.image = #imageLiteral(resourceName: "attach_contact")
        self.contactNameLabel.config(color:.black, size: 16, align: .left, text: EMPTY_STRING)
    }
}
