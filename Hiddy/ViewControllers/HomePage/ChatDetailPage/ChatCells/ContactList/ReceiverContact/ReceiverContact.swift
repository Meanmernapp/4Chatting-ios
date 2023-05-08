//
//  ReceiverContact.swift
//  Hiddy
//
//  Created by APPLE on 23/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class ReceiverContact: UITableViewCell {

    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var contactNameLbl: UILabel!
    @IBOutlet var phoneNoLbl: UILabel!
    @IBOutlet var addLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var backgorunView: UIView!
    @IBOutlet var contactPic: UIImageView!
    
    @IBOutlet var contactAddBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contactNameLbl.config(color: .white, size: 17, align: .left, text: EMPTY_STRING)
        self.phoneNoLbl.config(color: .white, size: 17, align: .left, text: EMPTY_STRING)
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .right, text: EMPTY_STRING)
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.containerView.backgroundColor = SECONDARY_COLOR
        self.addLbl.config(color: .white, size: 20, align: .left, text: "add_contact")
        self.contactPic.rounded()
        self.containerView.backgroundColor = RECIVER_BG_COLOR
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.phoneNoLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.phoneNoLbl.textAlignment = .right
            self.contactNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.contactNameLbl.textAlignment = .right
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.phoneNoLbl.transform = .identity
            self.phoneNoLbl.textAlignment = .left
            self.contactNameLbl.transform = .identity
            self.contactNameLbl.textAlignment = .left
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary)  {
        self.nameLbl.isHidden = true
        let contactName:String = msgDict.value(forKeyPath: "message_data.cName") as! String
        let contactNo:String = msgDict.value(forKeyPath: "message_data.cNo") as! String
        self.contactNameLbl.text = contactName
        self.phoneNoLbl.text = contactNo
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp:time)
    }
    
    //config group chat
    func configGroup(model:groupMsgModel.message)  {
        DispatchQueue.main.async {
            self.nameLbl.isHidden = false
            self.nameLbl.text = Utility.shared.getUsername(user_id: model.member_id)
            self.nameLbl.frame = CGRect.init(x: 10, y: 0, width: self.containerView.frame.width, height: 20)
            self.containerView.frame = CGRect.init(x: 10, y: 22, width: 240, height: 115)
            self.timeLbl.frame = CGRect.init(x: self.containerView.frame.width - 50, y: 106, width: 210, height: 20)
            self.addSubview(self.nameLbl)
            self.addSubview(self.containerView)
            self.addSubview(self.timeLbl)
        }
        self.contactNameLbl.text = model.contact_name
        self.phoneNoLbl.text = model.contact_no
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
    }
    
    //config group chat
    func configChannel(model:channelMsgModel.message,chatType:String)  {
        self.nameLbl.isHidden = true
        self.contactNameLbl.text = model.contact_name
        self.phoneNoLbl.text = model.contact_no
        if chatType == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        }
        
    }
    
}
