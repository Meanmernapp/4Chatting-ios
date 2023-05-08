//
//  ReceiverAudioCell.swift
//  Hiddy
//
//  Created by APPLE on 29/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class ReceiverAudioCell: UITableViewCell {

    @IBOutlet var nameLbl: UILabel!
    
    @IBOutlet var audioNameLb: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var musicIcon: UIImageView!
    @IBOutlet var timeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.audioNameLb.config(color: .white, size: 17, align: .left, text:"audio_not_support")
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text:EMPTY_STRING)

        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .right, text: EMPTY_STRING)
        self.containerView.backgroundColor = SECONDARY_COLOR
        self.musicIcon.image = self.musicIcon.image!.withRenderingMode(.alwaysTemplate)
        self.musicIcon.tintColor = .white
        self.containerView.backgroundColor = RECIVER_BG_COLOR
        
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .left
            self.audioNameLb.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.audioNameLb.textAlignment = .left
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .right
            self.audioNameLb.transform = .identity
            self.audioNameLb.textAlignment = .right
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func config(msgDict:NSDictionary){
        self.nameLbl.isHidden  = true
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp:time)
    }
    func configGroup(model:groupMsgModel.message){
//        DispatchQueue.main.async {
            self.nameLbl.isHidden = false
            self.nameLbl.text = Utility.shared.getUsername(user_id: model.member_id)
            self.nameLbl.frame = CGRect.init(x: 10, y: 0, width: FULL_WIDTH-40, height: 20)
            self.containerView.frame = CGRect.init(x: 10, y: 22, width: 240, height: 60)
            self.timeLbl.frame = CGRect.init(x: 184, y: 58, width: 56, height: 20)
            self.addSubview(self.nameLbl)
            self.addSubview(self.containerView)
            self.addSubview(self.timeLbl)
//        }
        self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
    }
    
    func configChannel(model:channelMsgModel.message,chatType:String){
        self.nameLbl.isHidden = true
        if chatType == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        }
    }
}
