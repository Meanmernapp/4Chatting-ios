//
//  ProfilePopup.swift
//  Hiddy
//
//  Created by APPLE on 05/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
protocol picPopUpDelegate {
    func popupDismissed()
}

class ProfilePopup: UIViewController ,socketClassDelegate{
    
    @IBOutlet var popview: UIView!
    @IBOutlet var contactNameLbl: UILabel!
    @IBOutlet var profileImgView: UIImageView!
    @IBOutlet var blurView: UIView!
    @IBOutlet var groupToolView: UIView!
    
    var profileDict = NSDictionary()
    var groupDict = NSDictionary()
    var group_id = String()
    var blockedMe = String()
    var blockedByMe = String()
    var viewType = String()
    var delegate:picPopUpDelegate?
    var barType = String()
    let localDB = LocalStorage()
    let callDB = CallStorage()
    var statusBarHide = true
    var darkMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
       
        
        statusBarHide = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.initialSetup()
        self.changeRTLView()
        self.popview.backgroundColor = BACKGROUND_COLOR
        self.groupToolView.backgroundColor = BACKGROUND_COLOR
        if #available(iOS 13.0, *) {
            if UserModel.shared.theme() == "Dark"{
                overrideUserInterfaceStyle = .dark
            }else if UserModel.shared.theme() == "Light"{
                overrideUserInterfaceStyle = .light
            }else if UITraitCollection.current.userInterfaceStyle == .dark{
                overrideUserInterfaceStyle = .dark
            }else if UITraitCollection.current.userInterfaceStyle == .light{
                overrideUserInterfaceStyle = .light
            }
        }
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
//            self.profileImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
        }
        else {
//            self.profileImgView.transform = .identity
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        statusBarHide = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHide
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialSetup()  {
        socketClass.sharedInstance.delegate = self
        self.blurView.frame = CGRect.init(x: 0, y: 0, width: FULL_WIDTH, height: FULL_HEIGHT)
        self.blurView.blurEffect()
        self.contactNameLbl.config(color: .white
            , size: 25, align: .left, text: EMPTY_STRING)
        self.popview.viewRadius(radius:15.0)
        if viewType == "1" {
            self.groupToolView.isHidden = false
            let groupObj = groupStorage()
            self.groupDict = groupObj.getGroupInfo(group_id: self.group_id)
            self.contactNameLbl.text = groupDict.value(forKey: "group_name") as? String
            let imageName:String? = groupDict.value(forKey: "group_icon") as? String
            if imageName != nil{
                self.profileImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)/\(imageName!)"), placeholderImage: #imageLiteral(resourceName: "group_popup"))
            }
            
        }else if viewType == "2"{
            self.groupToolView.isHidden = true
            if profileDict.value(forKey: "member_id") != nil{
            self.profileDict = localDB.getContact(contact_id: profileDict.value(forKey: "member_id") as! String)
                blockedByMe = self.profileDict.value(forKey: "blockedByMe") as! String
                blockedMe = self.profileDict.value(forKey: "blockedMe") as! String
            self.contactNameLbl.text = profileDict.value(forKey: "contact_name") as? String
            self.configBlockStatus()
            }
        }else{
            self.groupToolView.isHidden = true
            self.profileDict = localDB.getContact(contact_id: profileDict.value(forKey: "user_id") as! String)
            blockedByMe = self.profileDict.value(forKey: "blockedByMe") as! String
            blockedMe = self.profileDict.value(forKey: "blockedMe") as! String

            self.contactNameLbl.text = profileDict.value(forKey: "contact_name") as? String
            self.configBlockStatus()
        }
        //tap to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss (_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    //check block
    func configBlockStatus()  {
        if blockedMe == "1" {
            self.profileImgView.image = #imageLiteral(resourceName: "contact_popup_bg")
        }else{
            self.configPrivacySetting()
        }
    }
    //privacy setting
    func configPrivacySetting()  {
        let userid:String = self.profileDict.value(forKey: "user_id") as! String
        let localObj =  LocalStorage()
        self.profileDict = localObj.getContact(contact_id: userid)
        let privacy_image:String = profileDict.value(forKey: "privacy_image") as! String
        let mutual:String = profileDict.value(forKey: "mutual_status") as! String
            if privacy_image == "nobody"{
                self.profileImgView.image = #imageLiteral(resourceName: "contact_popup_bg")
            }else if privacy_image == "everyone"{
                let imageName:String = profileDict.value(forKey: "user_image") as! String
                self.profileImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "contact_popup_bg"))
            }else if privacy_image == "mycontacts"{
                if mutual == "true"{
                    let imageName:String = profileDict.value(forKey: "user_image") as! String
                    self.profileImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "contact_popup_bg"))
                }else{
                    self.profileImgView.image = #imageLiteral(resourceName: "contact_popup_bg")
                }
            }
    }
    
    @IBAction func msgBtnTapped(_ sender: Any) {
        if viewType == "1" {
            let groupObj = GroupChatPage()
            groupObj.modalPresentationStyle = .fullScreen
            groupObj.group_id = self.group_id
            groupObj.viewType = "1"
            self.present(groupObj, animated: true, completion: nil)
//            self.parent?.navigationController?.pushViewController(groupObj, animated: true)
        }else{
            let detailObj = ChatDetailPage()
            detailObj.modalPresentationStyle = .fullScreen
            detailObj.contact_id = profileDict.value(forKey: "user_id") as! String
            detailObj.viewType = "2"
//            self.parent?.navigationController?.pushViewController(detailObj, animated: true)
            self.present(detailObj, animated: true, completion: nil)
        }

    }
    
    @IBAction func videoCallBtnTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork() {

        blockedByMe = self.profileDict.value(forKey: "blockedByMe") as! String
        blockedMe = self.profileDict.value(forKey: "blockedMe") as! String
        if blockedByMe == "1"{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
        }else{
            DispatchQueue.main.async {
            let random_id = Utility.shared.random()
            let pageobj = CallPage()
            pageobj.receiverId =  self.profileDict.value(forKey: "user_id") as? String
            pageobj.random_id = random_id
            pageobj.userdict = self.profileDict
            pageobj.senderFlag = true
            pageobj.call_type = "video"
            // print(time.rounded().clean)
            pageobj.modalPresentationStyle = .fullScreen
            self.callDB.addNewCall(call_id: random_id, contact_id:  self.profileDict.value(forKey: "user_id") as! String, status: "outgoing", call_type: "video", timestamp: Utility.shared.getTime(), unread_count: "0")
            self.present(pageobj, animated: true, completion: nil)
            }
        }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    @IBAction func audioCallBtnTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork() {
        blockedByMe = self.profileDict.value(forKey: "blockedByMe") as! String
        blockedMe = self.profileDict.value(forKey: "blockedMe") as! String
        if blockedByMe == "1"{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
        }else{
            DispatchQueue.main.async {
                let random_id = Utility.shared.random()
                let pageobj = CallPage()
                pageobj.receiverId =  self.profileDict.value(forKey: "user_id") as? String
                pageobj.senderFlag = true
                pageobj.random_id = random_id
                pageobj.call_type = "audio"
                pageobj.userdict = self.profileDict
                pageobj.modalPresentationStyle = .fullScreen
                self.callDB.addNewCall(call_id: random_id, contact_id:  self.profileDict.value(forKey: "user_id") as! String, status: "outgoing", call_type: "audio", timestamp: Utility.shared.getTime(), unread_count: "0")
                self.present(pageobj, animated: true, completion: nil)
            }
        }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    @IBAction func infoBtnTapped(_ sender: Any) {
        if viewType == "1" {
            let groupObj = groupDetailsPage()
            groupObj.group_id = self.group_id
            groupObj.exitType = "1"
            groupObj.modalPresentationStyle = .fullScreen
            self.present(groupObj, animated: true, completion: nil)
        }else{
            let profileObj = ProfilePage()
            profileObj.chatID = "\(UserModel.shared.userID()!)\(self.profileDict.value(forKey: "user_id")!)"
            profileObj.viewType = "other"
            profileObj.contactName =  self.contactNameLbl.text!
            profileObj.exitType = "1"
            profileObj.modalPresentationStyle = .fullScreen
            profileObj.contact_id = self.profileDict.value(forKey: "user_id") as! String
            self.present(profileObj, animated: true, completion: nil)
        }

    }
    
    @IBAction func profilePicBtnTapped(_ sender: Any) {
            if self.viewType == "1" {
            let groupObj = groupDetailsPage()
            groupObj.exitType = "1"
            groupObj.group_id = self.group_id
                groupObj.modalPresentationStyle = .fullScreen
            self.present(groupObj, animated: false, completion:nil);
        }else{
            // print("profile dict \(self.profileDict)");
            let profileObj = ProfilePage()
            profileObj.viewType = "other"
            profileObj.chatID = "\(UserModel.shared.userID()!)\(self.profileDict.value(forKey: "user_id")!)"
            profileObj.contactName =  self.contactNameLbl.text!
            profileObj.exitType = "2"
                profileObj.modalPresentationStyle = .fullScreen
            profileObj.contact_id = self.profileDict.value(forKey: "user_id") as! String
            self.present(profileObj, animated: true, completion: nil)
        }
    }
    
    //dismiss view
    @objc func dismiss(_ sender: UITapGestureRecognizer) {
        if barType == "1"{
            darkMode = true
            setNeedsStatusBarAppearanceUpdate()
        }else{
            darkMode = false

            setNeedsStatusBarAppearanceUpdate()
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.popupDismissed()
            groupSocket.sharedInstance.refresh()
        }, completion: nil)
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .default : .lightContent
    }
    
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "changeuserimage" {
            self.initialSetup()
        }else if type == "blockstatus"{
            let blockType = dict.value(forKey: "type") as! String
            if blockType == "block"{
                self.blockedMe = "1"
            }else if blockType == "unblock"{
                self.blockedMe = "0"
            }
            self.configBlockStatus()
        }else if type == "makeprivate"{
            let user_id:String = dict.value(forKey: "user_id") as! String
            if viewType != "1" {
                let contact_id:String = self.profileDict.value(forKey: "user_id") as! String
            if user_id == contact_id{
                self.configPrivacySetting()
            }
            }
        }else if type == "refreshcount" {
            Utility.shared.setBadge(vc: self)
        }
    }
}

