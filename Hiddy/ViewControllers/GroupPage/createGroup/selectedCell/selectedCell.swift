//
//  selectedCell.swift
//  Hiddy
//
//  Created by APPLE on 12/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class selectedCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImgView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var addStiryImgView: UIImageView!
    @IBOutlet var userImg: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var closeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImg.rounded()
        self.addStiryImgView.isHidden = true
        self.usernameLbl.config(color: TEXT_TERTIARY_COLOR, size: 14, align: .center, text: EMPTY_STRING)
        self.changeRTLView()
//        self.contentView.backgroundColor = BACKGROUND_COLOR
//        self.backgroundColor = BACKGROUND_COLOR
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear

//        self.closeView.isHidden = true
//        self.closeView.cornerViewRadius()
//        self.closeView.setViewBorder(color: .white)
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
//            self.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.usernameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.userImg.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
//            self.contentView.transform = .identity
            self.usernameLbl.transform = .identity
            self.userImg.transform = .identity
        }
    }
    //config cell with details
    func config(contactDict:NSDictionary,type:String) {
        if type == "fav"{
            self.closeView.isHidden = true
        }else{
            self.closeView.isHidden = false
        }
        self.shadowView.backgroundColor = .clear

        self.usernameLbl.text = contactDict.value(forKey: "contact_name") as? String
        let imageName:String = contactDict.value(forKey: "user_image") as! String
        
        let privacy_image:String = contactDict.value(forKey: "privacy_image") as! String
        let mutual:String = contactDict.value(forKey: "mutual_status") as! String
        let blockedStatus:String = contactDict.value(forKey: "blockedMe") as! String
        if blockedStatus == "1"{
//            self.userImg.image = #imageLiteral(resourceName: "profile_placeholder")
            self.userImg.image = #imageLiteral(resourceName: "add_story")
        }else if blockedStatus == "0"{
            if privacy_image == "nobody"{
                self.userImg.image = #imageLiteral(resourceName: "add_story")
            }else if privacy_image == "everyone"{
                self.userImg.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            }else if privacy_image == "mycontacts"{
                if mutual == "true"{
                    self.userImg.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else{
                    self.userImg.image = #imageLiteral(resourceName: "add_story")
                }
            }
        }
    }
    func configStory(contactDict:RecentStoryModel,type:String) {
        if type == "fav"{
            self.closeView.isHidden = true
        }else{
            self.closeView.isHidden = false
        }
        self.usernameLbl.text = contactDict.contactName
        let imageName:String = contactDict.userImage
        DispatchQueue.main.async {
            self.userImg.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }
    func configMember(contactDict:NSDictionary) {
        self.shadowView.backgroundColor = .clear
        let member_id =  contactDict.value(forKey: "member_id") as? String
        if member_id == "\(UserModel.shared.userID()!)"{
            self.usernameLbl.text = "You"
        }else{
            self.usernameLbl.text = contactDict.value(forKey: "contact_name") as? String
        }
        let imageName:String = contactDict.value(forKey: "member_image") as! String
        
        
        let privacy_image:String = contactDict.value(forKey: "privacy_image") as! String
        let mutual:String = contactDict.value(forKey: "mutual_status") as! String
        let blockedStatus:String = contactDict.value(forKey: "blocked_me") as! String
        DispatchQueue.main.async {
            if blockedStatus == "1"{
                self.userImg.image = #imageLiteral(resourceName: "add_story")
            }else if blockedStatus == "0"{
                if privacy_image == "nobody"{
                    self.userImg.image = #imageLiteral(resourceName: "add_story")
                }else if privacy_image == "everyone"{
                    self.userImg.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else if privacy_image == "mycontacts"{
                    if mutual == "true"{
                        self.userImg.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                    }else{
                        self.userImg.image = #imageLiteral(resourceName: "add_story")
                    }
                }
            }
        }
    }
}









