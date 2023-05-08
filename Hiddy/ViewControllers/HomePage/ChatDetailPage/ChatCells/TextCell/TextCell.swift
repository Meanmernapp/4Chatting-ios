//
//  TextCell.swift
//  Hiddy
//
//  Created by HTS-Product on 05/10/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import Foundation

class TextCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var messageTextViewLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    //    @IBOutlet weak var msgTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var MsgTextView: UITextView!
    @IBOutlet var translateBtn: UIButton!
    
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var playButtonBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    var sender_id:String = ""
    var own_id:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        self.MsgTextView.config(color:.black, size: 16, align: .natural, text: EMPTY_STRING)
        self.nameLabel.config(color:TEXT_PRIMARY_COLOR, size: 16, align: .natural, text: EMPTY_STRING)
        self.timeLbl.config(color:.lightGray, size: 14, align: .natural, text: EMPTY_STRING)
        self.bgView.backgroundColor = SENDER_BG_COLOR
        self.bgView.layer.cornerRadius = 15
        self.playButtonBtn.clipsToBounds = true
        self.bgView.clipsToBounds = true
        self.translateBtn.config(color: .white, size: 15, align: .left, title: "translate")
        
        
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        SpeechService.shared.startSpeech(MsgTextView.text)
    }
    
    func changeRTL() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.translateBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
            
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.MsgTextView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            if self.sender_id == self.own_id {
                self.wholeStackView.alignment = .leading
            }
            else {
                self.wholeStackView.alignment = .trailing
            }
        }
        else {
            self.translateBtn.transform = .identity
            
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.MsgTextView.transform = .identity
            self.statusIcon.transform = .identity
            self.playButtonBtn.transform = .identity
            if self.sender_id == self.own_id {
                self.wholeStackView.alignment = .trailing
            }
            else {
                self.wholeStackView.alignment = .leading
            }
        }
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        //        DispatchQueue.main.async {
        let msg = msgDict.value(forKeyPath:"message_data.message") as? String
        //        let msgSize =  HPLActivityHUD.getMsgSize(msg, withFont: APP_FONT_REGULAR, andSize: 16)
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp: time)
        let status:String = msgDict.value(forKeyPath: "message_data.read_status") as! String
        let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
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
        
        
        if self.sender_id == self.own_id {
            self.translateBtn.isHidden = true
            self.MsgTextView.textColor = .black
            self.timeLbl.textColor = UIColor(named: "Chat time")
            self.bgView.backgroundColor = SENDER_BG_COLOR
            self.statusStackView.isHidden = false
            self.timeLbl.isHidden = false
            self.statusStackView.isHidden = false
            self.statusIcon.isHidden = false
        }
        else {
            self.translateBtn.isHidden = false
            
            self.MsgTextView.textColor = .white
            self.timeLbl.textColor = .white
            self.bgView.backgroundColor = RECIVER_BG_COLOR
            if type == "isDelete" {
                self.statusStackView.isHidden = true
            }
            else {
                self.timeLbl.isHidden = false
                self.statusStackView.isHidden = false
                self.statusIcon.isHidden = true
            }
            
        }
        if type == "isDelete" {
            self.MsgTextView.text = Utility.shared.getLanguage()?.value(forKey: msg ?? "") as? String ?? ""
            self.statusStackView.isHidden = false
            self.statusIcon.isHidden = true
            self.messageTextViewLeadingConst.constant = 18
        }
        else {
            if self.sender_id == self.own_id {
                self.statusIcon.isHidden = false
            }
            let trans_status:String = msgDict.value(forKeyPath: "message_data.translated_status") as! String
            let trans_msg:String = msgDict.value(forKeyPath: "message_data.translated_msg") as! String
            
            if trans_status == "0"{
                self.MsgTextView.text = msg
            }else{
                self.MsgTextView.text = trans_msg
            }

            self.messageTextViewLeadingConst.constant = 0
        }
        self.changeRTL()
    }
    func groupConfig(msgDict:groupMsgModel.message)  {
        //        DispatchQueue.main.async {
//        if UserModel.shared.getListen() {
//            self.playButtonBtn.isHidden = false
//        }
//        else {
//            self.playButtonBtn.isHidden = true
//        }
        let type = msgDict.message_type
        if self.sender_id == self.own_id {
            self.MsgTextView.textColor = .black
            self.timeLbl.textColor = UIColor(named: "Chat time")
            self.bgView.backgroundColor = SENDER_BG_COLOR
            self.statusStackView.isHidden = false
            self.nameLabel.isHidden = true
            self.translateBtn.isHidden = true
            
        }else{
            self.translateBtn.isHidden = false
            self.MsgTextView.textColor = .white
            self.timeLbl.textColor = .white
            self.bgView.backgroundColor = RECIVER_BG_COLOR
            self.timeLbl.isHidden = false
            self.statusStackView.isHidden = false
            self.statusIcon.isHidden = true
            self.nameLabel.isHidden = false
            self.nameLabel.text = Utility.shared.getUsername(user_id: msgDict.member_id)
        }
        let msg = msgDict.message
        let time:String = msgDict.timestamp
        self.timeLbl.text = Utility.shared.chatTime(stamp: time)
        self.statusIcon.isHidden = true
        if type == "isDelete" {
            self.MsgTextView.text = Utility.shared.getLanguage()?.value(forKey: msg) as? String ?? ""
            self.statusIcon.isHidden = true
            self.messageTextViewLeadingConst.constant = 18
        }else{
            if msgDict.translated_status == "0" ||  self.sender_id == self.own_id{
                self.MsgTextView.text = msg
            }else{
                self.MsgTextView.text = msgDict.translated_msg
            }
            
            if self.sender_id == self.own_id {
                self.statusIcon.isHidden = false
//                self.messageTextViewLeadingConst.constant = 0
            }
            self.messageTextViewLeadingConst.constant = -2

        }
        self.changeRTL()
    }
    
    func channelConfig(msgDict:channelMsgModel.message,chattype:String)  {
        let type = msgDict.message_type
        if self.sender_id == self.own_id{
            self.MsgTextView.textColor = .black
            self.timeLbl.textColor = UIColor(named: "Chat time")
            self.bgView.backgroundColor = SENDER_BG_COLOR
            self.statusStackView.isHidden = false
            self.nameLabel.isHidden = true
            self.translateBtn.isHidden = true
        }else{
            self.translateBtn.isHidden = false
            self.wholeStackView.alignment = .leading
            self.MsgTextView.textColor = .white
            self.timeLbl.textColor = .white
            self.bgView.backgroundColor = RECIVER_BG_COLOR
            self.timeLbl.isHidden = false
            self.statusStackView.isHidden = false
            self.nameLabel.isHidden = true
            self.statusIcon.isHidden = true
        }
        let msg = msgDict.message
        print("msg type \(type)  time \(msgDict.msg_date) normal time \(msgDict.timestamp)")
        if chattype == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: msgDict.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: msgDict.timestamp)
        }
        self.statusIcon.isHidden = true
        self.MsgTextView.text = msg
        if type == "isDelete"{
            self.MsgTextView.text = Utility.shared.getLanguage()?.value(forKey: msg) as? String ?? ""
            self.statusIcon.isHidden = true
            self.messageTextViewLeadingConst.constant = 18
        }else{
            self.MsgTextView.text = msg
            
            if msgDict.translated_status == "0"{
                self.MsgTextView.text = msg
            }else{
                self.MsgTextView.text = msgDict.translated_msg
            }
            
            if self.sender_id == self.own_id {
                self.statusIcon.isHidden = false
            }
            self.messageTextViewLeadingConst.constant = 0
        }
        self.changeRTL()
    }
    
    func cellHeight() ->CGFloat {
        return self.bgView.frame.size.height
    }
    
    func getSize(msg:String) -> CGSize {
        // new
        let labelSize: CGSize = msg.boundingRect(with: CGSize.init(width: 250, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.init(name: APP_FONT_REGULAR, size: 16)!], context: nil).size
        return labelSize
    }
    
}
