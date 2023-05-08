//
//  SenderImageCell.swift
//  Hiddy
//
//  Created by APPLE on 06/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import SwiftyGif

class SenderImageCell: UITableViewCell,SwiftyGifDelegate {
    
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var ImageFileView: UIImageView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet var gifImgView: UIImageView!
    var cellType = String()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.specificCornerRadius(radius: 15)
        self.gifImgView.delegate = self
        
        timeLbl.config(color: .white, size: 14, align: .left, text: EMPTY_STRING)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.ImageFileView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.gifImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.ImageFileView.transform = .identity
            self.gifImgView.transform = .identity
            self.statusIcon.transform = .identity
        }
        
    }
    
    override func prepareForReuse() {
        self.gifImgView.image = nil
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        let imageName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
        let localPath:String = msgDict.value(forKeyPath: "message_data.local_path") as! String
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
        self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)",attach: imageName, localPath: localPath)
    }
    func loadImage(url: String,attach:String, localPath: String) {
        //        self.gifImgView.clear()
        
        if self.cellType == "image"{
            self.gifImgView.isHidden = true
            self.ImageFileView.isHidden = false
            self.imageBtn.isHidden = false
            
            if localPath != "0" {
                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: localPath)
                if galleryPic == nil{
                    self.ImageFileView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else{
                    self.ImageFileView.image = galleryPic!
                }
            }else{
                self.ImageFileView.sd_setImage(with: URL(string: url))
            }
            
        }else{
            self.gifImgView.isHidden = false
            self.ImageFileView.isHidden = true
            self.containerView.backgroundColor = .clear
            self.imageBtn.isHidden = true
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
        
        self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)",attach: model.attachment, localPath: model.local_path)
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.statusIcon.isHidden = true
    }
    
    func configChannelMsg(model:channelMsgModel.message)  {
        
        self.loadImage(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)",attach: model.attachment, localPath: model.local_path)
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.statusIcon.isHidden = true
    }
    func gifURLDidFinish(sender: UIImageView) {
        DispatchQueue.main.async {
            self.gifImgView.isHidden = false
        }
    }
}
