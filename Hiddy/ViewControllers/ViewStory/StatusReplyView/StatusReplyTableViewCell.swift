//
//  StatusReplyTableViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 08/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import Lottie
class StatusReplyTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var receiveUserNAmeLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var wholeStatusView: UIView!
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var userStatusImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusStack: UIStackView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var audiotypeLabel: UILabel!
    @IBOutlet weak var audioTitleLabel: UILabel!
    @IBOutlet weak var audioProgressView: UISlider!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var replyImageView: UIImageView!
    @IBOutlet weak var replyMessageLabel: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusTypeLabel: UILabel!
    @IBOutlet weak var statusTypeImageView: UIImageView!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusView: UIStackView!
    @IBOutlet weak var wholeBackgroundView: UIView!
    
    var sender_id:String = ""
    var own_id:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.replyMessageLabel.config(color:TEXT_PRIMARY_COLOR, size: 16, align: .natural, text: EMPTY_STRING)
        self.statusTitleLabel.config(color:TEXT_PRIMARY_COLOR, size: 16, align: .natural, text: EMPTY_STRING)
        // self.statusTypeLabel.config(color:TEXT_PRIMARY_COLOR, size: 16, align: .natural, text: EMPTY_STRING)
        
        self.timeLabel.config(color:.lightGray, size: 14, align: .natural, text: EMPTY_STRING)
        self.wholeBackgroundView.backgroundColor = SENDER_BG_COLOR
        self.wholeStatusView.layer.cornerRadius = 5
        self.profileImageView.layer.cornerRadius = 5
        self.profileImageView.clipsToBounds = true
        self.wholeStatusView.clipsToBounds = true
        self.wholeBackgroundView.layer.cornerRadius = 15
        self.wholeBackgroundView.clipsToBounds = true
        self.changeRTLView()
        // Initialization code
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.replyMessageLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.statusTitleLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.statusTypeLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.profileImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.statusTypeImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.userStatusImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.replyMessageLabel.transform = .identity
            self.statusTitleLabel.transform = .identity
            self.statusTypeLabel.transform = .identity
            self.timeLabel.transform = .identity
            self.profileImageView.transform = .identity
            self.statusTypeImageView.transform = .identity
            self.userStatusImageView.transform = .identity
        }
    }
    private lazy var gradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = PRIMARY_COLOR
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = self.bounds
        return gradientLayer
    }()
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                self.wholeBackgroundView.layer.insertSublayer(self.gradient, at: 0)
            }
            else
            {
                self.gradient.removeFromSuperlayer()
            }
        }
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }

    func config(msgDict:NSDictionary)  {
//        DispatchQueue.main.async {
            // print(msgDict)
            let msg = msgDict.value(forKeyPath:"message_data.message") as? String
            //        let msgSize =  HPLActivityHUD.getMsgSize(msg, withFont: APP_FONT_REGULAR, andSize: 16)
            let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
            self.timeLabel.text = Utility.shared.chatTime(stamp: time)
            let status:String = msgDict.value(forKeyPath: "message_data.read_status") as! String
            let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            let jsonString:String = msgDict.value(forKeyPath: "message_data.status_data") as? String ?? ""
            
            if status == "1"{
                self.userStatusImageView.image = #imageLiteral(resourceName: "status_sent")
            }else if status == "2"{
                self.userStatusImageView.image = #imageLiteral(resourceName: "status_notified")
            }else if status == "3"{
                self.userStatusImageView.image = #imageLiteral(resourceName: "read_tick")
            }
            if self.sender_id == self.own_id {
                self.statusTypeImageView.tintColor = TEXT_SECONDARY_COLOR
                isSelected = false
                if UserModel.shared.getAppLanguage() == "عربى" {
                    self.wholeStackView.alignment = .leading
                }
                else {
                    self.wholeStackView.alignment = .trailing
                }
                self.replyMessageLabel.textColor = .black
                self.statusTitleLabel.textColor = .black
                self.statusTypeLabel.textColor = .black
                self.timeLabel.textColor = TEXT_SECONDARY_COLOR
                self.wholeBackgroundView.backgroundColor = SENDER_BG_COLOR
                //                self.wholeStatusView.backgroundColor = UIColor.init(red: 21.0/255.0, green: 115.0/255.0, blue: 137.0/255.0, alpha: 0.3)
                self.statusView.isHidden = false
                if type == "isDelete" {
                    self.statusView.isHidden = true
                }
                else {
                    self.timeLabel.isHidden = false
                    self.statusView.isHidden = false
                    self.userStatusImageView.isHidden = false
                }
            }
            else {
                self.statusTypeImageView.tintColor = UIColor.white
                isSelected = true
                if UserModel.shared.getAppLanguage() == "عربى" {
                    self.wholeStackView.alignment = .trailing
                }
                else {
                    self.wholeStackView.alignment = .leading
                }
                //                self.wholeStatusView.backgroundColor = UIColor.init(red: 221.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 0.3)
                self.replyMessageLabel.textColor = .white
                self.timeLabel.textColor = .white
                self.statusTypeLabel.textColor = .white
                self.statusTitleLabel.textColor = .white
                
                self.wholeBackgroundView.backgroundColor = RECIVER_BG_COLOR
                if type == "isDelete" {
                    self.statusView.isHidden = true
                }
                else {
                    self.timeLabel.isHidden = false
                    self.statusView.isHidden = false
                    self.userStatusImageView.isHidden = true
                }
                
            }
            self.replyMessageLabel.text = msg
            let cryptLib = CryptLib()
            let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: jsonString, key: ENCRYPT_KEY)
            
            if let value = self.jsonToString(value: decryptedMsg ?? "") {
                // print(value)
                var imageName:String = value["attachment"] as? String ?? ""

                self.statusTypeLabel.text = (value["story_type"] as? String ?? "image").capitalized
                
                if self.statusTypeLabel.text == "Image" {
                    self.statusTypeImageView.image = #imageLiteral(resourceName: "camera")
                    imageName = value["attachment"] as? String ?? ""
                }
                else {
                    self.statusTypeImageView.image = #imageLiteral(resourceName: "statusvideo")
                    imageName = value["thumbnail"] as? String ?? ""
                }
                DispatchQueue.main.async {
                    self.profileImageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }
//                self.userStatusImageView.isHidden = true
                //                self.statusTitleLabel.text = value["contactName"] as? String ?? ""
            }
//        }
//        self.statusTypeLabel.sizeToFit()
    }
    func jsonToString(value: String) -> Dictionary<String, Any>? {
        let string = value
        let data = string.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
            {
                // print(jsonArray) // use the json here
                return jsonArray
            } else {
                // print("bad json")
            }
        } catch let error as NSError {
            // print(error)
        }
        return nil
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
