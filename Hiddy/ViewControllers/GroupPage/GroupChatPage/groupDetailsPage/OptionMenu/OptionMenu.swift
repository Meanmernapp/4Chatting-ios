//
//  OptionMenu.swift
//  Hiddy
//
//  Created by APPLE on 27/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

protocol optionDelegate {
    func dismissWith(type:String)
}
class OptionMenu: UIViewController,UITableViewDelegate,UITableViewDataSource,alertDelegate,UIGestureRecognizerDelegate,CNContactPickerDelegate,CNContactViewControllerDelegate {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var menuTableView: UITableView!
    var menuArray = NSMutableArray()
    var memberDict = NSDictionary()
    var viewType = String()
    var group_id = String()
    var member_role = String()
    var member_id = String()
    var member_no = String()
    var delegate:optionDelegate?
    let groupDB = groupStorage()
    var contact_name = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        self.containerView.frame.size = self.menuTableView.contentSize
        self.containerView.center = self.view.center
        self.menuTableView.frame = CGRect.init(x: 0, y: 10, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshContact), name: Notification.Name("ContactRefresh"), object: nil)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func refreshContact() {
        DispatchQueue.main.async {}
    }
    
    func initialSetup()  {
//        DispatchQueue.main.async {
        
        self.containerView.viewRadius(radius: 15)
        self.menuTableView.register(UINib(nibName: "OptionCell", bundle: nil), forCellReuseIdentifier: "OptionCell")
         self.contact_name = self.memberDict.value(forKey: "contact_name") as! String
         self.member_role = self.memberDict.value(forKey: "member_role") as! String
        self.member_id = self.memberDict.value(forKey: "member_id") as! String

        //config menu array
        if self.viewType == "1" {
            var admin = String()
            if self.member_role == "0"{
                admin = "\(Utility().getLanguage()?.value(forKey: "make") as? String ?? "Make") \(self.contact_name) \(Utility().getLanguage()?.value(forKey: "as_admin") as? String ?? "as admin")"
            }else{
               admin = "\(Utility().getLanguage()?.value(forKey: "remove") as? String ?? "Remove") \(self.contact_name) \(Utility().getLanguage()?.value(forKey: "from_admin") as? String ?? "from admin")"
            }
            self.menuArray = ["\(Utility().getLanguage()?.value(forKey: "message") as? String ?? "Message") \(self.contact_name)","\(Utility().getLanguage()?.value(forKey: "view") as? String ?? "View") \(self.contact_name)",admin,"\(Utility().getLanguage()?.value(forKey: "remove") as? String ?? "Remove") \(self.contact_name)"]
        }else{
            self.menuArray = ["\(Utility().getLanguage()?.value(forKey: "message") as? String ?? "Message") \(self.contact_name)","\(Utility().getLanguage()?.value(forKey: "view") as? String ?? "View") \(self.contact_name)"]
        }
        self.menuTableView.reloadData()

        self.member_no = self.memberDict.value(forKey: "member_no") as! String
        self.contact_name = "\(self.contact_name.split(separator: " ").last ?? "")"

        if self.member_no == self.contact_name{
            self.menuArray.add("\(Utility().getLanguage()?.value(forKey: "add_to_contact") as? String ?? "Add to contacts")")
        }
        
        //tap to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss (_:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        self.viewDidLayoutSubviews()
    }
    //dismiss view
    @objc func dismiss(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
            self.dismiss(animated: true, completion: nil)
        }, completion: nil)
    }
    // UIGestureRecognizerDelegate method
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.menuTableView) == true {
            return false
        }
        return true
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionCell
        cell.menuLbl.text = self.menuArray.object(at: indexPath.row) as? String
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {

        let member_id = self.memberDict.value(forKey: "member_id") as! String
        let alert = CustomAlert()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        if indexPath.row == 0 {
            let detailObj = ChatDetailPage()
            detailObj.contact_id = member_id
            detailObj.viewType = "2"
            detailObj.modalPresentationStyle = .fullScreen
            self.present(detailObj, animated: true, completion: nil)
        }else if indexPath.row == 1 {
            let profileObj = ProfilePage()
            profileObj.viewType = "other"
            profileObj.contactName = self.memberDict.value(forKey: "contact_name")as! String
            profileObj.contact_id = member_id
            profileObj.exitType = "1"
            profileObj.modalPresentationStyle = .fullScreen
            self.present(profileObj, animated: true, completion: nil)
        }else if indexPath.row == 2 {
            if self.viewType == "1"{
                if self.member_role == "0"{
                    self.alertActionDone(type: "1")
                }else{
                    self.alertActionDone(type: "2")
                }
            }else{
                self.addToContact()
            }
           
        }else if indexPath.row == 3 {
            self.alertActionDone(type: "3")
        }else if indexPath.row == 4 {
                self.addToContact()
            }
        }
    }
    
    func addToContact()  {
        let store = CNContactStore()
        let contact = CNMutableContact()
        let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :member_no))
        contact.phoneNumbers = [homePhone]
        contact.namePrefix = ""
        let controller: CNContactViewController = CNContactViewController(forNewContact: contact)
//        let controller = CNContactViewController(forUnknownContact : contact)
        controller.contactStore = store
        controller.delegate = self
        self.navigationController?.isNavigationBarHidden = false
        let navigationController: UINavigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false) {
            // print("Present")
        }
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        let localObj = LocalStorage()
        viewController.dismiss(animated: true, completion: nil)
        if contact?.givenName != nil || contact != nil{
            localObj.updateName(cotact_id: self.member_id, name: (contact?.givenName)!)
            self.delegate?.dismissWith(type: "4")
            DispatchQueue.global(qos: .background).async{
                Contact.sharedInstance.synchronize()
            }
            self.navigationController?.isNavigationBarHidden = true
            self.dismiss(animated: true, completion: nil)
//            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
  
    
    func alertActionDone(type: String) {
    
        if type == "1" {//make admin
            self.updateStatusService(role: "1")
            groupDB.makeAdmin(member_key: "\(group_id)\(member_id)",status:"1")
            self.notifyNewAdmin(status: type)
            self.delegate?.dismissWith(type: type)
            self.dismiss(animated: true, completion: nil)
        }else if type == "2" {//remove admin
            self.updateStatusService(role: "0")
            groupDB.makeAdmin(member_key: "\(group_id)\(member_id)",status:"0")
            self.notifyNewAdmin(status: type)
            self.delegate?.dismissWith(type: type)
            self.dismiss(animated: true, completion: nil)
        }else if type == "3"{//remove member
            self.notifyRemoveMember()
            groupDB.removeMember(member_key: "\(group_id)\(member_id)")
            self.delegate?.dismissWith(type: type)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateStatusService(role:String)  {
        let dict = NSMutableDictionary()
        dict.setValue(member_id, forKey: "member_id")
        dict.setValue(role, forKey: "member_role")
        let memberArray = NSMutableArray()
        memberArray.add(dict)
        let groubObj = GroupServices()
        groubObj.modifyMember(group_id: group_id, memberArray: memberArray, onSuccess: {_ in
        })
    }
    
    //make or remove admin
    func notifyNewAdmin(status:String)  {
        let member_id = self.memberDict.value(forKey: "member_id") as! String
            let memberDict = self.groupDB.getMemberInfo(member_key: "\(group_id)\(UserModel.shared.userID()!)")
            let msgDict = NSMutableDictionary()
            let msg_id = Utility.shared.random()
            msgDict.setValue("group", forKey: "chat_type")
            msgDict.setValue(msg_id, forKey: "message_id")
            msgDict.setValue(group_id, forKey: "group_id")
            msgDict.setValue(memberDict.value(forKey: "member_role"), forKey: "member_role")
            msgDict.setValue(memberDict.value(forKey: "member_no"), forKey: "member_no")
            msgDict.setValue(memberDict.value(forKey: "member_name"), forKey: "member_name")
            msgDict.setValue(member_id, forKey: "member_id")
            msgDict.setValue(UserModel.shared.userID(), forKey: "group_admin_id")
            msgDict.setValue("Admin", forKey: "message")
            msgDict.setValue("admin", forKey: "message_type")

            if status == "1" {
                msgDict.setValue("1", forKey: "attachment")
            }else{
                msgDict.setValue("0", forKey: "attachment")
            }
            msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
            //send socket
            groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
    }
    
    // remove user from the group
    func notifyRemoveMember()  {
        let member_id = self.memberDict.value(forKey: "member_id") as! String
        let memberDict = self.groupDB.getMemberInfo(member_key: "\(group_id)\(UserModel.shared.userID()!)")
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(member_id, forKey: "member_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "group_admin_id")
        msgDict.setValue("removed", forKey: "message")
        msgDict.setValue("remove_member", forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        
        groupSocket.sharedInstance.exitGroup(group_id: self.group_id,user_id:self.member_id,msgDict: msgDict)
        socketClass.sharedInstance.goLive()
    }
}
