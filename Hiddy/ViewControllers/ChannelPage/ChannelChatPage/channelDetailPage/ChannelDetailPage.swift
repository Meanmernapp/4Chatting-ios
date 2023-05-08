//
//  ChannelDetailPage.swift
//  Hiddy
//
//  Created by APPLE on 02/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import GSImageViewerController
import AVKit


class ChannelDetailPage: UIViewController,UIScrollViewDelegate,alertDelegate, deleteAlertDelegate {
    
    
    @IBOutlet weak var forwardArrowIcon: UIImageView!
    
    @IBOutlet weak var encrytionContentLabel: UILabel!
    @IBOutlet weak var encryptionTitleLabel: UILabel!
    @IBOutlet weak var encryptionView: UIView!
    @IBOutlet var profileImgView: UIImageView!
        @IBOutlet var contentViewHeight: NSLayoutConstraint!
        @IBOutlet var headerImageViewHeight: NSLayoutConstraint!
        @IBOutlet var bottomViewTopConstraint: NSLayoutConstraint!
        @IBOutlet var bottomScroll: UIScrollView!
        @IBOutlet var topScroll: UIScrollView!
        @IBOutlet var contentView: UIView!
        @IBOutlet var editBtn: UIButton!
        @IBOutlet var topContainerView: UIView!
        @IBOutlet var transparentPic: UIImageView!
        @IBOutlet var navigationView: UIView!
        @IBOutlet var editIcon: UIImageView!
        @IBOutlet var backIcon: UIImageView!
        @IBOutlet var backBtn: UIImageView!
        @IBOutlet var nameLbl: UILabel!
        @IBOutlet var aboutTxtView: UILabel!
        @IBOutlet var titleLbl: UILabel!
        @IBOutlet var muteNotficationLbl: UILabel!
        @IBOutlet var createdByLbl: UILabel!
        @IBOutlet var muteSwitch: UISwitch!
        @IBOutlet var muteView: UIView!
        @IBOutlet var separatorLbl: UILabel!
        @IBOutlet var subCountLbl: UILabel!
        @IBOutlet var viewAllBtn: UIButton!
        @IBOutlet var subscriberView: UIView!
        @IBOutlet var privateIcon: UIImageView!
        @IBOutlet weak var aboutLblPlaceHolder: UILabel!
    
    let channelDB = ChannelStorage()

    // MediaView
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaCountLabel: UILabel!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    var mediaDict = NSArray()

        var viewSubscriber = false

        var scrollDirectionValue = Float()
        var yoffset = Float()
        var alphaValue = CGFloat()
//        var showStatusBar = true
        var type = String()
        var backType = String()
        var blockedType = String()
        var privacy_about = String()
        var mutual = String()
        var channel_id = String()
        var menuArray = NSMutableArray()
        var channelDict = NSDictionary()
        var createdBy = String()
        var channel_type = String()

        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            self.mediaCollectionView.delegate = self
            self.mediaCollectionView.dataSource = self
            self.mediaCollectionView.register(UINib(nibName: "profileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profileCollectionViewCell")
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            self.configParallaxView()
            adjustContentViewHeight()
            self.getChatDetails()
            self.mediaCountLabel.isUserInteractionEnabled = true
            self.mediaCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.mediaCountButtonAct)))
            self.forwardArrowIcon.isUserInteractionEnabled = true
            self.forwardArrowIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.mediaCountButtonAct)))
            //        UIApplication.shared.isStatusBarHidden = true
            
    }
    @objc func mediaCountButtonAct() {
        let vc = MediaDetailsViewController()
        vc.mediaDict = self.mediaDict
        vc.chatType = "channel"
        vc.chat_id = self.channel_id
        vc.image = self.profileImgView.image ?? #imageLiteral(resourceName: "profile_popup_bg")
        vc.userName = self.nameLbl.text!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
        override func viewWillAppear(_ animated: Bool) {
//            UIApplication.shared.isStatusBarHidden = true
            self.updateTheme()
            self.topContainerView.backgroundColor = BACKGROUND_COLOR
            self.contentView.backgroundColor = BACKGROUND_COLOR
            self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
            
            bottomScroll.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self.initialSetup()
            self.changeRTLView()
        }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutTxtView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutTxtView.textAlignment = .right
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteNotficationLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteNotficationLbl.textAlignment = .right
            self.createdByLbl.textAlignment = .right
            self.createdByLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.subCountLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.subCountLbl.textAlignment = .right
            self.aboutLblPlaceHolder.textAlignment = .right
            self.aboutLblPlaceHolder.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mediaTitleLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mediaCountLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.profileImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.encryptionTitleLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.encrytionContentLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.encryptionTitleLabel.textAlignment = .right
            self.encrytionContentLabel.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.nameLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.aboutTxtView.transform = .identity
            self.aboutTxtView.textAlignment = .left
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.muteNotficationLbl.transform = .identity
            self.muteNotficationLbl.textAlignment = .left
            self.createdByLbl.textAlignment = .left
            self.createdByLbl.transform = .identity
            self.subCountLbl.transform = .identity
            self.subCountLbl.textAlignment = .left
            self.aboutLblPlaceHolder.textAlignment = .left
            self.aboutLblPlaceHolder.transform = .identity
            self.mediaTitleLabel.transform = .identity
            self.mediaCountLabel.transform = .identity
            self.profileImgView.transform = .identity
            self.encryptionTitleLabel.transform = .identity
            self.encrytionContentLabel.transform = .identity
            self.encryptionTitleLabel.textAlignment = .left
            self.encrytionContentLabel.textAlignment = .left
        }
    }

        override func viewWillDisappear(_ animated: Bool) {
//            UIApplication.shared.isStatusBarHidden = false
        }
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
//        override var prefersStatusBarHidden: Bool {
//            return showStatusBar
//        }
        
        func initialSetup()  {
            viewSubscriber = false
            self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 30, align: .left, text: EMPTY_STRING)
            self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
            self.createdByLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
            self.aboutTxtView.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
            self.subCountLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: EMPTY_STRING)
            self.viewAllBtn.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .right, title: "view_all")
            self.encryptionTitleLabel.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "encryption_title")
            self.encrytionContentLabel.config(color: TEXT_PRIMARY_COLOR, size: 16, align: .left, text: "encryption_content")
            self.mediaTitleLabel.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "media_title")
            self.mediaCountLabel.config(color: TEXT_PRIMARY_COLOR, size: 16, align: .left, text: "view_all")

            self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
            self.editIcon.tintColor = .white

            self.contentView.specificCornerRadius(radius: 20)
            self.titleLbl.isHidden =  true

            let channelObj = ChannelStorage()
            channelDict = channelObj.getChannelInfo(channel_id: self.channel_id)
            self.mediaDict = channelObj.getAllChannelMediaMsg(channel_id: self.channel_id, message_type: "'image','video','document'")
            createdBy = channelDict.value(forKey:"created_by") as! String
            channel_type = channelDict.value(forKey:"channel_type") as! String
            let createdAt = channelDict.value(forKey:"created_time") as! String
            var created_time = ""
            if channelDict.value(forKey:"created_time") != nil{
                created_time = Utility.shared.timeStamp(stamp: createdAt, format: "dd/MM/yyyy")
            }
            let muteStatus:String = channelDict.value(forKey: "mute") as! String
            self.nameLbl.text = channelDict.value(forKey: "channel_name") as? String
            self.titleLbl.text = channelDict.value(forKey: "channel_name") as? String
            aboutTxtView.numberOfLines = 0
            let description = channelDict.value(forKey: "channel_des") as? String
            self.aboutTxtView.text = description?.html2String
            let count = channelDict.value(forKey: "subscriber_count") as? String
            if count == "0"{
                self.viewAllBtn.isHidden = true
            }
            self.subCountLbl.text = "\(count!) \((Utility.shared.getLanguage()?.value(forKey: "subscribers"))!)"
            //name label
            if createdBy == "admin" {
                self.createdByLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "created_by"))!) Admin \((Utility.shared.getLanguage()?.value(forKey: "at"))!) \(created_time)"
            }else if createdBy == UserModel.shared.userID()! as String {
                self.createdByLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "created_by"))!) You \((Utility.shared.getLanguage()?.value(forKey: "at"))!) \(created_time)"
            }else{
                let localObj = LocalStorage()
                let userDict = localObj.getContact(contact_id: createdBy)
                self.createdByLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "created_by"))!) \((userDict.value(forKey: "user_name")) ?? "") \((Utility.shared.getLanguage()?.value(forKey: "at"))!) \(created_time)"
            }
            //mute status
            if muteStatus == "0" {
                self.muteSwitch.isOn = false
                muteSwitch.thumbTintColor = UIColor().hexValue(hex: "EEE5E8")
                muteSwitch.onTintColor = UIColor().hexValue(hex: "A6A1A5")
            }else{
                self.muteSwitch.isOn = true
                muteSwitch.thumbTintColor = SECONDARY_COLOR
                muteSwitch.onTintColor = UIColor().hexValue(hex: "#D2ACF4")
            }
            
            //add subscribers
            if createdBy == "\(UserModel.shared.userID()!)" {
                self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "edit") as! String,Utility.shared.getLanguage()?.value(forKey: "invite_sub") as! String]
            }else if channel_type == "public"{
                self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String,Utility.shared.getLanguage()?.value(forKey: "invite_sub") as! String, Utility.shared.getLanguage()?.value(forKey: "un_subscribe") as! String, Utility.shared.getLanguage()?.value(forKey: "report") as! String]
                self.configMuteStatus()
                self.configReportStatus()
            }else{
                self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String]
                self.configMuteStatus()
                
            }
//            self.menuArray.add(Utility.shared.getLanguage()?.value(forKey: "clear_all") as! String)
            self.muteNotficationLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: "mute_notification")
            self.setDesign(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height)
            let imageName:String = self.channelDict.value(forKey: "channel_image") as! String
            self.profileImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "channel_detail_bg"))
            
            if channel_type == "private"{
                self.privateIcon.isHidden = false
            }else{
                self.privateIcon.isHidden = true
            }
            
            if self.createdBy == "admin"{
                self.subscriberView.isHidden = true
            }
        }
    
        override func viewDidLayoutSubviews() {
//            aboutTxtView.frame.size = aboutTxtView.bounds.size
        }
    
    func configReportStatus()  {
        self.channelDict = channelDB.getChannelInfo(channel_id: channel_id)
        self.createdBy = self.channelDict.value(forKey: "created_by") as! String
        let report:String = self.channelDict.value(forKey: "report") as? String ?? "0"
        if report == "0"{
            if self.createdBy == "admin" {
                self.menuArray.removeObject(at: 1)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "report") as! String, at: 1)
            }
            else {
                self.menuArray.removeObject(at: 3)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "report") as! String, at: 3)
            }
        }else if report == "1"{
            if self.createdBy == "admin" {
                self.menuArray.removeObject(at: 1)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "undo_report") as! String, at: 1)
            }
            else {
                self.menuArray.removeObject(at: 3)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "undo_report") as! String, at: 3)
            }
        }
    }

    //set mute status
    func configMuteStatus()  {
        let mute:String = self.channelDict.value(forKey: "mute") as! String
        self.menuArray.removeObject(at: 0)
        if mute == "0"{
            self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String, at: 0)
            self.muteSwitch.isOn = false
            
        }else if mute == "1"{
            self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "unmute_notify") as! String, at: 0)
            self.muteSwitch.isOn = true
            
        }
    }
    @IBAction func viewFullImgAction(_ sender: Any) {
        let imageName:String = self.channelDict.value(forKey: "channel_image") as! String
        if !Utility.shared.checkEmptyWithString(value:imageName) {
//            let imageInfo = GSImageInfo
            let data = try? Data(contentsOf: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")!)
            var image =  UIImage()
            if let imageData = data {
                image = UIImage(data: imageData) ?? #imageLiteral(resourceName: "profile_popup_bg")
            }
            else {
                image = #imageLiteral(resourceName: "profile_popup_bg")
            }
            let imageInfo = GSImageInfo.init(image: image, imageMode: .aspectFit, imageHD: nil)
            let transitionInfo = GSTransitionInfo(fromView: self.view)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            imageViewer.modalPresentationStyle = .fullScreen
            self.present(imageViewer, animated: true, completion: nil)
        }
        else {
            let imageInfo = GSImageInfo.init(image: #imageLiteral(resourceName: "profile_popup_bg"), imageMode: .aspectFit, imageHD: nil)
            let transitionInfo = GSTransitionInfo(fromView: self.view)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            imageViewer.modalPresentationStyle = .fullScreen
            self.present(imageViewer, animated: true, completion: nil)
        }
    }
    
    func getChatDetails()  {
        let channelObj = ChannelServices()
        channelObj.channelInfo(channelList: [channel_id], onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let channelArray:NSArray = response.value(forKey: "result") as! NSArray
                for channel in channelArray{
                    let detailDict:NSDictionary = channel as! NSDictionary
                    let channelID:String = detailDict.value(forKey: "_id") as! String
                    let totalCount:NSNumber = detailDict.value(forKey: "total_subscribers") as! NSNumber
                    let channelDB = ChannelStorage()
                    channelDB.updateChannelProfile(channel_id: channelID, title: detailDict.value(forKey: "channel_name") as! String, description: detailDict.value(forKey: "channel_des") as! String,  subscriber_count: "\(totalCount)")
                    if detailDict.value(forKey: "channel_image") != nil{
                        channelDB.updateChannelIcon(channel_id: channelID, channel_icon:detailDict.value(forKey: "channel_image") as! String )
                    }
                    self.initialSetup()
                }
            }
        })
    }

        //configure parallax view
        func configParallaxView()  {
        
            if responds(to: #selector(getter: self.edgesForExtendedLayout)) {
                edgesForExtendedLayout = []
            }
            bottomScroll.delegate = self
            self.contentView.frame = CGRect.init(x: 0, y: headerImageViewHeight.constant - 50, width: FULL_WIDTH, height: FULL_HEIGHT)
            if UIDevice.current.hasNotch{
                headerImageViewHeight.constant = FULL_HEIGHT - 225
            }else if IS_IPHONE_PLUS{
                headerImageViewHeight.constant = FULL_HEIGHT - 150
            }else{
                headerImageViewHeight.constant = FULL_HEIGHT - 100
            }
        }
        
        func adjustContentViewHeight() {
            bottomViewTopConstraint.constant = headerImageViewHeight.constant - 50
            let height = FULL_HEIGHT - bottomViewTopConstraint.constant
            contentViewHeight.constant = UIScreen.main.bounds.size.height+height
            
        }
        // MARK: UIScrollView Delegate
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            showStatusBar = false
//            self.setNeedsStatusBarAppearanceUpdate()
            let offset: CGFloat = scrollView.contentOffset.y
            let percentage: CGFloat = offset / headerImageViewHeight.constant
            let value: CGFloat = headerImageViewHeight.constant * percentage
            // negative when scrolling up more than the top
            alphaValue = CGFloat(abs(Float(percentage)))
            scrollDirectionValue = Float(value)
            if percentage < 0.00 {
                bottomScroll.contentOffset = CGPoint(x: 0, y: 0)
            } else { // scroll to up
                yoffset = Float(bottomScroll.contentOffset.y * 0.3)
                if yoffset > 150{
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                        self.transparentPic.isHidden = true
                        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.editIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.backIcon.image = self.backIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.backIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.navigationView.backgroundColor = BACKGROUND_COLOR
                        self.navigationView.elevationEffect()
                        self.setDesign(topHeight: self.navigationView.frame.origin.y+self.navigationView.frame.size.height+5)

                        self.titleLbl.isHidden = false
                        self.nameLbl.isHidden = true
                    }, completion: nil)
                }else{// scroll to down
                    if yoffset > 110{
                        self.contentView.removeCornerRadius()
                    }else{
                        self.contentView.specificCornerRadius(radius: 20)
                    }
                    self.setDesign(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height)

                    self.titleLbl.isHidden = true
                    self.nameLbl.isHidden = false
                    self.transparentPic.isHidden = false
                    self.editIcon.tintColor = .white
                    self.backIcon.tintColor = .white
                    self.navigationView.backgroundColor = .clear
                }
                topScroll.setContentOffset(CGPoint(x: topScroll.contentOffset.x, y: CGFloat(yoffset)), animated: false)
            }
        }
        
    func heightForView(text:String, font:UIFont, isDelete: CGFloat) -> CGRect {
        let width = (self.view.frame.width * 0.8) - isDelete
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame
    }

        func setDesign(topHeight:CGFloat)  {
            let size =  self.heightForView(text: self.aboutTxtView.text ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 20)!, isDelete: 0)
            self.createdByLbl.frame = CGRect.init(x: 20, y: topHeight-8, width: FULL_WIDTH-40, height: 30)
            self.separatorLbl.frame = CGRect.init(x: 0, y: self.createdByLbl.frame.origin.y+self.createdByLbl.frame.size.height+3, width: FULL_WIDTH, height: 1)
            self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: self.createdByLbl.frame.origin.y+self.createdByLbl.frame.size.height+10, width: FULL_WIDTH, height: 30)
            self.aboutTxtView.frame = CGRect.init(x: 20, y: self.separatorLbl.frame.origin.y+self.separatorLbl.frame.size.height+40, width: FULL_WIDTH-40, height: size.height)
            if mediaDict.count == 0 {
                self.mediaView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+5, width: FULL_WIDTH-40, height: 25)
                self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.size.height+7, width: FULL_WIDTH-40, height: 50)
                self.mediaView.isHidden = true
            }
            else {
                self.mediaView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+5, width: FULL_WIDTH-40, height: 135)
                self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.size.height+5, width: FULL_WIDTH-40, height: 50)
            }

            if createdBy == "\(UserModel.shared.userID()!)" {
                self.muteView.isHidden = true
                self.subCountLbl.frame = CGRect.init(x: 0, y: self.subCountLbl.frame.size.height-5 , width: self.subCountLbl.frame.size.width, height: self.subCountLbl.frame.size.height)
                self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height-50, width: FULL_WIDTH-40, height: 85)
                self.subscriberView.frame = CGRect.init(x: 20, y: self.encryptionView.frame.origin.y+self.encryptionView.frame.size.height+20, width: FULL_WIDTH-40, height: 53)
            }else{
                self.subCountLbl.frame = CGRect.init(x: 0, y: self.subCountLbl.frame.size.height-5 , width: self.subCountLbl.frame.size.width, height: self.subCountLbl.frame.size.height)
                self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+20, width: FULL_WIDTH-40, height: 85)
                self.subscriberView.frame = CGRect.init(x: 20, y: self.encryptionView.frame.origin.y+self.encryptionView.frame.size.height+20, width: FULL_WIDTH-40, height: 53)
            }
            self.changeRTLView()
        }
    
    
    
        @IBAction func backBtnTapped(_ sender: Any) {
            self.dismiss(animated: true, completion: nil)
        }
    
    @IBAction func subscriberListBtnTapped(_ sender: Any) {
        if !viewSubscriber {
            let subListObj = SubscribersList()
            subListObj.channel_id = self.channel_id
            subListObj.modalPresentationStyle = .fullScreen
            self.present(subListObj, animated: true, completion: nil)
            viewSubscriber = true
        }
    }
    
    @IBAction func muteBtnTapped(_ sender: Any) {
        let channelDB = ChannelStorage()
        if muteSwitch.isOn {
            socketClass.sharedInstance.muteStatus(chat_id: self.channel_id, type:"channel" , status: "mute")
            channelDB.channelMute(channel_id: self.channel_id, status: "1")
            muteSwitch.isOn = true
            muteSwitch.thumbTintColor = SECONDARY_COLOR
            muteSwitch.onTintColor = UIColor().hexValue(hex: "#D2ACF4")
        }else{
            socketClass.sharedInstance.muteStatus(chat_id: self.channel_id, type:"channel" , status: "unmute")
            channelDB.channelMute(channel_id: self.channel_id, status: "0")
            muteSwitch.isOn = false
            muteSwitch.thumbTintColor = UIColor().hexValue(hex: "EEE5E8")
            muteSwitch.onTintColor = UIColor().hexValue(hex: "A6A1A5")
        }
    }
        
    @IBAction func menuBtnTapped(_ sender: Any) {
        let alert = CustomAlert()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        let configMenu = FTPopOverMenuConfiguration()
        configMenu.textColor =  TEXT_PRIMARY_COLOR
        configMenu.shadowColor = .white
        configMenu.allowRoundedArrow = false
        configMenu.tintColor = .red
        var frame = self.editIcon.frame
        if UserModel.shared.getAppLanguage() == "عربى" {
            frame = CGRect(x: self.view.frame.origin.x + 5, y: self.editIcon.frame.origin.y, width: self.editIcon.frame.width, height: self.editIcon.frame.height)
            alert.alignmentTag = 1
        }
        FTPopOverMenu.show(fromSenderFrame: frame, withMenuArray: self.menuArray as? [Any], doneBlock: { selectedIndex in
                if selectedIndex == 0{
                    if self.createdBy == "\(UserModel.shared.userID()!)" {
                        let createObj = CreateChannel()
                        createObj.viewType = "1"
                        createObj.exitType = "1"
                        createObj.channel_id = self.channel_id
                        createObj.modalPresentationStyle = .fullScreen
                        self.present(createObj, animated: true, completion: nil)
                    }else{
                    let mute:String = self.channelDict.value(forKey: "mute") as! String
                    if mute == "0"{
                        alert.viewType = "0"
                        alert.msg = "mute_channel"
                        self.present(alert, animated: true, completion: nil)
                    }else if mute == "1"{
                        alert.viewType = "1"
                        alert.msg = "unmute_channel"
                        self.present(alert, animated: true, completion: nil)
                    }
                    }
                }else if selectedIndex == 1{
                    if self.createdBy == UserModel.shared.userID()! as String{
                        let channelObj = addChannelMembers()
                        channelObj.channel_id = self.channel_id
                        channelObj.viewType = "1"
                        channelObj.modalPresentationStyle = .fullScreen
                        self.present(channelObj, animated: true, completion: nil)
                    }
                    else if self.channel_type == "public"{
                        let channelObj = addChannelMembers()
                        channelObj.channel_id = self.channel_id
                        channelObj.viewType = "1"
                        channelObj.modalPresentationStyle = .fullScreen
                        self.present(channelObj, animated: true, completion: nil)
                    }
                    else if self.createdBy == "admin"{
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if selectedIndex == 2{
                    if self.createdBy == UserModel.shared.userID()! as String{
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }else if self.channel_type == "public"{
                        //unsubscribe
                        self.unsubscribeChannel()
                        self.channelDB.deleteChannel(channel_id:self.channel_id)
                    }else if self.createdBy == "admin"{
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else if selectedIndex == 3{
                    if self.channel_type == "public"{
                        let alert = DeleteAlertViewController()
                        alert.modalPresentationStyle = .overCurrentContext
                        alert.modalTransitionStyle = .crossDissolve
                        alert.delegate = self
                        let report:String = self.channelDict.value(forKey: "report") as? String ?? "0"
                        if report == "0"{
                            alert.viewType = "1"
                            alert.typeTag = 1
                            alert.msg = "report_msg"
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self.view.makeToast("Undo report successfully")
                            self.channelDB.channelReport(channel_id: self.channel_id, status: "0")
                            self.channelDict =  self.channelDB.getChannelInfo(channel_id: self.channel_id)
                            self.configReportStatus()
                            channelSocket.sharedInstance.reportChannel(user_id: UserModel.shared.userID() as String? ?? "", channel_id: self.channel_id, report: "", status: "delete", onSuccess: {response in
                                self.channelDict = self.channelDB.getChannelInfo(channel_id: self.channel_id)
                            })
                        }
                    }
                }
                else {
                    alert.viewType = "2"
                    alert.msg = "clear_msg"
                    self.present(alert, animated: true, completion: nil)
            }
            
        }, dismiss: {
            
        })
    }
    func deleteActionDone(type:String, viewType: String) {
        self.updateReport(type:type, viewType: viewType)
    }
    func updateReport(type:String, viewType: String) {
        var reportArr = [Utility().getLanguage()?.value(forKey: "report_abuse") as? String ?? "", Utility().getLanguage()?.value(forKey: "report_adult") as? String ?? "", Utility().getLanguage()?.value(forKey: "report_Inappropriate") as? String ?? ""]
        let report = reportArr[Int(type) ?? 0]
        var status = ""
        if viewType == "1" {
            status = "new"
            self.view.makeToast("Reporting Successfully")
            self.channelDB.channelReport(channel_id: self.channel_id, status: "1")
        }
        else {
            status = "delete"
            self.view.makeToast("Undo Report")
            self.channelDB.channelReport(channel_id: self.channel_id, status: "0")
        }
        self.channelDict =  self.channelDB.getChannelInfo(channel_id: self.channel_id)
        self.configReportStatus()
        
        channelSocket.sharedInstance.reportChannel(user_id: UserModel.shared.userID() as String? ?? "", channel_id: self.channel_id, report: report, status: status, onSuccess: {response in
            self.channelDict = self.channelDB.getChannelInfo(channel_id: self.channel_id)
        })
    }
    func unsubscribeChannel()  {
        let channelObj = ChannelStorage()
        channelSocket.sharedInstance.unSubscribe(channel_id: self.channel_id)
        channelObj.deleteChannelMsg(channel_id: channel_id)
        channelObj.updateSubscribtion(channel_id: self.channel_id,status:"0")
        let del = UIApplication.shared.delegate as! AppDelegate
        del.setHomeAsRootView()
        UserModel.shared.setTab(index: 2)
    }
    func alertActionDone(type: String) {
        let channelObj = ChannelStorage()
        if type == "0"{
            socketClass.sharedInstance.muteStatus(chat_id: self.channel_id, type:"channel" , status: "mute")
            channelObj.channelMute(channel_id: channel_id, status: "1")
            self.channelDict =  channelObj.getChannelInfo(channel_id: channel_id)
            self.configMuteStatus()
        }else if type == "1"{
            socketClass.sharedInstance.muteStatus(chat_id: self.channel_id, type:"channel" , status: "unmute")
            channelObj.channelMute(channel_id: channel_id, status: "0")
            self.channelDict =  channelObj.getChannelInfo(channel_id: channel_id)
            self.configMuteStatus()
        }
        else if type == "2"{
            channelObj.deleteChannelMsg(channel_id: channel_id)
        }
    }
    
}
extension ChannelDetailPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mediaDict.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict:channelMsgModel.message = self.mediaDict.object(at: indexPath.row) as! channelMsgModel.message
        let type = dict.message_type
        if type == "image"  {
            let message_id:String = dict.message_id
            let local_path:String = dict.local_path
            let updatedDict = self.channelDB.getChannelMsg(msg_id: message_id)
            self.openChannelImg(identifier: local_path, msgDict: updatedDict!)
        }
        else if type == "video" {
            self.openChannelVideo(index: indexPath)
        }
        else if type == "document" {
            self.openChannelDocument(index: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.mediaCollectionView.dequeueReusableCell(withReuseIdentifier: "profileCollectionViewCell", for: indexPath) as! profileCollectionViewCell
        let dict:channelMsgModel.message = self.mediaDict.object(at: indexPath.row) as! channelMsgModel.message
        cell.typeLbl.isHidden = true

        if dict.message_type == "image" {
            let imageName:String = dict.attachment
            cell.playView.isHidden = true
            cell.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else if dict.message_type == "video" {
            let imageName:String = dict.thumbnail
            cell.playView.isHidden = false
            cell.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else if dict.message_type == "document" {
            cell.playView.isHidden = true
            cell.imageView.image = #imageLiteral(resourceName: "document_icon")
            cell.imageView.contentMode = .scaleAspectFit
            cell.typeLbl.isHidden = false
            let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(dict.attachment)")
            cell.typeLbl.text = docURL?.pathExtension.uppercased()
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
extension ChannelDetailPage {
    //move to gallery
    
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
                    imageViewer.modalPresentationStyle = .fullScreen
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                let imageName = msgDict.attachment
                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
                
//                let data = try? Data(contentsOf: imageURL!)
//                var image =  UIImage()
//                if let imageData = data {
//                    image = UIImage(data: imageData)!
//                }
                let imageView = UIImageView(image: #imageLiteral(resourceName: "profile_placeholder"))
                imageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))

                let imageInfo = GSImageInfo.init(image: imageView.image!, imageMode: .aspectFit, imageHD: nil)
                
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
    func openChannelVideo(index: IndexPath) {
        let model:channelMsgModel.message = self.mediaDict.object(at: index.row) as! channelMsgModel.message
        let updatedModel = self.channelDB.getChannelMsg(msg_id: model.message_id)
        var videoName:String = updatedModel!.local_path
        if videoName == "0"{
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
        }
        let videoURL = URL.init(string: videoName)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    func openChannelDocument(index: IndexPath) {
        let model:channelMsgModel.message = self.mediaDict.object(at: index.row) as! channelMsgModel.message
        DispatchQueue.main.async {
            let docuName:String = model.attachment
            // print("\(docuName)")
            let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
            webVC.modalPresentationStyle = .fullScreen
            self.present(webVC, animated: true, completion: nil)
        }
    }
}
