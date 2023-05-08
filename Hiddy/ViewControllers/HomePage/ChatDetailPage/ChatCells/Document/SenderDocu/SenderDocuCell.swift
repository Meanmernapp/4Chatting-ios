//
//  SenderDocuCell.swift
//  Hiddy
//
//  Created by APPLE on 23/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class SenderDocuCell: UITableViewCell {
    
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var docuNameLbl: UILabel!
    @IBOutlet var typeLbl: UILabel!
    
    @IBOutlet var docIcon: UIImageView!
    @IBOutlet weak var docBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.docuNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 19, align: .left, text: EMPTY_STRING)
        timeLbl.config(color: TEXT_TERTIARY_COLOR, size: 14, align: .right, text: EMPTY_STRING)
        self.typeLbl.config(color: .white, size: 14, align: .center, text: EMPTY_STRING)
        self.containerView.specificCornerRadius(radius: 15)
        self.containerView.clipsToBounds = true
        self.docIcon.image = self.docIcon.image!.withRenderingMode(.alwaysTemplate)
        self.docIcon.tintColor = .lightGray
        self.containerView.backgroundColor = SENDER_BG_COLOR
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.typeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.typeLbl.textAlignment = .right
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.typeLbl.transform = .identity
            self.typeLbl.textAlignment = .left
            self.statusIcon.transform = .identity
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        let path:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(path)")
        self.typeLbl.text = docURL?.pathExtension.uppercased()
        
        let docuName:String = msgDict.value(forKeyPath: "message_data.message") as! String
        self.docuNameLbl.text = docuName
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp: time)
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
    //config group msg
    func configGroup(model:groupMsgModel.message)  {
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)")
        self.typeLbl.text = docURL?.pathExtension.uppercased()
        
        self.docuNameLbl.text = model.message
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.statusIcon.isHidden = true
        
    }
    //config channel msg
    func configChannel(model:channelMsgModel.message)  {
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)")
        self.typeLbl.text = docURL?.pathExtension.uppercased()
        
        self.docuNameLbl.text = model.message
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.statusIcon.isHidden = true
        
    }
}
