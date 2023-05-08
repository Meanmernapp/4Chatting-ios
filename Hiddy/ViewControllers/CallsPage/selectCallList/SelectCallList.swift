//
//  SelectCallList.swift
//  Hiddy
//
//  Created by APPLE on 30/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//



import UIKit
import Contacts

class SelectCallList: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,picPopUpDelegate {
    
    let phoneNoArray = NSMutableArray()
    var myContacts = NSMutableArray()
    var contactCopy = NSMutableArray()
    let contactStore = CNContactStore()
    let phoneContacts = NSMutableArray()
    var isSearch = Bool()
    var callDB = CallStorage()
    
    @IBOutlet var noView: UIView!
    @IBOutlet var noLbl: UILabel!
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var contactTableView: UITableView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var barBtnView: UIView!
    @IBOutlet var searchTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initalSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.updateTheme()
        
        self.changeRTLView()
//        if contactPermissionApproved == false {
//            contactPermissionAlert()
//        }
    }
    
    func contactPermissionAlert()  {
        AJAlertController.initialization().showAlert(aStrMessage: "contact_permission_again", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        })
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
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.noLbl.transform = .identity
            // self.noLbl.textAlignment = .left
            self.searchTF.transform = .identity
            self.searchTF.textAlignment = .left
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
    func initalSetup() {
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.contactTableView.backgroundColor = BACKGROUND_COLOR
        
        isSearch = false
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "select_contact")
        let localObj = LocalStorage()
        self.myContacts = localObj.getContactList()
        self.contactCopy = localObj.getContactList()
        self.checkAvailablity()
        self.backGroundRefresh()
        contactTableView.register(UINib(nibName: "SelectCallCell", bundle: nil), forCellReuseIdentifier: "SelectCallCell")
        self.searchTF.isHidden = true
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_contact")
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func backGroundRefresh()  {
        DispatchQueue.global(qos: .background).async {
            self.refreshContactList()
        }
    }
    func refreshContactList()  {
        self.checkPermission()
    }
    
    //check contact access permission
    func checkPermission()  {
        requestForAccess { (accessGranted) in
            if accessGranted == true{
                self.phoneNoArray.removeAllObjects()
                self.phoneContacts.removeAllObjects()
                DispatchQueue.main.async {
                        Contact.sharedInstance.synchronize()
                }
            }
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
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if isSearch {
            self.searchTF.resignFirstResponder()
            self.barBtnView.isHidden = false
            self.titleLbl.isHidden = false
            self.searchTF.isHidden = true
            self.isSearch =  false
            contactTableView.isHidden = false
            myContacts = contactCopy.mutableCopy() as! NSMutableArray
            self.checkAvailablity()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
            self.searchTF.isHidden = false
            self.barBtnView.isHidden = true
            self.titleLbl.isHidden = true
            self.isSearch =  true
            self.searchTF.becomeFirstResponder()
        }, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.myContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCallCell", for: indexPath) as! SelectCallCell
        if myContacts.count != 0 {
            
            let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
            cell.config(contactDict:contactDict)
            cell.profileBtn.tag = indexPath.row
            cell.callBtn.tag = indexPath.row
            cell.videoBtn.tag = indexPath.row
            cell.callBtn.addTarget(self, action: #selector(makeAudioCall), for: .touchUpInside)
            cell.videoBtn.addTarget(self, action: #selector(makeVideoCall), for: .touchUpInside)
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
        self.searchTF.resignFirstResponder()
        /*     let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
         let detailObj = ChatDetailPage()
         detailObj.contact_id = contactDict.value(forKey: "user_id") as! String
         detailObj.viewType = "0"
         self.navigationController?.pushViewController(detailObj, animated: true)*/
    }
    
    //profile popup
    @objc func makeAudioCall(_ sender: UIButton!)  {
        if Utility.shared.isConnectedToNetwork() {
            var profileDict = NSDictionary()
            profileDict = self.myContacts.object(at: sender.tag) as! NSDictionary
            let blockByMe = profileDict.value(forKey: "blockedByMe") as! String
            let user_id = profileDict.value(forKey: "user_id") as! String
            if blockByMe == "1"{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
            }else{
                DispatchQueue.main.async {
                    let random_id = Utility.shared.random()
                    let pageobj = CallPage()
                    pageobj.receiverId = user_id
                    pageobj.senderFlag = true
                    pageobj.random_id = random_id
                    pageobj.call_type = "audio"
                    pageobj.userdict = profileDict
                    pageobj.modalPresentationStyle = .fullScreen
                    self.callDB.addNewCall(call_id: random_id, contact_id: user_id, status: "outgoing", call_type: "audio", timestamp: Utility.shared.getTime(), unread_count: "0")
                    self.present(pageobj, animated: true, completion: nil)
                }
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    //profile popup
    @objc func makeVideoCall(_ sender: UIButton!)  {
        if Utility.shared.isConnectedToNetwork() {
            
            var profileDict = NSDictionary()
            profileDict = self.myContacts.object(at: sender.tag) as! NSDictionary
            let blockByMe = profileDict.value(forKey: "blockedByMe") as! String
            let user_id = profileDict.value(forKey: "user_id") as! String
            if blockByMe == "1"{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
            }else{
                let random_id = Utility.shared.random()
                let pageobj = CallPage()
                pageobj.receiverId = user_id
                pageobj.random_id = random_id
                pageobj.senderFlag = true
                pageobj.call_type = "video"
                pageobj.userdict = profileDict
                pageobj.modalPresentationStyle = .fullScreen
                self.callDB.addNewCall(call_id: random_id, contact_id: user_id, status: "outgoing", call_type: "video", timestamp: Utility.shared.getTime(), unread_count: "0")
                self.present(pageobj, animated: true, completion: nil)
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //profile popup
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        var profileDict = NSDictionary()
        profileDict = self.myContacts.object(at: sender.tag) as! NSDictionary
        let popup = ProfilePopup()
        popup.profileDict = profileDict
        popup.delegate = self
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
    
    func popupDismissed() {
        //socketClass.sharedInstance.delegate =  self
    }
    
    //MARK: Textfield delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        contactTableView.isHidden = false
        myContacts = contactCopy.mutableCopy() as! NSMutableArray
        self.checkAvailablity()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if contactCopy.count == 0 {
        } else {
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

