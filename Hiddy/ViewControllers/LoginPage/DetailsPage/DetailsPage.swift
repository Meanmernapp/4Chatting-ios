//
//  DetailsPage.swift
//  Hiddy
//
//  Created by APPLE on 08/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import AVFoundation
import Toast_Swift
import Contacts
import PhoneNumberKit


class DetailsPage: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate{

    @IBOutlet weak var aboutStackView: UIStackView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var subTitleLbl: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var usernameTF: FloatLabelTextField!
    @IBOutlet var aboutSepLbl: UILabel!
    @IBOutlet weak var abountLabel: UILabel!
    
    @IBOutlet weak var textViewHeightConst: NSLayoutConstraint!
    @IBOutlet var aboutTV: UITextView!
    let phoneNoArray = NSMutableArray()
    let contactStore = CNContactStore()
    let phoneNumberKit = PhoneNumberKit()
    var userDict = NSDictionary()
    var viewType = String()
    let imagePicker = UIImagePickerController()
    var imageView = PASImageView()
    var imageData = NSData()
    var imgChanged = Bool()
    let phoneContacts = NSMutableArray()
    var updateProfile = false
    
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    @IBOutlet var backIcon: UIImageView!
    @IBOutlet var backBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
//        self.textViewHeightConst.priority = .defaultHigh
        self.view.semanticContentAttribute = .forceLeftToRight

        // Do any additional setup after loading the view.
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.aboutTV.backgroundColor = .clear
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.wholeStackView.semanticContentAttribute = .forceRightToLeft
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.subTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.subTitleLbl.textAlignment = .right
            self.usernameTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.usernameTF.textAlignment = .right
            self.aboutSepLbl.textAlignment = .right
            self.aboutSepLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutTV.textAlignment = .right
            self.aboutTV.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.wholeStackView.alignment = .trailing
        }
        else {
            self.wholeStackView.semanticContentAttribute = .forceLeftToRight
            self.wholeStackView.alignment = .leading
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.subTitleLbl.transform = .identity
            self.subTitleLbl.textAlignment = .left
            self.usernameTF.transform = .identity
            self.usernameTF.textAlignment = .left
            self.aboutSepLbl.textAlignment = .left
            self.aboutSepLbl.transform = .identity
            self.aboutTV.textAlignment = .left
            self.aboutTV.transform = .identity
        }
        self.aboutTV.textContainerInset = UIEdgeInsets.zero
        self.aboutTV.textContainer.lineFragmentPadding = 0

    }
    override func viewDidDisappear(_ animated: Bool) {
//        UIApplication.shared.isStatusBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialSetup()  {
        self.loader.color = SECONDARY_COLOR
        
        self.imagePicker.delegate = self
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 25, align: .left, text: "profile_info")
        self.subTitleLbl.config(color: TEXT_SECONDARY_COLOR, size: 17, align: .left, text: "profile_des")
        self.usernameTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "usernameMind")
        self.aboutTV.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: "aboutMind")
        self.abountLabel.config(color: UIColor.lightGray, size: 17, align: .left, text: "aboutMind")
        self.usernameTF.titleFont = UIFont.init(name:APP_FONT_REGULAR, size: 17) ?? UIFont.systemFont(ofSize: 17)
        self.configFloatingBtn()
        if userDict.value(forKey: "user_image") != nil{
            self.profilePic.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(userDict.value(forKey: "user_image")!)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        self.profilePic.rounded()
        if self.userDict["user_name"] != nil{
            self.usernameTF.text = self.userDict.value(forKey: "user_name") as? String
        }
        
        if self.viewType != EDIT_VIEW{
            self.aboutTV.isHidden = true
            self.abountLabel.isHidden = true
            self.aboutSepLbl.isHidden = true
            self.backBtn.isHidden = true
            self.aboutStackView.isHidden = true
            self.backIcon.isHidden = true
//            UIApplication.shared.isStatusBarHidden = true
            self.subTitleLbl.config(color: TEXT_SECONDARY_COLOR, size: 17, align: .left, text: "profile_des")


        }else{
            setNeedsStatusBarAppearanceUpdate()
            self.aboutTV.text = UserModel.shared.userDict().value(forKey: "about") as? String ?? ""
            self.subTitleLbl.config(color: TEXT_SECONDARY_COLOR, size: 17, align: .left, text: "profile_des_Mind")

        }
        
        imageView = PASImageView(frame: self.profilePic.frame)
        imageView.backgroundProgressColor = .white
        imageView.progressColor = .red
//        self.view.addSubview(self.profilePic)
        }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    //config floating chat new btn
    func configFloatingBtn() {
        
        let actionButton = JJFloatingActionButton()
        if UIDevice.current.hasNotch{
        actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-120, width: 55, height: 55)
        }else{
        actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-90, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
   
        actionButton.buttonImage = #imageLiteral(resourceName: "next_arrow")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(goToChatPage), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    //floating btn action
    @objc func goToChatPage()  {
        if usernameTF.isEmpty() {
            self.usernameTF.setAsInvalidTF("enter_username", in: self.view)
        }else{
            self.usernameTF.setAsValidTF()
            loader.startAnimating()
            if self.viewType == EDIT_VIEW{
                if aboutTV.isEmpty() {
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "enter_about") as? String)
                }else{
                    if !updateProfile{
                        if self.imgChanged == true{
                            self.uploadProfilePicService(imageBase64:self.imageData as Data)
                        }else{
                            self.updateDetailsService()
                        }
                        updateProfile = true
                    }
                }
            }else{
//                self.loginService()
                if !updateProfile{
                    if self.imgChanged == true{
                        self.uploadLoginProfilePicService(imageBase64:self.imageData as Data)
                    }else{
                        self.loginService()
                    }
                    updateProfile = true
                }
                else {
                    self.loginService()
                }
            }
        }
    }
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func galleryPickBtnTapped(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: Utility.shared.getLanguage()?.value(forKey: "camera") as? String, style: .default) { (action) in
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                //already authorized
                self.moveToCamera()
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        //access allowed
                        self.moveToCamera()
                    } else {
                        //access denied
                        DispatchQueue.main.async {
                            self.cameraPermissionAlert()
                        }
                    }
                })
            }
        }
        let gallery = UIAlertAction(title: Utility.shared.getLanguage()?.value(forKey: "gallery") as? String, style: .default) { (action) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: Utility.shared.getLanguage()?.value(forKey: "cancel") as? String, style: .cancel)
        alertController.addAction(camera)
        alertController.addAction(gallery)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    //move to camera
    func moveToCamera()   {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .camera
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    //MARK:location restriction alert
    func cameraPermissionAlert(){
        AJAlertController.initialization().showAlert(aStrMessage: "camera_permission", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
            // print(index,title)
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profilePic.image = pickedImage
            self.imageData = pickedImage.jpegData(compressionQuality: 0)! as NSData//UIImageJPEGRepresentation(pickedImage, 0)! as NSData
            self.imgChanged = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Upload profile picture
    func uploadProfilePicService(imageBase64:Data)  {
        let upoloadObj = UploadServices()
        upoloadObj.uploadProfilePic(profileimage:imageBase64,user_id:self.userDict.value(forKey: "_id") as! String, onSuccess:{response in
            let status:NSString = response.value(forKey: "status") as! NSString
            if status.isEqual(to: STATUS_TRUE){
                let imageURL = "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(response.value(forKey: "user_image")!)"
                // Later
                self.imageView.imageURL(URL:URL.init(string: imageURL)!)
                UserModel.shared.setProfilePic(URL:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(response.value(forKey: "user_image")!)" as NSString)
                DispatchQueue.main.async{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "profile_pic_success") as? String)
                    let updateObj = UserWebService()
                    updateObj.updateProfile(user_name: self.usernameTF.text!, about: self.aboutTV.text!, onSuccess: {response in
                        let status:String = response.value(forKey: "status") as! String
                        if status == STATUS_TRUE{
                            UserModel.shared.setUserInfo(userDict: response)
                            self.navigationController?.popViewController(animated: true)
                            self.loader.stopAnimating()
                        }
                    })
                }
            }else{
                Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
            }
        })
    }
    func uploadLoginProfilePicService(imageBase64:Data)  {
        let upoloadObj = UploadServices()
        upoloadObj.uploadProfilePic(profileimage:imageBase64,user_id:self.userDict.value(forKey: "_id") as! String, onSuccess:{response in
            let status:NSString = response.value(forKey: "status") as! NSString
            if status.isEqual(to: STATUS_TRUE){
                let imageURL = "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(response.value(forKey: "user_image")!)"
                // Later
                self.imageView.imageURL(URL:URL.init(string: imageURL)!)
                UserModel.shared.setProfilePic(URL:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(response.value(forKey: "user_image")!)" as NSString)
                self.loginService()
            }else{
                Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
            }
        })
    }
    //login web service
    func loginService(){
        let loginObj = UserWebService()
        let countryCode = self.userDict.value(forKey: "country_code") as! NSNumber
        let phoneNo = self.userDict.value(forKey: "phone_no") as! NSNumber
        let currentLocale = NSLocale.current.regionCode
        loginObj.signUpService(user_name:usernameTF.text!, phone_no:String(describing: phoneNo) , country_code: String(describing: countryCode), country_name: currentLocale ?? "", onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                
                UserModel.shared.setUserInfo(userDict: response)
                socketClass.sharedInstance.connect()
                let storageObj =  LocalStorage()
                storageObj.createDB()
                storageObj.createTable()
                self.checkPermission()
                //get previous channels
                channelSocket.sharedInstance.getMyChannels()
                //get my groups
                groupSocket.sharedInstance.myGroups()
                let cc = response.value(forKey: "country_code") as! Int

                let localObj = LocalStorage()
                localObj.addContact(userid: response.value(forKey: "_id") as! String,
                                    contactName: "You",
                                    userName: response.value(forKey: "user_name") as! String,
                                    phone:String(describing: phoneNo) ,
                                    img: response.value(forKey: "user_image") as! String,
                                    about: response.value(forKey: "about") as? String ?? "",
                                    type:"0",
                                    mutual:"0",
                                    privacy_lastseen: response.value(forKey: "privacy_last_seen") as! String,
                                    privacy_about: response.value(forKey: "privacy_about") as! String,
                                    privacy_picture: response.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                self.loader.stopAnimating()
            }
        })
    }
    
    //Update details service
    func updateDetailsService(){
        let updateObj = UserWebService()
        updateObj.updateProfile(user_name: self.usernameTF.text!, about: self.aboutTV.text!, onSuccess: {response in
            
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                
                UserModel.shared.setUserInfo(userDict: response)
                self.navigationController?.popViewController(animated: true)
                self.loader.stopAnimating()
            }
        })
    }
    
    // uitextfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        let numLines = (textView.contentSize.height / (textView.font?.lineHeight ?? 0))
        
        // Check BackSpacee
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        }
        else if numberOfChars > 250 || Int(numLines) > 50{// per line 15 -> 34 lines & 500 chars
            textView.endEditing(true)
            print("\(numberOfChars) \(numLines)")
            self.view.makeToast("Only 250 Characters are allowed")
            return false
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.abountLabel.textColor = UIColor.darkGray
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.abountLabel.textColor = UIColor.lightGray
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.frame.height >= 100 {
            textViewHeightConst.constant = 100
            textViewHeightConst.priority = .defaultHigh
            textView.isScrollEnabled = true
        }
        else {
            textView.isScrollEnabled = false
            textViewHeightConst.constant = 45
            textViewHeightConst.priority = .defaultLow
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let full_string = textField.text!+string
        if full_string.containsEmoji(){
            return false
        }
        
        if textField.tag == 0 {
            if full_string.count>25{
                return false
            }
            var restrict = String()
            restrict = NAME_CHARACTERS
            if !string.isEmpty{
                let set = CharacterSet(charactersIn: restrict)
                let inverted = set.inverted
                let filtered = string.components(separatedBy: inverted).joined(separator: "")
                return filtered != string
            }else{
                return true
            }
        }else{
            if full_string.count>250{
                return false
            }
        }
        return true
    }
    //check contact access permission
    func checkPermission()  {
        requestForAccess { (accessGranted) in
            if accessGranted == true{
                DispatchQueue.main.async {
                    self.loader.startAnimating()
                }
                self.getContactFromAddressBook()
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
    //MARK:contact restriction alert
    func contactPermissionAlert()  {
        AJAlertController.initialization().showAlert(aStrMessage: "contact_permission", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
            // print(index,title)
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            else {
                self.goToHome()
            }
        })
    }
    //get all contact list
    func getContactFromAddressBook() {
        let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey]
        let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
        try? contactStore.enumerateContacts(with: request1) { (contact, error) in
            for people in contact.phoneNumbers  {
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

        // save my conatcts
        let userObj = UserWebService()
        userObj.saveContacts(contacts: self.phoneNoArray, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let localDB = LocalStorage()
                let localArray = localDB.getLocalPhoneNumbers()
                self.phoneNoArray.addObjects(from: localArray as! [Any])
                self.updateMyContacts()
            }
        })
        
    }
    func goToHome()  {
        socketClass.sharedInstance.disconnect()
        socketClass.sharedInstance.connect()
        let del = UIApplication.shared.delegate as! AppDelegate
        del.setHomeAsRootView()
    }
    func updateMyContacts()  {
        // print("PHONE NUMBER COUNT \(phoneNoArray.count)")
        if phoneNoArray.count == 0 {
            DispatchQueue.main.async {
                self.goToHome()
            }
        }else{
            let userObj = UserWebService()
            userObj.setContacts(contacts: self.phoneNoArray, onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    let tempArray = NSMutableArray()
                    tempArray.addObjects(from: (response.value(forKey: "result") as! NSArray) as! [Any])
                    let localObj = LocalStorage()
                    // print("MY CONTACTS COUNT \(tempArray.count)")
                    
                    for contactDict in tempArray {
                        let userDict:NSDictionary = contactDict as! NSDictionary
                        let phoneNo:NSNumber = userDict.value(forKey: "phone_no") as! NSNumber
                        var name = String()
                        let contactName = Utility.shared.searchPhoneNoAvailability(phoneNo: "\(phoneNo)")
                        if contactName == EMPTY_STRING{
                            name = "\(phoneNo)"
                        }else{
                            name = contactName
                        }
                        
                        var username = String()
                        let cc = userDict.value(forKey: "country_code") as! Int
                        
                        if userDict.value(forKey: "user_name") != nil {
                            username = userDict.value(forKey: "user_name") as! String
                        }else{
                            username = "+\(cc) " + "\(phoneNo)"
                        }
                        let type = String()
                        
                        localObj.addContact(userid: userDict.value(forKey: "_id") as! String,
                                            contactName: name, userName:username ,
                                            phone:String(describing: phoneNo) ,
                                            img: userDict.value(forKey: "user_image") as! String,
                                            about: userDict.value(forKey: "about") as? String,
                                            type:type,
                                            mutual:userDict.value(forKey: "contactstatus") as! String,
                                            privacy_lastseen: userDict.value(forKey: "privacy_last_seen") as! String,
                                            privacy_about: userDict.value(forKey: "privacy_about") as! String,
                                            privacy_picture: userDict.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                    }
                    self.goToHome()

                    Utility.shared.registerPushServices()
                }else if status == STATUS_FALSE{
                    DispatchQueue.main.async {
                        let message:String = response.value(forKey: "message") as! String
                        if message == "No contacts found"{
                            self.goToHome()
                            Utility.shared.registerPushServices()
                        }
                        self.loader.stopAnimating()
                    }
                }
            })
        }
        
    }
}
