//
//  GroupChatPage.swift
//  Hiddy
//
//  Created by APPLE on 13/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//
//
//  ChatDetailPage.swift
//  Hiddy
//
//  Created by APPLE on 01/06/18.
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
import Firebase
import TrueTime
import GiphyUISDK
import MLKitSmartReply

class GroupChatPage: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,fetchLocationDelegate,UIDocumentPickerDelegate,CNContactPickerDelegate,CNContactViewControllerDelegate,UIDocumentInteractionControllerDelegate,socketClassDelegate,alertDelegate,UIGestureRecognizerDelegate,groupDelegateChat,forwardDelegate,GrowingTextViewDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate, deleteAlertDelegate, GiphyDelegate {
    
    var docController:UIDocumentInteractionController!
    var numberOfPhotos: NSNumber?
    var msgArray = NSMutableArray()
    var tempMsgs:AnyObject?
    var finalArray = NSMutableArray()
    var groupDict = NSDictionary()
    var group_id = String()
    let groupDB = groupStorage()
    let localDB = LocalStorage()
    var chatCount = 0
    var galleryType = String()
    var contactStore = CNContactStore()
    let contactPicker = CNContactPickerViewController()
    var attachmentShow = Bool()
    var isFetch = Bool()
    var timeStamp = Date()
    var menuArray = NSMutableArray()
    var membersArray = NSMutableArray()
    var memberDict = NSDictionary()
    var viewType = String()
    var nameListString = String()
    var exitStatus = String()
    var longPressGesture = UILongPressGestureRecognizer()
    var selectedId = String()
    var selectedIndexArr = [IndexPath]()
    var selectedIdArr = [String]()
    var selectedDict = [groupMsgModel.message]()
    var msgIDs = NSMutableArray()
    
    var isKeyborad = false
    
    var keybordHeight = CGFloat()
    
    @IBOutlet var camerBtn: UIButton!
    @IBOutlet var galleryBtn: UIButton!
    @IBOutlet var fileBtn: UIButton!
    @IBOutlet var locationBtn: UIButton!
    @IBOutlet var contactBtn: UIButton!
    let gifBtn = UIButton()
    
    @IBOutlet var supportLanguageBtn: UIButton!
    
    var changedMemberId = String()
    let del = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var backArrowIcon: UIImageView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var forwardIcon: UIImageView!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var bootomInputView: UIView!
    @IBOutlet var groupNameLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var groupMembersLbl: UILabel!
    @IBOutlet var toolContainerView: UIView!
    @IBOutlet var messageTextView: GrowingTextView!
    @IBOutlet var msgTableView: UITableView!
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var sendImgView: UIImageView!
    @IBOutlet var groupIcon: UIImageView!
    @IBOutlet var attachmentMenuView: UIView!
    @IBOutlet var copyIcon: UIImageView!
    @IBOutlet var copyBtn: UIButton!
    @IBOutlet var forwardView: UIView!
    
    //New Customize
    @IBOutlet var smartReplyView: UIScrollView!
    @IBOutlet weak var record_btn_ref: RecordButton!
    @IBOutlet weak var recorderView: UIView!
    
    @IBOutlet var downView: UIView!
    @IBOutlet var newMsgView: UIView!
    
    let cryptLib = CryptLib()
    
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
    var isReload = true
    var isRefresh = false
    var isTranslate = true
    
    var counter = 0
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
    let recordView = RecordView()
    var scrollCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        self.groupDB.updateAllGroupMediaDownload()
        
        // Do any additional setup after loading the view.
        self.forwardView.isHidden = true
        self.msgTableView.rowHeight = UITableView.automaticDimension
        self.msgTableView.estimatedRowHeight = 50
        self.selectedId = EMPTY_STRING
        self.configMsgField()
        self.customAudioRecordView()
        self.nonecheck(type: UserModel.shared.translatedLanguage() ?? "none")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        self.recordAudioView()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        //down unread view
        self.newMsgView.applyGradient()
        self.newMsgView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.downView.cornerViewRadius()
        self.downView.backgroundColor = NEW_MSG_BACKGROUND
        self.newMsgView.isHidden = true
        self.downView.isHidden = true
        self.groupDB.checkAdded(group_id: self.group_id)
        
    }
    @objc func willResignActive() {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        requestDict.setValue(self.group_id, forKey: "group_id")
        requestDict.setValue("untyping", forKey: "type")
        groupSocket.sharedInstance.typingGroup(reqDict: requestDict)
        self.attachmentView.isHidden = false
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
        self.recorderView.isHidden = true
        messageTextView.isHidden = false
        
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
        recordView.slideToCancelText = Utility().getLanguage()?.value(forKey: "slide_cancel") as? String ?? ""
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
    //check contact access permission
    @objc func checkPermission()  {
        DispatchQueue.main.async {
            Contact.sharedInstance.synchronize()
        }
    }
    func socketrecoonect(){
        self.view.makeToast("Poor network connection...", duration: 2, position: .center)
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshContact), name: Notification.Name("ContactRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.toolContainerView.backgroundColor = BOTTOM_BAR_COLOR
        self.bootomInputView.backgroundColor = BOTTOM_BAR_COLOR
        self.attachmentMenuView.backgroundColor = BOTTOM_BAR_COLOR
        self.forwardView.backgroundColor = BOTTOM_BAR_COLOR
        
        self.recorderView.isHidden = true
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.nonecheck(type: UserModel.shared.translatedLanguage() ?? "none")
        self.msgTableView.reloadData()
        
        setNeedsStatusBarAppearanceUpdate()
        self.groupDict = self.groupDB.getGroupInfo(group_id: self.group_id)
        self.navigationController?.isNavigationBarHidden = true
        if self.groupDict.value(forKey: "group_id") != nil {
            self.initialSetup()
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.changeRTLView()
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermission), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermission), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.msgTableView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.backArrowIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.groupNameLbl.textAlignment = .right
            self.groupMembersLbl.textAlignment = .right
            self.messageTextView.textAlignment = .right
            self.sendView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.msgTableView.transform = .identity
            self.backArrowIcon.transform = .identity
            self.groupNameLbl.textAlignment = .left
            self.groupMembersLbl.textAlignment = .left
            self.messageTextView.textAlignment = .left
            self.sendView.transform = .identity
            
        }
    }
    @objc func handleApplicationDidBecomeActive() {
        print("Handle Active Status")
        self.groupDB.updateAllGroupMediaDownload()
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isReload = false
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        groupDB.readStatus(group_id: group_id)
        groupDB.updateUnreadCount(group_id: group_id)
        Utility.shared.setBadge(vc: self)
        IQKeyboardManager.shared.enable = true
    }
    override func viewDidLayoutSubviews() {
        //        DispatchQueue.main.async {
        //            if  self.msgTableView.contentSize.height >  self.msgTableView.bounds.size.height {
        //                self.msgTableView.contentOffset = CGPoint.init(x: 0, y:  self.msgTableView.contentSize.height -  self.msgTableView.bounds.size.height)
        //            }
        //        }
        
        
        
                self.configGif()
        self.supportLanguageBtn.isHidden = false
        self.smartReplyView.isHidden = false
    }
    
    
    //set up initial details
    func initialSetup()  {
        //update read status
        self.smartReplyView.backgroundColor = .clear
        
        groupDB.readStatus(group_id: group_id)
        groupDB.updateUnreadCount(group_id: group_id)
        Utility.shared.setBadge(vc: self)
        
        socketClass.sharedInstance.delegate = self
        groupSocket.sharedInstance.delegateChat = self
        contactPicker.delegate = self
        
        self.memberDict = self.groupDB.getMemberInfo(member_key: "\(self.group_id)\(UserModel.shared.userID()!)")
        //self.attachmentShow = false
        self.isFetch =  false
        self.navigationView.elevationEffectOnBottom()
        self.groupNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
       // self.groupMembersLbl.config(color: TEXT_TERTIARY_COLOR, size: 15, align: .left, text: EMPTY_STRING)
        if Utility.shared.isConnectedToNetwork() {
            if IS_IPHONE_5{
                self.groupMembersLbl.config(color: TEXT_TERTIARY_COLOR, size: 10, align: .left, text: EMPTY_STRING)
            }else{
                self.groupMembersLbl.config(color: TEXT_TERTIARY_COLOR, size: 13, align: .left, text: EMPTY_STRING)
            }
        }else{
            self.groupMembersLbl.config(color: TEXT_TERTIARY_COLOR, size: 15, align: .left, text: EMPTY_STRING)
        }
        
        self.groupNameLbl.text = self.groupDict.value(forKey: "group_name") as? String
        self.groupIcon.rounded()
        let imageName:String = self.groupDict.value(forKey: "group_icon") as! String
        self.groupIcon.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "group_placeholder"))
        
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
        if isReload{
            self.refresh(scroll: true)
        }
        self.menuArray = [Utility().getLanguage()?.value(forKey: "mute_notify") as! String,Utility().getLanguage()?.value(forKey: "clear_all") as! String,Utility().getLanguage()?.value(forKey: "exit_group_menu") as! String]
        self.configMuteStatus()
        self.configGroupMembers()
        self.configExitStatus()
        self.setupLongPressGesture()
        
        self.adjustDownView()
        
    }
    //set mute status
    func configMuteStatus()  {
        let mute:String = self.groupDict.value(forKey: "mute") as! String
        self.menuArray.removeObject(at: 0)
        if mute == "0"{
            self.menuArray.insert(Utility().getLanguage()?.value(forKey: "mute_notify") as! String, at: 0)
        }else if mute == "1"{
            self.menuArray.insert(Utility().getLanguage()?.value(forKey: "unmute_notify") as! String, at: 0)
        }
    }
    
    func configExitStatus() {
        self.exitStatus = self.groupDict.value(forKey: "exit") as! String
        if self.exitStatus == "1"{
            self.bootomInputView.isHidden = true
            self.menuArray.removeAllObjects()
            self.menuArray = [Utility().getLanguage()?.value(forKey: "delete_group_menu") as! String]
        }else{
            self.bootomInputView.isHidden = false
        }
    }
    
    func configGroupMembers() {
        self.membersArray = self.groupDB.getGroupMembers(group_id: group_id)
        // print("group members \(self.membersArray)")
        let nameArray = NSMutableArray()
        for people in self.membersArray {
            let tempDict:NSDictionary = people as! NSDictionary
            let member_id:String =  tempDict.value(forKey: "member_id") as! String
            
            if member_id == "\(UserModel.shared.userID()!)" {
                nameArray.add("You")
            }else{
                nameArray.add(tempDict.value(forKey: "contact_name")!)
            }
        }
        self.nameListString = nameArray.componentsJoined(by: ", ")
        self.groupMembersLbl.text = self.nameListString
    }
    
    //set up message text view
    func configMsgField()  {
        messageTextView.textColor = TEXT_PRIMARY_COLOR
        
        messageTextView.layer.borderWidth  = 1.0
        messageTextView.layer.borderColor = TEXT_TERTIARY_COLOR.cgColor
        recorderView.layer.borderWidth  = 1.0
        recorderView.layer.borderColor = TEXT_TERTIARY_COLOR.cgColor
        
        messageTextView.font = UIFont.systemFont(ofSize: 18)
        messageTextView.textContainer.lineFragmentPadding = 20
        messageTextView.delegate = self
        
        messageTextView.trimWhiteSpaceWhenEndEditing = true
        messageTextView.placeholder = Utility().getLanguage()?.value(forKey: "say_something") as? String
        messageTextView.placeholderColor = TEXT_TERTIARY_COLOR
        messageTextView.minHeight = 30.0
        messageTextView.maxHeight = 150.0
        messageTextView.layer.cornerRadius = 20.0
        recorderView.layer.cornerRadius = 20
        messageTextView.textAlignment = .left
        
        recorderView.layer.borderWidth  = 1.0
        recorderView.layer.borderColor = TEXT_TERTIARY_COLOR.cgColor
        recorderView.layer.cornerRadius = 20.0
        
    }
    
    //register table view cells
    func registerCells()  {
        msgTableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "TextCell")
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
        
        msgTableView.register(UINib(nibName: "ChatDetailsSectionTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ChatDetailsSectionTableViewCell")
        self.msgTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.msgTableView.estimatedSectionHeaderHeight = 40
        
    }
    
    //dismiss keyboard & attachment menu
    @objc func dismissKeyboard () {
        messageTextView.resignFirstResponder()
        //        self.scrollToBottom()
    }
    
    //navigation back btn tapped
    @IBAction func backBtnTapped(_ sender: Any) {
        
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
                self.selectedIdArr.removeAll()
                self.selectedDict.removeAll()
                self.scrollCount = 0
                self.msgTableView.reloadData()
            }
        }else{
            if self.viewType == "1"{
                DispatchQueue.main.async {
                    self.del.setInitialViewController(initialView: menuContainerPage())
                    UserModel.shared.setTab(index: 1)
                }
            }
            else if self.viewType == "10" {
                self.del.setInitialViewController(initialView: menuContainerPage())
                UserModel.shared.setTab(index: 1)
            }
            else{
                self.navigationController?.popViewController(animated: true)
                UserModel.shared.setTab(index: 1)
            }
        }
    }
    
    @IBAction func copyBtnTapped(_ sender: Any) {
        let msgDict = groupDB.getGroupMsg(msg_id: self.selectedIdArr.first ?? "")
        UIPasteboard.general.string = msgDict?.message
        self.view.makeToast(Utility().getLanguage()?.value(forKey: "copied") as? String)
        self.forwardView.isHidden = true
        self.selectedIdArr.removeAll()
        self.selectedIndexArr.removeAll()
        self.selectedDict.removeAll()
        self.infoHeight()
        self.scrollCount = 1
        self.msgTableView.reloadData()
    }
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        var typeTag = 0
        for i in 0..<self.selectedIdArr.count {
            let msgDict =  self.selectedDict[i]
            let chatTime:String = msgDict.timestamp
            let type:String = msgDict.message_type
            let sender_id:String = msgDict.member_id
            let own_id:String = UserModel.shared.userID()! as String
            
            let cal = Calendar.current
            var d1 = Date()
            let client = TrueTimeClient.sharedInstance
            if client.referenceTime?.now() != nil{
                d1 = (client.referenceTime?.now())!
            }
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
        if type == "0" {
            self.deleteForMeAct()
        }
        else {
            self.deleteForEveryOneAct()
        }
    }
    func deleteImageAndVideoFromPhotoLibrary(onSuccess success: @escaping (Bool) -> Void) {
        var localPathArr = [String]()
        for i in selectedDict {
            let localPath = i.local_path
            let deleteType = i.message_type
            let senderID = i.member_id
            if (deleteType == "image" || deleteType == "video") && senderID != (UserModel.shared.userID() as String? ?? "") {
                localPathArr.append(localPath)
            }
        }
        PhotoAlbum.sharedInstance.delete(local_ID: localPathArr, onSuccess: {response in
            success(response)
        })
    }
    func deleteForEveryOneAct() {
        for i in self.selectedDict {
            let msgVal =  i
            let msgDict = NSMutableDictionary()
            msgDict.setValue("group", forKey: "chat_type")
            msgDict.setValue(msgVal.message_id, forKey: "message_id")
            msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
            msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
            msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
            msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
            let cryptLib = CryptLib()
            let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"This message was deleted", key: ENCRYPT_KEY)
            
            msgDict.setValue(encryptedMsg, forKey: "message")
            msgDict.setValue("isDelete", forKey: "message_type")
            msgDict.setValue(msgVal.timestamp, forKey: "chat_time")
            msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
            msgDict.setValue(self.group_id, forKey: "group_id")
            groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
            self.groupDB.updateGroupMessage(msg_id: msgVal.message_id, msg_type: "isDelete")
        }
        self.deleteImageAndVideoFromPhotoLibrary { (status) in
            for msgID in self.selectedIdArr{
                self.replaceUpdatedMsg(msg_id:msgID)
            }
            self.selectedIndexArr.removeAll()
            self.selectedIdArr.removeAll()
            self.selectedDict.removeAll()
            self.scrollCount = 1
            DispatchQueue.main.async {
                self.forwardView.isHidden = true
            }
        }
    }
    
    @IBAction func forwardBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        let forwardObj = ForwardSelection()
        forwardObj.msgID = self.selectedIdArr
        forwardObj.msgFrom = "group"
        forwardObj.delegate = self
        self.navigationController?.pushViewController(forwardObj, animated: true)
    }
    func forwardMsg(type: String, idStr:String) {
        self.view.makeToast(Utility().getLanguage()?.value(forKey: "sending") as? String)
        self.forwardView.isHidden = true
        self.selectedDict.removeAll()
        self.selectedIdArr.removeAll()
        self.selectedIndexArr.removeAll()
        self.scrollCount = 1
        self.msgTableView.reloadData()
    }
    
    //refresh view
    func refresh(scroll:Bool)  {
        DispatchQueue.main.async {
            self.isFetch = false
            let newMsg = self.groupDB.getGroupChat(group_id: self.group_id, offset: "0")
            self.tempMsgs = self.groupDB.getGroupChat(group_id: self.group_id, offset: "0")
            //            self.msgArray = Utility.shared.arrangeGroupMsg(array:newMsg!)
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
        let profileObj = groupDetailsPage()
        profileObj.group_id = self.group_id
        profileObj.exitType = "3"
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        profileObj.modalPresentationStyle = .fullScreen
        profileObj.modalPresentationStyle = .fullScreen
        self.present(profileObj, animated: false, completion: nil)
    }
    //scroll to bottom
    func scrollToBottom(){
        if self.msgArray.count != 0 {
            DispatchQueue.main.async {
                if self.msgArray.count != 0 {
                    let indexPath = IndexPath(row: self.msgArray.count - 1, section: 0)
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
        var frame = CGRect(x: self.view.frame.width - 15, y: self.menuBtn.frame.origin.y + self.menuBtn.frame.height + 10, width: self.menuBtn.frame.width, height: self.menuBtn.frame.height)
        if UserModel.shared.getAppLanguage() == "عربى" {
            frame = CGRect(x: self.view.frame.origin.x + 5, y: self.menuBtn.frame.origin.y + self.menuBtn.frame.height + 10, width: self.menuBtn.frame.width, height: self.menuBtn.frame.height)
            alert.alignmentTag = 1
        }
        
        FTPopOverMenu.show(fromSenderFrame: frame, withMenuArray: self.menuArray as? [Any], doneBlock: { selectedIndex in
            
            if self.exitStatus == "1"{ //exit delete action
                alert.viewType = "4"
                alert.msg = "delete_group"
                self.present(alert, animated: true, completion: nil)
            }else{//without exit
                if selectedIndex == 0{
                    let mute:String = self.groupDict.value(forKey: "mute") as! String
                    if mute == "0"{
                        alert.viewType = "0"
                        alert.msg = "mute_group"
                        self.present(alert, animated: true, completion: nil)
                    }else if mute == "1"{
                        alert.viewType = "1"
                        alert.msg = "unmute_group"
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if selectedIndex == 1{
                    if self.msgArray.count == 0 {
                        self.view.makeToast(Utility().getLanguage()?.value(forKey: "no_clear") as? String)
                    }
                    else {
                        alert.viewType = "2"
                        alert.msg = "clear_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }else if selectedIndex == 2{
                    if Utility.shared.isConnectedToNetwork(){
                        alert.viewType = "3"
                        alert.msg = "exit_group"
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
                    }
                }
            }
        }, dismiss: {
            
        })
        
    }
    
    func alertActionDone(type: String) {
        if type == "0"{
            self.groupDB.groupMute(group_id: self.group_id, status: "1")
            socketClass.sharedInstance.muteStatus(chat_id: self.group_id, type:"group" , status: "mute")
            
            self.groupDict =  self.groupDB.getGroupInfo(group_id: group_id)
            self.configMuteStatus()
        }else if type == "1"{
            socketClass.sharedInstance.muteStatus(chat_id: self.group_id, type:"group" , status: "unmute")
            self.groupDB.groupMute(group_id: self.group_id, status: "0")
            self.groupDict =  self.groupDB.getGroupInfo(group_id: group_id)
            self.configMuteStatus()
        }else if type == "2"{
            self.view.endEditing(true)
            self.groupDB.deleteGroupMsg(group_id:self.group_id)
            self.tempMsgs?.removeAllObjects()
            self.msgArray.removeAllObjects()
            scrollCount = 0
            self.refresh(scroll: true)
        }else if type == "3"{
            self.groupDB.groupExit(group_id: group_id)
            self.groupDB.removeMember(member_key: "\(group_id)\(UserModel.shared.userID()!)")
            self.groupDict = self.groupDB.getGroupInfo(group_id: group_id)
            self.membersArray.removeAllObjects()
            self.membersArray = self.groupDB.getGroupMembers(group_id: group_id)
            self.notifyExitToGroup()
            self.configExitStatus()
        }else if type == "4"{
            self.groupDB.deleteGroupMsg(group_id:self.group_id)
            self.groupDB.deleteGroup(group_id: self.group_id)
            if self.viewType == "2"{
                self.navigationController?.popViewController(animated: true)
            }else{
                //To dismiss with animation
                let transition: CATransition = CATransition()
                transition.duration = 0.8
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                transition.type = CATransitionType.moveIn
                transition.subtype = CATransitionSubtype.fromLeft
                self.view.window!.layer.add(transition, forKey: nil)
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            }
        }else if type == "5"{
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
                self.groupDB.deleteGroupSingleMsg(msg_id: selectedIDVal)
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
    //update msg
    func updateLastMsg() {
        DispatchQueue.main.async {
            if self.msgArray.count > 0 {
                let lastMsg = self.msgArray.object(at: self.msgArray.count - 1) as! groupMsgModel.message
                if lastMsg.message_type == "date_sticky" {
                    if self.msgArray.count > 1 {
                        let lastMsg1 = self.msgArray.object(at: self.msgArray.count - 2) as! groupMsgModel.message
                        self.groupDB.updateRecentMsg(group_id:self.group_id, msgID:lastMsg1.message_id, timestamp: lastMsg1.timestamp)
                    }
                }else{
                    self.groupDB.updateRecentMsg(group_id:self.group_id, msgID:lastMsg.message_id, timestamp: lastMsg.timestamp)
                }
            }else{
                self.groupDB.updateRecentMsg(group_id:self.group_id, msgID: "", timestamp: Utility.shared.getTime())
            }
        }
    }
    //exit group
    func notifyExitToGroup()  {
        let memberDict = self.groupDB.getMemberInfo(member_key: "\(group_id)\(UserModel.shared.userID()!)")
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        msgDict.setValue("Member Left", forKey: "message")
        msgDict.setValue("left", forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        if !msgIDs.contains(msg_id){
            self.msgIDs.add(msg_id)
        }
        //exit add
        self.addToLocal(requestDict: msgDict)
        
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        socketClass.sharedInstance.goLive()
        if !self.groupDB.checkGroupMember(group_id: group_id) {
            if self.membersArray.count != 0 {
                self.makeSomeOneAsAdmin()
            }
        }
        groupSocket.sharedInstance.exitGroup(group_id: self.group_id, user_id: UserModel.shared.userID()! as String, msgDict: msgDict)
        
    }
    //make  admin
    func makeSomeOneAsAdmin()  {
        let newAdminDict:NSDictionary = self.membersArray.object(at: 0) as! NSDictionary
        let member_id = newAdminDict.value(forKey: "member_id") as! String
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(newAdminDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(newAdminDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(newAdminDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(member_id, forKey: "member_id")
        msgDict.setValue(member_id, forKey: "group_admin_id")
        msgDict.setValue("Admin", forKey: "message")
        msgDict.setValue("admin", forKey: "message_type")
        msgDict.setValue("1", forKey: "attachment")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        groupDB.makeAdmin(member_key: "\(group_id)\(member_id)",status:"1")
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
     giphy.dimBackground = true
//     giphy.showCheckeredBackground = true
     giphy.modalPresentationStyle = .overCurrentContext
     present(giphy, animated: true, completion: nil)
         
     }else{
         self.socketrecoonect()
     }
         
         
     }
     func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)   {
     
     let gifURL : String = media.url(rendition: .fixedWidth, fileType: .gif)!
     
     if Utility.shared.isConnectedToNetwork() {
         if socket.status == .connected{
     let msgDict = NSMutableDictionary()
     let msg_id = Utility.shared.random()
     let time = NSDate().timeIntervalSince1970
     msgDict.setValue("group", forKey: "chat_type")
     msgDict.setValue(msg_id, forKey: "message_id")
     msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
     msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
     msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
     msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
     msgDict.setValue(gifURL, forKey: "attachment")
     let encryptMsg = cryptLib.encryptPlainTextRandomIV(withPlainText: "Gif", key: ENCRYPT_KEY)
     
     msgDict.setValue(encryptMsg, forKey: "message")
     msgDict.setValue("gif", forKey: "message_type")
     //msgDict.setValue("\(time.rounded().clean)", forKey: "chat_time")
    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")

     msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
     msgDict.setValue(self.group_id, forKey: "group_id")
     //send socket
     groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
     self.configSendBtn(enable: false)
     self.ConfigVoiceBtn(enable: true)
     
     self.addToLocal(requestDict: msgDict)
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
    @IBAction func sendBtnTapped(_ sender: Any) {
        let txt = messageTextView.text.trimmingCharacters(in: .newlines)
        
        self.sendMsg(msg: txt)
    }
    
    func sendMsg(msg:String){
        if Utility.shared.isConnectedToNetwork() {
            if self.counter != 0 {
                self.counter = 0
                self.stopAudioPlayer()
            }
            if !Utility.shared.checkEmptyWithString(value: msg) {
                
                
                if socket.status != .connected{
                    socketClass.sharedInstance.connect()
                }
                if socket.status == .connected
                {
                
                let subViews = self.smartReplyView.subviews
                for subview in subViews{
                    subview.removeFromSuperview()
                }
                // prepare socket  dict
                let msgDict = NSMutableDictionary()
                let msg_id = Utility.shared.random()
                msgDict.setValue("group", forKey: "chat_type")
                msgDict.setValue(msg_id, forKey: "message_id")
                print("member info \(self.memberDict)")
                msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
                msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
                msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
                msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
                let cryptLib = CryptLib()
                let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:msg, key: ENCRYPT_KEY)
                
                msgDict.setValue(encryptedMsg, forKey: "message")
                msgDict.setValue("text", forKey: "message_type")
                msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
                msgDict.setValue(self.group_id, forKey: "group_id")
                //send socket
                groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
                print("sent successfully")
                
                if !msgIDs.contains(msg_id){
                    self.msgIDs.add(msg_id)
                }
                self.addToLocal(requestDict: msgDict)
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
    /*
    func showSmartReplies(msg:String){
        
        var conversation: [TextMessage] = []
        let time = NSDate().timeIntervalSince1970
        // Then, for each message sent and received:
        let message = TextMessage(
            text: msg,
            timestamp:time,
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
                    self.smartReplyView.addSubview(suggestionBtn)
                    leftPadding = Int(suggestionBtn.frame.origin.x+suggestionBtn.frame.size.width+5)
                    self.smartReplyView.contentSize = CGSize.init(width: leftPadding+100, height: 50)
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
    // add to local db
    func addToLocal(requestDict:NSDictionary)  {
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
        var admin : String = EMPTY_STRING
        
        
        let type : String = requestDict.value(forKey: "message_type") as! String
        if type == "image"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "location"{
            lat = requestDict.value(forKey: "lat") as! String
            lon = requestDict.value(forKey: "lon") as! String
        }else if type == "contact"{
            //            cc = requestDict.value(forKeyPath: "message_data.cc") as! String
            cName = requestDict.value(forKey: "contact_name") as! String
            cNo = requestDict.value(forKey: "contact_phone_no") as! String
        }else if type == "video"{
            attach = requestDict.value(forKey: "attachment") as! String
            thumbnail = requestDict.value(forKey: "thumbnail") as! String
        }else if type == "document"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "audio" {
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "admin"{
            admin = requestDict.value(forKey: "group_admin_id") as! String
        }else if type == "add_member" || type == "remove_member"{
            admin = requestDict.value(forKey: "group_admin_id") as! String
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "gif" {
            attach = requestDict.value(forKey: "attachment") as! String
        }
        
        //add local db
        self.groupDB.addGroupChat(msg_id: requestDict.value(forKey: "message_id") as! String,
                                  group_id: self.group_id,
                                  member_id: requestDict.value(forKey: "member_id")! as! String,
                                  msg_type: requestDict.value(forKey: "message_type")! as! String,
                                  msg: requestDict.value(forKey: "message")! as! String,
                                  time: requestDict.value(forKey: "chat_time")! as! String,
                                  lat: lat,
                                  lon: lon,
                                  contact_name: cName,
                                  contact_no: cNo,
                                  country_code: cc,
                                  attachment: attach,
                                  thumbnail: thumbnail, admin_id: admin,read_status:"0")
        
        let unreadcount = groupDB.getGroupUnreadCount(group_id: group_id)
        let groupDict = groupDB.getGroupInfo(group_id: group_id)
        let lastMsgInfo = groupDB.getLastMsgInfo(group_id: group_id)
        
        groupDB.updateGroupDetails(group_id: group_id, mute: groupDict.value(forKey: "mute") as! String, exit: groupDict.value(forKey: "exit") as! String, message_id: lastMsgInfo.value(forKey: "message_id") as! String, timestamp: lastMsgInfo.value(forKey: "chat_time") as! String, unread_count: "\(unreadcount)")
        print("added locally")
        //add local array
        let msg_id = requestDict.value(forKey: "message_id") as! String
        if !msgIDs.contains(msg_id){
            msgIDs.add(msg_id)
        }
        self.isFetch = false
        self.tempMsgs?.removeAllObjects()
        let newMsg = self.groupDB.getGroupChat(group_id: group_id, offset: "0")
        self.tempMsgs = self.groupDB.getGroupChat(group_id: group_id, offset: "0")
        self.groupDB.updateGroupMediaLocalURL(msg_id: requestDict.value(forKey: "message_id") as! String, url: requestDict.value(forKey: "local_path") as? String ?? "0")
        self.msgArray.removeAllObjects()
        self.msgArray = newMsg!
        
        self.infoHeight()
        self.scrollCount = 0
        self.msgTableView.reloadData()
        
        //        self.scroll(toTheBottom: false)
        self.viewDidLayoutSubviews()
        
        self.configSendBtn(enable: false)
        self.ConfigVoiceBtn(enable: true)
        self.scrollToBottom()
    }
    
    //open attachment menu
    @IBAction func attachmentMenuBtnTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        //        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
        //        }, completion: nil)
        if self.attachmentShow{
            self.showAttachmentMenu(enable: false)
        }else{
            self.showAttachmentMenu(enable: true)
        }
        
    }
    
    
    
    
    func makeSelection(tag:Int,index:IndexPath)  {
        let dict:groupMsgModel.message = msgArray.object(at: tag) as! groupMsgModel.message
        let msg_type = dict.message_type
        self.scrollCount = 1
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
                self.forwardView.isHidden = false
                self.selectedIdArr.append(id)
                self.selectedDict.append(dict)
            }
            else{
                if self.selectedIdArr.filter({$0 == id}).count != 0 {
                    let cell = view.viewWithTag(index.row + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                }
                let id = self.selectedIdArr.firstIndex(of: id)
                self.selectedIdArr.remove(at: id ?? 0)
                self.selectedDict.remove(at: id ?? 0)
                let selectedIndex = self.selectedIndexArr.firstIndex(of: index)
                self.selectedIndexArr.remove(at: selectedIndex ?? 0)
                self.msgTableView.reloadData()
            }
            self.checkDownloadStatus()
            if self.selectedDict.count != 1 {
                self.copyBtn.isHidden = true
                self.copyIcon.isHidden = true
            }
            else if msg_type == "text" {
                self.copyBtn.isHidden = false
                self.copyIcon.isHidden = false
            }else{
                self.copyBtn.isHidden = true
                self.copyIcon.isHidden = true
            }
            
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
            if (message_type != "text" && message_type != "isDelete" && message_type != "status") && (downloadStatus == "0") && (dict.member_id != UserModel.shared.userID() as String? ?? ""){
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
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        let model:groupMsgModel.message = msgArray.object(at: sender.tag) as! groupMsgModel.message
        if self.selectedIdArr.count == 0 {
            let type:String = model.message_type
            if type != "date_sticky" {
                if type == "document"{
                    let message_id:String = model.message_id
                    let sender_id:String = model.member_id
                    let own_id:String = UserModel.shared.userID()! as String
                    
                    let updatedDict = self.groupDB.getGroupMsg(msg_id: message_id)
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
                        if isDownload == "0" || isDownload == "4"{
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
                                self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
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
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, index: indexpath)
        }
    }
    
    @objc func imageCellBtnTapped(_ sender: UIButton!)  {
        self.isReload = false
        
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        let model:groupMsgModel.message = msgArray.object(at: sender.tag) as! groupMsgModel.message
        let type:String = model.message_type
        if self.selectedIdArr.count == 0 {
            let sender_id:String = model.member_id
            let own_id:String = UserModel.shared.userID()! as String
            DispatchQueue.main.async {
                let updatedModel = self.groupDB.getGroupMsg(msg_id: model.message_id)
                if sender_id != own_id{
                    if model.isDownload == "0" || model.isDownload == "4"{
                        self.downloadImage(index: sender.tag, msgModel: model)
                    }else{
                        self.openPic(identifier: model.local_path,msgMode:updatedModel!)
                    }
                }else{
                    print(model.local_path)
                    self.openPic(identifier: model.local_path,msgMode:updatedModel!)
                }
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, index: indexpath)
        }
    }
    
    @objc func videoCellBtnTapped(_ sender: UIButton!)  {
        self.isReload = false
        
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        let model:groupMsgModel.message = msgArray.object(at: sender.tag) as! groupMsgModel.message
        let type:String = model.message_type
        if self.selectedIdArr.count == 0 {
            let sender_id:String = model.member_id
            let own_id:String = UserModel.shared.userID()! as String
            let updatedModel = self.groupDB.getGroupMsg(msg_id: model.message_id)
            var videoName:String = updatedModel!.local_path
            if videoName == "0"{
                videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
            }
            let videoURL = URL.init(string: videoName)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            if sender_id != own_id{
                //check its downloaded
                if model.isDownload == "0" || model.isDownload == "4"{
                    self.downloadVideo(index: sender.tag, model: model)
                }else if model.isDownload == "1"{
                    playerViewController.modalPresentationStyle = .fullScreen
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            }else{
                //check if uploaded or not
                if model.isDownload == "1" {
                    if counter != 0 {
                        self.stopAudioPlayer()
                    }
                    playerViewController.modalPresentationStyle = .fullScreen
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }else if model.isDownload == "4"{//cancelled
                    if Utility.shared.isConnectedToNetwork(){
                        self.groupDB.updateGroupMediaDownload(msg_id: updatedModel!.message_id, status: "0")
                        self.infoHeight()
                        self.scrollCount = 1
                        self.msgTableView.reloadData()
                        
                        PhotoAlbum.sharedInstance.getGroupVideo(local_ID:videoURL!, msg_id: updatedModel!.message_id, requestData: updatedModel!, type: (videoURL?.pathExtension)!,role: self.memberDict.value(forKey: "member_role") as! String, phone: self.memberDict.value(forKey: "member_no")as! String, group_id: self.group_id, group_name: self.groupNameLbl.text!)
                    } else{
                        self.messageTextView.resignFirstResponder()
                        self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
                    }
                }
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, index: indexpath)
        }
    }
    
    //move to gallery
    func openPic(identifier:String,msgMode:groupMsgModel.message){
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if identifier != "0" {
            let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
            if galleryPic == nil{
                self.view.makeToast(Utility().getLanguage()?.value(forKey: "item_not_found") as? String)
            }else{
                let imageInfo = GSImageInfo.init(image: galleryPic!, imageMode: .aspectFit)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen
                self.present(imageViewer, animated: true, completion: nil)
            }
        }else{
            let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(msgMode.attachment)")
            //                let data = try? Data(contentsOf: imageURL!)
            
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
                previousMsg = self.groupDB.getGroupChat(group_id: group_id, offset: "\((tempMsgs?.count)!)")
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
                            self.infoHeight()
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
    
    @objc func locationTapped(_ sender: UIButton!)  {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        self.messageTextView.resignFirstResponder()
        let dict:groupMsgModel.message = msgArray.object(at: sender.tag) as! groupMsgModel.message
        let type:String = dict.message_type
        if self.selectedIdArr.count == 0 {
            if type != "date_sticky"{
                let locationObj = PickLocation()
                locationObj.type = "1"
                locationObj.viewType = "group"
                locationObj.locationModel = dict
                locationObj.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(locationObj, animated: true, completion: nil)
            }
        }else{
            let indexpath = IndexPath.init(row: sender.tag, section: 0)
            self.makeSelection(tag: sender.tag, index: indexpath)
        }
    }
    @objc func addToContact(_ sender: UIButton!)  {
        let dict:groupMsgModel.message = msgArray.object(at: sender.tag) as! groupMsgModel.message
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
    
    //add to contact
    func addChangedContact(phone_no:String)  {
        let store = CNContactStore()
        let contact = CNMutableContact()
        let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :phone_no))
        contact.phoneNumbers = [homePhone]
        contact.namePrefix = ""
        let controller: CNContactViewController = CNContactViewController(forNewContact: contact)
        controller.contactStore = store
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.isNavigationBarHidden = false
        let navigationController: UINavigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: false) {
            // print("Present")
        }
    }
    @objc func refreshContact() {
        DispatchQueue.main.async {}
    }
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        let localObj = LocalStorage()
        viewController.dismiss(animated: true, completion: nil)
        if contact?.givenName != nil || contact != nil{
            localObj.updateName(cotact_id: self.changedMemberId, name: (contact?.givenName)!)
            DispatchQueue.global(qos: .background).async{
                Contact.sharedInstance.synchronize()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
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
            let dict:groupMsgModel.message = self.msgArray.object(at: selectedIndexPath?.row ?? 0) as! groupMsgModel.message
            //arrange msg values
            let msg_type = dict.message_type
            let id = dict.message_id
            if msg_type != "date_sticky"{
                if self.selectedIdArr.filter({$0 == id}).count == 0{
                    let cell:UITableViewCell = self.msgTableView.cellForRow(at: selectedIndexPath!)!
                    cell.tag = (selectedIndexPath?.row ?? 0) + 400
                    //forward only downloaded media files
                    cell.backgroundColor = CHAT_SELECTION_COLOR
                    self.selectedIdArr.append(id)
                    self.selectedIndexArr.append(selectedIndexPath!)
                    self.selectedDict.append(dict)
                    self.forwardView.isHidden = false
                    
                    //msg type
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
                }
            }else{
                self.forwardView.isHidden = true
                let index = self.selectedIdArr.firstIndex(of: id)
                self.selectedIdArr.remove(at: index ?? 0)
                let selectedIndex = self.selectedIndexArr.firstIndex(of: selectedIndexPath!)
                self.selectedIndexArr.remove(at: selectedIndex ?? 0)
                
                if selectedIndexPath!.count != 0 {
                    let cell = view.viewWithTag(selectedIndexPath?.row ?? 0 + 400) as? UITableViewCell
                    cell?.backgroundColor = .clear
                }
            }
        }
    }
    
    //MARK: update tableview cell from bottom
    func scroll(toTheBottom animated: Bool) {
        if msgArray.count != 0 {
            //            self.scrollToBottom()
        }
        
    }
    @IBAction func supportedLanguageBtnTapped(_ sender: Any) {
        let languageObj =  ChooseLanguage()
        languageObj.viewType = "translate"
        languageObj.modalPresentationStyle = .fullScreen
        self.navigationController?.present(languageObj, animated: true, completion: nil)
    }
    
    @objc func translateBtnTapped(_ sender: UIButton!)  {
        let model:groupMsgModel.message = msgArray.object(at: sender.tag) as! groupMsgModel.message
        print(model)
        
        Utility.shared.translate(msg: model.message, callback: { translatedTxt in
            print("translated text \(translatedTxt)")
            DispatchQueue.main.async {
                let newModel =  groupMsgModel.message.init(message_id: model.message_id,
                                                           group_id: model.group_id,
                                                           member_id: model.member_id,
                                                           message_type: model.message_type,
                                                           message:translatedTxt,
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
                                                           translated_msg: translatedTxt)
                self.groupDB.updateTranslated(msg_id: model.message_id, msg: translatedTxt)
                self.msgArray.removeObject(at: sender.tag)
                self.msgArray.insert(newModel, at: sender.tag)
                self.msgTableView.reloadData()
            }
        })
    }
    //check and replace updated message
    func replaceUpdatedMsg(msg_id:String)  {
        var i = 0
        for msg in self.msgArray {
            let msgModel:groupMsgModel.message = msg as! groupMsgModel.message
            if msgModel.message_id == msg_id{
                let updatedMsg = self.groupDB.getGroupMsg(msg_id: msg_id)
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
    //DOWNLOAD IMAGE
    func downloadImage(index:Int, msgModel:groupMsgModel.message)  {
        self.groupDB.updateGroupMediaDownload(msg_id: msgModel.message_id, status: "2")
        let cell = view.viewWithTag(index + 50000) as? ReceiverImageCell
        cell?.loader.play()
        cell?.loader.isHidden = false
        let imageURL = URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(msgModel.attachment)")
        DispatchQueue.global(qos: .background).async {
            let data = try? Data(contentsOf: imageURL!)
            if let imageData = data {
                let image = UIImage(data: imageData)
                if image != nil{
                    PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgModel.attachment,type: "group")
                }
                self.groupDB.updateGroupMediaDownload(msg_id: msgModel.message_id, status: "1")
                self.scrollCount = 1
                DispatchQueue.main.async {
                    self.replaceUpdatedMsg(msg_id: msgModel.message_id)
                }
            }
            
        }
    }
    //DOWNLOAD DOCUMENT
    func downloadDocument(index:Int, model :groupMsgModel.message)  {
        self.groupDB.updateGroupMediaDownload(msg_id: model.message_id, status: "2")
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
                    self.groupDB.updateGroupMediaDownload(msg_id: model.message_id, status: "1")
                    self.scrollCount = 1
                    //                    self.refresh(scroll: true)
                    self.replaceUpdatedMsg(msg_id: model.message_id)
                }
            }
        }
    }
    //DOWNLOAD VIDEO
    func downloadVideo(index:Int, model :groupMsgModel.message)  {
        self.groupDB.updateGroupMediaDownload(msg_id: model.message_id, status: "2")
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
                    PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: model.message_id,type:"group")
                    self.groupDB.updateGroupMediaDownload(msg_id: model.message_id, status: "1")
                    self.scrollCount = 1
                    //                    self.refresh(scroll: true)
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
    
    @objc func endTyping(_ timeStamp: Date?) {
        if (timeStamp == self.timeStamp) {
            let requestDict = NSMutableDictionary()
            requestDict.setValue(UserModel.shared.userID(), forKey: "member_id")
            requestDict.setValue(self.group_id, forKey: "group_id")
            requestDict.setValue("untyping", forKey: "type")
            groupSocket.sharedInstance.typingGroup(reqDict: requestDict)
        }
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
            self.attachmentShow = true
            self.attachmentMenuView.isHidden = true
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
            locationObj.modalPresentationStyle = .overFullScreen
            UIApplication.shared.keyWindow?.rootViewController?.present(locationObj, animated: true, completion: nil)
            //            self.navigationController?.present(locationObj, animated: true, completion: nil)
                
            }
            else{
                self.socketrecoonect()
            }
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //MARK: location fetch delegate
    func fetchCurrentLocation(location: CLLocation) {
        if socket.status == .connected{
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
        msgDict.setValue(self.group_id, forKey: "group_id")
        let encryptedLat = cryptLib.encryptPlainTextRandomIV(withPlainText:"\(location.coordinate.latitude)", key: ENCRYPT_KEY)
        let encryptedLon = cryptLib.encryptPlainTextRandomIV(withPlainText:"\(location.coordinate.longitude)", key: ENCRYPT_KEY)
        
        msgDict.setValue(encryptedLat, forKey: "lat")
        msgDict.setValue(encryptedLon, forKey: "lon")
        msgDict.setValue("location", forKey: "message_type")
        let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Location", key: ENCRYPT_KEY)
        
        msgDict.setValue(encryptedMsg, forKey: "message")
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        self.addToLocal(requestDict: msgDict)
        }else{
            self.socketrecoonect()
        }
    }
    //MARK: ***************** DOCUMENT PICKER METHODS *********************
    
    @IBAction func fileBtnTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork() {
            if socket.status == .connected{
                picDocument()
            }else{
                self.socketrecoonect()
            }
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
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
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
        msgDict.setValue(self.group_id, forKey: "group_id")
        msgDict.setValue("document", forKey: "message_type")
        let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:fileName, key: ENCRYPT_KEY)
        
        msgDict.setValue(encryptedMsg, forKey: "message")
        
        self.uploadFiles(msgDict: msgDict, attachData: fileData! as Data, type: ".\(urls[0].pathExtension)", image: nil)
        
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
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
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
        if socket.status == .connected{
        if contact.isKeyAvailable(CNContactPhoneNumbersKey){
            if contact.phoneNumbers.count != 0  {
                // handle the selected contact
                let msgDict = NSMutableDictionary()
                let msg_id = Utility.shared.random()
                msgDict.setValue("group", forKey: "chat_type")
                msgDict.setValue(msg_id, forKey: "message_id")
                msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
                msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
                msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
                msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
                msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
                msgDict.setValue(self.group_id, forKey: "group_id")
                msgDict.setValue("contact", forKey: "message_type")
                let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Contact", key: ENCRYPT_KEY)
                let encryptedName = cryptLib.encryptPlainTextRandomIV(withPlainText:contact.givenName, key: ENCRYPT_KEY)
                
                msgDict.setValue(encryptedMsg, forKey: "message")
                msgDict.setValue(encryptedName, forKey: "contact_name")
                if contact.phoneNumbers.count == 1 {
                    
                if socket.status == .connected{
                    let encryptedno = self.cryptLib.encryptPlainTextRandomIV(withPlainText: (contact.phoneNumbers.first?.value.value(forKey: "digits") as? String ?? ""), key: ENCRYPT_KEY)
                    msgDict.setValue(encryptedno, forKey: "contact_phone_no")
                    groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
                    self.addToLocal(requestDict: msgDict)
                }else{
                    self.socketrecoonect()
                }
                }
                else {
                    
                    if socket.status != .connected{
                        socketClass.sharedInstance.connect()
                    }
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
                        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
                        self.addToLocal(requestDict: msgDict)
                    }
                    self.navigationController?.pushViewController(pageObj, animated: true)
                    }else{
                        self.socketrecoonect()
                    }
                }
            }else{
                self.view.makeToast(Utility().getLanguage()?.value(forKey: "no_number") as? String)
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
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        //access allowed
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
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
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
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
        msgDict.setValue(self.group_id, forKey: "group_id")
        
        var attachData = Data()
        var type =  String()
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] {
                    let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL as! URL], options: nil)
                    msgDict.setValue(result.firstObject?.localIdentifier, forKey: "local_path")
                }
                // print("infor \(info)")
                attachData = image.jpegData(compressionQuality: 0.1)!//UIImageJPEGRepresentation(image, 0.5)!
                if galleryType == "1"{
                    type = ".jpg"
                }else{
                    let assetPath = info[UIImagePickerController.InfoKey.referenceURL] as! NSURL
                    if (assetPath.absoluteString?.hasSuffix("JPG"))! {
                        type = ".jpg"
                    }else if (assetPath.absoluteString?.hasSuffix("jpeg"))! {
                        type = ".jpeg"
                    } else if (assetPath.absoluteString?.hasSuffix("PNG"))! {
                        type = ".png"
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
                        
                        msgDict.setValue("\((info[UIImagePickerController.InfoKey.referenceURL])!)", forKey: "local_path")
                        self.uploadThumbnail(msgDict: msgDict, attachData: videoData!, fileURL: fileURL, type: type)
                    }else{
                        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: Utility().getLanguage()?.value(forKey: "file_size") as! String, completion: { (index, title) in
                            self.dismiss(animated:true, completion: nil)
                        })
                    }
                }
            }
        }
    }
    //MARK: image picker delegate
    
    //upload video thumbnail
    func uploadThumbnail(msgDict: NSDictionary, attachData: NSData,fileURL:NSURL,type:String)  {
        if Utility.shared.isConnectedToNetwork() {
            let image = Utility.shared.thumbnailForVideoAtURL(url: fileURL as URL)
            let thumbData = image?.jpegData(compressionQuality: 0.5) //UIImageJPEGRepresentation(image!, 0.5)!
            let uploadObj = UploadServices()
            //upload thumbnail
            uploadObj.uploadFiles(fileData: thumbData!, type: ".jpg", user_id: UserModel.shared.userID()! as String,docuName:msgDict.value(forKey: "message") as! String, msg_id: msgDict.value(forKey: "message_id") as! String,api_type:"group", onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                    
                    msgDict.setValue(encryptedMsg, forKey: "thumbnail")
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue(EMPTY_STRING, forKey: "attachment")
                    msgDict.setValue("2", forKey: "isDownload")
                    //upload video file
                    
                    self.addToLocal(requestDict: msgDict)
                    self.groupDB.updateGroupMediaDownload(msg_id: msgDict.value(forKey: "message_id") as! String, status: "2")
                    let videoName:String = fileURL.lastPathComponent!
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/\(videoName)"
                    
                    attachData.write(toFile: filePath, atomically: true)
                    // print("new url \(filePath)")
                    if self.galleryType == "1"{ // SAVE VIDEO TO GALLERY
                        PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "group")
                    }else{
                        self.groupDB.updateGroupMediaLocalURL(msg_id: msgDict.value(forKey: "message_id") as! String, url: msgDict.value(forKey: "local_path") as! String)
                    }
                    
                    groupSocket.sharedInstance.uploadGroupChatVideo(fileData: attachData as Data, type: type, msg_id:  msgDict.value(forKey: "message_id") as! String, requestDict: msgDict)
                }
            })
            dismiss(animated:true, completion: nil)
        }else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    
    //upload files
    func uploadFiles(msgDict:NSDictionary,attachData:Data,type:String,image:UIImage?){
        if Utility.shared.isConnectedToNetwork() {
            if socket.status == .connected{
            let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText:msgDict.value(forKey: "message") as? String, key: ENCRYPT_KEY)!
            
            let uploadObj = UploadServices()
            uploadObj.uploadFiles(fileData: attachData, type: type, user_id: UserModel.shared.userID()! as String,docuName:decryptedMsg,msg_id: msgDict.value(forKey: "message_id") as! String,api_type:"group", onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    let encryptedAtttachment = self.cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                    
                    msgDict.setValue(encryptedAtttachment, forKey: "attachment")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue("0", forKey: "isDownload")
                    //send socket
                    groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
                    self.addToLocal(requestDict: msgDict)
                    //check if photo is already exists in gallery
                    let msgType:String = msgDict.value(forKey: "message_type") as! String
                    if msgType == "image"{
                        if msgDict.value(forKey: "local_path") != nil{
                            if !PhotoAlbum.sharedInstance.checkExist(identifier: msgDict.value(forKey: "local_path") as! String)!{
                                if self.galleryType == "1"{
                                    PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "group")
                                }
                            }else{
                                self.groupDB.updateGroupMediaLocalURL(msg_id: msgDict.value(forKey: "message_id") as! String, url: msgDict.value(forKey: "local_path") as! String)
                            }
                        }else{
                            if self.galleryType == "1"{
                                PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "group")
                            }
                        }
                    }
                }
            })
            let msgType:String = msgDict.value(forKey: "message_type") as! String
            
            if msgType != "document"{
                dismiss(animated:true, completion: nil)
            }
                
            }else{
                self.socketrecoonect()
            }
        } else{
            self.messageTextView.resignFirstResponder()
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //socket delegate
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "receivechat" {
            
        }
    }
    // socket group infor
    func gotGroupInfo(dict: NSDictionary, type: String) {
        print("AjmalAJ_4")

        print("dict \(dict) type \(type)")
        
        if type == "messagefromgroup" || type == "memberexited"{
            let group_id:String = dict.value(forKey: "group_id") as! String
            let msgType:String = dict.value(forKey: "message_type") as! String
            if group_id == self.group_id{
                self.scrollCount = 0
                let msg_type:String = dict.value(forKey: "message_type") as! String
                let member_id:String = dict.value(forKey: "member_id") as! String
                
                var addMsg = true
                if msg_type == "admin" {
                    if member_id != "\(UserModel.shared.userID()!)"{
                        addMsg = false
                    }
                }
                let msg_id:String = dict.value(forKey: "message_id") as! String
                
                
                let cryptLib = CryptLib()
                let msg:String = dict.value(forKey: "message") as! String
                let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText:msg, key: ENCRYPT_KEY)
                //            smart replay add-on
//                if member_id != UserModel.shared.userID()! as String{
//                    if msg_type == "text" {
//                        self.showSmartReplies(msg: decryptedMsg!)
//                    } else {
//                    }
//                }
                if self.isTranslate{
                    //translate add-on
                    Utility.shared.translate(msg:decryptedMsg!, callback: { translatedTxt in
                        print("translated text \(translatedTxt)")
                        DispatchQueue.main.async {
                            self.groupDB.updateTranslated(msg_id:msg_id, msg: translatedTxt)
                            if addMsg {
                                if !self.msgIDs.contains(msg_id){
                                    self.msgIDs.add(msg_id)
                                    let newMsg = self.groupDB.getGroupMsg(msg_id: msg_id)
                                    self.msgArray.add(newMsg!)
                                    self.tempMsgs?.add(newMsg!)
                                    self.infoHeight()
                                    self.msgTableView.reloadData()
                                    self.scrollToBottom()
                                }
                            }
                            
                        }
                    })
                }else{
                    if addMsg {
                        if !msgIDs.contains(msg_id){
                            msgIDs.add(msg_id)
                            let newMsg = self.groupDB.getGroupMsg(msg_id: msg_id)
                            self.msgArray.add(newMsg!)
                            self.tempMsgs?.add(newMsg!)
                            self.infoHeight()
                            self.msgTableView.reloadData()
                            self.scrollToBottom()
                        }
                    }
                }
                if msg_type == "isDelete"{ // type text
                    self.replaceUpdatedMsg(msg_id: msg_id)
                }
                
                
                if !self.downView.isHidden {
                    self.newMsgView.isHidden = false
                }
                
                if msgType == "group_image" {
                    self.groupDict = self.groupDB.getGroupInfo(group_id: group_id)
                    let imageName:String = self.groupDict.value(forKey: "group_icon") as! String
                    self.groupIcon.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "group_placeholder"))
                }else if msgType == "subject"{
                    self.groupDict = self.groupDB.getGroupInfo(group_id: group_id)
                    self.groupNameLbl.text = self.groupDict.value(forKey: "group_name") as? String
                }else if msgType == "remove_member"{
                    let member_id = dict.value(forKey: "member_id") as! String
                    if member_id == UserModel.shared.userID()! as String{
                        groupDB.groupExit(group_id: group_id)
                        self.groupDict = groupDB.getGroupInfo(group_id: self.group_id)
                        self.configExitStatus()
                        self.configGroupMembers()
                    }
                }else if msgType == "add_member"{
                    self.groupDict = groupDB.getGroupInfo(group_id: self.group_id)
                    self.configExitStatus()
                    groupDB.deleteAllMember(group_id: self.group_id)
                    self.updateGroupInfo()
                    self.refresh(scroll: false)
                }else{
                    self.configGroupMembers()
                }
                
            }
            
        }else if type == "groupUploadVideo" {
            let group_id:String = dict.value(forKey: "group_id") as! String
            let msg_id:String = dict.value(forKey: "message_id") as! String
            if group_id == self.group_id{
                //                self.scrollCount = 0
                //                self.refresh(scroll: true)
                self.replaceUpdatedMsg(msg_id: msg_id)
            }
        }else if type == "listengrouptyping" {
            if self.exitStatus != "1"{
                let type:String = dict.value(forKey: "type") as! String
                let groupId:String = dict.value(forKey: "group_id") as! String
                let member_id:String = dict.value(forKey: "member_id") as! String
                if groupId == self.group_id{
                    if member_id != "\(UserModel.shared.userID()!)"{
                        if type == "untyping"{
                            self.groupMembersLbl.text = self.nameListString
                        }else if type == "typing"{
                            self.groupMembersLbl.text = "\(Utility.shared.getUsername(user_id: member_id)) typing..."
                        }
                        else if type == "recording" {
                            self.groupMembersLbl.text = "\(Utility.shared.getUsername(user_id: member_id)) recording..."
                        }
                    }
                }
            }
        }else if type == "refreshGroup" || type == "groupRecentMsg"{
            self.scrollCount = 0
            self.refresh(scroll: true)
        }else if type == "groupinvitation" {
            
            self.groupDict = groupDB.getGroupInfo(group_id: self.group_id)
            print("groupdid \(groupDict)")
            self.configExitStatus()
            groupDB.deleteAllMember(group_id: self.group_id)
            self.updateGroupInfo()
            self.refresh(scroll: false)
        }
        
        
        
    }
    
    func updateGroupInfo(){
        let groupArray = NSMutableArray()
        groupArray.add(group_id)
        let groupObj = GroupServices()
        groupObj.groupInfo(groupArray: groupArray, onSuccess: {response in
            let groupList:NSArray = response.value(forKey: "result") as! NSArray
            for groupDict in groupList{
                let groupDetails :NSDictionary = groupDict as! NSDictionary
                let group_members:NSArray = groupDetails.value(forKey: "group_members") as! NSArray
                groupSocket.sharedInstance.addGroupMembers(groupId: self.group_id, members: group_members, type: "1")
            }
            self.configGroupMembers()
        })
    }
    //MARK: ***************** Audiogroup Implementation *********************
    
    
    @objc func uploadAudiotoServer(){
        
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        msgDict.setValue(self.memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(self.memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(self.memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.groupNameLbl.text, forKey: "group_name")
        msgDict.setValue(self.group_id, forKey: "group_id")
        
        
        let result = PHAsset.fetchAssets(withALAssetURLs: [getFileUrl()], options: nil)
        msgDict.setValue(result.firstObject?.localIdentifier, forKey: "local_path")
        let videoData = NSData.init(contentsOf: getFileUrl() as URL)
        
        
        msgDict.setValue("audio", forKey: "message_type")
        let encryptMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:"audio", key: ENCRYPT_KEY)
        
        msgDict.setValue(encryptMsg, forKey: "message")
        var type =  String()
        if (getFileUrl().absoluteString.hasSuffix("m4a")) {
            type = ".m4a"
        } else {
            type = ".mp3"
        }
        self.uploadaudioFiles(msgDict: msgDict,attachData: videoData! as Data, type:type)
        // socketClass.sharedInstance.uploadaudioFiles(msgDict: msgDict, requestDict: requestDict, attachData: videoData! as Data, type:type,msg_id: msgDict.value(forKey: "message_id") as! String)
        
        
        
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
                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
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
            if audioRecorder != nil {
                audioRecorder.stop()
                audioRecorder = nil
            }
            // print("recorded successfully.")
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
            //            audioPlayer.volume = 1.0
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
        //play_btn_ref.isEnabled = true
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
    
    
    func uploadaudioFiles(msgDict:NSDictionary,attachData:Data,type:String){
        if Utility.shared.isConnectedToNetwork() {
            
            
            if socket.status != .connected{
                socketClass.sharedInstance.connect()
            }
            if socket.status == .connected{
            let uploadObj = UploadServices()
            uploadObj.uploadFiles(fileData: attachData, type: type, user_id: UserModel.shared.userID()! as String,docuName:msgDict.value(forKey: "message") as! String,msg_id: msgDict.value(forKey: "message_id") as! String,api_type:"group", onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    let encryptedAtttachment = self.cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                    msgDict.setValue(encryptedAtttachment, forKey: "attachment")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                    msgDict.setValue("0", forKey: "isDownload")
                    //send socket
                    groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
                    self.addToLocal(requestDict: msgDict)
                    //                    PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "group")
                }
            })
            dismiss(animated:true, completion: nil)
            }else{
                self.socketrecoonect()
            }
        } else{
            // self.messageTextView.resignFirstResponder()
            //  self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //Mark:downloadaudiofromServer ------------------------------------------->
    
    func downloadaudiofromserver(index:Int, model :groupMsgModel.message)  {
        
        self.groupDB.updateGroupMediaDownload(msg_id: model.message_id, status: "2")
        let cell = view.viewWithTag(index + 4000) as! ReceiverVoiceCell
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
                    PhotoAlbum.sharedInstance.saveVideo(url: URL.init(string: filePath)!, msg_id: model.message_id,type:"group")
                    self.groupDB.updateGroupMediaDownload(msg_id: model.message_id, status: "1")
                    self.scrollCount = 1
                    //                    DispatchQueue.main.async {
                    self.replaceUpdatedMsg(msg_id: model.message_id)
                    cell.loader.stop()
                    self.msgTableView.reloadData()
                    
                    //                    }
                    
                }
            }
        }
        
    }
    
    
    
    //Mark: download Audio and store the audio to local path -------------------------->
    
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
                    } catch let error as NSError {
                        // print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    func stopAudioPlayer() {
        let dict:groupMsgModel.message = msgArray.object(at: tag_value) as! groupMsgModel.message
        let sender_Tag_id:String = dict.member_id
        let own_id:String = UserModel.shared.userID()! as String
        if sender_Tag_id != own_id {
            let cell1 = view.viewWithTag(tag_value + 4000) as? ReceiverVoiceCell
            audioPlayer.stop()
            self.timer.invalidate()
            cell1?.playerImg.image = UIImage(named:"play_audio.png")
            cell1?.audioProgress.value = Float(audioPlayer.currentTime)
            cell1?.PlayerBtn.clipsToBounds = true
            audioPlayer.currentTime = TimeInterval(0)
            cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
        }
        else {
            let cell1 = view.viewWithTag(tag_value + 3000) as? SenderAudioCell
            audioPlayer.stop()
            self.timer.invalidate()
            cell1?.playerImg.image = UIImage(named:"play_audio.png")
            cell1?.audioProgress.value = Float(audioPlayer.currentTime)
            cell1?.PlayerBtn.clipsToBounds = true
            audioPlayer.currentTime = TimeInterval(0)
            cell1?.audioProgress.value = Float(0)//Float(audioPlayer.currentTime)
            
        }
    }
    @objc func audioCellBtnTapped(_ sender: UIButton!)  {
        if Utility.shared.isConnectedToNetwork(){
            let model:groupMsgModel.message = msgArray.object(at: sender.tag) as! groupMsgModel.message
            if self.selectedIdArr.count == 0 {
                let sender_id:String = model.member_id
                let own_id:String = UserModel.shared.userID()! as String
                let updatedModel = self.groupDB.getGroupMsg(msg_id: model.message_id)
                var videoName:String = updatedModel!.local_path
                if videoName == "0"{
                    videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
                }
                let videoURL = URL.init(string: videoName)
                
                if tag_value != sender.tag && counter != 0 {
                    self.stopAudioPlayer()
                }
                
                if sender_id != own_id {
                    //check its downloaded
                    if model.isDownload == "0" || model.isDownload == "4"{
                        self.downloadaudiofromserver(index: sender.tag, model:model)
                        
                    }else if model.isDownload == "1"  || model.isDownload == "2"{
                        //if !audioPlayer.isPlaying || audioPlayer == nil {
                        if let audioUrl = URL(string: videoName) {
                            
                            // then lets create your document folder url
                            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            // lets create your destination file url
                            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                            
                            do {
                                if currentAudioMsgID.isEmpty || currentAudioMsgID != model.message_id {
                                    let data = try Data(contentsOf: destinationUrl)
                                    audioPlayer = try AVAudioPlayer.init(data: data)
                                    audioPlayer.prepareToPlay()
                                    currentAudioMsgID = model.message_id
                                    counter = 0
                                }
                                
                                let cell = view.viewWithTag(sender.tag + 4000) as? ReceiverVoiceCell
                                let maximumvalue:Double = audioPlayer.duration
                                //duration(for: videoName)
                                let int_value:Int = Int(maximumvalue)
                                
                                
                                cell?.audioProgress?.minimumValue = 0
                                cell?.audioProgress?.maximumValue = Float(int_value)
                                str_value_tofind_which_voiceCell = "ReceiverVoiceCell"
                                if counter == 0 {
                                    if (cell?.audioProgress.value ?? 0) != 0 {
                                        let audioValue = cell?.audioProgress.value
                                        audioPlayer.currentTime = Double(audioValue ?? 0) //* audioPlayer.duration / 100 // audioPlayer.currentTime * 100.0 / audioPlayer.duration
                                    }
                                    dowloadFile(audioString: videoName)
                                    audioPlayer.play()
                                    cell?.playerImg.image = UIImage(named:"pause_receive.png")
                                    
                                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer), userInfo: nil, repeats: true)
                                    
                                    cell?.PlayerBtn.clipsToBounds = true
                                    tag_value = sender.tag
                                    counter = 1
                                }else if tag_value == sender.tag {
                                    audioPlayer.pause()
                                    self.timer.invalidate()
                                    cell?.playerImg.image = UIImage(named:"play_receive.png")
                                    //                                    cell?.audioProgress.value = Float(audioPlayer.currentTime)
                                    cell?.audioProgress.clipsToBounds = true
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
                                    
                                    let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
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
                }
                
                else{
                    //check if uploaded or not
                    if model.isDownload == "0" || model.isDownload == "4"{
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
                                
                                let cell = view.viewWithTag(sender.tag + 3000) as? SenderAudioCell
                                cell?.audioProgress?.minimumValue = 0
                                cell?.audioProgress?.maximumValue = Float(int_value)
                                str_value_tofind_which_voiceCell = "SenderAudioCell"
                                if counter == 0 {
                                    dowloadFile(audioString: videoName)
                                    audioPlayer.play()
                                    cell?.playerImg.image = UIImage(named:"pause_audio.png")
                                    //cell?.PlayerBtn.setImage(UIImage(named:"pause_audio.png"), for: UIControlState.normal)
                                    
                                    //                                    let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
                                    // print(normalizedTime)
                                    //                                    cell?.audioProgress.value = normalizedTime
                                    
                                    cell?.PlayerBtn.clipsToBounds = true
                                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer), userInfo: nil, repeats: true)
                                    
                                    tag_value = sender.tag
                                    counter = 1
                                }
                                else if tag_value == sender.tag {
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
                                    
                                    let normalizedTime = Float(audioPlayer.currentTime * 100.0 / audioPlayer.duration)
                                    // print(normalizedTime)
                                    //                                        cell?.audioProgress.value = normalizedTime
                                    
                                    cell?.PlayerBtn.clipsToBounds = true
                                    tag_value = sender.tag
                                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer), userInfo: [cell?.audioProgress.tag ?? 0], repeats: true)
                                    
                                    counter = 1
                                }
                                
                            } catch let _ {
                                // print(error.localizedDescription)
                            }
                        }
                    }
                    else if model.isDownload == "4"{//cancelled
                        if Utility.shared.isConnectedToNetwork(){
                            self.groupDB.updateGroupMediaDownload(msg_id: updatedModel!.message_id, status: "0")
                            self.infoHeight()
                            self.scrollCount = 1
                            self.msgTableView.reloadData()
                            PhotoAlbum.sharedInstance.getGroupVideo(local_ID:videoURL!, msg_id: updatedModel!.message_id, requestData: updatedModel!, type: (videoURL?.pathExtension)!,role: self.memberDict.value(forKey: "member_role") as! String, phone: self.memberDict.value(forKey: "member_no")as! String, group_id: self.group_id, group_name: self.groupNameLbl.text!)
                        } else{
                            self.messageTextView.resignFirstResponder()
                            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
                        }
                    }
                }
            }
            else{
                let indexpath = IndexPath.init(row: sender.tag, section: 0)
                self.makeSelection(tag: sender.tag, index: indexpath)
            }
        }
        else{
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "check_network") as? String)
        }
        
        
    }
    @objc func respondToSlideEvents(sender: UISlider) {
        let currentValue: Float = Float(sender.value)
        // print("Event fired. Current value for slider: \(currentValue)%.")
        if self.tag_value == sender.tag {
            if str_value_tofind_which_voiceCell == "SenderAudioCell" {
                audioPlayer.currentTime = TimeInterval(currentValue)
                meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateUIWithTimer), userInfo:[sender.tag], repeats:true)
            }
            else if str_value_tofind_which_voiceCell == "ReceiverVoiceCell"{
                audioPlayer.currentTime = TimeInterval(currentValue)
                meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateUIWithTimer), userInfo:[sender.tag], repeats:true)
            }
        }
    }
    
    
    
    func duration(for resource: String) -> Double {
        let asset = AVURLAsset(url: URL(fileURLWithPath: resource))
        return Double(CMTimeGetSeconds(asset.duration))
    }
    
    @objc func updateUIWithTimer(){
        
        if str_value_tofind_which_voiceCell == "SenderAudioCell" {
            let cell = view.viewWithTag(tag_value + 3000) as? SenderAudioCell
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

extension GroupChatPage: RecordViewDelegate {
    
    func onStart() {
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        self.attachmentView.isHidden = true
        self.recorderView.isHidden = false
        if(isAudioRecordingGranted) {
            isSwipeCalled = false
            let requestDict = NSMutableDictionary()
            requestDict.setValue(UserModel.shared.userID(), forKey: "member_id")
            requestDict.setValue(self.group_id, forKey: "group_id")
            requestDict.setValue("recording", forKey: "type")
            groupSocket.sharedInstance.typingGroup(reqDict: requestDict)
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
        else{
            self.view.makeToast(Utility().getLanguage()?.value(forKey: "microphone_alert") as? String)
        }
    }
    
    func onCancel() {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        requestDict.setValue(self.group_id, forKey: "group_id")
        requestDict.setValue("untyping", forKey: "type")
        groupSocket.sharedInstance.typingGroup(reqDict: requestDict)
        self.attachmentView.isHidden = false
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
    func updateDuration(duration: CGFloat) {
        recordView.timeLabelText = duration.SecondsFromTimer()
    }
    func onFinished(duration: CGFloat) {
        self.recorderView.isHidden = true
        // print("end end")
        self.attachmentView.isHidden = false
        finishAudioRecording(success: true)
        if(isRecording)
        {
            ishold = true
            record_btn_ref.frame = CGRect(x:FULL_WIDTH-50, y:record_btn_ref.frame.origin.y, width:40, height:40)
            messageTextView.isHidden = false
            isRecording = false
            
            if(duration > 0.0){
                self.uploadAudiotoServer()
            }
            else {
                self.view.makeToast(Utility().getLanguage()?.value(forKey: "hold_voice") as? String)
            }
            let requestDict = NSMutableDictionary()
            requestDict.setValue(UserModel.shared.userID(), forKey: "member_id")
            requestDict.setValue(self.group_id, forKey: "group_id")
            requestDict.setValue("untyping", forKey: "type")
            groupSocket.sharedInstance.typingGroup(reqDict: requestDict)
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
    }
    
    func onAnimationEnd() {
        //when Trash Animation is Finished
        print("onAnimationEnd")
        self.recorderView.isHidden = true
        messageTextView.isHidden = false
        
    }
    
}
//MARK : UITABLEVIEW
extension GroupChatPage{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.msgArray.count == 0 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ChatDetailsSectionTableViewCell") as? ChatDetailsSectionTableViewCell
            return cell
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.msgArray.count == 0 {
            return UITableView.automaticDimension
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var customcell = UITableViewCell()
        var model:groupMsgModel.message = msgArray.object(at: indexPath.row) as! groupMsgModel.message
        let type:String = model.message_type
        let sender_id:String = model.member_id
        let own_id:String = UserModel.shared.userID()! as String
        print("Tableview type \(type)")
        if type == "text" || type == "isDelete"{ // type text
            let CellIdentifier = "TextCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! TextCell
            cell.sender_id = sender_id
            cell.own_id = own_id
            if type == "isDelete" {
                cell.deleteIcon.isHidden = false
                cell.statusStackView.isHidden = true
                if sender_id == own_id {
                    model.message = "deleted_by_you"
                }
                else {
                    model.message = "deleted_by_others"
                }
            }
            else {
                cell.statusStackView.isHidden = false
                cell.deleteIcon.isHidden = true
            }
            
            cell.translateBtn.tag = indexPath.row
            cell.translateBtn.addTarget(self, action: #selector(self.translateBtnTapped), for: .touchUpInside)
            cell.groupConfig(msgDict: model)
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
//            if indexPath.row == (self.msgArray.count-1) {
//                if sender_id != own_id{
//                    self.showSmartReplies(msg: model.message)
//                }
//            }
            customcell = cell
            
        }else if type == "image"{ // type image
            if sender_id == own_id{
                let senderImgCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                senderImgCell.cellType = "image"
                senderImgCell.configGroupMsg(model: model)
                senderImgCell.imageBtn.tag = indexPath.row
                senderImgCell.imageBtn.addTarget(self, action: #selector(imageCellBtnTapped), for: .touchUpInside)
                customcell = senderImgCell
                //                tableView.rowHeight = 150
            }else{
                let receiverImgCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                receiverImgCell.cellType = "image"
                receiverImgCell.configGroupMsg(model: model)
                receiverImgCell.tag = indexPath.row+50000
                receiverImgCell.imageBtn.tag = indexPath.row
                receiverImgCell.imageBtn.addTarget(self, action: #selector(imageCellBtnTapped), for: .touchUpInside)
                customcell = receiverImgCell
                //                tableView.rowHeight = 170
            }
            
        }else if type == "gif"{ // type image
            if sender_id == own_id{
                let senderImgCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                senderImgCell.cellType = "gif"
                senderImgCell.configGroupMsg(model: model)
                customcell = senderImgCell
            }else{
                let receiverImgCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                receiverImgCell.cellType = "gif"
                receiverImgCell.configGroupMsg(model: model)
                customcell = receiverImgCell
            }
            
        }else if type == "location"{ // type location
            if sender_id == own_id{
                let senderLocObj = tableView.dequeueReusableCell(withIdentifier: "SenderLocCell", for: indexPath) as! SenderLocCell
                senderLocObj.configGroup(model: model)
                senderLocObj.locationBtn.tag = indexPath.row
                senderLocObj.locationBtn.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
                customcell = senderLocObj
                //                tableView.rowHeight = 150
            }else{
                let receiverLocObj = tableView.dequeueReusableCell(withIdentifier: "ReceiverLocCell", for: indexPath) as! ReceiverLocCell
                receiverLocObj.configGroup(model: model)
                receiverLocObj.locationBtn.tag = indexPath.row
                receiverLocObj.locationBtn.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
                customcell = receiverLocObj
                //                tableView.rowHeight = 170
            }
            
        }else if type == "contact"{ // type contact
            if sender_id == own_id{
                let senderContactObj = tableView.dequeueReusableCell(withIdentifier: "SenderContact", for: indexPath) as! SenderContact
                senderContactObj.configGroup(model: model)
                customcell = senderContactObj
                //                tableView.rowHeight = 95
            }else{
                let receiverContactObj = tableView.dequeueReusableCell(withIdentifier: "ReceiverContact", for: indexPath) as! ReceiverContact
                receiverContactObj.configGroup(model:model)
                receiverContactObj.contactAddBtn.tag = indexPath.row
                receiverContactObj.contactAddBtn.addTarget(self, action: #selector(addToContact), for: .touchUpInside)
                customcell = receiverContactObj
                //                tableView.rowHeight = 145
            }
        }else if type == "video"{ // type video
            if sender_id == own_id{
                let sendVideo = tableView.dequeueReusableCell(withIdentifier: "SenderVideoCell", for: indexPath) as! SenderVideoCell
                sendVideo.configGroup(model: model)
                sendVideo.videoBtn.tag = indexPath.row
                sendVideo.videoBtn.addTarget(self, action: #selector(videoCellBtnTapped), for: .touchUpInside)
                customcell = sendVideo
                //                tableView.rowHeight = 150
            }else{
                let receiveVideo = tableView.dequeueReusableCell(withIdentifier: "ReceiverVideoCell", for: indexPath) as! ReceiverVideoCell
                receiveVideo.configGroup(model: model)
                receiveVideo.tag = indexPath.row+20000
                receiveVideo.videoBtn.tag = indexPath.row
                receiveVideo.videoBtn.addTarget(self, action: #selector(videoCellBtnTapped), for: .touchUpInside)
                customcell = receiveVideo
                //                tableView.rowHeight = 170
            }
        }else if type == "audio" { // type video
            
            
            if sender_id == own_id{
                
                let sendaudio = tableView.dequeueReusableCell(withIdentifier: "SenderAudioCell", for: indexPath) as! SenderAudioCell
                sendaudio.selectionStyle = UITableViewCell.SelectionStyle.none
                sendaudio.configGroup(model: model)
                sendaudio.tag = indexPath.row+3000
                sendaudio.PlayerBtn.tag = indexPath.row
                sendaudio.PlayerBtn.addTarget(self, action: #selector(audioCellBtnTapped), for: .touchUpInside)
                sendaudio.audioProgress.tag = indexPath.row
                sendaudio.audioProgress.addTarget(self, action: #selector(respondToSlideEvents), for: .valueChanged)
                
                customcell = sendaudio
                
                //                tableView.rowHeight = 80
            }else{
                let receiveAudio = tableView.dequeueReusableCell(withIdentifier: "ReceiverVoiceCell", for: indexPath) as! ReceiverVoiceCell
                receiveAudio.selectionStyle = UITableViewCell.SelectionStyle.none
                receiveAudio.configGroup(model: model)
                receiveAudio.tag = indexPath.row+4000
                receiveAudio.audioProgress.tag = indexPath.row
                receiveAudio.PlayerBtn.tag = indexPath.row
                receiveAudio.audioProgress.addTarget(self, action: #selector(respondToSlideEvents), for: .valueChanged)
                receiveAudio.PlayerBtn.addTarget(self, action: #selector(audioCellBtnTapped), for: .touchUpInside)
                customcell = receiveAudio
                //                tableView.rowHeight = 80
            }
        }else if type == "document"{ // type document
            if sender_id == own_id{
                let sendDoc = tableView.dequeueReusableCell(withIdentifier: "SenderDocuCell", for: indexPath) as! SenderDocuCell
                sendDoc.configGroup(model: model)
                sendDoc.docBtn.tag = indexPath.row
                sendDoc.docBtn.addTarget(self, action: #selector(docuCellBtnTapped), for: .touchUpInside)
                customcell = sendDoc
                //                tableView.rowHeight = 75
            }else{
                let receiveDocu = tableView.dequeueReusableCell(withIdentifier: "ReceiverDocuCell", for: indexPath) as! ReceiverDocuCell
                receiveDocu.configGroup(model: model)
                receiveDocu.docBtn.tag = indexPath.row
                receiveDocu.tag = indexPath.row
                receiveDocu.docBtn.addTarget(self, action: #selector(docuCellBtnTapped), for: .touchUpInside)
                customcell = receiveDocu
                //                tableView.rowHeight = 95
            }
        }else if type == "create_group" || type == "user_added" || type == "group_image" || type == "left" ||  type ==  "add_member" || type ==  "remove_member" || type == "admin" || type == "subject" || type == "change_number" {
            let info = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
            info.config(model: model)
            customcell = info
        }else if type == "date_sticky"{
            let dateSticky = tableView.dequeueReusableCell(withIdentifier: "dateStickyCell", for: indexPath) as! dateStickyCell
            
            let utcDate = Utility.shared.getSticky(date: model.date)
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
        }else if type == "audio"{
            let audioCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverAudioCell", for: indexPath) as! ReceiverAudioCell
            audioCell.configGroup(model: model)
            customcell = audioCell
        }
        
        if type != "date_sticky"{
            if self.selectedDict.contains(where: {$0.message_id == model.message_id}){
                customcell.backgroundColor = CHAT_SELECTION_COLOR
            }else{
                customcell.backgroundColor = .clear
            }
        }
        if indexPath.row == (self.msgArray.count - 1) && self.scrollCount == 0 {
            self.scrollToBottom()
        }
        return customcell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.messageTextView.resignFirstResponder()
        let model:groupMsgModel.message = msgArray.object(at: indexPath.row) as! groupMsgModel.message
        let type:String = model.message_type
        if self.counter != 0 {
            self.counter = 0
            self.stopAudioPlayer()
        }
        if self.selectedIdArr.count == 0 {
            if type != "date_sticky"{
                if type == "change_number"{
                    if model.member_id != UserModel.shared.userID()! as String {
                        let contactDict = self.localDB.getContact(contact_id: model.member_id)
                        let contact_name:String = contactDict.value(forKey: "contact_name") as! String
                        if contact_name == model.contact_no {
                            self.changedMemberId = model.member_id
                            self.addChangedContact(phone_no: model.contact_no)
                        }else{
                            self.view.makeToast(Utility().getLanguage()?.value(forKey: "contact_added") as? String)
                        }
                    }
                }
            }
        }else{
            if type != "date_sticky"{
                self.makeSelection(tag: indexPath.row, index: indexPath)
            }
        }
    }
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.msgArray.count
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model:groupMsgModel.message = msgArray.object(at: indexPath.row) as! groupMsgModel.message
        let type:String = model.message_type
        let sender_id:String = model.member_id
        let own_id:String = UserModel.shared.userID()! as String
        
        if type == "text" || type == "isDelete"{ // type text
            return UITableView.automaticDimension
        }else if type == "image" || type == "gif"{  // type image
            if sender_id == own_id{
                return 150
            }
            else {
                return 170
            }
        }else if type == "location"{ // type image
            if sender_id == own_id{
                return 150
            }
            else {
                return 170
            }
        }else if type == "contact"{ // type image
            if sender_id == own_id{
                return 95
            }
            else {
                return 145
            }
        }else if type == "video"{ // type Video
            if sender_id == own_id{
                return 150
            }
            else {
                return 170
            }
        }else if type == "audio" { // type Audio
            if sender_id == own_id{
                return 70
            }else {
                return 95
            }
        }else if type == "document"{ // type Video
            if sender_id == own_id{
                return 75
            }
            else {
                return 95
            }
        }else if type == "create_group" || type == "user_added" || type == "group_image" || type == "left" ||  type ==  "add_member" || type ==  "remove_member" || type == "admin" || type == "subject" || type == "change_number" {
            return self.infoSizeArr[indexPath.row]
            
        }else if type == "date_sticky"{
            return 40
        }
        return 40
    }
    func infoHeight() {
        self.infoSizeArr.removeAll()
        for i in 0..<self.msgArray.count {
            let model:groupMsgModel.message = msgArray.object(at: i) as! groupMsgModel.message
            let msg:String = model.message
            var val = heightForView(text: msg, font: UIFont.init(name:APP_FONT_REGULAR, size: 15)!, isDelete: 0)
            
            if model.message_type == "create_group"{
                val = heightForView(text: "\((Utility().getLanguage()?.value(forKey: "you_created_group"))!) \"\(model.message)\"", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
            }else if model.message_type == "user_added"{
                val = heightForView(text: "\(Utility.shared.getUsername(user_id: model.admin_id)) \((Utility().getLanguage()?.value(forKey: "added_you"))!)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
            }else if model.message_type == "left"{ // member exited
                if model.member_id == "\(UserModel.shared.userID()!)"{
                    val = heightForView(text: Utility().getLanguage()?.value(forKey: "you_left") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
                else {
                    val = heightForView(text: "\(Utility.shared.getUsername(user_id: model.member_id)) \((Utility().getLanguage()?.value(forKey: "left"))!)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
            }else if model.message_type == "group_image"{ // member exited
                if model.member_id == "\(UserModel.shared.userID()!)"{
                    val = heightForView(text: Utility().getLanguage()?.value(forKey: "you_changed_group_icon") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
                else {
                    val = heightForView(text: "\(Utility.shared.getUsername(user_id: model.member_id)) \((Utility().getLanguage()?.value(forKey: "group_icon_changed"))!)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
            }else if model.message_type == "subject"{ // member exited
                if model.member_id == "\(UserModel.shared.userID()!)"{
                    val = heightForView(text: "\((Utility().getLanguage()?.value(forKey: "you"))!) \(model.message)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
                else {
                    val = heightForView(text: "\(Utility.shared.getUsername(user_id: model.member_id)) \(model.message)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
            }else if model.message_type == "add_member"{ // member exited
                let names  = Utility.shared.getNames(membersStr: model.attachment)
                
                if model.member_id == "\(UserModel.shared.userID()!)"{
                    val = heightForView(text: "\((Utility().getLanguage()?.value(forKey: "you_group_added"))!) \(names)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
                else {
                    val = heightForView(text: "\(Utility.shared.getUsername(user_id: model.admin_id)) \((Utility().getLanguage()?.value(forKey: "added"))!) \(names)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
            }else if model.message_type == "admin"{ // member exited
                if model.member_id == "\(UserModel.shared.userID()!)"{
                    if model.attachment == "1"{
                        val = heightForView(text: Utility().getLanguage()?.value(forKey: "you_are_admin") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                        
                    }
                    else {
                        val = heightForView(text: Utility().getLanguage()?.value(forKey: "no_longer_admin") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                        
                    }
                }
            }else if model.message_type == "remove_member"{ // member exited
                if model.admin_id == "\(UserModel.shared.userID()!)"{
                    val = heightForView(text: "\((Utility().getLanguage()?.value(forKey: "you_removed"))!) \((Utility.shared.getUsername(user_id: model.member_id)))", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }else if model.member_id == "\(UserModel.shared.userID()!)"{
                    val = heightForView(text: "\((Utility.shared.getUsername(user_id: model.admin_id))) \((Utility().getLanguage()?.value(forKey: "removed_you"))!)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                    
                }
                else {
                    val = heightForView(text: "\((Utility.shared.getUsername(user_id: model.admin_id))) \((Utility().getLanguage()?.value(forKey: "removed"))!) \((Utility.shared.getUsername(user_id: model.member_id)))", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
            }else if model.message_type == "change_number"{
                if model.member_id == "\(UserModel.shared.userID()!)"{
                    val = heightForView(text: Utility().getLanguage()?.value(forKey: "changed_new_no") as? String ?? "", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
                else {
                    var old_no_name = Utility.shared.searchPhoneNoAvailability(phoneNo: model.attachment)
                    var new_no_name = Utility.shared.searchPhoneNoAvailability(phoneNo: model.contact_no)
                    if old_no_name == EMPTY_STRING{
                        old_no_name = model.attachment
                    }
                    if new_no_name == EMPTY_STRING{
                        new_no_name = model.contact_no
                    }
                    val = heightForView(text: "\(old_no_name) \(model.message)", font: UIFont.init(name:APP_FONT_REGULAR, size: 16)!, isDelete: 0)
                }
            }
            self.infoSizeArr.append(30 + val.height)
        }
    }
}

//MARK: UITEXTVIEW

extension GroupChatPage{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        requestDict.setValue(self.group_id, forKey: "group_id")
        requestDict.setValue("typing", forKey: "type")
        groupSocket.sharedInstance.typingGroup(reqDict: requestDict)
        
        let timeStamp = Date()
        self.timeStamp = timeStamp
        let END_TYPING_TIME: CGFloat = 1.5
        perform(#selector(self.endTyping(_:)), with: timeStamp, afterDelay: TimeInterval(END_TYPING_TIME))
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        // print("called")
        self.attachmentMenuView.isHidden = true
    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
}

extension GroupChatPage: noneDelegate{
    func forcheck(type: String){
        self.nonecheck(type: type)
    }
}
