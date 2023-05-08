//
//  ReceiverDocuCell.swift
//  Hiddy
//
//  Created by APPLE on 23/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import Lottie
class ReceiverDocuCell: UITableViewCell {
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var docuNameLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var backView: UIView!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet var docuIcon: UIImageView!
    @IBOutlet weak var docBtn: UIButton!
    @IBOutlet weak var loader: AnimationView!
    @IBOutlet weak var downloadIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.docuNameLbl.config(color: .white, size: 17, align: .left, text: EMPTY_STRING)
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .right, text: EMPTY_STRING)
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.containerView.backgroundColor = SECONDARY_COLOR
        self.typeLbl.config(color: .black, size: 14, align: .center, text: EMPTY_STRING)
        self.docuIcon.image = self.docuIcon.image!.withRenderingMode(.alwaysTemplate)
        self.docuIcon.tintColor = .white
        self.containerView.backgroundColor = RECIVER_BG_COLOR
        
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.docuNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.docuNameLbl.textAlignment = .left
            self.typeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.typeLbl.textAlignment = .right
        }else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.docuNameLbl.transform = .identity
            self.docuNameLbl.textAlignment = .left
            self.typeLbl.transform = .identity
            self.typeLbl.textAlignment = .left
        }

        loader = AnimationView.init(name: "Download")
        // loader.frame = CGRect.init(x: (self.containerView.frame.size.width/2)-20, y: (self.containerView.frame.size.height/2)-20, width: 40, height: 40)
        loader.frame = CGRect.init(x: self.containerView.frame.size.width - 23, y: (self.containerView.frame.size.height/2)-23, width: 25, height: 25)
        loader.loopMode = .loop
        loader.animationSpeed = 2
        loader.backgroundColor = UIColor.clear
        self.contentView.addSubview(loader)

    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary){
        self.nameLbl.isHidden = true
        let path:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(path)")
        self.typeLbl.text = docURL?.pathExtension.uppercased()
        let docuName:String = msgDict.value(forKeyPath: "message_data.message") as! String
        self.docuNameLbl.text = docuName
        let isDownload:String = msgDict.value(forKeyPath: "message_data.isDownload") as! String
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp:time)
        if isDownload == "0" {
            self.downloadIcon.isHidden = false
            self.loader.isHidden = true
        }else if isDownload == "1"{
            self.downloadIcon.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
        }else if isDownload == "2"{
            self.loader.isHidden = false
            self.downloadIcon.isHidden = true
        }
    }
    func configGroup(model:groupMsgModel.message){
        DispatchQueue.main.async {
            self.nameLbl.isHidden = false
            self.nameLbl.text = Utility.shared.getUsername(user_id: model.member_id)
            self.nameLbl.frame = CGRect.init(x: 10, y: 0, width: self.containerView.frame.width, height: 20)
            self.containerView.frame = CGRect.init(x: 10, y: 22, width: 240, height: 65)
            self.timeLbl.frame = CGRect.init(x: 180, y: 64, width: 56, height: 20)
            self.docBtn.frame = CGRect.init(x: 10, y: 22, width: 240, height: 65)
            self.addSubview(self.nameLbl)
            self.addSubview(self.docBtn)
            self.addSubview(self.containerView)
            self.addSubview(self.timeLbl)
            self.bringSubviewToFront(self.docBtn)
        }
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)")
        self.typeLbl.text = docURL?.pathExtension.uppercased()
        self.docuNameLbl.text = model.message
        self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        let isDownload:String = model.isDownload
        if isDownload == "0" {
            self.downloadIcon.isHidden = false
            self.loader.isHidden = true
        }else if isDownload == "1"{
            self.downloadIcon.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
        }else if isDownload == "2"{
            self.loader.isHidden = false
            self.downloadIcon.isHidden = true
        }
    }
    
    func configChannel(model:channelMsgModel.message,chatType:String){
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)")
        self.typeLbl.text = docURL?.pathExtension.uppercased()
        
        self.nameLbl.isHidden = true
        self.docuNameLbl.text = model.message
        if chatType == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        }
        let isDownload:String = model.isDownload
        if isDownload == "0" {
            self.downloadIcon.isHidden = false
            self.loader.isHidden = true
        }else if isDownload == "1"{
            self.downloadIcon.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
        }else if isDownload == "2"{
            self.loader.isHidden = false
            self.downloadIcon.isHidden = true
        }
    }
}
