//
//  profileCollectionViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 25/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit

class profileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 5
        self.imageView.clipsToBounds = true
        self.playView.cornerViewRadius()
        // Initialization code
        self.typeLbl.config(color: .white, size: 17, align: .center, text: "")
    }

}
