//
//  GroupInfoPage.swift
//  Hiddy
//
//  Created by APPLE on 12/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import IQKeyboardManagerSwift
import AVFoundation

class GroupInfoPage: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,groupDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var selectedCollectionView: UICollectionView!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var participantsLbl: UILabel!
    @IBOutlet var groupNameTF: FloatLabelTextField!
    @IBOutlet var groupIcon: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var viewType = String()
    var selectedId = NSMutableArray()
    var selectedContacts = NSMutableArray()
    var imageData =  NSData()
    var group_id = String()
    var member_id = String()
    var member_role = String()
    var groupIconUpdated  =  Bool()
    var groupDict = NSDictionary()
    var backType = String()
    var makeGroup  =  false
    let actionButton = JJFloatingActionButton()
    var groupID = ""
    
    @IBOutlet var loader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initalSetup()
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.countLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.countLbl.textAlignment = .left
            self.participantsLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.participantsLbl.textAlignment = .right
            self.groupNameTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.groupNameTF.textAlignment = .right
            actionButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.selectedCollectionView.semanticContentAttribute = .forceLeftToRight
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.countLbl.transform = .identity
            self.countLbl.textAlignment = .right
            self.participantsLbl.transform = .identity
            self.participantsLbl.textAlignment = .left
            self.groupNameTF.transform = .identity
            self.groupNameTF.textAlignment = .left
            actionButton.transform = .identity
            self.selectedCollectionView.semanticContentAttribute = .unspecified
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.selectedCollectionView.backgroundColor = BACKGROUND_COLOR
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    //initial setup
    func initalSetup()  {
        loader.color = SECONDARY_COLOR

        let groupDB = groupStorage()
        if  viewType == "1" {
            let dict = groupDB.getMemberInfo(member_key: "\(group_id)\(UserModel.shared.userID()!)")
            member_id = dict.value(forKey: "member_id") as! String
            member_role = dict.value(forKey: "member_role") as! String
        }
        
        groupIconUpdated = false
        self.groupNameTF.becomeFirstResponder()
        groupSocket.sharedInstance.delegate = self
        self.imagePicker.delegate = self
        IQKeyboardManager.shared.enable =  true
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "create_group")
        self.countLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .right, text: EMPTY_STRING)
        self.participantsLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "participants")
        self.groupNameTF.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, placeHolder: "group_name")
        self.groupIcon.rounded()
        
        //config collection view
        selectedCollectionView.register(UINib(nibName: "selectedCell", bundle: nil), forCellWithReuseIdentifier: "selectedCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        selectedCollectionView.collectionViewLayout = flowLayout
        self.countLbl.text = Utility.shared.countInAppLanguage(count: self.selectedContacts.count)
        self.configFloatingBtn()
        if self.viewType  == "1"{
            self.configGroupEditView()
        }
    }
    
    func getMemberId()->NSMutableArray{
        let mutableArray = NSMutableArray()
        for id in self.selectedId {
            let dict = NSMutableDictionary()
            dict.setValue(id, forKey: "member_id")
            dict.setValue("0", forKey: "member_role")
            mutableArray.add(dict)
        }
        let adminDict = NSMutableDictionary()
        adminDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        adminDict.setValue("1", forKey: "member_role")
        mutableArray.add(adminDict)
        return mutableArray
    }
    
    func configGroupEditView(){
        let groupDB = groupStorage()
        self.groupDict = groupDB.getGroupInfo(group_id: self.group_id)
        self.groupNameTF.text = self.groupDict.value(forKey: "group_name") as? String
        self.groupIcon.rounded()
        let imageName:String = self.groupDict.value(forKey: "group_icon") as! String
        self.groupIcon.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "group_placeholder"))
        self.selectedContacts = groupDB.getGroupMembers(group_id: group_id)
        self.countLbl.text = "\(self.selectedContacts.count)"
        self.selectedCollectionView.reloadData()
    }
    
    //config floating chat new btn
    func configFloatingBtn(){
        if UIDevice.current.hasNotch{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-120, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-90, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.buttonImage = #imageLiteral(resourceName: "floating_tick_white")
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
            //        DispatchQueue.main.async {
            if self.groupNameTF.isEmpty() {
                self.groupNameTF.setAsInvalidTF("enter_groupname", in: self.view)
            }else{
                self.groupNameTF.setAsValidTF()
                if !self.makeGroup{//for single time call method
                    self.makeGroup = true
                    if self.viewType == "1"{ //group edit option
                        let group_name:String = self.groupDict.value(forKey: "group_name") as! String
                        if group_name != self.groupNameTF.text{
                            let groupService = GroupServices()
                            groupService.modifySubject(group_id: self.group_id, group_name: self.groupNameTF.text!, onSuccess: { response in
                                let status:NSString = response.value(forKey: "status") as! NSString
                                if status.isEqual(to: STATUS_TRUE){
                                    let groupObj = groupStorage()
                                    groupObj.updateGroupName(group_id: self.group_id, group_name: self.groupNameTF.text!)
                                    self.notifySubjectChangeToGroup(group_id: self.group_id)
                                    if self.groupIconUpdated{
                                        self.uploadGroupIcon(group_id: self.group_id)
                                    }else{
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                                
                            })
                        }else{
                            if self.groupIconUpdated{
                                self.uploadGroupIcon(group_id: self.group_id)
                            }else{
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }else{ // new group create action
                        self.loader.startAnimating()
                        groupSocket.sharedInstance.createGroup(name: self.groupNameTF.text!, group_members: self.getMemberId())
                    }
                }//end single action
            }
            //        }//asyn end
        }else{ // show network alert
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    //back btn tapped
    @IBAction func backBtnTapped(_ sender: Any) {
        self.groupNameTF.resignFirstResponder()
        if backType == "1"{
            self.dismiss(animated: true, completion: nil)
        }else{
            //            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.groupNameTF.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let full_string = textField.text!+string
        if full_string.count>25{
            return false
        }
        return true
    }
    
    //MARK: Collection view delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedCell", for: indexPath) as! selectedCell
        let userDict:NSDictionary =  selectedContacts.object(at: indexPath.row) as! NSDictionary
        if self.viewType  == "1"{
            cell.configMember(contactDict: userDict)
        }else{
            cell.config(contactDict: userDict,type:"user")
        }
        cell.closeView.isHidden = true
        cell.addStiryImgView.isHidden = true

        return cell
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 10)
    }
    
    //socket group info
    func gotGroupInfo(dict: NSDictionary, type: String) {
        print("AjmalAJ_3")
        if type == "groupinvitation"{
            let member_id:String = dict.value(forKey: "group_admin_id") as! String
            if member_id == "\(UserModel.shared.userID()!)"{
                let group_id:String = dict.value(forKey: "_id") as! String
                if groupIconUpdated{
                    if self.groupID != group_id {
                        self.groupID = group_id
                        self.uploadGroupIcon(group_id:group_id)
                    }
                }else{
                    self.loader.stopAnimating()
                    let groupChat = GroupChatPage()
                    groupChat.group_id = group_id
                    groupChat.viewType = "1"
                    groupChat.modalPresentationStyle = .fullScreen
//                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: {
//                        UIApplication.shared.keyWindow?.rootViewController?.present(groupChat, animated: false, completion: nil)
//                    })
//                    self.present(groupChat, animated: true, completion: nil)
                    self.navigationController?.pushViewController(groupChat, animated: true)
                }
            }
        }
    }
    
    @IBAction func groupIconBtnTapped(_ sender: Any) {
        self.groupNameTF.resignFirstResponder()
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
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    //MARK:location restriction alert
    func cameraPermissionAlert(){
        AJAlertController.initialization().showAlert(aStrMessage: "camera_permission", aCancelBtnTitle: "cancel", aOtherBtnTitle: "settings", completion: { (index, title) in
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
        self.groupIcon.image = #imageLiteral(resourceName: "profile_placeholder")
        if let pickedImage = info[.originalImage] as? UIImage {
            self.groupIcon.image = pickedImage
            self.imageData = pickedImage.jpegData(compressionQuality: 0)! as NSData//UIImageJPEGRepresentation(pickedImage, 0)! as NSData
            self.groupIconUpdated = true
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Upload profile picture
    func uploadGroupIcon(group_id:String)  {
//        self.groupIconUpdated = false
        print("group_id:: \(group_id)")
        DispatchQueue.main.async {
            let uploadObj = UploadServices()
            uploadObj.uploadGroupIcon(iconImage: self.imageData as Data, group_id: group_id, onSuccess: {response in
                let status:NSString = response.value(forKey: "status") as! NSString
                if status.isEqual(to: STATUS_TRUE){
                    let group_name:String =  response.value(forKey: "group_image") as! String
                    let groupDB = groupStorage()
                    groupDB.updateGroupIcon(group_id: group_id, group_icon: group_name)
                    self.notifyGroup(attachment: group_name, group_id: group_id)
                    DispatchQueue.main.async{
                        if self.viewType == "1"{
                            self.dismiss(animated: true, completion: nil)
                        }else{
                            self.loader.stopAnimating()
                            let groupChat = GroupChatPage()
                            groupChat.group_id = group_id
                            groupChat.viewType = "10"
                            groupChat.modalPresentationStyle = .fullScreen
                            //                        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: {
                            //                            UIApplication.shared.keyWindow?.rootViewController?.present(groupChat, animated: false, completion: nil)
                            //                        })
                            //                      self.navigationController?.pushViewController(groupChat, animated: true)
                            self.present(groupChat, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func notifyGroup(attachment:String,group_id:String)  {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(attachment, forKey: "attachment")
        msgDict.setValue(self.member_role, forKey: "member_role")
        msgDict.setValue(UserModel.shared.phoneNo(), forKey: "member_no")
        msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name"), forKey: "member_name")
        msgDict.setValue(UserModel.shared.userID()!, forKey: "member_id")
        msgDict.setValue("group icon changed", forKey: "message")
        msgDict.setValue("group_image", forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
    }
    func notifySubjectChangeToGroup(group_id:String)  {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(self.groupNameTF.text!, forKey: "group_name")
        msgDict.setValue(self.member_role, forKey: "member_role")
        msgDict.setValue(UserModel.shared.phoneNo(), forKey: "member_no")
        msgDict.setValue(UserModel.shared.userDict().value(forKey: "user_name"), forKey: "member_name")
        msgDict.setValue(self.member_id, forKey: "member_id")
        msgDict.setValue("changed the subject to \"\(self.groupNameTF.text!)\"", forKey: "message")
        msgDict.setValue("subject", forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
    }
}

