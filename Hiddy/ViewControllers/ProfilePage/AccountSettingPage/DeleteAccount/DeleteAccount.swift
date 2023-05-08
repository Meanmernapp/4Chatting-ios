//
//  DeleteAccount.swift
//  Hiddy
//
//  Created by APPLE on 15/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class DeleteAccount: UIViewController,alertDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var deleteLbl: UILabel!
    
    @IBOutlet var deleteAcLbl: UILabel!
    @IBOutlet var acDot: UILabel!
    @IBOutlet var msgDot: UILabel!
    @IBOutlet var groupDot: UILabel!
    
    @IBOutlet var deleteGroupLbl: UILabel!
    @IBOutlet var deleteMsgLbl: UILabel!
    @IBOutlet var navigationCutomView: UIView!
   
    let groupDB = groupStorage()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.updateTheme()
        self.navigationCutomView.backgroundColor = BOTTOM_BAR_COLOR
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.deleteLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.deleteLbl.textAlignment = .right
            self.deleteGroupLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.deleteGroupLbl.textAlignment = .right
            self.deleteAcLbl.textAlignment = .right
            self.deleteAcLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.deleteMsgLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.deleteMsgLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.deleteLbl.transform = .identity
            self.deleteLbl.textAlignment = .left
            self.deleteGroupLbl.transform = .identity
            self.deleteGroupLbl.textAlignment = .left
            self.deleteMsgLbl.textAlignment = .left
            self.deleteMsgLbl.transform = .identity
            self.deleteAcLbl.transform = .identity
            self.deleteAcLbl.textAlignment = .left            
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func initialSetup()  {
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "delete_ac")
        if UIDevice.current.hasNotch{
//            self.titleLbl.frame = CGRect(x: self.titleLbl.frame.origin.x, y: self.titleLbl.frame.origin.y, width: self.titleLbl.frame.width, height: 37)
            self.navigationCutomView.frame = CGRect(x: self.navigationCutomView.frame.origin.x, y: self.navigationCutomView.frame.origin.y, width: self.navigationCutomView.frame.width, height:70)
        }
        self.deleteLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "delete_will")
        acDot.cornerRadius()
        acDot.backgroundColor = .lightGray
        groupDot.cornerRadius()
        groupDot.backgroundColor = .lightGray
        msgDot.cornerRadius()
        msgDot.backgroundColor = .lightGray
        deleteAcLbl.config(color: TEXT_TERTIARY_COLOR, size: 18, align:.left, text: "delete_ac_des")
        deleteMsgLbl.config(color: TEXT_TERTIARY_COLOR, size: 18, align:.left, text: "delete_msg_des")
        deleteGroupLbl.config(color: TEXT_TERTIARY_COLOR, size: 18, align:.left, text: "delete_group_des")
        self.configFloatingBtn()
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
        actionButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    
    //floating btn action
    @objc func deleteAccount(){
        let alert = CustomAlert()
        alert.msg = "delete_sure"
        alert.viewType = "1"
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
 
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func alertActionDone(type: String) {
        let groupArray = groupDB.getGroupList()
        // print("group array \(groupArray)")
        for group in groupArray{
            let dict:NSDictionary = group as! NSDictionary
            self.notifyExitToGroup(group: dict)
        }
        let deleteObj = GroupServices()
        deleteObj.deleteAccount(onSuccess: {response in
            let status:NSString = response.value(forKey: "status") as! NSString
            if status.isEqual(to: STATUS_TRUE){
                self.logoutUser()
            }
        })
    }
  
    //exit group
    func notifyExitToGroup(group:NSDictionary)  {
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
        msgDict.setValue("Member Left", forKey: "message")
        msgDict.setValue("left", forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        self.groupDB.removeMember(member_key: "\(group_id)\(UserModel.shared.userID()!)")
        if !groupDB.checkGroupMember(group_id: group_id) {
            self.makeSomeOneAsAdmin(group_id:group_id)
        }
        groupSocket.sharedInstance.exitGroup(group_id: group_id, user_id: UserModel.shared.userID()! as String, msgDict: msgDict)
        socketClass.sharedInstance.goLive()
    }
    
    //make  admin
    func makeSomeOneAsAdmin(group_id:String)  {
        let membersArray = groupDB.getGroupMembers(group_id: group_id)
        // print("member array \(membersArray)")
        if membersArray.count != 0 {            
        let newAdminDict:NSDictionary = membersArray.object(at: 0) as! NSDictionary
        let member_id = newAdminDict.value(forKey: "member_id") as! String
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(newAdminDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(newAdminDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(newAdminDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(member_id, forKey: "member_id")
        msgDict.setValue(member_id, forKey: "group_admin_id")
        msgDict.setValue("Admin", forKey: "message")
        msgDict.setValue("admin", forKey: "message_type")
        msgDict.setValue("1", forKey: "attachment")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        groupDB.makeAdmin(member_key: "\(group_id)\(member_id)",status:"1")
        }
    }

    

     //MARK: logout user
     func logoutUser(){
        socketClass.sharedInstance.disconnect()
         //remove badge count
         UIApplication.shared.applicationIconBadgeNumber = 0
    
         // clear local cache from nsuserdefault
        if let defaults = UserDefaults(suiteName: NOTIFICATION_EXTENSION) {
            defaults.removeObject(forKey: "user_id")
        }
         UserDefaults.standard.removeObject(forKey: "push_register")
         UserDefaults.standard.removeObject(forKey: "contact_ids")
         UserDefaults.standard.removeObject(forKey: "user_id")
         UserDefaults.standard.removeObject(forKey: "user_dict")
         UserDefaults.standard.removeObject(forKey: "user_accessToken")
         UserDefaults.standard.removeObject(forKey: "user_password")
         UserDefaults.standard.removeObject(forKey: "user_profilepic")
         UserDefaults.standard.removeObject(forKey: "tab_index")
         UserDefaults.standard.removeObject(forKey: "notify_groupid")
         UserDefaults.standard.removeObject(forKey: "notify_privateid")
         UserDefaults.standard.removeObject(forKey: "notify_channelid")
         UserDefaults.standard.removeObject(forKey: "user_accessToken")
         UserDefaults.standard.removeObject(forKey: "group_ids")
         UserDefaults.standard.removeObject(forKey: "channel_ids")
         UserDefaults.standard.removeObject(forKey: "date_Sticky")
         UserDefaults.standard.removeObject(forKey: "privacy_last_seen")
         UserDefaults.standard.removeObject(forKey: "privacy_profile_image")
         UserDefaults.standard.removeObject(forKey: "privacy_about")
         UserDefaults.standard.removeObject(forKey: "user_lastseen")
         UserDefaults.standard.removeObject(forKey: "user_profile_name")
         UserDefaults.standard.removeObject(forKey: "user_profile_no")
         UserDefaults.standard.removeObject(forKey: "user_profilePic_status")
         UserDefaults.standard.removeObject(forKey: "socket_handler")
         UserDefaults.standard.removeObject(forKey: "user_about_status")
         UserDefaults.standard.removeObject(forKey: "chat_listen")
         UserDefaults.standard.removeObject(forKey: "push_register")
         UserDefaults.standard.removeObject(forKey: "home_listen")
        
        
         //delte db
         let localObj = LocalStorage()
         let path = DBConfig().filePath()
         let fm = FileManager.default
         do {
             try fm.removeItem(atPath:path)
         } catch  {
             // print("error deleting file")
         }
         localObj.createDB()
         localObj.createTable()
         
         if #available(iOS 9.0, *) {
             let welcomeObj = LoginPage()
             let appDelegate = UIApplication.shared.delegate as! AppDelegate
             appDelegate.setInitialViewController(initialView: welcomeObj)
         }
     }
     
}
