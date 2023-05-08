//
//  ChangeNumber.swift
//  Hiddy
//
//  Created by APPLE on 15/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import PhoneNumberKit
import FirebaseUI

class ChangeNumber: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate {
    let groupDB = groupStorage()

    var enableSendToFacebook = Bool()
    var enableGetACall = Bool()
    let actionButton = JJFloatingActionButton()
    var verified = Bool()
    var noType = String()
    @IBOutlet var navigationView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var desLbl: UILabel!
    @IBOutlet var countryCodeTF: FloatLabelTextField!
    @IBOutlet var phoneTF: FloatLabelTextField!
    let authUI = FUIAuth.defaultAuthUI()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        authUI?.delegate = self

        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
            ]
        self.authUI?.providers = providers
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        setNeedsStatusBarAppearanceUpdate()
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.desLbl.textAlignment = .right
            self.desLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.countryCodeTF.textAlignment = .right
            self.countryCodeTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.phoneTF.textAlignment = .right
            self.phoneTF.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.desLbl.textAlignment = .left
            self.desLbl.transform = .identity
            self.countryCodeTF.textAlignment = .left
            self.countryCodeTF.transform = .identity
            self.phoneTF.textAlignment = .left
            self.phoneTF.transform = .identity
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func initialSetup()  {
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
            ]
        self.authUI?.providers = providers

        verified = false
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "change_no")
        if UIDevice.current.hasNotch{
//            self.titleLbl.frame = CGRect(x: self.titleLbl.frame.origin.x, y: self.titleLbl.frame.origin.y, width: self.titleLbl.frame.width, height: 32)
            self.navigationView.frame = CGRect(x: self.navigationView.frame.origin.x, y: self.navigationView.frame.origin.y, width: self.navigationView.frame.width, height:70)
        }
        self.desLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "change_no_des")
        self.countryCodeTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "country_code")
        self.phoneTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "phone_no")
        self.configFloatingBtn()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
            tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }

    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: actionButton) == true {
            return false
        }
        return true
    }
    
    //config floating chat new btn
    func configFloatingBtn()  {
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
        actionButton.addTarget(self, action: #selector(changeNewNumber), for: .touchUpInside)
        view.addSubview(actionButton)
        view.bringSubviewToFront(actionButton)
    }
    //dismiss keyboard & attachment menu
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        phoneTF.resignFirstResponder()
        countryCodeTF.resignFirstResponder()
    }
    
  
    //floating btn action
    @objc func changeNewNumber(){
        if countryCodeTF.isEmpty() {
            self.countryCodeTF.setAsInvalidTF("enter_countrycode", in: self.view)
        }else if phoneTF.isEmpty() {
            self.countryCodeTF.setAsValidTF()
            self.phoneTF.setAsInvalidTF("enter_phone", in: self.view)
        }else{
            self.countryCodeTF.setAsValidTF()
            self.phoneTF.setAsValidTF()
            let verifyObj = UserWebService()
            verifyObj.verfifyNo(phone_no: self.phoneTF.text!, onSuccess: {response in
                let status:NSString = response.value(forKey: "status") as! NSString
                if status.isEqual(to: STATUS_TRUE){
                    self.firebaseLogOut()
                    self.firebaseLogin()
                }else if status.isEqual(to: STATUS_FALSE){
                    let msg:String = response.value(forKey: "message") as! String
                    Utility.shared.showAlert(msg: msg)
                }
            })
        }
    }
    
    
    // uitextfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let full_string = textField.text!+string
        if textField.tag == 0 {
            let set = NSCharacterSet.init(charactersIn:COUNTRY_PREDICT)
            let characterSet = CharacterSet(charactersIn: string)
            if full_string.count>4{
                return false
            }
            return set.isSuperset(of: characterSet)
        }else{
            let set = NSCharacterSet.init(charactersIn:NUMERIC_PREDICT)
            let characterSet = CharacterSet(charactersIn: string)
            if full_string.count>10{
                return false
            }
            return set.isSuperset(of: characterSet)
        }
    }
    
    //MARK: move to phone number verification page
    func firebaseLogin() {
        let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
        
        phoneProvider.signIn(withPresenting: self, phoneNumber: self.phoneTF.text!)
    }
        
    func notifyAllGroup()  {
        let groupArray = groupDB.getGroupList()
        for group in groupArray{
            let dict:NSDictionary = group as! NSDictionary
            self.notifyToGroup(group: dict)
        }
        self.view.makeToast(Utility.shared.getLanguage()?.value(forKeyPath: "phone_mismatched") as? String)
        self.navigationController?.popViewController(animated: true)
    }
    //change number group
    func notifyToGroup(group:NSDictionary)  {
        let group_id:String = group.value(forKey: "group_id") as! String
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
        msgDict.setValue("Changed their number to new number. Tap to add contact", forKey: "message")
        msgDict.setValue("change_number", forKey: "message_type")
        msgDict.setValue(memberDict.value(forKey: "member_no"), forKey: "attachment")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        msgDict.setValue(self.countryCodeTF.text!, forKey: "contact_country_code")
        msgDict.setValue(self.phoneTF.text!, forKey: "contact_phone_no")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        
       
    }
}
extension ChangeNumber: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print(error?.localizedDescription ?? "")
        if error == nil {
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumbers = try phoneNumberKit.parse(authDataResult?.user.phoneNumber ?? "")

                let changeObj = UserWebService()
                changeObj.changePhoneNo(phone_no: "\(phoneNumbers.nationalNumber)",country_code: "\(phoneNumbers.countryCode)", onSuccess: {response in
                    let status:NSString = response.value(forKey: "status") as! NSString
                    if status.isEqual(to: STATUS_TRUE){
                        self.notifyAllGroup()
                    }
                    else {
                        let message:NSString = response.value(forKey: "message") as! NSString
                        self.view.makeToast("\(message)")
                    }
                })
            }
            catch {
                print("Generic parser error")
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
    func firebaseLogOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }
    
}
