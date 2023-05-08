//
//  ForwardSelection.swift
//  Hiddy
//
//  Created by APPLE on 12/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import MapKit
import Contacts

protocol forwardDelegate {
    func forwardMsg(type:String,idStr:String)
}


class ForwardSelection:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var noView: UIView!
    let del = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var groupArray = NSMutableArray()
    var recentArray = NSMutableArray()
    var contactArray = NSMutableArray()
    var channelArray = NSMutableArray()
    
    var recentCopy = NSMutableArray()
    var recentIDs = NSMutableArray()
    
    var searchArray = NSMutableArray()
    var overAllArray = NSMutableArray()
    
    var selectedId = NSMutableArray()
    var selectedContacts = NSMutableArray()
    var imageMsgDict = [NSMutableDictionary]()
    var msgID = [String]()
    var msgFrom = String()
    var sharedType = String()
    var selectedText = String()
    var contactData = Data()
    var group_id = ""
    var selectedShareImage = [UIImage]()
    var sharedCell = [CellModel]()
    var sharedVideoCell = [VideoCellModel]()

    var shareTag = 0
    var contact_id = String()
    var chat_id = String()
    var blockByMe = String()
    var blockedMe = String()
    
    let localDB = LocalStorage()
    let groupDB =  groupStorage()
    let channelDB =  ChannelStorage()
    var chatDetailDict = NSDictionary()
    var delegate:forwardDelegate?
    let userDefaults = UserDefaults(suiteName: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "").Share")
    let dispatchQueue = DispatchQueue(label: "com.test.Queue", qos: .userInteractive)
    let dispatchGroup = DispatchGroup()
    let cryptLib = CryptLib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.color = RECIVER_BG_COLOR
        if self.shareTag == 0 {
            print("type****** internal share")
        }
        else {
            print("type****** external share")
            self.uploadFilestoServer()
        }
        // Do any additional setup after loading the view.
        self.initalSetup()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.changeRTLView()
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.searchTF.textAlignment = .left
            self.searchTF.transform = .identity
            self.noLbl.transform = .identity
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
        configFloatingBtn()
        self.navigationView.elevationEffect()
        self.recentCopy = localDB.getSearchRecent()
        for user in self.recentCopy{
            let dict:NSDictionary = user as! NSDictionary
            self.recentIDs.add(dict.value(forKey: "user_id") as! String)
        }
        self.configList()
        self.overAllArray.addObjects(from: self.recentArray as! [Any])
        self.overAllArray.addObjects(from: self.groupArray as! [Any])
        self.overAllArray.addObjects(from: self.channelArray as! [Any])
        self.overAllArray.addObjects(from: self.contactArray as! [Any])
        
        // print("over all array count \(self.overAllArray.count)")
        if self.recentArray.count != 0 || self.groupArray.count != 0 {
            // self.searchTF.becomeFirstResponder()
        }
        searchTableView.register(UINib(nibName: "ForwardCell", bundle: nil), forCellReuseIdentifier: "ForwardCell")
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_contact")
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if shareTag == 0 {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.del.setInitialViewController(initialView: menuContainerPage())
        }
    }
    //config floating chat new btn
    func configFloatingBtn()  {
        let actionButton = JJFloatingActionButton()
        if UIDevice.current.hasNotch{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-125, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-90, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.buttonImage = #imageLiteral(resourceName: "next_arrow")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(forwordSelectionAct), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    
    func configList()  {
        self.recentArray.removeAllObjects()
        self.groupArray.removeAllObjects()
        self.contactArray.removeAllObjects()
        self.channelArray.removeAllObjects()
        self.searchArray.removeAllObjects()
        self.recentArray = localDB.getSearchRecent()
        self.groupArray = groupDB.getSearchGroupList()
        self.contactArray = localDB.filterContactFrom(recent: self.recentIDs)
        self.channelArray = channelDB.getSearchChannel(type: "forward")
        
        if self.recentArray.count != 0 && self.groupArray.count == 0 {
            self.addToArray(name:"recent" , list: self.recentArray)
        }else if self.recentArray.count == 0 && self.groupArray.count != 0{
            self.addToArray(name: "group", list: self.groupArray)
        }else if self.recentArray.count != 0 && self.groupArray.count != 0{
            self.addToArray(name:"recent" , list: self.recentArray)
            self.addToArray(name: "group", list: self.groupArray)
        }
        if self.channelArray.count != 0 {
            self.addToArray(name: "channel", list: self.channelArray)
        }
        if self.contactArray.count != 0 {
            self.addToArray(name: "contact", list: self.contactArray)
        }
        self.checkAvailablity()
    }
    
    func addToArray(name:String,list:NSArray){
        // print("count \(list)")
        let dict = NSMutableDictionary()
        dict.setValue(Utility.shared.getLanguage()?.value(forKey: name) as! String, forKey: "title")
        dict.setValue(list, forKey: "list")
        self.searchArray.add(dict)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.searchArray.count
    }
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        let msgDict:NSDictionary = self.searchArray.object(at: section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForwardCell", for: indexPath) as! ForwardCell

        if self.searchArray.count != 0{

        let msgDict:NSDictionary = self.searchArray.object(at: indexPath.section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        let contactDict:NSDictionary =  listArray.object(at: indexPath.row) as! NSDictionary
        let search_id :String = contactDict.value(forKey: "search_id") as! String
        if self.selectedId.contains(search_id) {
            cell.selectview.applyGradient()
        }else if !self.selectedId.contains(search_id){
            cell.selectview.removeGrandient()
        }
        cell.tag = indexPath.row+100
        cell.config(contactDict: contactDict)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchTF.resignFirstResponder()
        let msgDict:NSDictionary = self.searchArray.object(at: indexPath.section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        let dict:NSDictionary =  listArray.object(at: indexPath.row) as! NSDictionary
        let search_id :String = dict.value(forKey: "search_id") as! String
        let cell = view.viewWithTag(indexPath.row+100) as? ForwardCell
        let search_type :String = dict.value(forKey: "search_type") as! String
        var blockedByMe = String()
        if search_type == "recent" || search_type == "contact"{
            blockedByMe = dict.value(forKey: "blockedByMe") as! String
        }else{
            blockedByMe = "0" //other group, channel
        }
        
        if blockedByMe == "1" {
            
        }else{
            if self.selectedId.contains(search_id) {
                self.selectedId.remove(search_id)
                cell?.selectview.backgroundColor = .white
                cell?.selectview.removeGrandient()
                self.selectedContacts.remove(dict)
            }else {
                self.selectedId.add(search_id)
                cell?.selectview.applyGradient()
                self.selectedContacts.add(dict)
            }
            self.searchTableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dict:NSDictionary = self.searchArray.object(at: section) as! NSDictionary
        return dict.value(forKey: "title") as? String
    }
    
    //check contacts available or not
    func checkAvailablity()  {
        print("search array \(self.searchArray.count)")
        if searchArray.count == 0 {
            self.searchTableView.isHidden = true
            self.noView.isHidden = false
        }else{
            self.searchTableView.isHidden = false
            self.searchTableView.reloadData()
            self.noView.isHidden = true
        }
    }
    
    //MARK: Textfield delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchTableView.isHidden = false
        configList()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if overAllArray.count == 0 {
        } else {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            searchTableView.isHidden = true
            recentArray.removeAllObjects()
            contactArray.removeAllObjects()
            channelArray.removeAllObjects()
            groupArray.removeAllObjects()
            searchArray.removeAllObjects()
            // remove all data that belongs to previous search
            if (newString == "") || newString == nil {
                searchTableView.isHidden = false
                configList()
                return true
            }
            var counter: Int = 0
            var searchType = String()
            for dict in overAllArray {
                let tempArray = NSMutableArray.init(array: [dict])
                var tempDict = NSDictionary()
                tempDict = tempArray.object(at: 0) as! NSDictionary
                let searchName = tempDict.value(forKey: "search_name") as! String
                searchType = tempDict.value(forKey: "search_type") as! String
                
                let range = searchName.range(of: newString!, options: NSString.CompareOptions.caseInsensitive, range: nil,locale: nil)
                if range != nil {
                    if searchType == "recent"{
                        self.recentArray.add(dict)
                    }else if searchType == "group"{
                        self.groupArray.add(dict)
                    }else if searchType == "contact"{
                        self.contactArray.add(dict)
                    }else if searchType == "channel"{
                        self.channelArray.add(dict)
                    }
                }
                counter += 1
            }
            if self.recentArray.count != 0{
                self.addToArray(name: "recent", list:self.recentArray)
            }
            if self.groupArray.count != 0{
                self.addToArray(name: "group", list:self.groupArray)
            }
            if self.contactArray.count != 0{
                self.addToArray(name: "contact", list:self.contactArray)
            }
            if self.channelArray.count != 0{
                self.addToArray(name: "channel", list:self.channelArray)
            }
            self.checkAvailablity()
        }
        return true
    }
    
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.searchTableView.frame.size.height = FULL_HEIGHT-self.navigationView.frame.size.height
        self.searchTableView.frame.size.height -= keyboardFrame.height
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.searchTableView.frame.size.height += keyboardFrame.height
    }
    @objc func forwordSelectionAct() {
        if self.selectedContacts.count == 0 {
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "select_one") as? String)
        }
        else {
            if socket.defaultSocket.status.active {
                forwardMsg()
            }else{
                print("********** not good connection")
                self.forwordSelectionAct()
            }
        }
    }
    
    @objc func forwardMsg()  {
        if Utility.shared.isConnectedToNetwork() {
            
            if self.shareTag == 0 {
                DispatchQueue.main.async {
                    for messageID in self.msgID {
                        var forwardMsg = NSMutableDictionary()
                        var msgData = NSMutableDictionary()
                        if self.msgFrom == "single"{
                            forwardMsg = self.localDB.getMsg(msg_id: messageID)
                            let dict:NSDictionary = forwardMsg.value(forKey: "message_data") as! NSDictionary
                            msgData = NSMutableDictionary.init(dictionary: dict)
                        }else if self.msgFrom == "group"{
                            msgData = self.groupDB.getGroupForwardMsg(msg_id: messageID)
                        }else if self.msgFrom == "channel"{
                            msgData = self.channelDB.getChannelForwardMsg(msg_id: messageID)
                        }
                        let newDict = NSMutableDictionary()
                        
                        for users in self.selectedContacts{
                            let detail : NSDictionary = users as! NSDictionary
                            let type:String = detail.value(forKey: "search_type") as! String
                            let receiver:String = detail.value(forKey: "search_id") as! String
                            let name:String = detail.value(forKey: "search_name") as! String
                            let msgType:String = msgData.value(forKey: "message_type") as! String
                            if self.msgFrom == "single"{
                                msgData.removeObject(forKey: "receiver_id")
                                msgData.removeObject(forKey: "chat_id")
                                msgData.removeObject(forKey: "sender_id")
                            }
                            msgData.removeObject(forKey: "chat_time")
                            msgData.removeObject(forKey: "message_id")
                            let msg_id = Utility.shared.random()
                            msgData.setValue(msg_id, forKey: "message_id")
                            msgData.setValue(Utility.shared.getTime(), forKey: "chat_time")
                          
                            let msg = msgData.value(forKey: "message") as! String
//                            let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:msg, key: ENCRYPT_KEY)
                            msgData.setValue(msg, forKey: "message")
                            
                            let msg_type = msgData.value(forKey: "message_type") as? String ?? ""
                            if msg_type == "story" {
                                msgData.removeObject(forKey: "message_type")
                                msgData.setValue("text", forKey: "message_type")
                            }
                            if type == "recent" || type == "contact"{
                                self.blockedMe = detail.value(forKey: "blockedMe") as! String
                                msgData.setValue(UserModel.shared.userID(), forKey: "sender_id")
                                msgData.setValue("single", forKey: "chat_type")
                                msgData.setValue(receiver, forKey: "receiver_id")
                                msgData.setValue("\(receiver)\(UserModel.shared.userID()!)", forKey: "chat_id")
                                msgData.setValue(detail.value(forKey: "user_name") as! String, forKey: "user_name")
                                if msgType == "contact"{
                                    msgData.setValue(msgData.value(forKey: "cName"), forKey: "contact_name")
                                    msgData.setValue(msgData.value(forKey: "cNo"), forKey: "contact_phone_no")
                                }
                                newDict.setValue(msgData, forKey: "message_data")
                                newDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                                newDict.setValue(receiver, forKey: "receiver_id")
                                newDict.setValue(detail.value(forKey: "user_phoneno") as! String, forKey: "phone")

                                if self.blockedMe == "0"{
                                
                                    socketClass.sharedInstance.sendMsg(requestDict: newDict)

                                }
                                
                                Utility.shared.addToLocal(requestDict: newDict, chat_id: "\(UserModel.shared.userID()!)\(receiver)", contact_id: receiver)
                                if msgType == "video"{
                                    self.localDB.updateDownload(msg_id: msg_id,status:"1")
                                }
                                self.delegate?.forwardMsg(type: msg_id, idStr:"\(UserModel.shared.userID()!)\(receiver)")
                            }else if type == "group"{
                                msgData.setValue("group", forKey: "chat_type")
                                msgData.setValue(UserModel.shared.userID(), forKey: "member_id")
                                msgData.setValue("0", forKey: "member_role")
                                if msgType == "contact"{
                                    msgData.setValue(msgData.value(forKey: "cName"), forKey: "contact_name")
                                    msgData.setValue(msgData.value(forKey: "cNo"), forKey: "contact_phone_no")
                                }
                                msgData.setValue(UserModel.shared.phoneNo(), forKey: "member_no")
                                msgData.setValue(UserModel.shared.userName(), forKey: "member_name")
                                msgData.setValue(name, forKey: "group_name")
                                msgData.setValue(receiver, forKey: "group_id")
                                print("forward msggggg \(msgData)")
                                //send socket
                                self.addToGroupLocal(requestDict: msgData)
                                
                                groupSocket.sharedInstance.sendGroupMsg(requestDict: msgData)
                                if msgType == "video"{
                                    self.groupDB.updateGroupMediaDownload(msg_id: msg_id, status: "1")
                                }
                                self.delegate?.forwardMsg(type: msg_id, idStr:receiver)
                            }else if type == "channel"{
                                msgData.setValue("channel", forKey: "chat_type")
                                msgData.setValue(UserModel.shared.userID(), forKey: "admin_id")
                                msgData.setValue(name, forKey: "channel_name")
                                msgData.setValue(receiver, forKey: "channel_id")
                                if msgType == "contact"{
                                    msgData.setValue(msgData.value(forKey: "cName"), forKey: "contact_name")
                                    msgData.setValue(msgData.value(forKey: "cNo"), forKey: "contact_phone_no")
                                }
                                channelSocket.sharedInstance.sendChannelMsg(requestDict: msgData)
                                Utility.shared.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData, msg_id: msg_id, time: Utility.shared.getTime(), admin: UserModel.shared.userID()! as String)
                                if msgType == "video"{
                                    self.channelDB.updateChannelMediaDownload(msg_id: msg_id, status: "1")
                                }
                                self.channelDB.channelReadStatus(channel_id: receiver)
                                self.channelDB.channelUpdateUnreadCount(channel_id: receiver)
                                self.delegate?.forwardMsg(type: msg_id, idStr:receiver)

                            }
                        }
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                print("selected ids \(self.msgID) contacts \(self.selectedContacts)")

                var msgData = NSMutableDictionary()
                let newDict = NSMutableDictionary()
                for users in self.selectedContacts {
                    let detail : NSDictionary = users as! NSDictionary
                    let type:String = detail.value(forKey: "search_type") as! String
                    let receiver:String = detail.value(forKey: "search_id") as! String
                    let name:String = detail.value(forKey: "search_name") as! String
                    self.blockByMe = detail.value(forKey: "blockedByMe") as? String ?? "0"
                    self.blockedMe = detail.value(forKey: "blockedMe") as? String ?? "0"
                    let msgType:String = self.sharedType
                    
                    self.contact_id = receiver
                    self.chatDetailDict = detail
                    self.msgFrom = "single"
                    // Time & Message Type
                    msgData.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    msgData.setValue(self.sharedType, forKey: "message_type")
                    msgData.setValue("1", forKey: "read_status")
                    
                    if type == "recent" || type == "contact" {
                        self.chat_id = "\(UserModel.shared.userID()!)\(detail.value(forKey: "user_id")!)"
                        self.blockedMe = detail.value(forKey: "blockedMe") as! String
                        msgData.setValue(UserModel.shared.userID(), forKey: "sender_id")
                        msgData.setValue("single", forKey: "chat_type")
                        msgData.setValue(receiver, forKey: "receiver_id")
                        msgData.setValue("\(receiver)\(UserModel.shared.userID()!)", forKey: "chat_id")
                        msgData.setValue(detail.value(forKey: "user_name") as! String, forKey: "user_name")
                        if msgType == "contact"{
                            msgData.setValue(msgData.value(forKey: "cName"), forKey: "contact_name")
                            msgData.setValue(msgData.value(forKey: "cNo"), forKey: "contact_phone_no")
                        }
                        newDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                        newDict.setValue(receiver, forKey: "receiver_id")
                        let requestDict = NSMutableDictionary()
                        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
                        requestDict.setValue(self.chatDetailDict.value(forKey: "user_id") as! String, forKey: "receiver_id")
                        if self.sharedType == "text" || self.sharedType == "location" || self.sharedType == "contact" { // If text then create message
                            let msg_id = Utility.shared.random()
                            msgData.setValue(msg_id, forKey: "message_id")
                            if self.sharedType == "text" {
//                                let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:self.selectedText, key: ENCRYPT_KEY)
                                msgData.setValue(self.selectedText, forKey: "message")
                                newDict.setValue(msgData, forKey: "message_data")
                                if self.blockedMe == "0" && self.blockByMe == "0"{
                                    socketClass.sharedInstance.sendMsg(requestDict: newDict)
                                    self.addToLocal(requestDict: newDict)
                                }
                                else if self.blockByMe == "1"{
                                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                                }else{
                                    self.addToLocal(requestDict: newDict)
                                }
                                
                            }
                            else if self.sharedType == "contact" {
                                msgData.setValue("contact", forKey: "message_type")
                                msgData.setValue("Contact", forKey: "message")
                                if let contact = self.saveVCardContacts(vCard: self.contactData) {
                                    msgData.setValue(contact.givenName, forKey: "contact_name")
                                    msgData.setValue((contact.phoneNumbers[0].value).value(forKey: "digits") as? String, forKey: "contact_phone_no")
                                }
                                newDict.setValue(msgData, forKey: "message_data")
                                if self.blockedMe == "0" && self.blockByMe == "0"{
                                    socketClass.sharedInstance.sendMsg(requestDict: newDict)
                                    self.addToLocal(requestDict: newDict)
                                }
                                else if self.blockByMe == "1"{
                                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                                }else{
                                    self.addToLocal(requestDict: newDict)
                                }
                                
                            }
                            else if self.sharedType == "location" {
                                let geoCoder = CLGeocoder()
                                geoCoder.geocodeAddressString(self.selectedText) { (placemarks, error) in
                                    guard
                                        let placemarks = placemarks,
                                        let location = placemarks.first?.location
                                        else {
                                            // handle no location found
                                            return
                                    }
                                    msgData.setValue("location", forKey: "message_type")
                                    msgData.setValue("Location", forKey: "message")
                                    msgData.setValue("\(location.coordinate.latitude)", forKey: "lat")
                                    msgData.setValue("\(location.coordinate.longitude)", forKey: "lon")
                                    newDict.setValue(msgData, forKey: "message_data")
                                    if self.blockedMe == "0" && self.blockByMe == "0"{
                                        socketClass.sharedInstance.sendMsg(requestDict: newDict)
                                        self.addToLocal(requestDict: newDict)
                                    }
                                    else if self.blockByMe == "1"{
                                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                                    }else{
                                        self.addToLocal(requestDict: newDict)
                                    }
                                    
                                    // Use your location
                                }
                            }
                        }
                        if self.sharedType == "document" {
                            let url = URL(fileURLWithPath: self.selectedText)
                            let fileData = self.userDefaults?.data(forKey: "documentData")
                            let fileName = url.lastPathComponent
                            let extensionType = ".\(url.pathExtension)"
                            msgData.setValue("0", forKey: "isDownload")
                            msgData.setValue("document", forKey: "message_type")
                            msgData.setValue(fileName, forKey: "message")
                            self.uploadFiles(msgDict: msgData, requestDict: requestDict, attachData: fileData!, type:extensionType , image: nil, onSuccess: {response in
                                msgData = response as! NSMutableDictionary
                                newDict.setValue(msgData, forKey: "message_data")
                                if self.blockedMe == "0" && self.blockByMe == "0"{
                                    socketClass.sharedInstance.sendMsg(requestDict: newDict)
                                    self.addToLocal(requestDict: newDict)
                                }
                                else if self.blockByMe == "1"{
                                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                                }else{
                                    self.addToLocal(requestDict: newDict)
                                }
                                
                            })
                        }
                        else if self.sharedType == "imageVideo" {
                            self.singleUserImageVideoUpload(msgData: msgData, requestDict: newDict) { (status) in
                                print(status)
                            }
                        }
                        self.delegate?.forwardMsg(type: "", idStr:"\(UserModel.shared.userID()!)\(receiver)")

                    }else if type == "group"{
                        msgData.setValue("group", forKey: "chat_type")
                        msgData.setValue(UserModel.shared.userID(), forKey: "member_id")
                        msgData.setValue("0", forKey: "member_role")
                        msgData.setValue(UserModel.shared.phoneNo(), forKey: "member_no")
                        msgData.setValue(UserModel.shared.userName(), forKey: "member_name")
                        msgData.setValue(name, forKey: "group_name")
                        msgData.setValue(receiver, forKey: "group_id")
                        self.group_id = receiver
                        if self.sharedType == "text" || self.sharedType == "contact" || self.sharedType == "location" {
                            let msg_id = Utility.shared.random()
                            msgData.setValue(msg_id, forKey: "message_id")
                            if self.sharedType == "text" {
//                                let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:self.selectedText, key: ENCRYPT_KEY)
                                msgData.setValue(self.selectedText, forKey: "message")
                                newDict.setValue(msgData, forKey: "message_data")
                                groupSocket.sharedInstance.sendGroupMsg(requestDict: newDict)
                                self.addToGroupLocal(requestDict: msgData)
                            }
                            else if self.sharedType == "contact" {
                                msgData.setValue("contact", forKey: "message_type")
                                msgData.setValue("Contact", forKey: "message")
                                if let contact = self.saveVCardContacts(vCard: self.contactData) {
                                    msgData.setValue(contact.givenName, forKey: "contact_name")
                                    msgData.setValue((contact.phoneNumbers[0].value).value(forKey: "digits") as? String, forKey: "contact_phone_no")
                                }
                                newDict.setValue(msgData, forKey: "message_data")
                                groupSocket.sharedInstance.sendGroupMsg(requestDict: newDict)
                                self.addToGroupLocal(requestDict: msgData)
                            }
                            else if self.sharedType == "location" {
                                let geoCoder = CLGeocoder()
                                geoCoder.geocodeAddressString(self.selectedText) { (placemarks, error) in
                                    guard
                                        let placemarks = placemarks,
                                        let location = placemarks.first?.location
                                        else {
                                            // handle no location found
                                            return
                                    }
                                    msgData.setValue("location", forKey: "message_type")
                                    msgData.setValue("Location", forKey: "message")
                                    msgData.setValue("\(location.coordinate.latitude)", forKey: "lat")
                                    msgData.setValue("\(location.coordinate.longitude)", forKey: "lon")
                                    newDict.setValue(msgData, forKey: "message_data")
                                    groupSocket.sharedInstance.sendGroupMsg(requestDict: newDict)
                                    self.addToGroupLocal(requestDict: msgData)
                                    
                                    // Use your location
                                }
                            }
                        }
                        else if self.sharedType == "document" {
                            let url = URL(fileURLWithPath: self.selectedText)
                            let fileData = self.userDefaults?.data(forKey: "documentData")
                            let fileName = url.lastPathComponent
                            let extensionType = ".\(url.pathExtension)"
                            msgData.setValue("0", forKey: "isDownload")
                            msgData.setValue("document", forKey: "message_type")
                            msgData.setValue(fileName, forKey: "message")
                            self.uploadFiles(msgDict: msgData, requestDict: newDict, attachData: fileData!, type:extensionType , image: nil, onSuccess: {response in
                                msgData = response as! NSMutableDictionary
                                newDict.setValue(msgData, forKey: "message_data")
                                groupSocket.sharedInstance.sendGroupMsg(requestDict: newDict)
                                self.addToGroupLocal(requestDict: msgData)
                            })
                        }
                        else if self.sharedType == "imageVideo" {
                            self.groupUserImageVideoUpload(msgData: msgData, requestDict: newDict)
                        }
                        self.delegate?.forwardMsg(type: "", idStr:receiver )
                    }
                    else if type == "channel"{
                        msgData.setValue("channel", forKey: "chat_type")
                        msgData.setValue(UserModel.shared.userID(), forKey: "admin_id")
                        msgData.setValue(name, forKey: "channel_name")
                        msgData.setValue(receiver, forKey: "channel_id")
                        if self.sharedType == "text" || self.sharedType == "contact" || self.sharedType == "location"{
                            let msg_id = Utility.shared.random()
                            msgData.setValue(msg_id, forKey: "message_id")
                            if self.sharedType == "text" {
//                                let encryptedMsg = self.cryptLib.encryptPlainTextRandomIV(withPlainText:self.selectedText, key: ENCRYPT_KEY)
                                msgData.setValue(self.selectedText, forKey: "message")
                                channelSocket.sharedInstance.sendChannelMsg(requestDict: msgData)
                                self.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData)
                                
                            }
                            else if self.sharedType == "contact" {
                                msgData.setValue("contact", forKey: "message_type")
                                msgData.setValue("Contact", forKey: "message")
                                if let contact = self.saveVCardContacts(vCard: self.contactData) {
                                    msgData.setValue(contact.givenName, forKey: "contact_name")
                                    msgData.setValue((contact.phoneNumbers[0].value).value(forKey: "digits") as? String, forKey: "contact_phone_no")
                                }
                                channelSocket.sharedInstance.sendChannelMsg(requestDict: msgData)
                                self.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData)
                                
                            }
                            else if self.sharedType == "location" {
                                let geoCoder = CLGeocoder()
                                geoCoder.geocodeAddressString(self.selectedText) { (placemarks, error) in
                                    guard
                                        let placemarks = placemarks,
                                        let location = placemarks.first?.location
                                        else {
                                            // handle no location found
                                            return
                                    }
                                    msgData.setValue("location", forKey: "message_type")
                                    msgData.setValue("Location", forKey: "message")
                                    msgData.setValue("\(location.coordinate.latitude)", forKey: "lat")
                                    msgData.setValue("\(location.coordinate.longitude)", forKey: "lon")
                                    channelSocket.sharedInstance.sendChannelMsg(requestDict: msgData)
                                    self.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData)
                                    
                                    // Use your location
                                }
                            }
                        }
                        else if self.sharedType == "document" {
                            let url = URL(fileURLWithPath: self.selectedText)
                            let fileData = self.userDefaults?.data(forKey: "documentData")
                            let fileName = url.lastPathComponent
                            let extensionType = ".\(url.pathExtension)"
                            msgData.setValue("0", forKey: "isDownload")
                            msgData.setValue("document", forKey: "message_type")
                            msgData.setValue(fileName, forKey: "message")
                            self.uploadFiles(msgDict: msgData, requestDict: msgData, attachData: fileData!, type:extensionType , image: nil, onSuccess: {response in
                                msgData = response as! NSMutableDictionary
                                channelSocket.sharedInstance.sendChannelMsg(requestDict: msgData)
                                self.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData)
                            })
                        }
                        else if self.sharedType == "imageVideo"
                        {
                            self.channelUserImageVideoUpload(msgData: msgData, requestDict: newDict)
                        }
                        self.delegate?.forwardMsg(type: "", idStr:receiver )
                    }
                }
                self.del.setInitialViewController(initialView: menuContainerPage())
            }
        }
    }
    func uploadFilestoServer() {
        let uploadObj = UploadServices()
        self.shadowView.isHidden = false
        self.activityIndicator.startAnimating()
        if self.shareTag == 1 {
            if self.sharedType == "imageVideo" {
                let dispatchGroup = DispatchGroup()
                for i in 0..<self.sharedVideoCell.count {
                    // print(self.sharedVideoCell[i])
                    let type = (self.sharedVideoCell[i].type)
                    if type == "video" {
                        let size = Float((self.sharedVideoCell[i].imageData?.count)!) / 1024.0 / 1024.0
                        if size.rounded() < 50 {
                            let url = NSURL(string: self.sharedVideoCell[i].imageURL)
                                //upload video file{
                                let videoName:String = (url?.lastPathComponent)!
                                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                let filePath="\(documentsPath)/\(videoName)"
                                let attachData = self.sharedVideoCell[i].imageData! as NSData
                                attachData.write(toFile: filePath, atomically: true)
                                let extensionType = ".\(url?.pathExtension ?? "")"
                            dispatchGroup.enter()

                                // print("type:::: \(extensionType)")
                            uploadObj.uploadMultipleFiles(fileData: attachData as Data, type: extensionType, user_id: UserModel.shared.userID()! as String, docuName: "Video", api_type: "private") { (response) in
                                self.sharedVideoCell[i].imageURL = response.value(forKey: "user_image") as? String ?? ""
                                
                                let url = URL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(self.sharedVideoCell[i].imageURL)")
                                let image = Utility.shared.thumbnailForVideoAtURL(url: url!)
                                let flippedImage = UIImage(cgImage: (image?.cgImage)!, scale: (image?.scale)!, orientation: .right)
                                let thumbData = flippedImage.jpegData(compressionQuality: 0.5)//UIImageJPEGRepresentation(flippedImage, 0.5)!
                                if thumbData != nil
                                {
                                    uploadObj.uploadMultipleFiles(fileData: thumbData!, type: ".jpg", user_id: UserModel.shared.userID()! as String, docuName: "video", api_type: "private", onSuccess: { (response) in
                                        self.sharedVideoCell[i].thumb = response.value(forKey: "user_image") as? String ?? ""
                                        if i == self.sharedVideoCell.count - 1 {
                                            self.activityIndicator.stopAnimating()
                                            self.shadowView.isHidden = true
                                        }
                                        dispatchGroup.leave()
                                    })
                                }
                            }
                        }
                    }
                    else {
                        dispatchGroup.enter()
                        let sharedData = self.sharedVideoCell[i].imageData
                        let url = NSURL(string: self.sharedVideoCell[i].imageURL)
                        let extensionType = ".\(url?.pathExtension ?? "")"
                        uploadObj.uploadMultipleFiles(fileData: sharedData!, type: extensionType, user_id: UserModel.shared.userID()! as String, docuName: "image", api_type: "private") { (response) in
                            self.sharedVideoCell[i].imageURL = response.value(forKey: "user_image") as? String ?? ""
                            if i == self.sharedVideoCell.count - 1 {
                                self.activityIndicator.stopAnimating()
                                self.shadowView.isHidden = true
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                self.shadowView.isHidden = true
            }
        }
    }
    func singleUserImageVideoUpload(msgData: NSMutableDictionary, requestDict: NSMutableDictionary, onSuccess success: @escaping (Bool) -> Void) {
        self.imageMsgDict.removeAll()
//        if self.sharedVideoCell.filter({$0.type == "image"})
        for i in 0..<self.sharedVideoCell.count {
            // print(self.sharedVideoCell[i])
            let type = (self.sharedVideoCell[i].type)
            let msg_id = Utility.shared.random()
            msgData.setValue(msg_id, forKey: "message_id")
            if type == "video" {
                let size = Float((self.sharedVideoCell[i].imageData?.count)!) / 1024.0 / 1024.0
                if size.rounded() < 50 {
                    msgData.setValue("video", forKey: "message_type")
                    msgData.setValue("video", forKey: "message")
                    msgData.setValue("0", forKey: "isDownload")
                    msgData.setValue(EMPTY_STRING, forKey: "attachment")
                    msgData.setValue(self.sharedVideoCell[i].localPath, forKey: "local_path")
                    msgData.setValue(self.sharedVideoCell[i].thumb, forKey: "thumbnail")
                    msgData.setValue(self.sharedVideoCell[i].imageURL, forKey: "attachment")

                    let url = NSURL(string: self.sharedVideoCell[i].imageURL)
                    if self.blockByMe == "1"{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                    }else{
                        PhotoAlbum.sharedInstance.saveVideo(url: url! as URL ,msg_id: msgData.value(forKey: "message_id") as? String ?? "", type: "single")
                        requestDict.setValue(msgData, forKey: "message_data")
                        if self.blockedMe == "0" && self.blockByMe == "0"{
                            socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                            self.addToLocal(requestDict: requestDict)
                        }
                        else if self.blockByMe == "1"{
                            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                        }else{
                            self.addToLocal(requestDict: requestDict)
                        }
//                        socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                        self.localDB.updateDownload(msg_id: msg_id,status:"1")
                        success(true)

                    }
                }
                else {
                    success(true)
                }
            }
            else {
                self.imageMsgDict.append(msgData)
                msgData.setValue("image", forKey: "message_type")
                msgData.setValue("image", forKey: "message")
                msgData.setValue("0", forKey: "isDownload")
                msgData.setValue(EMPTY_STRING, forKey: "attachment")
                msgData.setValue(self.sharedVideoCell[i].localPath, forKey: "local_path")
                
                msgData.setValue(self.sharedVideoCell[i].imageURL, forKey: "attachment")
                msgData.setValue("0", forKey: "isDownload")
                msgData.setValue("single", forKey: "chat_type")
                requestDict.setValue(msgData, forKey: "message_data")
                if self.blockedMe == "0" && self.blockByMe == "0"{
                    socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                    self.addToLocal(requestDict: requestDict)
                }
                else if self.blockByMe == "1"{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                }else{
                    self.addToLocal(requestDict: requestDict)
                }
            }
        }
    }
    func groupUserImageVideoUpload(msgData: NSDictionary, requestDict: NSDictionary) {
        self.imageMsgDict.removeAll()
        //        if self.sharedVideoCell.filter({$0.type == "image"})
        print("shared video counttttt \(self.sharedVideoCell.count)")
        for i in 0..<self.sharedVideoCell.count {
            // print(self.sharedVideoCell[i])
            let type = (self.sharedVideoCell[i].type)
            let msg_id = Utility.shared.random()
            msgData.setValue(msg_id, forKey: "message_id")
            if type == "video" {
                let size = Float((self.sharedVideoCell[i].imageData?.count)!) / 1024.0 / 1024.0
                if size.rounded() < 50 {
                    msgData.setValue("video", forKey: "message_type")
                    msgData.setValue("video", forKey: "message")
                    msgData.setValue("0", forKey: "isDownload")
                    msgData.setValue(self.sharedVideoCell[i].localPath, forKey: "local_path")
                    msgData.setValue(self.sharedVideoCell[i].thumb, forKey: "thumbnail")
                    msgData.setValue(self.sharedVideoCell[i].imageURL, forKey: "attachment")
                    msgData.setValue("group", forKey: "chat_type")

                    let url = NSURL(string: self.sharedVideoCell[i].imageURL)
                    PhotoAlbum.sharedInstance.saveVideo(url: url! as URL ,msg_id: msgData.value(forKey: "message_id") as? String ?? "", type: "group")
                    requestDict.setValue(msgData, forKey: "message_data")
                    self.addToGroupLocal(requestDict: msgData)
                    self.groupDB.updateGroupMediaDownload(msg_id: msg_id, status: "1")
                    groupSocket.sharedInstance.sendGroupMsg(requestDict: msgData)
                }
            }
            else {
                msgData.setValue("image", forKey: "message_type")
                msgData.setValue("image", forKey: "message")
                msgData.setValue("0", forKey: "isDownload")
                msgData.setValue(EMPTY_STRING, forKey: "attachment")
                msgData.setValue(self.sharedVideoCell[i].localPath, forKey: "local_path")
                msgData.setValue(self.sharedVideoCell[i].imageURL, forKey: "attachment")
                msgData.setValue("0", forKey: "isDownload")
                msgData.setValue("group", forKey: "chat_type")
                
                requestDict.setValue(msgData, forKey: "message_data")
                if self.blockedMe == "0" && self.blockByMe == "0"{
                    groupSocket.sharedInstance.sendGroupMsg(requestDict: requestDict)
                    self.addToGroupLocal(requestDict: msgData)
                }
                else if self.blockByMe == "1"{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                }else{
                    self.addToGroupLocal(requestDict: msgData)
                }
            }
        }
    }
    func channelUserImageVideoUpload(msgData: NSDictionary, requestDict: NSDictionary) {
        self.imageMsgDict.removeAll()
        //        if self.sharedVideoCell.filter({$0.type == "image"})
        for i in 0..<self.sharedVideoCell.count {
            // print(self.sharedVideoCell[i])
            let type = (self.sharedVideoCell[i].type)
            let msg_id = Utility.shared.random()
            msgData.setValue(msg_id, forKey: "message_id")
            let receiver = msgData.value(forKey: "channel_id") as? String ?? ""
            if type == "video" {
                let size = Float((self.sharedVideoCell[i].imageData?.count)!) / 1024.0 / 1024.0
                if size.rounded() < 50 {
                    msgData.setValue("video", forKey: "message_type")
                    msgData.setValue("video", forKey: "message")
                    msgData.setValue("0", forKey: "isDownload")
                    msgData.setValue(self.sharedVideoCell[i].localPath, forKey: "local_path")
                    msgData.setValue(self.sharedVideoCell[i].thumb, forKey: "thumbnail")
                    msgData.setValue(self.sharedVideoCell[i].imageURL, forKey: "attachment")
                    msgData.setValue("channel", forKey: "chat_type")
                    
                    let url = NSURL(string: self.sharedVideoCell[i].imageURL)
                    if self.blockByMe == "1"{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                    }else{
                        PhotoAlbum.sharedInstance.saveVideo(url: url! as URL ,msg_id: msgData.value(forKey: "message_id") as? String ?? "", type: "channel")
                        requestDict.setValue(msgData, forKey: "message_data")
                        channelSocket.sharedInstance.sendChannelMsg(requestDict: msgData)
                        self.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData)
                        self.channelDB.updateChannelMediaDownload(msg_id: msg_id, status: "1")
                    }
                }
            }
            else {
                msgData.setValue("image", forKey: "message_type")
                msgData.setValue("image", forKey: "message")
                msgData.setValue("0", forKey: "isDownload")
                msgData.setValue(EMPTY_STRING, forKey: "attachment")
                msgData.setValue(self.sharedVideoCell[i].localPath, forKey: "local_path")
                msgData.setValue(self.sharedVideoCell[i].imageURL, forKey: "attachment")
                msgData.setValue("0", forKey: "isDownload")
                msgData.setValue("channel", forKey: "chat_type")
                
                requestDict.setValue(msgData, forKey: "message_data")
                if self.blockedMe == "0" && self.blockByMe == "0"{
                    channelSocket.sharedInstance.sendChannelMsg(requestDict: msgData)
                    self.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData)
                }
                else if self.blockByMe == "1"{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
                }else{
                    self.addChannelMsgToLocal(channel_id: receiver, requestDict: msgData)
                }
            }
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
            thumbnail = requestDict.value(forKey: "thumbnail") as? String ?? ""
        }else if type == "document"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "audio"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "gif"{
            attach = requestDict.value(forKey: "attachment") as! String
        }
//        channelDB.readStatus(id: requestDict.value(forKey: "message_id") as! String, status: "4", type: "message")
//        channelDB.updateDownload(requestDict.value(forKey: "message_id") as! String, msg_id, status: "4")

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
        
        var dateString = String()
        dateString = Utility.shared.chatDate(stamp: time)
        
        _ = channelMsgModel.message.init(message_id: requestDict.value(forKey: "message_id") as! String,
                                                 channel_id: channel_id,
                                                 message_type: requestDict.value(forKey: "message_type")! as! String,
                                                 message: requestDict.value(forKey: "message")! as! String,
                                                 timestamp: time,
                                                 lat: lat,
                                                 lon: lon,
                                                 contact_name: cName,
                                                 contact_no: cNo,
                                                 country_code: cc,
                                                 attachment: attach,
                                                 thumbnail: thumbnail,
                                                 isDownload: "",
                                                 local_path: "",
                                                 date: dateString,
                                                 admin_id: UserModel.shared.userID()! as String ,translated_status: "", translated_msg: "", msg_date: msg_date)
    }

    func addToGroupLocal(requestDict:NSDictionary)  {
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
        var admin : String = EMPTY_STRING
        self.group_id = requestDict.value(forKey: "group_id") as? String ?? ""
        
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
            thumbnail = requestDict.value(forKey: "thumbnail") as? String ?? ""
        }else if type == "document"{
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
            
        }
    
    func saveVCardContacts (vCard : Data) -> CNContact? { // assuming you have alreade permission to acces contacts
        
        if #available(iOS 9.0, *) {
            
            
            do {
                
                let contacts = try CNContactVCardSerialization.contacts(with: vCard) // get contacts array from vCard
                if contacts[0].isKeyAvailable(CNContactPhoneNumbersKey){
                    
                    if contacts[0].phoneNumbers.count != 0  {
                        return contacts[0]
                    }else{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_number") as? String)
                    }
                }
                
            } catch  {
                
                // print("Unable to show the new contact") // something went wrong
                
            }
            
        }else{
            // print("CNContact not supported.") //
            
        }
        return nil
    }
    func uploadFiles(msgDict:NSDictionary,requestDict:NSDictionary,attachData:Data,type:String,image:UIImage?, onSuccess success: @escaping (NSDictionary) -> Void){
        let msgVal = msgDict
        if Utility.shared.isConnectedToNetwork() {
            let uploadObj = UploadServices()
            uploadObj.uploadMultipleFiles(fileData: attachData, type: type, user_id: UserModel.shared.userID()! as String,docuName:msgDict.value(forKey: "message") as? String ?? "",api_type:"private",onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    let msg_id = Utility.shared.random()
                    msgVal.setValue(msg_id, forKey: "message_id")
                    msgVal.setValue(Utility.shared.getTime(), forKey: "chat_time")
                    msgVal.setValue(response.value(forKey: "user_image"), forKey: "attachment")
                    msgVal.setValue("0", forKey: "isDownload")
                    msgVal.setValue("single", forKey: "chat_type")
                    
//                    requestDict.setValue(msgVal, forKey: "message_data")
                    //send socket
//                    socketClass.sharedInstance.sendMsg(requestDict: requestDict)
//                    self.addToLocal(requestDict: requestDict)
                    
                    //check if photo is already exists in gallery
                    let msgType:String = msgVal.value(forKey: "message_type") as! String
                    if msgType == "image"{
                        if msgVal.value(forKey: "local_path") != nil{
                            let image = UIImage(data: attachData)
                            if !PhotoAlbum.sharedInstance.checkExist(identifier: msgVal.value(forKey: "local_path") as! String)!{
                                PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgVal.value(forKey: "message_id") as! String, type: "single")
                            }else{
                                self.localDB.updateLocalURL(msg_id: msgVal.value(forKey: "message_id") as! String, url: msgVal.value(forKey: "local_path") as! String)
                            }
                        }else{
                            PhotoAlbum.sharedInstance.save(image: image!, msg_id: msgVal.value(forKey: "message_id") as! String, type: "single")
                        }
                    }
                    success(msgVal)
                }
            })
            dismiss(animated:true, completion: nil)
        } else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    func fetchCurrentLocation(location: CLLocation) -> NSMutableDictionary{
        let msgDict = NSMutableDictionary()
        msgDict.setValue("\(location.coordinate.latitude)", forKey: "lat")
        msgDict.setValue("\(location.coordinate.longitude)", forKey: "lon")
        msgDict.setValue("location", forKey: "message_type")
        msgDict.setValue("Location", forKey: "message")
        return msgDict
    }
    
    //upload video thumbnail
    func uploadThumbnail(msgDict: NSDictionary, requestDict: NSDictionary, attachData: NSData,fileURL:NSURL,type:String)  {
        if Utility.shared.isConnectedToNetwork() {
            let msg_id = Utility.shared.random()
            msgDict.setValue(msg_id, forKey: "message_id")
            msgDict.setValue(EMPTY_STRING, forKey: "thumbnail")
            msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
            msgDict.setValue(self.contact_id, forKey: "receiver_id")
            msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
            msgDict.setValue("\(self.chatDetailDict.value(forKey: "user_id")!)\(UserModel.shared.userID()!)", forKey: "chat_id")
            msgDict.setValue(EMPTY_STRING, forKey: "attachment")
            msgDict.setValue("single", forKey: "chat_type")
            msgDict.setValue("0", forKey: "isDownload")
            requestDict.setValue(msgDict, forKey: "message_data")
            if self.blockByMe == "1"{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_send") as? String)
            }else{
                //upload video file
                
                self.addToLocal(requestDict: requestDict)
                let videoName:String = fileURL.lastPathComponent!
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(videoName)"
                attachData.write(toFile: filePath, atomically: true)
//                PhotoAlbum.sharedInstance.saveForwordVideo(url: URL.init(string: filePath)!, msg_id: msgDict.value(forKey: "message_id") as! String, type: "single", requestDict: requestDict, onSuccess: <#(NSDictionary) -> Void#>)
                //                        if self.galleryType == "1"{ // SAVE VIDEO TO GALLERY
                //                        }else{
                //                            self.localDB.updateLocalURL(msg_id: msgDict.value(forKey: "message_id") as! String, url:msgDict.value(forKey: "local_path") as! String)
                //                        }
                socketClass.sharedInstance.uploadChatVideo(fileData: attachData as Data, type: type, msg_id: msgDict.value(forKey: "message_id") as! String, requestDict: requestDict,blockedbyMe: nil,blockedMe: nil)
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
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
            thumbnail = requestDict.value(forKeyPath: "message_data.thumbnail") as? String ?? ""
        }else if type == "document"{
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
                             attachment: attach,thumbnail:thumbnail, read_count: readCount, statusData: "", blocked: "0")
        if msgDict.value(forKey: "local_path") != nil {
            
        }
        let unreadcount = localDB.getUnreadCount(contact_id: self.contact_id)
        self.localDB.addRecent(contact_id: self.contact_id, msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String, unread_count: "\(unreadcount)",time: requestDict.value(forKeyPath: "message_data.chat_time") as! String)
    }
    func fileUpload(name:String,docuData:Data,type:String)  {
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
        msgDict.setValue(name, forKey: "message")
//        self.uploadFiles(msgDict: msgDict, requestDict: requestDict, attachData: docuData, type:type , image: nil)
    }

}

