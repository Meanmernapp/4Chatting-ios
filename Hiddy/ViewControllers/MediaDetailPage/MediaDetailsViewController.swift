//
//  MediaDetailsViewController.swift
//  Hiddy
//
//  Created by Hitasoft on 25/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import GSImageViewerController
import AVKit

class MediaDetailsViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var barButtonView: UIView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var animationStackView: UIStackView!
    @IBOutlet weak var audionButton: UIButton!
    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var gallertButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var animationLabel: UILabel!
    
    var mediaDict = NSArray()
    var selectedId = ""
    
    let localObj = LocalStorage()
    let channelObj = ChannelStorage()
    let groupDB = groupStorage()

    var chat_id = ""
    var chatType = ""
    var image = UIImage()
    var userName = ""
    var sender = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customUI()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

        // Do any additional setup after loading the view.
    }
    
    func customUI() {
        self.collectionView.register(UINib(nibName: "MediaDerailsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaDerailsCollectionViewCell")
        self.collectionView.register(UINib(nibName: "MediaDetailsDocumentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaDetailsDocumentCollectionViewCell")

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.animationLabel.backgroundColor = RECIVER_BG_COLOR
        self.changeBtnColor()
        self.userNameLabel.font =  UIFont.init(name: APP_FONT_REGULAR, size: 20)
        self.gallertButton.titleLabel?.font = UIFont.init(name: APP_FONT_REGULAR, size: 20)
        self.documentButton.titleLabel?.font = UIFont.init(name: APP_FONT_REGULAR, size: 20)
        self.audionButton.titleLabel?.font = UIFont.init(name: APP_FONT_REGULAR, size: 20)
        
        self.mediaButtonAct(self.gallertButton)
        
        self.userProfileImageView.image = image
        self.userNameLabel.text = userName
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.width / 2
        self.navigationView.backgroundColor = .white
        self.navigationView.elevationEffectOnBottom()
        self.barButtonView.backgroundColor = .white
        self.barButtonView.elevationEffectOnBottom()
        self.changeRTL()
    }
    func changeRTL() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.backBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.backBtn.transform = .identity
        }
    }
    
    func changeBtnColor() {
        self.gallertButton.setTitleColor(.lightGray, for: .normal)
        self.documentButton.setTitleColor(.lightGray, for: .normal)
        self.audionButton.setTitleColor(.lightGray, for: .normal)
    }
    
    @IBAction func backButtonAct(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mediaButtonAct(_ sender: UIButton) {
        self.changeBtnColor()
        sender.setTitleColor(.darkGray, for: .normal)
        self.sender = sender
        
        if sender == gallertButton {
            self.animationStackView.alignment = .leading
            self.loadMediaData(message_type: "'image','video'")
        }
        else if sender == documentButton {
            self.animationStackView.alignment = .trailing
            self.loadMediaData(message_type: "'document'")
        }
        else {
            self.animationStackView.alignment = .trailing
            self.loadMediaData(message_type: "'audio'")
        }
    }
    
    func loadMediaData(message_type: String) {
        if self.chatType == "single" {
            self.mediaDict = self.localObj.getPerticularMediaChat(chat_id:self.chat_id, message_type:message_type)
        }
        else if self.chatType == "group" {
            self.mediaDict = self.groupDB.getGroupMediaInfo(group_id: self.chat_id, message_type: message_type)
        }
        else {
            self.mediaDict = channelObj.getAllChannelMediaMsg(channel_id: self.chat_id, message_type: message_type)
        }
        self.collectionView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MediaDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mediaDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if chatType == "single" {
            let dict:messageModel.message = self.mediaDict.object(at: indexPath.row) as! messageModel.message
            let type = dict.message_data.value(forKeyPath: "message_type") as! String
            if type == "image" || type == "video" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDerailsCollectionViewCell", for: indexPath) as! MediaDerailsCollectionViewCell
                cell.configSingleChat(dict: dict)
                return cell

            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsDocumentCollectionViewCell", for: indexPath) as! MediaDetailsDocumentCollectionViewCell
                cell.configSingleChat(dict: dict)
                return cell
            }
        }
        else if self.chatType == "group" {
            let dict:groupMsgModel.message = self.mediaDict.object(at: indexPath.row) as! groupMsgModel.message
            let type = dict.message_type
            if type == "image" || type == "video" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDerailsCollectionViewCell", for: indexPath) as! MediaDerailsCollectionViewCell
                cell.configGroupChat(dict: dict)
                return cell
                
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsDocumentCollectionViewCell", for: indexPath) as! MediaDetailsDocumentCollectionViewCell
                cell.configGroupChat(dict: dict)
                return cell
            }
        }
        else {
            let dict:channelMsgModel.message = self.mediaDict.object(at: indexPath.row) as! channelMsgModel.message
            let type = dict.message_type
            if type == "image" || type == "video" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDerailsCollectionViewCell", for: indexPath) as! MediaDerailsCollectionViewCell
                cell.configChannelChat(dict: dict)
                return cell
                
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsDocumentCollectionViewCell", for: indexPath) as! MediaDetailsDocumentCollectionViewCell
                cell.configChannelChat(dict: dict)
                return cell
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.sender == gallertButton {
            return CGSize(width: (self.view.frame.width / 3), height: (self.view.frame.width / 3) )
        }
        else {
            return CGSize(width: self.view.frame.width - 40 , height: 50)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if chatType == "single" {
            let dict:messageModel.message = self.mediaDict.object(at: indexPath.row) as! messageModel.message
            let type = dict.message_data.value(forKeyPath: "message_type") as! String
            if type == "image"  {
                let message_id:String = dict.message_data.value(forKeyPath: "message_id") as! String
                let local_path:String = dict.message_data.value(forKeyPath: "local_path") as! String
                let updatedDict = self.localObj.getMsg(msg_id: message_id)
                self.openPic(identifier: local_path, msgDict: updatedDict)
            }
            else if type == "video" {
                self.openVideo(index: indexPath)
            }
            else if type == "document" {
                self.openDocument(index: indexPath)
            }
            else {
                
            }
        }
        else if chatType == "group" {
            let dict:groupMsgModel.message = self.mediaDict.object(at: indexPath.row) as! groupMsgModel.message
            let type = dict.message_type
            if type == "image"  {
                let message_id:String = dict.message_id
                let local_path:String = dict.local_path
                let updatedDict = self.groupDB.getGroupMsg(msg_id: message_id)
                self.openGroupPic(identifier: local_path, msgDict: updatedDict!)
            }
            else if type == "video" {
                self.openGroupVideo(index: indexPath)
            }
            else if type == "document" {
                self.openGroupDocument(index: indexPath)
            }
        }
        else {
            let dict:channelMsgModel.message = self.mediaDict.object(at: indexPath.row) as! channelMsgModel.message
            let type = dict.message_type
            if type == "image"  {
                let message_id:String = dict.message_id
                let local_path:String = dict.local_path
                let updatedDict = self.channelObj.getChannelMsg(msg_id: message_id)
                self.openChannelImg(identifier: local_path, msgDict: updatedDict!)
            }
            else if type == "video" {
                self.openChannelVideo(index: indexPath)
            }
            else if type == "document" {
                self.openChannelDocument(index: indexPath)
            }
        }
    }
    
}
extension MediaDetailsViewController {
    //move to gallery
    func openPic(identifier:String,msgDict:NSDictionary){
        DispatchQueue.main.async {
            if identifier != "0" {
                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
                if galleryPic == nil{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "item_not_found") as? String)
                }else{
                    let imageInfo = GSImageInfo.init(image: galleryPic!, imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView: self.view)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                    imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency

                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                let imageName = msgDict.value(forKeyPath: "message_data.attachment") as! String
                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
                let data = try? Data(contentsOf: imageURL!)
                var image =  UIImage()
                if let imageData = data {
                    image = UIImage(data: imageData)!
                }
                let imageInfo = GSImageInfo.init(image: image, imageMode: .aspectFit, imageHD: nil)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
    func openGroupPic(identifier:String,msgDict:groupMsgModel.message){
        DispatchQueue.main.async {
            if identifier != "0" {
                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
                if galleryPic == nil{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "item_not_found") as? String)
                }else{
                    let imageInfo = GSImageInfo.init(image: galleryPic!, imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView: self.view)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                    imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                let imageName = msgDict.attachment
                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
                let data = try? Data(contentsOf: imageURL!)
                var image =  UIImage()
                if let imageData = data {
                    image = UIImage(data: imageData)!
                }
                let imageInfo = GSImageInfo.init(image: image, imageMode: .aspectFit, imageHD: nil)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
    func openVideo(index: IndexPath) {
        let dict:messageModel.message = mediaDict.object(at: index.row) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        
        let updatedDict = self.localObj.getMsg(msg_id: message_id)
        var videoName:String = updatedDict.value(forKeyPath: "message_data.local_path") as! String
        if videoName == "0"{
            let serverLink = msgDict.value(forKeyPath: "message_data.attachment") as! String
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
        }
        let videoURL = URL.init(string: videoName)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen//or .overFullScreen for transparency
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    func openDocument(index: IndexPath) {
        let dict:messageModel.message = self.mediaDict.object(at: index.row) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        
        DispatchQueue.main.async {
            let docuName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
            // print("\(docuName)")
            let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
            webVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(webVC, animated: true, completion: nil)
        }
    }
    
    func openChannelImg(identifier:String,msgDict:channelMsgModel.message){
        DispatchQueue.main.async {
            if identifier != "0" {
                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
                if galleryPic == nil{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "item_not_found") as? String)
                }else{
                    let imageInfo = GSImageInfo.init(image: galleryPic!, imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView: self.view)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                    imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                let imageName = msgDict.attachment
                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
                
                let data = try? Data(contentsOf: imageURL!)
                var image =  UIImage()
                if let imageData = data {
                    image = UIImage(data: imageData)!
                }
                let imageInfo = GSImageInfo.init(image: image, imageMode: .aspectFit, imageHD: nil)

                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
    func openGroupVideo(index: IndexPath) {
        let model:groupMsgModel.message = self.mediaDict.object(at: index.row) as! groupMsgModel.message
        let updatedModel = self.groupDB.getGroupMsg(msg_id: model.message_id)
        var videoName:String = updatedModel!.local_path
        if videoName == "0"{
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
        }
        let videoURL = URL.init(string: videoName)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    func openChannelVideo(index: IndexPath) {
        let model:channelMsgModel.message = self.mediaDict.object(at: index.row) as! channelMsgModel.message
        let updatedModel = self.channelObj.getChannelMsg(msg_id: model.message_id)
        var videoName:String = updatedModel!.local_path
        if videoName == "0"{
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
        }
        let videoURL = URL.init(string: videoName)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    func openGroupDocument(index: IndexPath) {
        let model:groupMsgModel.message = self.mediaDict.object(at: index.row) as! groupMsgModel.message
        
        DispatchQueue.main.async {
            let docuName:String = model.attachment
            // print("\(docuName)")
            let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
            webVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(webVC, animated: true, completion: nil)
        }
    }
    func openChannelDocument(index: IndexPath) {
        let model:channelMsgModel.message = self.mediaDict.object(at: index.row) as! channelMsgModel.message
        DispatchQueue.main.async {
            let docuName:String = model.attachment
            // print("\(docuName)")
            let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
            webVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(webVC, animated: true, completion: nil)
        }
    }
}
