//
//  SenderLocCell.swift
//  Hiddy
//
//  Created by APPLE on 23/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class SenderLocCell: UITableViewCell {
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var locationImgView: UIImageView!
    @IBOutlet weak var locationBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .right, text: EMPTY_STRING)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.locationImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.locationImgView.transform = .identity
            self.statusIcon.transform = .identity
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        let lat:String = msgDict.value(forKeyPath: "message_data.lat") as! String
        let lon:String = msgDict.value(forKeyPath: "message_data.lon") as! String
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat),\(lon)&zoom=14&size=400x200&sensor=false&key=\(GOOGLE_API_KEY)&maptype=roadmap&markers=color:red%7Clabel:S%7C\(lat),\(lon)"
        print(urlString)
        self.loadImage(url: urlString)
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
    func loadImage(url: String) {
        DispatchQueue.main.async {
            self.locationImgView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }
    
    func configGroup(model:groupMsgModel.message)  {
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(model.lat),\(model.lon)&zoom=14&size=400x200&key=\(GOOGLE_API_KEY)&sensor=false&maptype=roadmap&markers=color:red%7Clabel:S%7C\(model.lat),\(model.lon)"
        self.loadImage(url: urlString)
        self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        self.statusIcon.isHidden = true
    }
    
    func configChannel(model:channelMsgModel.message)  {
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(model.lat),\(model.lon)&zoom=14&size=400x200&sensor=false&key=\(GOOGLE_API_KEY)&maptype=roadmap&markers=color:red%7Clabel:S%7C\(model.lat),\(model.lon)"
        self.loadImage(url: urlString)
        self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        self.statusIcon.isHidden = true
    }
}
