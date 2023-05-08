//
//  SenderAudioCell.swift
//  Hiddy
//
//  Created by HTS-MacAir002 on 20/02/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import Lottie

class SenderAudioCell: UITableViewCell {
    
    //Mark: Outlet Connections -------------------------------->
    
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var audioTimeLbl: UILabel!
    @IBOutlet var playerImg: UIImageView!
    @IBOutlet var PlayerBtn:UIButton!
    @IBOutlet var loader: AnimationView!
    @IBOutlet var audioProgress:UISlider!
    var audioPlayer: AVAudioPlayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.audioTimeLbl.config(color: TEXT_TERTIARY_COLOR, size: 14, align: .left, text: "00:00")
        self.containerView.specificCornerRadius(radius: 15)
        timeLbl.config(color: TEXT_TERTIARY_COLOR, size: 14, align: .left, text: EMPTY_STRING)
        self.containerView.backgroundColor = SENDER_BG_COLOR
        self.audioProgress.thumbTintColor =  SECONDARY_COLOR
        self.audioProgress.tintColor =  SECONDARY_COLOR
        self.audioProgress.minimumTrackTintColor = SECONDARY_COLOR
        
        loader = AnimationView.init(name: "Download")
        loader.frame = CGRect.init(x: self.containerView.frame.size.width - 23, y: (self.containerView.frame.size.height/2)-23, width: 25, height: 25)
        loader.loopMode = .loop
        loader.animationSpeed = 1
        audioProgress.setThumbImage(#imageLiteral(resourceName: "round_yellow"), for: .normal)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.statusIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.audioTimeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.audioTimeLbl.textAlignment = .right
            self.playerImg.transform = CGAffineTransform(scaleX: -1, y: 1)
            //            self.progressBar.semanticContentAttribute = .forceRightToLeft
        }
        else {
            self.statusIcon.transform = .identity
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.audioTimeLbl.transform = .identity
            self.audioTimeLbl.textAlignment = .left
            self.playerImg.transform = .identity
            //            self.progressBar.semanticContentAttribute = .unspecified
        }
        //self.containerView.addSubview(loader)
        
        // Initialization code
    }
    func getTimmerValue(url: URL) {
        
    }
    
    //config single chat
    func config(msgDict:NSDictionary,chatRead:Bool)  {
        // self.contactNameLbl.text = contactName
        //self.phoneNoLbl.text = contactNo
        let time:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
        self.timeLbl.text = Utility.shared.chatTime(stamp:time)
        //        self.audioTimeLbl.text = "00:00"
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
        let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        let updatedDict = LocalStorage().getMsg(msg_id: message_id)
        var videoName:String = updatedDict.value(forKeyPath: "message_data.local_path") as! String
        if videoName == "0"{
            let serverLink = msgDict.value(forKeyPath: "message_data.attachment") as! String
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
        }
        // print("-------------Audio_URL : @",videoName)
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
                            let currentTime = CGFloat(self.audioPlayer.duration)
                            DispatchQueue.main.async {
                                self.audioTimeLbl.text = currentTime.SecondsFromTimer()
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
    //config group  msg
    func configGroup(model:groupMsgModel.message)  {
        self.timeLbl.text = Utility.shared.chatTime(stamp: model.timestamp)
        self.audioTimeLbl.text = "00:00"
        
        self.statusIcon.isHidden = true
        if model.isDownload == "0"{
            
            loader.isHidden = false
            loader.play()
            
        }else if model.isDownload == "4"{ //cancelled
            
            
            loader.isHidden = false
            loader.pause()
            
        }else{
            
            loader.stop()
            loader.isHidden = true
            
        }
        let message_id:String = model.message_id
        let updatedDict = groupStorage().getGroupMsg(msg_id: message_id)
        var videoName:String = updatedDict!.local_path
        if videoName == "0"{
            let serverLink = model.attachment
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
        }
        // print("-------------Audio_URL : @",videoName)
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
                            let currentTime = CGFloat(self.audioPlayer.duration)
                            DispatchQueue.main.async {
                                self.audioTimeLbl.text = currentTime.SecondsFromTimer()
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
    
    //Config Channel Audio ------>
    
    func configChannel(model:channelMsgModel.message)  {
        self.timeLbl.text = Utility.shared.chatTime(stamp:model.timestamp)
        self.audioTimeLbl.text = "00:00"
        
        self.statusIcon.isHidden = true
        if model.isDownload == "0"{
            
            loader.isHidden = false
            loader.play()
            
        }else if model.isDownload == "4"{ //cancelled
            loader.isHidden = false
            loader.pause()
            
        }else{
            loader.stop()
            loader.isHidden = true
        }
        
        let message_id:String = model.message_id
        let updatedDict = ChannelStorage().getChannelMsg(msg_id: message_id)
        var videoName:String = updatedDict!.local_path
        if videoName == "0"{
            let serverLink = model.attachment
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
        }
        // print("-------------Audio_URL : @",videoName)
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
                            let currentTime = CGFloat(self.audioPlayer.duration)
                            DispatchQueue.main.async {
                                self.audioTimeLbl.text = currentTime.SecondsFromTimer()
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

