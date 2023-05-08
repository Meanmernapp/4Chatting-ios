//
//  ForwardCell.swift
//  Hiddy
//
//  Created by APPLE on 13/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class ForwardCell: UITableViewCell {

    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var selectview: UIView!
    @IBOutlet var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profilePic.rounded()
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.selectview.backgroundColor = BACKGROUND_COLOR
        self.selectview.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.statusLbl.config(color: TEXT_TERTIARY_COLOR, size: 12, align: .left, text: "blocked")
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.statusLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.statusLbl.textAlignment = .right
        }
        else {
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.statusLbl.transform = .identity
            self.statusLbl.textAlignment = .left
        }


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //config cell with details
    func config(contactDict:NSDictionary) {
        self.nameLbl.text = contactDict.value(forKey: "search_name") as? String
        let imageName:String = contactDict.value(forKey: "search_image") as! String
        let type:String = contactDict.value(forKey: "search_type") as! String

        var path = String()
        if type == "group"{
            path = IMAGE_SUB_URL
            self.statusLbl.isHidden = true
        }else if type == "contact" || type == "recent"{
            path = USERS_SUB_URL
        }else if type == "channel"{
            path = IMAGE_SUB_URL
            self.statusLbl.isHidden = true
        }
        
        self.profilePic.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(path)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        
        if type == "contact" || type == "recent"{
        let privacy_image:String = contactDict.value(forKey: "privacy_image") as! String
        let mutual:String = contactDict.value(forKey: "mutual_status") as! String
        let blockedStatus:String = contactDict.value(forKey: "blockedMe") as! String
        let blockedByMeStatus:String = contactDict.value(forKey: "blockedByMe") as! String
        if blockedByMeStatus == "0"{
            self.statusLbl.isHidden = true
        }else{
            self.statusLbl.isHidden = false
        }

        if blockedStatus == "1"{
            self.profilePic.image = #imageLiteral(resourceName: "profile_placeholder")
        }else if blockedStatus == "0"{
            //picture
            if privacy_image == "nobody"{
                self.profilePic.image = #imageLiteral(resourceName: "profile_placeholder")
            }else if privacy_image == "everyone"{
                self.profilePic.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(path)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            }else if privacy_image == "mycontacts"{
                if mutual == "true"{
                    self.profilePic.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(path)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else{
                    self.profilePic.image = #imageLiteral(resourceName: "profile_placeholder")
                }
            }
        }
      }
    }
}
