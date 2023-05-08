//
//  SenderVideoCell.swift
//  Hiddy
//
//  Created by APPLE on 06/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie

class SenderVideoCell: UITableViewCell {
    
    
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var thumnailView: UIImageView!
    @IBOutlet var loader: AnimationView!
    @IBOutlet var playIcon: UIImageView!
    
    @IBOutlet var playView: UIView!
    
    @IBOutlet weak var videoBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .left, text: EMPTY_STRING)
        loader = AnimationView.init(name: "Download")
        loader.frame = CGRect.init(x: (self.containerView.frame.size.width/2)-20, y: (self.containerView.frame.size.height/2)-20, width: 40, height: 40)
        loader.loopMode = .loop
        loader.animationSpeed = 1
        self.playView.cornerViewRadius()
        self.containerView.addSubview(loader)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.statusIcon.transform = .identity
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        if msgDict.count > 0 {
            let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
            self.timeLbl.text = Utility.shared.chatTime(stamp: time)
            
            let thumbname:String = msgDict.value(forKeyPath: "message_data.thumbnail") as! String
            self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(thumbname)")
            print( "thumbname \(thumbname)")
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
            
            self.playIcon.image = #imageLiteral(resourceName: "video_play")
            let uploadStatus:String = msgDict.value(forKeyPath: "message_data.isDownload") as! String
            print("uploadStatus \(uploadStatus)")
            if uploadStatus == "0"{
                self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
                self.thumnailView.layer.minificationFilterBias = 3.0
                loader.isHidden = false
                loader.play()
                self.playView.isHidden = false
                self.playIcon.image = #imageLiteral(resourceName: "upload")
                self.statusIcon.isHidden = true
            }
            else if uploadStatus == "2"{
                self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
                self.thumnailView.layer.minificationFilterBias = 3.0
                loader.isHidden = false
                loader.play()
                self.playView.isHidden = false
                self.playIcon.image = #imageLiteral(resourceName: "upload")
                self.statusIcon.isHidden = true
            }
            else if uploadStatus == "4"{ //cancelled
//                self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
//                self.thumnailView.layer.minificationFilterBias = 3.0
//                loader.isHidden = true
//                self.playView.isHidden = false
//                self.statusIcon.isHidden = true
                self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
                self.thumnailView.layer.minificationFilterBias = 3.0
                loader.isHidden = false
                loader.play()
                self.playView.isHidden = false
                self.playIcon.image = #imageLiteral(resourceName: "upload")
                self.statusIcon.isHidden = true
            }else{
                self.thumnailView.layer.minificationFilterBias = 0.0
                loader.stop()
                loader.isHidden = true
                self.playView.isHidden = false
                self.statusIcon.isHidden = false
            }
        }
        
    }
    func loadImage(url: String) {
        DispatchQueue.main.async {
            self.thumnailView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }
    
    //config group  msg
    func configGroup(model:groupMsgModel.message)  {
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.thumbnail)")
        print( "thumgroupbname \(model.thumbnail)")
        
        self.statusIcon.isHidden = true
        self.playIcon.image = #imageLiteral(resourceName: "play_icon")
        
        if model.isDownload == "0"{
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            loader.isHidden = false
            loader.play()
            self.playView.isHidden = false
            self.playIcon.image = #imageLiteral(resourceName: "upload")
            self.statusIcon.isHidden = true
        }
        else if model.isDownload == "2"{
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            loader.isHidden = false
            loader.play()
            self.playView.isHidden = false
            self.playIcon.image = #imageLiteral(resourceName: "upload")
            self.statusIcon.isHidden = true
        }
        else if model.isDownload == "4"{ //cancelled
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            loader.isHidden = true
            self.playView.isHidden = false
            self.statusIcon.isHidden = true
        }else{
            self.thumnailView.layer.minificationFilterBias = 0.0
            loader.stop()
            loader.isHidden = true
            self.playView.isHidden = false
        }
        
    }
    
    
    //config channel msg
    func configChannel(model:channelMsgModel.message)  {
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.thumbnail)")
        print( "thumgchannelbname \(model.thumbnail)")
        
        self.statusIcon.isHidden = true
        self.playIcon.image = #imageLiteral(resourceName: "play_icon")
        
        if model.isDownload == "0"{
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            loader.isHidden = false
            loader.play()
            self.playView.isHidden = false
            self.playIcon.image = #imageLiteral(resourceName: "upload")
            self.statusIcon.isHidden = true
        }
        else if model.isDownload == "2"{
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            loader.isHidden = false
            loader.play()
            self.playView.isHidden = false
            self.playIcon.image = #imageLiteral(resourceName: "upload")
            self.statusIcon.isHidden = true
        }
        else if model.isDownload == "4"{ //cancelled
            self.thumnailView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.thumnailView.layer.minificationFilterBias = 3.0
            loader.isHidden = false
            loader.pause()
            self.playView.isHidden = false
        }else{
            self.thumnailView.layer.minificationFilterBias = 0.0
            loader.stop()
            loader.isHidden = true
            self.playView.isHidden = false
        }
        
    }
}
