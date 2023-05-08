//
//  ReceiverImageCell.swift
//  Hiddy
//
//  Created by APPLE on 06/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import Lottie
import SwiftyGif

class ReceiverImageCell: UITableViewCell,SwiftyGifDelegate {
    
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var ImageFileView: UIImageView!
    @IBOutlet var downloadIcon: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var loader: AnimationView!
    @IBOutlet var downloadView: UIView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet var gifImgView: UIImageView!
    
    var cellType = String()
    
    var blurView = UIVisualEffectView()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .left, text: EMPTY_STRING)
        self.ImageFileView.layer.minificationFilter = CALayerContentsFilter.linear
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 16, align: .left, text: EMPTY_STRING)
        loader = AnimationView.init(name: "Download")
        loader.frame = CGRect.init(x: (self.containerView.frame.size.width/2)-20, y: (self.containerView.frame.size.height/2)-20, width: 40, height: 40)
        loader.loopMode = .loop
        //        loader.loopAnimation = true
        loader.animationSpeed = 2
        self.gifImgView.delegate = self
        
        self.containerView.addSubview(loader)
        self.downloadView.cornerViewRadius()
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .left
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.ImageFileView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.gifImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .right
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.ImageFileView.transform = .identity
            self.gifImgView.transform = .identity
        }
    }
    
    override func prepareForReuse() {
        self.gifImgView.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary)  {
        self.nameLbl.isHidden = true
        let imageName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
        // print("Image URL \(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp: time)
        
        let isDownload:String = msgDict.value(forKeyPath: "message_data.isDownload") as! String
        print("iiiiisdownloaddd \(isDownload)")
        if isDownload == "0" {
            self.ImageFileView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.ImageFileView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = false
            self.downloadView.isHidden = false
            self.loader.isHidden = true
        }else if isDownload == "1"{
            self.ImageFileView.layer.minificationFilterBias = 0.0
            self.ImageFileView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
        }else if isDownload == "2"{
            self.ImageFileView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.ImageFileView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
            self.loader.isHidden = false
            self.loader.play()
        }
        self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)",attach:imageName)
    }
    
    
    func loadImage(url: String,attach:String) {
        //        self.gifImgView.clear()
        
        if self.cellType == "image"{
            DispatchQueue.main.async {
                self.gifImgView.isHidden = true
                self.ImageFileView.isHidden = false
                self.ImageFileView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            }
            
        }else{
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
            self.loader.isHidden = true
            self.gifImgView.isHidden = false
            self.ImageFileView.isHidden = true
            self.containerView.backgroundColor = .clear
            
            if let imgUrl = URL(string: attach) {
                /*
                 self.gifImgView.sd_setImage(with: imgUrl, placeholderImage: nil)
                self.gifImgView.contentMode = .scaleAspectFit
                */
                self.gifImgView.setGifFromURL(imgUrl)
                self.gifImgView.contentMode = .scaleAspectFit
                
            }
            
        }
    }
    
    func configGroupMsg(model:groupMsgModel.message)  {
        DispatchQueue.main.async {
            self.timeLbl.config(color: .white, size: 14, align: .right, text: EMPTY_STRING)
            self.nameLbl.isHidden = false
            self.nameLbl.text = Utility.shared.getUsername(user_id: model.member_id)
            self.nameLbl.frame = CGRect.init(x: 10, y: 0, width: self.containerView.frame.width, height: 20)
            self.containerView.frame = CGRect.init(x: 10, y: 22, width: 210, height: 140)
            self.timeLbl.frame = CGRect.init(x: 10, y: 110, width: 210, height: 20)
            self.imageBtn.frame = CGRect.init(x: 10, y: 22, width: 210, height: 140)
            self.addSubview(self.imageBtn)
            self.addSubview(self.nameLbl)
            self.addSubview(self.containerView)
            self.addSubview(self.timeLbl)
            self.bringSubviewToFront(self.imageBtn)
        }
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)",attach:model.attachment)
        if model.isDownload == "0" {
            self.ImageFileView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.ImageFileView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = false
            self.downloadView.isHidden = false
            self.loader.isHidden = true
        }else if model.isDownload == "1"{
            self.ImageFileView.layer.minificationFilterBias = 0.0
            self.ImageFileView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
        }else if model.isDownload == "2"{
            self.ImageFileView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.ImageFileView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
            self.loader.isHidden = false
            self.loader.play()
        }
        if self.cellType == "gif"{
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
        }
    }
    
    //    channel msg
    func configChannelMsg(model:channelMsgModel.message,chatType:String)  {
        self.nameLbl.isHidden = true
        var base_url = String()
        base_url =  IMAGE_BASE_URL
        self.loadImage(url: "\(base_url)\(IMAGE_SUB_URL)\(model.attachment)",attach:model.attachment)
        if chatType == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        }
        if model.isDownload == "0" {
            self.ImageFileView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.ImageFileView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = false
            self.downloadView.isHidden = false
            self.loader.isHidden = true
        }else if model.isDownload == "1"{
            self.ImageFileView.layer.minificationFilterBias = 0.0
            self.ImageFileView.sd_setImage(with: URL(string:"\(base_url)\(IMAGE_SUB_URL)\(model.attachment)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
        }else if model.isDownload == "2"{
            self.ImageFileView.layer.minificationFilter = CALayerContentsFilter.trilinear
            self.ImageFileView.layer.minificationFilterBias = 3.0
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
            self.loader.isHidden = false
            self.loader.play()
        }
        if self.cellType == "gif"{
            self.downloadIcon.isHidden = true
            self.downloadView.isHidden = true
        }
    }
    func gifURLDidFinish(sender: UIImageView) {
        DispatchQueue.main.async {
            self.gifImgView.isHidden = false
        }
    }
}
