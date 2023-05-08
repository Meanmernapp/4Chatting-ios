
//
//  ChatDetailPage.swift
//  Hiddy
//
//  Created by APPLE on 01/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import MapKit
import MobileCoreServices
import Contacts
import ContactsUI
import AVKit
import GSImageViewerController
import Photos
import Lottie
import AssetsLibrary
import GrowingTextView
import AVFoundation
import iRecordView
import IQKeyboardManagerSwift
import PhoneNumberKit
import Alamofire
import QuickLook
import TrueTime
import GiphyUISDK
import Firebase
import MLKitSmartReply
import Speech

class ChatDetailPage: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,fetchLocationDelegate,UIDocumentPickerDelegate,CNContactPickerDelegate,CNContactViewControllerDelegate,UIDocumentInteractionControllerDelegate,socketClassDelegate,alertDelegate,UIGestureRecognizerDelegate,forwardDelegate,GrowingTextViewDelegate,UITextViewDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate, deleteAlertDelegate, GiphyDelegate{
    
    
    
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var recorderView: UIView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet var camerBtn: UIButton!
    @IBOutlet var galleryBtn: UIButton!
    @IBOutlet var fileBtn: UIButton!
    @IBOutlet var locationBtn: UIButton!
    @IBOutlet var contactBtn: UIButton!
    @IBOutlet var downView: UIView!
    @IBOutlet var newMsgView: UIView!
    
    @IBOutlet var deleteAcLbl: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    let gifBtn = UIButton()
    var isKeyborad = false
    var keybordHeight = CGFloat()
    let quickLookController = QLPreviewController()
    var lastText = ""
    var localCallDB = CallStorage()
    var docController:UIDocumentInteractionController!
    var numberOfPhotos: NSNumber?
    var msgArray = NSMutableArray()
    var tempMsgs:AnyObject?
    var finalArray = NSMutableArray()
    var chatDetailDict = NSDictionary()
    let localDB = LocalStorage()
    var onlineTimer = Timer()
    var chat_id = String()
    var galleryType = String()
    var attachmentShow = Bool()
    var isFetch = Bool()
    var timeStamp = Date()
    var contactStore = CNContactStore()
    let contactPicker = CNContactPickerViewController()
    var contact_id = String()
    var menuArray = NSMutableArray()
    var blockByMe = String()
    var blockedMe = String()
    var isDeleted = String()
    var viewType = String()
    var startTyping = Bool()
    var selectedIndexArr = [IndexPath]()
    var selectedIdArr = [String]()
    var longPressGesture = UILongPressGestureRecognizer()
    var receiverId : String!
    var heightAtIndexPath = NSMutableDictionary()
    var isScrollBottom = Bool()
    var statusSizeArr = [CGFloat]()
    var textSizeArr = [CGFloat]()
    let del = UIApplication.shared.delegate as! AppDelegate
    let cryptLib = CryptLib()
    var isReload = true
    var chatRead = false
    var isTranslate = true
    var translateDict = NSDictionary()
    var isChatTranslation = true
    
    var speechRecognizer        = SFSpeechRecognizer(locale: Locale(identifier: "ar_SA"))
    var recognitionRequest      : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask         : SFSpeechRecognitionTask?
    let audioEngine             = AVAudioEngine()
    
    @IBOutlet weak var forwardIconView: UIView!
    @IBOutlet weak var attachmentIcon: UIImageView!
    @IBOutlet weak var backArrowIcon: UIImageView!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet var copyIcon: UIImageView!
    @IBOutlet var copyBtn: UIButton!
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var bootomInputView: UIView!
    @IBOutlet var contactNameLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var lastSeenLbl: UILabel!
    @IBOutlet var toolContainerView: UIView!
    @IBOutlet var messageTextView: GrowingTextView!
    @IBOutlet var msgTableView: UITableView!
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var sendImgView: UIImageView!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var attachmentMenuView: UIView!
    @IBOutlet var forwardView: UIView!
    
    @IBOutlet var translatedLanguageView: UIView!
    //New Customize
    @IBOutlet var smartReplyView: UIScrollView!
    
    
    @IBOutlet weak var record_btn_ref: RecordButton!
    var audioRecorder: AVAudioRecorder!
    var msgIDs = NSMutableArray()
    
    //var audioPlayer = AVAudioPlayer()
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var ishold = false
    var isPlaying = false
    var updater : CADisplayLink! = nil
    var senderaudioCell = SenderAudioCell()
    var audioPlayer:AVAudioPlayer!
    var receiveraudioCell = ReceiverVoiceCell()
    
    var counter = 0
    var timer = Timer()
    var tag_value = Int()
    var str_value_tofind_which_voiceCell = String()
    var isSwipeCalled = Bool()
    var currentAudioMsgID = String()
    var currentAudioStatus = String()
    var VoiceRecordingSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Voice_record", ofType: ".wav")!)
    var audioPlayer_VoiceRecord:AVAudioPlayer!
    
    var chatCount = 0
    var selectedDict = [messageModel.message]()
    var keyboardTypeUpdate = 0
    let recordView = RecordView()
    var scrollTag = 0
    var isFromBackground = false
    var cellHeights = [IndexPath: CGFloat]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnStart.setTitle("Start Recording", for: .normal)
        self.setupSpeech()
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        //        quickLookController.dataSource = self
        
        self.localDB.updateAllDownloadStatus()
        // Do any additional setup after loading the view.
        self.forwardView.isHidden = true
        self.smartReplyView.backgroundColor = .clear
        
        self.msgTableView.rowHeight = UITableView.automaticDimension
        self.msgTableView.estimatedRowHeight = 150
        self.msgTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.msgTableView.estimatedSectionHeaderHeight = 40
        self.configMsgField()
        self.customAudioRecordView()
        self.nonecheck(type: UserModel.shared.translatedLanguage() ?? "none")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            
        }
        self.recordAudioView()
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        //down unread view
        self.newMsgView.applyGradient()
        self.newMsgView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.downView.cornerViewRadius()
        self.downView.backgroundColor = NEW_MSG_BACKGROUND
        self.newMsgView.isHidden = true
        self.downView.isHidden = true
    }
    
    func socketrecoonect(){
        
        if socket.status != .connected {
            self.view.makeToast("Please wait ...", duration: 2, position: .center)
            socketClass.sharedInstance.connect()
        }
    }
    
    func nonecheck(type: String) {
        if type == "none" {
            self.isTranslate = false
        } else {
            self.isTranslate = true
        }
    }

    @objc func willResignActive() {
        //        self.onCancel()
        //        self.recorderView.isHidden = true
        //        self.recordView.isHidden = true
        //                if(isRecording){
        //                    if(audioRecorder.isRecording){
        //                        audioRecorder.stop()
        //                        audioRecorder.deleteRecording()
        //                    }
        //                }
        //        isRecording = false
        //        let requestDict = NSMutableDictionary()
        //        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        //        requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
        //        let sender_id:String = UserModel.shared.userID()! as String
        //        let receiver_id:String = self.chatDetailDict.value(forKey: "user_id") as! String
        //
        //        requestDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
        //        requestDict.setValue("untyping", forKey: "type")
        //        if self.blockedMe != "1" && blockByMe == "0"{
        //            socketClass.sharedInstance.sendTypingStatus(requestDict: requestDict)
        //        }
        //        self.attachmentView.isHidden = false
        //        messageTextView.isHidden = false
        
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
        recordView.slideToCancelArrowImage = nil
        recordView.slideToCancelText = Utility.shared.getLanguage()?.value(forKey: "slide_cancel") as? String ?? ""
        recordView.slideToCancelTextColor = TEXT_TERTIARY_COLOR
        //
    }
    func customAudioRecordView() {
        self.check_record_permission()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshContact), name: Notification.Name("ContactRefresh"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resignActive), name: UIApplication.willResignActiveNotification, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermission), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermission), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        self.updateTheme()
        self.recorderView.isHidden = true
        self.recordView.isHidden = true
        IQKeyboardManager.shared.enable = false
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.isNavigationBarHidden = true
        self.initialSetup()
        self.changeRTLView()
        self.checkPermission()
        self.msgTableView.reloadData()
        self.nonecheck(type: UserModel.shared.translatedLanguage() ?? "none")
    }
    @objc func refreshContact() {
        
    }
    //check contact access permission
    @objc func checkPermission()  {
        requestForAccess { (accessGranted) in
            if accessGranted == true{
                self.initialSetup()
            }
        }
    }
    @objc func handleApplicationDidBecomeActive() {
        print("Handle Active Status")
        //        if socket.status == .connected {
        self.isFromBackground = true
        self.localDB.updateAllDownloadStatus()
        self.chat_id = "\(UserModel.shared.userID()!)\(self.chatDetailDict.value(forKey: "user_id")!)"
        //sent viewed status to sender
        self.localDB.readStatus(id: self.contact_id, status: "3", type: "sender")
        self.localDB.updateRecent(chat_id: self.chat_id)
        Utility.shared.setBadge(vc: self)
        self.refresh(type:"scroll")
    }
    @objc func resignActive() {
        print("&&&&&&&&&&&& resign active")
        self.sendEndTyping()
    }
    
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.msgTableView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.backArrowIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.messageTextView.textAlignment = .right
            //self.sendBtn.setImage(UIImage(named:  "detail_back")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
            self.sendView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.sendBtn.transform = .identity
            self.msgTableView.transform = .identity
            self.backArrowIcon.transform = .identity
            self.sendView.transform = .identity
            
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewDidAppear(_ animated: Bool) {
        //        self.viewDidLayoutSubviews()
        //        self.initialSetup()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.isReload = false
        //        self.chatRead = false
        self.localDB.readStatus(id: self.contact_id, status: "3", type: "sender")
        self.localDB.updateRecent(chat_id: self.chat_id)
        self.localDB.updateAllDownloadStatus()
        self.onlineTimer.invalidate()
        Utility.shared.setBadge(vc: self)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
        
    }
    //scroll to bottom
    func scrollToBottom(){
        if self.msgArray.count != 0 {
            DispatchQueue.main.async {
                if self.msgArray.count != 0 {
                    let indexPath = IndexPath(row: self.msgArray.count - 1, section: 0)
                    self.msgTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }else {
                }
            }
        }
        else {
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        self.configGif()
        
        self.translatedLanguageView.isHidden = false
        self.smartReplyView.isHidden = true
    }
    
    //set up initial details
    func initialSetup()  {
        self.chatDetailDict = localDB.getContact(contact_id: self.contact_id)
        //connect socket
        socketClass.sharedInstance.delegate = self
        isScrollBottom = false
        //check online
        self.updateOnlineStatus()
        onlineTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateOnlineStatus), userInfo: nil, repeats: true)
        contactPicker.delegate = self
        //self.attachmentShow = false
        self.startTyping = false
        self.isFetch =  false
        self.toolContainerView.elevationEffectOnBottom()
        self.contactNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        if Utility.shared.isConnectedToNetwork() {
            if IS_IPHONE_5{
                self.lastSeenLbl.config(color: TEXT_SECONDARY_COLOR, size: 10, align: .left, text: EMPTY_STRING)
            }else{
                self.lastSeenLbl.config(color: TEXT_SECONDARY_COLOR, size: 10.5, align: .left, text: "tap_here_info")
            }
        }else{
            self.lastSeenLbl.config(color: TEXT_SECONDARY_COLOR, size: 10.5, align: .left, text: EMPTY_STRING)
        }
        self.profilePic.rounded()
        //send btn
        self.sendBtn.cornerRoundRadius()
        if Utility.shared.checkEmptyWithString(value: messageTextView.text) {
            self.configSendBtn(enable: false)
            self.ConfigVoiceBtn(enable: true)
            
        }else{
            self.configSendBtn(enable: true)
            self.ConfigVoiceBtn(enable:false)
            
        }
        //tap to dismiss keyboard
        self.contactNameLbl.text = self.chatDetailDict.value(forKey: "contact_name") as? String
        //register cell nibs
        self.registerCells()
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //MARK:STOP AUDIO START
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground(_:)), name:UIApplication.didEnterBackgroundNotification, object: nil)
        
        //get chat msgs from local db
        chat_id = "\(UserModel.shared.userID()!)\(self.chatDetailDict.value(forKey: "user_id")!)"
        if isReload {
            self.refresh(type:"scroll")
        }
        
        //sent viewed status to sender
        socketClass.sharedInstance.chatRead(sender_id:self.contact_id, receiver_id:UserModel.shared.userID()! as String)
        self.localDB.readStatus(id: self.contact_id, status: "3", type: "sender")
        self.localDB.updateRecent(chat_id: self.chat_id)
        Utility.shared.setBadge(vc: self)
        print("chat details dict \(self.chatDetailDict)")
        
        blockByMe = self.chatDetailDict.value(forKey: "blockedByMe") as! String
        blockedMe = self.chatDetailDict.value(forKey: "blockedMe") as! String
        DispatchQueue.main.async {
            self.configBlockedStatus()
            self.configMuteStatus()
            self.configFavStatus()
        }
        
        setupLongPressGesture()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.toolContainerView.backgroundColor = BOTTOM_BAR_COLOR
        self.forwardView.backgroundColor = BOTTOM_BAR_COLOR
        self.bootomInputView.backgroundColor = BOTTOM_BAR_COLOR
        self.attachmentMenuView.backgroundColor = BOTTOM_BAR_COLOR
        self.adjustDownView()
        
        isDeleted = self.chatDetailDict.value(forKey: "isDelete") as! String
        
        if isDeleted == "1"{
            self.bottomStackView.isHidden = true
            self.deleteAcLbl.config(color: .white, size: 17, align: .center, text: "deleted_account")
        }else{
            self.deleteAcLbl.isHidden = true
        }
        
        //        self.smartReplyView.isHidden = true
        
    }
    
    
    @objc func applicationDidEnterBackground(_ notification: NSNotification) {
        self.stopAudioPlayer()
    }
    
    //config mute status
    func configMuteStatus()  {
        self.chatDetailDict =  self.localDB.getContact(contact_id: self.contact_id)
        let mute:String = self.chatDetailDict.value(forKey: "mute") as! String
        self.menuArray.removeObject(at: 0)
        if mute == "0"{
            self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String, at: 0)
        }else if mute == "1"{
            self.menuArray.insert(Utility.shared.getLanguage()?.value(forKey: "unmute_notify") as! String, at: 0)
        }
    }
    
    //config fav status
    func configFavStatus()  {
        self.chatDetailDict =  self.localDB.getContact(contact_id: self.contact_id)
        let fav:String = self.chatDetailDict.value(forKey: "favourite") as! String
        if fav == "0"{
            if self.menuArray.contains(Utility.shared.getLanguage()?.value(forKey: "remove_favourite")as! String){
                self.menuArray.remove(Utility.shared.getLanguage()?.value(forKey: "remove_favourite") as! String)
            }
            self.menuArray.add(Utility.shared.getLanguage()?.value(forKey: "add_favourite")as! String)
        }else if fav == "1"{
            if self.menuArray.contains(Utility.shared.getLanguage()?.value(forKey: "add_favourite") as! String){
                self.menuArray.remove(Utility.shared.getLanguage()?.value(forKey: "add_favourite") as! String)
            }
            self.menuArray.add(Utility.shared.getLanguage()?.value(forKey: "remove_favourite") as! String)
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
        messageTextView.isUserInteractionEnabled = true
        
        recorderView.layer.borderWidth  = 1.0
        recorderView.layer.borderColor = TEXT_TERTIARY_COLOR.cgColor
        recorderView.layer.cornerRadius = 20.0
    }
    //config blocked Status
    func configBlockedStatus(){
        self.chatDetailDict = self.localDB.getContact(contact_id: contact_id)
        let contact_name:String = chatDetailDict.value(forKey: "contact_name") as? String ?? ""
        let phone_no:String = chatDetailDict.value(forKey: "user_phoneno") as? String ?? ""
        let cc: String = chatDetailDict.value(forKey: "countrycode") as? String ?? ""
        if blockByMe == "1"{
            self.lastSeenLbl.isHidden = true
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String,Utility.shared.getLanguage()?.value(forKey: "unblock") as! String,Utility.shared.getLanguage()?.value(forKey: "clear_all")as! String]
        }else if blockByMe == "0"{
            self.lastSeenLbl.isHidden = false
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "mute_notify") as! String,Utility.shared.getLanguage()?.value(forKey: "block")as! String,Utility.shared.getLanguage()?.value(forKey: "clear_all")as! String]
        }
        
        if contact_name == "+\(cc) \(phone_no)" {
            self.menuArray.add(Utility.shared.getLanguage()?.value(forKey: "add_to_contact")as! String)
        }
        
        if blockedMe == "1" {
            self.profilePic.image = #imageLiteral(resourceName: "profile_placeholder")
            self.lastSeenLbl.isHidden = true
        }else if blockedMe == "0" && blockByMe == "1"{
            self.lastSeenLbl.isHidden = true
            self.configPrivacySettings()
        }else if blockedMe == "0"{
            self.profilePic.image = #imageLiteral(resourceName: "profile_placeholder")
            self.lastSeenLbl.isHidden = false
        }
        if blockedMe == "0" && blockByMe == "0"{
            self.lastSeenLbl.isHidden = false
            self.configPrivacySettings()
        }
        
    }
    //account setting validation
    func configPrivacySettings() {
        self.chatDetailDict = self.localDB.getContact(contact_id: contact_id)
        let privacy_image:String = chatDetailDict.value(forKey: "privacy_image") as? String ?? ""
        let mutual:String = chatDetailDict.value(forKey: "mutual_status") as? String ?? ""
        let privacy_lastseen:String = chatDetailDict.value(forKey: "privacy_lastseen") as? String ?? ""
        let imageName:String = chatDetailDict.value(forKey: "user_image") as? String ?? ""
        // profile pic
        DispatchQueue.main.async {
            if privacy_image == "nobody"{
                self.profilePic.image =  #imageLiteral(resourceName: "profile_placeholder")
            }else if privacy_image == "everyone"{
                self.profilePic.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage:  #imageLiteral(resourceName: "profile_placeholder"))
            }else if privacy_image == "mycontacts"{
                if mutual == "true"{
                    self.profilePic.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage:  #imageLiteral(resourceName: "profile_placeholder"))
                }else{
                    self.profilePic.image =  #imageLiteral(resourceName: "profile_placeholder")
                }
            }
        }
        //last seen
        if privacy_lastseen == "nobody"{
            self.lastSeenLbl.isHidden = true
            //            self.contactNameLbl.frame =  CGRect.init(x: self.profilePic.frame.origin.x+50, y:  self.profilePic.frame.origin.y + 10, width: 150, height: 25)
        }else if privacy_lastseen == "everyone"{
            if blockByMe != "1"{
                self.lastSeenLbl.isHidden = false
            }
            
        }else if privacy_lastseen == "mycontacts"{
            if mutual == "true"{
                self.lastSeenLbl.isHidden = false
            }else{
                self.lastSeenLbl.isHidden = true
                //                self.contactNameLbl.frame =  CGRect.init(x: self.profilePic.frame.origin.x+50, y:  self.profilePic.frame.origin.y + 10, width: 150, height: 25)
            }
        }
    }
    
    
    //register table view cells
    func registerCells()  {
        msgTableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "TextCell")
        msgTableView.register(UINib(nibName: "SenderImageCell", bundle: nil), forCellReuseIdentifier: "SenderImageCell")
        msgTableView.register(UINib(nibName: "ReceiverImageCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageCell")
        
        msgTableView.register(UINib(nibName: "SenderAudioCell", bundle: nil), forCellReuseIdentifier: "SenderAudioCell")
        msgTableView.register(UINib(nibName: "ReceiverVoiceCell", bundle: nil), forCellReuseIdentifier: "ReceiverVoiceCell")
        
        msgTableView.register(UINib(nibName: "SenderVideoCell", bundle: nil), forCellReuseIdentifier: "SenderVideoCell")
        msgTableView.register(UINib(nibName: "ReceiverVideoCell", bundle: nil), forCellReuseIdentifier: "ReceiverVideoCell")
        
        msgTableView.register(UINib(nibName: "SenderLocCell", bundle: nil), forCellReuseIdentifier: "SenderLocCell")
        msgTableView.register(UINib(nibName: "ReceiverLocCell", bundle: nil), forCellReuseIdentifier: "ReceiverLocCell")
        
        msgTableView.register(UINib(nibName: "SenderContact", bundle: nil), forCellReuseIdentifier: "SenderContact")
        msgTableView.register(UINib(nibName: "ReceiverContact", bundle: nil), forCellReuseIdentifier: "ReceiverContact")
        
        msgTableView.register(UINib(nibName: "SenderDocuCell", bundle: nil), forCellReuseIdentifier: "SenderDocuCell")
        msgTableView.register(UINib(nibName: "ReceiverDocuCell", bundle: nil), forCellReuseIdentifier: "ReceiverDocuCell")
        
        msgTableView.register(UINib(nibName: "dateStickyCell", bundle: nil), forCellReuseIdentifier: "dateStickyCell")
        
        msgTableView.register(UINib(nibName: "ReceiverAudioCell", bundle: nil), forCellReuseIdentifier: "ReceiverAudioCell")
        msgTableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "TextCell")
        msgTableView.register(UINib(nibName: "StatusReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "StatusReplyTableViewCell")
        msgTableView.register(UINib(nibName: "ChatDetailsSectionTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ChatDetailsSectionTableViewCell")
        
    }
    func setupLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1 // 1 second press
        longPressGesture.delaysTouchesBegan = true
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
            //get msg data basleton the selection
            let dict:messageModel.message = self.msgArray.object(at: selectedIndexPath?.row ?? 0) as! messageModel.message
            //arrange msg values
            let msg_type = dict.message_data.value(forKey: "message_type") as! String
            let id = dict.message_data.value(forKey: "message_id") as! String
            if msg_type != "date_sticky"{
                if self.selectedIdArr.filter({$0 == id}).count == 0{
                    let cell:UITableViewCell = self.msgTableView.cellForRow(at: selectedIndexPath ?? IndexPath(row: 0, section: 0))!
                    cell.tag = (selectedIndexPath?.row ?? 0) + 400
                    //forward only downloaded media files
                    cell.backgroundColor = CHAT_SELECTION_COLOR
                    self.forwardView.isHidden = false
                    self.selectedIdArr.append(id)
                    self.selectedIndexArr.append(selectedIndexPath!)
                    
                    self.selectedDict.append(dict)
                    
                    //msg type
                    if msg_type == "text" {
                        self.copyBtn.isHidden = false
                        self.copyIcon.isHidden = false
                    }else{
                        self.copyBtn.isHidden = true
                        self.copyIcon.isHidden = true
                    }
                    self.checkDownloadStatus()
                }
            }else{
                self.forwardView.isHidden = true
                let index = self.selectedIdArr.firstIndex(of: id)
                self.selectedIdArr.remove(at: index ?? 0)
                let selectedIndex = self.selectedIndexArr.firstIndex(of: selectedIndexPath!)
                self.selectedIndexArr.remove(at: selectedIndex ?? 0)
                
                if selectedIndexPath!.count != 0 {
                    let cell = view.viewWithTag(selectedIndexPath!.row + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                }
            }
        }
    }
    
    //dismiss keyboard & attachment menu
    @objc func dismissKeyboard() {
        messageTextView.resignFirstResponder()
        self.scrollToBottom()
    }
    
    
    @IBAction func copyBtnTapped(_ sender: Any) {
        let msgDict :NSDictionary = localDB.getMsg(msg_id: self.selectedIdArr.first ?? "")
        UIPasteboard.general.string = msgDict.value(forKeyPath: "message_data.message") as? String
        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "copied") as? String)
        self.forwardView.isHidden = true
        self.selectedIdArr.removeAll()
        self.selectedDict.removeAll()
        self.selectedIndexArr.removeAll()
        self.scrollTag = 1
        self.msgTableView.reloadData()
    }
    @IBAction func deleteBtnTapped(_ sender: Any) {
        var typeTag = 0
        let own_id:String = UserModel.shared.userID()! as String
        for i in 0..<self.selectedIdArr.count {
            let msgDict =  NSMutableDictionary()
            msgDict.setValue(self.selectedDict[i].message_data, forKey: "message_data")
            let chatTime:String = msgDict.value(forKeyPath: "message_data.chat_time") as! String
            let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            let sender_id:String = self.selectedDict[i].sender_id
            
            let cal = Calendar.current
            var d1 = Date()
            let client = TrueTimeClient.sharedInstance
            if client.referenceTime?.now() != nil{
                d1 = (client.referenceTime?.now())!
            }
            let d2 = Utility.shared.getUTC(date: chatTime)
            //            let d2 = Date.init(timeIntervalSince1970: Double(chatTime) ?? 0) // April 27, 2018 12:00:00 AM
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
        if type == "0"{
            self.deleteForMeAct()
        }else {
            self.deleteForEveryOneAct()
        }
    }
    
    func deleteForEveryOneAct() {
        self.deleteImageAndVideoFromPhotoLibrary(onSuccess: {response in
            for i in self.selectedDict {
                let msgDict =  NSMutableDictionary()
                let cryptLib = CryptLib()
                let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"This message was Deleted", key: ENCRYPT_KEY)
                msgDict.setValue(encryptedMsg, forKey: "message")
                msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
                msgDict.setValue(i.message_data.value(forKey: "message_id") as? String ?? "", forKey: "message_id")
                msgDict.setValue(self.contact_id, forKey: "receiver_id")
                msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                msgDict.setValue(i.message_data.value(forKey: "chat_time") as? String ?? "", forKey: "chat_time")
                msgDict.setValue("1", forKey: "read_status")
                msgDict.setValue("single", forKey: "chat_type")
                msgDict.setValue("isDelete", forKey: "message_type")
                //                msgDict.setValue(self.chatDetailDict.value(forKey: "user_phoneno"), forKey: "phone")
                msgDict.setValue(UserModel.shared.userDict().value(forKey: "phone_no") as? String, forKey: "phone")
                msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name") as? String, forKey: "user_name")
                msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                
                let requestDict = NSMutableDictionary()
                requestDict.setValue(i.sender_id, forKey: "sender_id")
                requestDict.setValue(i.receiver_id, forKey: "receiver_id")
                requestDict.setValue(msgDict, forKey: "message_data")
                socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                self.localDB.updateMessage(message_type: "isDelete", msg_id: i.message_data.value(forKey: "message_id") as? String ?? "")
                
            }
            for msgID in self.selectedIdArr{
                self.checkAndReplace(msg_id:msgID)
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
        self.isReload = false
        
        self.messageTextView.resignFirstResponder()
        let forwardObj = ForwardSelection()
        forwardObj.msgID = self.selectedIdArr
        forwardObj.msgFrom = "single"
        forwardObj.delegate = self
        self.navigationController?.pushViewController(forwardObj, animated: true)
    }
    
    @IBAction func voiceToTextBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.btnStart.setTitle("Stop Recording", for: .normal)
            self.startRecording()
        }
        else {
            self.lastText = self.messageTextView.text
            self.btnStart.setTitle("Start Recording", for: .normal)
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.recognitionTask?.cancel()
            self.speechRecognizer = nil
            self.btnStart.isEnabled = false
            self.btnStart.isSelected = false
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.messageTextView.text = self.lastText
            }
            self.setupSpeech()
        }
    }
    
    func forwardMsg(type: String, idStr:String) {
        if !msgIDs.contains(type){
            msgIDs.add(type)
            let newMsg = self.localDB.getParticularMsg(msg_id: type)
            print("chat_id \(idStr) currentchatid \(self.chat_id)")
            if idStr == self.chat_id {
                if newMsg != nil{
                    self.msgArray.add(newMsg!)
                    self.tempMsgs?.add(newMsg!)
                }
            }
            
            self.msgTableView.reloadData()
        }
        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "sending") as? String)
        self.forwardView.isHidden = true
        for selectedIndexPath in self.selectedIndexArr {
            if selectedIndexPath.count != 0 {
                let cell = view.viewWithTag(selectedIndexPath.row + 400) as? UITableViewCell
                cell?.backgroundColor = .clear
            }
        }
        self.selectedIdArr.removeAll()
        self.selectedDict.removeAll()
        self.selectedIndexArr.removeAll()
    }
    
    //navigation back btn tapped
    @IBAction func backBtnTapped(_ sender: Any) {
        //        if audioPlayer.isPlaying{
        //            audioPlayer.stop()
        //            self.timer.invalidate()
        //        }
        // audioPlayer.stop()
        print("curent id \(currentAudioMsgID)")
        if currentAudioMsgID != "" {
            audioPlayer.stop()
            self.timer.invalidate()
        }
        
        if self.selectedIdArr.count != 0  {
            self.forwardView.isHidden = true
            if selectedIndexArr.count != 0 {
                for i in selectedIndexArr {
                    let cell = view.viewWithTag(i.row + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                    
                }
                self.selectedIndexArr.removeAll()
            }
            self.selectedIdArr.removeAll()
            self.selectedDict.removeAll()
            self.scrollTag = 0
            self.msgTableView.reloadData()
        }else{
            if self.viewType == "1" {
                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            }
            else if self.viewType == "10" {
                self.del.setInitialViewController(initialView: menuContainerPage())
                //                UserModel.shared.setTab(index: 0)
            }
            else if self.viewType == "2"{
                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            }
            else if self.viewType == "0"{
                self.navigationController?.popViewController(animated: true)
                UserModel.shared.setTab(index: 0)
            }
            else if self.viewType == "3"{
                if let anIndex = navigationController?.viewControllers[1] {
                    navigationController?.popToViewController(anIndex, animated: true)
                    UserModel.shared.setTab(index: 0)
                }
            }
        }
    }
    /*
     //old
     func stopAudioPlayer() {
     let dict:messageModel.message = msgArray.object(at: tag_value) as! messageModel.message
     let sender_Tag_id:String = dict.sender_id
     let own_id:String = UserModel.shared.userID()! as String
     audioPlayer.currentTime = TimeInterval(0)
     if sender_Tag_id != own_id {
     let cell1 = view.viewWithTag(tag_value + 4000) as? ReceiverVoiceCell
     audioPlayer.stop()
     self.timer.invalidate()
     cell1?.playerImg.image = UIImage(named:"play_audio.png")
     cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
     cell1?.PlayerBtn.clipsToBounds = true
     }
     else {
     let cell1 = view.viewWithTag(tag_value + 3000) as? SenderAudioCell
     audioPlayer.stop()
     cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
     self.timer.invalidate()
     cell1?.playerImg.image = UIImage(named:"play_audio.png")
     cell1?.PlayerBtn.clipsToBounds = true
     
     }
     }
     */
    
    func stopAudioPlayer() {
        if msgArray.count > tag_value {
            if let dict = msgArray.object(at: tag_value) as? messageModel.message {
                let sender_Tag_id:String = dict.sender_id
                let own_id:String = UserModel.shared.userID()! as String
                if audioPlayer != nil {
                    audioPlayer.currentTime = TimeInterval(0)
                }
                if sender_Tag_id != own_id {
                    let cell1 = view.viewWithTag(tag_value + 4000) as? ReceiverVoiceCell
                    if audioPlayer != nil {
                        audioPlayer.stop()
                    }
                    
                    self.timer.invalidate()
                    cell1?.playerImg.image = UIImage(named:"play_audio.png")
                    cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
                    cell1?.PlayerBtn.clipsToBounds = true
                }
                else {
                    let cell1 = view.viewWithTag(tag_value + 3000) as? SenderAudioCell
                    if audioPlayer != nil {
                        audioPlayer.stop()
                    }
                    cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
                    self.timer.invalidate()
                    cell1?.playerImg.image = UIImage(named:"play_audio.png")
                    cell1?.PlayerBtn.clipsToBounds = true
                }
            }
        }
    }
    
    @objc func audioCellBtnTapped(_ sender: UIButton!)  {
        if Utility.shared.isConnectedToNetwork(){
            let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
            let msgDict =  NSMutableDictionary()
            msgDict.setValue(dict.message_data, forKey: "message_data")
            // print(msgDict)
            if self.selectedIdArr.count == 0{
                let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
                if type != "date_sticky" {
                    let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
                    let sender_id:String = dict.sender_id
                    let own_id:String = UserModel.shared.userID()! as String
                    let updatedDict = self.localDB.getMsg(msg_id: message_id)
                    var videoName:String = updatedDict.value(forKeyPath: "message_data.local_path") as! String
                    if videoName == "0"{
                        let serverLink = msgDict.value(forKeyPath: "message_data.attachment") as! String
                        videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
                    }
                    // print("-------------Audio_URL : %@",videoName)
                    let videoURL = URL.init(string: videoName)
                    let message = videoURL?.lastPathComponent
                    
                    //                    dowloadFile(audioString: videoName,message:message ?? "audio")
                    
                    let isDownload = msgDict.value(forKeyPath: "message_data.isDownload") as! String
                    if tag_value != sender.tag && counter != 0 {
                        stopAudioPlayer()
                    }
                    
                    if sender_id != own_id {
                        //check its downloaded
                        if isDownload == "0" || isDownload == "4"{
                            self.dowloadAudioFile(index:sender.tag,audioString:videoName, message: message ?? "audio", model :dict)
                            //                            self.downloadaudiofromserver(index: sender.tag, model: dict)
                        }
                        else if isDownload == "1" || isDownload == "2"
                        {
                            //if !audioPlayer.isPlaying || audioPlayer == nil {
                            
                            if let audioUrl = URL(string: videoName) {
                                // then lets create your document folder url
                                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                // lets create your destination file url
                                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                                //                                let desURL = Bundle.main.url(forResource: "attachment-1591338452538", withExtension: "mp3")!
                                do {
                                    
                                    let msg_id = msgDict.value(forKeyPath:"message_data.message_id") as! String
                                    print("currentAudioMsgID one \(currentAudioMsgID) msg_id \(msg_id)")
                                    
                                    if currentAudioMsgID == "" || currentAudioMsgID != msg_id{
                                        let data = try Data(contentsOf: destinationUrl)
                                        audioPlayer = try AVAudioPlayer.init(data: data)
                                        //                                        audioPlayer.volume = 3
                                        audioPlayer.delegate = self
                                        audioPlayer.stop()
                                        audioPlayer.prepareToPlay()
                                        currentAudioMsgID = msg_id
                                        
                                    }
                                    let cell = view.viewWithTag(sender.tag + 4000) as? ReceiverVoiceCell
                                    let maximumvalue:Double = audioPlayer.duration
                                    //duration(for: videoName)
                                    let int_value:Int = Int(maximumvalue)
                                    
                                    
                                    cell?.audioProgress?.minimumValue = 0
                                    cell?.audioProgress?.maximumValue = Float(int_value)
                                    str_value_tofind_which_voiceCell = "ReceiverVoiceCell"
                                    if counter == 0 {
                                        audioPlayer.play()
                                        counter = 1
                                        cell?.playerImg.image = UIImage(named:"pause_receive.png")
                                        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer(_:)), userInfo: [cell?.audioProgress.tag ?? 0], repeats: true)
                                        cell?.audioProgress.clipsToBounds = true
                                        cell?.PlayerBtn.clipsToBounds = true
                                        tag_value = sender.tag
                                    } else {
                                        
                                        if tag_value == sender.tag {
                                            print("check 2")
                                            audioPlayer.pause()
                                            self.timer.invalidate()
                                            cell?.playerImg.image = UIImage(named:"play_receive.png")
                                            cell?.audioProgress.value = Float(audioPlayer.currentTime)
                                            cell?.PlayerBtn.clipsToBounds = true
                                            counter = 0
                                        }
                                        else {
                                            
                                            if (cell?.audioProgress.value ?? 0) != 0 {
                                                let audioValue = cell?.audioProgress.value
                                                audioPlayer.currentTime = Double(audioValue ?? 0)
                                            }
                                            // print(audioPlayer.currentTime)
                                            audioPlayer.play()
                                            cell?.playerImg.image = UIImage(named:"pause_receive.png")
                                            cell?.PlayerBtn.clipsToBounds = true
                                            tag_value = sender.tag
                                            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer(_:)), userInfo: [cell?.audioProgress.tag ?? 0], repeats: true)
                                            counter = 1
                                        }
                                    }
                                } catch let error {
                                    print(error.localizedDescription)
                                }
                            }
                            
                        }
                    }else{
                        if isDownload == "0" {
                            
                            if let audioUrl = URL(string: videoName) {
                                
                                // then lets create your document folder url
                                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                
                                // lets create your destination file url
                                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                                
                                do {
                                    let msg_id = msgDict.value(forKeyPath:"message_data.message_id") as! String
                                    if currentAudioMsgID == "" || currentAudioMsgID != msg_id{
                                        let data = try Data(contentsOf: destinationUrl)
                                        audioPlayer = try AVAudioPlayer.init(data: data)
                                        audioPlayer.delegate = self
                                        audioPlayer.prepareToPlay()
                                        currentAudioMsgID = msg_id
                                    }
                                    // print(audioPlayer.currentTime)
                                    let maximumvalue:Double = audioPlayer.duration
                                    //duration(for: videoName)
                                    
                                    let int_value:Int = Int(maximumvalue)
                                    
                                    let cell = view.viewWithTag(sender.tag + 3000) as? SenderAudioCell
                                    cell?.audioProgress?.minimumValue = 0
                                    cell?.audioProgress?.maximumValue = Float(int_value)
                                    str_value_tofind_which_voiceCell = "SenderAudioCell"
                                    
                                    if counter == 0 {
                                        if (cell?.audioProgress.value ?? 0) != 0 {
                                            let audioValue = cell?.audioProgress.value
                                            audioPlayer.currentTime = Double(audioValue ?? 0) //* audioPlayer.duration / 100 // audioPlayer.currentTime * 100.0 / audioPlayer.duration
                                        }
                                        audioPlayer.play()
                                        cell?.playerImg.image = UIImage(named:"pause_audio.png")
                                        //cell?.PlayerBtn.setImage(UIImage(named:"pause_audio.png"), for: UIControlState.normal)
                                        
                                        //                                        let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
                                        // print(normalizedTime)
                                        //                                        cell?.audioProgress.value = normalizedTime
                                        
                                        cell?.PlayerBtn.clipsToBounds = true
                                        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer(_:)), userInfo: [cell?.audioProgress.tag ?? 0], repeats: true)
                                        
                                        tag_value = sender.tag
                                        counter = 1
                                    } else {
                                        if tag_value == sender.tag {
                                            audioPlayer.stop()
                                            self.timer.invalidate()
                                            
                                            cell?.playerImg.image = UIImage(named:"play_audio.png")
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
                                            cell?.playerImg.image = UIImage(named:"pause_audio.png")
                                            //cell?.PlayerBtn.setImage(UIImage(named:"pause_audio.png"), for: UIControlState.normal)
                                            
                                            //                                            let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
                                            // print(normalizedTime)
                                            //                                        cell?.audioProgress.value = normalizedTime
                                            
                                            cell?.PlayerBtn.clipsToBounds = true
                                            tag_value = sender.tag
                                            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer(_:)), userInfo: [cell?.audioProgress.tag ?? 0], repeats: true)
                                            
                                            counter = 1
                                        }
                                    }
                                } catch let error {
                                    // print(error.localizedDescription)
                                }
                            }
                            
                            
                        }else if isDownload == "4"{//cancelled
                            
                            if Utility.shared.isConnectedToNetwork(){
                                let msg_id:String = updatedDict.value(forKeyPath: "message_data.message_id") as! String
                                self.localDB.updateDownload(msg_id: msg_id, status: "0")
                                self.scrollTag = 1
                                self.msgTableView.reloadData()
                                PhotoAlbum.sharedInstance.getVideo(local_ID: videoURL!, msg_id: msg_id, requestData: updatedDict,type:(videoURL?.pathExtension)!)
                            } else{
                                self.messageTextView.resignFirstResponder()
                                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
                            }
                        }
                    }
                }
            }else{
                let indexpath = IndexPath.init(row: sender.tag, section: 0)
                self.makeSelection(tag: sender.tag, index: indexpath)
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
    func dowloadAudioFile(index:Int,audioString:String, message: String, model :messageModel.message)  {
        let msgDict = NSMutableDictionary()
        msgDict.setValue(model.message_data, forKey: "message_data")
        let messageID:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        let oldMsgDict = NSMutableDictionary.init(dictionary: model.message_data)
        
        self.localDB.updateDownload(msg_id: messageID, status: "2")
        let cell = view.viewWithTag(index + 4000) as? ReceiverVoiceCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        cell?.downloadIcon.isHidden = true
        if let url = URL.init(string:audioString){
            
            // if let audioUrl = URL(string: "http://freetone.org/ring/stan/iPhone_5-Alarm.mp3") {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(message)
            // print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        guard
                            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                            let mimeType = response?.mimeType, mimeType.hasPrefix("audio"),
                            error == nil
                        else { return }
                        do {
                            try FileManager.default.moveItem(at: location, to: destinationUrl)
                            print("file saved")
                        } catch {
                            print(error)
                        }
                        print("File moved to documents folder \(destinationUrl) \(location)")
                        self.localDB.updateDownload(msg_id: messageID, status: "1")
                        //oldMsgDict.removeObject(forKey: "isDownload")
                        let localObj = LocalStorage()
                        
                        localObj.updateLocalURL(msg_id: messageID, url: destinationUrl.absoluteString)
                        oldMsgDict.setValue("1", forKey: "isDownload")
                        let newModel = messageModel.message.init(sender_id: model.sender_id, receiver_id: model.receiver_id, message_data:oldMsgDict, date: model.date)
                        self.msgArray.removeObject(at: index)
                        self.msgArray.insert(newModel, at: index)
                        DispatchQueue.main.async {
                            self.scrollTag = 1
                            self.msgTableView.reloadData()
                        }
                    } catch let error as NSError {
                        print("error.localizedDescription \(error.localizedDescription)")
                    }
                }).resume()
            }
        }
    }
    @objc func updateUIWithTimer(_ timer: Timer){
        if str_value_tofind_which_voiceCell == "SenderAudioCell" {
            //            if info[0] as? Int ?? 0 == tag
            let cell = view.viewWithTag(tag_value + 3000) as? SenderAudioCell
            
            let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
            if normalizedTime == 0.0 {
                if counter != 0 {
                    counter = 0
                }
                self.timer.invalidate()
                cell?.audioProgress.value = normalizedTime
                let currentTime = Int(audioPlayer.duration)
                let minutes = currentTime/60
                let seconds = currentTime - minutes * 60
                currentAudioMsgID = ""
                self.audioPlayer.stop()
                cell?.audioTimeLbl.text = NSString(format: "%02d:%02d", minutes,seconds) as String
                cell?.playerImg.image = UIImage(named:"play_audio.png")
                
            }else{
                
                cell?.audioProgress.value = Float(audioPlayer.currentTime)
                let currentTime = Int(audioPlayer.currentTime)
                let minutes = currentTime/60
                let seconds = currentTime - minutes * 60
                let time = NSString(format: "%02d:%02d", minutes,seconds) as String
                cell?.audioTimeLbl.text = time
                
                
                if counter != 0 {
                    cell?.playerImg.image = UIImage(named:"pause_audio.png")
                }
            }
            audioPlayer.updateMeters()
            cell?.audioProgress.clipsToBounds = true
            
        }else if str_value_tofind_which_voiceCell == "ReceiverVoiceCell"{
            let cell = view.viewWithTag(tag_value + 4000) as? ReceiverVoiceCell
            
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
    /*
     @objc func updateUIWithTimer(_ timer: Timer){
     if str_value_tofind_which_voiceCell == "SenderAudioCell" {
     //            if info[0] as? Int ?? 0 == tag
     let cell = view.viewWithTag(tag_value + 3000) as? SenderAudioCell
     
     let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
     if normalizedTime == 0.0 {
     if counter != 0 {
     counter = 0
     }
     self.timer.invalidate()
     cell?.audioProgress.value = normalizedTime
     let currentTime = Int(audioPlayer.duration)
     let minutes = currentTime/60
     let seconds = currentTime - minutes * 60
     currentAudioMsgID = ""
     self.audioPlayer.stop()
     cell?.audioTimeLbl.text = NSString(format: "%02d:%02d", minutes,seconds) as String
     cell?.playerImg.image = UIImage(named:"play_audio.png")
     
     }else{
     
     cell?.audioProgress.value = Float(audioPlayer.currentTime)
     let currentTime = Int(audioPlayer.currentTime)
     let minutes = currentTime/60
     let seconds = currentTime - minutes * 60
     let time = NSString(format: "%02d:%02d", minutes,seconds) as String
     cell?.audioTimeLbl.text = time
     
     
     if counter != 0 {
     cell?.playerImg.image = UIImage(named:"pause_audio.png")
     }
     }
     audioPlayer.updateMeters()
     cell?.audioProgress.clipsToBounds = true
     
     }else if str_value_tofind_which_voiceCell == "ReceiverVoiceCell"{
     let cell = view.viewWithTag(tag_value + 4000) as? ReceiverVoiceCell
     let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
     if normalizedTime == 0.0 {
     self.timer.invalidate()
     cell?.audioProgress.value = normalizedTime
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
     
     
     }else{
     cell?.audioProgress.value = Float(audioPlayer.currentTime)
     let currentTime = Int(audioPlayer.currentTime)
     let minutes = currentTime/60
     let seconds = currentTime - minutes * 60
     
     let time = NSString(format: "%02d:%02d", minutes,seconds) as String
     cell?.audioTimeLbl.text = time
     
     if normalizedTime >= 0.0{
     if counter != 0 {
     cell?.playerImg.image = UIImage(named:"pause_receive.png")
     }
     }
     
     }
     audioPlayer.updateMeters()
     cell?.audioProgress.clipsToBounds = true
     
     }
     
     }
     */
    
    //update online status
    @objc func updateOnlineStatus(){
        if isSocketConnected {
            print("checkkkkk - onlineeeee")
            socketClass.sharedInstance.sendOnlineStatus(contact_id: self.contact_id)
            socketClass.sharedInstance.chatRead(sender_id:self.contact_id, receiver_id:UserModel.shared.userID() as? String ?? "")
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                if !Utility.shared.isConnectedToNetwork(){
                    self.lastSeenLbl.isHidden = true
                    print("checkkkkk - chat read")
                }
            })
        }else{
            print("checkkkkk - offllllinnnnneeee")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                self.updateOnlineStatus()
            }
        }
        
    }
    
    //reload view
    func refresh(type:String){
        isScrollBottom = false
        self.isFetch = false
        let newMsg = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
        self.tempMsgs = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
        //        self.msgArray = Utility.shared.arrangeMsg(array:newMsg!)
        self.msgArray = newMsg!
        
        if type != "NoScroll" {
            self.scrollToBottom()
            self.scrollTag = 0
            //reload to empty table view
            self.msgTableView.reloadData()
        }
    }
    
    @IBAction func callBtnTapped(_ sender: Any)    {
        self.messageTextView.resignFirstResponder()
        if isDeleted != "1"{
            if Utility.shared.isConnectedToNetwork() {
                
                if socket.status != .connected{
                    socketClass.sharedInstance.connect()
                }
                if socket.status == .connected{
                    
                    if blockByMe == "1"{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
                    }else{
                        if UserModel.shared.alreadyInCall() == "true" {
                            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "already_in_call") as? String)
                        } else{
                            DispatchQueue.main.async {
                                if self.counter != 0 {
                                    self.counter = 0
                                    self.stopAudioPlayer()
                                }
                                let random_id = Utility.shared.random()
                                let pageobj = CallPage()
                                pageobj.updateCallStatus = { [weak self] in
                                }
                                pageobj.receiverId = self.contact_id
                                pageobj.senderFlag = true
                                pageobj.random_id = random_id
                                pageobj.userdict = self.chatDetailDict
                                pageobj.call_type = "audio"
                                pageobj.modalPresentationStyle = .fullScreen
                                self.localCallDB.addNewCall(call_id: random_id, contact_id: self.contact_id, status: "outgoing", call_type: "audio", timestamp: Utility.shared.getTime(), unread_count: "0")
                                self.present(pageobj, animated: true, completion: nil)
                            }
                        }
                    }
                    
                }else{
                    self.socketrecoonect()
                }
                
            }else{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
            }
        }
    }
    
    @IBAction func videoBtnTapped(_ sender: Any) {
        if isDeleted != "1"{
            if Utility.shared.isConnectedToNetwork() {
                if socket.status != .connected{
                    socketClass.sharedInstance.connect()
                }
                if socket.status == .connected{
                    self.messageTextView.resignFirstResponder()
                    if blockByMe == "1"{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
                    }else{
                        if UserModel.shared.alreadyInCall() == "true" {
                            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "already_in_call") as? String)
                        } else{
                            self.isReload = false
                            let random_id = Utility.shared.random()
                            let pageobj = CallPage()
                            pageobj.receiverId = self.contact_id
                            pageobj.updateCallStatus = { [weak self] in
                            }
                            pageobj.random_id = random_id
                            pageobj.senderFlag = true
                            pageobj.call_type = "video"
                            pageobj.userdict = self.chatDetailDict
                            // print(time.rounded().clean)
                            if self.counter != 0 {
                                self.counter = 0
                                self.stopAudioPlayer()
                            }
                            pageobj.modalPresentationStyle = .fullScreen
                            self.localCallDB.addNewCall(call_id: random_id, contact_id: self.contact_id, status: "outgoing", call_type: "video", timestamp: Utility.shared.getTime(), unread_count: "0")
                            self.present(pageobj, animated: true, completion: nil)
                        }
                    }
                    
                    
                }else{
                    self.socketrecoonect()
                }
                
            }else{
                self.messageTextView.resignFirstResponder()
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
            }
        }
    }
    
    
    
    @IBAction func profileViewBtnTapped(_ sender: Any) {
        if self.isDeleted != "1"{
            self.isReload = false
            self.messageTextView.resignFirstResponder()
            let profileObj = ProfilePage()
            profileObj.viewType = "other"
            profileObj.chatID = self.chat_id
            profileObj.contactName = self.contactNameLbl.text!
            profileObj.contact_id = self.contact_id
            if self.counter != 0 {
                self.counter = 0
                self.stopAudioPlayer()
            }
            if viewType == "1" || viewType == "2" {
                profileObj.exitType = self.viewType
                profileObj.modalPresentationStyle = .fullScreen
                self.present(profileObj, animated: true, completion: nil)
            }else if viewType == "0"{
                profileObj.exitType = "0"
                profileObj.modalPresentationStyle = .fullScreen
                self.present(profileObj, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        if isDeleted != "1"{
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
            configMenu.bgColor = BACKGROUND_COLOR
            configMenu.allowRoundedArrow = true
            configMenu.tintColor = .red
            var frame = self.menuBtn.frame
            if UserModel.shared.getAppLanguage() == "عربى" {
                frame = CGRect(x: self.view.frame.origin.x + 5, y: self.menuBtn.frame.origin.y + self.menuBtn.frame.height + 10, width: self.menuBtn.frame.width, height: self.menuBtn.frame.height)
                alert.alignmentTag = 1
            }
            else {
                frame = CGRect(x: self.view.frame.width - 5, y: self.menuBtn.frame.origin.y + self.menuBtn.frame.height + 10, width: self.menuBtn.frame.width, height: self.menuBtn.frame.height)
                alert.alignmentTag = 1
            }
            
            FTPopOverMenu.show(fromSenderFrame: frame, withMenuArray: self.menuArray as? [Any], doneBlock: { selectedIndex in
                
                if selectedIndex == 0{
                    let mute:String = self.chatDetailDict.value(forKey: "mute") as! String
                    if mute == "0"{
                        alert.viewType = "3"
                        alert.msg = "mute_msg"
                        self.present(alert, animated: true, completion: nil)
                    }else if mute == "1"{
                        alert.viewType = "4"
                        alert.msg = "unmute_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if selectedIndex == 1{
                    let type:String = self.menuArray.object(at: 1) as! String
                    if type == "Block"{
                        alert.viewType = "0"
                        alert.msg = "block_msg"
                        self.present(alert, animated: true, completion: nil)
                    }else if type == "UnBlock"{
                        alert.viewType = "1"
                        alert.msg = "unblock_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if selectedIndex == 2{
                    if self.msgArray.count == 0 {
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_clear") as? String)
                    }
                    else {
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if selectedIndex == 3{
                    let contact_name:String = self.chatDetailDict.value(forKey: "contact_name") as! String
                    let phone_no:String = self.chatDetailDict.value(forKey: "user_phoneno") as! String
                    let cc: String = self.chatDetailDict.value(forKey: "countrycode") as! String
                    
                    if contact_name == "+\(cc) \(phone_no)" {
                        self.addAsContact()
                    }else{
                        self.addAsFavourite()
                    }
                }else if selectedIndex == 4{
                    self.addAsFavourite()
                }
            }, dismiss: {
            })
        }
    }
    
    func addAsFavourite()  {
        let fav:String = self.chatDetailDict.value(forKey: "favourite") as! String
        let alert = CustomAlert()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        if fav == "0" {
            alert.msg = "add_fav"
            alert.viewType = "5"
        }else{
            alert.msg = "remove_fav"
            alert.viewType = "6"
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //add new contact
    
    func addAsContact()  {
        let cc: String = self.chatDetailDict.value(forKey: "countrycode") as! String
        let phone_no:String = self.chatDetailDict.value(forKey: "user_phoneno") as! String
        let store = CNContactStore()
        let contact = CNMutableContact()
        let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :"+\(cc)\(phone_no)"))
        contact.phoneNumbers = [homePhone]
        contact.namePrefix = ""
        let controller: CNContactViewController = CNContactViewController(forNewContact: contact)
        controller.contactStore = store
        controller.delegate = self
        let navigationController: UINavigationController = UINavigationController(rootViewController: controller)
        //        controller.modalPresentationStyle = .overFullScreen
        self.navigationController?.isNavigationBarHidden = false
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: false) {
            // print("Present")
        }
        //        self.navigationController?.pushViewController(controller, animated: true)
        //        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
        if contact?.givenName != nil || contact != nil{
            self.localDB.updateName(cotact_id: self.contact_id, name: (contact?.givenName)!)
            DispatchQueue.global(qos: .background).async {
                Contact.sharedInstance.synchronize()
            }
            self.navigationController?.isNavigationBarHidden = true
            self.dismiss(animated: true, completion: nil)
            //            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.navigationController?.isNavigationBarHidden = true
            self.dismiss(animated: true, completion: nil)
            //            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
    //alert delegate
    func alertActionDone(type: String) {
        self.messageTextView.resignFirstResponder()
        if type == "0"{
            var blockType = String()
            self.blockByMe = "1"
            blockType = "block"
            self.configBlockedStatus()
            self.configFavStatus()
            socketClass.sharedInstance.blockContact(contact_id: self.contact_id, type: blockType)
        }else if type == "1"{
            var blockType = String()
            self.blockByMe = "0"
            blockType = "unblock"
            self.configBlockedStatus()
            self.configFavStatus()
            socketClass.sharedInstance.blockContact(contact_id: self.contact_id, type: blockType)
        }else if type == "2"{
            self.localDB.deleteChat(chat_id: self.chat_id)
            self.tempMsgs?.removeAllObjects()
            self.msgArray.removeAllObjects()
            self.msgTableView.reloadData()
        }else if type == "3"{
            socketClass.sharedInstance.muteStatus(chat_id: contact_id, type:"single" , status: "mute")
            self.localDB.updateMute(cotact_id: self.contact_id, status: "1")
            self.configMuteStatus()
        }else if type == "4"{
            socketClass.sharedInstance.muteStatus(chat_id: contact_id, type:"single" , status: "unmute")
            self.localDB.updateMute(cotact_id: self.contact_id, status: "0")
            self.configMuteStatus()
        }else if type == "5"{
            self.localDB.updateFavourite(cotact_id: contact_id, status: "1")
            self.configFavStatus()
        }else if type == "6"{
            self.localDB.updateFavourite(cotact_id: contact_id, status: "0")
            self.configFavStatus()
        }else if type == "7"{
            self.deleteForMeAct()
        }
    }
    func deleteImageAndVideoFromPhotoLibrary(onSuccess success: @escaping (Bool) -> Void) {
        var localPathArr = [String]()
        for i in selectedDict {
            let messageID = i.message_data.value(forKey: "message_id") as? String ?? ""
            let localMsg = localDB.getMsg(msg_id: messageID)
            let localPath = localMsg.value(forKeyPath: "message_data.local_path") as! String
            let senderID = i.sender_id
            let deleteType = i.message_data.value(forKey: "message_type") as? String ?? ""
            if (deleteType == "image" || deleteType == "video") && senderID != (UserModel.shared.userID() as String? ?? "") {
                localPathArr.append(localPath)
            }
        }
        PhotoAlbum.sharedInstance.delete(local_ID: localPathArr, onSuccess: {response in
            success(response)
        })
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
        self.deleteImageAndVideoFromPhotoLibrary(onSuccess: {response in
            if response {
                
                print("select idarr \(self.selectedIdArr)")
                self.localDB.deleteMsg(msg_id: selectedIDVal)
                
                for msgID in self.selectedIdArr{
                    print("msgID \(msgID)")
                    self.checkAndReplace(msg_id:msgID)
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
    func updateLastMsg() {
        if self.msgArray.count > 0 {
            let lastMsg = self.msgArray.object(at: self.msgArray.count - 1) as! messageModel.message
            if lastMsg.message_data.value(forKey: "message_type") as? String == "date_sticky" {
                if self.msgArray.count > 1 {
                    let lastMsg1 = self.msgArray.object(at: self.msgArray.count - 2) as! messageModel.message
                    self.localDB.updateRecentMessage(chat_id: self.chat_id, message_id: lastMsg1.message_data.value(forKey: "message_id") as? String ?? "You Deleted this message", time: lastMsg1.message_data.value(forKey: "chat_time") as? String ?? Utility.shared.getTime())
                }
            }else {
                self.localDB.updateRecentMessage(chat_id: self.chat_id, message_id: lastMsg.message_data.value(forKey: "message_id") as? String ?? "You Deleted this message", time: lastMsg.message_data.value(forKey: "chat_time") as? String ?? Utility.shared.getTime())
            }
        } else {
            self.localDB.updateRecentMessage(chat_id: self.chat_id, message_id: "You Deleted this message", time: "\(String(describing: time))")
        }
    }
    // getsture delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.msgTableView) == true {
            return false
        }
        return true
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
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
        if socket.status == .connected{
            let giphy = GiphyViewController()
            GiphyViewController.trayHeightMultiplier = 0.7
            giphy.shouldLocalizeSearch = true
            giphy.delegate = self
            giphy.theme = GPHTheme(type: .darkBlur)
            giphy.dimBackground = true
            //     giphy.showCheckeredBackground = true
            giphy.modalPresentationStyle = .overCurrentContext
            present(giphy, animated: true, completion: nil)
            
        }
        else{
            self.socketrecoonect()
        }
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)   {
        
        
        
        
        let gifURL : String = media.url(rendition: .fixedWidth, fileType: .gif)!
        if Utility.shared.isConnectedToNetwork() {
            
            if socket.status != .connected{
                socketClass.sharedInstance.connect()
            }
            
            if socket.status == .connected
            {
                
                // prepare socket  dict
                let msgDict = NSMutableDictionary()
                let time = NSDate().timeIntervalSince1970
                let msg_id = Utility.shared.random()
                let encryptMsg = cryptLib.encryptPlainTextRandomIV(withPlainText: "Gif", key: ENCRYPT_KEY)
                
                msgDict.setValue(encryptMsg, forKey: "message")
                msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
                msgDict.setValue(msg_id, forKey: "message_id")
                msgDict.setValue("gif", forKey: "message_type")
                msgDict.setValue(gifURL, forKey: "attachment")
                
                msgDict.setValue(self.contact_id, forKey: "receiver_id")
                msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                msgDict.setValue("1", forKey: "read_status")
                msgDict.setValue("single", forKey: "chat_type")
                msgDict.setValue(self.chatDetailDict.value(forKey: "user_phoneno"), forKey: "phone")
                
                let requestDict = NSMutableDictionary()
                requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                requestDict.setValue(self.contact_id, forKey: "receiver_id")
                requestDict.setValue(msgDict, forKey: "message_data")
                //send socket
                if blockByMe == "0" && blockedMe == "0"{
                    socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                    self.addToLocal(requestDict: requestDict)
                }else if blockByMe == "1"{
                    self.messageTextView.resignFirstResponder()
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                }else{
                    self.addToLocal(requestDict: requestDict)
                }
            }else{
                self.socketrecoonect()
            }
            self.messageTextView.text = EMPTY_STRING
        }
        
        // your user tapped a GIF!
        giphyViewController.dismiss(animated: true, completion: nil)
    }
    
    func didDismiss(controller: GiphyViewController?) {
        // your user dismissed the controller without selecting a GIF.
    }
    
    //text msg send btn
    @IBAction func sendBtnTapped(_ sender: Any){
        let txt = messageTextView.text.trimmingCharacters(in: .newlines)
        self.sendMsg(msg: txt)
        
    }
    /*
     
     func showSmartReplies(msg:String){
     
     var conversation: [TextMessage] = []
     let time = NSDate().timeIntervalSince1970
     
     // Then, for each message sent and received:
     let message = TextMessage(
     text: msg,
     timestamp: time,
     userID: "userId",
     isLocalUser: false)
     conversation.append(message)
     
     SmartReply.smartReply().suggestReplies(for: conversation) { result, error in
     
     let subViews = self.smartReplyView.subviews
     for subview in subViews{
     subview.removeFromSuperview()
     }
     guard error == nil, let result = result else {
     return
     }
     if (result.status == .notSupportedLanguage) {
     // The conversation's language isn't supported, so the
     // the result doesn't contain any suggestions.
     } else if (result.status == .success) {
     // Successfully suggested smart replies.
     // ...
     self.smartReplyView.isHidden = false
     self.scrollToBottom()
     var leftPadding = 5
     for suggestion in result.suggestions {
     print("Suggested reply: \(suggestion.text)")
     let suggestionBtn = UIButton()
     suggestionBtn.config(color: .white, size: 17, align: .center, title: "")
     suggestionBtn.setTitle(suggestion.text, for: .normal)
     suggestionBtn.addTarget(self,action:#selector(self.smartMsgSend),
     for:.touchUpInside)
     suggestionBtn.frame = CGRect.init(x: leftPadding, y: 5, width: Int(suggestionBtn.intrinsicContentSize.width)+30, height: 30)
     suggestionBtn.cornerRoundRadius()
     suggestionBtn.backgroundColor = SECONDARY_COLOR
     suggestionBtn.setBorder(color: SECONDARY_COLOR)
     suggestionBtn.titleEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
     self.smartReplyView.addSubview(suggestionBtn)
     leftPadding = Int(suggestionBtn.frame.origin.x+suggestionBtn.frame.size.width+5)
     self.smartReplyView.contentSize = CGSize.init(width: leftPadding+200, height: 50)
     }
     }
     }
     }
     */
    
    @objc func smartMsgSend(sender:UIButton)
    {
        print("msg btn tapp")
        self.smartReplyView.isHidden = true
        self.sendMsg(msg: (sender.titleLabel?.text)!)
        
    }
    func sendMsg(msg:String){
        
        if Utility.shared.isConnectedToNetwork() {
            if !Utility.shared.checkEmptyWithString(value: msg) {
                if socket.status != .connected{
                    socketClass.sharedInstance.connect()
                }
                // if isSocketConnected{
                if socket.status == .connected
                {
                    // prepare socket  dict
                    let subViews = self.smartReplyView.subviews
                    for subview in subViews{
                        subview.removeFromSuperview()
                    }
                    
                    let msgDict = NSMutableDictionary()
                    let msg_id = Utility.shared.random()
                    let cryptLib = CryptLib()
                    let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:msg, key: ENCRYPT_KEY)
                    
                    msgDict.setValue(encryptedMsg, forKey: "message")
                    
                    msgDict.setValue(msg_id, forKey: "message_id")
                    msgDict.setValue("text", forKey: "message_type")
                    msgDict.setValue(self.contact_id, forKey: "receiver_id")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    msgDict.setValue("1", forKey: "read_status")
                    msgDict.setValue("single", forKey: "chat_type")
                    //msgDict.setValue(self.chatDetailDict.value(forKey: "user_phoneno"), forKey: "phone")
                    //msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
                    
                    msgDict.setValue(UserModel.shared.userDict().value(forKey: "phone_no") as? String, forKey: "phone")
                    msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name") as? String, forKey: "user_name")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                    
                    let requestDict = NSMutableDictionary()
                    requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    requestDict.setValue(self.contact_id, forKey: "receiver_id")
                    requestDict.setValue(msgDict, forKey: "message_data")
                    //send socket
                    print("blockByMe: \(blockByMe), blockedMe: \(blockedMe)")
                    if blockByMe == "0" && blockedMe == "0"{
                        socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                        self.addToLocal(requestDict: requestDict)
                    }else if blockByMe == "1"{
                        self.messageTextView.resignFirstResponder()
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                    }else{
                        self.addToLocal(requestDict: requestDict)
                    }
//                    if audioEngine.isRunning {
                        self.audioEngine.stop()
                        self.recognitionRequest?.endAudio()
                    self.btnStart.setTitle("Start Recording", for: .normal)
//                    }
                    self.messageTextView.text = EMPTY_STRING
                    self.configSendBtn(enable: false)
                    self.ConfigVoiceBtn(enable: true)
                }else{
                    print("****socket not connectttttt")
                    self.socketrecoonect()
                }
            }
        }else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    // add to local db
    func addToLocal(requestDict:NSDictionary)  {
        // print("LOCAL DICT \(requestDict)")
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
        
        let type : String = requestDict.value(forKeyPath: "message_data.message_type") as! String
        if type == "image"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
        }else if type == "location"{
            lat = requestDict.value(forKeyPath: "message_data.lat") as! String
            lon = requestDict.value(forKeyPath: "message_data.lon") as! String
        }else if type == "contact"{
            //            cc = requestDict.value(forKeyPath: "message_data.cc") as! String
            cName = requestDict.value(forKeyPath: "message_data.contact_name") as! String
            cNo = requestDict.value(forKeyPath: "message_data.contact_phone_no") as! String
        }else if type == "video"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
            thumbnail = requestDict.value(forKeyPath: "message_data.thumbnail") as! String
        }else if type == "document"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
        }
        else if type == "audio"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
        }else if type == "gif"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
        }
        
        //add local db
        let msgDict = localDB.getMsg(msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String)
        var readCount =  String()
        if msgDict.value(forKeyPath: "message_data.read_status") == nil{
            readCount = "1"
        }else{
            readCount = msgDict.value(forKeyPath: "message_data.read_status") as! String
        }
        
        
        
        self.localDB.addChat(msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String,
                             chat_id: self.chat_id,
                             sender_id:requestDict.value(forKey: "sender_id")! as! String,
                             receiver_id:requestDict.value(forKey: "receiver_id")! as! String,
                             msg_type: requestDict.value(forKeyPath: "message_data.message_type") as! String,
                             msg: requestDict.value(forKeyPath: "message_data.message") as! String,
                             time: requestDict.value(forKeyPath: "message_data.chat_time") as! String,
                             lat: lat,
                             lon: lon,
                             contact_name: cName,
                             contact_no: cNo,
                             country_code: cc,
                             attachment: attach,thumbnail:thumbnail, read_count: readCount, statusData: "", blocked: self.blockedMe)
        if msgDict.value(forKey: "local_path") != nil {
            
        }
        let unreadcount = localDB.getUnreadCount(contact_id: self.contact_id)
        self.localDB.addRecent(contact_id: self.contact_id, msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String, unread_count: "\(unreadcount)",time: requestDict.value(forKeyPath: "message_data.chat_time") as! String)
        
        //add local array
        if isChatTranslation {
            self.translateMessage()
        } else {
            self.addMsgToLocal()
        }
        
        if Utility.shared.checkEmptyWithString(value: messageTextView.text) {
            self.configSendBtn(enable: false)
            self.ConfigVoiceBtn(enable:true)
        }else{
            self.configSendBtn(enable: true)
            self.ConfigVoiceBtn(enable:false)
        }
    }
    func addMsgToLocal() {
        isScrollBottom = false
        self.isFetch = false
        self.tempMsgs?.removeAllObjects()
        let newMsg = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
        self.tempMsgs = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
        self.msgArray.removeAllObjects()
        self.msgArray = newMsg!
        self.chatRead = false
        self.scrollTag = 0
        self.msgTableView.reloadData()
        self.scrollToBottom()
    }
    
    func translateMessage() {
        print("print the print msgDict \(self.translateDict)")
        if let msg_id = self.translateDict.value(forKeyPath: "message_data.message_id") as? String {
            if isTranslate{
                let cryptLib = CryptLib()
                let msg = self.translateDict.value(forKeyPath: "message_data.message") as! String
                let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText:msg, key: ENCRYPT_KEY)!
                Utility.shared.translate(msg: decryptedMsg, callback: { translatedTxt in
                    print("translated text 1 \(translatedTxt)")
                    DispatchQueue.main.async {
                        LocalStorage.sharedInstance.updateTranslated(msg_id:msg_id, msg: translatedTxt)
                        self.addMsgToLocal()
                    }
                })
            } else {
                self.addMsgToLocal()
            }
        } else {
            self.addMsgToLocal()
        }
    }
    
    //open attachment menu
    @IBAction func attachmentMenuBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        if self.attachmentShow{
            self.showAttachmentMenu(enable: false)
        }else{
            self.showAttachmentMenu(enable: true)
        }
    }
    
    
    func jsonToString(value: String) -> Dictionary<String, Any>? {
        let string = value
        let data = string.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
            {
                // print(jsonArray) // use the json here
                return jsonArray
            } else {
                // print("bad json")
            }
        } catch let error as NSError {
            // print(error)
        }
        return nil
    }
    @objc func imageGestureAct(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        let storage = storyStorage()
        let dict:messageModel.message = self.msgArray.object(at: tag ?? 0) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        let jsonString:String = msgDict.value(forKeyPath: "message_data.status_data") as? String ?? ""
        let cryptLib = CryptLib()
        let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: jsonString, key: ENCRYPT_KEY)
        
        if let value = self.jsonToString(value: decryptedMsg ?? "") {
            print(value)
            let id:String = value["story_id"] as? String ?? ""
            let stryData = storage.checkIfExsit(story_id: id).first
            if stryData != nil {
                if self.counter != 0 {
                    self.counter = 0
                    self.stopAudioPlayer()
                }
                let vc = ContentViewController()
                vc.modalPresentationStyle = .overFullScreen
                vc.infoUpdated = { dict,type in
                    print("******** get it ")
                    
                    self.gotSocketInfo(dict: dict, type: type)
                }
                let sender_id:String = dict.sender_id
                let own_id:String = UserModel.shared.userID()! as String
                var userStatus = RecentStoryModel(sender_id: stryData?.sender_id ?? "", story_id: stryData?.story_id ?? "", message: "", story_type: "", attachment: "", story_date: "", story_time: "", expiry_time: "", contactName: "", userName: "", phoneNumber: "", userImage: "", aboutUs: "", blockedMe: "", blockedByMe: "", mute: "", mutual_status: "", privacy_lastseen: "", privacy_about: "", privacy_image: "", favourite: "")
                if sender_id != own_id {
                    userStatus = RecentStoryModel(sender_id: stryData?.sender_id ?? "", story_id: stryData?.story_id ?? "", message: "", story_type: "", attachment: "", story_date: "", story_time: "", expiry_time: "", contactName: "", userName: "", phoneNumber: "", userImage: "", aboutUs: "", blockedMe: "", blockedByMe: "", mute: "", mutual_status: "", privacy_lastseen: "", privacy_about: "", privacy_image: "", favourite: "")
                }
                else {
                    userStatus = RecentStoryModel(sender_id: stryData?.sender_id ?? "", story_id: stryData?.story_id ?? "", message: "", story_type: "", attachment: "", story_date: "", story_time: "", expiry_time: "", contactName: self.contactNameLbl.text!, userName: "", phoneNumber: "", userImage: "", aboutUs: "", blockedMe: "", blockedByMe: "", mute: "", mutual_status: "", privacy_lastseen: "", privacy_about: "", privacy_image: "", favourite: "")
                }
                vc.pages = [userStatus]
                print(userStatus)
                vc.currentIndex = 0
                vc.isFromChat = true
                let statusDict = storage.getUserInfo(userID: stryData?.sender_id ?? "")
                let index = statusDict.firstIndex(where: {$0.story_id == stryData?.story_id})
                print(index)
                vc.segIndex = index ?? 0
                self.isReload = false
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @objc func respondToSlideEvents(sender: UISlider) {
        let currentValue: Float = Float(sender.value)
        // print("Event fired. Current value for slider: \(currentValue)%.")
        if self.tag_value == sender.tag {
            if str_value_tofind_which_voiceCell == "SenderAudioCell" {
                audioPlayer.currentTime = TimeInterval(currentValue)
                meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateUIWithTimer(_:)), userInfo:[sender.tag], repeats:true)
            }else if str_value_tofind_which_voiceCell == "ReceiverVoiceCell" {
                audioPlayer.currentTime = TimeInterval(currentValue)
                meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateUIWithTimer(_:)), userInfo:[sender.tag], repeats:true)
            }
        }
    }
    
    func makeSelection(tag:Int,index:IndexPath)  {
        let dict:messageModel.message = msgArray.object(at: tag) as! messageModel.message
        let msg_type = dict.message_data.value(forKey: "message_type") as! String
        //        if selectedIndexPath.count != 0 {
        //            let cell = view.viewWithTag(selectedIndexPath.row + 400) as? UITableViewCell
        //            cell?.backgroundColor = .clear
        //        }
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if msg_type != "date_sticky"{
            let id = dict.message_data.value(forKey: "message_id") as! String
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
                if id != nil {
                    self.selectedIdArr.remove(at: id ?? 0)
                    self.selectedDict.remove(at: id ?? 0)
                    let selectedIndex = self.selectedIndexArr.firstIndex(of: index)
                    self.selectedIndexArr.remove(at: selectedIndex ?? 0)
                    self.msgTableView.reloadData()
                }
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
            if self.messageTextView.becomeFirstResponder() {
                dismissKeyboard()
            }
        }
    }
    func checkDownloadStatus() {
        for dict in self.selectedDict {
            let downloadStatus = dict.message_data.value(forKey: "isDownload") as? String ?? ""
            let message_type = dict.message_data.value(forKey: "message_type") as! String
            print(message_type)
            if (message_type == "image" && message_type == "video" && message_type == "audio") && (downloadStatus == "0") && (dict.sender_id != UserModel.shared.userID() as String? ?? ""){
                self.forwardIconView.isHidden = true
                break
            } else {
                if message_type == "isDelete" {
                    self.forwardIconView.isHidden = true
                    self.copyIcon.isHidden = true
                    break
                }
                self.forwardIconView.isHidden = false
            }
        }
    }
    //    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    //        return 1
    //    }
    //
    //    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    //        return URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")! as QLPreviewItem
    //
    //    }
    
    func viewDoc(url:String){
        print("url \(url)")
        
        //        let document = Document(url: URL.init(string: url)!)
        //        let controller = PDFViewController(document: document)
        //        self.present(controller, animated: true, completion: nil)
        
        let webVC = SwiftModalWebVC(urlString: url)
        webVC.modalPresentationStyle = .fullScreen
        self.present(webVC, animated: true, completion: nil)
        
        
    }
    
    @objc func docuCellBtnTapped(_ sender: UIButton!)  {
        self.isReload = false
        
        self.messageTextView.resignFirstResponder()
        let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        print("doc details \(dict) tag no \(sender.tag)")
        if self.selectedIdArr.count == 0 {
            let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            if type != "date_sticky" {
                if type == "document"{
                    let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
                    let sender_id:String = dict.sender_id
                    let own_id:String = UserModel.shared.userID()! as String
                    let updatedDict = self.localDB.getMsg(msg_id: message_id)
                    var docName:String = updatedDict.value(forKeyPath: "message_data.local_path") as! String
                    if docName == "0"{
                        let serverLink = msgDict.value(forKeyPath: "message_data.attachment") as! String
                        docName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
                    }
                    
                    // print("-------------Audio_URL : %@",videoName)
                    _ = URL.init(string: docName)
                    let message = msgDict.value(forKeyPath: "message_data.message") as! String
                    let isDownload = msgDict.value(forKeyPath: "message_data.isDownload") as! String
                    if sender_id != own_id{
                        //check its downloaded
                        if isDownload == "0" || isDownload == "4"{
                            self.downloadDocument(index: sender.tag, model: dict)
                        }else if isDownload == "1"{
                            DispatchQueue.main.async {
                                var docuName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
                                // print("\(docuName)")
                                if self.counter != 0 {
                                    self.counter = 0
                                    self.stopAudioPlayer()
                                }
                                
                                let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                if docURL?.pathExtension == ""{
                                    docuName = "\(docuName).pdf"
                                }
                                //                                let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                //                                webVC.modalPresentationStyle = .fullScreen
                                //                                self.present(webVC, animated: true, completion: nil)
                                
                                
                                self.viewDoc(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                
                            }
                        }
                    }else{
                        //check if uploaded or not
                        if isDownload == "1" {
                            DispatchQueue.main.async {
                                var docuName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
                                // print("\(docuName)")
                                if self.counter != 0 {
                                    self.counter = 0
                                    self.stopAudioPlayer()
                                }
                                let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                if docURL?.pathExtension == ""{
                                    docuName = "\(docuName).pdf"
                                }
                                
                                
                                //                                let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                //                                webVC.modalPresentationStyle = .fullScreen
                                //                                self.present(webVC, animated: true, completion: nil)
                                
                                self.viewDoc(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                
                            }
                        }else if isDownload == "4"{//cancelled
                            if Utility.shared.isConnectedToNetwork(){
                                DispatchQueue.main.async {
                                    var docuName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
                                    // print("\(docuName)")
                                    if self.counter != 0 {
                                        self.counter = 0
                                        self.stopAudioPlayer()
                                    }
                                    let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                    if docURL?.pathExtension == ""{
                                        docuName = "\(docuName).pdf"
                                    }
                                    //                                    let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                    //                                    webVC.modalPresentationStyle = .fullScreen
                                    //                                    self.present(webVC, animated: true, completion: nil)
                                    
                                    self.viewDoc(url: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                    
                                }
                            } else{
                                self.messageTextView.resignFirstResponder()
                                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                let docuName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
                                //                                let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                                //                                webVC.modalPresentationStyle = .fullScreen
                                //                                self.present(webVC, animated: true, completion: nil)
                                
                                self.viewDoc(url:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
                            }
                        }
                    }
                }
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, index: indexpath)
        }
    }
    //image cell process
    @objc func receiverImageCellBtnTapped(_ sender: UIButton!)  {
        let cell = view.viewWithTag(sender.tag + 50000) as? ReceiverImageCell
        let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
        if cell!.ImageFileView.image != nil{
            self.imageAction(dict: dict, tagNum: sender.tag, image: cell!.ImageFileView.image!)
        }
        
    }
    @objc func senderImageCellBtnTapped(_ sender: UIButton!)  {
        let cell = view.viewWithTag(sender.tag + 50000) as? SenderImageCell
        let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
        if cell!.ImageFileView.image != nil{
            self.imageAction(dict: dict, tagNum: sender.tag, image: cell!.ImageFileView.image!)
        }
    }
    func imageAction(dict:messageModel.message,tagNum:Int,image:UIImage)  {
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        if self.selectedIdArr.count == 0 {
            let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            if type != "date_sticky" {
                if self.counter != 0 {
                    self.counter = 0
                    self.stopAudioPlayer()
                }
                let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
                let sender_id:String = dict.sender_id
                let own_id:String = UserModel.shared.userID()! as String
                
                DispatchQueue.main.async {
                    let updatedDict = self.localDB.getMsg(msg_id: message_id)
                    let local_path:String = updatedDict.value(forKeyPath: "message_data.local_path") as! String
                    if sender_id != own_id{
                        let isDownload:String = msgDict.value(forKeyPath: "message_data.isDownload") as! String
                        if (isDownload == "0" || isDownload == "4") && local_path == "0"{
                            self.downloadImage(index: tagNum, model:dict)
                        }else{
                            self.localDB.updateDownload(msg_id: message_id, status: "1")
                            self.openPic(identifier: local_path,msgDict:updatedDict)
                            
                            let imageInfo = GSImageInfo.init(image:image, imageMode: .aspectFit)
                            let transitionInfo = GSTransitionInfo(fromView: self.view)
                            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                            imageViewer.modalPresentationStyle = .fullScreen
                            self.present(imageViewer, animated: true, completion: nil)
                        }
                    }else{
                        let imageInfo = GSImageInfo.init(image:image, imageMode: .aspectFit)
                        let transitionInfo = GSTransitionInfo(fromView: self.view)
                        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                        imageViewer.modalPresentationStyle = .fullScreen
                        self.present(imageViewer, animated: true, completion: nil)
                        
                    }
                }
            }
        }else{
            let indexpath = IndexPath.init(row: tagNum, section: 0)
            self.makeSelection(tag: tagNum, index: indexpath)
        }
    }
    @objc func videoCellBtnTapped(_ sender: UIButton!)  {
        self.isReload = false
        
        let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        if self.selectedIdArr.count == 0 {
            let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            if type != "date_sticky" {
                let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
                let sender_id:String = dict.sender_id
                let own_id:String = UserModel.shared.userID()! as String
                
                
                let updatedDict = self.localDB.getMsg(msg_id: message_id)
                var videoName:String = updatedDict.value(forKeyPath: "message_data.local_path") as! String
                if videoName == "0"{
                    let serverLink = msgDict.value(forKeyPath: "message_data.attachment") as! String
                    videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
                }
                let videoURL = URL.init(string: videoName)
                let player = AVPlayer(url: videoURL!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                playerViewController.allowsPictureInPicturePlayback = false
                let isDownload:String = msgDict.value(forKeyPath: "message_data.isDownload") as! String
                if sender_id != own_id{
                    //check its downloaded
                    if isDownload == "0" || isDownload == "4"{
                        self.downloadVideo(index: sender.tag, model: dict)
                    }else if isDownload == "1"{
                        if self.counter != 0 {
                            self.counter = 0
                            self.stopAudioPlayer()
                        }
                        playerViewController.modalPresentationStyle = .fullScreen
                        self.present(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }
                    }
                }else{
                    //check if uploaded or not
                    if isDownload == "1" {
                        if self.counter != 0 {
                            self.counter = 0
                            self.stopAudioPlayer()
                        }
                        playerViewController.modalPresentationStyle = .fullScreen
                        self.present(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }
                    }else if isDownload == "4"{//cancelled
                        if Utility.shared.isConnectedToNetwork(){
                            let msg_id:String = updatedDict.value(forKeyPath: "message_data.message_id") as! String
                            self.localDB.updateDownload(msg_id: msg_id, status: "2")
                            self.scrollTag = 1
                            self.msgTableView.reloadData()
                            PhotoAlbum.sharedInstance.getVideo(local_ID: videoURL!, msg_id: msg_id, requestData: updatedDict,type:(videoURL?.pathExtension)!)
                        } else{
                            self.messageTextView.resignFirstResponder()
                            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
                        }
                    }
                }
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, index: indexpath)
        }
    }
    
    @objc func locationTapped(_ sender: UIButton!)  {
        let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        if self.selectedIdArr.count == 0 {
            let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            if type != "date_sticky" {
                if self.counter != 0 {
                    self.counter = 0
                    self.stopAudioPlayer()
                }
                self.isReload = false
                
                let locationObj = PickLocation()
                locationObj.type = "1"
                locationObj.locationDict = msgDict
                locationObj.modalPresentationStyle = .fullScreen
                self.navigationController?.present(locationObj, animated: true, completion: nil)
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, index: indexpath)
        }
    }
    
    @objc func addToContact(_ sender: UIButton!)  {
        let dict:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
        self.isReload = false
        
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        if #available(iOS 9.0, *) {
            let phoneNo:String = msgDict.value(forKeyPath: "message_data.cNo") as! String
            let name:String = msgDict.value(forKeyPath: "message_data.cName") as! String
            let store = CNContactStore()
            let contact = CNMutableContact()
            //            let phoneStr = phoneNo.replacingCharacters(in: "+", with: "")
            let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :phoneNo))
            contact.phoneNumbers = [homePhone]
            contact.namePrefix = name
            let controller = CNContactViewController(forUnknownContact : contact)
            controller.contactStore = store
            controller.delegate = self
            controller.modalPresentationStyle = .fullScreen
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func supportedLanguageBtnTapped(_ sender: Any) {
        self.isReload = false
        
        let languageObj =  ChooseLanguage()
        languageObj.viewType = "translate"
        languageObj.modalPresentationStyle = .fullScreen
        self.navigationController?.present(languageObj, animated: true, completion: nil)
    }
    
    @objc func translateBtnTapped(_ sender: UIButton!)  {
        let model:messageModel.message = msgArray.object(at: sender.tag) as! messageModel.message
        Utility.shared.translate(msg: model.message_data.value(forKey: "message") as! String, callback: { translatedTxt in
            DispatchQueue.main.async {
                let msgDict = NSMutableDictionary.init(dictionary: model.message_data)
                msgDict.removeObject(forKey: "message")
                msgDict.setValue(translatedTxt, forKey: "message")
                msgDict.setValue(translatedTxt, forKey: "translated_msg")
                
                print("translated text \(translatedTxt)")
                
                LocalStorage.sharedInstance.updateTranslated(msg_id: msgDict.value(forKey: "message_id") as! String, msg: translatedTxt)
                
                let newModel = messageModel.message.init(sender_id: model.sender_id, receiver_id: model.receiver_id, message_data:msgDict, date: model.date)
                self.msgArray.removeObject(at: sender.tag)
                self.msgArray.insert(newModel, at: sender.tag)
                print(self.msgArray)
                self.scrollTag = 1
                self.msgTableView.reloadData()
            }
        })
    }
    
    
    //move to gallery
    func openPic(identifier:String,msgDict:NSDictionary){
        DispatchQueue.main.async {
            self.isReload = false
            if identifier != "0" {
                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
                if galleryPic == nil{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "item_not_found") as? String)
                }else{
                    if self.counter != 0 {
                        self.counter = 0
                        self.stopAudioPlayer()
                    }
                    let imageInfo = GSImageInfo.init(image: galleryPic!, imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView: self.view)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                    imageViewer.modalPresentationStyle = .fullScreen
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                let imageName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
                let data = try? Data(contentsOf: imageURL!)
                var image =  UIImage()
                if let imageData = data {
                    image = UIImage(data: imageData) ?? #imageLiteral(resourceName: "profile_placeholder")
                }
                let imageInfo = GSImageInfo.init(image: image, imageMode: .aspectFit, imageHD: nil)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                if self.counter != 0 {
                    self.counter = 0
                    self.stopAudioPlayer()
                }
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
    
    func getDataFromAssetAtUrl( assetUrl: URL, success: @escaping (_ data: NSData) -> ()){
        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [assetUrl], options: nil)
        if let phAsset = fetchResult.firstObject {
            PHImageManager.default().requestImageData(for: phAsset, options: nil) {
                (imageData, dataURI, orientation, info) -> Void in
                if let imageDataExists = imageData {
                    success(imageDataExists as NSData)
                }
            }
        }
    }
    @IBAction func goToBottom(_ sender: Any) {
        //        self.msgTableView.reloadData()
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
        UIView.performWithoutAnimation {
            
            let currentOffset = self.msgTableView.contentOffset
            let pageHeight = self.msgTableView.contentSize.height - (FULL_HEIGHT - 100)
            
            if currentOffset.y < pageHeight{
                self.adjustDownView()
                self.downView.isHidden = false
            }else{
                self.downView.isHidden = true
                self.newMsgView.isHidden = true
            }
            
            if currentOffset.y < 50{
                if isFetch == false {
                    isFetch = true
                    //get new msg from service based on offset
                    var previousMsg:AnyObject?
                    let tempArray = NSMutableArray()
                    tempArray.addObjects(from: tempMsgs as! [Any])
                    
                    previousMsg = self.localDB.getChat(chat_id: self.chat_id, offset: "\(tempArray.count)")
                    //                previousMsg = self.localDB.getChat(chat_id: self.chat_id, offset: "20")
                    
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
                        if self.msgArray.count != 0 {
                            // Put your code which should be executed with a delay here
                            UIView.performWithoutAnimation {
                                print("*********** reload")
                                UIView.setAnimationsEnabled(false)
                                self.msgTableView.reloadData()
                                let indexPath = IndexPath(row: (previousMsg?.count)!, section: 0)
                                self.msgTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                self.isFetch = false
                                UIView.setAnimationsEnabled(true)
                            }
                        }
                    }
                }
            }else{
                //            if !isScrollBottom{
                //                viewDidLayoutSubviews()
                //                isScrollBottom = true
                //            }
            }
            
        }
    }
    
    //DOWNLOAD IMAGE
    func downloadImage(index:Int, model :messageModel.message)  {
        let msgDict = NSMutableDictionary()
        msgDict.setValue(model.message_data, forKey: "message_data")
        let messageID:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        let oldMsgDict = NSMutableDictionary.init(dictionary: model.message_data)
        self.localDB.updateDownload(msg_id: messageID, status: "2")
        let cell = view.viewWithTag(index + 50000) as? ReceiverImageCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        cell?.downloadIcon.isHidden = true
        cell?.downloadView.isHidden = true
        let imageName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
        
        DispatchQueue.global(qos: .background).async {
            let imageURL = URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
            
            let data = try? Data(contentsOf: imageURL!)
            if let imageData = data {
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                    let messageID:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
                    if image != nil{
                        PhotoAlbum.sharedInstance.save(image: image!, msg_id: messageID,type:"single")
                    }
                    self.localDB.updateDownload(msg_id: messageID, status: "1")
                    
                    oldMsgDict.removeObject(forKey: "isDownload")
                    oldMsgDict.setValue("1", forKey: "isDownload")
                    let newModel = messageModel.message.init(sender_id: model.sender_id, receiver_id: model.receiver_id, message_data:oldMsgDict, date: model.date)
                    self.msgArray.removeObject(at: index)
                    self.msgArray.insert(newModel, at: index)
                    self.scrollTag = 1
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.msgTableView.reloadRows(at: [indexPath], with: .fade)
                        
                    }
                }
                
            }
            
            
        }
    }
    
    //DOWNLOAD Document
    func downloadDocument(index:Int, model :messageModel.message)  {
        
        let msgDict = NSMutableDictionary()
        msgDict.setValue(model.message_data, forKey: "message_data")
        let messageID:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        let oldMsgDict = NSMutableDictionary.init(dictionary: model.message_data)
        print("msgDict \(msgDict)")
        self.localDB.updateDownload(msg_id: messageID, status: "2")
        let cell = view.viewWithTag(index) as? ReceiverDocuCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        cell?.downloadIcon.isHidden = true
        
        let videoName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(videoName)"),
               let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(videoName)"
                //                DispatchQueue.main.async {
                
                urlData.write(toFile: filePath, atomically: true)
                DispatchQueue.main.async {
                    self.localDB.updateDownload(msg_id: messageID, status: "1")
                    oldMsgDict.removeObject(forKey: "isDownload")
                    oldMsgDict.setValue("1", forKey: "isDownload")
                    let newModel = messageModel.message.init(sender_id: model.sender_id, receiver_id: model.receiver_id, message_data:oldMsgDict, date: model.date)
                    self.msgArray.removeObject(at: index)
                    self.msgArray.insert(newModel, at: index)
                    let localObj = LocalStorage()
                    localObj.updateLocalURL(msg_id: messageID, url: filePath)
                    DispatchQueue.main.async {
                        self.scrollTag = 1
                        self.msgTableView.reloadData()
                    }
                }
                //                }
            }
            
            
        }
    }
    
    //show & hide attachment menu view
    func showAttachmentMenu(enable:Bool)  {
        if !enable{
            self.attachmentShow = false
            self.attachmentMenuView.isHidden = false
            
        }else{
            //open
            self.attachmentShow = true
            self.attachmentMenuView.isHidden = true
            //            self.msgTableView.frame.size.height -= 60
            //            self.bootomInputView.frame.origin.y -= 60
            //            self.attachmentMenuView.frame.origin.y = FULL_HEIGHT-60
        }
    }
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        self.isKeyborad = true
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //        self.showAttachmentMenu(enable: false)
        self.attachmentShow = true
        if UIDevice.current.hasNotch{
            self.bottomConst.constant = keyboardFrame.height-35
            keybordHeight = keyboardFrame.height-35
        }else{
            self.bottomConst.constant = keyboardFrame.height-8
            keybordHeight = keyboardFrame.height-8
        }
        
        print("Keyboard OverLap \(self.bottomConst.constant)")
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
        if msgArray.count != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.chatCount = self.msgArray.count
                self.scrollToBottom()
            }
        }
    }
    
    @objc func endTyping(_ timeStamp: Date?) {
        if (timeStamp == self.timeStamp) {
            self.sendEndTyping()
        }
    }
    
    func sendEndTyping() {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
        let sender_id:String = UserModel.shared.userID()! as String
        let receiver_id:String = self.chatDetailDict.value(forKey: "user_id") as! String
        
        requestDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
        requestDict.setValue("untyping", forKey: "type")
        if self.blockedMe != "1" && blockByMe == "0"{
            socketClass.sharedInstance.sendTypingStatus(requestDict: requestDict)
        }
        self.startTyping = false
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
    
    func ConfigVoiceBtn(enable:Bool){
        if(enable){
            self.record_btn_ref.isUserInteractionEnabled = true
            self.record_btn_ref.isHidden = false
        }else {
            self.record_btn_ref.isUserInteractionEnabled = false
            self.record_btn_ref.isHidden = true
        }
    }
    
    //MARK: ***************** LOCATION PICKER METHODS *********************
    
    @IBAction func locationBtnTapped(_ sender: Any) {
        
        if Utility.shared.isConnectedToNetwork() {
            
            if socket.status == .connected{
                self.isReload = false
                let locationObj = PickLocation()
                locationObj.delegate = self
                if self.counter != 0 {
                    self.counter = 0
                    self.stopAudioPlayer()
                }
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
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        if socket.status == .connected
        {
            
            let msgDict = NSMutableDictionary()
            let msg_id = Utility.shared.random()
            
            msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
            msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
            msgDict.setValue(msg_id, forKey: "message_id")
            msgDict.setValue("1", forKey: "read_status")
            msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
            let encryptedLat = cryptLib.encryptPlainTextRandomIV(withPlainText:"\(location.coordinate.latitude)", key: ENCRYPT_KEY)
            let encryptedLon = cryptLib.encryptPlainTextRandomIV(withPlainText:"\(location.coordinate.longitude)", key: ENCRYPT_KEY)
            
            msgDict.setValue(encryptedLat, forKey: "lat")
            msgDict.setValue(encryptedLon, forKey: "lon")
            msgDict.setValue(self.contact_id, forKey: "receiver_id")
            msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
            msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
            msgDict.setValue("single", forKey: "chat_type")
            
            msgDict.setValue(UserModel.shared.userDict().value(forKey: "phone_no") as? String, forKey: "phone")
            msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name") as? String, forKey: "user_name")
            msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
            
            let requestDict = NSMutableDictionary()
            requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
            requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
            msgDict.setValue("location", forKey: "message_type")
            let msg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Location", key: ENCRYPT_KEY)
            msgDict.setValue(msg, forKey: "message")
            requestDict.setValue(msgDict, forKey: "message_data")
            if blockByMe == "0" && blockedMe == "0"{
                socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                self.addToLocal(requestDict: requestDict)
            }else if blockByMe == "1"{
                self.messageTextView.resignFirstResponder()
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
            }else{
                self.addToLocal(requestDict: requestDict)
            }
        }else{
            self.socketrecoonect()
        }
    }
    //MARK: ***************** DOCUMENT PICKER METHODS *********************
    
    @IBAction func fileBtnTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork() {
            if self.counter != 0 {
                self.counter = 0
                self.stopAudioPlayer()
            }
            if socket.status == .connected{
                picDocument()
            } else{
                self.socketrecoonect()
            }
        }else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    //MARK: pic document from docment drobox icloud
    func picDocument()  {
        self.isReload = false
        
        let types: NSArray = NSArray.init(objects: kUTTypePDF,kUTTypeText)
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as! [String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    //MARK: Document picker delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // you get from the urls parameter the urls from the files selected
        let fileData = NSData.init(contentsOf: URL.init(string: "\(url)")!)
        let fileName = url.lastPathComponent
        let extensionType = ".\(url.pathExtension)"
        self.fileUpload(name: fileName, docuData: fileData!, type: extensionType)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // you get from the urls parameter the urls from the files selected
        let fileData = NSData.init(contentsOf: URL.init(string: "\(urls[0])")!)
        let fileName = urls[0].lastPathComponent
        let extensionType = ".\(urls[0].pathExtension)"
        print("Path Extension \(urls[0].pathExtension)")
        self.fileUpload(name: fileName, docuData: fileData!, type: extensionType)
    }
    
    func fileUpload(name:String,docuData:NSData,type:String)  {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue("1", forKey: "read_status")
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
        msgDict.setValue("document", forKey: "message_type")
        let encryptMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:name, key: ENCRYPT_KEY)
        msgDict.setValue(encryptMsg, forKey: "message")
        self.uploadFiles(msgDict: msgDict, requestDict: requestDict, attachData: docuData as Data, type:type , image: nil)
    }
    
    //MARK: ***************** CONTACT PICKER METHODS *********************
    @IBAction func contactBtnTapped(_ sender: Any) {
        
        if Utility.shared.isConnectedToNetwork() {
            if socket.status == .connected{
                requestForAccess { (accessGranted) in
                    if accessGranted == true{
                        self.isReload = false
                        
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
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        if socket.status == .connected
        {
            if contact.isKeyAvailable(CNContactPhoneNumbersKey){
                
                if contact.phoneNumbers.count != 0  {
                    // handle the selected contact
                    let msgDict = NSMutableDictionary()
                    let msg_id = Utility.shared.random()
                    
                    msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                    msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
                    msgDict.setValue(msg_id, forKey: "message_id")
                    msgDict.setValue("1", forKey: "read_status")
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    let encryptedname = cryptLib.encryptPlainTextRandomIV(withPlainText:contact.givenName, key: ENCRYPT_KEY)
                    let encryptedmsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Contact", key: ENCRYPT_KEY)
                    
                    msgDict.setValue(encryptedname, forKey: "contact_name")
                    msgDict.setValue(self.contact_id, forKey: "receiver_id")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                    msgDict.setValue("single", forKey: "chat_type")
                    //                msgDict.setValue(self.chatDetailDict.value(forKey: "user_phoneno"), forKey: "phone")
                    msgDict.setValue(UserModel.shared.userDict().value(forKey: "phone_no") as? String, forKey: "phone")
                    msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name") as? String, forKey: "user_name")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                    
                    let requestDict = NSMutableDictionary()
                    requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
                    
                    msgDict.setValue("contact", forKey: "message_type")
                    msgDict.setValue(encryptedmsg, forKey: "message")
                    requestDict.setValue(msgDict, forKey: "message_data")
                    if contact.phoneNumbers.count == 1 {
                        
                        if socket.status != .connected{
                            socketClass.sharedInstance.connect()
                        }
                        if socket.status == .connected
                        {
                            
                            let encryptedno = self.cryptLib.encryptPlainTextRandomIV(withPlainText: (contact.phoneNumbers.first?.value.value(forKey: "digits") as? String ?? ""), key: ENCRYPT_KEY)
                            msgDict.setValue(encryptedno, forKey: "contact_phone_no")
                            if self.blockByMe == "0" && self.blockedMe == "0"{
                                socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                                self.addToLocal(requestDict: requestDict)
                            }else if self.blockByMe == "1"{
                                self.messageTextView.resignFirstResponder()
                                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                            }else{
                                self.addToLocal(requestDict: requestDict)
                            }
                            
                        }else{
                            self.socketrecoonect()
                        }
                    }
                    else {
                        if socket.status != .connected{
                            socketClass.sharedInstance.connect()
                        }
                        if socket.status == .connected
                        {
                            self.isReload = false
                            
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
                                
                                if self.blockByMe == "0" && self.blockedMe == "0"{
                                    socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                                    self.addToLocal(requestDict: requestDict)
                                }else if self.blockByMe == "1"{
                                    self.messageTextView.resignFirstResponder()
                                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                                }else{
                                    self.addToLocal(requestDict: requestDict)
                                }
                            }
                            self.navigationController?.pushViewController(pageObj, animated: true)
                        }else{
                            self.socketrecoonect()
                        }
                    }
                    
                    
                }else{
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
    func openCamera()  {
        //access allowed
        if Utility.shared.isConnectedToNetwork() {
            self.isReload = false
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.galleryType = "1"
                let imagePicker = UIImagePickerController()
                //                imagePicker.mediaTypes = ["public.image", "public.movie"]
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                if self.counter != 0 {
                    self.counter = 0
                    self.stopAudioPlayer()
                }
                //                imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
                imagePicker.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cance", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
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
        if Utility.shared.isConnectedToNetwork() {
            if socket.status == .connected{
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    self.isReload = false
                    
                    self.galleryType = "2"
                    let imagePicker = UIImagePickerController()
                    imagePicker.mediaTypes = ["public.image", "public.movie"]
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary;
                    imagePicker.allowsEditing = false
                    if self.counter != 0 {
                        self.counter = 0
                        self.stopAudioPlayer()
                    }
                    imagePicker.modalPresentationStyle = .fullScreen
                    //                imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
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
        msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue("1", forKey: "read_status")
        
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
        
        var attachData = Data()
        var type =  String()
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                // print("infor \(info)")
                // print("image orientation \(image.imageOrientation.rawValue)")
                
                if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] {
                    let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL as! URL], options: nil)
                    msgDict.setValue(result.firstObject?.localIdentifier, forKey: "local_path")
                }
                
                attachData = image.jpegData(compressionQuality: 0.1)!//UIImageJPEGRepresentation(image, 0.5)!
                if galleryType == "1"{
                    type = ".jpg"
                }else{
                    let assetPath = info[UIImagePickerController.InfoKey.referenceURL] as! NSURL
                    if (assetPath.absoluteString?.hasSuffix("JPG"))! {
                        type = ".jpg"
                    } else if (assetPath.absoluteString?.hasSuffix("jpeg"))! {
                        type = ".jpeg"
                    }else if (assetPath.absoluteString?.hasSuffix("PNG"))! {
                        type = ".png"
                    }
                }
                msgDict.setValue("image", forKey: "message_type")
                let encryptMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Image", key: ENCRYPT_KEY)
                
                msgDict.setValue(encryptMsg, forKey: "message")
                self.uploadFiles(msgDict: msgDict, requestDict: requestDict, attachData: attachData, type: type, image: image)
            }
            // ********VIDEO PICKER**********
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
                        let encryptMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Video", key: ENCRYPT_KEY)
                        
                        msgDict.setValue(encryptMsg, forKey: "message")
                        
                        msgDict.setValue("\((info[UIImagePickerController.InfoKey.referenceURL])!)", forKey: "local_path")
                        self.uploadThumbnail(msgDict: msgDict, requestDict: requestDict, attachData: videoData!, fileURL: fileURL, type: type)
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
    func uploadThumbnail(msgDict: NSDictionary, requestDict: NSDictionary, attachData: NSData,fileURL:NSURL,type:String)  {
        if Utility.shared.isConnectedToNetwork() {
            let image = Utility.shared.thumbnailForVideoAtURL(url: fileURL as URL)
            //            let flippedImage = UIImage(cgImage: (image?.cgImage)!, scale: (image?.scale)!, orientation: .right)
            let thumbData =  image?.jpegData(compressionQuality: 0)//UIImageJPEGRepresentation(flippedImage, 0.5)!
            let uploadObj = UploadServices()
            //upload thumbnail
            print("******video upload thumbnail")
            uploadObj.uploadFiles(fileData: thumbData!, type: ".jpg", user_id: UserModel.shared.userID()! as String,docuName:msgDict.value(forKey: "message") as! String, msg_id: msgDict.value(forKey: "message_id") as! String,api_type:"private", onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    let encryptThumbnail = self.cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                    msgDict.setValue(encryptThumbnail, forKey: "thumbnail")
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    msgDict.setValue(self.contact_id, forKey: "receiver_id")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                    msgDict.setValue(EMPTY_STRING, forKey: "attachment")
                    msgDict.setValue("single", forKey: "chat_type")
                    msgDict.setValue("2", forKey: "isDownload")
                    requestDict.setValue(msgDict, forKey: "message_data")
                    if self.blockByMe == "1"{
                        self.messageTextView.resignFirstResponder()
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                    }else{
                        //upload video file
                        self.addToLocal(requestDict: requestDict)
                        self.localDB.updateDownload(msg_id: msgDict.value(forKey: "message_id") as! String, status: "2")
                        let videoName:String = fileURL.lastPathComponent!
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                        let filePath="\(documentsPath)/\(videoName)"
                        attachData.write(toFile: filePath, atomically: true)
                        if self.galleryType == "1"{ // SAVE VIDEO TO GALLERY
                            if  msgDict.value(forKey: "message_id") != nil{
                                PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "single")
                            }
                        }else{
                            self.localDB.updateLocalURL(msg_id: msgDict.value(forKey: "message_id") as! String, url:msgDict.value(forKey: "local_path") as! String)
                        }
                        socketClass.sharedInstance.uploadChatVideo(fileData: attachData as Data, type: type, msg_id: msgDict.value(forKey: "message_id") as! String, requestDict: requestDict,blockedbyMe: self.blockByMe,blockedMe: self.blockedMe)
                    }
                }
            })
            dismiss(animated:true, completion: nil)
        }else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    
    //upload files
    func uploadFiles(msgDict:NSDictionary,requestDict:NSDictionary,attachData:Data,type:String,image:UIImage?){
        if Utility.shared.isConnectedToNetwork() {
            if socket.status != .connected{
                socketClass.sharedInstance.connect()
            }
            if socket.status == .connected
            {
                let cryptLib = CryptLib()
                
                let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText:msgDict.value(forKey: "message") as? String, key: ENCRYPT_KEY)!
                
                let uploadObj = UploadServices()
                uploadObj.uploadFiles(fileData: attachData, type: type, user_id: UserModel.shared.userID()! as String,docuName:decryptedMsg,msg_id: msgDict.value(forKey: "message_id") as! String,api_type:"private", onSuccess: {response in
                    let status:String = response.value(forKey: "status") as! String
                    if status == STATUS_TRUE{
                        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                        print("docRes \(response)")
                        let encryptedAttachment = cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String ?? "", key: ENCRYPT_KEY)
                        msgDict.setValue(encryptedAttachment, forKey: "attachment")
                        msgDict.setValue(self.contact_id, forKey: "receiver_id")
                        msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                        msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                        msgDict.setValue("1", forKey: "isDownload")
                        msgDict.setValue("single", forKey: "chat_type")
                        //                    msgDict.setValue(self.chatDetailDict.value(forKey: "user_phoneno"), forKey: "phone")
                        msgDict.setValue(UserModel.shared.userDict().value(forKey: "phone_no") as? String, forKey: "phone")
                        msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name") as? String, forKey: "user_name")
                        msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                        
                        requestDict.setValue(msgDict, forKey: "message_data")
                        
                        if socket.status != .connected{
                            socketClass.sharedInstance.connect()
                        }
                        if socket.status == .connected
                        {
                            
                            //send socket
                            if self.blockByMe == "0" && self.blockedMe == "0"{
                                socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                                self.addToLocal(requestDict: requestDict)
                            }else if self.blockByMe == "1"{
                                self.messageTextView.resignFirstResponder()
                                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                            }else{
                                self.addToLocal(requestDict: requestDict)
                            }
                        }else{
                            
                            if socket.status != .connected{
                                self.view.makeToast("Please wait ...", duration: 1, position: .center)
                                socketClass.sharedInstance.connect()
                            }
                        }
                        //check if photo is already exists in gallery
                        let msgType:String = msgDict.value(forKey: "message_type") as! String
                        if msgType == "image"{
                            if msgDict.value(forKey: "local_path") != nil{
                                if !PhotoAlbum.sharedInstance.checkExist(identifier: msgDict.value(forKey: "local_path") as! String)!{
                                    if image != nil && msgDict.value(forKey: "message_id") != nil && self.galleryType == "1"{
                                        
                                        PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "single")
                                    }
                                }else{
                                    self.localDB.updateLocalURL(msg_id: msgDict.value(forKey: "message_id") as! String, url: msgDict.value(forKey: "local_path") as! String)
                                }
                            }else{
                                if image != nil && msgDict.value(forKey: "message_id") != nil && self.galleryType == "1"{
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
    
    
    //MARK: ********* SOCKET RESPONSE ********
    func gotSocketInfo(dict: NSDictionary, type: String) {
        
        if type == "receivechat" {
            print("******** check it ")
            let sender_id:String = dict.value(forKey: "sender_id") as! String
            if sender_id == self.contact_id{
                let cryptLib = CryptLib()
                let msg:String = dict.value(forKeyPath: "message_data.message") as! String
                let msg_id:String = dict.value(forKeyPath: "message_data.message_id") as! String
                let msg_type:String = dict.value(forKeyPath: "message_data.message_type") as? String ?? ""
                let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText:msg, key: ENCRYPT_KEY)!
                self.translateDict = dict
                print("print the print msgDict siva \(self.translateDict)")
                print("print the print msgDict sivakumar \(dict)")
                if UserModel.shared.getListen() {
                    SpeechService.shared.startSpeech(decryptedMsg)
                }
                
                // smart reply add-on
                //                if msg_type == "text" {
                ////                    self.showSmartReplies(msg: decryptedMsg)
                //                }
                
                if isTranslate{
                    //Translate add-on
                    Utility.shared.translate(msg: decryptedMsg, callback: { translatedTxt in
                        print("translated text 1 \(translatedTxt)")
                        DispatchQueue.main.async {
                            LocalStorage.sharedInstance.updateTranslated(msg_id:msg_id, msg: translatedTxt)
                            if !self.msgIDs.contains(msg_id){
                                self.msgIDs.add(msg_id)
                                let timeStr = self.localDB.getLastMsgTime(chat_id: self.chat_id)
                                if timeStr == ""{
                                    let newMsg = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
                                    self.tempMsgs = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
                                    self.msgArray.removeAllObjects()
                                    self.msgArray = newMsg!
                                }else{
                                    if let newMsg = self.localDB.getParticularMsg(msg_id: msg_id) {
                                        self.msgArray.add(newMsg)
                                        self.tempMsgs?.add(newMsg)
                                    }
                                }
                                self.msgTableView.reloadData()
                                self.scrollToBottom()
                            }
                        }
                    })
                }else{
                    
                    
                    if !msgIDs.contains(msg_id){
                        msgIDs.add(msg_id)
                        let timeStr = self.localDB.getLastMsgTime(chat_id: chat_id)
                        
                        if timeStr == ""{
                            let newMsg = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
                            self.tempMsgs = self.localDB.getChat(chat_id: self.chat_id, offset: "0")
                            self.msgArray.removeAllObjects()
                            self.msgArray = newMsg!
                            
                        }else{
                            let newMsg = self.localDB.getParticularMsg(msg_id: msg_id)
                            self.msgArray.add(newMsg!)
                            self.tempMsgs?.add(newMsg!)
                            
                        }
                        self.msgTableView.reloadData()
                        self.scrollToBottom()
                    }
                }
                if msg_type == "isDelete"{ // type text
                    self.checkAndReplace(msg_id: msg_id)
                }
                
                if !self.downView.isHidden {
                    self.newMsgView.isHidden = false
                }
                //sent chat read status
                if UIApplication.shared.applicationState != .background || UIApplication.shared.applicationState != .inactive{
                    socketClass.sharedInstance.chatRead(sender_id: dict.value(forKey: "sender_id")! as! String, receiver_id: dict.value(forKey: "receiver_id")! as! String)
                }
                self.localDB.updateRecent(chat_id: self.chat_id)
            }else{
                let userDict = localDB.getContact(contact_id: sender_id)
                /*   let imageName:String = userDict.value(forKey: "user_image") as! String
                 let url = URL.init(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)")
                 let data = NSData.init(contentsOf: url!)
                 let image = UIImage(data : data! as Data)*/
                let cryptLib = CryptLib()
                let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: dict.value(forKeyPath: "message_data.message") as? String, key: ENCRYPT_KEY)
                //                localNotify.show(withImage:nil , title: userDict.value(forKey: "contact_name") as? String, message: decryptedMsg, onTap: {
                //                })
            }
        }else if type == "listentyping"{
            let type:String = dict.value(forKey: "type") as! String
            let sender_id:String = dict.value(forKey: "sender_id") as! String
            if sender_id == self.contact_id{
                if type == "untyping"{
                    self.lastSeenLbl.text = (Utility().getLanguage()?.value(forKey: "online") as? String ?? "online")
                }
                else if type == "typing"{
                    self.lastSeenLbl.text = (Utility().getLanguage()?.value(forKey: "typing") as? String ?? "typing...")
                }
                else if type == "recording"{
                    self.lastSeenLbl.text = (Utility().getLanguage()?.value(forKey: "recording") as? String ?? "recording...")
                }
            }
        }else if type == "receivedstatus"{
            let receiver_id:String = dict.value(forKey: "receiver_id") as! String
            if receiver_id == self.contact_id{
                let msg_id = dict.value(forKey: "message_id")
                let newDict = self.localDB.getParticularMsg(msg_id: msg_id as! String)
                var i = 0
                for msg in self.msgArray {
                    let msgModel:messageModel.message = msg as! messageModel.message
                    let newid = msgModel.message_data.value(forKey: "message_id") as! String
                    if msg_id as! String == newid{
                        self.msgArray.removeObject(at: i)
                        self.msgArray.insert(newDict!, at: i)
                        self.msgTableView.reloadData()
                    }
                    i += 1
                }
                
            }
        }else if type == "readstatus"{
            let receiver_id:String = dict.value(forKey: "receiver_id") as! String
            print("read statussss \(dict)")
            if receiver_id == self.contact_id{
                self.chatRead = true
                self.msgTableView.reloadData()
            }
        } else if type == "onlinestatus"{
            let status:String = dict.value(forKey: "livestatus") as! String
            let contact_id:String = dict.value(forKey: "contact_id") as! String
            if contact_id ==  self.contact_id {
                
                if status == "online"{
                    self.lastSeenLbl.isHidden = false
                    if self.lastSeenLbl.text != "recording..."{
                        self.lastSeenLbl.text = "Online"
                    }
                    if self.blockedMe == "1" || self.blockByMe == "1"{
                        self.lastSeenLbl.isHidden = true
                    }
                    if isFromBackground {
                        socketClass.sharedInstance.chatRead(sender_id:self.contact_id, receiver_id:UserModel.shared.userID()! as String)
                        self.isFromBackground = false
                    }
                }else if status == "offline"{
                    if dict.value(forKey: "lastseen") != nil{
                        let lastSeen = dict.value(forKey: "lastseen") as! String
                        self.lastSeenLbl.text = Utility.shared.setStatus(timeStamp: "\(lastSeen)")
                        if self.blockedMe == "1" || self.blockByMe == "1"{
                            self.lastSeenLbl.isHidden = true
                        }else{
                            //last seen
                            let mutual:String = self.chatDetailDict.value(forKey: "mutual_status") as! String
                            let privacy_lastseen:String = self.chatDetailDict.value(forKey: "privacy_lastseen") as! String
                            if privacy_lastseen == "nobody"{
                                self.lastSeenLbl.isHidden = true
                            }else if privacy_lastseen == "everyone"{
                                self.lastSeenLbl.isHidden = false
                                
                            }else if privacy_lastseen == "mycontacts"{
                                if mutual == "true"{
                                    self.lastSeenLbl.isHidden = false
                                }else{
                                    self.lastSeenLbl.isHidden = true
                                }
                            }
                        }
                    }
                }
            }
        }else if type == "changeuserimage"{
            self.chatDetailDict = localDB.getContact(contact_id: self.contact_id)
            let imageName:String = chatDetailDict.value(forKey: "user_image") as! String
            let urlString:String = "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"
            DispatchQueue.main.async {
                self.profilePic.sd_setImage(with: URL(string:urlString), placeholderImage:  #imageLiteral(resourceName: "profile_placeholder"))
            }
        }else if type == "blockstatus"{
            let blockType = dict.value(forKey: "type") as! String
            let sender_id:String = dict.value(forKey: "sender_id") as! String
            if sender_id == self.contact_id{
                if blockType == "block"{
                    self.blockedMe = "1"
                }else if blockType == "unblock"{
                    self.blockedMe = "0"
                }
                self.configBlockedStatus()
                self.configFavStatus()
            }
        }else if type == "checkCurrentChat"{
            let sender_id:String = dict.value(forKey: "sender_id") as! String
            if sender_id == self.contact_id{
                if UIApplication.shared.applicationState != .background || UIApplication.shared.applicationState != .inactive{
                    socketClass.sharedInstance.chatRead(sender_id: dict.value(forKey: "sender_id")! as! String, receiver_id: dict.value(forKey: "receiver_id")! as! String)
                }
                self.localDB.readStatus(id: self.chat_id, status: "3", type: "chat")
                self.localDB.updateRecent(chat_id: self.chat_id)
                self.refresh(type:"scroll")
            }
        }else if type == "videoUploadStatus"{
            let receiver_id:String = dict.value(forKey: "receiver_id") as! String
            if receiver_id == self.contact_id{
                print("check dict \(dict)")
                let msg_id = dict.value(forKeyPath: "message_data.message_id")
                let newDict = self.localDB.getParticularMsg(msg_id: msg_id as! String)
                var i = 0
                for msg in self.msgArray {
                    let msgModel:messageModel.message = msg as! messageModel.message
                    let id = msgModel.message_data.value(forKey: "message_id") as! String
                    if msg_id as! String == id{
                        self.msgArray.removeObject(at: i)
                        self.msgArray.insert(newDict!, at: i)
                        self.msgTableView.reloadData()
                    }
                    i += 1
                }
            }
        } else if type == "makeprivate" {
            let user_id:String = dict.value(forKey: "user_id") as! String
            if user_id == self.contact_id{
                self.configPrivacySettings()
            }
        }else if type == "offlineRefresh"{
            let receiver_id:String = dict.value(forKey: "receiver_id") as! String
            if receiver_id == self.contact_id{
                self.refresh(type:"NoScroll")
            }
        }else if type == "storyComment"{
            //            let receiver_id:String = dict.value(forKey: "receiver_id") as! String
            print("******** story comment  ")
            
            self.refresh(type:"scroll")
            
        }
    }
    
    func checkAndReplace(msg_id:String)  {
        var i = 0
        for msg in self.msgArray {
            let msgModel:messageModel.message = msg as! messageModel.message
            let newid = msgModel.message_data.value(forKey: "message_id") as! String
            if msg_id == newid{
                let newDict = self.localDB.getParticularMsg(msg_id: msg_id)
                if newDict == nil{
                    DispatchQueue.main.async {
                        self.msgArray.remove(msg)
                        self.msgTableView.reloadData()
                        self.updateLastMsg()
                    }
                }else{
                    self.msgArray.removeObject(at: i)
                    self.msgArray.insert(newDict!, at: i)
                    self.updateLastMsg()
                    DispatchQueue.main.async {
                        self.msgTableView.reloadData()
                    }
                }
            }
            i += 1
        }
    }
    
    @objc func voiceSent(){
        if Utility.shared.isConnectedToNetwork() {
            
            if socket.status != .connected{
                socketClass.sharedInstance.connect()
            }
            if socket.status == .connected
            {
                // prepare socket  dict
                let msgDict = NSMutableDictionary()
                let cryptLib = CryptLib()
                let msg_id = Utility.shared.random()
                
                let encryptMsg = cryptLib.encryptPlainTextRandomIV(withPlainText: getFileUrl().path, key: ENCRYPT_KEY)
                
                msgDict.setValue(encryptMsg, forKey: "message")
                msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
                msgDict.setValue(msg_id, forKey: "message_id")
                msgDict.setValue("audio", forKey: "message_type")
                msgDict.setValue(self.contact_id, forKey: "receiver_id")
                msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                msgDict.setValue("1", forKey: "read_status")
                msgDict.setValue("single", forKey: "chat_type")
                //            msgDict.setValue(self.chatDetailDict.value(forKey: "user_phoneno"), forKey: "phone")
                msgDict.setValue(UserModel.shared.userDict().value(forKey: "phone_no") as? String, forKey: "phone")
                msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name") as? String, forKey: "user_name")
                msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                
                let requestDict = NSMutableDictionary()
                requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                requestDict.setValue(self.contact_id, forKey: "receiver_id")
                requestDict.setValue(msgDict, forKey: "message_data")
                //send socket
                if blockByMe == "0" && blockedMe == "0"{
                    socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                    self.addToLocal(requestDict: requestDict)
                }else if blockByMe == "1"{
                    self.messageTextView.resignFirstResponder()
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                }else{
                    self.addToLocal(requestDict: requestDict)
                }
                self.messageTextView.text = EMPTY_STRING
            }else{
                self.socketrecoonect()
            }
        }
        
    }
    
    
    @objc func uploadAudiotoServer(){
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        msgDict.setValue(self.chatDetailDict.value(forKey: "contact_name"), forKey: "user_name")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue("1", forKey: "read_status")
        
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
        
        let result = PHAsset.fetchAssets(withALAssetURLs: [getFileUrl()], options: nil)
        msgDict.setValue(result.firstObject?.localIdentifier, forKey: "local_path")
        let videoData = NSData.init(contentsOf: getFileUrl() as URL)
        msgDict.setValue("audio", forKey: "message_type")
        let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"audio", key: ENCRYPT_KEY)
        msgDict.setValue(encryptedMsg, forKey: "message")
        var type =  String()
        if (getFileUrl().absoluteString.hasSuffix("m4a")) {
            type = ".m4a"
        } else {
            type = ".mp3"
        }
        self.uploadaudioFiles(msgDict: msgDict, requestDict: requestDict, attachData: videoData! as Data, type:type)
        
        
        
    }
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
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL
    {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
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
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    
    func player(url:NSURL) {
        // print("playing \(url)")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url as URL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error as NSError {
            //self.player = nil
            // print(error.localizedDescription)
        } catch {
            // print("AVAudioPlayer init failed")
        }
        
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        record_btn_ref.isEnabled = true
    }
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
    
    
    
    //Mark: uploadaudiotoServer -------------------------------------------------->
    
    
    func uploadaudioFiles(msgDict:NSDictionary,requestDict:NSDictionary,attachData:Data,type:String){
        if Utility.shared.isConnectedToNetwork() {
            if socket.status != .connected{
                socketClass.sharedInstance.connect()
            }
            if socket.status == .connected
            {
                let uploadObj = UploadServices()
                uploadObj.uploadFiles(fileData: attachData, type: type, user_id: UserModel.shared.userID()! as String,docuName:msgDict.value(forKey: "message") as! String,msg_id: msgDict.value(forKey: "message_id") as! String,api_type:"private", onSuccess: {response in
                    let status:String = response.value(forKey: "status") as! String
                    if status == STATUS_TRUE{
                        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                        
                        let cryptLib = CryptLib()
                        //                    let encryptedMsg = response.value(forKey: "user_image") as? String ?? ""
                        let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String ?? "", key: ENCRYPT_KEY)
                        
                        msgDict.setValue(encryptedMsg, forKey: "attachment")
                        msgDict.setValue(self.contact_id, forKey: "receiver_id")
                        msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                        msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
                        msgDict.setValue("0", forKey: "isDownload")
                        msgDict.setValue("single", forKey: "chat_type")
                        //                    msgDict.setValue(self.chatDetailDict.value(forKey: "user_phoneno"), forKey: "phone")
                        msgDict.setValue(UserModel.shared.userDict().value(forKey: "phone_no") as? String, forKey: "phone")
                        msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name") as? String, forKey: "user_name")
                        msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                        
                        requestDict.setValue(msgDict, forKey: "message_data")
                        
                        //send socket
                        if self.blockByMe == "0" && self.blockedMe == "0"{
                            socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                            self.addToLocal(requestDict: requestDict)
                        }else if self.blockByMe == "1"{
                            
                            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                        }else{
                            self.addToLocal(requestDict: requestDict)
                        }
                    }
                })
                dismiss(animated:true, completion: nil)
            }else{
                self.socketrecoonect()
            }
        } else{
            // self.messageTextView.resignFirstResponder()
            //  self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    
    func downloadAudio(index:Int,audioString:String, message: String, model :messageModel.message)  {
        
        let msgDict = NSMutableDictionary()
        msgDict.setValue(model.message_data, forKey: "message_data")
        let messageID:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        let oldMsgDict = NSMutableDictionary.init(dictionary: model.message_data)
        
        self.localDB.updateDownload(msg_id: messageID, status: "2")
        let cell = view.viewWithTag(index + 4000) as? ReceiverVoiceCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        cell?.downloadIcon.isHidden = true
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(message)"),
               let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(message)"
                // print("file path \(filePath)")
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: messageID,type:"single")
                    self.localDB.updateDownload(msg_id: messageID, status: "1")
                    //oldMsgDict.removeObject(forKey: "isDownload")
                    let localObj = LocalStorage()
                    
                    localObj.updateLocalURL(msg_id: messageID, url: filePath)
                    oldMsgDict.setValue("1", forKey: "isDownload")
                    let newModel = messageModel.message.init(sender_id: model.sender_id, receiver_id: model.receiver_id, message_data:oldMsgDict, date: model.date)
                    self.msgArray.removeObject(at: index)
                    self.msgArray.insert(newModel, at: index)
                    DispatchQueue.main.async {
                        self.scrollTag = 1
                        self.msgTableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    //Mark: download Audio and store the audio to local path -------------------------->
    
    
    func dowloadFile(audioString:String, message: String)  {
        
        if let url = URL.init(string:audioString){
            
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
}
extension ChatDetailPage: RecordViewDelegate {
    
    
    func onStart() {
        self.navigationView.isUserInteractionEnabled = false
        
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        self.recorderView.isHidden = false
        self.recordView.isHidden = false
        
        self.attachmentView.isHidden = true
        if(isAudioRecordingGranted) {
            isSwipeCalled = false
            if(!isRecording)
            {
                do {
                    let imageData = try Data(contentsOf: VoiceRecordingSound as URL)
                    audioPlayer_VoiceRecord = try AVAudioPlayer.init(data: imageData)
                    //                    audioPlayer_VoiceRecord = try AVAudioPlayer(contentsOf: VoiceRecordingSound as URL)
                    audioPlayer_VoiceRecord.play()
                } catch {
                    print(error.localizedDescription)
                }
                messageTextView.isHidden = true
                setup_recorder()
                audioRecorder.record()
                isRecording = true
            }
        }
        else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "microphone_alert") as? String)
        }
        let requestDict = NSMutableDictionary()
        let sender_id:String = UserModel.shared.userID()! as String
        let receiver_id:String = self.chatDetailDict.value(forKey: "user_id") as! String
        requestDict.setValue(sender_id, forKey: "sender_id")
        requestDict.setValue(receiver_id, forKey: "receiver_id")
        requestDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
        requestDict.setValue("recording", forKey: "type")
        
        if self.blockedMe != "1" && blockByMe == "0"{
            socketClass.sharedInstance.sendTypingStatus(requestDict: requestDict)
        }
        
    }
    
    func onCancel() {
        if(isRecording){
            if(audioRecorder.isRecording){
                audioRecorder.stop()
                audioRecorder.deleteRecording()
            }
        }
        isRecording = false
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
        let sender_id:String = UserModel.shared.userID()! as String
        let receiver_id:String = self.chatDetailDict.value(forKey: "user_id") as! String
        
        requestDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
        requestDict.setValue("untyping", forKey: "type")
        if self.blockedMe != "1" && blockByMe == "0"{
            socketClass.sharedInstance.sendTypingStatus(requestDict: requestDict)
        }
        self.navigationView.isUserInteractionEnabled = true
        
    }
    func updateDuration(duration: CGFloat) {
        let requestDict = NSMutableDictionary()
        let sender_id:String = UserModel.shared.userID()! as String
        let receiver_id:String = self.chatDetailDict.value(forKey: "user_id") as! String
        requestDict.setValue(sender_id, forKey: "sender_id")
        requestDict.setValue(receiver_id, forKey: "receiver_id")
        requestDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
        requestDict.setValue("recording", forKey: "type")
        recordView.timeLabelText = duration.SecondsFromTimer()
        if self.blockedMe != "1" && blockByMe == "0"{
            socketClass.sharedInstance.sendTypingStatus(requestDict: requestDict)
        }
        //        self.recordView.updateDuration(duration: duration.fromatSecondsFromTimer())
        
    }
    func onFinished(duration: CGFloat) {
        print("end end \(duration)")
        finishAudioRecording(success: true)
        self.recorderView.isHidden = true
        self.recordView.isHidden = true
        if(isRecording)
        {
            self.attachmentView.isHidden = false
            messageTextView.isHidden = false
            
            ishold = true
            isRecording = false
            if(duration > 0.0){
                self.uploadAudiotoServer()
            }
            else {
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "hold_voice") as? String)
            }
            let requestDict = NSMutableDictionary()
            let sender_id:String = UserModel.shared.userID()! as String
            let receiver_id:String = self.chatDetailDict.value(forKey: "user_id") as! String
            requestDict.setValue(sender_id, forKey: "sender_id")
            requestDict.setValue(receiver_id, forKey: "receiver_id")
            requestDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
            requestDict.setValue("untyping", forKey: "type")
            if self.blockedMe != "1" && blockByMe == "0"{
                socketClass.sharedInstance.sendTypingStatus(requestDict: requestDict)
            }
        }
        else {
            isRecording = false
        }
        self.navigationView.isUserInteractionEnabled = true
        
    }
    
    func onAnimationEnd() {
        //when Trash Animation is Finished
        print("onAnimationEnd")
        self.recorderView.isHidden = true
        self.recordView.isHidden = true
        self.attachmentView.isHidden = false
        messageTextView.isHidden = false
    }
}
extension ChatDetailPage {
    //DOWNLOAD VIDEO
    func downloadVideo(index:Int, model :messageModel.message)  {
        
        let msgDict = NSMutableDictionary()
        msgDict.setValue(model.message_data, forKey: "message_data")
        let videoName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
        
        let messageID:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        let oldMsgDict = NSMutableDictionary.init(dictionary: model.message_data)
        
        self.localDB.updateDownload(msg_id: messageID, status: "2")
        let cell = view.viewWithTag(index + 20000) as? ReceiverVideoCell
        cell?.loader.isHidden = false
        cell?.loader.play()
        cell?.downloadIcon.isHidden = true
        cell?.playImgView.image =  #imageLiteral(resourceName: "download_icon")
        let url = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(videoName)"
        print("Video URL: \(url)")
        Alamofire.request(url).downloadProgress(closure : { (progress) in
            print(progress.fractionCompleted)
            
        }).responseData{ (response) in
            print(response)
            print(response.result.value!)
            print(response.result.description)
            if let data = response.result.value {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent((videoName))
                do {
                    try data.write(to: videoURL)
                } catch {
                    print("Something went wrong!")
                }
                print(videoURL)
                
                PhotoAlbum.sharedInstance.saveVideo(url: videoURL, msg_id: messageID, type: "single")
                
                DispatchQueue.main.async {
                    self.localDB.updateDownload(msg_id: messageID, status: "1")
                    oldMsgDict.removeObject(forKey: "isDownload")
                    oldMsgDict.setValue("1", forKey: "isDownload")
                    let newModel = messageModel.message.init(sender_id: model.sender_id, receiver_id: model.receiver_id, message_data:oldMsgDict, date: model.date)
                    self.msgArray.removeObject(at: index)
                    self.msgArray.insert(newModel, at: index)
                    DispatchQueue.main.async {
                        self.scrollTag = 1
                        self.msgTableView.reloadData()
                    }
                }
            }
        }
    }
}
//MARK: TABLEVIEW
extension ChatDetailPage{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.tableView(tableView, heightForRowAt: indexPath)
        //        return cellHeights[indexPath] ?? UITableView.automaticDimension
        
    }
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.msgArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msgDict =  NSMutableDictionary()
        let dict:messageModel.message = self.msgArray.object(at: indexPath.row) as! messageModel.message
        msgDict.setValue(dict.message_data, forKey: "message_data")
        let type:String = msgDict.value(forKeyPath: "message_data.message_type") as? String ?? ""
        
        if type == "text" || type == "isDelete"{ // type text
            return UITableView.automaticDimension
        }else if type == "image"{ // type image
            return 150
        }else if type == "location"{ // type location
            return 150
        }else if type == "audio"{
            return 70
        }else if type == "gif"{ // type image
            return 150
        }else if type == "contact"{ // type contact
            if dict.sender_id == (UserModel.shared.userID() as String? ?? ""){
                return 95
            }
            else {
                return 125
            }
        }else if type == "video"{ // type video
            return 150
        }else if type == "document"{ // type document
            return 75
        }else if type == "date_sticky"{
            return 40
        }else if type == "audio"{
            return 70
        }
        else if type == "story" {
            return UITableView.automaticDimension
        }
        return 45
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
        
        do{
            
            var customcell = UITableViewCell()
            let dict:messageModel.message = self.msgArray.object(at: indexPath.row) as! messageModel.message
            let msgDict =  NSMutableDictionary()
            msgDict.setValue(dict.message_data, forKey: "message_data")
            let type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            let sender_id:String = dict.sender_id
            let own_id:String = UserModel.shared.userID()! as String
            if type == "text" || type == "isDelete"{ // type text
                let CellIdentifier = "TextCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! TextCell
                cell.bgView.isUserInteractionEnabled = true
                cell.sender_id = sender_id
                cell.nameLabel.isHidden = true
                cell.own_id = own_id
                var deleteStatus = CGFloat(0)
                cell.deleteIcon.tintColor = .white
                //                cell.playButtonBtn.
                if type == "isDelete" {
                    DispatchQueue.main.async {
                        cell.deleteIcon.isHidden = false
                    }
                    
                    deleteStatus = 20.0
                    if sender_id == own_id {
                        cell.deleteIcon.tintColor = .black
                        msgDict.setValue("deleted_by_you", forKey: "message_data.message")
                    }
                    else {
                        cell.deleteIcon.tintColor = .white
                        msgDict.setValue("deleted_by_others", forKey: "message_data.message")
                    }
                    
                }
                else {
                    DispatchQueue.main.async {
                        cell.deleteIcon.isHidden = true
                    }
                    deleteStatus = 0
                    
                }
                cell.translateBtn.tag = indexPath.row
                cell.translateBtn.addTarget(self, action: #selector(self.translateBtnTapped), for: .touchUpInside)
                
                cell.config(msgDict: msgDict,chatRead:self.chatRead)
                let msg:String = msgDict.value(forKeyPath: "message_data.message") as? String ?? ""
                let val = heightForView(text: msg, font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: deleteStatus)
                cell.labelWidth.constant = val.width
                
                
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
                //                if indexPath.row == (self.msgArray.count-1) {
                //                    if sender_id != own_id{
                ////                        self.showSmartReplies(msg: msgDict.value(forKeyPath: "message_data.message") as! String)
                //                    }
                //                }
                customcell = cell
                customcell.backgroundColor = .clear
                //            }
            }else if type == "image"{ // type image
                if sender_id == own_id{
                    let senderImgCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                    senderImgCell.cellType = "image"
                    senderImgCell.config(msgDict: msgDict,chatRead:self.chatRead)
                    senderImgCell.tag = indexPath.row+50000
                    senderImgCell.imageBtn.tag = indexPath.row
                    senderImgCell.imageBtn.addTarget(self, action: #selector(self.senderImageCellBtnTapped), for: .touchUpInside)
                    customcell = senderImgCell
                }else{
                    let receiverImgCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                    receiverImgCell.cellType = "image"
                    receiverImgCell.config(msgDict: msgDict)
                    receiverImgCell.tag = indexPath.row+50000
                    receiverImgCell.imageBtn.tag = indexPath.row
                    receiverImgCell.imageBtn.addTarget(self, action: #selector(self.receiverImageCellBtnTapped), for: .touchUpInside)
                    customcell = receiverImgCell
                }
                //            tableView.rowHeight = 150
                
            }
            else if type == "audio"{
                if sender_id == own_id{
                    let updatedDict = self.localDB.getMsg(msg_id: msgDict.value(forKeyPath:"message_data.message_id") as! String)
                    let senderImgCell = tableView.dequeueReusableCell(withIdentifier: "SenderAudioCell", for: indexPath) as! SenderAudioCell
                    senderImgCell.selectionStyle = .none
                    senderImgCell.PlayerBtn.tag = indexPath.row
                    senderImgCell.tag = indexPath.row+3000
                    //senderImgCell.audioProgress.addTarget(self, action: #selector(self.trackaudio), for: ([.touchUpInside,.touchUpOutside]))
                    // senderImgCell.audioProgress.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
                    senderImgCell.audioProgress.tag = indexPath.row
                    senderImgCell.audioProgress.addTarget(self, action: #selector(respondToSlideEvents), for: .valueChanged)
                    senderImgCell.PlayerBtn.addTarget(self, action: #selector(self.audioCellBtnTapped), for: .touchUpInside)
                    senderImgCell.config(msgDict: updatedDict,chatRead:self.chatRead)
                    
                    
                    customcell = senderImgCell
                }else{
                    
                    let receiverImgCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverVoiceCell", for: indexPath) as! ReceiverVoiceCell
                    receiverImgCell.selectionStyle = .none
                    receiverImgCell.config(msgDict: msgDict,chatRead:self.chatRead)
                    receiverImgCell.tag = indexPath.row+4000
                    receiverImgCell.PlayerBtn.tag = indexPath.row
                    receiverImgCell.audioProgress.tag = indexPath.row
                    
                    //receiverImgCell.audioProgress.addTarget(self, action: #selector(self.trackaudio), for: ([.touchUpInside,.touchUpOutside]))
                    //receiverImgCell.audioProgress.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
                    receiverImgCell.audioProgress.addTarget(self, action: #selector(respondToSlideEvents), for: .valueChanged)
                    
                    receiverImgCell.PlayerBtn.addTarget(self, action: #selector(self.audioCellBtnTapped), for: .touchUpInside)
                    
                    customcell = receiverImgCell
                }
            }
            else if type == "location"{ // type location
                if sender_id == own_id{
                    let senderLocObj = tableView.dequeueReusableCell(withIdentifier: "SenderLocCell", for: indexPath) as! SenderLocCell
                    senderLocObj.config(msgDict: msgDict,chatRead:self.chatRead)
                    senderLocObj.locationBtn.tag = indexPath.row
                    senderLocObj.locationBtn.addTarget(self, action: #selector(self.locationTapped), for: .touchUpInside)
                    customcell = senderLocObj
                }else{
                    let receiverLocObj = tableView.dequeueReusableCell(withIdentifier: "ReceiverLocCell", for: indexPath) as! ReceiverLocCell
                    receiverLocObj.config(msgDict: msgDict)
                    receiverLocObj.locationBtn.tag = indexPath.row
                    receiverLocObj.locationBtn.addTarget(self, action: #selector(self.locationTapped), for: .touchUpInside)
                    customcell = receiverLocObj
                }
                
                //            tableView.rowHeight = 150
            }else if type == "contact"{ // type contact
                if sender_id == own_id{
                    let senderContactObj = tableView.dequeueReusableCell(withIdentifier: "SenderContact", for: indexPath) as! SenderContact
                    senderContactObj.config(msgDict: msgDict,chatRead:self.chatRead)
                    customcell = senderContactObj
                    //                tableView.rowHeight = 95
                }else{
                    let receiverContactObj = tableView.dequeueReusableCell(withIdentifier: "ReceiverContact", for: indexPath) as! ReceiverContact
                    receiverContactObj.config(msgDict: msgDict)
                    receiverContactObj.contactAddBtn.tag = indexPath.row
                    receiverContactObj.contactAddBtn.addTarget(self, action: #selector(self.addToContact), for: .touchUpInside)
                    customcell = receiverContactObj
                    //                tableView.rowHeight = 125
                }
            }else if type == "video"{ // type video
                if sender_id == own_id{
                    let updatedDict = self.localDB.getMsg(msg_id: msgDict.value(forKeyPath:"message_data.message_id") as! String)
                    let sendVideo = tableView.dequeueReusableCell(withIdentifier: "SenderVideoCell", for: indexPath) as! SenderVideoCell
                    sendVideo.videoBtn.tag = indexPath.row
                    sendVideo.videoBtn.addTarget(self, action: #selector(self.videoCellBtnTapped), for: .touchUpInside)
                    sendVideo.config(msgDict: updatedDict,chatRead:self.chatRead)
                    customcell = sendVideo
                }else{
                    let receiveVideo = tableView.dequeueReusableCell(withIdentifier: "ReceiverVideoCell", for: indexPath) as! ReceiverVideoCell
                    receiveVideo.config(msgDict: msgDict)
                    receiveVideo.tag = indexPath.row+20000
                    receiveVideo.videoBtn.tag = indexPath.row
                    receiveVideo.videoBtn.addTarget(self, action: #selector(self.videoCellBtnTapped), for: .touchUpInside)
                    customcell = receiveVideo
                }
                //            tableView.rowHeight = 150
                
            }else if type == "document"{ // type document
                if sender_id == own_id{
                    let sendDoc = tableView.dequeueReusableCell(withIdentifier: "SenderDocuCell", for: indexPath) as! SenderDocuCell
                    sendDoc.config(msgDict: msgDict,chatRead:self.chatRead)
                    sendDoc.docBtn.tag = indexPath.row
                    sendDoc.docBtn.addTarget(self, action: #selector(self.docuCellBtnTapped), for: .touchUpInside)
                    customcell = sendDoc
                }else{
                    let receiveDocu = tableView.dequeueReusableCell(withIdentifier: "ReceiverDocuCell", for: indexPath) as! ReceiverDocuCell
                    receiveDocu.config(msgDict: msgDict)
                    receiveDocu.tag = indexPath.row
                    receiveDocu.docBtn.tag = indexPath.row
                    receiveDocu.docBtn.addTarget(self, action: #selector(self.docuCellBtnTapped), for: .touchUpInside)
                    customcell = receiveDocu
                }
                //            tableView.rowHeight = 75
                
            }else if type == "date_sticky"{
                let dateSticky = tableView.dequeueReusableCell(withIdentifier: "dateStickyCell", for: indexPath) as! dateStickyCell
                let utcString = msgDict.value(forKeyPath: "message_data.date") as? String
                let utcDate = Utility.shared.getSticky(date: utcString!)
                let dateformat =  DateFormatter()
                // dateformat.locale = Locale(identifier: "en_US")
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
            }
            else if type == "story" {
                let storyCell = tableView.dequeueReusableCell(withIdentifier: "StatusReplyTableViewCell", for: indexPath) as! StatusReplyTableViewCell
                storyCell.replyMessageLabel.text = "hii"
                storyCell.wholeBackgroundView.isUserInteractionEnabled = true
                storyCell.sender_id = sender_id
                storyCell.receiveUserNAmeLabel.isHidden = true
                storyCell.own_id = own_id
                storyCell.wholeStatusView.tag = indexPath.row
                storyCell.wholeStatusView.isUserInteractionEnabled = true
                storyCell.wholeStatusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageGestureAct(_:))))
                storyCell.receiveUserNAmeLabel.isHidden = true
                if storyCell.sender_id != storyCell.own_id {
                    storyCell.statusTitleLabel.text = (Utility.shared.getLanguage()?.value(forKey: "your_story") as? String ?? "Your Story") + " " + (Utility.shared.getLanguage()?.value(forKey: "status") as? String ?? "Status")
                }
                else {
                    storyCell.statusTitleLabel.text = self.contactNameLbl.text! + " " + (Utility.shared.getLanguage()?.value(forKey: "status") as? String ?? "Status")
                }
                storyCell.config(msgDict: msgDict)
                //            storyCell.replyMessageLabel.sizeToFit()
                customcell = storyCell
            }else if type == "gif" {
                print("GIPHY LOADED")
                if sender_id == own_id{
                    let senderImgCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                    senderImgCell.cellType = "gif"
                    senderImgCell.tag = indexPath.row+50000
                    senderImgCell.imageBtn.tag = indexPath.row
                    senderImgCell.config(msgDict: msgDict,chatRead:self.chatRead)
                    customcell = senderImgCell
                }else{
                    let receiverImgCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                    receiverImgCell.cellType = "gif"
                    receiverImgCell.tag = indexPath.row+50000
                    receiverImgCell.imageBtn.tag = indexPath.row
                    receiverImgCell.config(msgDict: msgDict)
                    customcell = receiverImgCell
                }
            }
            if type != "date_sticky"{
                if self.selectedDict.contains(where: {$0.message_data == dict.message_data}){
                    customcell.backgroundColor = CHAT_SELECTION_COLOR
                }else{
                    customcell.backgroundColor = .clear
                }
            }
            //        customcell.tag = indexPath.row
            if indexPath.row == (self.msgArray.count - 1) && self.scrollTag == 0 {
                self.scrollToBottom()
            }
            
            return customcell
        }catch{
            
        }
        
    }
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.messageTextView.resignFirstResponder()
        let dict:messageModel.message = msgArray.object(at: indexPath.row) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        let type:String = msgDict.value(forKeyPath: "message_data.message_type") as? String ?? ""
        if self.selectedIdArr.count != 0 && type != "date_sticky"{
            self.makeSelection(tag: indexPath.row, index: indexPath)
        }
    }
}

//MARK: TEXTVIEW

extension ChatDetailPage{
    
    //MARK: textview delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        // print("called")
        self.attachmentMenuView.isHidden = true
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let requestDict = NSMutableDictionary()
        let sender_id:String = UserModel.shared.userID()! as String
        let receiver_id:String = self.chatDetailDict.value(forKey: "user_id") as! String
        requestDict.setValue(sender_id, forKey: "sender_id")
        requestDict.setValue(receiver_id, forKey: "receiver_id")
        requestDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
        requestDict.setValue("typing", forKey: "type")
        if self.blockedMe != "1" && blockByMe == "0"{
            socketClass.sharedInstance.sendTypingStatus(requestDict: requestDict)
        }
        
        let timeStamp = Date()
        self.timeStamp = timeStamp
        let END_TYPING_TIME: CGFloat = 1.5
        perform(#selector(self.endTyping(_:)), with: timeStamp, afterDelay: TimeInterval(END_TYPING_TIME))
        if Utility.shared.checkEmptyWithString(value: textView.text!+text) {
            self.configSendBtn(enable: false)
            self.ConfigVoiceBtn(enable:true)
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
            self.ConfigVoiceBtn(enable:false)
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
        //        self.msgTableView.frame.size.height -= 60
        //        self.msgTableView.frame.size.height = self.bootomInputView.frame.origin.y - self.navigationView.frame.size.height
        //        self.scrollToBottom()
    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
}

extension ChatDetailPage: noneDelegate{
    func forcheck(type: String){
        self.nonecheck(type: type)
    }
}

// MARK: - Speech to text

extension ChatDetailPage {
    
//    func getAudio() {
//        // Request speech recognition authorization
//        self.messageTextView.text = ""
//        speechToTextService.requestAuthorization { isAuthorized in
//            if isAuthorized {
//                do {
//                    // Start recording audio and transcribing speech
//                    try self.speechToTextService.startRecording { transcript in
//                        if let transcript = transcript {
//                            print("Transcript: \(transcript)")
//                        }
//                    }
//                } catch {
//                    print("Error starting recording: \(error.localizedDescription)")
//                }
//
//                // Stop recording audio and transcribing speech after 10 seconds
//                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//                    self.speechToTextService.stopRecording()
//                }
//            } else {
//                print("Speech recognition not authorized")
//            }
//        }
//
//    }
    
    func setupSpeech() {

        self.btnStart.isEnabled = false
        self.speechRecognizer?.delegate = self

        SFSpeechRecognizer.requestAuthorization { (authStatus) in

            var isButtonEnabled = false

            switch authStatus {
            case .authorized:
                isButtonEnabled = true

            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")

            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")

            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }

            OperationQueue.main.addOperation() {
                self.btnStart.isEnabled = isButtonEnabled
            }
        }
    }
    
    func startRecording() {

        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: UserModel.shared.translatedLanguage() ?? "en" ))
        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

//         Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
//        let audioSession = AVAudioSession.sharedInstance()
//         do {
//             try audioSession.setCategory(AVAudioSession.Category.playback)
//             try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//         } catch {
//             // handle errors
//         }

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            var isFinal = false

            if result != nil {

                self.messageTextView.text = result?.bestTranscription.formattedString
                self.configSendBtn(enable: true)
                self.ConfigVoiceBtn(enable: false)
                isFinal = (result?.isFinal)!
            }

            if error != nil || isFinal {

                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.btnStart.isEnabled = true
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        self.audioEngine.prepare()

        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        if UserModel.shared.translatedLanguage() == "ar"{
            self.messageTextView.textAlignment = .right
        }
        else {
            self.messageTextView.textAlignment = .left
        }

        self.messageTextView.placeholder = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String
    }
}

extension ChatDetailPage: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.btnStart.isEnabled = true
        } else {
            self.btnStart.isEnabled = false
        }
    }
}



