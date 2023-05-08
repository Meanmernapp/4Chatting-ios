//
//  GroupCell.swift
//  Hiddy
//
//  Created by APPLE on 01/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    
    @IBOutlet var lastMsgLbl: UILabel!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var userImgView: UIImageView!
    @IBOutlet var separatorLbl: UILabel!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var unreadLbl: UILabel!
    @IBOutlet var unreadView: UIView!
    @IBOutlet var media_Icon: UIImageView!
    @IBOutlet var typingLbl: UILabel!
    @IBOutlet var profileBtn: UIButton!
    @IBOutlet var muteIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.isHidden = true
        self.userNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: EMPTY_STRING)
        self.lastMsgLbl.config(color: TEXT_SECONDARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        self.timeLbl.config(color: TEXT_SECONDARY_COLOR, size: 15, align: .right, text: EMPTY_STRING)
        self.unreadView.cornerViewRadius()
        self.unreadLbl.config(color: .white, size: 14, align: .center, text: EMPTY_STRING)
        self.userImgView.rounded()
        self.backgroundColor = BACKGROUND_COLOR

        self.unreadView.backgroundColor = UNREAD_COLOR
        self.separatorLbl.backgroundColor = SEPARTOR_COLOR
        self.typingLbl.config(color: SECONDARY_COLOR, size: 18, align: .left, text: "someone_typing")
        self.RTLView()
        
    }
    
    func RTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.lastMsgLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.lastMsgLbl.textAlignment = .right
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .left
            self.typingLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.typingLbl.textAlignment = .right
            self.unreadLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            //            self.unreadLbl.textAlignment = .right
            self.separatorLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.separatorLbl.textAlignment = .right
            self.userNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.userNameLbl.textAlignment = .right
        }
        else {
            self.lastMsgLbl.transform = .identity
            self.lastMsgLbl.textAlignment = .left
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .right
            self.typingLbl.transform = .identity
            self.typingLbl.textAlignment = .left
            self.unreadLbl.transform = .identity
            //            self.unreadLbl.textAlignment = .left
            self.separatorLbl.transform = .identity
            self.separatorLbl.textAlignment = .left
            self.userNameLbl.transform = .identity
            self.userNameLbl.textAlignment = .left
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func config(groupDict:NSDictionary) {
        
        self.userNameLbl.text = groupDict.value(forKey: "group_name") as? String
        self.lastMsgLbl.text = groupDict.value(forKey: "message") as? String
        let imageName:String = groupDict.value(forKey: "group_icon") as! String
        DispatchQueue.main.async {
            self.userImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "group_placeholder"))
        }
        
     
        
        let unread_count:String = groupDict.value(forKey: "unread_count") as! String
        self.unreadLbl.text = unread_count
        self.unreadLbl.sizeToFit()
        if Int(unread_count)! > 99 {
            self.unreadView.frame.size.width = self.unreadLbl.intrinsicContentSize.width + 20
            self.unreadLbl.frame = CGRect.init(x: 0, y: 0, width: self.unreadLbl.intrinsicContentSize.width + 20, height: self.unreadView.frame.size.height)
        }else{
            self.unreadLbl.frame = CGRect.init(x: 0, y: 0, width: self.unreadView.frame.size.width, height: self.unreadView.frame.size.height)
        }
        
        if unread_count == "0" {
            self.unreadView.isHidden = true
        }else{
            self.unreadView.isHidden = false
        }
        //set time
        print("checkkkk \(groupDict)")
        let time:String = groupDict.value(forKey: "timestamp") as! String
        
        
        if groupDict.value(forKey: "message_type") != nil {
            
            let message_type:String = groupDict.value(forKey: "message_type") as! String
            if message_type == "date_sticky"{
                self.timeLbl.text = ""
            }else{
                self.timeLbl.text = Utility.shared.chatTime(stamp: time)
            }
            //check and hide read status based on sender receiver
            let member_id:String = groupDict.value(forKey: "member_id") as! String
            self.lastMsgLbl.frame = CGRect.init(x: self.userNameLbl.frame.origin.x, y: self.userNameLbl.frame.origin.y+self.userNameLbl.frame.size.height+7, width: self.unreadView.frame.origin.x, height: 21)
            let type:String = groupDict.value(forKey: "message_type") as! String
            let typingStatus:String = groupDict.value(forKey: "typing") as! String
            let isDownload:String = groupDict.value(forKey: "isDownload") as! String
            let exitStatus:String = groupDict.value(forKey: "exit") as! String
            if typingStatus == "0" || exitStatus == "1"{
                self.typingLbl.isHidden = true
                self.lastMsgLbl.isHidden = false
                if type == "text" {
                    self.media_Icon.isHidden = true
                    self.userImgView.frame = CGRect.init(x: 15, y: 20, width: 50, height: 50)
                    self.userNameLbl.frame = CGRect.init(x: 80, y: 20, width: 200, height: 25)
                    self.lastMsgLbl.frame = CGRect.init(x: self.userNameLbl.frame.origin.x, y: self.userNameLbl.frame.origin.y+self.userNameLbl.frame.size.height+7, width: self.unreadView.frame.origin.x, height: 21)
                }else if type == "create_group" || type == "user_added" || type == "group_image" || type == "left" ||  type ==  "add_member" || type ==  "remove_member" || type == "admin" || type == "subject" || type == "change_number" {
                    self.media_Icon.isHidden = true
                    self.userImgView.frame = CGRect.init(x: 15, y: 20, width: 50, height: 50)
                    self.userNameLbl.frame = CGRect.init(x: 80, y: 20, width: 200, height: 25)
                    self.lastMsgLbl.frame = CGRect.init(x: self.userNameLbl.frame.origin.x, y: self.userNameLbl.frame.origin.y+self.userNameLbl.frame.size.height+7, width: self.unreadView.frame.origin.x, height: 21)
                print("*****group member \(groupDict)")
                    self.lastMsgLbl.text = self.getMsg(groupDict: groupDict)
                }
                else {
                    self.media_Icon.isHidden = false
                    self.setDesignChanges(msgType: type,xPos: self.userNameLbl.frame.origin.x)
                }
            }else{
                self.typingLbl.isHidden = false
                let typeStatus = groupDict.value(forKey: "typing") as! String
                let splitype = typeStatus.split(separator: " ")
                if splitype.last == "recording" {
                    self.typingLbl.text = "\((splitype.first!)) \((Utility.language?.value(forKey:"recording"))!)"
                }else {
                    self.typingLbl.text = "\((groupDict.value(forKey: "typing"))!) \((Utility.language?.value(forKey:"typing"))!)"
                }
                self.media_Icon.isHidden = true
                self.lastMsgLbl.isHidden = true
            }
            if(UserModel.shared.userID()?.isEqual(to: member_id))!{
                if type == "video" && isDownload == "4"{
                    self.media_Icon.image = #imageLiteral(resourceName: "attach_camera")
                    self.lastMsgLbl.text = Utility.language?.value(forKey: "sending") as? String
                    self.setDesignChanges(msgType: type,xPos: self.userNameLbl.frame.origin.x)
                }
            }
            if type == "isDelete" {
                self.media_Icon.isHidden = true
                if (UserModel.shared.userID()?.isEqual(to: member_id))! {
                    self.lastMsgLbl.text = Utility().getLanguage()?.value(forKey: "deleted_by_you") as? String ?? ""
                }
                else {
                    self.lastMsgLbl.text = Utility().getLanguage()?.value(forKey: "deleted_by_others") as? String ?? ""
                }
            }
//            if type != "isDelete" && type != "text" && type != "story" {
//                self.lastMsgLbl.text = Utility().getLanguage()?.value(forKey: type) as? String ?? ""
//            }
            
        }else{//hide when clear all msgs
            self.typingLbl.isHidden = true
            self.media_Icon.isHidden = true
            self.lastMsgLbl.isHidden = true
        }
        let mute:String = groupDict.value(forKey: "mute") as! String
        if mute == "0"{
            self.muteIcon.isHidden = true
        }else if mute == "1"{
            self.muteIcon.isHidden = false
        }
        self.contentView.isHidden = false
        self.RTLView()
    }
    
    func setDesignChanges(msgType:String,xPos:CGFloat)  {
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
        self.media_Icon.frame = CGRect.init(x: xPos, y: self.userNameLbl.frame.origin.y+self.userNameLbl.frame.size.height+7, width: 15, height: 15)
        self.lastMsgLbl.frame = CGRect.init(x: self.media_Icon.frame.origin.x+20, y: self.media_Icon.frame.origin.y, width: self.unreadView.frame.origin.x, height: 21)
        self.userImgView.frame = CGRect.init(x: 15, y: 20, width: 50, height: 50)
        self.userNameLbl.frame = CGRect.init(x: 80, y: 20, width: 200, height: 25)
    }
    func getMsg(groupDict:NSDictionary)->String {
        let msgType:String = groupDict.value(forKey: "message_type") as! String
        let admin_id:String = groupDict.value(forKey: "admin_id") as! String
        let member_id:String = groupDict.value(forKey: "member_id") as! String
        let message:String = groupDict.value(forKey: "message") as! String
        let message_id:String = groupDict.value(forKey: "message_id") as! String
        
        print("admin id \(admin_id)")
        if msgType == "create_group"{
            if admin_id == "\(UserModel.shared.userID()!)"{ // group created
                return  "\(Utility().getLanguage()?.value(forKey: "you_created_group") as? String ?? "") \"\(message)\""
            }else{
                return  "\(Utility.shared.getUsername(user_id:admin_id)) \(Utility().getLanguage()?.value(forKey: "crated_group") as? String ?? "") \"\(message)\""
            }
        }
        else if msgType == "user_added"{  //user added
            if member_id == "\(UserModel.shared.userID()!)"{
                return "\(Utility.shared.getUsername(user_id: admin_id)) \(Utility().getLanguage()?.value(forKey: "added_you") as? String ?? "")"
            }else{
                return  "\(Utility.shared.getUsername(user_id: member_id)) \(Utility().getLanguage()?.value(forKey: "added_you") as? String ?? "")"
            }
        }
        else if msgType == "left"{ // member exited
            if member_id == "\(UserModel.shared.userID()!)"{
                return (Utility().getLanguage()?.value(forKey: "you_left") as? String ?? "")
            }else{
                return "\(Utility.shared.getUsername(user_id: member_id)) \(Utility().getLanguage()?.value(forKey: "left") as? String ?? "")"
            }
        }else if msgType == "group_image"{// group icon changed
            if member_id == "\(UserModel.shared.userID()!)"{
                return (Utility().getLanguage()?.value(forKey: "you_changed_group_icon") as? String ?? "")
            }else{
                return "\(Utility.shared.getUsername(user_id: member_id)) \(Utility().getLanguage()?.value(forKey: "group_icon_changed") as? String ?? "")"
            }
        }else if msgType == "subject"{// group icon changed
            if member_id == "\(UserModel.shared.userID()!)"{
                return "\(Utility().getLanguage()?.value(forKey: "you") as? String ?? "") \(message)"
            }else{
                return "\(Utility.shared.getUsername(user_id: member_id)) \(message)"
            }
        }else if msgType == "add_member"{
            let groupObj = groupStorage()
            let model = groupObj.getGroupMsg(msg_id: message_id)
            let names  = Utility.shared.getNames(membersStr: model!.attachment)
            if admin_id == "\(UserModel.shared.userID()!)"{
                return "\(Utility().getLanguage()?.value(forKey: "you_group_added") as? String ?? "") \(names)"
            }else{
                return "\(Utility.shared.getUsername(user_id: member_id)) \(Utility().getLanguage()?.value(forKey: "added") as? String ?? "") \(names)"
            }
        }else if msgType == "admin"{
            if member_id == "\(UserModel.shared.userID()!)"{
                let groupObj = groupStorage()
                let model = groupObj.getGroupMsg(msg_id: message_id)
                if model?.attachment == "1"{
                    return (Utility().getLanguage()?.value(forKey: "you_are_admin") as? String ?? "")
                }else{
                    return (Utility().getLanguage()?.value(forKey: "no_longer_admin") as? String ?? "")
                }
            }
        }else if msgType == "remove_member"{
            if admin_id == "\(UserModel.shared.userID()!)"{
                return "\(Utility().getLanguage()?.value(forKey: "you_removed") as? String ?? "") \((Utility.shared.getUsername(user_id: member_id)))"
            }else if member_id == "\(UserModel.shared.userID()!)"{
                return "\((Utility.shared.getUsername(user_id: admin_id))) \(Utility().getLanguage()?.value(forKey: "removed_you") as? String ?? "")"
            }else {
                return "\((Utility.shared.getUsername(user_id: admin_id))) \(Utility().getLanguage()?.value(forKey: "removed") as? String ?? "") \((Utility.shared.getUsername(user_id: member_id)))"
            }
        }else if msgType == "change_number"{
            if member_id == "\(UserModel.shared.userID()!)"{
                return (Utility().getLanguage()?.value(forKey: "changed_new_no") as? String ?? "")
            }else {
                let groupObj = groupStorage()
                let model = groupObj.getGroupMsg(msg_id: message_id)
                var old_no_name = Utility.shared.searchPhoneNoAvailability(phoneNo: model!.attachment)
                var new_no_name = Utility.shared.searchPhoneNoAvailability(phoneNo: model!.contact_no)
                if old_no_name == EMPTY_STRING{
                    old_no_name = model!.attachment
                }
                if new_no_name == EMPTY_STRING{
                    new_no_name = model!.contact_no
                }
                return "\(old_no_name) \(model?.message)"
            }
        }
        return EMPTY_STRING
    }
}

