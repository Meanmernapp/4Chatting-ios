//
//  ReceiverLocCell.swift
//  Hiddy
//
//  Created by APPLE on 23/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class ReceiverLocCell: UITableViewCell {
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var locationImgView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet weak var locationBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .left, text: EMPTY_STRING)
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.locationImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.locationImgView.transform = .identity
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary)  {
        self.nameLbl.isHidden = true
        let lat:String = msgDict.value(forKeyPath: "message_data.lat") as! String
        let lon:String = msgDict.value(forKeyPath: "message_data.lon") as! String
        
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat),\(lon)&zoom=14&size=400x200&sensor=false&maptype=roadmap&key=\(GOOGLE_API_KEY)&markers=color:red%7Clabel:S%7C\(lat),\(lon)"

        self.locationImgView.sd_setImage(with: URL(string:urlString), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp: time)
    }
    
    func configGroup(model:groupMsgModel.message)  {
        DispatchQueue.main.async {
            self.nameLbl.isHidden = false
            self.nameLbl.text = Utility.shared.getUsername(user_id: model.member_id)
            self.nameLbl.frame = CGRect.init(x: 20, y: 0, width: self.containerView.frame.width, height: 20)
            self.containerView.frame = CGRect.init(x: 20, y: 22, width: 210, height: 140)
            self.timeLbl.frame = CGRect.init(x: 151, y: 133, width: 56, height: 20)
            self.locationBtn.frame = CGRect.init(x: 20, y: 22, width: 210, height: 140)
            self.addSubview(self.locationBtn)
            self.addSubview(self.nameLbl)
            self.addSubview(self.containerView)
            self.addSubview(self.timeLbl)
            self.bringSubviewToFront(self.locationBtn)
        }
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(model.lat),\(model.lon)&zoom=14&size=400x200&sensor=false&maptype=roadmap&key=\(GOOGLE_API_KEY)&markers=color:red%7Clabel:S%7C\(model.lat),\(model.lon)"
        self.locationImgView.sd_setImage(with: URL(string:urlString), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        }
    
    func configChannel(model:channelMsgModel.message,chatType:String)  {
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(model.lat),\(model.lon)&zoom=14&size=400x200&sensor=false&maptype=roadmap&key=\(GOOGLE_API_KEY)&markers=color:red%7Clabel:S%7C\(model.lat),\(model.lon)"
        self.locationImgView.sd_setImage(with: URL(string:urlString), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        if chatType == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        }
        
    }
    
}
