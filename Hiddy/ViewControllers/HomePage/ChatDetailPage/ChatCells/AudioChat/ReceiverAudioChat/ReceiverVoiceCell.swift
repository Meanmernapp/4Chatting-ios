//
//  ReceiverVoiceCell.swift
//  Hiddy
//
//  Created by HTS-MacAir002 on 20/02/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import Lottie
class ReceiverVoiceCell: UITableViewCell {
    
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var audioTimeLbl: UILabel!
    @IBOutlet var playerImg: UIImageView!
    @IBOutlet var PlayerBtn:UIButton!
    @IBOutlet var loader: AnimationView!
    @IBOutlet var downloadIcon:UIImageView!
    @IBOutlet var audioProgress:UISlider!
    
    @IBOutlet var nameLbl: UILabel!
    
    var audioPlayer: AVAudioPlayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.downloadIcon.image = #imageLiteral(resourceName: "download_icon")
        self.audioTimeLbl.config(color:.white, size: 14, align: .left, text: "00:00")
        self.audioTimeLbl.clipsToBounds = true
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: .white, size: 14, align: .right, text: EMPTY_STRING)
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text:EMPTY_STRING)
        
        loader = AnimationView.init(name: "Download")
        // loader.frame = CGRect.init(x: (self.containerView.frame.size.width/2)-20, y: (self.containerView.frame.size.height/2)-20, width: 40, height: 40)
        loader.frame = CGRect.init(x: self.containerView.frame.size.width - 28, y: (self.containerView.frame.size.height/2)-23, width: 25, height: 25)
        loader.loopMode = .loop
        loader.animationSpeed = 2
        loader.backgroundColor = UIColor.clear
        self.containerView.addSubview(loader)

        // let thumbTintColor = UIColor(patternImage: #imageLiteral(resourceName: "receive_thumb"))
        audioProgress.setThumbImage(#imageLiteral(resourceName: "round_white"), for: .normal)
        
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.audioTimeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.audioTimeLbl.textAlignment = .right
            self.playerImg.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.progressBar.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.statusIcon.transform = .identity
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.audioTimeLbl.transform = .identity
            self.audioTimeLbl.textAlignment = .left
            self.playerImg.transform = .identity
            self.progressBar.transform = .identity
            
        }
        
        
        self.containerView.specificCornerRadius(radius: 15)
        //timeLbl.config(color: TEXT_TERTIARY_COLOR, size: 14, align: .left, text: EMPTY_STRING)
        timeLbl.config(color: .white, size: 14, align: .left, text: EMPTY_STRING)
        self.containerView.applyGradient()
        self.containerView.bringSubviewToFront(self.statusIcon)
        self.containerView.bringSubviewToFront(self.timeLbl)
        self.containerView.bringSubviewToFront(self.containerView)
        self.containerView.bringSubviewToFront(self.progressBar)
        self.containerView.bringSubviewToFront(self.audioTimeLbl)
        self.containerView.bringSubviewToFront(self.playerImg)
        self.containerView.bringSubviewToFront(self.PlayerBtn)
        self.containerView.bringSubviewToFront(self.loader)
        self.containerView.bringSubviewToFront(self.downloadIcon)
        self.containerView.bringSubviewToFront(self.audioProgress)
        //        self.contentView.bringSubviewToFront(self.downloadButton)
        //self.containerView.backgroundColor = PRIMARY_COLOR
        // Initialization code
    }
    
    
    
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        self.nameLbl.isHidden = true
        
        self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 165 , height: self.audioProgress.frame.height)
        // self.contactNameLbl.text = contactName
        //self.phoneNoLbl.text = contactNo
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp:time)
        self.audioTimeLbl.text = "00:00"
        self.audioTimeLbl.clipsToBounds = true
        let status:String = msgDict.value(forKeyPath: "message_data.read_status") as! String
        // print("status --------------------------- %@",status)
        let blocked:String = msgDict.value(forKeyPath: "message_data.blocked") as! String
        if blocked == "0"{
            if status == "1"{
                self.statusIcon.image = #imageLiteral(resourceName: "status_sent")
            }else if status == "2"{
                self.statusIcon.image = #imageLiteral(resourceName: "status_notified")
            }else if status == "3"{
                self.statusIcon.image = #imageLiteral(resourceName: "read_tick")
            }
        }else{
            self.statusIcon.image = #imageLiteral(resourceName: "status_sent")
        }
        
        let isDownload:String = msgDict.value(forKeyPath: "message_data.isDownload") as! String
        // print("downloadstatus --------------------------- %@",isDownload)
        if isDownload == "0" {
            self.downloadIcon.isHidden = false
            self.loader.isHidden = false
            self.audioTimeLbl.config(color: .white, size: 14, align: .left, text: "00:00")
        }else if isDownload == "1"{
            self.downloadIcon.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
            self.audioTimeLbl.config(color: .white, size: 14, align: .left, text: "00:00")
            self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 190 , height: self.audioProgress.frame.height)
            
            let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
            let updatedDict = LocalStorage().getMsg(msg_id: message_id)
            var videoName:String = updatedDict.value(forKeyPath: "message_data.local_path") as? String ?? ""
            
            if videoName == "0"{
                let serverLink = msgDict.value(forKeyPath: "message_data.attachment") as! String
                videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
            }
            // print("-------------Audio_URL : @",videoName)
            self.downloadAudio(videoName: videoName)
            
        }else if isDownload == "2"{
      
            self.audioTimeLbl.config(color: .white, size: 14, align: .left, text: "00:00")
            self.downloadIcon.isHidden = true
            self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 190 , height: self.audioProgress.frame.height)
            self.loader.isHidden = true
            self.loader.stop()
        }
        
    }
    
    func downloadAudio(videoName: String) {
        
        if let audioUrl = URL(string: videoName) {
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                // print("The file already exists at path")
                do {
                    let data = try Data(contentsOf: destinationUrl)
                    audioPlayer = try AVAudioPlayer.init(data: data)
                    let currentTime = CGFloat(self.audioPlayer.duration)
                    DispatchQueue.main.async {
                        self.audioTimeLbl.text = currentTime.SecondsFromTimer()
                    }
                    //                self.audioTimeLbl.text = "\(CGFloat(self.audioPlayer.duration))"
                } catch {
                    assertionFailure("Failed crating audio player: \(error).")
                }
                // if the file doesn't exist
            } else {
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        // print("File moved to documents folder")
                        do {
                            self.audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                            let currentTime = Int(self.audioPlayer.duration)
                            let minutes = currentTime/60
                            let seconds = currentTime - minutes / 60
                            DispatchQueue.main.async {
                                self.audioTimeLbl.text = NSString(format: "%02d:%02d", minutes,seconds) as String
                            }
                            
                            //                self.audioTimeLbl.text = "\(CGFloat(self.audioPlayer.duration))"
                        } catch {
                            assertionFailure("Failed crating audio player: \(error).")
                        }
                        
                    } catch let error as NSError {
                        // print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    //config group msg cell
    func configGroup(model:groupMsgModel.message)  {
        self.nameLbl.isHidden = false
        self.nameLbl.text = Utility.shared.getUsername(user_id: model.member_id)
        self.nameLbl.frame = CGRect.init(x: 10, y: 5, width: 250, height: 25)
        
        self.containerView.frame = CGRect.init(x: 10, y: 30, width: 250, height: 60)
        
        self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        self.audioTimeLbl.text = "00:00"
        self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 165 , height: self.audioProgress.frame.height)
        self.downloadIcon.image = #imageLiteral(resourceName: "download_icon")
        if model.isDownload == "0" {
            self.downloadIcon.isHidden = false
            self.loader.isHidden = false
        }else if model.isDownload == "1"{
            self.audioTimeLbl.config(color: .white, size: 14, align: .left, text: "00:00")
            self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 190 , height: self.audioProgress.frame.height)
            
            self.downloadIcon.isHidden = true
            let message_id:String = model.message_id
            let updatedDict = groupStorage().getGroupMsg(msg_id: message_id)
            var videoName:String = updatedDict!.local_path
            
            if videoName == "0"{
                let serverLink = model.attachment
                videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
            }
            // print("-------------Audio_URL : @",videoName)
            self.downloadAudio(videoName: videoName)
            
            self.loader.stop()
            self.loader.isHidden = true
        }
        else if model.isDownload == "2"{
            self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 190 , height: self.audioProgress.frame.height)
            
            self.audioTimeLbl.config(color: .white, size: 14, align: .left, text: "00:00")
            self.downloadIcon.isHidden = true
            self.loader.isHidden = false
            self.loader.play()
        }
    }
    
    //Config Channel Audio ------>
    
    func configChannel(model:channelMsgModel.message,chatType:String)  {
        self.nameLbl.isHidden = true
        if chatType == "admin" {
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.msg_date)
        }else{
            self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        }
        self.audioTimeLbl.text = "00:00"
        //self.audioProgress.value = 10
        self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 165 , height: self.audioProgress.frame.height)
        
        self.statusIcon.isHidden = true
        if model.isDownload == "0"{
            self.downloadIcon.isHidden = false
            loader.isHidden = false
            loader.pause()
            
        }else if model.isDownload == "1"{ //cancelled
            self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 190 , height: self.audioProgress.frame.height)
            
            self.downloadIcon.isHidden = true
            self.loader.stop()
            self.loader.isHidden = true
            
            self.audioTimeLbl.config(color: .white, size: 14, align: .left, text: "00:00")
            let message_id:String = model.message_id
            let updatedDict = ChannelStorage().getChannelMsg(msg_id: message_id)
            var videoName:String = updatedDict!.local_path
            
            if videoName == "0"{
                let serverLink = model.attachment
                videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
            }
            // print("-------------Audio_URL : @",videoName)
            self.downloadAudio(videoName: videoName)
            
            
        }else if model.isDownload == "4"{
            self.audioProgress.frame = CGRect(x: self.audioProgress.frame.origin.x, y: self.audioProgress.frame.origin.y, width: 190 , height: self.audioProgress.frame.height)
            
            self.downloadIcon.isHidden = true
            loader.isHidden = false
            loader.pause()
            
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

