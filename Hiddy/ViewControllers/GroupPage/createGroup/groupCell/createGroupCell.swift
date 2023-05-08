//
//  groupCell.swift
//  Hiddy
//
//  Created by APPLE on 12/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class createGroupCell: UITableViewCell {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var aboutLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImgView.rounded()
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        self.aboutLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.selectionView.backgroundColor = .white
        self.selectionView.setViewBorder(color: SELECTION_BORDER_COLOR)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.nameLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutLbl.textAlignment = .right
            self.aboutLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.userImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.nameLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.aboutLbl.textAlignment = .left
            self.aboutLbl.transform = .identity
            self.userImgView.transform = .identity
        }
        self.contentView.backgroundColor = BACKGROUND_COLOR
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //config cell with details
    func config(contactDict:NSDictionary) {
        self.nameLbl.text = contactDict.value(forKey: "contact_name") as? String
        self.aboutLbl.text =  "\(contactDict.value(forKey: "user_aboutus") as! String)"
        let imageName:String = contactDict.value(forKey: "user_image") as! String
        self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        let privacy_image:String = contactDict.value(forKey: "privacy_image") as! String
        let privacy_about:String = contactDict.value(forKey: "privacy_about") as! String
        let mutual:String = contactDict.value(forKey: "mutual_status") as! String
        let blockedStatus:String = contactDict.value(forKey: "blockedMe") as! String
        DispatchQueue.main.async {
            let isDeleted:String = contactDict.value(forKey: "isDelete") as! String

            if isDeleted == "1"{
                self.nameLbl.text = Utility.language?.value(forKey: "deleted_account") as? String
            }else{
            if blockedStatus == "1"{
                self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
            }else if blockedStatus == "0"{
                //picture
                if privacy_image == "nobody"{
                    self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
                }else if privacy_image == "everyone"{
                    self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else if privacy_image == "mycontacts"{
                    if mutual == "true"{
                        self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                    }else if mutual == "false"{
                        self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
                    }
                }
                //about
                if privacy_about == "nobody"{
                    self.aboutLbl.isHidden = true
                }else if privacy_about == "everyone"{
                    self.aboutLbl.isHidden = false
                }else if privacy_about == "mycontacts"{
                    if mutual == "true"{
                        self.aboutLbl.isHidden = false
                    }else{
                        self.aboutLbl.isHidden = true
                    }
                }
            }
        }
        }
    }
}
