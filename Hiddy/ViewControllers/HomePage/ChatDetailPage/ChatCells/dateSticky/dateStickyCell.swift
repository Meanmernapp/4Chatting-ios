//
//  dateStickyCell.swift
//  Hiddy
//
//  Created by APPLE on 25/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class dateStickyCell: UITableViewCell {

    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.cornerViewRadius()
        self.containerView.backgroundColor =  UIColor().hexValue(hex: "#DCDCDC")
        self.dateLbl.config(color: UIColor().hexValue(hex: "#9E9D9D"), size: 14, align: .center, text: EMPTY_STRING)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
