//
//  ChatDetailsSectionTableViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 16/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit

class ChatDetailsSectionTableViewCell: UITableViewHeaderFooterView {
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var backgroundShadowView: UIView!
    @IBOutlet weak var encryptionTextLabel: UILabel!
    
    let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.encryptionTextLabel.config(color:.white, size: 15, align: .center, text: "encryption_content")
        self.backgroundShadowView.layer.cornerRadius = 5
        self.backgroundShadowView.clipsToBounds = true
        self.applyGradientView()
        self.changeRTLView()
        // Initialization code
    }
    func applyGradientView() {
        gradientLayer.removeFromSuperlayer()
        gradientLayer.colors = PRIMARY_COLOR
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0, 1]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = CGRect(x: self.backgroundShadowView.frame.origin.x - 10, y: self.backgroundShadowView.frame.origin.y - 10, width: FULL_WIDTH - 20, height: self.backgroundShadowView.frame.height - 10)
        self.layoutSubviews()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.encryptionTextLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.encryptionTextLabel.textAlignment = .right
        }
        else {
            self.encryptionTextLabel.transform = .identity
            self.encryptionTextLabel.textAlignment = .left
        }
    }
    
}
