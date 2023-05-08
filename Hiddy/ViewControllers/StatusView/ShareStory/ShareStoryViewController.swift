//
//  createGroup.swift
//  Hiddy
//
//  Created by APPLE on 12/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//


import UIKit
import Contacts
import JJFloatingActionButton
import Alamofire
protocol addmemberViewdelegate {
    func dismissMemberView()
}
class ShareStoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var contactTableView: UITableView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var barBtnView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var bottomView: UIView!
    @IBOutlet weak var noView: UIView!
    
    let contactStore = CNContactStore()
    let phoneNoArray = NSMutableArray()
    var myContacts = NSMutableArray()
    var contactCopy = NSMutableArray()
    var isSearch = Bool()
    var selectedId = NSMutableArray()
    var selectedContacts = NSMutableArray()
    var viewType = String()
    var previousID = NSMutableArray()
    var group_id = String()
    var delegate:addmemberViewdelegate?
    var requestDict = NSMutableDictionary()
    var selectionTag = 0
    var image = UIImage()
    var videoURL: URL?
    var storyType = ""
    let dummyMediaDict = NSMutableDictionary()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loaderView.color = RECIVER_BG_COLOR
        self.hideView.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        setNeedsStatusBarAppearanceUpdate()
        contactTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0); //values
        self.initalSetup()
        self.changeRTLView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
//            // self.noLbl.textAlignment = .right
            self.searchTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.textAlignment = .right
            self.countLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.countLbl.textAlignment = .right
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.noLbl.transform = .identity
//            // self.noLbl.textAlignment = .left
            self.searchTF.transform = .identity
            self.searchTF.textAlignment = .left
            self.countLbl.transform = .identity
            self.countLbl.textAlignment = .left
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //initial setup
    func initalSetup()  {
        isSearch = false
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "Share_friends")
        self.countLbl.config(color: TEXT_TERTIARY_COLOR, size: 15, align: .left, text: EMPTY_STRING)
        self.hideView.isHidden = false
        self.loaderView.startAnimating()
        self.contactTableView.isHidden = true
        self.noView.isHidden = true
        DispatchQueue.main.async {
            let localObj = LocalStorage()
            self.myContacts = localObj.getContactList()
            self.contactCopy = localObj.getContactList()
            self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
            self.checkAvailablity()
        }
        
        self.searchTF.isHidden = true
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .center, text: "no_contact")
        
        
        contactTableView.register(UINib(nibName: "createGroupCell", bundle: nil), forCellReuseIdentifier: "createGroupCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        self.countLbl.text = "0 \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
        self.configFloatingBtn()
        
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //config floating chat new btn
    func configFloatingBtn()  {
        let actionButton = JJFloatingActionButton()
        if UIDevice.current.hasNotch{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-120, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-90, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.contentMode = .scaleAspectFit
        actionButton.buttonImage = #imageLiteral(resourceName: "next_arrow")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(groupCreationTapped), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    @objc func FileUpload(){
        //        self.startLoading(string: "")
        dummyMediaDict.setValue("user", forKey: "type")
        if self.storyType == "image" {
            dummyMediaDict.setValue(image, forKey: "image")
            dummyMediaDict.setValue(".jpg",forKey: "mime_type")
            image = image.fixedOrientation()!
            let imagedata = image.jpegData(compressionQuality: 0.5)!
            dummyMediaDict.setValue(imagedata, forKey: "media_data")
        }
        else {
            dummyMediaDict.setValue("user", forKey: "type")
            dummyMediaDict.setValue(videoURL, forKey: "videos")
            self.image = Utility.shared.thumbnailForVideoAtURL(url: videoURL!) ?? #imageLiteral(resourceName: "tab_unselect_user")
            dummyMediaDict.setValue(".mp4",forKey: "mime_type")
            var movieData:Data?
            do{
                movieData = try Data.init(contentsOf: videoURL!)
            }catch{
                
            }
            dummyMediaDict.setValue(movieData, forKey: "media_data")
        }
        let data = dummyMediaDict.value(forKey: "media_data") as! NSData
        let mimeStr = dummyMediaDict .value(forKey: "mime_type") as! String
        
        self.uploadFiles(fileData: data as Data, type: mimeStr, upload_type: self.storyType, user_id: UserModel.shared.userID() as String? ?? "", onSuccess:
            {
                response in
                //                self.stopLoading()
                self.createThumbNailImage(dummyMediaDict: self.dummyMediaDict, responseStr: response)
//                self.createStory(response: response, thumbResponse: response)

//                self.createStory(response: response)
                // print(response)
        })
    }
    func saveToDocument(response: String) {
        // get the documents directory url
        var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let data = dummyMediaDict.value(forKey: "media_data") as! NSData

        let fileName = response
        // create the destination file url to save your image
        documentsDirectory.appendPathComponent(DOCUMENT_PATH)
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved: \(fileURL)")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    func createThumbNailImage(dummyMediaDict: NSDictionary, responseStr: NSDictionary) {
        let imageData = image.jpegData(compressionQuality: 0.5)!
        self.uploadFiles(fileData: imageData as Data, type: ".jpg", upload_type: "image", user_id: UserModel.shared.userID() as String? ?? "", onSuccess:
            {
                response in
                self.createStory(response: responseStr, thumbResponse: response)
        })
    }
    func createStory(response: NSDictionary, thumbResponse: NSDictionary) {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        msgDict.setValue(requestDict.value(forKey: "message") as? String ?? "", forKey: "message")
        msgDict.setValue(msg_id, forKey: "story_id")
        msgDict.setValue(requestDict.value(forKey: "story_type") as? String ?? "", forKey: "story_type")
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        msgDict.setValue(formatter.string(from: date), forKey: "story_date")
//        let cryptLib = CryptLib()
        let encryptedMsg = response.value(forKey: "user_image") as? String ?? ""//cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String ?? "", key: ENCRYPT_KEY)
        msgDict.setValue(encryptedMsg, forKey: "attachment")
        msgDict.setValue(thumbResponse.value(forKey: "user_image") as? String ?? "" , forKey: "thumbnail")
//        msgDict.setValue("", forKey: "thumbnail")

        self.saveToDocument(response: encryptedMsg)
        msgDict.setValue(Utility.shared.getTime(), forKey: "story_time")
        var today = Date()
        
        if client.referenceTime?.now() != nil{
            today = (client.referenceTime?.now())!
        }else{
            today = Date()
        }
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: today)        
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        utcFormatter.timeZone = TimeZone(abbreviation: "UTC")
        msgDict.setValue(utcFormatter.string(from: nextDate!), forKey: "expiry_time")
        msgDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        
        msgDict.setValue(getMemberId(), forKey: "story_members")
        
        StorySocket.sharedInstance.postStory(user_id: UserModel.shared.userID()! as String, story_id: msgDict.value(forKey: "story_id") as!String, stories: msgDict)
        let storage = storyStorage()
        let StrMembers = self.selectedId.componentsJoined(by: ",")
        storage.addStory(story_id: msgDict.value(forKey: "story_id") as!String, sender_id: UserModel.shared.userID()! as String, story_members: StrMembers, message: msgDict.value(forKey: "message") as! String, story_type: msgDict.value(forKey: "story_type") as! String, attachment: msgDict.value(forKey: "attachment") as! String, story_date: msgDict.value(forKey: "story_date") as! String, story_time: msgDict.value(forKey: "story_time") as! String, expiry_time: msgDict.value(forKey: "expiry_time") as! String, thumbNail: msgDict.value(forKey: "thumbnail") as? String ?? "")
        
//        let del = UIApplication.shared.delegate as! AppDelegate
        self.hideView.isHidden = true
        self.loaderView.stopAnimating()
        let menuObj = menuContainerPage()
        menuObj.viewType = "share"
        self.navigationController?.pushViewController(menuObj, animated: true)
//        self.tabBarController?.selectedIndex = 0
//        del.setInitialViewController(initialView: menuContainerPage())

    }
    public func uploadFiles(fileData:Data,type:String,upload_type:String,user_id:String, onSuccess success: @escaping (NSDictionary) -> Void)
    {
        let uploadObj = UploadServices()
        uploadObj.uploadFiles(fileData: fileData, type: type, user_id: UserModel.shared.userID()! as String, docuName: upload_type, msg_id: "", api_type: "private") { (response) in
            // print(response)
            success(response)
        }
    }

    //floating btn action
    @objc func groupCreationTapped()  {
        self.view.bringSubviewToFront(self.hideView)
        if Utility.shared.isConnectedToNetwork() {
            if selectedId.count == 0{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "select_one") as? String)
            }else{
                self.hideView.isHidden = false
                self.loaderView.startAnimating()
                self.FileUpload()
                
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    func getMemberId()->NSMutableArray{
        let mutableArray = NSMutableArray()
        for id in self.selectedId {
            let dict = NSMutableDictionary()
            dict.setValue(id, forKey: "member_id")
            dict.setValue("0", forKey: "member_role")
            let memberDict = ["member_id":id]
            mutableArray.add(memberDict)
        }
        return mutableArray
    }

    //members added notification
    func notifyAddMembersToGroup(memberArray:NSMutableArray)  {
        let groupDB = groupStorage()
        let memberDict = groupDB.getMemberInfo(member_key: "\(group_id)\(UserModel.shared.userID()!)")
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "group_admin_id")
        msgDict.setValue("Participants Added", forKey: "message")
        msgDict.setValue(Utility.shared.convertJson(from: memberArray), forKey: "attachment")
        msgDict.setValue(memberArray, forKey: "new_members")

        msgDict.setValue("add_member", forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        
    }
    
    //back btn tapped
    @IBAction func backBtnTapped(_ sender: Any) {
        if isSearch {
            self.barBtnView.isHidden = false
            self.titleLbl.isHidden = false
            self.countLbl.isHidden = false
            self.searchTF.isHidden = true
            self.isSearch =  false
            self.searchTF.resignFirstResponder()
            self.reloadAllData()

        }else{
//            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //search for contact
    @IBAction func searchBtnTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
            self.searchTF.isHidden = false
            self.barBtnView.isHidden = true
            self.titleLbl.isHidden = true
            self.countLbl.isHidden = true
            self.isSearch =  true
            self.searchTF.becomeFirstResponder()
        }, completion: nil)
    }
    
    //check contact access permission
    
    
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
                        // DispatchQueue.main.async{
                        self.contactPermissionAlert()
                        //}
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
    
    //add contat to local db
    func addToDB(contact:NSMutableArray)  {
        let localObj = LocalStorage()
        for contactDict in contact {
            let userDict:NSDictionary = contactDict as! NSDictionary
            let phoneNo:NSNumber = userDict.value(forKey: "phone_no") as! NSNumber
            DispatchQueue.global(qos: .background).async {
                var name = String()
                let contactName = Utility.shared.searchPhoneNoAvailability(phoneNo: "\(phoneNo)")
                let cc = userDict.value(forKey: "country_code") as! Int

                if contactName == EMPTY_STRING{
                    name = "+\(cc) " + "\(phoneNo)"
                }else{
                    name = contactName
                }
                //  DispatchQueue.main.async {
                let type = String()
                localObj.addContact(userid: userDict.value(forKey: "_id") as! String,
                                    contactName: name,
                                    userName: userDict.value(forKey: "user_name") as! String,
                                    phone:String(describing: phoneNo) ,
                                    img: userDict.value(forKey: "user_image") as! String,
                                    about: userDict.value(forKey: "about") as? String ?? "",
                                    type:type,
                                    mutual:userDict.value(forKey: "contactstatus") as! String,
                                    privacy_lastseen: userDict.value(forKey: "privacy_last_seen") as! String,
                                    privacy_about: userDict.value(forKey: "privacy_about") as! String,
                                    privacy_picture: userDict.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                // }
            }
        }
        if viewType == "1" {
            let array = localObj.getContactList()
            for member in array{
                let memberDict:NSDictionary = member as! NSDictionary
                let user_id:String = memberDict.value(forKey: "user_id") as! String
                if !self.previousID.contains(user_id){
                    self.myContacts.add(memberDict)
                }
            }
            self.checkAvailablity()
        }else{
            self.myContacts = localObj.getContactList()
            self.checkAvailablity()
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.myContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupCell", for: indexPath) as! createGroupCell
        if self.myContacts.count != 0{

        let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
        let user_id :String = contactDict.value(forKey: "user_id") as! String
        if self.selectedId.contains(user_id) {
            cell.selectionView.applyGradient()
        }else if !self.selectedId.contains(user_id){
            cell.selectionView.removeGrandient()
        }
        cell.tag = indexPath.row+100
        cell.config(contactDict:contactDict)
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.addTarget(self, action: #selector(goToProfilePopup), for: .touchUpInside)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
        let user_id :String = contactDict.value(forKey: "user_id") as! String
        // print(contactDict)
        let blockedMe = contactDict.value(forKey: "blockedMe") as! String
        let blockByMe = contactDict.value(forKey: "blockedByMe") as! String
        let isDeleted = contactDict.value(forKey: "isDelete") as! String
        if isDeleted == "0"{
        if blockedMe == "0" && blockByMe == "0" {
            let cell = view.viewWithTag(indexPath.row+100) as? createGroupCell
            if self.selectedId.contains(user_id) {
                self.selectedId.remove(user_id)
                cell?.selectionView.backgroundColor = .white
                cell?.selectionView.removeGrandient()
                self.selectedContacts.remove(contactDict)
            } else {
                self.selectedId.add(user_id)
                cell?.selectionView.applyGradient()
                self.selectedContacts.add(contactDict)
            }
            self.checkSelectionStatus()
            if self.selectedContacts.count == self.myContacts.count {
                selectionTag = 1
            }
            else {
                selectionTag = 0
            }
        }else{
            self.searchTF.resignFirstResponder()
            let contact_name = contactDict.value(forKey: "contact_name") as! String
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "could_not_add"))!) \(contact_name)")
        }
        }else{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "deleted_account"))!)")
        }
        self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"

        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = BACKGROUND_COLOR
        
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 15, width:
            tableView.bounds.size.width, height: 20))
        headerLabel.font = UIFont(name: APP_FONT_REGULAR, size: 20)
        headerLabel.textColor = TEXT_PRIMARY_COLOR
        headerLabel.text = Utility.shared.getLanguage()?.value(forKey: "share_people") as? String
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        let selectView = UIView(frame: CGRect(x: self.view.frame.width - 32, y: 15, width: 16, height: 16))
        if selectionTag == 0 {
            selectView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            selectView.removeGrandient()

        } else {
            selectView.applyGradient()

        }
        selectView.setViewBorder(color: SELECTION_BORDER_COLOR)
        headerView.tag = 0
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectAllAct)))
        headerView.addSubview(selectView)
        if UserModel.shared.getAppLanguage() == "عربى" {
            headerLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            headerLabel.textAlignment = .right
        } else {
            headerLabel.transform = .identity
            headerLabel.textAlignment = .left
        }
        return headerView
    }
    @objc func selectAllAct() {
        if selectionTag == 0 {
            selectionTag = 1
            for i in 0..<myContacts.count {
                let userDict:NSDictionary =  myContacts.object(at: i) as! NSDictionary
                let user_id :String = userDict.value(forKey: "user_id") as! String
                let blockedMe = userDict.value(forKey: "blockedMe") as! String
                if (!self.selectedId.contains(user_id) && blockedMe == "0") {
                    self.selectedId.add(user_id)
                    self.selectedContacts.add(userDict)
                }
            }
        }
        else {
            selectionTag = 0
            self.selectedId.removeAllObjects()
            self.selectedContacts.removeAllObjects()

        }
        self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"

        self.contactTableView.reloadData()
        self.checkSelectionStatus()

    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func checkSelectionStatus()  {
//        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
//            if self.selectedContacts.count == 0 {
//                self.topView.isHidden = true
//                self.bottomView.frame = CGRect.init(x: 0, y: self.navigationView.frame.size.height+2, width: FULL_WIDTH, height: FULL_HEIGHT)
//            }else{
//                self.topView.isHidden = true
//                let top = self.topView.frame.origin.y+self.topView.frame.size.height
////                self.bottomView.frame = CGRect.init(x: 0, y: top, width: FULL_WIDTH, height: FULL_HEIGHT-top)
//                self.bottomView.frame = CGRect.init(x: 0, y: self.navigationView.frame.size.height+2, width: FULL_WIDTH, height: FULL_HEIGHT)
//
//                self.selectedCollectionView.reloadData()
//            }
//            self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
//
//        }, completion: nil)
    }
    
    //profile popup
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        var profileDict = NSDictionary()
        profileDict = self.myContacts.object(at: sender.tag) as! NSDictionary
        let popup = ProfilePopup()
        popup.profileDict = profileDict
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
    
    func reloadAllData() {
        contactTableView.isHidden = false
        myContacts = contactCopy.mutableCopy() as! NSMutableArray
        self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
        self.checkAvailablity()
        self.searchTF.resignFirstResponder()
    }
    
    //MARK: Textfield delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.reloadAllData()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if contactCopy.count == 0 {
        }else {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            contactTableView.isHidden = true
            myContacts.removeAllObjects()
            // remove all data that belongs to previous search
            if (newString == "") || newString == nil {
                contactTableView.isHidden = false
                myContacts = contactCopy.mutableCopy() as! NSMutableArray
                self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
                self.checkAvailablity()
                return true
            }
            var counter: Int = 0
            for dict in contactCopy {
                let tempArray = NSMutableArray.init(array: [dict])
                var tempDict = NSDictionary()
                tempDict = tempArray.object(at: 0) as! NSDictionary
                let searchName = tempDict.value(forKey: "contact_name") as! String
                
                let range = searchName.range(of: newString!, options: NSString.CompareOptions.caseInsensitive, range: nil,locale: nil)
                if range != nil {
                    self.myContacts.add(dict)
                }
                counter += 1
            }
            self.checkAvailablity()
        }
        return true
    }
    
    //check contacts available or not
    func checkAvailablity()  {
        if myContacts.count == 0 {
            self.contactTableView.isHidden = true
            self.noView.isHidden = false
        }else{
            self.contactTableView.isHidden = false
            self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
            self.contactTableView.reloadData()
            self.hideView.isHidden = true
            self.loaderView.stopAnimating()
            self.noView.isHidden = true
        }
        
    }
    //background refresh action
    
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.contactTableView.frame.size.height = FULL_HEIGHT-self.navigationView.frame.size.height
        self.contactTableView.frame.size.height -= keyboardFrame.height
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.contactTableView.frame.size.height += keyboardFrame.height
    }
}

