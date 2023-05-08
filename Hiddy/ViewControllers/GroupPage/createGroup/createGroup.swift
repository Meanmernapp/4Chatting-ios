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
protocol addmemberdelegate {
    func dismissMemberView()
}
class createGroup: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
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
    var delegate:addmemberdelegate?
    
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var contactTableView: UITableView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var barBtnView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var selectedCollectionView: UICollectionView!
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet weak var noView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initalSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        
        setNeedsStatusBarAppearanceUpdate()
        if self.selectedContacts.count != 0 {
            let top = self.topView.frame.origin.y+self.topView.frame.size.height
            self.bottomView.frame = CGRect.init(x: 0, y: top, width: FULL_WIDTH, height: FULL_HEIGHT-top)
        }
        contactTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0); //values
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            // self.noLbl.textAlignment = .right
            self.searchTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.textAlignment = .right
            self.countLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.countLbl.textAlignment = .right
            self.selectedCollectionView.semanticContentAttribute = .forceLeftToRight
        }
        else {
            self.selectedCollectionView.semanticContentAttribute = .unspecified
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.noLbl.transform = .identity
            // self.noLbl.textAlignment = .left
            self.searchTF.transform = .identity
            self.searchTF.textAlignment = .left
            self.countLbl.transform = .identity
            self.countLbl.textAlignment = .left
        }
    }
    //    override var preferredStatusBarStyle : UIStatusBarStyle {
    //        return
    //    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //initial setup
    func initalSetup()  {
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.topView.backgroundColor = BACKGROUND_COLOR
        self.contactTableView.backgroundColor = BACKGROUND_COLOR
        self.selectedCollectionView.backgroundColor = BACKGROUND_COLOR
        self.bottomView.backgroundColor = BACKGROUND_COLOR
        
        isSearch = false
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "create_group")
        self.countLbl.config(color: TEXT_TERTIARY_COLOR, size: 15, align: .left, text: EMPTY_STRING)
        
        let localObj = LocalStorage()
        if viewType == "1" {
            let array = localObj.getContactList()
            for member in array{
                let memberDict:NSDictionary = member as! NSDictionary
                let user_id:String = memberDict.value(forKey: "user_id") as! String
                if !self.previousID.contains(user_id){
                    self.myContacts.add(memberDict)
                    self.contactCopy.add(memberDict)
                }
            }
            self.checkAvailablity()
        }else{
            self.myContacts = localObj.getContactList()
            self.contactCopy = localObj.getContactList()
            self.checkAvailablity()
        }
        self.searchTF.isHidden = true
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .center, text: "no_contact")
        
        contactTableView.register(UINib(nibName: "createGroupCell", bundle: nil), forCellReuseIdentifier: "createGroupCell")
        selectedCollectionView.register(UINib(nibName: "selectedCell", bundle: nil), forCellWithReuseIdentifier: "selectedCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        selectedCollectionView.collectionViewLayout = flowLayout
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
    
    //floating btn action
    @objc func groupCreationTapped()  {
        if Utility.shared.isConnectedToNetwork() {
            let groupDB = groupStorage()
            if selectedId.count == 0{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "select_one") as? String)
            }else{
                if self.viewType == "1"{
                    let total_count = self.previousID.count + self.selectedContacts.count
                    if total_count <= 50{
                        let memberArray = NSMutableArray()
                        for contact in self.selectedContacts{
                            let dict:NSDictionary = contact as! NSDictionary
                            let memberDict = NSMutableDictionary()
                            memberDict.setValue(dict.value(forKey: "user_id"), forKey: "member_id")
                            memberDict.setValue(dict.value(forKey: "user_phoneno"), forKey: "member_no")
                            memberDict.setValue("0", forKey: "member_role")
                            memberArray.add(memberDict)
                            groupDB.addGroupMembers(group_id: group_id, member_id: dict.value(forKey: "user_id") as! String, member_role: "0")
                        }
                        let newMember = GroupServices()
                        newMember.addNewMembers(group_id: group_id, members: memberArray, onSuccess: {response in
                            let status:NSString = response.value(forKey: "status") as! NSString
                            if status.isEqual(to: STATUS_TRUE){
                                self.notifyAddMembersToGroup(memberArray: memberArray)
                                self.delegate?.dismissMemberView()
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }else{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "max_limit") as? String)
                    }
                }else{
                    if self.selectedContacts.count <= 50{
                        let groupObj =  GroupInfoPage()
                        groupObj.selectedId = self.selectedId
                        groupObj.modalPresentationStyle = .fullScreen
                        groupObj.selectedContacts = self.selectedContacts
                        //                self.dismiss(animated: false, completion: {
                        //                    UIApplication.shared.keyWindow?.rootViewController?.present(groupObj, animated: false, completion: nil)
                        self.navigationController?.pushViewController(groupObj, animated: true)
                    }else{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "max_limit") as? String)
                    }
                }
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
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
            contactTableView.isHidden = false
            myContacts = contactCopy.mutableCopy() as! NSMutableArray
            self.checkAvailablity()
            self.searchTF.resignFirstResponder()
        }else{
            if viewType == "1" {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
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
        let blockedMe = contactDict.value(forKey: "blockedByMe") as! String
        let isDeleted = contactDict.value(forKey: "isDelete") as! String
        if isDeleted == "0"{
            if blockedMe == "0"{
                let cell = view.viewWithTag(indexPath.row+100) as? createGroupCell
                if self.selectedId.contains(user_id) {
                    self.selectedId.remove(user_id)
                    cell?.selectionView.backgroundColor = BACKGROUND_COLOR
                    cell?.selectionView.removeGrandient()
                    self.selectedContacts.remove(contactDict)
                } else {
                    self.selectedId.add(user_id)
                    cell?.selectionView.applyGradient()
                    self.selectedContacts.add(contactDict)
                }
                self.checkSelectionStatus()
            }else{
                self.searchTF.resignFirstResponder()
                let contact_name = contactDict.value(forKey: "contact_name") as! String
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "could_not_add"))!) \(contact_name)")
            }
        }else{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "deleted_account"))!)")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = BACKGROUND_COLOR
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 12, width:
                                                    tableView.bounds.size.width, height: 20))
        headerLabel.font = UIFont(name: APP_FONT_REGULAR, size: 20)
        headerLabel.textColor = TEXT_PRIMARY_COLOR
        headerLabel.text = Utility.shared.getLanguage()?.value(forKey: "add_peoples") as? String
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    func checkSelectionStatus()  {
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            if self.selectedContacts.count == 0 {
                self.topView.isHidden = true
                self.bottomView.frame = CGRect.init(x: 0, y: self.navigationView.frame.size.height+2, width: FULL_WIDTH, height: FULL_HEIGHT)
            }else{
                self.topView.isHidden = false
                let top = self.topView.frame.origin.y+self.topView.frame.size.height
                self.bottomView.frame = CGRect.init(x: 0, y: top, width: FULL_WIDTH, height: FULL_HEIGHT-top)
                self.selectedCollectionView.reloadData()
            }
            self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
            
        }, completion: nil)
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
    
    //MARK: Textfield delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        contactTableView.isHidden = false
        myContacts = contactCopy.mutableCopy() as! NSMutableArray
        self.checkAvailablity()
        self.searchTF.resignFirstResponder()
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
            self.contactTableView.reloadData()
            self.noView.isHidden = true
        }
        
    }
    
    //MARK: Collection view delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedCell", for: indexPath) as! selectedCell
        let userDict:NSDictionary =  selectedContacts.object(at: indexPath.row) as! NSDictionary
        cell.config(contactDict: userDict,type:"user")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userDict:NSDictionary =  selectedContacts.object(at: indexPath.row) as! NSDictionary
        let user_id :String = userDict.value(forKey: "user_id") as! String
        self.selectedContacts.remove(userDict)
        self.selectedId.remove(user_id)
        self.contactTableView.reloadData()
        self.checkSelectionStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    
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

