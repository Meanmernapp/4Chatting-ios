//
//  BlockCell.swift
//  Hiddy
//
//  Created by APPLE on 12/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit


class BlockCell: UITableViewCell {
    @IBOutlet var userImgView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var profileBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImgView.rounded()
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
        }
        else {
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
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
        let imageName:String = contactDict.value(forKey: "user_image") as! String
        self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        
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
                }else if mutual == "false"{
                    self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
                }
            }
        }
    }
    func configSearch(contactDict:NSDictionary, index: IndexPath, recentArray: NSMutableArray, overAllArray: NSMutableArray) {
        self.nameLbl.text = contactDict.value(forKey: "search_name") as? String
        let imageName:String = contactDict.value(forKey: "search_image") as! String
        let type:String = contactDict.value(forKey: "search_type") as! String
        if type == "group"{
            var indexCount = recentArray.count
            if index[0] == 1{
                indexCount = index[1] + indexCount
                self.profileBtn.tag = indexCount
            }
            self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }else if type == "contact"{
            if index[0] == 0{
                self.profileBtn.tag = index[1]
            }
            self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }else{
            self.profileBtn.tag = overAllArray.count - 1
            self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }
    func configSubscriber(contactDict:NSDictionary){
        let userid = contactDict.value(forKey: "_id") as? String
        let phone = contactDict.value(forKey: "phone_no") as? NSNumber
        if (UserModel.shared.contactIDs()?.contains(userid!))!{
            let localObj = LocalStorage()
            let userDict:NSDictionary = localObj.getContact(contact_id: userid!)
            let contactname = userDict.value(forKey: "contact_name") as? String
            let cc = userDict.value(forKey: "countrycode") as? String ?? ""
            if contactname == "+\(cc) \((phone)!)" {
                self.nameLbl.text = contactDict.value(forKey: "user_name") as? String
            }else{
                self.nameLbl.text = contactname
            }
        }else{
            self.nameLbl.text = contactDict.value(forKey: "user_name") as? String
        }
        if "\(phone!)" ==  UserModel.shared.phoneNo() as String? {
            self.nameLbl.text = "You"
        }
        let imageName:String = contactDict.value(forKey: "user_image") as! String
        self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        
        if userid != UserModel.shared.userID()! as String {
        let privacy_image:String = contactDict.value(forKey: "privacy_profile_image") as! String
        let mutual:String = contactDict.value(forKey: "contactstatus") as! String
        let blockedStatus:String = "0"
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
}
