//
//  languageCell.swift
//  Hiddy
//
//  Created by APPLE on 16/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class languageCell: UITableViewCell {

    @IBOutlet var selctionView: UIView!
    @IBOutlet var languageNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.languageNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.selctionView.backgroundColor = .white
        self.selctionView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.changeRTLView()
        self.contentView.backgroundColor = BACKGROUND_COLOR
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.languageNameLbl.textAlignment = .right
            self.languageNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.languageNameLbl.textAlignment = .left
            self.languageNameLbl.transform = .identity
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
