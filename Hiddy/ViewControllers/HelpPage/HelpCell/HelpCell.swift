//
//  HelpCell.swift
//  Hiddy
//
//  Created by APPLE on 29/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class HelpCell: UITableViewCell {

    @IBOutlet var helpTitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.helpTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: "")
        self.changeRTLView()
//        self.contentView.backgroundColor = BOTTOM_BAR_COLOR

    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.helpTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.helpTitleLbl.textAlignment = .right
        }
        else {
            self.helpTitleLbl.transform = .identity
            self.helpTitleLbl.textAlignment = .left
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
