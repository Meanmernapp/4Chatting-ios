//
//  MenuTableCell.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 15/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit

class MenuTableCell: UITableViewCell {

    @IBOutlet var menuNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        // Initialization code
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configCell(menuDict:NSDictionary) {
        let menuName:String = menuDict.value(forKey: "menu_name")as! String
        menuNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text:menuName)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.menuNameLbl.textAlignment = .right
            self.menuNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.menuNameLbl.textAlignment = .left
            self.menuNameLbl.transform = .identity
        }

    }
    
}
