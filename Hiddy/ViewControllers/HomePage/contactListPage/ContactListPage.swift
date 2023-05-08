//
//  ContactListPage.swift
//  Hiddy
//
//  Created by APPLE on 01/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import Contacts
import PhoneNumberKit

class ContactListPage: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,socketClassDelegate {
   
    @IBOutlet weak var groupIcon: UIImageView!
    @IBOutlet weak var lineView: UILabel!

    @IBOutlet weak var groupLbl: UILabel!
    let contactStore = CNContactStore()
    let phoneNoArray = NSMutableArray()
    let phoneContacts = NSMutableArray()

    var myContacts = NSMutableArray()
    var contactCopy = NSMutableArray()
    let phoneNumberKit = PhoneNumberKit()
    var isSearch = Bool()

    @IBOutlet var topView: UIView!
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var noLbl: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var barBtnView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    
    @IBOutlet var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initalSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshContact), name: Notification.Name("ContactRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestTimeOut), name: Notification.Name("RequestTimeOut"), object: nil)
        self.updateTheme()
        self.changeRTLView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    @objc func refreshContact() {
        DispatchQueue.main.async {
            let localObj = LocalStorage()
            self.myContacts = localObj.getContactList()
            self.checkAvailablity()
            self.loader.stopAnimating()
        }
    }

    @objc func requestTimeOut() {
        
        print("here called timed out")
        let alertController = UIAlertController(title: Utility.shared.getLanguage()?.value(forKey: "network_error1") as? String ?? "", message: Utility.shared.getLanguage()?.value(forKey: "neterror") as? String ?? "", preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: Utility.shared.getLanguage()?.value(forKey: "cancel") as? String ?? "", style: .cancel, handler: nil)
        let settingAction = UIAlertAction(title: Utility.shared.getLanguage()?.value(forKey: "setting") as? String ?? "", style: UIAlertAction.Style.default) {
            UIAlertAction in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addAction(settingAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            self.present(alertController, animated: true, completion: nil)
        }
        //UIApplication.shared.keyWindow?.rootViewController!.present(alertController, animated: true, completion: nil)
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
    //initial setup
    func initalSetup()  {
        self.loader.color = SECONDARY_COLOR
        self.topView.backgroundColor = BACKGROUND_COLOR
        self.navigationView.backgroundColor = BACKGROUND_COLOR
        self.lineView.backgroundColor = UIColor(named: "separetor_color")
        socketClass.sharedInstance.delegate = self
        isSearch = false
        self.navigationView.elevationEffect()
        self.contactTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 100, right: 0)
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "select_contact")
   
            let localObj = LocalStorage()
            self.myContacts = localObj.getContactList()
            self.contactCopy = localObj.getContactList()
            self.checkAvailablity()

        contactTableView.register(UINib(nibName: "createGroupCell", bundle: nil), forCellReuseIdentifier: "createGroupCell")
        self.searchTF.isHidden = true
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_contact")
        self.groupIcon.rounded()
        self.groupLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "create_group")
        self.backGroundRefresh()
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.checkAvailablity()

    }
    @IBAction func createGroupBtnTapped(_ sender: Any) {
        DispatchQueue.main.async {
            let groupObj =  createGroup()
            groupObj.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(groupObj, animated: true)
//            self.navigationController?.present(groupObj, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if isSearch {
            self.barBtnView.isHidden = false
            self.titleLbl.isHidden = false
            self.searchTF.isHidden = true
            self.searchTF.resignFirstResponder()
            self.isSearch =  false
            self.searchTF.text = ""
            contactTableView.isHidden = false
            myContacts = contactCopy.mutableCopy() as! NSMutableArray
            self.checkAvailablity()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        let menuArray:NSArray = ["\(Utility.shared.getLanguage()?.value(forKey: "refresh") as! String)"]
        var frame = CGRect.init(x: self.barBtnView.frame.origin.x+self.menuIcon.frame.origin.x, y: self.barBtnView.frame.origin.y+self.menuIcon.frame.origin.y, width: 11, height: 21)
        if UserModel.shared.getAppLanguage() == "عربى" {
            frame = CGRect(x: self.view.frame.origin.x + 5, y: self.menuBtn.frame.origin.y, width: self.menuBtn.frame.width, height: self.menuBtn.frame.height)
        }
        let menu = FTPopOverMenuConfiguration()
//        menu.textColor =  TEXT_PRIMARY_COLOR
        FTPopOverMenu.show(fromSenderFrame:frame , withMenuArray: menuArray as? [Any], doneBlock: { selectedIndex in
                if selectedIndex == 0{
                    Contact.sharedInstance.isAlreadyLoaded = false
                    self.loader.startAnimating()
                    self.backGroundRefresh()
                }
            }, dismiss: {
                
            })
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
    
    func refreshContactList()  {
        self.checkPermission()
    }
    
    /*
     //old
    //check contact access permission
    func checkPermission()  {
        requestForAccess { (accessGranted) in
            if accessGranted == true{
                self.getContactFromAddressBook()
            }
        }
    }
    */
    
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
    
    //get all contact list
    func getContactFromAddressBook() {
        self.phoneNoArray.removeAllObjects()
        self.phoneContacts.removeAllObjects()
        
        let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey]
        let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
        try? contactStore.enumerateContacts(with: request1) { (contact, error) in
            for people in contact.phoneNumbers {
                // Whatever you want to do with it
                let phoneStr = people.value.stringValue.replacingOccurrences(of: "-", with:"")

                do {
                    let currentLocale = Locale.current.regionCode
                    let phoneNumber = try self.phoneNumberKit.parse(phoneStr, withRegion: currentLocale ?? "GB", ignoreType: true)
                    self.phoneNoArray.add(phoneNumber.nationalNumber)
                    let dict = ["phone_no":"\(phoneNumber.nationalNumber)","contact_name":"\(contact.givenName)"]
                    self.phoneContacts.add(dict)
                }
                catch {
                    let numberSet = CharacterSet(charactersIn: "0123456789")
                    if phoneStr.rangeOfCharacter(from: numberSet.inverted) != nil {
                        print("string contains special characters")
                    }else{
                        if phoneStr.length > 5 {
                            self.phoneNoArray.add(phoneStr)
                            let dict = ["phone_no":"\(phoneStr)","contact_name":"\(contact.givenName)"]
                            self.phoneContacts.add(dict)
                        }
                    }
                }
            }
        }
        UserModel.shared.setAllContacts(contacts: self.phoneContacts as! [[String : String]])

        if self.phoneNoArray.count != 0{
        let userObj = UserWebService()
        userObj.setContacts(contacts: self.phoneNoArray, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let tempArray = NSMutableArray()
                let localObj = LocalStorage()
                let previousArray = localObj.getContactList()
                tempArray.addObjects(from: previousArray as! [Any])
                tempArray.addObjects(from: (response.value(forKey: "result") as! NSArray) as! [Any])
                self.addToDB(contact: tempArray)
            }
        })
        }
    }
    
    //add contat to local db
    func addToDB(contact:NSMutableArray)  {
        let localObj = LocalStorage()
        for contactDict in contact {
            let userDict:NSDictionary = contactDict as! NSDictionary
            var phoneNo = String()
            var userID =  String()
            var about =  String()
            var mutual_status = String()
            var privacy_lastseen = String()
            var privacy_image =  String()
            
            if userDict.value(forKey: "phone_no") != nil{
                let phone:NSNumber = userDict.value(forKey: "phone_no") as! NSNumber
                phoneNo = "\(phone)"
                userID = userDict.value(forKey: "_id") as! String
                about = (userDict.value(forKey: "about") as? String ?? "")
                mutual_status = userDict.value(forKey: "contactstatus") as! String
                privacy_lastseen = userDict.value(forKey: "privacy_last_seen") as! String
                privacy_image = userDict.value(forKey: "privacy_profile_image") as! String

            }else{
                phoneNo = userDict.value(forKey: "user_phoneno") as! String
                userID = userDict.value(forKey: "user_id") as! String
                about =  (userDict.value(forKey: "user_aboutus") as? String)!
                mutual_status = userDict.value(forKey: "mutual_status") as! String
                privacy_lastseen = userDict.value(forKey: "privacy_lastseen") as! String
                privacy_image = userDict.value(forKey: "privacy_image") as! String

            }
            DispatchQueue.global(qos: .background).async{
                var name = String()
                var contactName =  String()

                DispatchQueue.main.async {
                    contactName = Utility.shared.searchPhoneNoAvailability(phoneNo: phoneNo)
                    let cc = userDict.value(forKey: "country_code") as? UInt64 ?? (91)
                    print("contact name \(contactName)")
                    if contactName == EMPTY_STRING{
                        name = "+\(cc) " + "\(phoneNo)"
                    }else{
                        name = contactName
                    }

                    let type = String()
                    localObj.addContact(userid: userID,
                                        contactName: name,
                                        userName: userDict.value(forKey: "user_name") as? String ?? "",
                                        phone:String(describing: phoneNo) ,
                                        img: userDict.value(forKey: "user_image") as? String ?? "",
                                        about: about,
                                        type:type,
                                        mutual:mutual_status,
                                        privacy_lastseen: privacy_lastseen,
                                        privacy_about: userDict.value(forKey: "privacy_about") as! String,
                                        privacy_picture: privacy_image, countryCode: String(cc))
                }
            }
        }
//        self.myContacts = localObj.getContactList()
//        self.checkAvailablity()
//        self.loader.stopAnimating()
        
        //Utility.shared.checkDeletedList()
        Utility.shared.checkDeletedList({ [weak self] success in
            
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.myContacts = localObj.getContactList()
            self.checkAvailablity()
            self.loader.stopAnimating()
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return myContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupCell", for: indexPath) as! createGroupCell

        if myContacts.count != 0 {
        let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
        cell.selectionView.isHidden = true
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
        self.searchTF.resignFirstResponder()
        let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
        let detailObj = ChatDetailPage()
        detailObj.contact_id = contactDict.value(forKey: "user_id") as! String
        detailObj.viewType = "0"
        self.navigationController?.pushViewController(detailObj, animated: true)
    }
  
    //profile popup
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        var profileDict = NSDictionary()
        profileDict = self.myContacts.object(at: sender.tag) as! NSDictionary
        let popup = ProfilePopup()
        popup.profileDict = profileDict
        popup.barType = "1"
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popup, animated: false, completion: nil)
    }
    
    //MARK: Textfield delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        contactTableView.isHidden = false
        myContacts = contactCopy.mutableCopy() as! NSMutableArray
        self.checkAvailablity()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("print count \(myContacts.count)")
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
    //background refresh action
    func backGroundRefresh()  {
        DispatchQueue.global(qos: .background).async {
            self.refreshContactList()
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
    
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "makeprivate" || type == "changeuserimage"{
            let localObj = LocalStorage()
            self.myContacts = localObj.getContactList()
            self.contactCopy = localObj.getContactList()
            self.checkAvailablity()
        }
    }
    
   
}
