//
//  SelectCallCell.swift
//  Hiddy
//
//  Created by APPLE on 30/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class SelectCallCell: UITableViewCell {
    @IBOutlet var userImgView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var profileBtn: UIButton!
    @IBOutlet var videoImgView: UIImageView!
    @IBOutlet var audioImgView: UIImageView!
    @IBOutlet var videoBtn: UIButton!
    @IBOutlet var callBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImgView.rounded()
        
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.nameLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.userImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            videoImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            audioImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.nameLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.userImgView.transform = .identity
            videoImgView.transform = .identity
            audioImgView.transform = .identity
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //config cell with details
    func config(contactDict:NSDictionary) {
        self.nameLbl.text = contactDict.value(forKey: "contact_name") as? String
        let imageName:String = contactDict.value(forKey: "user_image") as! String
        
        let privacy_image:String = contactDict.value(forKey: "privacy_image") as! String
        let mutual:String = contactDict.value(forKey: "mutual_status") as! String
        let blockedStatus:String = contactDict.value(forKey: "blockedMe") as! String
        
        if blockedStatus == "1"{
            self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
        }else if blockedStatus == "0"{
            if privacy_image == "nobody"{
                self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
            }else if privacy_image == "everyone"{
                self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            }else if privacy_image == "mycontacts"{
                if mutual == "true"{
                    self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else{
                    self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
                }
            }
        }
    }
}
