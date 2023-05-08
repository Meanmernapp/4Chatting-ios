//
//  RecentCell.swift
//  Hiddy
//
//  Created by APPLE on 31/05/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class RecentCell: UITableViewCell {
    
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var favouriteIcon: UIImageView!
    @IBOutlet var lastMsgLbl: UILabel!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var userImgView: UIImageView!
    @IBOutlet var separatorLbl: UILabel!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var statusImgView: UIImageView!
    @IBOutlet var unreadLbl: UILabel!
    @IBOutlet var unreadView: UIView!
    @IBOutlet var media_Icon: UIImageView!
    @IBOutlet var typingLbl: UILabel!
    @IBOutlet var profileBtn: UIButton!
    @IBOutlet var muteIcon: UIImageView!
    @IBOutlet var stackViewTrailConst: NSLayoutConstraint!
   @IBOutlet var stackViewLeadConst: NSLayoutConstraint!
    
    @IBOutlet var unreadConst: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: EMPTY_STRING)
        self.lastMsgLbl.config(color: TEXT_SECONDARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        self.timeLbl.config(color: TEXT_SECONDARY_COLOR, size: 15, align: .right, text: EMPTY_STRING)
        self.unreadView.cornerViewRadius()
        self.unreadLbl.config(color: .white, size: 14, align: .center, text: EMPTY_STRING)
        self.userImgView.rounded()
        self.separatorLbl.backgroundColor = SEPARTOR_COLOR
        self.typingLbl.config(color: SECONDARY_COLOR, size: 16, align: .left, text: "typing")
        self.unreadView.backgroundColor = UNREAD_COLOR
        self.changeRTL()
        self.contentView.backgroundColor = BACKGROUND_COLOR
        self.backgroundColor = BACKGROUND_COLOR
    }
    func changeRTL() {
        
        if UserModel.shared.getAppLanguage() == "عربى" {
        self.lastMsgLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.lastMsgLbl.textAlignment = .right
        self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.timeLbl.textAlignment = .right
        self.typingLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.typingLbl.textAlignment = .right
        self.unreadLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        //            self.unreadLbl.textAlignment = .right
        self.separatorLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.separatorLbl.textAlignment = .right
        self.userNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.userNameLbl.textAlignment = .right
        self.rightStackView.alignment = .leading
        for view in self.contentView.subviews {
            if let imageView = view.viewWithTag(1) as? UIImageView {
                imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
            self.stackViewLeadConst.isActive = true
            self.stackViewTrailConst.isActive = false
        }
        else {
            self.lastMsgLbl.transform = .identity
            self.lastMsgLbl.textAlignment = .left
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.typingLbl.transform = .identity
            self.typingLbl.textAlignment = .left
            self.unreadLbl.transform = .identity
            self.separatorLbl.transform = .identity
            self.separatorLbl.textAlignment = .left
            self.userNameLbl.transform = .identity
            self.userNameLbl.textAlignment = .left
            self.rightStackView.alignment = .trailing
            for view in self.contentView.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
            self.stackViewLeadConst.isActive = false
            self.stackViewTrailConst.isActive = true

        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(recentDict:NSDictionary) {
        let deleteAccount = recentDict.value(forKey: "isDelete") as! String
        if deleteAccount == "1"{
            self.userNameLbl.text = "\(recentDict.value(forKey: "contact_name") as? String ?? "") - \(Utility.shared.getLanguage()?.value(forKey: "deleted_account") ?? "")"
        }else{
            self.userNameLbl.text = recentDict.value(forKey: "contact_name") as? String
        }
        self.lastMsgLbl.text = recentDict.value(forKey: "message") as? String
        
        let unread_count:String = recentDict.value(forKey: "unread_count") as! String
        self.unreadLbl.text = unread_count
        self.unreadLbl.sizeToFit()
        if Int(unread_count)! > 99 {
            self.unreadConst.constant = self.unreadLbl.intrinsicContentSize.width + 20
            self.unreadLbl.frame = CGRect.init(x: 0, y: 2, width: self.unreadLbl.intrinsicContentSize.width + 20, height: self.unreadView.frame.size.height)
        }else{
            self.unreadLbl.frame = CGRect.init(x: 0, y: 2, width: self.unreadView.frame.size.width, height: self.unreadView.frame.size.height)

        }
        if unread_count == "0" {
            self.unreadView.isHidden = true
        }else{
            self.unreadView.isHidden = false
        }
        //set time
        let time:String = recentDict.value(forKey: "timestamp") as! String
        /*
        self.timeLbl.text = Utility.shared.chatTime(stamp: time)
        */
        //old
        self.timeLbl.text = Utility.shared.setChatDate(timeStamp: time)

        
        if recentDict.value(forKey: "message_type") != nil {
            //set read status
            let status:String = recentDict.value(forKey: "read_status") as! String
            if status == "1"{
                self.statusImgView.image = #imageLiteral(resourceName: "status_sent")
            }else if status == "2"{
                self.statusImgView.image = #imageLiteral(resourceName: "status_notified")
            }else if status == "3"{
                self.statusImgView.image = #imageLiteral(resourceName: "read_tick")
            }
            //check and hide read status based on sender receiver
            let sender_id:String = recentDict.value(forKey: "sender_id") as! String
            if (UserModel.shared.userID()?.isEqual(to: sender_id))! {
                self.statusImgView.isHidden = false
            }else{
                self.statusImgView.isHidden = true
                self.lastMsgLbl.frame = CGRect.init(x: self.userNameLbl.frame.origin.x, y: self.userNameLbl.frame.origin.y+self.userNameLbl.frame.size.height+7, width: 200, height: 21)
                
            }
            
            let msgType:String = recentDict.value(forKey: "message_type") as! String
            let typingStatus:String = recentDict.value(forKey: "typing") as! String
            let isDownload:String = recentDict.value(forKey: "isDownload") as! String
            
            if typingStatus == "0" {
                self.typingLbl.isHidden = true
                self.lastMsgLbl.isHidden = false
                
                if (msgType == "text" || msgType == "isDelete" || msgType == "story") && (UserModel.shared.userID()?.isEqual(to: sender_id))!{
                    self.media_Icon.isHidden = true
                    self.statusImgView.frame = CGRect.init(x: self.userNameLbl.frame.origin.x, y: self.userNameLbl.frame.origin.y+32, width: 17, height: 17)
                    self.lastMsgLbl.frame = CGRect.init(x: self.userNameLbl.frame.origin.x+20, y: self.userNameLbl.frame.origin.y+30, width: 200, height: 21)
                    
                }else if msgType == "text" && !(UserModel.shared.userID()?.isEqual(to: sender_id))!{
                    self.statusImgView.isHidden = true
                    self.media_Icon.isHidden = true
                    self.lastMsgLbl.frame = CGRect.init(x: self.userNameLbl.frame.origin.x, y: self.userNameLbl.frame.origin.y+30, width: 200, height: 21)
                    
                }else if(UserModel.shared.userID()?.isEqual(to: sender_id))!{
                    self.statusImgView.isHidden = false
                    self.media_Icon.isHidden = false
                    let statusImgPos = self.userNameLbl.frame.origin.x
                    let mediaImgPos = self.statusImgView.frame.origin.x+20
                    self.setDesignChanges(msgType: msgType, statusX: statusImgPos, mediaX: mediaImgPos)
                }else if !(UserModel.shared.userID()?.isEqual(to: sender_id))!{
                    self.statusImgView.isHidden = true
                    self.media_Icon.isHidden = false
                    let mediaImgPos = self.userNameLbl.frame.origin.x
                    let statusImgPos = self.userNameLbl.frame.origin.x
                    self.setDesignChanges(msgType: msgType, statusX: statusImgPos, mediaX: mediaImgPos)
                }
            }else{
                let mediaImgPos = self.userNameLbl.frame.origin.x
                let statusImgPos = self.userNameLbl.frame.origin.x
                self.setDesignChanges(msgType: msgType, statusX: statusImgPos, mediaX: mediaImgPos)
                let blockedStatus:String = recentDict.value(forKey: "blockedMe") as! String
                let blockByMe:String = recentDict.value(forKey: "blockedByMe") as! String
                if blockedStatus != "1" && blockByMe != "1"{
                    self.typingLbl.isHidden = false
                    self.media_Icon.isHidden = true
                    self.statusImgView.isHidden = true
                    self.lastMsgLbl.isHidden = true
                    if typingStatus == "1" {
                        self.typingLbl.text = Utility.shared.getLanguage()?.value(forKey: "typing") as? String ?? ""
                    }
                    else {
                        self.typingLbl.text = Utility.shared.getLanguage()?.value(forKey: "recording") as? String ?? ""
                    }
                }
            }
            
            if(UserModel.shared.userID()?.isEqual(to: sender_id))!{
                if msgType == "video" && isDownload == "4"{
                    self.media_Icon.image = #imageLiteral(resourceName: "attach_camera")
                    self.statusImgView.isHidden =  true
                    self.lastMsgLbl.text = Utility.language?.value(forKey: "sending") as? String
                    let mediaImgPos = self.userNameLbl.frame.origin.x
                    let statusImgPos = self.userNameLbl.frame.origin.x
                    self.setDesignChanges(msgType: msgType, statusX: statusImgPos, mediaX: mediaImgPos)
                }
            }
            if msgType == "isDelete" {
                if (UserModel.shared.userID()?.isEqual(to: sender_id))! {
                    self.lastMsgLbl.text = Utility.shared.getLanguage()?.value(forKey: "deleted_by_you") as? String ?? ""
                }
                else {
                    self.lastMsgLbl.text = Utility.shared.getLanguage()?.value(forKey: "deleted_by_others") as? String ?? ""
                }
            }
            if msgType != "isDelete" && msgType != "text" && msgType != "story" {
                self.lastMsgLbl.text = Utility.shared.getLanguage()?.value(forKey: msgType) as? String ?? ""
            }
            
            if msgType == "gif" {
                       self.lastMsgLbl.text = msgType
                   }
        }else{//hide when clear all msgs
            self.typingLbl.isHidden = true
            self.media_Icon.isHidden = true
            self.statusImgView.isHidden = true
            self.lastMsgLbl.isHidden = true
        }
        
        let mute:String = recentDict.value(forKey: "mute") as! String
        if mute == "0"{
            muteIcon.isHidden = true
        }else if mute == "1"{
            muteIcon.isHidden = false
        }
        
        
        let imageName:String = recentDict.value(forKey: "user_image") as! String
        let blockedStatus:String = recentDict.value(forKey: "blockedMe") as! String
        let privacy_image:String = recentDict.value(forKey: "privacy_image") as! String
        let mutual:String = recentDict.value(forKey: "mutual_status") as! String
        DispatchQueue.main.async {
            if blockedStatus == "1"{
                self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
            }else if blockedStatus == "0"{
                if privacy_image == "nobody"{
                    self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
                }else if privacy_image == "everyone"{
                    DispatchQueue.main.async {
                        self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                    }
                }else if privacy_image == "mycontacts"{
                    if mutual == "true"{
                        self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                    }else{
                        self.userImgView.image = #imageLiteral(resourceName: "profile_placeholder")
                    }
                }
            }
        }
        
        let fav:String = recentDict.value(forKey: "favourite") as! String
        if fav == "0"{
            self.favouriteIcon.isHidden = true
        }else{
            self.favouriteIcon.isHidden = false
        }
        self.changeRTL()
    }
    
    func setDesignChanges(msgType:String,statusX:CGFloat,mediaX:CGFloat)  {
        if msgType == "image"{
            self.media_Icon.image = #imageLiteral(resourceName: "attach_gallery")
        }else if msgType == "document"{
            self.media_Icon.image = #imageLiteral(resourceName: "attach_document")
        }else if msgType == "location"{
            self.media_Icon.image = #imageLiteral(resourceName: "attach_location")
        }else if msgType == "contact"{
            self.media_Icon.image = #imageLiteral(resourceName: "attach_contact")
        }else if msgType == "video"{
            self.media_Icon.image = #imageLiteral(resourceName: "attach_camera")
        }else if msgType == "audio"{
            self.media_Icon.image = #imageLiteral(resourceName: "attach_music")
        }
        self.media_Icon.image = self.media_Icon.image!.withRenderingMode(.alwaysTemplate)
        self.media_Icon.tintColor = TEXT_SECONDARY_COLOR
        
        self.statusImgView.frame = CGRect.init(x: statusX, y: self.userNameLbl.frame.origin.y+self.userNameLbl.frame.size.height+7, width: 15, height: 15)
        self.media_Icon.frame = CGRect.init(x: mediaX, y: self.statusImgView.frame.origin.y, width: 15, height: 15)
        self.lastMsgLbl.frame = CGRect.init(x: self.media_Icon.frame.origin.x+20, y: self.media_Icon.frame.origin.y-3, width: 200, height: 21)
        self.changeRTL()

    }
    
}

