//
//  ReceiverVideoCell.swift
//  Hiddy
//
//  Created by APPLE on 06/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie

class ReceiverVideoCell: UITableViewCell {
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var thumnailView: UIImageView!
    @IBOutlet var downloadIcon: UIImageView!
    @IBOutlet var playImgView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var loader: AnimationView!
    @IBOutlet var playView: UIView!
    @IBOutlet weak var videoBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .right, text: EMPTY_STRING)
        loader = AnimationView.init(name: "Download")
        loader.frame = CGRect.init(x: (self.containerView.frame.size.width/2)-20, y: (self.containerView.frame.size.height/2)-20, width: 40, height: 40)
        loader.loopMode = .loop
        loader.animationSpeed = 2
        self.containerView.addSubview(loader)
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.playView.cornerViewRadius()
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.thumnailView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.playImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.thumnailView.transform = .identity
            self.playImgView.transform = .identity
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary)  {
        self.nameLbl.isHidden = true

        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp: time)
        let thumbname:String = msgDict.value(forKeyPath: "message_data.thumbnail") as! String
        self.thumnailView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(thumbname)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        
        let isDownload:String = msgDict.value(forKeyPath: "message_data.isDownload") as! String
        if isDownload == "0" {
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = false
            self.playImgView.image = #imageLiteral(resourceName: "video_play")
            self.loader.isHidden = true
            self.playView.isHidden = false
        }else if isDownload == "1"{
            self.thumnailView.layer.minificationFilterBias = 0.0
            self.downloadIcon.isHidden = true
            self.playView.isHidden = false
            self.playImgView.image = #imageLiteral(resourceName: "video_play")
            self.loader.stop()
            self.loader.isHidden = true
        }else if isDownload == "2"{
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = true
            self.playView.isHidden = false
            self.playImgView.image = #imageLiteral(resourceName: "download_icon")
            self.loader.isHidden = false
            self.loader.play()
        }
    }
    //config group msg cell
    func configGroup(model:groupMsgModel.message)  {
        DispatchQueue.main.async {
            self.nameLbl.isHidden = false
            self.nameLbl.text = Utility.shared.getUsername(user_id: model.member_id)
            self.nameLbl.frame = CGRect.init(x: 10, y: 0, width: self.containerView.frame.width, height: 20)
            self.containerView.frame = CGRect.init(x: 10, y: 22, width: 210, height: 140)
//            self.timeLbl.frame = CGRect.init(x: 20, y: 144, width: 210, height: 20)

            self.videoBtn.frame = CGRect.init(x: 10, y: 22, width: 210, height: 140)
            self.addSubview(self.videoBtn)
            self.addSubview(self.nameLbl)
            self.addSubview(self.containerView)
            self.bringSubviewToFront(self.videoBtn)
//            self.addSubview(self.timeLbl)
        }
        self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        self.thumnailView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.thumbnail)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        if model.isDownload == "0" {
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = false
            self.loader.isHidden = true
            self.playView.isHidden = false
        }else if model.isDownload == "1"{
            self.thumnailView.layer.minificationFilterBias = 0.0
            self.downloadIcon.isHidden = true
            self.playView.isHidden = false
            self.playImgView.image = #imageLiteral(resourceName: "video_play")
            self.loader.stop()
            self.loader.isHidden = true
        }else if model.isDownload == "2"{
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = true
            self.playView.isHidden = false
            self.loader.isHidden = false
            self.playImgView.image = #imageLiteral(resourceName: "download_icon")
            self.loader.play()
        }
    }
    
    //config channel cell
    func configChannel(model:channelMsgModel.message,chatType:String)  {
        
        self.nameLbl.isHidden = true
        if chatType == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        }
        self.thumnailView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.thumbnail)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        print( "thumgchannelbname \(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.thumbnail)")

        if model.isDownload == "0" {
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = false
            self.loader.isHidden = true
            self.playView.isHidden = false
        }else if model.isDownload == "1"{
            self.thumnailView.layer.minificationFilterBias = 0.0
            self.downloadIcon.isHidden = true
            self.playView.isHidden = false
            self.playImgView.image = #imageLiteral(resourceName: "video_play")
            self.loader.stop()
            self.loader.isHidden = true
        }else if model.isDownload == "2"{
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = true
            self.playView.isHidden = false
            self.loader.isHidden = false
            self.playImgView.image = #imageLiteral(resourceName: "download_icon")
            self.loader.play()
        }
        
    }
    
}
