//
//  SenderContact.swift
//  Hiddy
//
//  Created by APPLE on 23/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class SenderContact: UITableViewCell {
    
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var contactNameLbl: UILabel!
    @IBOutlet var phoneNoLbl: UILabel!
    @IBOutlet var contactPic: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contactNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.phoneNoLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: TEXT_TERTIARY_COLOR, size: 14, align: .left, text: EMPTY_STRING)
        self.contactPic.rounded()
        self.containerView.backgroundColor = SENDER_BG_COLOR
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.contactNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.contactNameLbl.textAlignment = .right
            self.phoneNoLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.phoneNoLbl.textAlignment = .right
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.contactNameLbl.transform = .identity
            self.contactNameLbl.textAlignment = .left
            self.phoneNoLbl.transform = .identity
            self.phoneNoLbl.textAlignment = .left
            self.statusIcon.transform = .identity
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    //config single chat
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        let contactName:String = msgDict.value(forKeyPath: "message_data.cName") as! String
        let contactNo:String = msgDict.value(forKeyPath: "message_data.cNo") as! String
        
        self.contactNameLbl.text = contactName
        self.phoneNoLbl.text = contactNo
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp:time)
        
        let status:String = msgDict.value(forKeyPath: "message_data.read_status") as! String
        let blocked:String = msgDict.value(forKeyPath: "message_data.blocked") as! String
        if blocked == "0"{
            if status == "1"{
                self.statusIcon.image = #imageLiteral(resourceName: "status_sent")
            }else if status == "2"{
                self.statusIcon.image = #imageLiteral(resourceName: "status_notified")
            }else if status == "3"{
                self.statusIcon.image = #imageLiteral(resourceName: "read_tick")
            }
            if chatRead{
                self.statusIcon.image = #imageLiteral(resourceName: "read_tick")
            }
        }else{
            self.statusIcon.image = #imageLiteral(resourceName: "status_sent")
        }
        
    }
    //config group chat
    func configGroup(model:groupMsgModel.message)  {
        self.contactNameLbl.text = model.contact_name
        self.phoneNoLbl.text = model.contact_no
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.statusIcon.isHidden = true
    }
    //config channel chat
    func configChannel(model:channelMsgModel.message)  {
        self.contactNameLbl.text = model.contact_name
        self.phoneNoLbl.text = model.contact_no
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.statusIcon.isHidden = true
    }
}
