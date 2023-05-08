//
//  HomePage.swift
//  Hiddy
//
//  Created by APPLE on 29/05/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import SQLite3
import TrueTime
import Contacts

protocol popOverDeletagte {
    
}
var contactPermissionApproved : Bool?

class HomePage: UIViewController,UITableViewDelegate,UITableViewDataSource,socketClassDelegate,picPopUpDelegate ,groupDelegate,channelDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,alertDelegate, storyDelegate{
    
    @IBOutlet var logoImgView: UIImageView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var recentTableView: UITableView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var noView: UIView!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet var favLbl: UILabel!
    @IBOutlet var favCollectionView: UICollectionView!
    @IBOutlet var favView: UIView!
    @IBOutlet var recentView: UIView!
    @IBOutlet var sideMenuIcon: UIImageView!
    
    var contactStore = CNContactStore()
    let localDB = LocalStorage()
    var recentArray = NSMutableArray()
    var favArray = NSMutableArray()
    var pickContact = false
    var storyArray = [RecentStoryModel]()
    var ownStoryArray = [statusModel]()
    var viewedStoryArray = [RecentStoryModel]()
    var userDetails: [UserDetails] = []
    let actionButton = JJFloatingActionButton()
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        self.noLbl.numberOfLines = 0
        
//        self.checkPermission()
        // Do any additional setup after loading the view.
        self.updateTheme()
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        /*
        //old
        if UserModel.shared.contactSync() != "1" {
            Contact.sharedInstance.synchronize()
            UserModel.shared.setContactSync(type: "1")
        }
        */
        UIApplication.shared.statusBarStyle = .lightContent
        self.configFloatingBtn()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        favCollectionView.collectionViewLayout = flowLayout
        //Utility.shared.checkDeletedList()
        
        Utility.shared.checkDeletedList({ [weak self] success in
            
        })
        
    }
    
    @objc func refreshContact() {
        DispatchQueue.main.async {
            self.refreshList()
            self.loadStory()
        }
    }
    @objc func enterForground() {
        DispatchQueue.main.async {
            if UserModel.shared.notificationPrivateID() == nil {
                Contact.sharedInstance.synchronize()
            }
        }
    }
    
    func contactPermissionAlert()  {
        AJAlertController.initialization().showAlert(aStrMessage: "contact_permission_again", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    func gotStoryInfo(dict: NSArray, type: String) {
        print(dict)
        let storage = storyStorage()
        let contacts = LocalStorage.sharedInstance.getContactList()
        if type == "receivestory" {
         /*   for story in dict {
                let story = story as! NSDictionary
                let senderID = story.value(forKey: "sender_id") as? String ?? ""
                let storyID = story.value(forKey: "story_id") as? String ?? ""
                let message = story.value(forKey: "message") as? String ?? ""
                let storyType = story.value(forKey: "story_type") as? String ?? ""
                let attachment = story.value(forKey: "attachment") as? String ?? ""
                let storyDate = story.value(forKey: "story_date") as? String ?? ""
                let storyTime = story.value(forKey: "story_time") as? String ?? ""
                let expiryTime = story.value(forKey: "expiry_time") as? String ?? ""
                let thumbnail = story.value(forKey: "thumbnail") as? String ?? ""
                let storyMembers = story.value(forKey: "story_members") as! NSArray
                var selectedID = [String]()
                for i in storyMembers {
                    selectedID.append(i as? String ?? "")
                }
                let strMembers = selectedID.joined(separator: ",")
                //                StorySocket().updateReceivedSocket(story_id: storyID)
                for contact in contacts {
                    let userID = (contact as AnyObject).value(forKey: "user_id") as? String ?? ""
                    if userID == senderID {
                        let contactlist = localDB.getContact(contact_id: userID)
                        let blockByMe = contactlist.value(forKey: "blockedByMe") as! String
                        let blockedMe = contactlist.value(forKey: "blockedMe") as! String
                        if blockedMe != "1" || blockByMe != "1"{
                            storage.addStory(story_id: storyID, sender_id: senderID, story_members: strMembers, message: message, story_type: storyType, attachment: attachment, story_date: storyDate, story_time: storyTime, expiry_time: expiryTime, thumbNail: thumbnail)
                        }
                    }
                }
                StorySocket().updateReceivedSocket(story_id: storyID)*/
            self.loadStory()

        }else  if type == "getbackstatus"{
           /* for story in dict {
                if story is NSDictionary {
                    let story = story as! NSDictionary
                    let senderID = story.value(forKey: "sender_id") as? String ?? ""
                    let storyID = story.value(forKey: "story_id") as? String ?? ""
                    let message = story.value(forKey: "message") as? String ?? ""
                    let storyType = story.value(forKey: "story_type") as? String ?? ""
                    let attachment = story.value(forKey: "attachment") as? String ?? ""
                    let storyDate = story.value(forKey: "story_date") as? String ?? ""
                    let storyTime = story.value(forKey: "story_time") as? String ?? ""
                    let expiryTime = story.value(forKey: "expiry_time") as? String ?? ""
                    let thumbnail = story.value(forKey: "thumbnail") as? String ?? ""
                    let storyMembers = story.value(forKey: "story_members") as! NSArray
                    var selectedID = [String]()
                    for i in storyMembers {
                        selectedID.append(i as? String ?? "")
                    }
                    let strMembers = selectedID.joined(separator: ",")
                    //                StorySocket().updateReceivedSocket(story_id: storyID)
                    for contact in contacts {
                        let userID = (contact as AnyObject).value(forKey: "user_id") as? String ?? ""
                        if userID == senderID {
                            let contactlist = localDB.getContact(contact_id: userID)
                            let blockByMe = contactlist.value(forKey: "blockedByMe") as! String
                            let blockedMe = contactlist.value(forKey: "blockedMe") as! String
                            if blockedMe != "1" || blockByMe != "1"{
                                storage.addStory(story_id: storyID, sender_id: senderID, story_members: strMembers, message: message, story_type: storyType, attachment: attachment, story_date: storyDate, story_time: storyTime, expiry_time: expiryTime, thumbNail: thumbnail)
                            }
                        }
                    }
                    StorySocket().updateReceivedSocket(story_id: storyID)
                    self.loadStory()
                    
                }
            }*/
        }
        else if type == "storyviewed" {
           /* for viewStory in dict {
                print(viewStory)
                if viewStory is NSDictionary {
                    let story = viewStory as! NSDictionary
                    let senderID = story.value(forKey: "sender_id") as? String ?? ""
                    let receiverID = story.value(forKey: "receiver_id") as? String ?? ""
                    let storyID = story.value(forKey: "story_id") as? String ?? ""
                    let time = NSDate().timeIntervalSince1970
                    storage.addViewList(sender_id: senderID, receiver_id: receiverID, story_id: storyID, timestamp: time.rounded().clean)
                }
                else {
                    if viewStory is NSArray {
                        let storyArray = viewStory as! NSArray
                        let story = storyArray[0] as! NSDictionary
                        let senderID = story.value(forKey: "sender_id") as? String ?? ""
                        let receiverID = story.value(forKey: "receiver_id") as? String ?? ""
                        let storyID = story.value(forKey: "story_id") as? String ?? ""
                        let time = NSDate().timeIntervalSince1970
                        storage.addViewList(sender_id: senderID, receiver_id: receiverID, story_id: storyID, timestamp: time.rounded().clean)
                    }
                }
            }*/
        }
        else if type == "stroydeleted" {
            /*for viewStory in dict {
                print(viewStory)
                if viewStory is NSDictionary {
                    let story = viewStory as! NSDictionary
                    let storyIDArr = story.value(forKey: "story_id") as? NSArray ?? [""]
                    for i in storyIDArr {
                        let storyID = i as? String ?? ""
                        let storyList = storage.checkIfExsit(story_id: storyID)
                        let attachment = storyList.first?.attachment ?? ""
                        storage.deleteStory(story_id: storyID, fileName: attachment)
                    }
                }else {
                    let story = jsonToString(value: viewStory as? String ?? "")
                    let storyIDArr = story?["story_id"] as? NSArray ?? [""]
                    for i in storyIDArr {
                        let storyID = i as? String ?? ""
                        let storyList = storage.checkIfExsit(story_id: storyID)
                        let attachment = storyList.first?.attachment ?? ""
                        storage.deleteStory(story_id: "\(storyID)", fileName: attachment)
                    }
                }
                self.loadStory()
            }*/
            self.loadStory()

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
        } catch let _ as NSError { // let error as NSError
            // print(error)
        }
        return nil
    }
    
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.logoImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            actionButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.favCollectionView.semanticContentAttribute = .forceLeftToRight
            self.favLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.favLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.searchIcon.transform = .identity
            self.logoImgView.transform = .identity
            actionButton.transform = .identity
            self.favCollectionView.transform = .identity
            self.favCollectionView.semanticContentAttribute = .unspecified
            self.favLbl.transform = .identity
            self.favLbl.textAlignment = .left
        }
        UserDefaults.standard.set(APP_RTC_URL, forKey: "web_rtc_web")
        
        recentTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0); //values
        
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_msg")
//        self.favLbl.config(color: TEXT_TERTIARY_COLOR, size: 21, align: .left, text: "status")
        self.favCollectionView.reloadData()
        //        DispatchQueue.main.async {
        //            self.favCollectionView.reloadSections(IndexSet(integer: 0))
        //            self.favCollectionView.reloadSections(IndexSet(integer: 1))
        //        }
        self.recentTableView.reloadData()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        favCollectionView.collectionViewLayout = flowLayout
        
        
    }
    
    //MARK: -  contacts
    
    func checkPermission()  {
        requestForAccess { (accessGranted) in
//            self.refreshLbl(approved: accessGranted)
            if accessGranted != true {
                DispatchQueue.main.async {
                    self.contactPermissionAlert()
                }
            }
        }
    }
    
//    func refreshLbl(approved:Bool) {
//        approved ? self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_msg") : self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "contact_permission_again")
//    }
    
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
                } else {
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
    
    override func viewWillAppear(_ animated: Bool) {
        if socket.status != .connected{
            socketClass.sharedInstance.connect()
        }
        
        DispatchQueue.main.async {
            if UserModel.shared.notificationPrivateID() == nil {
                Contact.sharedInstance.synchronize()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshContact), name: Notification.Name("ContactRefresh"), object: nil)

        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(enterForground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(enterForground), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        self.updateTheme()
        
//        self.favView.backgroundColor = BACKGROUND_COLOR
//        self.favCollectionView.backgroundColor = BACKGROUND_COLOR
        self.favView.backgroundColor = UIColor.init(named: "primary")!
        self.favCollectionView.backgroundColor = UIColor.init(named: "primary")!
        self.recentTableView.backgroundColor = BACKGROUND_COLOR
        self.recentTableView.backgroundColor = BACKGROUND_COLOR
        setNeedsStatusBarAppearanceUpdate()
        self.initialSetup()
        self.changeRTLView()
        LocalStorage.sharedInstance.updateDefaultTranslation()        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    override  func viewDidLayoutSubviews() {
        self.navigationView.applyGradient()
        self.favView.layer.cornerRadius = 25
        self.favView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.favCollectionView.layer.cornerRadius = 25
        self.favCollectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.navigationView.bringSubviewToFront(logoImgView)
        self.navigationView.bringSubviewToFront(searchIcon)
        self.navigationView.bringSubviewToFront(searchBtn)
        self.navigationView.bringSubviewToFront(sideMenuIcon)
        Utility.shared.setBadge(vc: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        //        self.loadviewData()
    }
    func loadviewData() {
        socketClass.sharedInstance.delegate = self
        groupSocket.sharedInstance.delegate =  self
        channelSocket.sharedInstance.delegate = self
        StorySocket.sharedInstance.delegate = self
        StorySocket.sharedInstance.addStoryHandler()
        Utility.shared.setBadge(vc: self)
        //        DispatchQueue.main.async {
        //        }
        pickContact = false
        self.checkNotificationRedirection()
        
        self.refreshList()
        self.loadStory()
    }
    func loadStory() {
        let storage = storyStorage()
        self.storyArray.removeAll()
        self.viewedStoryArray.removeAll()
        self.ownStoryArray.removeAll()
        
        self.storyArray = storage.getGroupRecentList(isViewed: "0")
        let storageList = storage.getGroupRecentList(isViewed: "1")
        for i in storageList {
            if !(self.storyArray.contains(where: {$0.sender_id == i.sender_id})) {
                self.viewedStoryArray.append(i)
            }
        }
        // print(self.viewedStoryArray)
        self.favCollectionView.reloadData()
    }
    
    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //set up initial details
    func initialSetup(){
        UserDefaults.standard.set(APP_RTC_URL, forKey: "web_rtc_web")
        recentTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0); //values
        //        DispatchQueue.main.async {
        self.getBlockedUserList()
        //        }
        Utility.shared.setBadge(vc: self)
        self.navigationController?.isNavigationBarHidden = true
        recentTableView.register(UINib(nibName: "RecentCell", bundle: nil), forCellReuseIdentifier: "RecentCell")
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_msg")
//        contactPermissionApproved ?? false ? self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_msg") : self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "contact_permission_again")
//        self.favLbl.config(color: TEXT_TERTIARY_COLOR, size: 21, align: .left, text: "status")
        self.favLbl.config(color: .white, size: 21, align: .left, text: "status")
//        favCollectionView.backgroundColor = BACKGROUND_COLOR
        self.favCollectionView.backgroundColor = UIColor.init(named: "primary")!
        favCollectionView.register(UINib(nibName: "selectedCell", bundle: nil), forCellWithReuseIdentifier: "selectedCell")
        self.loadviewData()
        
    }
    
    func refreshList()  {
        recentArray = localDB.getRecentList(isFavourite: "0")
        favArray = localDB.getRecentList(isFavourite: "1")
        recentTableView.reloadData()
        self.favView.isHidden = false
        let topPadding = self.favView.frame.size.height+self.favView.frame.origin.y
        self.recentView.frame = CGRect.init(x: 0, y:topPadding , width: FULL_WIDTH, height:FULL_HEIGHT-topPadding)
        self.recentTableView.frame = CGRect.init(x: 0, y:0 , width: FULL_WIDTH, height:self.recentView.frame.size.height-25)
        
        self.loadViewIfNeeded()
    }
    
    //check and notification redirection
    func checkNotificationRedirection(){
        if UserModel.shared.notificationPrivateID() != nil && !Utility.shared.checkEmptyWithString(value: UserModel.shared.notificationPrivateID()!) {
            let  contactInfo = DBConfig().getContact(contact_id: UserModel.shared.notificationPrivateID()!)
            if contactInfo == nil{
                let userObj = UserWebService()
                userObj.otherUserDetail(contact_id: UserModel.shared.notificationPrivateID()!, onSuccess: {response in
                    let status:String = response.value(forKey: "status") as! String
                    if status == STATUS_TRUE{
                        let localObj = LocalStorage()
                        let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                        let cc = response.value(forKey: "country_code") as! Int
                        
                        localObj.addContact(userid: UserModel.shared.notificationPrivateID()!,
                                            contactName: ("+\(cc) " + "\(phone_no)"),
                                            userName: response.value(forKey: "user_name") as! String,
                                            phone: "\(phone_no)",
                            img: response.value(forKey: "user_image") as! String,
                            about: response.value(forKey: "about") as? String,
                            type: EMPTY_STRING,
                            mutual:response.value(forKey: "contactstatus") as! String,
                            privacy_lastseen: response.value(forKey: "privacy_last_seen") as! String,
                            privacy_about: response.value(forKey: "privacy_about") as! String,
                            privacy_picture: response.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                        print("added locally")
                        let detailObj = ChatDetailPage()
                        detailObj.contact_id = UserModel.shared.notificationPrivateID()!
                        detailObj.viewType = "0"
                        self.navigationController?.pushViewController(detailObj, animated: true)
                        UserModel.shared.setNotificationPrivateID(id: EMPTY_STRING)
                        
                    }
                })
                
            }else{
                
                let detailObj = ChatDetailPage()
                detailObj.contact_id = UserModel.shared.notificationPrivateID()!
                detailObj.viewType = "0"
                self.navigationController?.pushViewController(detailObj, animated: true)
                UserModel.shared.setNotificationPrivateID(id: EMPTY_STRING)
            }
            
        }
    }
    
    //config floating chat new btn
    func configFloatingBtn()  {
        if UIDevice.current.hasNotch{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-155, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-125, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.buttonImage = #imageLiteral(resourceName: "chat_float_icon")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(goToContactListPage), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    
    //floating btn action
    @objc func goToContactListPage()  {
        if !pickContact{
            pickContact = true
            //        DispatchQueue.main.async {
            CFRunLoopWakeUp(CFRunLoopGetCurrent())
            let contactList = ContactListPage()
            //            let contactList = typStatusViewController()
            self.navigationController?.pushViewController(contactList, animated: false)
        }
        //        }
    }
    
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        self.noView.isHidden = false
        self.recentView.isHidden = true
        if section == 0 {
            return favArray.count
        }
        else {
            return recentArray.count
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.noView.isHidden = true
        self.recentView.isHidden = false
        let recentCell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath) as! RecentCell
        recentCell.profileBtn.setTitle("\(indexPath.section)", for: .normal)
        if indexPath.section == 0 {
            let recentDict:NSDictionary =  self.favArray.object(at: indexPath.row) as! NSDictionary
            recentCell.config(recentDict: recentDict)
            recentCell.profileBtn.tag = indexPath.row
            recentCell.profileBtn.addTarget(self, action: #selector(goToProfilePopup), for: .touchUpInside)
        }
        else {
            let recentDict:NSDictionary =  self.recentArray.object(at: indexPath.row) as! NSDictionary
            recentCell.config(recentDict: recentDict)
            recentCell.profileBtn.tag = indexPath.row
            recentCell.profileBtn.addTarget(self, action: #selector(goToProfilePopup), for: .touchUpInside)
        }
        return recentCell
    }
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 90
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var recentDict = NSDictionary()
        if indexPath.section == 0 {
            recentDict =  self.favArray.object(at: indexPath.row) as! NSDictionary
        }
        else {
            recentDict =  self.recentArray.object(at: indexPath.row) as! NSDictionary
        }
        print("recent \(recentDict)")
        let detailObj = ChatDetailPage()
        detailObj.contact_id = recentDict.value(forKey: "user_id") as! String
        detailObj.viewType = "0"
        self.navigationController?.pushViewController(detailObj, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            headerView.backgroundColor = BACKGROUND_COLOR
            let headerLabel = UILabel(frame: CGRect(x: 20, y: 12, width:
                tableView.bounds.size.width, height: 20))
            headerLabel.font = UIFont(name: APP_FONT_REGULAR, size: 22)
            headerLabel.textColor = TEXT_TERTIARY_COLOR
            headerLabel.text = Utility.shared.getLanguage()?.value(forKey: "recent") as? String
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
            if UserModel.shared.getAppLanguage() == "عربى" {
                headerLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
                headerLabel.textAlignment = .right
            } else {
                headerLabel.transform = .identity
                headerLabel.textAlignment = .left
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 35
        }
        return 0
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var recentDict = NSDictionary()
        
        if indexPath.section == 0 {
            recentDict =  self.favArray.object(at: indexPath.row) as! NSDictionary
        }
        else {
            recentDict =  self.recentArray.object(at: indexPath.row) as! NSDictionary
        }
        let contact_id:String = recentDict.value(forKey: "user_id") as! String
        let fav:String = recentDict.value(forKey: "favourite") as! String
        
        //favourite
        let favAction = UITableViewRowAction(style: .normal, title: "") { (rowAction, indexPath) in
            if fav == "0"{
                self.localDB.updateFavourite(cotact_id: contact_id, status: "1")
            }else{
                self.localDB.updateFavourite(cotact_id: contact_id, status: "0")
            }
            self.refreshList()
        }
        
        if fav == "0"{
            favAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "fav", btnImg: #imageLiteral(resourceName: "swipe_fav")))
        }else{
            favAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "fav", btnImg: #imageLiteral(resourceName: "swipe_unfav")))
        }
        
        //mute
        
        let mute:String = recentDict.value(forKey: "mute") as! String
        let muteAction = UITableViewRowAction(style: .normal, title: "") { (rowAction, indexPath) in
            if mute == "0"{
                self.localDB.updateMute(cotact_id: contact_id, status: "1")
                socketClass.sharedInstance.muteStatus(chat_id: contact_id, type:"single" , status: "mute")
            }else{
                socketClass.sharedInstance.muteStatus(chat_id: contact_id, type:"single" , status: "unmute")
                self.localDB.updateMute(cotact_id: contact_id, status: "0")
            }
            self.refreshList()
        }
        var image = #imageLiteral(resourceName: "swipe_unmute")
        
        if mute != "0"{
            image = #imageLiteral(resourceName: "swipe_mute")
        }
        
        var rotatedImage = image
        if UserModel.shared.getAppLanguage() == "عربى" {
            rotatedImage = image.rotate(radians: .pi)
        }
        
        muteAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "mute", btnImg: rotatedImage))
        //delete
        let deleteAction = UITableViewRowAction(style: .normal, title: "") { (rowAction, indexPath) in
            let alert = CustomAlert()
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.delegate = self
            alert.viewType = contact_id
            alert.msg = "delete_chat"
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "delete", btnImg: #imageLiteral(resourceName: "swipe_delete")))
        
        return [deleteAction,muteAction,favAction]
    }
    
    func swipeBackGroundView(indexPath:IndexPath,type:String,btnImg:UIImage)->UIImage {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 90))
        let myImage = UIImageView(frame: CGRect(x: 23, y: 30, width: 24, height: 24))
        myImage.contentMode = .scaleAspectFill
        if type == "fav"{
            backView.backgroundColor = UIColor.init(named: "swipe1")
        }else if type == "mute"{
            backView.backgroundColor = UIColor.init(named: "swipe2")
        }else{
            backView.backgroundColor = UIColor.init(named: "swipe3")
        }
        myImage.image = btnImg
        backView.addSubview(myImage)
        let imgSize: CGSize = recentTableView.frame.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        backView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func alertActionDone(type: String) {
        self.localDB.deleteChat(chat_id:"\(UserModel.shared.userID()!)\(type)")
        self.localDB.deleteRecent(chat_id:"\(UserModel.shared.userID()!)\(type)")
        self.refreshList()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    //MARK: Collection view delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return 1
        if section == 0 {
            let storage = storyStorage()
            let storyVal = storage.getUserInfo(userID: UserModel.shared.userID() as String? ?? "")
            if storyVal.count > 0 {
                return 2
            }
            return 1
        }
        else if section == 1 {
            return self.storyArray.count
        }
        else if section  == 2 {
            return self.viewedStoryArray.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /*
        let cell : selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedCell", for: indexPath) as! selectedCell
        cell.usernameLbl.isHidden = true
        if indexPath.section == 0 {
            cell.backgroundImgView.layer.borderWidth = 0
            if indexPath.row == 0 {
                cell.addStiryImgView.isHidden = false
                cell.addStiryImgView.image = #imageLiteral(resourceName: "add_story")
                cell.usernameLbl.text = Utility.shared.getLanguage()?.value(forKey: "add_story") as? String
                cell.shadowView.layer.cornerRadius = 0
                cell.shadowView.layer.borderWidth = 0
                cell.shadowView.backgroundColor = .clear
                DispatchQueue.main.async {
                    if (UserModel.shared.getProfilePic() != nil) {
                        cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(UserModel.shared.getProfilePic()! as String)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                    }
                }
            } else {
                cell.shadowView.layer.cornerRadius = 0
                cell.shadowView.layer.borderWidth = 0
                cell.shadowView.backgroundColor = .clear
                cell.addStiryImgView.isHidden = true
                cell.usernameLbl.text = Utility.shared.getLanguage()?.value(forKey: "your_story") as? String
                DispatchQueue.main.async{
                    if (UserModel.shared.getProfilePic() != nil) {
                        cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(UserModel.shared.getProfilePic()! as String)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                    }
                }
            }
            if UserModel.shared.getAppLanguage() == "عربى" {
                cell.userImg.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else {
                cell.userImg.transform = .identity
            }
        }
         
         
         */
        
        
        
            let cell : selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedCell", for: indexPath) as! selectedCell
            cell.usernameLbl.isHidden = true
            if indexPath.section == 0 {
                cell.backgroundImgView.layer.borderWidth = 0
                if indexPath.row == 0 {
                    cell.addStiryImgView.isHidden = true
                    cell.addStiryImgView.image = #imageLiteral(resourceName: "add_story")
                    cell.usernameLbl.text = Utility.shared.getLanguage()?.value(forKey: "add_story") as? String
                    cell.shadowView.layer.cornerRadius = 0
                    cell.shadowView.layer.borderWidth = 0
                    cell.shadowView.backgroundColor = .clear
                    DispatchQueue.main.async {
                        if (UserModel.shared.getProfilePic() != nil) {
//                            cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(UserModel.shared.getProfilePic()! as String)"), placeholderImage: #imageLiteral(resourceName: "add_story"))
                            cell.userImg.setImage(UIImage(named: "add_story")!)
                        }
                        cell.usernameLbl.isHidden = true
                    }
                } else {
                    cell.shadowView.layer.cornerRadius = 0
                    cell.shadowView.layer.borderWidth = 0
                    cell.shadowView.backgroundColor = .clear
                    cell.addStiryImgView.isHidden = true
                    cell.usernameLbl.text = Utility.shared.getLanguage()?.value(forKey: "your_story") as? String
                    DispatchQueue.main.async{
                        if (UserModel.shared.getProfilePic() != nil) {
                            cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(UserModel.shared.getProfilePic()! as String)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                        }
                    }
                    cell.usernameLbl.isHidden = true
                }
                if UserModel.shared.getAppLanguage() == "عربى" {
                    cell.userImg.transform = CGAffineTransform(scaleX: -1, y: 1)
                } else {
                    cell.userImg.transform = .identity
                }
            }
         
         
         else if indexPath.section == 1 {
            if self.storyArray.count > indexPath.row - 1 {
                cell.configStory(contactDict: self.storyArray[indexPath.row], type: "fav")
            }
            cell.shadowView.cornerViewRadius()
            cell.addStiryImgView.isHidden = true
            cell.shadowView.layer.borderWidth = 2
            cell.shadowView.layer.borderColor = SECONDARY_COLOR.cgColor
        } else {
            if self.viewedStoryArray.count > indexPath.row - 1 {
                cell.configStory(contactDict: self.viewedStoryArray[indexPath.row], type: "fav")
            }
            cell.shadowView.cornerViewRadius()
            cell.addStiryImgView.isHidden = true
            cell.shadowView.layer.borderWidth = 2
            cell.shadowView.layer.borderColor = UIColor.lightGray.cgColor
            
        }
        if UserModel.shared.getAppLanguage() == "عربى" {
            cell.usernameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.userImg.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            cell.usernameLbl.transform = .identity
            cell.userImg.transform = .identity
        }
        cell.addStiryImgView.isUserInteractionEnabled = true
        cell.addStiryImgView.tag = indexPath.row
        cell.addStiryImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addStoryAct(_:))))
        //        let userDict:NSDictionary =  favArray.object(at: indexPath.row) as! NSDictionary
        //        cell.config(contactDict: userDict,type:"fav")
        return cell
    }
    @objc func addStoryAct(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        if tag == 0{
            let contactList = CameraVideoController()
            self.navigationController?.pushViewController(contactList, animated: false)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let recentDict:NSDictionary =  self.favArray.object(at: indexPath.row) as! NSDictionary
        //        let detailObj = ChatDetailPage()
        //        detailObj.contact_id = recentDict.value(forKey: "user_id") as! String
        //        detailObj.viewType = "0"
        //        self.navigationController?.pushViewController(detailObj, animated: true)
        DispatchQueue.main.async {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let contactList = CameraVideoController()
                    self.navigationController?.pushViewController(contactList, animated: false)
                }
                else {
                    let vc = ContentViewController()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.infoUpdated = { dict,type in
                    }

                    //                    let name = "You"
                    let userStatus = RecentStoryModel(sender_id: UserModel.shared.userID() as String? ?? "", story_id: "", message: "", story_type: "", attachment: "", story_date: "", story_time: "", expiry_time: "", contactName: "", userName: "", phoneNumber: "", userImage: "", aboutUs: "", blockedMe: "", blockedByMe: "", mute: "", mutual_status: "", privacy_lastseen: "", privacy_about: "", privacy_image: "", favourite: "")
                    print("userStatus: \(userStatus)")
                    vc.pages = [userStatus]
                    vc.currentIndex = 0
                    vc.segIndex = 0
                    self.navigationController?.pushViewController(vc, animated: true)
                    //                self.present(vc, animated: true, completion: nil)
                }
            }
            else if indexPath.section == 1 || indexPath.section == 2 {
                let vc = ContentViewController()
                vc.modalPresentationStyle = .overFullScreen
                vc.pages = self.storyArray + self.viewedStoryArray
                vc.infoUpdated = { dict,type in
                }

                if indexPath.section == 1 {
                    vc.currentIndex = indexPath.row
                } else {
                    vc.currentIndex = self.storyArray.count + indexPath.row
                }
                vc.segIndex = 0
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //profile popup
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        // self.view.blurEffect()
        var profileDict = NSDictionary()
        if sender.titleLabel?.text == "0" {
            profileDict =  self.favArray.object(at: sender.tag) as! NSDictionary
        }
        else {
            profileDict =  self.recentArray.object(at: sender.tag) as! NSDictionary
        }
        //        profileDict = self.recentArray.object(at: sender.tag) as! NSDictionary
        let popup = ProfilePopup()
        popup.profileDict = profileDict
        popup.delegate = self
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
    func popupDismissed() {
        socketClass.sharedInstance.delegate =  self
    }
    
    //get blocked user list
    func getBlockedUserList(){
        let userObj = UserWebService()
        let localDB = LocalStorage()
//        localDB.markAllUnblocked()
        userObj.blockedList(onSuccess: {response in
            let status:NSString = response.value(forKey: "status") as! NSString
            if status.isEqual(to: STATUS_TRUE){
                let blockedMeArray:NSArray = response.value(forKey: "blockedme") as! NSArray
                for contact in blockedMeArray {
                    let contactTempArray = NSMutableArray.init(array: [contact])
                    var contactTempDict = NSDictionary()
                    contactTempDict = contactTempArray.object(at: 0) as! NSDictionary
                    localDB.updateBlockedStatus(contact_id:contactTempDict.value(forKey: "user_id") as! String, type: "blockedMe", value: "1")
                }
                let blockedByMeArray:NSArray = response.value(forKey: "blockedbyme") as! NSArray
                for contact in blockedByMeArray {
                    let contactTempArray = NSMutableArray.init(array: [contact])
                    var contactTempDict = NSDictionary()
                    contactTempDict = contactTempArray.object(at: 0) as! NSDictionary
                    localDB.updateBlockedStatus(contact_id:contactTempDict.value(forKey: "buser_id") as! String, type: "blockedByMe", value: "1")
                }
                self.refreshList()
            }
        })
    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
//        Utility.shared.getTime()

        let searchObj =  SearchAll()
        self.navigationController?.pushViewController(searchObj, animated: true)
    }
    
    @IBAction func sideMenuBtnTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    //MARK: ********* SOCKET RESPONSE ********
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "receivechat" {
            
            Contact.sharedInstance.synchronize()
                self.refreshList()
                Utility.shared.setBadge(vc: self)
            
            Utility.shared.checkDeletedList1( onSuccess: { (success) in
                print("sucessof:\(success)")
                if !success {
                    print("cjhvakxbkabclasbcvjasvcjvzvcdsvckjsdvcjvdsjcvds")
                    self.refreshList()
                    Utility.shared.setBadge(vc: self)
                }
            })
/*
            //old
            self.refreshList()
            Utility.shared.setBadge(vc: self)
 */
            
        }else if type == "changeuserimage" || type == "readstatus" || type == "blockstatus" || type == "videoUploadStatus" || type == "makeprivate"{
            self.refreshList()
        }else if type == "listentyping"{
            let type:String = dict.value(forKey: "type") as! String
            let sender_id:String = dict.value(forKey: "sender_id") as! String
            if type == "untyping"{
                self.localDB.updateTyping(contact_id: sender_id, status: "0")
            }else if type == "typing"{
                self.localDB.updateTyping(contact_id: sender_id, status: "1")
            }
            else if type == "recording"{
                self.localDB.updateTyping(contact_id: sender_id, status: "2")
            }
            self.refreshList()
        }else if type == "offlineRefresh" || type == "recentMsg" {
            Utility.shared.setBadge(vc: self)
            self.refreshList()
        }else if type == "refreshcount" {
            Utility.shared.setBadge(vc: self)
        }
        
    }
    func gotChannelInfo(dict: NSDictionary, type: String) {
        if type == "messagefromadminchannels"{
            Utility.shared.setBadge(vc: self)
        }
        else if type == "blockchannel" {
            
        }
    }
    
    func gotGroupInfo(dict: NSDictionary, type: String) {
        print("AjmalAJ_1")
        
        if type == "messagefromgroup" || type == "refreshGroup"{
            Utility.shared.setBadge(vc: self)
        }
    }
}
