//
//  ChannelChatPage.swift
//  Hiddy
//
//  Created by APPLE on 02/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import MapKit
import MobileCoreServices
import Contacts
import ContactsUI
import AVKit
import GSImageViewerController
import Photos
import Lottie
import GrowingTextView
import AVFoundation
import iRecordView
import TrueTime
import GiphyUISDK
class ChannelChatPage: UIViewController,  UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, fetchLocationDelegate,UIDocumentPickerDelegate,CNContactPickerDelegate,CNContactViewControllerDelegate,UIDocumentInteractionControllerDelegate,socketClassDelegate,alertDelegate,UIGestureRecognizerDelegate,groupDelegate,channelDelegate,forwardDelegate,GrowingTextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, deleteAlertDelegate, GiphyDelegate{
    
    var docController:UIDocumentInteractionController!
    var numberOfPhotos: NSNumber?
    var msgArray = NSMutableArray()
    var tempMsgs:AnyObject?
    var finalArray = NSMutableArray()
    var channelDict = NSDictionary()
    var channel_id = String()
    let channelDB = ChannelStorage()
    let localDB = LocalStorage()
    let cryptLib = CryptLib()
    var galleryType = String()
    var contactStore = CNContactStore()
    let contactPicker = CNContactPickerViewController()
    var attachmentShow = Bool()
    var isFetch = Bool()
    var timeStamp = Date()
    var menuArray = NSMutableArray()
    var viewType = String()
    var nameListString = String()
    var exitStatus = String()
    var createdBy = String()
    var channel_type = String()
    var longPressGesture = UILongPressGestureRecognizer()
    var selectedId = String()
    var selectedIndexPath = IndexPath()
    var chatCount = 0
    let del = UIApplication.shared.delegate as! AppDelegate
    let gifBtn = UIButton()
    var isRefresh = false
    var isReload = true
    var isKeyborad = false
    var isTranslate = true
    
    var keybordHeight = CGFloat()
    @IBOutlet var camerBtn: UIButton!
    @IBOutlet var galleryBtn: UIButton!
    @IBOutlet var fileBtn: UIButton!
    @IBOutlet var locationBtn: UIButton!
    @IBOutlet var contactBtn: UIButton!
    
    @IBOutlet var downView: UIView!
    @IBOutlet var newMsgView: UIView!
    
    @IBOutlet var supportLanguageBtn: UIButton!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var attachmentIconView: UIView!
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var bootomInputView: UIView!
    @IBOutlet var channelNameLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var subscriberLbl: UILabel!
    @IBOutlet var toolContainerView: UIView!
    @IBOutlet var messageTextView: GrowingTextView!
    @IBOutlet var msgTableView: UITableView!
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var sendImgView: UIImageView!
    @IBOutlet var channelIcon: UIImageView!
    @IBOutlet var attachmentMenuView: UIView!
    @IBOutlet var copyIcon: UIImageView!
    @IBOutlet var copyBtn: UIButton!
    @IBOutlet var forwardView: UIView!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var forwardIcon: UIImageView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var backArrowIcon: UIImageView!
    
    //New Customize
    @IBOutlet weak var record_btn_ref: RecordButton!
    @IBOutlet weak var recorderView: UIView!
    
    var msgIDs = NSMutableArray()
    
    var audioRecorder: AVAudioRecorder!
    //var audioPlayer = AVAudioPlayer()
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var ishold = false
    var isPlaying = false
    var updater : CADisplayLink! = nil
    var senderaudioCell = SenderAudioCell()
    var audioPlayer :AVAudioPlayer!
    var receiveraudioCell = ReceiverVoiceCell()
    
    var counter = 0
    var scrollCount = 0
    var timer = Timer()
    var tag_value = Int()
    var str_value_tofind_which_voiceCell = String()
    var isSwipeCalled = Bool()
    var currentAudioMsgID = String()
    var currentAudioStatus = String()
    var VoiceRecordingSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Voice_record", ofType: ".wav")!)
    var audioPlayer_VoiceRecord: AVAudioPlayer!
    var textSizeArr = [CGFloat]()
    var infoSizeArr = [CGFloat]()
    
    var selectedIndexArr = [IndexPath]()
    var selectedIdArr = [String]()
    var selectedDict = [channelMsgModel.message]()
    let recordView = RecordView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        self.channelDB.updateAllChannelMediaDownload()
        // Do any additional setup after loading the view.
        self.forwardView.isHidden = true
        self.selectedId = EMPTY_STRING
        self.configMsgField()
        self.msgTableView.rowHeight = UITableView.automaticDimension
        self.msgTableView.estimatedRowHeight = 150
        self.msgTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.msgTableView.estimatedSectionHeaderHeight = 40
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        self.customAudioRecordView()
        recordAudioView()
        self.nonecheck(type: UserModel.shared.translatedLanguage() ?? "none")
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        //down unread view
        self.newMsgView.applyGradient()
        self.newMsgView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.downView.cornerViewRadius()
        self.downView.backgroundColor = NEW_MSG_BACKGROUND
        self.newMsgView.isHidden = true
        self.downView.isHidden = true
        
    }
    @objc func willResignActive() {
        
        if(isRecording){
            if(audioRecorder.isRecording){
                audioRecorder.stop()
                audioRecorder.deleteRecording()
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        isRecording = false
    }
    func nonecheck(type: String) {
        if type == "none" {
            self.isTranslate = false
        } else {
            self.isTranslate = true
        }
    }
    func recordAudioView() {
        recordView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordView)
        recordView.trailingAnchor.constraint(equalTo: recorderView.trailingAnchor, constant: -15).isActive = true
        recordView.leadingAnchor.constraint(equalTo: recorderView.leadingAnchor, constant: 15).isActive = true
        recordView.topAnchor.constraint(equalTo: recorderView.topAnchor, constant: 0).isActive = true
        recordView.bottomAnchor.constraint(equalTo: recorderView.bottomAnchor, constant: 0).isActive = true
        record_btn_ref.recordView = recordView
        recordView.delegate = self
        //enable/disable Record Sounds
        recordView.isSoundEnabled = true
        
        recordView.durationTimerColor = TEXT_TERTIARY_COLOR
        
        //        recordView.smallMicImage = #imageLiteral(resourceName: "icon2")
        recordView.slideToCancelArrowImage = nil
        recordView.slideToCancelText = Utility.shared.getLanguage()?.value(forKey: "slide_cancel") as? String ?? ""
        recordView.slideToCancelTextColor = TEXT_TERTIARY_COLOR
        //
        self.recorderView.isHidden = true
        self.attachmentIconView.isHidden = false
        isSwipeCalled = true
        messageTextView.isHidden = false
        
    }
    
    
    
    func customAudioRecordView() {
        self.check_record_permission()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func handleApplicationDidBecomeActive() {
        self.channelDB.updateAllChannelMediaDownload()
        print("Handle Active Status")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.toolContainerView.backgroundColor = BOTTOM_BAR_COLOR
        self.bootomInputView.backgroundColor = BOTTOM_BAR_COLOR
        self.attachmentMenuView.backgroundColor = BOTTOM_BAR_COLOR
        self.forwardView.backgroundColor = BOTTOM_BAR_COLOR
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = false
        self.channelDict = self.channelDB.getChannelInfo(channel_id: self.channel_id)
        self.navigationController?.isNavigationBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        self.recorderView.isHidden = true
        self.attachmentIconView.isHidden = false
        self.initialSetup()
        self.changeRTLView()
        self.nonecheck(type: UserModel.shared.translatedLanguage() ?? "none")
        self.msgTableView.reloadData()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.msgTableView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.backArrowIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.channelNameLbl.textAlignment = .right
            self.subscriberLbl.textAlignment = .right
            self.messageTextView.textAlignment = .right
            self.sendView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.msgTableView.transform = .identity
            self.backArrowIcon.transform = .identity
            self.channelNameLbl.textAlignment = .left
            self.messageTextView.textAlignment = .left
            self.subscriberLbl.textAlignment = .left
            self.sendView.transform = .identity
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.isReload = false
        
        NotificationCenter.default.removeObserver(self)
        self.channelDB.channelReadStatus(channel_id: self.channel_id)
        self.channelDB.channelUpdateUnreadCount(channel_id: self.channel_id)
        Utility.shared.setBadge(vc: self)
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidLayoutSubviews() {
        //        UIView.performWithoutAnimation {
        //        DispatchQueue.main.async {
        ////            self.scrollToBottom()
        //        }
        //        //        }
        
        
                self.configGif()
    }
    
    //set up initial details
    func initialSetup()  {
        //update read status
        self.channelDB.channelReadStatus(channel_id: self.channel_id)
        self.channelDB.channelUpdateUnreadCount(channel_id: self.channel_id)
        Utility.shared.setBadge(vc: self)
        
        socketClass.sharedInstance.delegate = self
        groupSocket.sharedInstance.delegate = self
        channelSocket.sharedInstance.delegate = self
        contactPicker.delegate = self
        
        //self.attachmentShow = false
        self.isFetch =  false
        
        self.navigationView.elevationEffectOnBottom()
        self.channelNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
//        self.subscriberLbl.config(color: TEXT_TERTIARY_COLOR, size: 15, align: .left, text: EMPTY_STRING)
        let description = self.channelDict.value(forKey: "channel_des") as? String
        self.channelNameLbl.text = self.channelDict.value(forKey: "channel_name") as? String
      
        if Utility.shared.isConnectedToNetwork() {
            if IS_IPHONE_5{
                self.subscriberLbl.config(color: TEXT_TERTIARY_COLOR, size: 10, align: .left, text: EMPTY_STRING)
            }else{
                self.subscriberLbl.config(color: TEXT_TERTIARY_COLOR, size: 13, align: .left, text: EMPTY_STRING)
            }
        }else{
            self.subscriberLbl.config(color: TEXT_TERTIARY_COLOR, size: 15, align: .left, text: EMPTY_STRING)
        }
        self.subscriberLbl.text = description?.html2String
        self.channelIcon.rounded()
        
        //send btn
        self.sendBtn.cornerRoundRadius()
        if Utility.shared.checkEmptyWithString(value: messageTextView.text) {
            self.configSendBtn(enable: false)
            self.ConfigVoiceBtn(enable: true)
            
        }else{
            self.configSendBtn(enable: true)
            self.ConfigVoiceBtn(enable: false)
            
        }
        //tap to dismiss keyboard
        //        self.noView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        
        //register cell nibs
        self.registerCells()
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.scrollCount = 0
        if self.isReload{
            self.refresh(scroll: true)
        }
        self.createdBy = self.channelDict.value(forKey: "created_by") as? String ?? ""
        self.channel_type = channelDict.value(forKey:"channel_type") as? String ?? ""
        self.bootomInputView.isHidden = true
        if createdBy == UserModel.shared.userID()! as String {
            self.supportLanguageBtn.isHidden = true
            self.bootomInputView.isHidden = false
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "invite_sub") as! String,Utility.shared.getLanguage()?.value(forKey: "leave_channel_menu") as! String]
        }else if createdBy == "admin" {
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String] // , Utility.shared.getLanguage()?.value(forKey: "report") as! String
            self.configMuteStatus()
            //            self.configReportStatus()
        }else if channel_type == "public"{
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String,Utility.shared.getLanguage()?.value(forKey: "invite_sub") as! String,Utility.shared.getLanguage()?.value(forKey: "un_subscribe") as! String, Utility.shared.getLanguage()?.value(forKey: "report") as! String]
            self.configMuteStatus()
            self.configReportStatus()
        }else{
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String,Utility.shared.getLanguage()?.value(forKey: "un_subscribe") as! String,Utility.shared.getLanguage()?.value(forKey: "report") as! String]
            self.configMuteStatus()
            self.configReportStatus()
        }
        self.menuArray.add(Utility.shared.getLanguage()?.value(forKey: "clear_all") as! String)
        let imageName:String = self.channelDict.value(forKey: "channel_image") as! String
        self.channelIcon.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "channel_placeholder"))
        let height = self.navigationView.frame.size.height
        
        if createdBy != UserModel.shared.userID()! as String {
            self.msgTableView.frame.size.height =  FULL_HEIGHT - height
        }
        //get updated details from service
        self.getChatDetails()
        self.setupLongPressGesture()
        self.adjustDownView()
    }
    
    //set mute status
    func configMuteStatus()  {
        let mute:String = self.channelDict.value(forKey: "mute") as! String
        self.menuArray.removeObject(at: 0)
        if mute == "0"{
            self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String, at: 0)
        }else if mute == "1"{
            self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "unmute_notify") as! String, at: 0)
        }
    }
    
    func socketrecoonect(){
        self.view.makeToast("Poor network connection...", duration: 2, position: .center)
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
    }
    
    
    func configReportStatus()  {
        self.createdBy = self.channelDict.value(forKey: "created_by") as! String
        let report:String = self.channelDict.value(forKey: "report") as? String ?? "0"
        if report == "0"{
            if self.createdBy == "admin" {
                self.menuArray.removeObject(at: 1)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "report") as! String, at: 1)
            }
            else if self.channel_type == "public"{
                self.menuArray.removeObject(at: 3)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "report") as! String, at: 3)
            }
            else {
                self.menuArray.removeObject(at: 2)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "report") as! String, at: 2)
            }
        }else if report == "1"{
            if self.createdBy == "admin" {
                self.menuArray.removeObject(at: 1)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "undo_report") as! String, at: 1)
            }
            else if self.channel_type == "public"{
                self.menuArray.removeObject(at: 3)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "undo_report") as! String, at: 3)
            }
            else {
                self.menuArray.removeObject(at: 2)
                self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "undo_report") as! String, at: 2)
            }
        }
    }
    
    //set up message text view
    func configMsgField()  {
        messageTextView.textColor = TEXT_PRIMARY_COLOR
        messageTextView.layer.borderWidth  = 1.0
        messageTextView.layer.borderColor = TEXT_TERTIARY_COLOR.cgColor
        messageTextView.font = UIFont.systemFont(ofSize: 18)
        messageTextView.textContainer.lineFragmentPadding = 20
        messageTextView.delegate = self
        
        messageTextView.trimWhiteSpaceWhenEndEditing = true
        messageTextView.placeholder = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String
        messageTextView.placeholderColor = TEXT_TERTIARY_COLOR
        messageTextView.minHeight = 30.0
        messageTextView.maxHeight = 150.0
        messageTextView.layer.cornerRadius = 20.0
        messageTextView.textAlignment = .left
        
        recorderView.layer.borderWidth  = 1.0
        recorderView.layer.borderColor = TEXT_TERTIARY_COLOR.cgColor
        recorderView.layer.cornerRadius = 20.0
        
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
                    self.channelDB.updateChannelProfile(channel_id: channelID, title: detailDict.value(forKey: "channel_name") as! String, description: detailDict.value(forKey: "channel_des") as! String,  subscriber_count: "\(totalCount)")
                    
                    if detailDict.value(forKey: "channel_image") != nil{
                        self.channelDB.updateChannelIcon(channel_id: channelID, channel_icon:detailDict.value(forKey: "channel_image") as! String )
                    }
                }
            }
        })
    }
    //register table view cells
    func registerCells()  {
        msgTableView.register(UINib(nibName: "SenderImageCell", bundle: nil), forCellReuseIdentifier: "SenderImageCell")
        msgTableView.register(UINib(nibName: "ReceiverImageCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageCell")
        
        msgTableView.register(UINib(nibName: "SenderVideoCell", bundle: nil), forCellReuseIdentifier: "SenderVideoCell")
        msgTableView.register(UINib(nibName: "ReceiverVideoCell", bundle: nil), forCellReuseIdentifier: "ReceiverVideoCell")
        
        msgTableView.register(UINib(nibName: "SenderLocCell", bundle: nil), forCellReuseIdentifier: "SenderLocCell")
        msgTableView.register(UINib(nibName: "ReceiverLocCell", bundle: nil), forCellReuseIdentifier: "ReceiverLocCell")
        
        msgTableView.register(UINib(nibName: "SenderContact", bundle: nil), forCellReuseIdentifier: "SenderContact")
        msgTableView.register(UINib(nibName: "ReceiverContact", bundle: nil), forCellReuseIdentifier: "ReceiverContact")
        
        msgTableView.register(UINib(nibName: "SenderDocuCell", bundle: nil), forCellReuseIdentifier: "SenderDocuCell")
        msgTableView.register(UINib(nibName: "ReceiverDocuCell", bundle: nil), forCellReuseIdentifier: "ReceiverDocuCell")
        
        msgTableView.register(UINib(nibName: "InfoCell", bundle: nil), forCellReuseIdentifier: "InfoCell")
        msgTableView.register(UINib(nibName: "dateStickyCell", bundle: nil), forCellReuseIdentifier: "dateStickyCell")
        msgTableView.register(UINib(nibName: "ReceiverAudioCell", bundle: nil), forCellReuseIdentifier: "ReceiverAudioCell")
        msgTableView.register(UINib(nibName: "SenderAudioCell", bundle:nil), forCellReuseIdentifier: "SenderAudioCell")
        msgTableView.register(UINib(nibName: "ReceiverVoiceCell", bundle: nil), forCellReuseIdentifier: "ReceiverVoiceCell")
        msgTableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "TextCell")
        
        msgTableView.register(UINib(nibName: "ChatDetailsSectionTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ChatDetailsSectionTableViewCell")
        self.msgTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.msgTableView.estimatedSectionHeaderHeight = 40
        
    }
    
    //dismiss keyboard & attachment menu
    @objc func dismissKeyboard () {
        messageTextView.resignFirstResponder()
        self.scrollToBottom()
    }
    
    //navigation back btn tapped
    @IBAction func backBtnTapped(_ sender: Any) {
        
        if currentAudioMsgID != "" {
            audioPlayer.stop()
            self.timer.invalidate()
        }
        
        if self.selectedIdArr.count != 0  {
            self.forwardView.isHidden = true
            self.selectedId = EMPTY_STRING
            if selectedIndexArr.count != 0 {
                for i in selectedIndexArr {
                    let cell = view.viewWithTag(i.row + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                }
            }
            self.selectedIdArr.removeAll()
            self.selectedIndexArr.removeAll()
            self.selectedDict.removeAll()
            self.scrollCount = 0
            self.msgTableView.reloadData()
            
            
        }else{
            if self.viewType == "2"{
                for controller in self.navigationController!.viewControllers as Array {
                    if UserModel.shared.navType() == "1"{
                        if controller.isKind(of:MyChannelList.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }else if UserModel.shared.navType() == "4"{
                        if controller.isKind(of:AllChannels.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }else{
                        if controller.isKind(of:menuContainerPage.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
            else if self.viewType == "10" {
                self.del.setInitialViewController(initialView: menuContainerPage())
                UserModel.shared.setTab(index: 2)
            }
            else if self.viewType == "1"{
                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
                UserModel.shared.setTab(index: 2)
            }
        }
    }
    
    @IBAction func copyBtnTapped(_ sender: Any) {
        let msgDict = channelDB.getChannelMsg(msg_id: self.selectedIdArr.first ?? "")
        UIPasteboard.general.string = msgDict?.message
        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "copied") as? String)
        self.forwardView.isHidden = true
        self.selectedIdArr.removeAll()
        self.selectedDict.removeAll()
        self.selectedIndexArr.removeAll()
        self.textMsgSize()
        self.infoHeight()
        self.scrollCount = 1
        self.msgTableView.reloadData()
    }
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        var typeTag = 0
        
        // Check if the message is send by own user & msg Time within 1 hr & type is not "isDelete"
        for i in 0..<self.selectedIdArr.count {
            let msgDict =  self.selectedDict[i]
            let chatTime:String = msgDict.timestamp
            let type:String = msgDict.message_type
            let sender_id:String = msgDict.admin_id
            let own_id:String = UserModel.shared.userID()! as String
            
            let cal = Calendar.current
            var d1 = Date()
            let client = TrueTimeClient.sharedInstance
            if client.referenceTime?.now() != nil{
                d1 = (client.referenceTime?.now())!
            }
            if chatTime != nil {
                let d2 = Utility.shared.getUTC(date: chatTime)
                let components = cal.dateComponents([.hour], from: d2, to: d1)
                let diff = components.hour!
                // print(diff)
                if sender_id != own_id || diff >= 1 || type == "isDelete"{
                    typeTag = 0
                    break
                }
                else {
                    typeTag = 1
                }
            }
            
            

            
        }
        let alert = DeleteAlertViewController()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        alert.viewType = "0"
        alert.typeTag = typeTag
        alert.msg = "delete_msg"
        self.present(alert, animated: true, completion: nil)
        
    }
    func deleteActionDone(type:String, viewType: String) {
        if viewType == "0" {
            if type == "0" {
                self.deleteForMeAct()
            }
            else {
                self.deleteForEveryOneAct()
            }
        }
        else {
            self.updateReport(type:type, viewType: viewType)
        }
    }
    func deleteImageAndVideoFromPhotoLibrary(onSuccess success: @escaping (Bool) -> Void) {
        var localPathArr = [String]()
        for i in selectedDict {
            let localPath = i.local_path
            let deleteType = i.message_type
            if (deleteType == "image" || deleteType == "video") && i.admin_id != (UserModel.shared.userID() as String? ?? "") {
                localPathArr.append(localPath)
            }
        }
        PhotoAlbum.sharedInstance.delete(local_ID: localPathArr, onSuccess: {response in
            success(response)
        })
    }
    func updateReport(type:String, viewType: String) {
        var reportArr = [Utility().getLanguage()?.value(forKey: "report_abuse") as? String ?? "", Utility().getLanguage()?.value(forKey: "report_adult") as? String ?? "", Utility().getLanguage()?.value(forKey: "report_Inappropriate") as? String ?? ""]
        let report = reportArr[Int(type) ?? 0]
        var status = ""
        if viewType == "1" {
            status = "new"
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "success_report") as? String ?? "")
            self.channelDB.channelReport(channel_id: self.channel_id, status: "1")
        }
        else {
            status = "delete"
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "undo_report_status") as? String ?? "")
            self.channelDB.channelReport(channel_id: self.channel_id, status: "0")
        }
        
        channelSocket.sharedInstance.reportChannel(user_id: UserModel.shared.userID() as String? ?? "", channel_id: self.channel_id, report: report, status: status, onSuccess: {response in
            self.channelDict = self.channelDB.getChannelInfo(channel_id: self.channel_id)
            self.configReportStatus()
        })
        
    }
    func deleteForEveryOneAct() {
        let channelName = self.channelNameLbl.text!
        for i in self.selectedDict {
            let msgVal =  i
            let msgDict = NSMutableDictionary()
            
            msgDict.setValue("channel", forKey: "chat_type")
            msgDict.setValue(msgVal.message_id, forKey: "message_id")
            msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
            let cryptLib = CryptLib()
            let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"This message was deleted", key: ENCRYPT_KEY)
            
            msgDict.setValue(encryptedMsg, forKey: "message")
            msgDict.setValue("isDelete", forKey: "message_type")
            msgDict.setValue(msgVal.timestamp, forKey: "chat_time")
            msgDict.setValue(channelName, forKey: "channel_name")
            msgDict.setValue(self.channel_id, forKey: "channel_id")
            channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
            self.channelDB.updateChannelMessage(msg_id: msgVal.message_id, msg_type: "isDelete")
            //            self.addChannelMsgToLocal(channel_id: self.channel_id, requestDict: msgDict)
        }
        self.deleteImageAndVideoFromPhotoLibrary(onSuccess: {response in
            
            for msgID in self.selectedIdArr{
                self.replaceUpdatedMsg(msg_id:msgID)
            }
            self.selectedIndexArr.removeAll()
            self.selectedIdArr.removeAll()
            self.selectedDict.removeAll()
            
            DispatchQueue.main.async {
                self.forwardView.isHidden = true
            }
            
        })
    }
    @IBAction func forwardBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        let forwardObj = ForwardSelection()
        forwardObj.msgID = self.selectedIdArr
        forwardObj.msgFrom = "channel"
        forwardObj.delegate = self
        self.navigationController?.pushViewController(forwardObj, animated: true)
    }
    func forwardMsg(type: String, idStr:String) {
        if !msgIDs.contains(type){
            let newMsg = self.channelDB.getChannelMsg(msg_id: type)
            print("idstr \(idStr) channel \(self.channel_id)")
            if idStr == self.channel_id{
                if newMsg != nil{
                    msgIDs.add(type)
                    self.msgArray.add(newMsg!)
                    self.tempMsgs?.add(newMsg!)
                    self.msgTableView.reloadData()
                }
            }
        }
        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "sending") as? String)
        self.forwardView.isHidden = true
        self.selectedIdArr.removeAll()
        self.selectedIndexArr.removeAll()
        self.selectedDict.removeAll()
    }
    
    //refresh view
    func refresh(scroll:Bool)  {
        DispatchQueue.main.async {
            self.isFetch = false
            let newMsg = self.channelDB.getAllChannelMsg(channel_id: self.channel_id, offset: "0")
            self.tempMsgs = self.channelDB.getAllChannelMsg(channel_id: self.channel_id, offset: "0")
            self.msgArray = newMsg!
            if scroll{
                self.infoHeight()
                self.msgTableView.reloadData()
                if self.msgArray.count != 0 && self.scrollCount == 0{
                    
                    let indexPath = IndexPath(row: self.msgArray.count - 1, section: 0)
                    self.msgTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
            
        }
    }
    
    @IBAction func profileViewBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        let channelObj = ChannelDetailPage()
        channelObj.channel_id = self.channel_id
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        channelObj.modalPresentationStyle = .fullScreen
        self.present(channelObj, animated: true, completion: nil)
    }
    func scrollToBottom(){
        if self.msgArray.count != 0 {
            let indexPath = IndexPath(row: self.msgArray.count-1, section: 0)
            self.msgTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.msgArray.count > self.chatCount {
                    self.chatCount = self.msgArray.count
                    let indexPath = IndexPath(row: self.msgArray.count-1, section: 0)
                    self.msgTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                else {
                }
            }
        }
        else {
        }
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        let alert = CustomAlert()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        let configMenu = FTPopOverMenuConfiguration()
        configMenu.textColor =  TEXT_PRIMARY_COLOR
        configMenu.shadowColor = .white
        configMenu.allowRoundedArrow = false
        configMenu.tintColor = .red
        var frame = CGRect(x: self.view.frame.width - 15, y: self.menuBtn.frame.origin.y + self.menuBtn.frame.height - 5 , width: self.menuBtn.frame.width, height: self.menuBtn.frame.height)
        if UserModel.shared.getAppLanguage() == "عربى" {
            frame = CGRect(x: self.view.frame.origin.x + 5, y: self.menuBtn.frame.origin.y + self.menuBtn.frame.height - 5 , width: self.menuBtn.frame.width, height: self.menuBtn.frame.height)
            alert.alignmentTag = 1
        }
        FTPopOverMenu.show(fromSenderFrame: frame, withMenuArray: self.menuArray as? [Any], doneBlock: { selectedIndex in
            if selectedIndex == 0{
                if self.createdBy == UserModel.shared.userID()! as String {
                    
                    let channelObj = addChannelMembers()
                    channelObj.channel_id = self.channel_id
                    channelObj.viewType = "1"
                    channelObj.modalPresentationStyle = .fullScreen
                    self.present(channelObj, animated: true, completion: nil)
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
                    alert.viewType = "3"
                    alert.msg = "leave_channel"
                    self.present(alert, animated: true, completion: nil)
                }else if self.channel_type == "public"{
                    //add member
                    let channelObj = addChannelMembers()
                    channelObj.channel_id = self.channel_id
                    channelObj.viewType = "1"
                    channelObj.modalPresentationStyle = .fullScreen
                    self.present(channelObj, animated: true, completion: nil)
                }
                else if self.createdBy == "admin"{
                    if self.msgArray.count == 0 {
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_clear") as? String)
                    }
                    else {
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    //unsubscribe
                    self.unsubscribeChannel()
                    self.channelDB.deleteChannel(channel_id:self.channel_id)
                    
                }
            }else if selectedIndex == 2{
                if self.createdBy == UserModel.shared.userID()! as String{
                    if self.msgArray.count == 0 {
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_clear") as? String)
                    }
                    else {
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }else if self.channel_type == "public"{
                    //unsubscribe
                    self.unsubscribeChannel()
                    self.channelDB.deleteChannel(channel_id:self.channel_id)
                }else if self.createdBy == "admin"{
                    if self.msgArray.count == 0 {
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_clear") as? String)
                    }
                    else {
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else{
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
                        self.view.makeToast(Utility().getLanguage()?.value(forKey: "undo_report_status") as? String ?? "")
                        self.channelDB.channelReport(channel_id: self.channel_id, status: "0")
                        self.channelDict =  self.channelDB.getChannelInfo(channel_id: self.channel_id)
                        self.configReportStatus()
                        channelSocket.sharedInstance.reportChannel(user_id: UserModel.shared.userID() as String? ?? "", channel_id: self.channel_id, report: "", status: "delete", onSuccess: {response in
                            // print(response)
                            self.channelDict = self.channelDB.getChannelInfo(channel_id: self.channel_id)
                        })
                    }
                }
            }else if selectedIndex == 3{
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
                        self.view.makeToast(Utility().getLanguage()?.value(forKey: "undo_report_status") as? String ?? "")
                        self.channelDB.channelReport(channel_id: self.channel_id, status: "0")
                        self.channelDict =  self.channelDB.getChannelInfo(channel_id: self.channel_id)
                        self.configReportStatus()
                        channelSocket.sharedInstance.reportChannel(user_id: UserModel.shared.userID() as String? ?? "", channel_id: self.channel_id, report: "", status: "delete", onSuccess: {response in
                            // print(response)
                            self.channelDict = self.channelDB.getChannelInfo(channel_id: self.channel_id)
                        })
                    }
                }
                else{
                    if self.msgArray.count == 0 {
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_clear") as? String)
                    }
                    else {
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                if self.msgArray.count == 0 {
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_clear") as? String)
                }
                else {
                    alert.viewType = "2"
                    alert.msg = "clear_msg"
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }, dismiss: {
            
        })
    }
    
    func unsubscribeChannel()  {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        channelSocket.sharedInstance.unSubscribe(channel_id: self.channel_id)
        self.channelDB.deleteChannelMsg(channel_id: channel_id)
        self.channelDB.updateSubscribtion(channel_id: self.channel_id,status:"0")
        let del = UIApplication.shared.delegate as! AppDelegate
        del.setHomeAsRootView()
        UserModel.shared.setTab(index: 2)
    }
    func alertActionDone(type: String) {
        if type == "0"{
            socketClass.sharedInstance.muteStatus(chat_id: self.channel_id, type:"channel" , status: "mute")
            self.channelDB.channelMute(channel_id: channel_id, status: "1")
            self.channelDict =  self.channelDB.getChannelInfo(channel_id: channel_id)
            self.configMuteStatus()
        }else if type == "1"{
            socketClass.sharedInstance.muteStatus(chat_id: self.channel_id, type:"channel" , status: "unmute")
            self.channelDB.channelMute(channel_id: channel_id, status: "0")
            self.channelDict =  self.channelDB.getChannelInfo(channel_id: channel_id)
            self.configMuteStatus()
        }else if type == "2"{
            self.channelDB.deleteChannelMsg(channel_id: channel_id)
            self.tempMsgs?.removeAllObjects()
            self.msgArray.removeAllObjects()
            self.scrollCount = 0
            self.refresh(scroll: true)
        }else if type == "3"{
            channelSocket.sharedInstance.leaveChannel(channel_id: channel_id)
            UserModel().setChannelDeleted(id: channel_id)
            self.channelDB.deleteChannelMsg(channel_id: channel_id)
            self.channelDB.deleteChannel(channel_id: channel_id)
            if self.viewType == "2"{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of:menuContainerPage.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            }else if self.viewType == "4"{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of:MyChannelList.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else if type == "5"{
            //            self.channelDB.deleteChannelSingleMsg(msg_id: selectedId)
            //            self.forwardView.isHidden = true
            //            self.selectedId = EMPTY_STRING
            //            self.msgArray.removeObject(at: selectedIndexPath.row)
            //            self.textMsgSize()
            //            self.msgTableView.reloadData()
            //            self.scrollToBottom()
            self.deleteForMeAct()
        }
    }
    func deleteForMeAct() {
        var selectedIDVal = ""
        for id in 0..<self.selectedIdArr.count {
            if id == 0 {
                selectedIDVal = "'" + self.selectedIdArr[id] + "'"
            }
            else {
                selectedIDVal = selectedIDVal + ",'" + self.selectedIdArr[id] + "'"
            }
        }
        deleteImageAndVideoFromPhotoLibrary(onSuccess: {response in
            if response {
                self.channelDB.deleteChannelSingleMsg(msg_id: selectedIDVal)
                for msgID in self.selectedIdArr{
                    self.replaceUpdatedMsg(msg_id: msgID)
                }
                self.selectedIndexArr.removeAll()
                self.selectedIdArr.removeAll()
                self.selectedDict.removeAll()
                DispatchQueue.main.async {
                    self.forwardView.isHidden = true
                }
            }
        })
        
    }
    
     func configGif(){
     Giphy.configure(apiKey: GIPHY_API_KEY)
     
     let width = FULL_WIDTH/6
     camerBtn.frame = CGRect.init(x: 0, y: 0, width:width , height: 64)
     galleryBtn.frame = CGRect.init(x: width, y: 0, width: width, height: 64)
     
     gifBtn.frame = CGRect.init(x: self.galleryBtn.frame.origin.x+self.galleryBtn.frame.size.width, y: 0, width: width, height: 64)
     gifBtn.setImage(#imageLiteral(resourceName: "attach_gif"), for: .normal)
     gifBtn.addTarget(self, action: #selector(self.gifBtnTapped), for: .touchUpInside)
     
     attachmentMenuView.addSubview(gifBtn)
     fileBtn.frame = CGRect.init(x: gifBtn.frame.origin.x+gifBtn.frame.size.width, y: 0, width: width, height: 64)
     
     locationBtn.frame = CGRect.init(x: self.fileBtn.frame.origin.x+self.fileBtn.frame.size.width, y: 0, width:width, height: 64)
     
     contactBtn.frame = CGRect.init(x: self.locationBtn.frame.origin.x+self.locationBtn.frame.size.width, y: 0, width: width, height: 64)
         
         if IS_IPHONE_5 || IS_IPHONE_PLUS || IS_IPHONE_678 || IS_IPHONE_X {
             fileBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 22, bottom: 20, right: 22)
             gifBtn.imageEdgeInsets = UIEdgeInsets.init(top: 18, left: 18, bottom: 18, right: 18)
             locationBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 22, bottom: 20, right: 22)
             contactBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 22, bottom: 20, right: 22)
         } else {
             camerBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 24, bottom: 20, right: 24)
             galleryBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 24, bottom: 20, right: 24)
             fileBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 24, bottom: 20, right: 24)
             gifBtn.imageEdgeInsets = UIEdgeInsets.init(top: 18, left: 20, bottom: 18, right: 20)
             locationBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 24, bottom: 20, right: 24)
             contactBtn.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 24, bottom: 20, right: 24)
         }
     
     }
     @objc func gifBtnTapped() {
     let giphy = GiphyViewController()
     GiphyViewController.trayHeightMultiplier = 0.7
     giphy.shouldLocalizeSearch = true
     giphy.delegate = self
     giphy.dimBackground = true
//     giphy.showCheckeredBackground = true
     giphy.modalPresentationStyle = .overCurrentContext
     present(giphy, animated: true, completion: nil)
     }
     
     
     
     func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)   {
     
     let gifURL : String = media.url(rendition: .fixedWidth, fileType: .gif)!
     
     if Utility.shared.isConnectedToNetwork() {
     let msgDict = NSMutableDictionary()
     let msg_id = Utility.shared.random()
     let time = NSDate().timeIntervalSince1970
     msgDict.setValue("channel", forKey: "chat_type")
     msgDict.setValue(msg_id, forKey: "message_id")
     msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
     msgDict.setValue(gifURL, forKey: "attachment")
     
     let encryptMsg = cryptLib.encryptPlainTextRandomIV(withPlainText: "Gif", key: ENCRYPT_KEY)
     
     msgDict.setValue(encryptMsg, forKey: "message")
     msgDict.setValue("gif", forKey: "message_type")
    // msgDict.setValue("\(time.rounded().clean)", forKey: "chat_time")
     msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")

     msgDict.setValue(self.channelNameLbl.text, forKey: "channel_name")
     msgDict.setValue(self.channel_id, forKey: "channel_id")
     //send socket
     self.configSendBtn(enable: false)
     self.ConfigVoiceBtn(enable: true)
     channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
     self.addChannelMsgToLocal(channel_id: channel_id, requestDict: msgDict)
     self.messageTextView.text = EMPTY_STRING
     }
     
     // your user tapped a GIF!
     giphyViewController.dismiss(animated: true, completion: nil)
     }
     
     func didDismiss(controller: GiphyViewController?) {
     // your user dismissed the controller without selecting a GIF.
     }
     
    //text msg send btn
    @IBAction func sendBtnTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork() {
            if !Utility.shared.checkEmptyWithString(value: messageTextView.text) {
                
                
                if socket.status == .connected{
                // prepare socket  dict
                let msgDict = NSMutableDictionary()
                let msg_id = Utility.shared.random()
                msgDict.setValue("channel", forKey: "chat_type")
                msgDict.setValue(msg_id, forKey: "message_id")
                msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
                let msg = messageTextView.text.trimmingCharacters(in: .newlines)
                let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:msg, key: ENCRYPT_KEY)
                msgDict.setValue(encryptedMsg, forKey: "message")
                msgDict.setValue("text", forKey: "message_type")
                msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                msgDict.setValue(self.channelNameLbl.text, forKey: "channel_name")
                msgDict.setValue(self.channel_id, forKey: "channel_id")
                //send socket
                channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
                //store
                self.addChannelMsgToLocal(channel_id: channel_id, requestDict: msgDict)
                //empty textfield
                self.messageTextView.text = EMPTY_STRING
                self.configSendBtn(enable: false)
                self.ConfigVoiceBtn(enable: true)
                }else{
                    self.socketrecoonect()
                }
            }
        }else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    // add to channel db
    func addChannelMsgToLocal(channel_id:String,requestDict:NSDictionary)  {
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
        
        let type : String = requestDict.value(forKey: "message_type") as! String
        if type == "image"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "location"{
            lat = requestDict.value(forKey: "lat") as! String
            lon = requestDict.value(forKey: "lon") as! String
        }else if type == "contact"{
            cName = requestDict.value(forKey: "contact_name") as! String
            cNo = requestDict.value(forKey: "contact_phone_no") as! String
        }else if type == "video"{
            attach = requestDict.value(forKey: "attachment") as! String
            thumbnail = requestDict.value(forKey: "thumbnail") as! String
        }else if type == "document"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "audio"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "gif"{
            attach = requestDict.value(forKey: "attachment") as! String
        }
        
        let time = requestDict.value(forKey: "chat_time")! as! String
        var msg_date = String()
        if requestDict[ "message_date"] != nil{
            msg_date = requestDict.value(forKey: "message_date")! as! String
        }else{
            msg_date = ""
        }
        //add local db
        channelDB.addChannelMsg(msg_id: requestDict.value(forKey: "message_id") as! String,
                                channel_id:channel_id ,
                                admin_id: UserModel.shared.userID()! as String,
                                msg_type: requestDict.value(forKey: "message_type")! as! String,
                                msg: requestDict.value(forKey: "message")! as! String,
                                time: time,
                                lat: lat,
                                lon: lon,
                                contact_name: cName,
                                contact_no: cNo,
                                country_code: cc,
                                attachment: attach,
                                thumbnail: thumbnail,read_status:"0", msg_date: msg_date)
        if  UserModel.shared.channelIDs().contains(channel_id) {
            channelDB.updateChannelDetails(channel_id: channel_id, mute: "0", report: "0",  message_id: requestDict.value(forKey: "message_id") as! String, timestamp: requestDict.value(forKey: "chat_time") as! String, unread_count: "0")
        }
        
        //        var dateString = String()
        //        dateString = Utility.shared.chatDate(stamp: time)
        //
        //        let model = channelMsgModel.message.init(message_id: requestDict.value(forKey: "message_id") as! String,
        //                                                 channel_id: channel_id,
        //                                                 message_type: requestDict.value(forKey: "message_type")! as! String,
        //                                                 message: requestDict.value(forKey: "message")! as! String,
        //                                                 timestamp: time,
        //                                                 lat: lat,
        //                                                 lon: lon,
        //                                                 contact_name: cName,
        //                                                 contact_no: cNo,
        //                                                 country_code: cc,
        //                                                 attachment: attach,
        //                                                 thumbnail: thumbnail,
        //                                                 isDownload: "",
        //                                                 local_path: "",
        //                                                 date: dateString,
        //                                                 admin_id: UserModel.shared.userID()! as String,
        //                                                 translated_status:"",
        //                                                 translated_msg:"")
        //        if UserModel.shared.dateSticky() == nil {
        //            msgArray.add(channelMsgModel.message.init(message_id: "",channel_id: "",message_type: "date_sticky",message: "",timestamp: "",lat: "",lon: "",contact_name: "",contact_no: "",country_code: "",attachment: "",thumbnail: "",isDownload: "",local_path: "",date: model.date, admin_id: "", translated_status:"", translated_msg:""))
        //            UserModel.shared.setDateSticky(date: model.date)
        //        }else{
        //            if !(UserModel.shared.dateSticky()?.contains(model.date))!{
        //                msgArray.add(channelMsgModel.message.init(message_id: "",channel_id: "",message_type: "date_sticky",message: "",timestamp: "",lat: "",lon: "",contact_name: "",contact_no: "",country_code: "",attachment: "",thumbnail: "",isDownload: "",local_path: "",date: model.date, admin_id: "", translated_status:"", translated_msg:""))
        //                UserModel.shared.setDateSticky(date: model.date)
        //            }
        //        }
        
        self.channelDB.updateChannelMediaLocalURL(msg_id: requestDict.value(forKey: "message_id") as! String, url: requestDict.value(forKey: "local_path") as? String ?? "0")
        
        //add local array
        self.isFetch = false
        self.tempMsgs?.removeAllObjects()
        let newMsg = self.channelDB.getAllChannelMsg(channel_id: channel_id, offset: "0")
        self.tempMsgs = self.channelDB.getAllChannelMsg(channel_id: channel_id, offset: "0")
        self.msgArray.removeAllObjects()
        self.msgArray = newMsg!
        self.textMsgSize()
        self.infoHeight()
        self.msgTableView.reloadData()
        self.scrollToBottom()
        
        self.configSendBtn(enable: false)
        self.ConfigVoiceBtn(enable: true)
        
    }
    
    //open attachment menu
    @IBAction func attachmentMenuBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        if self.attachmentShow{
            self.showAttachmentMenu(enable: false)
        }else{
            self.showAttachmentMenu(enable: true)
        }
        //        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
        //        }, completion: nil)
    }
    
    func textMsgSize() {
        self.textSizeArr.removeAll()
        for i in 0..<self.msgArray.count {
            let model:channelMsgModel.message = msgArray.object(at: i) as! channelMsgModel.message
            var msg:String = model.message
            let type:String = model.message_type
            let sender_id:String = model.admin_id
            let own_id:String = UserModel.shared.userID()! as String
            
            var deleteStatus = CGFloat(0)
            if type == "isDelete" {
                msg = "This message was deleted"
                deleteStatus = 15
            }
            heightForView(text: msg, font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: deleteStatus) { (value) in
                let val = value.height
                if sender_id == own_id {
                    self.textSizeArr.append(65 + val)
                }
                else {
                    if type == "isDelete" {
                        self.textSizeArr.append(65 + val)
                    }
                    else {
                        self.textSizeArr.append(65 + val + 21)
                    }
                }
            }
        }
    }
    func heightForView(text:String, font:UIFont, isDelete: CGFloat, onSuccess success: @escaping (CGRect) -> Void) {
        DispatchQueue.main.async {
            let width = (self.view.frame.width * 0.8) - isDelete
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.font = font
            label.text = text
            label.sizeToFit()
            success(label.frame)
        }
    }
    
    
    
    func makeSelection(tag:Int,type:String,index:IndexPath)  {
        let dict:channelMsgModel.message = msgArray.object(at: tag) as! channelMsgModel.message
        let msg_type = dict.message_type
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if msg_type != "date_sticky"{
            let id = dict.message_id
            if self.selectedIdArr.filter({$0 == id}).count == 0 {
                let cell:UITableViewCell = self.msgTableView.cellForRow(at: index)!
                cell.tag = tag + 400
                
                self.selectedIndexArr.append(index)
                cell.backgroundColor = CHAT_SELECTION_COLOR
                self.selectedIdArr.append(id)
                self.selectedDict.append(dict)
                self.forwardView.isHidden = false
                
            }else{
                if self.selectedIdArr.filter({$0 == id}).count != 0 {
                    let cell = view.viewWithTag(index.row + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                }
                let id = self.selectedIdArr.firstIndex(of: id)
                self.selectedIdArr.remove(at: id ?? 0)
                self.selectedDict.remove(at: id ?? 0)
                let selectedIndex = self.selectedIndexArr.firstIndex(of: index)
                self.selectedIndexArr.remove(at: selectedIndex ?? 0)
                self.scrollCount = 1
                self.msgTableView.reloadData()
            }
            if self.selectedDict.count != 1 {
                self.copyBtn.isHidden = true
                self.copyIcon.isHidden = true
            }
            else if msg_type == "text"{
                self.copyBtn.isHidden = false
                self.copyIcon.isHidden = false
            }
            else {
                self.copyBtn.isHidden = true
                self.copyIcon.isHidden = true
            }
            self.checkDownloadStatus()
            
        }else{
            for index in self.selectedIndexArr {
                if index.count != 0 {
                    let cell = view.viewWithTag(index.row + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                }
            }
        }
        if self.selectedIdArr.count == 0 {
            self.forwardView.isHidden = true
            if self.messageTextView.isFirstResponder {
                dismissKeyboard()
            }
        }
    }
    func checkDownloadStatus() {
        for dict in self.selectedDict {
            let downloadStatus = dict.isDownload
            let message_type = dict.message_type
            print(message_type)
            if (message_type != "text" && message_type != "isDelete" && message_type != "status") && (downloadStatus == "0") && (dict.admin_id != UserModel.shared.userID() as String? ?? ""){
                self.forwardButton.isHidden = true
                self.forwardIcon.isHidden = true
                break
            }
            else {
                if message_type == "isDelete" {
                    self.forwardIcon.isHidden = true
                    self.copyIcon.isHidden = true
                    break
                }
                self.forwardButton.isHidden = false
                self.forwardIcon.isHidden = false
            }
        }
    }
    @objc func docuCellBtnTapped(_ sender: UIButton!)  {
        self.messageTextView.resignFirstResponder()
        let model:channelMsgModel.message = msgArray.object(at: sender.tag) as! channelMsgModel.message
        if self.selectedIdArr.count == 0 {
            let type:String = model.message_type
            if type != "date_sticky" {
                if type == "document"{
                    let message_id:String = model.message_id
                    let sender_id:String = model.admin_id
                    let own_id:String = UserModel.shared.userID()! as String
                    
                    let updatedDict = self.channelDB.getChannelMsg(msg_id: message_id)
                    var docName:String = updatedDict!.local_path
                    if docName == "0"{
                        let serverLink = model.attachment
                        docName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
                    }
                    // print("-------------Audio_URL : %@",videoName)
                    _ = URL.init(string: docName)
                    let message = model.message
                    dowloaDocdFile(docString: docName, message: message)
                    let isDownload = model.isDownload
                    
                    if sender_id != own_id{
                        //check its downloaded
                        if isDownload == "0" {
                            self.downloadDocument(index: sender.tag, model: model)
                        }else if isDownload == "1"{
                            DispatchQueue.main.async {
                                let docuName:String = model.attachment
                                // print("\(docuName)")
                                let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                webVC.modalPresentationStyle = .fullScreen
                                self.present(webVC, animated: true, completion: nil)
                            }
                        }
                    }else{
                        //check if uploaded or not
                        if isDownload == "1" {
                            DispatchQueue.main.async {
                                let docuName:String = model.attachment
                                // print("\(docuName)")
                                let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                webVC.modalPresentationStyle = .fullScreen
                                self.present(webVC, animated: true, completion: nil)
                            }
                        }else if isDownload == "4"{//cancelled
                            if Utility.shared.isConnectedToNetwork(){
                                DispatchQueue.main.async {
                                    let docuName:String = model.attachment
                                    // print("\(docuName)")
                                    let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                    webVC.modalPresentationStyle = .fullScreen
                                    self.present(webVC, animated: true, completion: nil)
                                }
                            } else{
                                self.messageTextView.resignFirstResponder()
                                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                let docuName:String = model.attachment
                                // print("\(docuName)")
                                let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                webVC.modalPresentationStyle = .fullScreen
                                self.present(webVC, animated: true, completion: nil)
                            }
                        }
                    }
                    
                }
            }
        }else{
            let type:String = model.message_type
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, type: type, index: indexpath)
        }
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
    }
    func downloadDocument(index:Int, model :channelMsgModel.message)  {
        self.channelDB.updateChannelMediaDownload(msg_id: model.message_id, status: "2")
        let cell = view.viewWithTag(index) as? ReceiverDocuCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        cell?.downloadIcon.isHidden = true
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"),
               let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(model.message)"
                // print("file path \(filePath)")
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    self.channelDB.updateChannelMediaDownload(msg_id: model.message_id, status: "1")
                    self.scrollCount = 1
                    self.replaceUpdatedMsg(msg_id: model.message_id)
                    
                }
            }
        }
    }
    func dowloaDocdFile(docString:String, message: String)  {
        
        if let url = URL.init(string:docString){
            
            // if let audioUrl = URL(string: "http://freetone.org/ring/stan/iPhone_5-Alarm.mp3") {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
            // print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: message) {
                // print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        // print("File moved to documents folder \(destinationUrl)")
                    } catch let error as NSError {
                        // print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    @objc func imageCellBtnTapped(_ sender: UIButton!)  {
        self.isReload = false
        
        let model:channelMsgModel.message = msgArray.object(at: sender.tag) as! channelMsgModel.message
        let type:String = model.message_type
        if self.selectedIdArr.count == 0 {
            let sender_id:String = model.admin_id
            let own_id:String = UserModel.shared.userID()! as String
            DispatchQueue.main.async {
                let updatedModel = self.channelDB.getChannelMsg(msg_id: model.message_id)
                if sender_id != own_id{
                    if model.isDownload == "0" {
                        self.downloadImage(index: sender.tag, msgModel: model)
                    }else{
                        self.openPic(identifier: model.local_path,msgMode:updatedModel!)
                    }
                }else{
                    self.openPic(identifier: model.local_path,msgMode:updatedModel!)
                }
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, type: type, index: indexpath)
        }
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
    }
    
    @objc func videoCellBtnTapped(_ sender: UIButton!)  {
        self.isReload = false
        
        let model:channelMsgModel.message = msgArray.object(at: sender.tag) as! channelMsgModel.message
        let type:String = model.message_type
        if self.selectedIdArr.count == 0 {
            let sender_id:String = model.admin_id
            let own_id:String = UserModel.shared.userID()! as String
            
            let updatedModel = self.channelDB.getChannelMsg(msg_id: model.message_id)
            var videoName:String = updatedModel!.local_path
            if videoName == "0"{
                videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
            }
            let videoURL = URL.init(fileURLWithPath: videoName)
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            if sender_id != own_id{
                //check its downloaded
                if model.isDownload == "0" {
                    self.downloadVideo(index: sender.tag, model: model)
                }else if model.isDownload == "1"{
                    if counter != 0 {
                        audioPlayer.stop()
                    }
                    playerViewController.modalPresentationStyle = .fullScreen
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            }else{
                //check if uploaded or not
                if model.isDownload == "1" {
                    if counter != 0 {
                        audioPlayer.stop()
                    }
                    playerViewController.modalPresentationStyle = .fullScreen
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
                else if model.isDownload == "4"{//cancelled
                    if Utility.shared.isConnectedToNetwork(){
                        self.channelDB.updateChannelMediaDownload(msg_id: model.message_id, status: "0")
                        self.infoHeight()
                        self.scrollCount = 1
                        self.msgTableView.reloadData()
                        PhotoAlbum.sharedInstance.getChannelVideo(local_ID: videoURL, msg_id: model.message_id, requestData: model, type: model.message_type, channel_id: model.channel_id, channel_name: self.channelNameLbl.text!)
                        //                        PhotoAlbum.sharedInstance.getGroupVideo(local_ID:videoURL!, msg_id: updatedModel.message_id, requestData: updatedModel, type: (videoURL?.pathExtension)!,role: self.memberDict.value(forKey: "member_role") as! String, phone: self.memberDict.value(forKey: "member_no")as! String, group_id: self.group_id, group_name: self.groupNameLbl.text!)
                    } else{
                        self.messageTextView.resignFirstResponder()
                        self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
                    }
                }
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, type: type, index: indexpath)
        }
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
    }
    
    @objc func locationTapped(_ sender: UIButton!)  {
        
        let model:channelMsgModel.message = msgArray.object(at: sender.tag) as! channelMsgModel.message
        let locationObj = PickLocation()
        locationObj.type = "1"
        locationObj.viewType = "channel"
        locationObj.channelLocationModel = model
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        locationObj.modalPresentationStyle = .fullScreen
        self.navigationController?.present(locationObj, animated: true, completion: nil)
    }
    //move to gallery
    func openPic(identifier:String,msgMode:channelMsgModel.message){
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
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
                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(msgMode.attachment)")
                print("imag url \(imageURL)")
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
    
    @IBAction func goToBottom(_ sender: Any) {
        self.msgTableView.reloadData()
        self.newMsgView.isHidden = true
        self.downView.isHidden = true
        if self.msgArray.count != 0 {
            let indexPath = IndexPath(row: self.msgArray.count - 1, section: 0)
            self.msgTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    //adjust down view frame
    func adjustDownView()  {
        var topPadding = CGFloat()
        if UIDevice.current.hasNotch {
            topPadding = FULL_HEIGHT - 200
        }else{
            topPadding = FULL_HEIGHT - 150
        }
        if isKeyborad {
            topPadding -= keybordHeight
        }
        
        self.downView.frame = CGRect.init(x: FULL_WIDTH - 60, y: topPadding, width: 40, height: 40)
        self.newMsgView.frame = CGRect.init(x: self.downView.frame.origin.x+25, y: topPadding, width: 15, height: 15)
    }
    //load more action
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = self.msgTableView.contentOffset
        let pageHeight = self.msgTableView.contentSize.height - (FULL_HEIGHT - 50)
        
        if currentOffset.y < pageHeight{
            self.adjustDownView()
            self.downView.isHidden = false
        }else{
            self.downView.isHidden = true
            self.newMsgView.isHidden = true
        }
        //reload if directly scroll down
        if !self.newMsgView.isHidden{
            if self.isRefresh{
                self.isRefresh = false
                self.msgTableView.reloadData()
            }
        }
        if currentOffset.y < 50{
            if isFetch == false {
                isFetch = true
                //get new msg from service based on offset
                var previousMsg:AnyObject?
                previousMsg = self.channelDB.getAllChannelMsg(channel_id: channel_id, offset: "\((tempMsgs?.count)!)")
                if previousMsg?.count != 0{
                    //prepare added final array to load
                    self.finalArray.removeAllObjects()
                    self.finalArray.addObjects(from: previousMsg as! [Any])
                    self.finalArray.addObjects(from:tempMsgs as! [Any])
                    self.msgArray.removeAllObjects()
                    self.msgArray.addObjects(from: self.finalArray as! [Any])
                    
                    // add over all temp array
                    self.tempMsgs?.removeAllObjects()
                    self.tempMsgs?.addObjects(from: self.finalArray as! [Any])
                    if self.msgArray.count != 0{
                        UIView.performWithoutAnimation {
                            print("*********** reload")
                            UIView.setAnimationsEnabled(false)
                            //                            self.infoHeight()
                            self.msgTableView.reloadData()
                            let indexPath = IndexPath(row: (previousMsg?.count)!, section: 0)
                            self.msgTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            self.isFetch = false
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                }
            }
        }
    }
    
    func setupLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        self.msgTableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        //get touch point
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        let touchPoint = gestureRecognizer.location(in: self.msgTableView)
        let selectedIndexPath = self.msgTableView.indexPathForRow(at: touchPoint)
        //check if selected is empty or not
        if selectedIndexPath?.count != 0 && self.selectedIdArr.count == 0 && selectedIndexPath != nil{
            //get msg data based on the selection
            let dict:channelMsgModel.message = self.msgArray.object(at: selectedIndexPath?.row ?? 0) as! channelMsgModel.message
            //arrange msg values
            let msg_type = dict.message_type
            let id = dict.message_id
            if msg_type != "date_sticky"{
                if self.selectedIdArr.filter({$0 == id}).count == 0{
                    let cell:UITableViewCell = self.msgTableView.cellForRow(at: selectedIndexPath!)!
                    cell.tag = selectedIndexPath?.row ?? 0 + 400
                    //forward only downloaded media files
                    if msg_type == "image" || msg_type == "video" || msg_type == "contact" || msg_type == "document" || msg_type == "text" ||  msg_type ==  "location"{
                        let isDownload = dict.isDownload
                        
                        if dict.admin_id == UserModel.shared.userID()! as String {
                            cell.backgroundColor = CHAT_SELECTION_COLOR
                            self.forwardView.isHidden = false
                            self.selectedDict.append(dict)
                            self.selectedIdArr.append(id)
                            self.selectedIndexArr.append(selectedIndexPath!)
                        }
                        else if isDownload == "0" && (msg_type == "image" || msg_type == "video"){
                            self.forwardView.isHidden = true
                        }
                        else{
                            cell.backgroundColor = CHAT_SELECTION_COLOR
                            self.forwardView.isHidden = false
                            self.selectedIdArr.append(id)
                            self.selectedIndexArr.append(selectedIndexPath!)
                            self.selectedDict.append(dict)
                        }
                    }else{
                        cell.backgroundColor = CHAT_SELECTION_COLOR
                        self.selectedIdArr.append(id)
                        self.selectedIndexArr.append(selectedIndexPath!)
                        self.selectedDict.append(dict)
                        self.forwardView.isHidden = false
                    }
                    //msg type
                    if msg_type == "text" {
                        self.copyBtn.isHidden = false
                        self.copyIcon.isHidden = false
                    }else{
                        self.copyBtn.isHidden = true
                        self.copyIcon.isHidden = true
                    }
                }
                self.checkDownloadStatus()
                
            }else{
                self.forwardView.isHidden = true
                let index = self.selectedIdArr.firstIndex(of: id)
                if selectedIdArr.count != 0 {
                    self.selectedIdArr.remove(at: index ?? 0)
                    let selectedIndex = self.selectedIndexArr.firstIndex(of: selectedIndexPath!)
                    self.selectedIndexArr.remove(at: selectedIndex ?? 0)
                }                
                if selectedIndexPath?.count != 0 {
                    let cell = view.viewWithTag(selectedIndexPath?.row ?? 0 + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                }
            }
        }
    }
    //MARK: update tableview cell from bottom
    func scroll(toTheBottom animated: Bool) {
        if msgArray.count != 0 {
            //            let indexPath = IndexPath(row: self.msgArray.count-1, section: 0)
            //            self.msgTableView.scrollToRow(at: indexPath, at: .top, animated: false)
            self.scrollToBottom()
            
        }
        
    }
    //check and replace updated message
    func replaceUpdatedMsg(msg_id:String)  {
        var i = 0
        for msg in self.msgArray {
            let msgModel:channelMsgModel.message = msg as! channelMsgModel.message
            if msgModel.message_id == msg_id{
                let updatedMsg = self.channelDB.getChannelMsg(msg_id: msg_id)
                if updatedMsg == nil{
                    DispatchQueue.main.async {
                        self.msgArray.remove(msg)
                        self.updateLastMsg()
                        self.msgTableView.reloadData()
                    }
                }else{
                    self.msgArray.removeObject(at: i)
                    self.msgArray.insert(updatedMsg!, at: i)
                    self.updateLastMsg()
                    DispatchQueue.main.async {
                        self.msgTableView.reloadData()
                    }
                }
            }            
            i += 1
        }
    }
    func updateLastMsg() {
        if self.msgArray.count > 0 {
            let lastMsg = self.msgArray.object(at: self.msgArray.count - 1) as! channelMsgModel.message
            let unreadcount = channelDB.getChannelUnreadCount(channel_id: channel_id)
            if lastMsg.message_type == "date_sticky" {
                if self.msgArray.count > 1 {
                    let lastMsg1 = self.msgArray.object(at: self.msgArray.count - 2) as! channelMsgModel.message
                    
                    channelDB.updateChannelDetails(channel_id: channel_id, mute: channelDict.value(forKey: "mute") as! String, report: channelDict.value(forKey: "report") as! String, message_id: lastMsg1.message_id, timestamp:  lastMsg1.timestamp, unread_count: "\(unreadcount)")
                }
            }else {
                channelDB.updateChannelDetails(channel_id: channel_id, mute: channelDict.value(forKey: "mute") as! String, report: channelDict.value(forKey: "report") as! String, message_id: lastMsg.message_id, timestamp:  lastMsg.timestamp, unread_count: "\(unreadcount)")
            }
        } else {
            channelDB.updateChannelDetails(channel_id: channel_id, mute: channelDict.value(forKey: "mute") as! String, report: channelDict.value(forKey: "report") as! String, message_id: "You Deleted this message", timestamp: Utility.shared.getTime(), unread_count: "0")
            
        }
    }
    //DOWNLOAD IMAGE
    func downloadImage(index:Int, msgModel:channelMsgModel.message)  {
        self.channelDB.updateChannelMediaDownload(msg_id: msgModel.message_id, status: "2")
        let cell = view.viewWithTag(index + 50000) as? ReceiverImageCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        let imageURL = URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(msgModel.attachment)")
        print("download url \(imageURL)")
        DispatchQueue.global(qos: .background).async {
            let data = try? Data(contentsOf: imageURL!)
            if let imageData = data {
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                    PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgModel.attachment,type: "channel")
                    self.channelDB.updateChannelMediaDownload(msg_id: msgModel.message_id, status: "1")
                    self.scrollCount = 1
                    self.replaceUpdatedMsg(msg_id: msgModel.message_id)
                }
            }
        }
    }
    //DOWNLOAD VIDEO
    func downloadVideo(index:Int, model :channelMsgModel.message)  {
        
        self.channelDB.updateChannelMediaDownload(msg_id: model.message_id, status: "2")
        let cell = view.viewWithTag(index + 20000) as? ReceiverVideoCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        cell?.downloadIcon.isHidden = true
        cell?.playImgView.image = #imageLiteral(resourceName: "download_icon")
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"),
               let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(model.attachment)"
                // print("file path \(filePath)")
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    //                    if self.galleryType == "1"{
                    PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: model.message_id,type:"channel")
                    //                    }
                    self.channelDB.updateChannelMediaDownload(msg_id: model.message_id, status: "1")
                    self.scrollCount = 1
                    self.replaceUpdatedMsg(msg_id: model.message_id)
                }
            }
        }
    }
    
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        self.isKeyborad = true
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.attachmentShow = true
        if UIDevice.current.hasNotch{
            self.bottomConst.constant = keyboardFrame.height-35
            keybordHeight = keyboardFrame.height-35
        }else{
            self.bottomConst.constant = keyboardFrame.height-8
            keybordHeight = keyboardFrame.height-8
        }
        
        self.scrollToBottom()
        if msgArray.count != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.chatCount = self.msgArray.count
                let indexPath = IndexPath(row: self.msgArray.count-1, section: 0)
                self.msgTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.isKeyborad = false
        self.keybordHeight = 0.0
        self.bottomConst.constant = 0
        self.scrollToBottom()
    }
    
    
    func configSendBtn(enable:Bool)  {
        if enable {
            self.sendBtn.isUserInteractionEnabled = true
            self.sendView.isHidden = false
        }else{
            self.sendBtn.isUserInteractionEnabled = false
            self.sendView.isHidden = true
        }
    }
    
    //show & hide attachment menu view
    func showAttachmentMenu(enable:Bool)  {
        if !enable{
            //dismiss
            self.attachmentShow = false
            self.attachmentMenuView.isHidden = false
            
        }else{
            //open
            self.attachmentMenuView.isHidden = true
            self.attachmentShow = true
        }
    }
    
    
    //MARK: ***************** LOCATION PICKER METHODS *********************
    
    @IBAction func locationBtnTapped(_ sender: Any) {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if Utility.shared.isConnectedToNetwork() {
            
            
            if socket.status == .connected{
                let locationObj = PickLocation()
                locationObj.delegate = self
                locationObj.modalPresentationStyle = .fullScreen
                self.navigationController?.present(locationObj, animated: true, completion: nil)
            }else{
                self.socketrecoonect()
            }
            

        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //MARK: location fetch delegate
    func fetchCurrentLocation(location: CLLocation) {
        if socket.status == .connected{
            let msgDict = NSMutableDictionary()
            let msg_id = Utility.shared.random()
            msgDict.setValue("channel", forKey: "chat_type")
            msgDict.setValue(msg_id, forKey: "message_id")
            msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
            
            msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
            msgDict.setValue(self.channelNameLbl.text, forKey: "channel_name")
            msgDict.setValue(self.channel_id, forKey: "channel_id")
            let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Location", key: ENCRYPT_KEY)
            let encryptedLat = cryptLib.encryptPlainTextRandomIV(withPlainText:"\(location.coordinate.latitude)", key: ENCRYPT_KEY)
            let encryptedLon = cryptLib.encryptPlainTextRandomIV(withPlainText:"\(location.coordinate.longitude)", key: ENCRYPT_KEY)
            
            msgDict.setValue(encryptedLat, forKey: "lat")
            msgDict.setValue(encryptedLon, forKey: "lon")
            msgDict.setValue("location", forKey: "message_type")
            
            msgDict.setValue(encryptedMsg, forKey: "message")
            channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
            self.addChannelMsgToLocal(channel_id: channel_id, requestDict: msgDict)
        }else{
            self.socketrecoonect()
        }
    }
    //MARK: ***************** DOCUMENT PICKER METHODS *********************
    
    @IBAction func fileBtnTapped(_ sender: Any) {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if Utility.shared.isConnectedToNetwork() {
        if socket.status == .connected{
            picDocument()
        }else{
            self.socketrecoonect()
        }
            
            
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    //MARK: pic document from docment drobox icloud
    func picDocument()  {
        let types: NSArray = NSArray.init(objects: kUTTypePDF,kUTTypeText)
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as! [String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    //MARK: Document picker delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // you get from the urls parameter the urls from the files selected
        let fileData = NSData.init(contentsOf: URL.init(string: "\(urls[0])")!)
        let fileName = urls[0].lastPathComponent
        
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("channel", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
        
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.channelNameLbl.text, forKey: "channel_name")
        msgDict.setValue(self.channel_id, forKey: "channel_id")
        msgDict.setValue("document", forKey: "message_type")
        
        let encryptedName = self.cryptLib.encryptPlainTextRandomIV(withPlainText:fileName, key: ENCRYPT_KEY)
        
        msgDict.setValue(encryptedName, forKey: "message")
        self.uploadFiles(msgDict: msgDict, attachData: fileData! as Data, type: ".\(urls[0].pathExtension)", image: nil)
    }
    
    @objc func addToContact(_ sender: UIButton!)  {
        let dict:channelMsgModel.message = msgArray.object(at: sender.tag) as! channelMsgModel.message
        if #available(iOS 9.0, *) {
            let store = CNContactStore()
            let contact = CNMutableContact()
            let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :"\(dict.country_code)\(dict.contact_no)"))
            contact.phoneNumbers = [homePhone]
            contact.namePrefix = dict.contact_name
            let controller = CNContactViewController(forUnknownContact : contact)
            controller.contactStore = store
            controller.delegate = self
            controller.modalPresentationStyle = .fullScreen
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    @IBAction func supportedLanguageBtnTapped(_ sender: Any) {
        let languageObj =  ChooseLanguage()
        languageObj.viewType = "translate"
        languageObj.modalPresentationStyle = .fullScreen
        self.navigationController?.present(languageObj, animated: true, completion: nil)
    }
    
    @objc func translateBtnTapped(_ sender: UIButton!)  {
        let model:channelMsgModel.message = msgArray.object(at: sender.tag) as! channelMsgModel.message
        print(model)
        
        Utility.shared.translate(msg: model.message, callback: { translatedTxt in
            print("translated text \(translatedTxt)")
            DispatchQueue.main.async {
                let newModel = channelMsgModel.message.init(message_id: model.message_id,
                                                            channel_id: model.channel_id,
                                                            message_type: model.message_type,
                                                            message: translatedTxt,
                                                            timestamp: model.timestamp,
                                                            lat: model.lat,
                                                            lon: model.lon,
                                                            contact_name: model.contact_name,
                                                            contact_no: model.contact_no,
                                                            country_code: model.country_code,
                                                            attachment: model.attachment,
                                                            thumbnail: model.thumbnail,
                                                            isDownload: model.isDownload,
                                                            local_path: model.local_path,
                                                            date: model.date,
                                                            admin_id: model.admin_id,
                                                            translated_status: "1",
                                                            translated_msg: translatedTxt, msg_date: model.msg_date)
                
                self.channelDB.updateTranslated(msg_id: model.message_id, msg: translatedTxt)
                self.msgArray.removeObject(at: sender.tag)
                self.msgArray.insert(newModel, at: sender.tag)
                self.msgTableView.reloadData()
            }
        })
    }
    
    //MARK: ***************** CONTACT PICKER METHODS *********************
    @IBAction func contactBtnTapped(_ sender: Any) {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if Utility.shared.isConnectedToNetwork() {
            
            if socket.status == .connected{
                requestForAccess { (accessGranted) in
                    if accessGranted == true{
                        self.contactPicker.modalPresentationStyle = .fullScreen
                        self.present(self.contactPicker,animated: true, completion: nil)
                    }
                }
            }else{
                self.socketrecoonect()
            }
            
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
        
    }
    // Ask contact access permisssion
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    contactPermissionApproved = true
                    completionHandler(access)
                }else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async{
                            self.contactPermissionAlert()
                        }
                    }
                }
            })
        default:
            completionHandler(false)
        }
    }
    //MARK:contact restriction alert
    func contactPermissionAlert()  {
        AJAlertController.initialization().showAlert(aStrMessage: "contact_permission", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    // MARK: contact picker view delegate
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        if socket.status == .connected{
            
            if contact.isKeyAvailable(CNContactPhoneNumbersKey){
                if contact.phoneNumbers.count != 0  {
                    // handle the selected contact
                    let msgDict = NSMutableDictionary()
                    let msg_id = Utility.shared.random()
                    msgDict.setValue("channel", forKey: "chat_type")
                    msgDict.setValue(msg_id, forKey: "message_id")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
                    
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    msgDict.setValue(self.channelNameLbl.text, forKey: "channel_name")
                    msgDict.setValue(self.channel_id, forKey: "channel_id")
                    msgDict.setValue("contact", forKey: "message_type")
                    let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Contact", key: ENCRYPT_KEY)
                    let encryptedName = cryptLib.encryptPlainTextRandomIV(withPlainText:contact.givenName, key: ENCRYPT_KEY)
                    
                    msgDict.setValue(encryptedMsg, forKey: "message")
                    msgDict.setValue(encryptedName, forKey: "contact_name")
                    if contact.phoneNumbers.count == 1 {
                        
                        
                        if socket.status == .connected{
                            
                            let encryptedNo = cryptLib.encryptPlainTextRandomIV(withPlainText:(contact.phoneNumbers[0].value).value(forKey: "digits") as? String, key: ENCRYPT_KEY)
                            msgDict.setValue(encryptedNo, forKey: "contact_phone_no")
                            channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
                            self.addChannelMsgToLocal(channel_id: self.channel_id, requestDict: msgDict)
                        }else{
                            self.socketrecoonect()
                        }
                    }
                    else {
                         if socket.status == .connected{
                        let contactVal = ContactModel()
                        contactVal.contactName = contact.givenName
                        for val in contact.phoneNumbers {
                            //                    (contact.phoneNumbers[0].value).value(forKey: "digits") as? String
                            contactVal.contactNumber.append(val.value.value(forKey: "digits") as? String ?? "")
                        }
                        let pageObj = ContactPickerViewController()
                        pageObj.contactVal = contactVal
                        pageObj.refreshContact = { selected in
                            let encryptedno = self.cryptLib.encryptPlainTextRandomIV(withPlainText: selected, key: ENCRYPT_KEY)
                            msgDict.setValue(encryptedno, forKey: "contact_phone_no")
                            channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
                            self.addChannelMsgToLocal(channel_id: self.channel_id, requestDict: msgDict)
                        }
                        self.navigationController?.pushViewController(pageObj, animated: true)
                    }else{
                        self.socketrecoonect()
                    }
                    }
                }
                else {
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_number") as? String)
                }
            }
        }else{
            self.socketrecoonect()
        }
        
        
        
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        // print("Cancelled picking a contact")
        
    }
    //MARK: ***************** IMAGE/VIDEO PICKER METHODS *********************
    //MARK: Attachment actions
    @IBAction func cameraBtnTapped(_ sender: Any) {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            self.openCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.openCamera()
                } else {
                    //access denied
                    DispatchQueue.main.async{
                        self.cameraPermissionAlert()
                    }
                }
            })
        }
        
    }
    
    func openCamera()  {
        //access allowed
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if Utility.shared.isConnectedToNetwork() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.galleryType = "1"
                let imagePicker = UIImagePickerController()
                //                imagePicker.mediaTypes = ["public.image", "public.movie"]
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                imagePicker.modalPresentationStyle = .fullScreen
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //MARK:contact restriction alert
    func cameraPermissionAlert()  {
        AJAlertController.initialization().showAlert(aStrMessage: "camera_permission", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    @IBAction func galleryBtnTapped(_ sender: Any) {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if Utility.shared.isConnectedToNetwork() {
            
            if socket.status == .connected{
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.galleryType = "2"
                let imagePicker = UIImagePickerController()
                imagePicker.mediaTypes = ["public.image", "public.movie"]
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = false
                imagePicker.modalPresentationStyle = .fullScreen
                self.present(imagePicker, animated: true, completion: nil)
            }
        }else{
            self.socketrecoonect()
        }
            
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("channel", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.channelNameLbl.text, forKey: "channel_name")
        msgDict.setValue(self.channel_id, forKey: "channel_id")
        
        var attachData = Data()
        var type =  String()
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                // print("infor \(info)")
                attachData = image.jpegData(compressionQuality: 0.1)!//UIImageJPEGRepresentation(image, 0.5)!
                if galleryType == "1"{
                    type = ".jpg"
                }else{
                    let assetPath = info[UIImagePickerController.InfoKey.imageURL] as! NSURL
                    if (assetPath.absoluteString?.hasSuffix("JPG"))! {
                        type = ".jpg"
                    } else if (assetPath.absoluteString?.hasSuffix("PNG"))! {
                        type = ".png"
                    }else if (assetPath.absoluteString?.hasSuffix("jpeg"))! {
                        type = ".jpeg"
                    }
                }
                msgDict.setValue("image", forKey: "message_type")
                let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:"Image", key: ENCRYPT_KEY)
                
                msgDict.setValue(encryptedMsg, forKey: "message")
                self.uploadFiles(msgDict: msgDict, attachData: attachData, type: type, image: image)
            }
            
            if mediaType == "public.movie" {
                if let fileURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
                    //                    if (fileURL.absoluteString?.hasSuffix("MOV"))! {
                    //                        type = ".mov"
                    //                    } else {
                    type = ".mp4"
                    //                    }
                    let videoData = NSData.init(contentsOf: fileURL as URL)
                    
                    let size = Float((videoData?.length)!) / 1024.0 / 1024.0
                    if Int(size.rounded()) < UPLOAD_SIZE {
                        msgDict.setValue("video", forKey: "message_type")
                        let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:"Video", key: ENCRYPT_KEY)
                        
                        msgDict.setValue(encryptedMsg, forKey: "message")
                        self.uploadThumbnail(msgDict: msgDict, attachData: videoData! as Data, fileURL: fileURL, type: type)
                        
                        let videoName:String = fileURL.lastPathComponent!
                        DispatchQueue.global(qos: .background).async {
                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                            let filePath="\(documentsPath)/\(videoName)"
                            DispatchQueue.main.async {
                                videoData?.write(toFile: filePath, atomically: true)
                                if self.galleryType == "1"{
                                    
                                    PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: msg_id, type: "channel")
                                }
                            }
                        }
                    }else{
                        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: Utility.shared.getLanguage()?.value(forKey: "file_size") as! String, completion: { (index, title) in
                            self.dismiss(animated:true, completion: nil)
                        })
                    }
                    
                }
            }
        }
    }
    //MARK: image picker delegate
    
    //upload video thumbnail
    func uploadThumbnail(msgDict: NSDictionary, attachData: Data,fileURL:NSURL,type:String)  {
        if Utility.shared.isConnectedToNetwork() {
            let image = Utility.shared.thumbnailForVideoAtURL(url: fileURL as URL)
            let thumbData = image?.jpegData(compressionQuality: 0.5)//UIImageJPEGRepresentation(image!, 0.5)!
            let uploadObj = UploadServices()
            uploadObj.uploadChannelFiles(fileData: thumbData!, type: ".jpg", channel_id: self.channel_id, docuName: msgDict.value(forKey: "message") as! String, msg_id: msgDict.value(forKey: "message_id") as! String, onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    print("thumbnail response \(response)")
                    let encryptedThumbnail = self.cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                    
                    msgDict.setValue(encryptedThumbnail, forKey: "thumbnail")
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue(EMPTY_STRING, forKey: "attachment")
                    msgDict.setValue("2", forKey: "isDownload")
                    channelSocket.sharedInstance.uploadChatVideo(fileData: attachData, type: type, msg_id:  msgDict.value(forKey: "message_id") as! String,channel_id:self.channel_id ,requestDict: msgDict)
                    self.addChannelMsgToLocal(channel_id: self.channel_id, requestDict: msgDict)
                    self.channelDB.updateChannelMediaDownload(msg_id: msgDict.value(forKey: "message_id") as! String, status: "2")
                }
            })
            dismiss(animated:true, completion: nil)
        }else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
        
    }
    
    
    //upload files
    func uploadFiles(msgDict:NSDictionary,attachData:Data,type:String,image:UIImage?){
        if Utility.shared.isConnectedToNetwork() {
            
            if socket.status == .connected{
            
            let uploadObj = UploadServices()
            let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText:msgDict.value(forKey: "message") as? String, key: ENCRYPT_KEY)!
            
            uploadObj.uploadChannelFiles(fileData: attachData, type: type, channel_id: self.channel_id, docuName: decryptedMsg, msg_id: msgDict.value(forKey: "message_id") as! String, onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    let encryptedAttachment = self.cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                    
                    msgDict.setValue(encryptedAttachment, forKey: "attachment")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue("0", forKey: "isDownload")
                    //send socket
                    channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
                    self.addChannelMsgToLocal(channel_id: self.channel_id, requestDict: msgDict)
                    
                    //check if photo is already exists in gallery
                    let msgType:String = msgDict.value(forKey: "message_type") as! String
                    if msgType == "image"{
                        if msgDict.value(forKey: "local_path") != nil{
                            if !PhotoAlbum.sharedInstance.checkExist(identifier: msgDict.value(forKey: "local_path") as! String)!{
                                if self.galleryType == "1"{
                                    PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "single")
                                }
                            }else{
                                self.channelDB.updateChannelMediaLocalURL(msg_id: msgDict.value(forKey: "message_id") as! String, url: msgDict.value(forKey: "local_path") as! String)
                            }
                        }else{
                            if self.galleryType == "1"{
                                PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "single")
                            }
                        }
                    }
                }
            })
            dismiss(animated:true, completion: nil)
            
            
        }else{
            self.socketrecoonect()
        }
            
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //socket delegate
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "receivechat" {
            let sender_id:String = dict.value(forKey: "sender_id") as! String
            let userDict = localDB.getContact(contact_id: sender_id)
            let imageName:String = userDict.value(forKey: "user_image") as! String
            let url = URL.init(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)")
            //            let data = NSData.init(contentsOf: url!)
            //            let image = UIImage(data : data! as Data)
            //            localNotify.show(withImage:image , title: userDict.value(forKey: "contact_name") as? String, message: dict.value(forKeyPath: "message_data.message") as? String, onTap: {
            //            })
        }
    }
    // socket group infor
    func gotGroupInfo(dict: NSDictionary, type: String) {
        print("AjmalAJ_6")

        
    }
    
    func gotChannelInfo(dict: NSDictionary, type: String) {
        print("channelinfote \(dict)")
        self.msgTableView.reloadData()
        if type == "channelUploadVideo"{
            let channel_id:String = dict.value(forKey: "channel_id") as! String
            let msg_id:String = dict.value(forKey: "message_id") as! String
            if channel_id == self.channel_id{
                self.scrollCount = 0
                self.replaceUpdatedMsg(msg_id: msg_id)
            }
        }else if type == "messagefromadminchannels"{
            let channel_id:String = dict.value(forKey: "channel_id") as! String
            let msgType:String = dict.value(forKey: "message_type") as! String
            if channel_id == self.channel_id{
                if msgType == "subject" || msgType == "channel_des" || msgType == "channel_image"{
                    self.channelDict = self.channelDB.getChannelInfo(channel_id: self.channel_id)
                    self.initialSetup()
                }else{
                    self.scrollCount = 0
                    var msg_id = String()
                    if dict.value(forKey: "message_id") == nil{
                        msg_id = dict.value(forKey: "_id") as! String
                    }else{
                        msg_id = dict.value(forKey: "message_id") as! String
                    }
                    
                    let cryptLib = CryptLib()
                    let msg:String = dict.value(forKey: "message") as! String
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText:msg, key: ENCRYPT_KEY)
                    //            smart replay add-on
//                    if member_id != UserModel.shared.userID()! as String{
//                        self.showSmartReplies(msg: decryptedMsg!)
//                    }
                    
                    if self.isTranslate{
                        //translate add-on
                        Utility.shared.translate(msg:decryptedMsg!, callback: { translatedTxt in
                            print("translated text \(translatedTxt)")
                            DispatchQueue.main.async {
                                self.channelDB.updateTranslated(msg_id:msg_id, msg: translatedTxt)
                                if !self.msgIDs.contains(msg_id){
                                    self.msgIDs.add(msg_id)
                                    let newMsg = self.channelDB.getChannelMsg(msg_id: msg_id)
                                    self.msgArray.add(newMsg!)
                                    self.tempMsgs?.add(newMsg!)
                                    self.msgTableView.reloadData()
                                    self.scrollToBottom()
                                }
                            }
                        })
                    }else{
                        if !msgIDs.contains(msg_id){
                            msgIDs.add(msg_id)
                            let newMsg = self.channelDB.getChannelMsg(msg_id: msg_id)
                            self.msgArray.add(newMsg!)
                            self.tempMsgs?.add(newMsg!)
                            self.msgTableView.reloadData()
                            self.scrollToBottom()
                        }
                    }
                    if msgType == "isDelete"{
                        self.replaceUpdatedMsg(msg_id: msg_id)
                    }
                    if !self.downView.isHidden {
                        self.newMsgView.isHidden = false
                    }else{
                        if self.msgArray.count != 0 {
                            let indexPath = IndexPath(row: self.msgArray.count-1, section: 0)
                            self.msgTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        }
                    }
                }
            }
        }else if type == "deletechannel"{
            let channel_id:String = dict.value(forKey: "channel_id") as! String
            if channel_id == self.channel_id{
                self.navigationController?.popViewController(animated: true)
            }
        }else if type == "refreshChannel"{
            self.scrollCount = 0
            self.refresh(scroll: true)
        }else if type == "channel_modified"{
            
        }
    }
    /********* ************  Voice message sending ********************/
    
    //MARK: - Check Mic Permission ------------->
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
            // print("recorded successfully.")
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
                //setCategory(AVAudioSession.Category.playAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        else{
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    func getFileUrl() -> URL
    {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func UploadAudioToServer() {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("channel", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.channelNameLbl.text, forKey: "channel_name")
        msgDict.setValue(self.channel_id, forKey: "channel_id")
        
        
        let result = PHAsset.fetchAssets(withALAssetURLs: [getFileUrl()], options: nil)
        msgDict.setValue(result.firstObject?.localIdentifier, forKey: "local_path")
        let videoData = NSData.init(contentsOf: getFileUrl() as URL)
        
        
        msgDict.setValue("audio", forKey: "message_type")
        msgDict.setValue("audio", forKey: "message")
        var type =  String()
        if (getFileUrl().absoluteString.hasSuffix("m4a")) {
            type = ".m4a"
        } else {
            type = ".mp3"
        }
        
        self.uploadAudio(msgDict: msgDict, attachData: videoData! as Data, type: type)
        // socketClass.sharedInstance.uploadaudioFiles(msgDict: msgDict, requestDict: requestDict, attachData: videoData! as Data, type:type,msg_id: msgDict.value(forKey: "message_id") as! String)
    }
    
    // MARK: - upload Audio Files ------>
    
    func uploadAudio(msgDict: NSDictionary, attachData: Data,type:String)  {
        if Utility.shared.isConnectedToNetwork() {
            
            if socket.status != .connected{
                socketClass.sharedInstance.connect()
            }
            if socket.status == .connected{
                
                let uploadObj = UploadServices()
                uploadObj.uploadChannelFiles(fileData: attachData, type: ".m4a", channel_id: self.channel_id, docuName: msgDict.value(forKey: "message") as! String, msg_id: msgDict.value(forKey: "message_id") as! String, onSuccess: {response in
                    let status:String = response.value(forKey: "status") as! String
                    if status == STATUS_TRUE{
                        
                        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                        let encryptedAttachment = self.cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                        msgDict.setValue(encryptedAttachment, forKey: "attachment")
                        msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                        msgDict.setValue("0", forKey: "isDownload")
                        //send socket
                        channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
                        self.addChannelMsgToLocal(channel_id: self.channel_id, requestDict: msgDict)
                        self.scrollCount = 0
                        self.refresh(scroll: true)
                    }
                })
                dismiss(animated:true, completion: nil)
            }else{
                self.socketrecoonect()
                
            }
        }else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
        
    }
    /*
     message
     - message_id : "5c6f8a6994b47367040c9c79p27yqg4SjJ"
     - channel_id : "5c70dc03ba05934512bb4e5c"
     - message_type : "voice"
     - message : "Voice"
     - timestamp : "1550914036"
     - lat : ""
     - lon : ""
     - contact_name : ""
     - contact_no : ""
     - country_code : ""
     - attachment : "channel_attachment-1550914035906.m4a"
     - thumbnail : ""
     - isDownload : "1"
     - local_path : "0"
     - date : "23 Feb 2019"
     - admin_id : "5c6f8a6994b47367040c9c79"
     */
    func stopAudioPlayer() {
        let dict:channelMsgModel.message = msgArray.object(at: tag_value) as! channelMsgModel.message
        let sender_Tag_id:String = dict.admin_id
        let own_id:String = UserModel.shared.userID()! as String
        audioPlayer.currentTime = TimeInterval(0)
        if sender_Tag_id != own_id {
            let cell1 = view.viewWithTag(tag_value + 8000) as? ReceiverVoiceCell
            audioPlayer.stop()
            self.timer.invalidate()
            cell1?.playerImg.image = UIImage(named:"play_receive.png")
            cell1?.audioProgress.value = Float(audioPlayer.currentTime)
            cell1?.PlayerBtn.clipsToBounds = true
            cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
        }
        else {
            let cell1 = view.viewWithTag(tag_value + 7000) as? SenderAudioCell
            audioPlayer.stop()
            self.timer.invalidate()
            cell1?.playerImg.image = UIImage(named:"play_audio.png")
            cell1?.audioProgress.value = Float(audioPlayer.currentTime)
            cell1?.PlayerBtn.clipsToBounds = true
            cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
            
        }
    }
    @objc func audioCellBtnTapped(_ sender: UIButton!)  {
        if Utility.shared.isConnectedToNetwork(){
            let model:channelMsgModel.message = msgArray.object(at: sender.tag) as! channelMsgModel.message
            // print(model)
            //let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
            if self.selectedIdArr.count == 0 {
                let sender_id:String = model.admin_id
                let own_id:String = UserModel.shared.userID()! as String
                let updatedModel = self.channelDB.getChannelMsg(msg_id: model.message_id)
                var videoName:String = updatedModel!.local_path
                //                if videoName == "0"{
                videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
                //                }
                let videoURL = URL.init(string: videoName)
                
                if tag_value != sender.tag && counter != 0 {
                    self.stopAudioPlayer()
                }
                if sender_id != own_id{
                    //check its downloaded
                    if model.isDownload == "0" {
                        //                        self.downloadVideo(index: sender.tag, model: model)
                        self.downloadaudiofromserver(index: sender.tag, model: model)
                        //                        self.dowloadAudioFile(index:sender.tag,audioString:videoName, message: message ?? "audio", model :model)
                        
                    }
                    else if model.isDownload == "1" || model.isDownload == "2"
                    {
                        //if !audioPlayer.isPlaying || audioPlayer == nil {
                        if let audioUrl = URL(string: videoName) {
                            
                            // then lets create your document folder url
                            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            
                            // lets create your destination file url
                            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                            
                            do {
                                //  let msg_id = msgDict.value(forKeyPath:"message_data.message_id") as! String
                                if currentAudioMsgID.isEmpty || currentAudioMsgID != model.message_id {
                                    let data = try Data(contentsOf: destinationUrl)
                                    audioPlayer = try AVAudioPlayer.init(data: data)
                                    audioPlayer.prepareToPlay()
                                    currentAudioMsgID = model.message_id
                                    //                                    currentAudioURL = destinationUrl
                                }
                                
                                
                                let cell = view.viewWithTag(sender.tag + 8000) as? ReceiverVoiceCell
                                let maximumvalue:Double = audioPlayer.duration
                                //duration(for: videoName)
                                let int_value:Int = Int(maximumvalue)
                                
                                
                                cell?.audioProgress?.minimumValue = 0
                                cell?.audioProgress?.maximumValue = Float(int_value)
                                str_value_tofind_which_voiceCell = "ReceiverVoiceCell"
                                if counter == 0 {
                                    dowloadFile(audioString: videoName)
                                    audioPlayer.play()
                                    cell?.playerImg.image = UIImage(named:"pause_receive.png")
                                    //cell?.PlayerBtn.setImage(UIImage(named:"pause_receive.png"), for: UIControlState.normal)
                                    let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
                                    // print(normalizedTime)
                                    //                                    cell?.audioProgress.value = normalizedTime
                                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer), userInfo: nil, repeats: true)
                                    //cell?.audioProgress.value = Float(audioPlayer.currentTime)
                                    cell?.audioProgress.clipsToBounds = true
                                    cell?.PlayerBtn.clipsToBounds = true
                                    tag_value = sender.tag
                                    counter = 1
                                }
                                else if tag_value == sender.tag {
                                    audioPlayer.stop()
                                    self.timer.invalidate()
                                    cell?.playerImg.image = UIImage(named:"play_receive.png")
                                    cell?.audioProgress.value = Float(audioPlayer.currentTime)
                                    cell?.PlayerBtn.clipsToBounds = true
                                    counter = 0
                                }
                                else {
                                    if (cell?.audioProgress.value ?? 0) != 0 {
                                        let audioValue = cell?.audioProgress.value
                                        audioPlayer.currentTime = Double(audioValue ?? 0) //* audioPlayer.duration / 100 // audioPlayer.currentTime * 100.0 / audioPlayer.duration
                                    }
                                    // print(audioPlayer.currentTime)
                                    audioPlayer.play()
                                    cell?.playerImg.image = UIImage(named:"pause_receive.png")
                                    //cell?.PlayerBtn.setImage(UIImage(named:"pause_audio.png"), for: UIControlState.normal)
                                    let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
                                    // print(normalizedTime)
                                    //cell?.audioProgress.value = normalizedTime
                                    cell?.PlayerBtn.clipsToBounds = true
                                    tag_value = sender.tag
                                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer), userInfo: [cell?.audioProgress.tag ?? 0], repeats: true)
                                    
                                    counter = 1
                                }
                            } catch let error {
                                // print(error.localizedDescription)
                            }
                        }
                        
                    }
                }else{
                    if model.isDownload == "0" {
                        
                        if let audioUrl = URL(string: videoName) {
                            
                            
                            // then lets create your document folder url
                            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            
                            // lets create your destination file url
                            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                            
                            //let url = Bundle.main.url(forResource: destinationUrl, withExtension: "mp3")!
                            
                            do {
                                //let msg_id = msgDict.value(forKeyPath:"message_data.message_id") as! String
                                if currentAudioMsgID.isEmpty || currentAudioMsgID != model.message_id {
                                    let data = try Data(contentsOf: destinationUrl)
                                    audioPlayer = try AVAudioPlayer.init(data: data)
                                    audioPlayer.prepareToPlay()
                                    currentAudioMsgID = model.message_id
                                }
                                
                                let maximumvalue:Double = audioPlayer.duration
                                //duration(for: videoName)
                                
                                let int_value:Int = Int(maximumvalue)
                                
                                let cell = view.viewWithTag(sender.tag + 7000) as? SenderAudioCell
                                cell?.audioProgress?.minimumValue = 0
                                cell?.audioProgress?.maximumValue = Float(int_value)
                                str_value_tofind_which_voiceCell = "SenderAudioCell"
                                if counter == 0 {
                                    dowloadFile(audioString: videoName)
                                    audioPlayer.play()
                                    cell?.playerImg.image = UIImage(named:"pause_audio.png")
                                    //cell?.PlayerBtn.setImage(UIImage(named:"pause_audio.png"), for: UIControlState.normal)
                                    
                                    let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
                                    // print(normalizedTime)
                                    //                                    cell?.audioProgress.value = normalizedTime
                                    
                                    cell?.PlayerBtn.clipsToBounds = true
                                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer), userInfo: nil, repeats: true)
                                    
                                    tag_value = sender.tag
                                    counter = 1
                                } else if tag_value == sender.tag {
                                    audioPlayer.stop()
                                    self.timer.invalidate()
                                    cell?.playerImg.image = UIImage(named:"play_audio.png")
                                    cell?.audioProgress.value = Float(audioPlayer.currentTime)
                                    cell?.audioProgress.clipsToBounds = true
                                    cell?.PlayerBtn.clipsToBounds = true
                                    counter = 0
                                    
                                }else {
                                    if (cell?.audioProgress.value ?? 0) != 0 {
                                        let audioValue = cell?.audioProgress.value
                                        audioPlayer.currentTime = Double(audioValue ?? 0) //* audioPlayer.duration / 100 // audioPlayer.currentTime * 100.0 / audioPlayer.duration
                                    }
                                    audioPlayer.play()
                                    cell?.playerImg.image = UIImage(named:"pause_audio.png")
                                    cell?.PlayerBtn.clipsToBounds = true
                                    tag_value = sender.tag
                                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer), userInfo: [cell?.audioProgress.tag ?? 0], repeats: true)
                                    counter = 1
                                }
                                
                            } catch _ {
                                // print(error.localizedDescription)
                            }
                        }
                        
                        
                    }else if model.isDownload == "4"{//cancelled
                        
                        if Utility.shared.isConnectedToNetwork(){
                            let msg_id:String = model.message_id
                            self.localDB.updateDownload(msg_id: msg_id, status: "0")
                            self.textMsgSize()
                            self.infoHeight()
                            self.scrollCount = 1
                            self.msgTableView.reloadData()
                            //                            PhotoAlbum.sharedInstance.getVideo(local_ID: videoURL!, msg_id: msg_id, requestData: updatedDict,type:(videoURL?.pathExtension)!)
                        } else{
                            self.messageTextView.resignFirstResponder()
                            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
                        }
                    }
                }
                //  }
            }else{
                
                let type:String = model.message_type
                let indexpath = IndexPath.init(row: sender.tag, section: 0)
                self.makeSelection(tag: sender.tag, type: type, index: indexpath)
            }
            
        }
        else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
        
    }
    
    func duration(for resource: String) -> Double {
        let asset = AVURLAsset(url: URL(fileURLWithPath: resource))
        return Double(CMTimeGetSeconds(asset.duration))
    }
    //Mark: download Audio and store the audio to local path -------------------------->
    
    
    func dowloadFile(audioString:String)  {
        
        if let url = URL.init(string:audioString){
            
            // if let audioUrl = URL(string: "http://freetone.org/ring/stan/iPhone_5-Alarm.mp3") {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
            // print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                // print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        // print("File moved to documents folder \(destinationUrl)")
                    } catch _ as NSError {
                        // print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    //Mark:downloadaudiofromServer ------------------------------------------->
    
    func downloadaudiofromserver(index:Int, model :channelMsgModel.message)  {
        
        self.channelDB.updateChannelMediaDownload(msg_id: model.message_id, status: "2")
        let cell = view.viewWithTag(index + 8000) as! ReceiverVoiceCell
        cell.loader.play()
        cell.loader.isHidden = false
        cell.downloadIcon.isHidden = true
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"),
               let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(model.attachment)"
                // print("file path \(filePath)")
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: model.message_id,type:"channel")
                    
                    self.channelDB.updateChannelMediaDownload(msg_id: model.message_id, status: "1")
                    self.scrollCount = 1
                    //                    DispatchQueue.main.async {
                    self.replaceUpdatedMsg(msg_id: model.message_id)
                    cell.loader.play()
                    self.msgTableView.reloadData()
                    
                    //                    }
                    
                }
            }
        }
        
    }
    
    @objc func updateUIWithTimer(){
        
        if str_value_tofind_which_voiceCell == "SenderAudioCell" {
            let cell = view.viewWithTag(tag_value + 7000) as? SenderAudioCell
            let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
            // print(normalizedTime)
            if normalizedTime == 0.0 {
                self.timer.invalidate()
                cell?.audioProgress.value = normalizedTime
                let currentTime = Int(audioPlayer.duration)
                let minutes = currentTime/60
                let seconds = currentTime - minutes * 60
                currentAudioMsgID = ""
                if counter != 0 {
                    counter = 0
                }
                self.audioPlayer.stop()
                cell?.audioTimeLbl.text = NSString(format: "%02d:%02d", minutes,seconds) as String
                cell?.playerImg.image = UIImage(named:"play_audio.png")
            }else{
                cell?.audioProgress.value = Float(audioPlayer.currentTime)
                let currentTime = Int(audioPlayer.currentTime)
                let minutes = currentTime/60
                let seconds = currentTime - minutes * 60
                if counter != 0 {
                    cell?.playerImg.image = UIImage(named:"pause_audio.png")
                }
                cell?.audioTimeLbl.text = NSString(format: "%02d:%02d", minutes,seconds) as String
            }
            cell?.audioProgress.clipsToBounds = true
            
        }else if str_value_tofind_which_voiceCell == "ReceiverVoiceCell"{
            let cell = view.viewWithTag(tag_value + 8000) as? ReceiverVoiceCell
            
            cell?.audioProgress.value = Float(audioPlayer.currentTime)
            let currentTime = Int(audioPlayer.currentTime)
            let minutes = currentTime/60
            let seconds = currentTime - minutes * 60
            
            let time = NSString(format: "%02d:%02d", minutes,seconds) as String
            cell?.audioTimeLbl.text = time
            
            let fullDuration = Int(audioPlayer.duration)
            let durationMinutes = fullDuration/60
            let durationSeconds = fullDuration - durationMinutes * 60
            let duration = NSString(format: "%02d:%02d", durationMinutes,durationSeconds) as String
            if time == duration{
                self.timer.invalidate()
                cell?.audioProgress.value = 0.0
                let currentTime = Int(audioPlayer.currentTime)
                let minutes = currentTime/60
                let seconds = currentTime - minutes * 60
                currentAudioMsgID = ""
                if counter != 0 {
                    counter = 0
                }
                let time = NSString(format: "%02d:%02d", minutes,seconds) as String
                cell?.audioTimeLbl.text = time
                cell?.playerImg.image = UIImage(named:"play_receive.png")
            }
            
            audioPlayer.updateMeters()
            cell?.audioProgress.clipsToBounds = true
            
        }
        
    }
    
    @objc func respondToSlideEvents(sender: UISlider) {
        let currentValue: Float = Float(sender.value)
        // print("Event fired. Current value for slider: \(currentValue)%.")
        
        if str_value_tofind_which_voiceCell == "SenderAudioCell" {
            audioPlayer.currentTime = TimeInterval(currentValue)
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateUIWithTimer), userInfo:nil, repeats:true)
        }
        else if str_value_tofind_which_voiceCell == "ReceiverVoiceCell"{
            audioPlayer.currentTime = TimeInterval(currentValue)
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateUIWithTimer), userInfo:nil, repeats:true)
        }
    }
    
    //MARK: - Cutom Alert show ------->
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    func ConfigVoiceBtn(enable:Bool)
    {
        if(enable){
            self.record_btn_ref.isUserInteractionEnabled = true
            self.record_btn_ref.isHidden = false
        }
        else {
            self.record_btn_ref.isUserInteractionEnabled = false
            self.record_btn_ref.isHidden = true
        }
    }
    
}
extension ChannelChatPage: RecordViewDelegate {
    func onStart() {
        self.navigationView.isUserInteractionEnabled = false

        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        // print("begin")
        self.recorderView.isHidden = false
        self.attachmentIconView.isHidden = true
        if(isAudioRecordingGranted) {
            if(!isRecording)
            {
                do {
                    audioPlayer_VoiceRecord = try AVAudioPlayer(contentsOf: VoiceRecordingSound as URL)
                    audioPlayer_VoiceRecord.play()
                } catch {
                    // print(error.localizedDescription)
                }
                
                messageTextView.isHidden = true
                setup_recorder()
                audioRecorder.record()
                isRecording = true
            }
        }
        else {
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "microphone_alert") as? String)
        }
    }
    
    func onCancel() {
        if(isRecording){
            if(audioRecorder.isRecording){
                audioRecorder.stop()
                audioRecorder.deleteRecording()
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        isRecording = false
        self.navigationView.isUserInteractionEnabled = true

    }
    func updateDuration(duration: CGFloat) {
        recordView.timeLabelText = duration.SecondsFromTimer()
    }
    func onFinished(duration: CGFloat) {
        self.recorderView.isHidden = true
        self.attachmentIconView.isHidden = false
        // print("end end")
        finishAudioRecording(success: true)
        if(isRecording)
        {
            ishold = true
            messageTextView.isHidden = false
            isRecording = false
            
            if(duration > 0.0){
                self.UploadAudioToServer()
            }
            else {
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "hold_voice") as? String)
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        self.navigationView.isUserInteractionEnabled = true

    }
    
    func onAnimationEnd() {
        //when Trash Animation is Finished
        self.recorderView.isHidden = true
        self.attachmentIconView.isHidden = false
        isSwipeCalled = true
        messageTextView.isHidden = false
        
        print("onAnimationEnd")
    }
    
}
// MARK: - UITABLEVIEW

extension ChannelChatPage{
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.msgArray.count
    }
    func infoHeight() {
        self.infoSizeArr.removeAll()
        for i in 0..<self.msgArray.count {
            let model:channelMsgModel.message = msgArray.object(at: i) as! channelMsgModel.message
            let msg:String = model.message
            
            heightForView(text: msg, font: UIFont.init(name:APP_FONT_REGULAR, size: 15)!, isDelete: 0) { (value) in
                var val = value
                if model.message_type == "added" {
                    self.heightForView(text: Utility.shared.getLanguage()?.value(forKey: "subject_changed") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0, onSuccess: { (value) in
                        val = value
                        self.infoSizeArr.append(30 + val.height)
                    })
                }else if model.message_type == "channel_image"{
                    self.heightForView(text: Utility.shared.getLanguage()?.value(forKey: "channel_icon_changed") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0, onSuccess: { (value) in
                        val = value
                        self.infoSizeArr.append(30 + val.height)
                    })
                }else if model.message_type == "channel_des"{
                    self.heightForView(text: Utility.shared.getLanguage()?.value(forKey: "channel_icon_changed") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0, onSuccess: { (value) in
                        val = value
                        self.infoSizeArr.append(30 + val.height)
                    })
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model:channelMsgModel.message = msgArray.object(at: indexPath.row) as! channelMsgModel.message
        
        let type:String = model.message_type
        let sender_id:String = model.admin_id
        let own_id:String = UserModel.shared.userID()! as String
        
        if type == "text" || type == "isDelete"{ // type text
            //            return self.textSizeArr[indexPath.row]
            return UITableView.automaticDimension
        }else if type == "image" || type == "gif"{ // type image
            return 150
        }else if type == "location"{ // type location
            return 150
        }else if type == "contact"{ // type contact
            if sender_id == own_id{
                return 95
            }
            else {
                return 125
            }
        }else if type == "video"{ // type video
            return 150
        }else if type == "document"{ // type document
            return 75
        }else if type == "audio"{ // type audio
            return 70
        }else if type == "date_sticky"{
            return 40
        }else if type == "added" || type == "subject" || type == "channel_image" || type == "channel_des"{
            
        }
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.msgArray.count == 0 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ChatDetailsSectionTableViewCell") as? ChatDetailsSectionTableViewCell
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.msgArray.count == 0 {
            return UITableView.automaticDimension
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var customcell = UITableViewCell()
        
        var model:channelMsgModel.message = msgArray.object(at: indexPath.row) as! channelMsgModel.message
        
        let type:String = model.message_type
        let sender_id:String = model.admin_id
        let own_id:String = UserModel.shared.userID()! as String
        if type == "text" || type == "isDelete"{ // type text
            let CellIdentifier = "TextCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! TextCell
            cell.sender_id = sender_id
            cell.own_id = own_id
            var deleteStatus = CGFloat(0)
            if type == "isDelete" {
                cell.deleteIcon.isHidden = false
                cell.statusStackView.isHidden = true
                deleteStatus = 20.0
                if sender_id == own_id {
                    model.message = "deleted_by_you"
                } else {
                    model.message = "deleted_by_others"
                }
            }else {
                cell.statusStackView.isHidden = false
                deleteStatus = 0
                cell.deleteIcon.isHidden = true
            }
            cell.translateBtn.tag = indexPath.row
            cell.translateBtn.addTarget(self, action: #selector(self.translateBtnTapped), for: .touchUpInside)
            cell.channelConfig(msgDict: model,chattype:self.createdBy)
            
            let val = heightForView(text: model.message, font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: deleteStatus)
            cell.labelWidth.constant = val.width
            let msg:String = model.message as? String ?? ""
            if isTranslate{
                if sender_id == own_id{
                    cell.translateBtn.isHidden = true
                }else{
                    if msg.containsEmoji() || type == "isDelete" {
                        cell.translateBtn.isHidden = true
                    } else {
                        cell.translateBtn.isHidden = false
                    }
                }
            }else{
                cell.translateBtn.isHidden = true
            }
       
            customcell = cell
            
        }else if type == "image"{ // type image
            if sender_id == own_id{
                let senderImgCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                senderImgCell.cellType = "image"
                senderImgCell.configChannelMsg(model: model)
                senderImgCell.imageBtn.tag = indexPath.row
                senderImgCell.imageBtn.addTarget(self, action: #selector(imageCellBtnTapped), for: .touchUpInside)
                customcell = senderImgCell
            }else{
                let receiverImgCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                receiverImgCell.cellType = "image"
                receiverImgCell.configChannelMsg(model: model, chatType: self.createdBy)
                receiverImgCell.tag = indexPath.row+50000
                receiverImgCell.imageBtn.tag = indexPath.row
                receiverImgCell.imageBtn.addTarget(self, action: #selector(imageCellBtnTapped), for: .touchUpInside)
                customcell = receiverImgCell
            }
            //            tableView.rowHeight = 150
        }else if type == "gif" {
            print("GIPHY LOADED")
            
            if sender_id == own_id{
                let senderImgCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                senderImgCell.cellType = "gif"
                senderImgCell.configChannelMsg(model: model)
                customcell = senderImgCell
            }else{
                let receiverImgCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                receiverImgCell.cellType = "gif"
                receiverImgCell.configChannelMsg(model: model, chatType: self.createdBy)
                customcell = receiverImgCell
            }
            
        }else if type == "location"{ // type location
            if sender_id == own_id{
                let senderLocObj = tableView.dequeueReusableCell(withIdentifier: "SenderLocCell", for: indexPath) as! SenderLocCell
                senderLocObj.configChannel(model: model)
                senderLocObj.locationBtn.tag = indexPath.row
                senderLocObj.locationBtn.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
                customcell = senderLocObj
            }else{
                let receiverLocObj = tableView.dequeueReusableCell(withIdentifier: "ReceiverLocCell", for: indexPath) as! ReceiverLocCell
                receiverLocObj.configChannel(model: model, chatType: self.createdBy)
                receiverLocObj.locationBtn.tag = indexPath.row
                receiverLocObj.locationBtn.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
                customcell = receiverLocObj
            }
            //            tableView.rowHeight = 150
        }else if type == "contact"{ // type contact
            if sender_id == own_id{
                let senderContactObj = tableView.dequeueReusableCell(withIdentifier: "SenderContact", for: indexPath) as! SenderContact
                senderContactObj.configChannel(model: model)
                customcell = senderContactObj
                //                tableView.rowHeight = 95
            }else{
                let receiverContactObj = tableView.dequeueReusableCell(withIdentifier: "ReceiverContact", for: indexPath) as! ReceiverContact
                receiverContactObj.configChannel(model:model, chatType: self.createdBy)
                receiverContactObj.contactAddBtn.tag = indexPath.row
                receiverContactObj.contactAddBtn.addTarget(self, action: #selector(addToContact), for: .touchUpInside)
                customcell = receiverContactObj
                //                tableView.rowHeight = 125
            }
        }else if type == "video"{ // type video
            if sender_id == own_id{
                let sendVideo = tableView.dequeueReusableCell(withIdentifier: "SenderVideoCell", for: indexPath) as! SenderVideoCell
                sendVideo.configChannel(model: model)
                sendVideo.videoBtn.tag = indexPath.row
                sendVideo.videoBtn.addTarget(self, action: #selector(videoCellBtnTapped), for: .touchUpInside)
                customcell = sendVideo
            }else{
                let receiveVideo = tableView.dequeueReusableCell(withIdentifier: "ReceiverVideoCell", for: indexPath) as! ReceiverVideoCell
                receiveVideo.configChannel(model: model, chatType: self.createdBy)
                receiveVideo.tag = indexPath.row+20000
                receiveVideo.videoBtn.tag = indexPath.row
                receiveVideo.videoBtn.addTarget(self, action: #selector(videoCellBtnTapped), for: .touchUpInside)
                customcell = receiveVideo
            }
            //            tableView.rowHeight = 150
        }else if type == "document"{ // type document
            if sender_id == own_id{
                let sendDoc = tableView.dequeueReusableCell(withIdentifier: "SenderDocuCell", for: indexPath) as! SenderDocuCell
                sendDoc.configChannel(model: model)
                sendDoc.docBtn.tag = indexPath.row
                sendDoc.docBtn.addTarget(self, action: #selector(docuCellBtnTapped), for: .touchUpInside)
                customcell = sendDoc
            }else{
                let receiveDocu = tableView.dequeueReusableCell(withIdentifier: "ReceiverDocuCell", for: indexPath) as! ReceiverDocuCell
                receiveDocu.configChannel(model: model, chatType: self.createdBy)
                receiveDocu.docBtn.tag = indexPath.row
                receiveDocu.docBtn.addTarget(self, action: #selector(docuCellBtnTapped), for: .touchUpInside)
                customcell = receiveDocu
            }
            //            tableView.rowHeight = 75
        }else if type == "audio"{ // type video
            if sender_id == own_id{
                let sendaudio = tableView.dequeueReusableCell(withIdentifier: "SenderAudioCell", for: indexPath) as! SenderAudioCell
                sendaudio.selectionStyle = UITableViewCell.SelectionStyle.none
                sendaudio.configChannel(model: model)
                sendaudio.tag = indexPath.row+7000
                sendaudio.PlayerBtn.tag = indexPath.row
                sendaudio.audioProgress.tag = indexPath.row
                sendaudio.audioProgress.addTarget(self, action: #selector(respondToSlideEvents), for: .valueChanged)
                sendaudio.PlayerBtn.addTarget(self, action: #selector(audioCellBtnTapped), for: .touchUpInside)
                customcell = sendaudio
            }else{
                let receiveAudio = tableView.dequeueReusableCell(withIdentifier: "ReceiverVoiceCell", for: indexPath) as! ReceiverVoiceCell
                receiveAudio.selectionStyle = UITableViewCell.SelectionStyle.none
                receiveAudio.configChannel(model: model, chatType: self.createdBy)
                receiveAudio.tag = indexPath.row+8000
                receiveAudio.PlayerBtn.tag = indexPath.row
                receiveAudio.audioProgress.tag = indexPath.row
                receiveAudio.audioProgress.addTarget(self, action: #selector(respondToSlideEvents), for: .valueChanged)
                receiveAudio.PlayerBtn.addTarget(self, action: #selector(audioCellBtnTapped), for: .touchUpInside)
                customcell = receiveAudio
            }
            
            //            tableView.rowHeight = 80
        }else if type == "date_sticky"{
            let dateSticky = tableView.dequeueReusableCell(withIdentifier: "dateStickyCell", for: indexPath) as! dateStickyCell
            
            let utcDate = Utility.shared.getSticky(date: model.date)
            let dateformat =  DateFormatter()
            //dateformat.locale = Locale(identifier: "en_US")
            dateformat.locale = Locale(identifier: "en_US_POSIX")
            
            dateformat.dateFormat = "dd MMM yyyy"
            
            let todayDateStr = dateformat.string(from: Date())
            let stickyStr = dateformat.string(from: utcDate)
            
            if todayDateStr == stickyStr  {
                dateSticky.dateLbl.attributedText = NSAttributedString.init(string: Utility.shared.getLanguage()?.value(forKey: "today") as? String ?? "Today")
            }else{
                dateSticky.dateLbl.attributedText = NSAttributedString.init(string: stickyStr)
            }
            if UserModel.shared.getAppLanguage() == "عربى" {
                dateSticky.dateLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            else {
                dateSticky.dateLbl.transform = .identity
            }
            customcell = dateSticky
            //            tableView.rowHeight = 40
        }else if type == "added" || type == "subject" || type == "channel_image" || type == "channel_des"{
            let info = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
            info.configChannel(model: model)
            customcell = info
            //            tableView.rowHeight = info.containerView.frame.size.height+20
        }else if type == "audio"{
            let audioCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverAudioCell", for: indexPath) as! ReceiverAudioCell
            audioCell.configChannel(model: model, chatType: self.createdBy)
            customcell = audioCell
            //            tableView.rowHeight = 70
        }
        if type != "date_sticky"{
            if self.selectedDict.contains(where: {$0.message_id == model.message_id}){
                customcell.backgroundColor = CHAT_SELECTION_COLOR
            }else{
                customcell.backgroundColor = .clear
            }
        }
        return customcell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.messageTextView.resignFirstResponder()
        let model:channelMsgModel.message = msgArray.object(at: indexPath.row) as! channelMsgModel.message
        let type:String = model.message_type
        if self.selectedIdArr.count != 0 {
            self.makeSelection(tag: indexPath.row, type: type, index: indexPath)
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
}

//MARK: UITEXTVIEW

extension ChannelChatPage{
    func textViewDidBeginEditing(_ textView: UITextView) {
        // print("called")
        self.attachmentMenuView.isHidden = true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if Utility.shared.checkEmptyWithString(value: textView.text!+text) {
            self.configSendBtn(enable: false)
            self.ConfigVoiceBtn(enable: true)
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            
        }else{
            if let char = text.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) && (textView.text.count == 1) {
                    self.configSendBtn(enable: false)
                    self.ConfigVoiceBtn(enable: true)
                    return true
                }
            }
            self.configSendBtn(enable: true)
            self.ConfigVoiceBtn(enable: false)
            
        }
        self.adjustContentSize(tv: textView)
        return true
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.bootomInputView.frame.origin.y += self.bootomInputView.frame.size.height
        self.bootomInputView.frame.size.height = height+20
        self.messageTextView.frame.size.height = height
        self.bootomInputView.frame.origin.y -= self.bootomInputView.frame.size.height
        self.messageTextView.frame.origin.y = 10
        self.msgTableView.frame.size.height -= 60
        self.msgTableView.frame.size.height = self.bootomInputView.frame.origin.y - self.navigationView.frame.size.height
    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
    
}

extension ChannelChatPage: noneDelegate{
    func forcheck(type: String){
        self.nonecheck(type: type)
    }
}
