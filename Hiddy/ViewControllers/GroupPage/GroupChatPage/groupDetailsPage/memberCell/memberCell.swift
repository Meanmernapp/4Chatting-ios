//
//  memberCell.swift
//  Hiddy
//
//  Created by APPLE on 23/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class memberCell: UITableViewCell {
    @IBOutlet var userImgView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var profileBtn: UIButton!
    @IBOutlet var roleLbl: UILabel!
    @IBOutlet var roleView: UIView!
    @IBOutlet var usernameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImgView.rounded()
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 19, align: .left, text: EMPTY_STRING)
        self.roleLbl.config(color: SECONDARY_COLOR, size: 15, align: .center, text: "admin")
        self.usernameLbl.config(color: TEXT_TERTIARY_COLOR, size: 14, align: .right, text: EMPTY_STRING)
        self.roleView.cornerViewRadius()
        self.roleView.layer.borderWidth = 1
        self.roleView.layer.borderColor = SECONDARY_COLOR.cgColor
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.usernameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.usernameLbl.textAlignment = .right
            self.userImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.usernameLbl.transform = .identity
            self.usernameLbl.textAlignment = .left
            self.userImgView.transform = .identity
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //config cell with details
    func config(contactDict:NSDictionary) {
        let member_id :String = contactDict.value(forKey: "member_id") as! String
        let contactName = contactDict.value(forKey: "contact_name") as? String
        let phone = contactDict.value(forKey: "member_no") as? String
        
        if  contactName == phone {
            self.usernameLbl.isHidden = false
            let username:String = contactDict.value(forKey: "member_name") as! String
            self.usernameLbl.text = "@\(username)"
        }else{
            self.usernameLbl.isHidden = true
        }
        
        if member_id == "\(UserModel.shared.userID()!)"{
            self.usernameLbl.isHidden = true
            self.nameLbl.text = "\((Utility().getLanguage()?.value(forKey: "you"))!)"
        } else{
            self.nameLbl.text = contactName
        }
        
        let imageName:String = contactDict.value(forKey: "member_image") as! String
        self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        let role:String = contactDict.value(forKey: "member_role") as! String
        if  role == "0" {
            self.roleView.isHidden = true
            self.nameLbl.frame = CGRect.init(x: 80, y: 14, width: FULL_WIDTH-100, height: 32)
        }else{
            self.roleView.isHidden = false
            self.nameLbl.frame = CGRect.init(x: 80, y: 14, width: FULL_WIDTH-160, height: 32)
            if  contactName == phone && member_id != "\(UserModel.shared.userID()!)"{
                self.roleView.frame = CGRect.init(x: FULL_WIDTH-85, y: 7, width: 65, height: 30)
            }else{
                self.roleView.frame = CGRect.init(x: FULL_WIDTH-85, y: 15, width: 65, height: 30)
            }
        }
        
        let privacy_image:String = contactDict.value(forKey: "privacy_image") as! String
        let mutual:String = contactDict.value(forKey: "mutual_status") as! String
        let blockedStatus:String = contactDict.value(forKey: "blocked_me") as! String
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
