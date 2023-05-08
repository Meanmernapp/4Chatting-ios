//
//  ChannelCell.swift
//  Hiddy
//
//  Created by APPLE on 01/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
    
    @IBOutlet weak var media_Icon: UIImageView!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var channelNameLbl: UILabel!
    @IBOutlet var channel_icon: UIImageView!
    @IBOutlet var separatorLbl: UILabel!
    @IBOutlet var unreadLbl: UILabel!
    @IBOutlet var unreadView: UIView!
    @IBOutlet var profileBtn: UIButton!
    @IBOutlet var muteIcon: UIImageView!
    
    @IBOutlet var typeIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.channelNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: EMPTY_STRING)
        self.descriptionLbl.config(color: TEXT_SECONDARY_COLOR, size: 19, align: .left, text: EMPTY_STRING)
        self.unreadView.cornerViewRadius()
        self.unreadLbl.config(color: .white, size: 14, align: .center, text: EMPTY_STRING)
        self.unreadView.backgroundColor = UNREAD_COLOR
        self.channel_icon.rounded()
        self.separatorLbl.backgroundColor = SEPARTOR_COLOR
        self.backgroundColor = BACKGROUND_COLOR
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func config(channelDict:NSDictionary,type:String) {
        self.channelNameLbl.frame = CGRect.init(x: 80, y: 20, width: 200, height: 25)
        self.descriptionLbl.frame = CGRect.init(x: 80, y: self.channelNameLbl.frame.origin.y+self.channelNameLbl.frame.size.height+7, width: self.unreadView.frame.origin.x - 80, height: 21)
        self.channel_icon.frame = CGRect.init(x: 20, y: 20, width: 50, height: 50)
        if type == "des"{
//            self.channelNameLbl.frame = CGRect.init(x: 80, y: 15, width: 200, height: 25)
//            self.descriptionLbl.frame = CGRect.init(x: 80, y: self.channelNameLbl.frame.origin.y+self.channelNameLbl.frame.size.height+7, width: 200, height: 21)
//            self.separatorLbl.frame = CGRect.init(x:80,y:70, width: FULL_WIDTH-100, height: 1)
//            self.channel_icon.frame = CGRect.init(x: 20, y: 15, width: 50, height: 50)
        }
        let description:String = channelDict.value(forKey: "channel_des") as! String
        let msg_type:String = channelDict.value(forKey: "message_type") as? String ?? "text"
        let admin_id:String = channelDict.value(forKey: "admin_id") as? String ?? ""
        
        //unread count
        if channelDict.value(forKey: "unread_count") != nil{
            let unread_count:String = channelDict.value(forKey: "unread_count") as! String
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
        }else{
            self.unreadView.isHidden = true
        }
        
        print("type \(type) msg_type \(msg_type)")
        if type == "msg"{
            let msg = channelDict.value(forKey: "message") as? String
            if msg == nil || msg == "You added" || msg == EMPTY_STRING{
                self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: "you_added_channel") as? String ?? ""
            }else{
                //                self.descriptionLbl.text = description
                if msg_type == "text" {
                    self.descriptionLbl.text = msg
                }
                if msg_type == "isDelete" {
                    if (UserModel.shared.userID()?.isEqual(to: admin_id))! {
                        self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: "deleted_by_you") as? String ?? ""
                    }
                    else {
                        self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: "deleted_by_others") as? String ?? ""
                    }
                }
                else {
                    self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: msg?.lowercased() ?? "") as? String ?? ""
                }
                if self.descriptionLbl.text == "" {
                    self.descriptionLbl.text = msg
                }
                
                
                if msg_type == "added" {
                    self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: "you_added_channel") as? String
                }else if msg_type == "subject"{
                    self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: "subject_changed") as? String
                }else if msg_type == "channel_image"{
                    self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: "channel_icon_changed") as? String
                }else if msg_type == "channel_des"{
                    self.descriptionLbl.text = Utility().getLanguage()?.value(forKey: "description_changed") as? String
                }
            }
        } else{
            self.unreadView.isHidden = true
            self.descriptionLbl.text = description
        }
        
        self.channelNameLbl.text = channelDict.value(forKey: "channel_name") as? String
        let imageName:String = channelDict.value(forKey: "channel_image") as! String
        DispatchQueue.main.async {
            self.channel_icon.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "channel_placeholder"))
        }
        
        let channel_type = channelDict.value(forKey: "channel_type") as? String
        if channel_type == "private"{
            self.typeIcon.image = #imageLiteral(resourceName: "private_channel")
            self.typeIcon.isHidden = false
        }else{
            self.typeIcon.isHidden = true
        }
        
        //mute
        if channelDict.value(forKey: "mute") != nil{
            let mute:String = channelDict.value(forKey: "mute") as! String
            if mute == "0"{
                muteIcon.isHidden = true
            }else if mute == "1"{
                if channel_type != "private"{
                    muteIcon.isHidden = true
                    self.typeIcon.isHidden = false
                    self.typeIcon.image = #imageLiteral(resourceName: "mute_icon")
                }else{
                    muteIcon.isHidden = false
                    self.typeIcon.image = #imageLiteral(resourceName: "private_channel")
                    self.typeIcon.isHidden = false
                }
            }
        }else{
            muteIcon.isHidden = true
        }
        
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.descriptionLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.descriptionLbl.textAlignment = .right
            self.channelNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.channelNameLbl.textAlignment = .right
            self.separatorLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.separatorLbl.textAlignment = .right
            self.unreadLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            for view in self.contentView.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
            //            self.unreadLbl.textAlignment = .right
        }
        else {
            self.descriptionLbl.transform = .identity
            self.descriptionLbl.textAlignment = .left
            self.channelNameLbl.transform = .identity
            self.channelNameLbl.textAlignment = .left
            self.separatorLbl.transform = .identity
            self.separatorLbl.textAlignment = .left
            self.unreadLbl.transform = .identity
            for view in self.contentView.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
            //            self.unreadLbl.textAlignment = .left
        }
        self.setDesignChanges(msgType:msg_type,xPos:self.channelNameLbl.frame.origin.x)
    }
    func setDesignChanges(msgType:String,xPos:CGFloat)  {
        print(msgType)
        if (msgType != "text" && msgType != "isDelete") {
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
            self.media_Icon.isHidden = false
            self.media_Icon.image = self.media_Icon.image!.withRenderingMode(.alwaysTemplate)
            self.media_Icon.tintColor = TEXT_SECONDARY_COLOR
            self.media_Icon.frame = CGRect.init(x: xPos, y: self.channelNameLbl.frame.origin.y+self.channelNameLbl.frame.size.height+7, width: 15, height: 15)
            self.descriptionLbl.frame = CGRect.init(x: self.media_Icon.frame.origin.x+20, y: self.descriptionLbl.frame.origin.y, width: self.descriptionLbl.frame.width, height: self.descriptionLbl.frame.height)
            self.channel_icon.frame = CGRect.init(x: 15, y: 20, width: 50, height: 50)
            self.channelNameLbl.frame = CGRect.init(x: 80, y: 20, width: 200, height: 25)
        }
        else {
            self.media_Icon.isHidden = true
            self.channel_icon.frame = CGRect.init(x: 15, y: 20, width: 50, height: 50)
            self.channelNameLbl.frame = CGRect.init(x: 80, y: 20, width: 200, height: 25)
            self.descriptionLbl.frame = CGRect.init(x: self.channelNameLbl.frame.origin.x, y: self.descriptionLbl.frame.origin.y, width: self.descriptionLbl.frame.width, height: self.descriptionLbl.frame.height)
        }
    }
}


