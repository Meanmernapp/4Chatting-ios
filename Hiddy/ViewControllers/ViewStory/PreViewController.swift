
import UIKit
import AVFoundation
import AVKit
import CoreMedia
import Photos
import Lottie
import Alamofire
import IQKeyboardManagerSwift

class PreViewController: UIViewController, SegmentedProgressBarDelegate ,UITextFieldDelegate {
    @IBOutlet weak var imagePreviewView: UIView!
    
    @IBOutlet weak var noViewLabel: UILabel!
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var storyMessageLabel: UILabel!
    @IBOutlet weak var storyMessageStackVoew: UIStackView!
    @IBOutlet weak var otherUserStatusStackView: UIStackView!
    @IBOutlet weak var otherUserStatusView: UIView!
    //    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userProfileView: UIView!
    @IBOutlet weak var animationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var viewUserAnimationView: UIView!
    @IBOutlet weak var viewUserTableView: UITableView!
    @IBOutlet weak var viewerCountLAbel: UILabel!
    @IBOutlet weak var ownUSerStackView: UIStackView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userImageBGView: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var muteUnmuteImage: UIImageView!
    @IBOutlet weak var statusReplyTF: UITextField!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var userStoryView: UIView!
    @IBOutlet weak var otherStoryView: UIView!
    @IBOutlet weak var lblUserStorySeenCount: UILabel!
    @IBOutlet weak var lblUserLikesCount: UILabel!
    @IBOutlet weak var MoreOptionStackView: UIStackView!
    @IBOutlet weak var MoreOptionStackHeight: NSLayoutConstraint!
    var lblVideoImage: String = ""
    @IBOutlet var arrMoreOptionView:[UIView]!
    @IBOutlet weak var moreOptionBaseView: UIView!
    @IBOutlet weak var SaveImageVideoView: UIView!
    @IBOutlet weak var DeleteView: UIView!
    @IBOutlet weak var ReportView: UIView!
    @IBOutlet weak var SpamView: UIView!
    @IBOutlet weak var AppropriateView: UIView!
    @IBOutlet weak var likedImage: UIImageView!
    @IBOutlet weak var LastSeenuserBgView: UIView!
    @IBOutlet weak var LastSeenuserImage: UIImageView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var replyTextView: UITextView!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var attchmentView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var longPressGestureView: UIView!
    
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var replyTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var longPressTimeShowLabel: UILabel!
    @IBOutlet weak var lottieView: AnimationView!
    @IBOutlet weak var longPressMikeBlink: UIImageView!
    @IBOutlet weak var longPressSwipeLabel: UILabel!
    @IBOutlet weak var LastSeenuserBgView1: UIView!
    @IBOutlet weak var LastSeenuserImage1: UIImageView!
    @IBOutlet weak var attackmentView: UIView!
    
    @IBOutlet var simmerView: UIView!
    @IBOutlet weak var viewUserStack: UIStackView!
    @IBOutlet weak var popViewButton: UIButton!
    @IBOutlet weak var viewUserButton: UIButton!
    @IBOutlet weak var LastSeenuserBgView2: UIView!
    @IBOutlet weak var LastSeenuserImage2: UIImageView!
    let del = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var bottomContest: NSLayoutConstraint!
    
    var commentPosted: ((_ dict:NSDictionary,_ type:String) -> Void)?

    var pageIndex : Int = 0
    var segIndex: Int = 0
    var items: [RecentStoryModel] = []
    var item: [statusModel] = []
    var SPB: SegmentedProgressBar!
    var player: AVPlayer!
    let loader = ImageLoader()
    var user_id_Current_story : Int = 0
    var globalindex : Int = 0
    var reason : String = ""
    var position : CGPoint!
    var boolLikeButton : Bool = false
    let socket1 = StorySocket()
    var viewUserList = [viewListModel]()
    let localDB = LocalStorage()
    var isFromChat = false
    var isFirst = true
    var userStatus = userStatusModel(sender_id: "", contact_name: "", profile_image: "", receiver_id: "", StatusDict: [statusModel]())
    //    let usersData = CallParsingFunction()
    //    let loadingIndicator = NVActivityIndicatorView.init(frame: CGRect(x:FULL_WIDTH/2-30,y:FULL_HEIGHT/2-90,width:60,height:60), type: NVActivityIndicatorType.circleStrokeSpin, color: AppOrange, padding: 45)
    var videoURL : URL!
    let gradientLayer = CAGradientLayer()
    var start_index = 0
    var isTouchBegin = false
    let myGroup = DispatchGroup()

    //    let globaldetails = GlobalDetails.getSharedUser()
    //  internal var newVideoPlayer = Player()


    override func viewDidLoad() {
        super.viewDidLoad()
        loaderView.color = SECONDARY_COLOR
        
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }

        IQKeyboardManager.shared.enable = false
        userImageBGView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        userProfileImage.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.userProfileImage.contentMode = .scaleAspectFill
        self.userImageBGView.cornerViewRadius()
        userImageBGView.backgroundColor = UIColor.clear
        self.userImageBGView.layer.borderColor = (SECONDARY_COLOR).cgColor
        self.readMoreBtn.isHidden = true
        //        self.navigationView.elevationEffect()
        self.userProfileView.elevationEffect()
        //        self.otherStoryView.elevationEffect()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let storage = storyStorage()
        print("self.items: \(self.items)")
        let statusDict = storage.getUserInfo(userID: self.items[pageIndex].sender_id)
        let name = self.items[pageIndex].contactName
        userStatus = userStatusModel(sender_id: self.items[pageIndex].sender_id, contact_name: name , profile_image: self.items[pageIndex].userImage, receiver_id: "", StatusDict: statusDict)
        if userStatus.contact_name != "" {
            lblUserName.text = userStatus.contact_name.capitalized
        }
        else {
            lblUserName.text = "You"
        }
        
        item = userStatus.StatusDict
        if isFromChat == true {
            SPB = SegmentedProgressBar(numberOfSegments: 1, duration: 5)
        }
        else {
            SPB = SegmentedProgressBar(numberOfSegments: item.count, duration: 5)
        }
        if #available(iOS 11.0, *) {
            
            let window = UIApplication.shared.keyWindow
              let topPadding = window?.safeAreaInsets.top
            SPB.frame = CGRect(x: 5, y: topPadding!, width: UIScreen.main.bounds.width - 10, height: 5)
        } else {
            // Fallback on earlier versions
            SPB.frame = CGRect(x: 5, y: 15, width: UIScreen.main.bounds.width - 10, height: 5)
        }
        self.navigationView.bringSubviewToFront(deleteButton)
        self.navigationView.bringSubviewToFront(viewUserStack)
        
        self.configTextView(self.replyTextView)
        self.LastSeenViewDesign(img: LastSeenuserImage, vw: LastSeenuserBgView)
        self.LastSeenViewDesign(img: LastSeenuserImage1, vw: LastSeenuserBgView1)
        self.LastSeenViewDesign(img: LastSeenuserImage2, vw: LastSeenuserBgView2)
        SPB.delegate = self
        SPB.topColor = UIColor.white
        SPB.bottomColor = UIColor.white.withAlphaComponent(0.25)
        SPB.padding = 2
        SPB.isPaused = true
        view.addSubview(SPB)
        view.bringSubviewToFront(SPB)
        socket1.delegate = self
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(tapOn(_:)))
        tapGestureImage.numberOfTapsRequired = 1
        tapGestureImage.numberOfTouchesRequired = 1
        imagePreviewView.isUserInteractionEnabled = true
        imagePreviewView.addGestureRecognizer(tapGestureImage)
        
        item = userStatus.StatusDict
        if(UserModel.shared.userID()! as String == "\(userStatus.sender_id)")
        {
            if UserModel.shared.getProfilePic() != nil{
                self.userProfileImage.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(UserModel.shared.getProfilePic()! as String)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            }
            self.ownUSerStackView.isHidden = false
            if(pageIndex == 0)   {
                userStoryView.isHidden = false
                otherStoryView.isHidden = true
                lblUserLikesCount.isHidden = true
                lblUserStorySeenCount.text = ""
                LastSeenuserBgView.isHidden = true
                LastSeenuserBgView1.isHidden = true
                LastSeenuserBgView2.isHidden = true
            }
            else{
                self.ownUSerStackView.isHidden = true
                userStoryView.isHidden = true
                otherStoryView.isHidden = false
            }
        }
        else
        {
            self.userProfileImage.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(self.userStatus.profile_image)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            self.ownUSerStackView.isHidden = true
            userStoryView.isHidden = true
            otherStoryView.isHidden = false
        }
        
        statusReplyTF.delegate = self
        statusReplyTF.layer.borderColor = UIColor.lightText.cgColor
        statusReplyTF.layer.borderWidth = 0.5
        statusReplyTF.layer.cornerRadius = 15
        statusReplyTF.attributedPlaceholder = NSAttributedString(string: "   Sent message",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        //        self.view.addSubview(loadingIndicator)
        
        self.userImageBGView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(self.userPageCall)))
        self.userImageBGView.isUserInteractionEnabled = true
        
        self.lblUserName.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(self.userPageCall)))
        self.lblUserName.isUserInteractionEnabled = true
        self.configMsgField()
        self.storyMessageLabel.config(color:#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), size: 14, align: .center, text: EMPTY_STRING)
//        self.storyMessageLabel.backgroundColor = .red
        self.viewUserTableView.register(UINib(nibName: "PopOverTableViewCell", bundle: nil), forCellReuseIdentifier: "PopOverTableViewCell")
        self.navigationView.elevationEffect()
//        segmentedProgressBarChangedIndex(index: segIndex)
        let layer = Utility.shared.gradient(size: sendBtn.frame.size)
        layer.cornerRadius = sendBtn.frame.size.height / 2
        sendBtn.layer.addSublayer(layer)
        //        sendBtn.layer.borderColor = UIColor.white.cgColor
        //        sendBtn.layer.borderWidth = 2
        sendBtn.bringSubviewToFront(sendBtn.imageView!)
        self.storyMessageLabel.numberOfLines = 3
        self.setGradientBackground(colorTop: UIColor(white: 0, alpha: 0.02), colorBottom: UIColor(white: 0.2, alpha: 0.02))
        self.changeRTLView()
        self.heightConst.priority = .defaultHigh
        self.readMoreBtn.config(color:#colorLiteral(red: 0.09411764706, green: 0.5647058824, blue: 0.537254902, alpha: 1), size: 18, align: .left, title: "read_more")
        self.viewUserAnimationView.elevationEffect()
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        getInitialDuration()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.replyTextView.textAlignment = .right
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
            self.sendBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.SPB.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.SPB.transform = .identity
            self.replyTextView.textAlignment = .left
            self.sendBtn.transform = .identity
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
        }
    }
    func pausePlaySPB(_ status: Bool) {
        print("touchesStatus \(status)")
        print("touchesSPBStatus \(self.SPB.isPaused)")
        if self.SPB.isPaused != status {
            if self.SPB.isPaused == false {
                self.SPB.isPaused = status
            }
            else {
                self.SPB.isPaused = status
                if self.storyMessageLabel.numberOfLines != 3 {
                    self.readMoreBtn.tag = 1
                    self.readMoreBtnAct(self.readMoreBtn)
                }
            }
        }
    }
    @IBAction func readMoreBtnAct(_ sender: UIButton) {
        if sender.tag == 0 {
            self.storyMessageLabel.numberOfLines = 0
            self.pausePlaySPB(true)
            self.heightConst.priority = .defaultLow
            sender.tag = 1
            if self.player != nil {
                self.player?.pause()
            }
            sender.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "read_less"))!) ", for: .normal)
        }
        else {
            sender.tag = 0
            self.heightConst.constant = 100
            self.heightConst.priority = .defaultHigh
            self.storyMessageLabel.numberOfLines = 3
            if self.player != nil {
                self.player?.play()
            }
            self.pausePlaySPB(false)
            sender.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "read_more"))!) ", for: .normal)

        }
        self.storyMessageLabel.sizeToFit()
    }
    @IBAction func swipeAnimation(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            if self.viewUserAnimationView.isHidden != false {
                view.layoutIfNeeded() // force any pending operations to finish
                UIView.animate(withDuration: 0.2, animations: {
                    self.animationViewHeight.constant = 0
                    self.viewUserAnimationView.isHidden = true
                    self.viewUserStack.isHidden = true
                    self.view.layoutIfNeeded()
                }) { (bool) in
                    self.viewUserStack.isHidden = true
                }
            }
        }
        else if sender.direction == .down {
            if self.viewUserAnimationView.isHidden != true {
                self.viewUserList = storyStorage().storyViewList(story_id: self.item[segIndex].story_id)
                self.viewCountLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "view_by"))!) " + Utility.shared.countInAppLanguage(count: self.viewUserList.count)
                self.viewerCountLAbel.text = Utility.shared.countInAppLanguage(count: self.viewUserList.count)
                self.viewUserAnimationView.isHidden = false
                view.layoutIfNeeded() // force any pending operations to finish
                self.animationViewHeight.constant = 0
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.viewUserTableView.reloadData()
                    if self.viewUserTableView.contentSize.height < self.view.frame.width * 2 / 3  {
                        self.animationViewHeight.constant = self.viewUserTableView.contentSize.height + 125
                        self.view.layoutIfNeeded()
                    }
                }) { (bool) in
                    self.viewUserStack.isHidden = false
                }
                
            }
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationView.applyGradient()
        self.navigationView.bringSubviewToFront(viewUserStack)
        self.navigationView.bringSubviewToFront(deleteButton)
        gradientLayer.frame = self.otherUserStatusView.bounds
        self.viewUserAnimationView.layer.cornerRadius = 10
        self.viewUserAnimationView.clipsToBounds = true

        //        self.adjustUITextViewHeight(arg: self.statusTextView)
    }
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor){
        gradientLayer.removeFromSuperlayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0, 1]
        self.otherUserStatusView.layer.insertSublayer(gradientLayer, at: 0)
        self.configTextView(replyTextView)
        self.viewDidLayoutSubviews()
//        gradientLayer.frame = self.otherUserStatusView.bounds
    }
    
    @IBAction func AttachmentSubButtonsAct(_ sender: UIButton) {
        if sender.tag == 0 {
        }
        else if sender.tag == 1 {
        }
        else if sender.tag == 2 {
        }
        else if sender.tag == 3 {
        }
        else if sender.tag == 4 {
        }
    }
    
    @IBAction func sendButtonAct(_ sender: UIButton) {
        self.replyTextView.endEditing(true)
        self.sendBtn.isUserInteractionEnabled = false
        if Utility.shared.isConnectedToNetwork() {
            
            if !Utility.shared.checkEmptyWithString(value: replyTextView.text) && replyTextView.tag == 1 {
                
                
                if socket.status != .connected{
                    socketClass.sharedInstance.connect()
                }
                if socket.status == .connected{
                
                // prepare socket  dict
                let msgDict = NSMutableDictionary()
                let msg_id = Utility.shared.random()
                let msg = replyTextView.text.trimmingCharacters(in: .newlines)
                let cryptLib = CryptLib()
                let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:msg, key: ENCRYPT_KEY)
                let userDict = localDB.getContact(contact_id: self.userStatus.sender_id)
                let blockByMe = userDict.value(forKey: "blockedByMe") as! String
                let blockedMe = userDict.value(forKey: "blockedMe") as! String

                //        let key = "123"
                //        let cryptLib = CryptLib()
                //        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: msg, key: key)
                msgDict.setValue(encryptedMsg, forKey: "message")
                
                msgDict.setValue(self.userStatus.contact_name, forKey: "user_name")
                msgDict.setValue(msg_id, forKey: "message_id")
                msgDict.setValue("story", forKey: "message_type")
                msgDict.setValue(self.userStatus.sender_id, forKey: "receiver_id")
                msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                msgDict.setValue("\(self.userStatus.sender_id)\(UserModel.shared.userID()!)", forKey: "chat_id")
                msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                msgDict.setValue("1", forKey: "read_status")
                msgDict.setValue(msg_id, forKey: "message_id")
                
                msgDict.setValue("single", forKey: "chat_type")
                msgDict.setValue(createJSONObject(), forKey: "status_data")
                msgDict.setValue("1", forKey: "read_status")
                
                let requestDict = NSMutableDictionary()
                requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                requestDict.setValue(self.userStatus.sender_id, forKey: "receiver_id")
                requestDict.setValue(msgDict, forKey: "message_data")
                //send socket
                if blockByMe == "0" && blockedMe == "0"{
                    socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                    self.addToLocal(requestDict: requestDict)
                }else if blockByMe == "1"{
                    self.replyTextView.resignFirstResponder()
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                }else{
                    self.addToLocal(requestDict: requestDict)
                }

                self.replyTextView.text = EMPTY_STRING
                self.replyTextViewHeight.constant = 50
                self.configTextView(replyTextView)
                
                
            }else{
                self.socketrecoonect()
            }
                
            }
            else {
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "send_msg") as? String)
            }
        }else{
            self.replyTextView.resignFirstResponder()
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    func socketrecoonect(){
        self.view.makeToast("Poor network connection...", duration: 2, position: .center)
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
    }
    
    func createJSONObject() -> String {
        let jsonObject: [String: Any] = [
            "story_id": item[segIndex].story_id,
            "message": item[segIndex].message,
            "story_type": item[segIndex].story_type,
            "attachment": item[segIndex].attachment,
            "thumbnail": item[segIndex].thumbNail,
            ]
        
        let valid = JSONSerialization.isValidJSONObject(jsonObject) // true
        if valid == true {
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            // print(jsonString ?? "")
            let cryptLib = CryptLib()
            let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:jsonString, key: ENCRYPT_KEY)
            return encryptedMsg!
        }
        return ""
    }
    func addToLocal(requestDict:NSDictionary)  {
        // print("LOCAL DICT \(requestDict)")
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
        var statusData : String = EMPTY_STRING
        
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
        }
        else if type == "story" {
            // print(createJSONObject())
            statusData = createJSONObject()
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
                             chat_id: "\(UserModel.shared.userID()!)\(self.item[0].sender_id)",
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
            attachment: attach,thumbnail:thumbnail, read_count: readCount, statusData: statusData, blocked: "0")
        self.commentPosted!(requestDict,"storyComment")

        if msgDict.value(forKey: "local_path") != nil {
            
        }
        let unreadcount = localDB.getUnreadCount(contact_id: self.userStatus.sender_id)
        self.localDB.addRecent(contact_id: userStatus.sender_id, msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String, unread_count: "\(unreadcount)",time: requestDict.value(forKeyPath: "message_data.chat_time") as! String)
        //add local array
    }
    func configMsgField()  {

        replyTextView.layer.borderWidth  = 1.0
        replyTextView.layer.borderColor = UIColor.white.cgColor
        replyTextView.font = UIFont.systemFont(ofSize: 18)
        noViewLabel.font = UIFont.systemFont(ofSize: 18)
        noViewLabel.textColor = RECIVER_BG_COLOR
        self.noViewLabel.text = Utility.shared.getLanguage()?.value(forKey: "no_view") as? String ?? ""
        replyTextView.textContainer.lineFragmentPadding = 20
        replyTextView.delegate = self
        replyTextView.layer.cornerRadius = 20.0
        replyTextView.textAlignment = .left
        replyTextView.isUserInteractionEnabled = true
    }
    
    @IBAction func deleteAct(_ sender: UIButton) {
        self.pausePlaySPB(true)
        viewAnimation()
    }
    
    @IBAction func deleteButtonAct(_ sender: UIButton) {
//        let alert = DeleteAlertViewController()
//        alert.modalPresentationStyle = .overCurrentContext
//        alert.modalTransitionStyle = .crossDissolve
//        alert.delegate = self
//        alert.viewType = "0"
//        alert.typeTag = 0
//        alert.msg = "delete_msg"
//        self.present(alert, animated: true, completion: nil)
        deleteActionDone(type: "0", viewType: "0")
    }
    @IBAction func attachmentButtonAct(_ sender: UIButton) {
        self.replyTextView.endEditing(true)
        if sender.tag == 0 {
            sender.tag = 1
            self.attackmentView.isHidden = false
            SPB.isPaused = true
        }
        else {
            sender.tag = 0
            self.attackmentView.isHidden = true
            SPB.isPaused = false
        }
    }
    
    @objc func LastSeenViewDesign(img : UIImageView , vw : UIView)
    {
        vw.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        img.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        self.specificCornerRadius(radius: 12,view : vw)
        vw.backgroundColor = LINE_COLOR
    }
    @objc func userPageCall()
    {
        
        //        if(UserDefaults.standard.object(forKey: "userid") as! String == items[pageIndex].user_id)
        //        {
        //            globaldetails.SELECTED_TABBAR_ITEM = 4
        //            let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //            self.del.setInitialViewController(initialView: menuContainerPage())
        //
        //        }else{
        //            self.dismiss(animated: false, completion: nil)
        //            globaldetails.PROFILE_NAVIGATION_ID = "OTHERPROFILE"
        //            globaldetails.PROFILE_USER_ID = items[pageIndex].user_id
        //            globaldetails.SELECTED_TABBAR_ITEM = 4
        //            let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //            self.del.setInitialViewController(initialView: menuContainerPage())
        //
        //
        //        }
        
    }
    @objc func corderView(view : UIView)
    {
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5;
    }
    
    @objc func MoreoptionDismiss()
    {
        moreOptionBaseView.isHidden = true
        moreOptionBaseView.isUserInteractionEnabled = false
        if(lblVideoImage == "Save Image")
        {
            SPB.isPaused = false
            
        }
        else
        {
            SPB.isPaused = false
            self.player?.pause()
        }
    }
    
    @IBAction func btnLiked_Act(_ sender: Any) {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sendBtn.isUserInteractionEnabled = true
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        self.viewUserTableView.backgroundColor = BOTTOM_BAR_COLOR
        self.viewUserAnimationView.isHidden = true
        UIView.animate(withDuration: 0.8) {
            self.view.transform = .identity
        }
        if #available(iOS 13.0, *) {
        }
        else {
            if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView{
                statusBar.isHidden = true
            }
        }
    }
    func getInitialDuration() {
        self.SPB.startAnimation()
        if self.isFromChat == true {
            for i in 0..<self.item.count {
                if i == self.segIndex{
                    start_index = i
                    return
                }
            }
        }
        else {
            let viewId = self.item.firstIndex(where: {$0.is_Viewed == "0"}) ?? 0
            if self.item.filter({$0.is_Viewed == "0"}).count > 0 {
                for i in 0..<self.item.count {
                    if i == viewId {
                        start_index = i
                        return
                    }
                    else {
                        self.SPB.currentAnimatiopnIndex(animationIndex: i)
                    }
                }
            }
            else {
                start_index = 0
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loaderView.isHidden = true
        self.loaderView.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isFirst = true
            self.playVideoOrLoadImage(index: self.start_index)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        // print("runned get disppear")
        self.resetPlayer()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            self.SPB.currentAnimationIndex = 0
            self.SPB.cancel()
            self.pausePlaySPB(true)
            self.resetPlayer()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    //MARK: - SegmentedProgressBarDelegate
    //1
    func segmentedProgressBarChangedIndex(index: Int) {
        self.pausePlaySPB(true)
        self.start_index = index
        self.playVideoOrLoadImage(index: index)

    }
    //2
    func segmentedProgressBarFinished() {
        if pageIndex == (self.items.count - 1) {
            // self.dismiss(animated: true, completion: nil)
            //            self.homePageCall()
            imagePreviewView.isUserInteractionEnabled = false
            self.navigationController?.popViewController(animated: true)
        }
        else {
            _ = ContentViewControllerVC.goNextPage(fowardTo: pageIndex + 1)
        }
    }
    @IBAction func btnMoreOption_Act(_ sender: Any) {}
    
    @IBAction func btnLastSeen_Act(_ sender: Any) {}
    @objc func viewhide(vw0 : Bool ,vw1 : Bool ,vw2 : Bool ,vw3 : Bool ,vw4 : Bool)
    {
        DeleteView.isHidden = vw0
        SaveImageVideoView.isHidden = vw1
        ReportView.isHidden = vw2
        SpamView.isHidden = vw3
        AppropriateView.isHidden = vw4
        
    }
    @objc func btnDeleteMyStory_Act() {}
    @objc func homePageCall() {
        self.del.setInitialViewController(initialView: menuContainerPage())
    }
    
    @objc func btnSaveVideoPhoto_Act() {
        
        if(lblVideoImage == "Save Image")
        {
            PhotoAlbum.sharedInstance.save(image: imagePreview.image!, msg_id: "",type:"")
            self.showToast(message: "Photos Saved In Gallery")
            SPB.isPaused = false
        }
        else
        {
            
            PhotoAlbum.sharedInstance.saveVideo(url: videoURL, msg_id: "", type: "")
            self.showToast(message: "Video Saved")
            //self.player?.play()
            
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("touchesBegan")
        
        if self.replyTextView.isFirstResponder || self.viewUserAnimationView.isHidden == false {
            if self.viewUserAnimationView.isHidden == false {
                viewAnimation()
            }
            else {
                self.replyTextView.endEditing(true)
            }
            self.pausePlaySPB(false)
            return
        }
        self.isTouchBegin = true
        if let touch = touches.first {
            position = touch.location(in: self.view)
        }
        if self.player != nil {
            self.player?.pause()
        }
        self.pausePlaySPB(true)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
           if !(self.replyTextView.isFirstResponder || self.viewUserAnimationView.isHidden == false) {
               self.pausePlaySPB(false)
               if self.player != nil {
                   self.player?.play()
               }
           }
           self.isTouchBegin = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("toucheEnd")
        super.touchesEnded(touches, with: event)
        if !(self.replyTextView.isFirstResponder || self.viewUserAnimationView.isHidden == false) {
            self.pausePlaySPB(false)
            if self.player != nil {
                self.player?.play()
            }
        }
        self.isTouchBegin = false
    }
    
    @objc func tapOn(_ sender: UITapGestureRecognizer) {
        print("touchesTap")
        position = sender.location(in: self.view)
        print(position)
        if isTouchBegin {
            print("toucheEnd")
            if !(self.replyTextView.isFirstResponder || self.viewUserAnimationView.isHidden == false) {
                self.pausePlaySPB(false)
                if self.player != nil {
                    self.player?.play()
                }
            }
            self.isTouchBegin = false
            return
        }
        else if self.replyTextView.isFirstResponder || self.viewUserAnimationView.isHidden == false {
            if self.viewUserAnimationView.isHidden == false {
                viewAnimation()
            }
            else {
                self.replyTextView.endEditing(true)
            }
            self.pausePlaySPB(false)
            return
        }
        if UserModel.shared.getAppLanguage() == "عربى" && self.isFromChat == false{
            if(position.x > 0) && (position != nil)
            {
                if(position.x > self.view.center.x)
                {
                    
                    if (position.x > self.view.center.x) && (segIndex > 0) { //
                        if (self.storyMessageLabel.numberOfLines == 3 || self.readMoreBtn.isHidden == true) {
                            self.SPB.rewind()
                        }
                    }
                    else {
                        if self.player != nil {
                            self.player?.play()
                        }
                    }
                }
                else if(position.x < self.view.frame.width - 75)
                {
                    if (self.storyMessageLabel.numberOfLines == 3 || self.readMoreBtn.isHidden == true) {
                        self.pausePlaySPB(true)
                        self.SPB.skip()
                    }
                }
            }
        }
        else if self.isFromChat == false{
            if(position.x > 0) && (position != nil)
            {
                if(position.x < self.view.center.x)
                {
                    if (position.x < self.view.center.x) && (segIndex > 0) { //
                        if (self.storyMessageLabel.numberOfLines == 3 || self.readMoreBtn.isHidden == true) {
                            self.SPB.rewind()
                        }
                    }
                    else {
                        if self.player != nil {
                            self.player?.play()
                        }
                    }
                }
                else
                {
                    if (self.storyMessageLabel.numberOfLines == 3 || self.readMoreBtn.isHidden == true) {
                        self.pausePlaySPB(true)
                        self.SPB.skip()
                    }
                }
            }
        }
    }
    func viewAnimation() {
        if self.viewUserAnimationView.isHidden == false {
            if self.player != nil {
                self.player?.play()
            }
            view.layoutIfNeeded() // force any pending operations to finish
            UIView.animate(withDuration: 0.2, animations: {
                self.animationViewHeight.constant = 0
                self.viewUserAnimationView.isHidden = true
                self.viewUserStack.isHidden = true
                self.view.layoutIfNeeded()
            }) { (bool) in
                self.viewUserStack.isHidden = true
            }
        }
        else{
            if self.player != nil {
                self.player?.pause()
            }
            self.viewUserList = storyStorage().storyViewList(story_id: self.item[segIndex].story_id)
            self.viewCountLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "view_by"))!) " + Utility.shared.countInAppLanguage(count: self.viewUserList.count)
            self.viewUserAnimationView.isHidden = false
            view.layoutIfNeeded() // force any pending operations to finish
            self.animationViewHeight.constant = 0
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.viewUserTableView.reloadData()
                if self.viewUserTableView.contentSize.height < self.view.frame.width * 2 / 3  {
                    if self.viewUserList.count == 0 {
                        self.animationViewHeight.constant = self.viewUserTableView.contentSize.height + 125
                    }
                    else {
                        if CGFloat(self.viewUserList.count * 100) < (self.view.frame.height / 2) {
                            self.animationViewHeight.constant = CGFloat(self.viewUserList.count * 100 + 50)
                        }
                        else {
                            self.animationViewHeight.constant = (self.view.frame.height / 2)

                        }
                    }
                    self.view.layoutIfNeeded()
                }
            }) { (bool) in
                self.viewUserStack.isHidden = false
            }
        }
        self.viewDidLayoutSubviews()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    //MARK: - Play or show image
    func playVideoOrLoadImage(index: NSInteger) {
        self.segIndex = index
        let dict = NSDictionary()
        self.resetPlayer()
        self.loaderView.startAnimating()
        self.imagePreview.alpha = 0
        self.pausePlaySPB(true)
        self.storyMessageLabel.text = item[index].message
        if self.storyMessageLabel.text == "" {
            storyMessageStackVoew.isHidden = true
        }
        else {
            storyMessageStackVoew.isHidden = false
        }
        if self.storyMessageLabel.calculateMaxLines() <= 3 {
            self.readMoreBtn.isHidden = true
        }
        else {
            self.readMoreBtn.isHidden = false
        }
        lblTime.text = Utility.shared.getPreviewStatusTime(timeStamp: item[index].story_time)
        if (item[index].local_path != "" && item[index].local_path != "0"){
            print(item[index].local_path)
            if item[index].story_type == "image" {
                self.imagePreview.isHidden = false
                self.videoView.isHidden = true
                self.SPB.duration = 5
                if self.isFirst == true {
                    self.isFirst = false
                    if self.isFromChat == true {
                        self.SPB.animate(animationIndex: 0)
                    }
                    else {
                        self.SPB.animate(animationIndex: index)
                    }
                }
                self.imagePreview.sd_setImage(with: URL(string:item[index].local_path), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"), options: []) { (image, err, data, imgURL) in
                    UIView.animate(withDuration: 1) {
                        self.imagePreview.alpha = 1
                        self.loaderView.stopAnimating()
                        DispatchQueue.main.async {
                            self.pausePlaySPB(false)
                        }
                    }
                    DispatchQueue.main.async {
                        self.pausePlaySPB(false)
                    }
                }
            }
            else {
                self.imagePreview.isHidden = true
                self.videoView.isHidden = false
                do {
                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    var destinationUrl = documentsDirectoryURL.appendingPathComponent(DOCUMENT_PATH)
                    destinationUrl = destinationUrl.appendingPathComponent((item[index].attachment))
                    self.player = AVPlayer(url: destinationUrl)
                    self.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
                    let videoLayer = AVPlayerLayer(player: self.player)
                    videoLayer.frame = view.bounds
                    videoLayer.videoGravity = .resizeAspect
                    self.videoView.layer.addSublayer(videoLayer)
                    self.SPB.duration = CMTimeGetSeconds(player?.currentItem!.asset.duration ?? CMTime(seconds: 5, preferredTimescale: 1000))
                    if self.isFirst == true {
                        self.isFirst = false
                        if self.isFromChat == true {
                            self.SPB.animate(animationIndex: 0)
                        }
                        else {
                            self.SPB.animate(animationIndex: index)
                        }
                    }
                    self.pausePlaySPB(true)
                    self.player?.play()

                }
                 catch let error {
                 print("Status Video Play: \(error.localizedDescription)")
                }
            }
        }
        else {
            let urlPath = URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(item[index].attachment)")
            if urlPath != nil {
                self.imagePreview.alpha = 0
                self.loaderView.isHidden = false
                self.loaderView.startAnimating()
                self.downloadUsingAlamofire(url: urlPath!, fileName: DOCUMENT_PATH, storyID: item[index].story_id, index: index)
            }
        }
        if(UserModel.shared.userID()! as String != "\(userStatus.sender_id)") {
//            let storyObj = StoryServices()
//            storyObj.storyViewed(story_id: item[index].story_id, onSuccess:{response in
//            })
            self.socket1.viewStory(sender_id: UserModel.shared.userID()! as String , receiver_id: item[index].sender_id , story_id: item[index].story_id)

            self.viewAct(dict: dict)
        }
        else {
            self.viewUserList = storyStorage().storyViewList(story_id: self .item[index].story_id)
            self.viewCountLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "view_by"))!) " + Utility.shared.countInAppLanguage(count: self.viewUserList.count)
            self.viewerCountLAbel.text = Utility.shared.countInAppLanguage(count: self.viewUserList.count)
            
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if item[segIndex].story_type != "image" {
            if object as AnyObject? === self.player {
                if keyPath == "status" {
                    
                } else if keyPath == "timeControlStatus" {
                    if player.timeControlStatus == .playing {
                        if (self.player.rate != 0 && self.player?.error == nil){
                            self.pausePlaySPB(false)
                        }
                        self.loaderView.stopAnimating()
                    } else {
//                        self.pausePlaySPB(false)
//                        self.loaderView.stopAnimating()
//                        self.loaderView.isHidden = true
                    }
                } else if keyPath == "rate" {}
            }
        }
    }
    
    // MARK: Private func
    private func getDuration(at index: Int) -> TimeInterval {
        var retVal: TimeInterval = 5.0
        if item.count > index {
            print(item[index].story_type)
            if item[index].story_type == "image" {
                retVal = 5.0
            } else {
                guard let url = NSURL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(item[index].attachment)") as URL? else { return retVal }
                self.player = AVPlayer(url: url)
                retVal = CMTimeGetSeconds(player?.currentItem!.asset.duration ?? CMTime(seconds: 5, preferredTimescale: 1000))
            }
            
        }
        return retVal
    }
    
    func specificCornerRadius(radius:Int ,view : UIView)
    {
        let rectShape = CAShapeLayer()
        rectShape.bounds = view.frame
        rectShape.position = view.center
        rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topRight , .bottomLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        view.layer.mask = rectShape
    }
    private func resetPlayer()
    {
        if player != nil {
            player?.pause()
            player?.replaceCurrentItem(with: nil)
            player = nil
        }
    }
    //    private func resetPlayer() {
    //         newVideoPlayer.setupPlayerItem(nil)
    //        self.newVideoPlayer.removePlayerObservers()
    //    }
    @objc func willResignActive() {
        resetPlayer()
        self.pausePlaySPB(true)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func closeButtonact(_ sender: UIButton) {
        resetPlayer()
        self.pausePlaySPB(true)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    func downloadUsingAlamofire(url: URL, fileName: String, storyID: String, index: NSInteger) {
        myGroup.enter()
        let manager = Alamofire.SessionManager.default
        var documentsURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsURL.appendPathComponent(DOCUMENT_PATH)
        let fileURL = url
        let filePath = fileURL.lastPathComponent
        documentsURL.appendPathComponent(filePath)
        print(documentsURL)
        if (NSData(contentsOf: documentsURL) != nil) {
            let storage = storyStorage()
            storage.updateLocalPath(storyID: storyID, local_path: "\(documentsURL)")
            self.item = storage.getUserInfo(userID: self.items[self.pageIndex].sender_id)
            if self.start_index == index {
                self.loaderView.isHidden = true
                self.loaderView.stopAnimating()
                self.playVideoOrLoadImage(index: index)
            }
        }
        else {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (documentsURL, [.removePreviousFile])
            }
            manager.download(url, to: destination)
                
                .downloadProgress(queue: .main, closure: { (progress) in
                    //progress closure
                    print(progress.fractionCompleted)
                })
                .validate { request, response, temporaryURL, destinationURL in
                    // Custom evaluation closure now includes file URLs (allows you to parse out error messages if necessary)
                    return .success
            }
                
            .responseData { response in
                if let destinationUrl = response.destinationURL {
                    print(destinationUrl)
                    
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Success: \(statusCode)")
                    }
                    let documentPathUrl = "\(destinationUrl)"
                    let storage = storyStorage()
                    storage.updateLocalPath(storyID: storyID, local_path: documentPathUrl)
                    self.myGroup.leave()
                    self.item = storage.getUserInfo(userID: self.items[self.pageIndex].sender_id)
                    self.loaderView.isHidden = true
                    self.loaderView.stopAnimating()
                    
                } else {
                }
            }
            self.myGroup.notify(queue: .main) {
                if self.start_index == index {
                    self.playVideoOrLoadImage(index: index)
                }
            }
        }
        
    }
    //MARK: - Button actions
    @IBAction func close(_ sender: Any) {
        //     self.dismiss(animated: true, completion: nil)
        //        self.del.setInitialViewController(initialView: menuContainerPage())
        //        resetPlayer()
        self.pausePlaySPB(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnVolumeMute_Act(_ sender: Any) {
        
        if player?.isMuted == false {
            player?.isMuted = true
            muteUnmuteImage.image = UIImage(named: "speaker_mute")
        } else {
            player?.isMuted = false
            muteUnmuteImage.image = UIImage(named: "speaker")
            
        }
        
    }
    
    //MARK: Keyboard hide/show
       @objc func keyboardWillShow(sender: NSNotification) {
           let info = sender.userInfo!
        print("keyboard log")
           let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomContest.constant = (keyboardFrame.height-50)
    
       }
       
       @objc func keyboardWillHide(sender: NSNotification) {
           self.bottomContest.constant = 0
       }
    
    public func textFieldDidBeginEditing(_ textField: UITextField){
        
        if(textField == statusReplyTF)
        {
            self.pausePlaySPB(true)
            if(lblVideoImage == "Save Video")
            {
                self.player?.pause()
            }
            
        }
        
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        self.statusReplyTF.resignFirstResponder()
        
        return true
    }
    
    @IBAction func btnSendStatusReply_Act(_ sender: Any) {
        if((statusReplyTF.text?.count)!>0){}
    }
    
}
extension PreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noViewLabel.isHidden = false
        return self.viewUserList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.noViewLabel.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopOverTableViewCell") as! PopOverTableViewCell
        cell.config(self.viewUserList[indexPath.row])
        return cell
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-300, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension PreViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.pausePlaySPB(false)
        if self.player != nil {
            self.player?.play()
        }

        self.configTextView(textView)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.player != nil {
            self.player?.pause()
        }
        self.pausePlaySPB(true)
        self.configTextView(textView)
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.frame.height >= 150 && textView.tag != 0 {
            textView.isScrollEnabled = true
            self.replyTextViewHeight.constant = 150
            self.replyTextViewHeight.priority = .defaultHigh
        }
        else {
            textView.isScrollEnabled = false
            self.replyTextViewHeight.constant = 35
            self.replyTextViewHeight.priority = .defaultLow
        }
//        self.configTextView(textView)
    }
    func configTextView(_ sender: UITextView) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.text = ""
        }
        else {
            if sender.text == "" {
                sender.tag = 0
                sender.text = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String ?? ""
            }
        }
        if sender.frame.height >= 150 && sender.tag != 0 {
            sender.isScrollEnabled = true
            self.replyTextViewHeight.constant = 150
            self.replyTextViewHeight.priority = .defaultHigh
        }
        else {
            sender.isScrollEnabled = false
            self.replyTextViewHeight.constant = 35
            self.replyTextViewHeight.priority = .defaultLow
        }

    }
}
extension PreViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.pausePlaySPB(false)
    }
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.pausePlaySPB(true)
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.pausePlaySPB(false)
        return true
    }
}
extension PreViewController: storyDelegate {
    func gotStoryInfo(dict: NSArray, type: String) {
        
    }
    
    func viewAct(dict: NSDictionary) {
        let storage = storyStorage()
        let senderID = UserModel.shared.userID()! as String
        if self.item.count > segIndex {
            let receiverID = item[segIndex].sender_id
            let storyID = item[segIndex].story_id
            storage.addViewList(sender_id: senderID, receiver_id: receiverID, story_id: storyID, timestamp: Utility.shared.getTime())
            storage.updateViewStatus(storyID: storyID)
        }
    }
    
}
extension PreViewController: deleteAlertDelegate {
    func deleteActionDone(type: String, viewType: String) {
        let storage = storyStorage()
        let storyID = self.item[segIndex].story_id
        self.socket1.deleteStory(story_id: storyID, memberID: self.item[segIndex].story_members)
        storage.deleteStory(story_id: storyID, fileName: self.item[segIndex].attachment)
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}


