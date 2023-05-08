//
//  ProfilePage.swift
//  Hiddy
//
//  Created by APPLE on 11/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class ProfilePage: ProfileHeaderPage,socketClassDelegate {
    var viewType = String()
    var profileDict = NSDictionary()
    var contact_id = String()
    var exitType = String()
    var blockedMe = String()
    var contactName = String()
    var chatID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        adjustContentViewHeight()
        self.initialSetup(type: self.viewType,id: self.contact_id,exit:self.exitType)
        if viewType == "own"{
            self.setDesign(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height)
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            self.topScroll.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        self.updateTheme()
        self.topContainerView.backgroundColor = BACKGROUND_COLOR
        self.contentView.backgroundColor = BACKGROUND_COLOR
//        socketClass.sharedInstance.delegate = self
        self.aboutTxtView.textColor = TEXT_TERTIARY_COLOR
        self.aboutTxtView.font = UIFont.init(name: APP_FONT_REGULAR, size: 25)
        self.aboutTxtView.textAlignment = .left
        aboutTxtView.numberOfLines = 0
        if viewType == "own"{
            self.setOwnProfile()
        }else{
            self.configOtherProfile()
        }
        self.aboutTxtView.sizeToFit()
        aboutTxtView.frame.size.width = FULL_WIDTH-40
        
        self.changeRTLView()
    }
    
    override func viewDidLayoutSubviews() {
        aboutTxtView.frame.size.width = FULL_WIDTH-40
        
        self.aboutTxtView.sizeToFit()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setOwnProfile()  {
        self.otherProfileView.isHidden = true
        
        if (UserModel.shared.getProfilePic() != nil) {
            self.profileImgView.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(UserModel.shared.getProfilePic()! as String)"), placeholderImage: #imageLiteral(resourceName: "profile_popup_bg"))
        }
        let about:String = UserModel.shared.userDict().value(forKey: "about") as? String ?? ""
        
        if  about == EMPTY_STRING {
            self.aboutTxtView.text = Utility.shared.getLanguage()?.value(forKey: "about") as? String ?? ""
        }else{
            self.aboutTxtView.text = UserModel.shared.userDict().value(forKey: "about") as? String ?? ""
        }
        self.aboutTxtView.sizeToFit()
        
        self.nameLbl.text = UserModel.shared.userDict().value(forKey: "user_name") as? String
        self.titleLbl.text = contactName
        self.muteView.isHidden = true
        self.scrollViewDidScroll(bottomScroll)
        //
    }
    //set up other profile
    func configOtherProfile() {
        self.otherProfileView.isHidden = false
        let localObj = LocalStorage()
        self.profileDict = localObj.getContact(contact_id: self.contact_id)
        self.setOtherProfileDetails()
        DispatchQueue.global(qos: .background).async {
            self.fetchCurrentDetails()
        }
    }
    
    //set values to other profiles
    func setOtherProfileDetails(){
        blockedMe = self.profileDict.value(forKey: "blockedMe") as! String
        self.configBlockStatus()
        let about:String = self.profileDict.value(forKey: "user_about") as? String ?? ""
        if  about == EMPTY_STRING {
            //config about text view
            self.aboutTxtView.text = Utility.shared.getLanguage()?.value(forKey: "about") as? String ?? ""
        }else{
            self.aboutTxtView.text = about
        }
        self.nameLbl.text = self.profileDict.value(forKey: "contact_name") as? String
        self.titleLbl.text = self.profileDict.value(forKey: "contact_name") as? String
        let cc = (profileDict.value(forKey: "countrycode") as? String ?? "")
        let mobileNo = (profileDict.value(forKey: "user_phoneno") as? String ?? "")
        self.phoneNoLbl.text = "+" + cc + " " + mobileNo
        self.muteNotficationLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "mute_notification")
        if self.chatID != "" {
            self.chat_ID = self.chatID
            mediaDict = localObj.getPerticularMediaChat(chat_id: self.chatID, message_type: "'image','video','document'") // ,'audio'
            // self.mediaCountLabel.text = "\(self.mediaDict.count)"
            print("media chat \(mediaDict)")
            mediaCollectionView.reloadData()
        }
        self.setDesign(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height)
    }
    
    //check block
    func configBlockStatus()  {
        if blockedMe == "1" {
            self.profileImgView.image = #imageLiteral(resourceName: "profile_popup_bg")
            self.aboutTxtView.isHidden = true
        }else{
            self.configPrivacySettings()
        }
    }
    
    //account setting validation
    func configPrivacySettings() {
        let localObj = LocalStorage()
        self.profileDict = localObj.getContact(contact_id: self.contact_id)
        let privacy_image:String = profileDict.value(forKey: "privacy_image") as! String
        let mutual:String = profileDict.value(forKey: "mutual_status") as! String
        let privacy_about:String = profileDict.value(forKey: "privacy_about") as! String
        let imageName:String = profileDict.value(forKey: "user_image") as! String
        // profile pic
        if privacy_image == "nobody"{
            self.profileImgView.image = #imageLiteral(resourceName: "profile_popup_bg")
        }else if privacy_image == "everyone"{
            self.profileImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_popup_bg"))
        }else if privacy_image == "mycontacts"{
            if mutual == "true"{
                self.profileImgView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_popup_bg"))
            }else{
                self.profileImgView.image = #imageLiteral(resourceName: "profile_popup_bg")
            }
        }
        //last seen
        if privacy_about == "nobody"{
            self.aboutTxtView.isHidden = true
        }else if privacy_about == "everyone"{
            self.aboutTxtView.isHidden = false
        }else if privacy_about == "mycontacts"{
            if mutual == "true"{
                self.aboutTxtView.isHidden = false
            }else{
                self.aboutTxtView.isHidden = true
            }
        }
    }
    
    func fetchCurrentDetails()  {
        let localObj = LocalStorage()
        let userObj = UserWebService()
        userObj.otherUserDetail(contact_id: contact_id, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                let cc = response.value(forKey: "country_code") as! Int
                localObj.addContact(userid: self.contact_id,
                                    contactName: self.contactName,
                                    userName: response.value(forKey: "user_name") as! String,
                                    phone: "\(phone_no)",
                                    img: response.value(forKey: "user_image") as! String,
                                    about: response.value(forKey: "about") as? String ?? "",
                                    type: EMPTY_STRING,
                                    mutual:response.value(forKey: "contactstatus") as! String,
                                    privacy_lastseen: response.value(forKey: "privacy_last_seen") as! String,
                                    privacy_about: response.value(forKey: "privacy_about") as! String,
                                    privacy_picture: response.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                self.profileDict = localObj.getContact(contact_id: self.contact_id)
                self.aboutTxtView.text = response.value(forKey: "about") as? String ?? ""
            }
        })
    }
    
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "changeuserimage" {
            if viewType != "own"{
                self.configOtherProfile()
            }
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
            if user_id == self.contact_id{
                self.configBlockStatus()
                self.initialSetup(type: "other", id: self.contact_id, exit: self.exitType)
            }
        }
    }
}
