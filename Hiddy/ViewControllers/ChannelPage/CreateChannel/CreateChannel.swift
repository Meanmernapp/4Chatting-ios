//
//  CreateChannel.swift
//  Hiddy
//
//  Created by APPLE on 06/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import AVFoundation

class CreateChannel: UIViewController,UITextViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,channelDelegate {
    
    @IBOutlet var navigationView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var channelDP: UIImageView!
    @IBOutlet var descriptionTV: UITextView!
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var typeLbl: UILabel!
    @IBOutlet var publicLbl: UILabel!
    @IBOutlet var publicDesLbl: UILabel!
    @IBOutlet var privateLbl: UILabel!
    @IBOutlet var privateDesLbl: UILabel!
    @IBOutlet var publicSelView: UIView!
    @IBOutlet var privateSelView: UIView!
    @IBOutlet var desTitleLbl: UILabel!
    @IBOutlet var privacyView: UIView!
    @IBOutlet var nameOfChannelLbl: UILabel!
    
    var imageData = NSData()
    var channelIconUpdated = Bool()
    let imagePicker = UIImagePickerController()
    var selection =  String()
    let channelDB = ChannelStorage()
    var viewType =  String()
    var channel_id =  String()
    var exitType =  String()
    var channelDict = NSDictionary()
    var channelCreated = Bool()

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

        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.descriptionTV.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.descriptionTV.textAlignment = .right
            self.desTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.desTitleLbl.textAlignment = .right
            self.typeLbl.textAlignment = .right
            self.typeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameOfChannelLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameOfChannelLbl.textAlignment = .right
            self.nameTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameTF.textAlignment = .right
            self.publicLbl.textAlignment = .right
            self.publicLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.publicDesLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.publicDesLbl.textAlignment = .right
            self.privateLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.privateLbl.textAlignment = .right
            self.privateDesLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.privateDesLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.descriptionTV.transform = .identity
            self.descriptionTV.textAlignment = .left
            self.typeLbl.transform = .identity
            self.typeLbl.textAlignment = .left
            self.nameTF.transform = .identity
            self.nameTF.textAlignment = .left
            self.privateLbl.textAlignment = .left
            self.privateLbl.transform = .identity
            self.publicLbl.transform = .identity
            self.publicLbl.textAlignment = .left
            self.publicDesLbl.transform = .identity
            self.publicDesLbl.textAlignment = .left
            self.privateDesLbl.transform = .identity
            self.privateDesLbl.textAlignment = .left
            self.desTitleLbl.transform = .identity
            self.desTitleLbl.textAlignment = .left
            self.nameOfChannelLbl.transform = .identity
            self.nameOfChannelLbl.textAlignment = .left
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
     @IBAction func backBtnTapped(_ sender: Any) {
        self.removeKeyboard()
        if exitType == "1"{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
     }
    
    func initialSetup()  {
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR

        channelSocket.sharedInstance.delegate = self
        channelIconUpdated = false
        channelCreated = false
        self.imagePicker.delegate = self
        configFloatingBtn()
        self.navigationView.elevationEffect()
        self.channelDP.rounded()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "create_channel")
        self.nameTF.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, placeHolder: EMPTY_STRING)
        self.descriptionTV.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "description")
        self.desTitleLbl.config(color: TEXT_TERTIARY_COLOR, size: 18, align: .left, text: "description")
        self.nameOfChannelLbl.config(color: TEXT_TERTIARY_COLOR, size: 18, align: .left, text: "channel_name")
        self.typeLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: "channel_type")
        self.privateLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "private")
        self.publicLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "public")
        self.privateDesLbl.config(color: TEXT_TERTIARY_COLOR, size: 18, align: .left, text: "private_msg")
        self.publicDesLbl.config(color: TEXT_TERTIARY_COLOR, size: 18, align: .left, text: "public_msg")
        self.configSelectionView()
        self.descriptionTV.contentInset = UIEdgeInsets(top: -7.0, left: 0.0, bottom: 0.0, right: 0.0)
        if viewType == "1"{
            self.privacyView.isHidden = true
            channelDict = channelDB.getChannelInfo(channel_id: self.channel_id)
            self.nameTF.text = channelDict.value(forKey: "channel_name") as? String
            self.descriptionTV.text = channelDict.value(forKey: "channel_des") as? String
            let imageName:String = channelDict.value(forKey: "channel_image") as! String
            self.channelDP.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
//        self.descriptionTV.textContainerInset = UIEdgeInsets.zero
        self.descriptionTV.textContainer.lineFragmentPadding = 0
    }
    func configSelectionView()  {
        self.publicSelView.backgroundColor = .white
        self.publicSelView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.privateSelView.backgroundColor = .white
        self.privateSelView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.publicSelView.applyGradient()
        self.selection = "public"
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
        actionButton.buttonImage = #imageLiteral(resourceName: "next_arrow")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(createChannelAction), for: .touchUpInside)
        view.addSubview(actionButton)
        
    }
    //floating btn action
    @objc func createChannelAction()  {
        if Utility.shared.isConnectedToNetwork() {
        if nameTF.isEmpty() {
            self.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "enter_channel_username") as! String)
        }else if descriptionTV.isEmpty(){
            self.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "enter_description") as! String)
        }else{
            if viewType == "1"{
                let updateObj = ChannelServices()
                updateObj.updateChannel(channel_id: channel_id, channel_name: self.nameTF.text!, channel_des: self.descriptionTV.text!, onSuccess: {response in
                })
                channelDB.updateChannelName(channel_id: channel_id, name: self.nameTF.text!, des: self.descriptionTV.text!)
                let channel_name = channelDict.value(forKey: "channel_name") as? String
                let channel_des = channelDict.value(forKey: "channel_des") as! String
              
                if channel_name != self.nameTF.text{
                    self.notifyChannel(type:"subject")
                    self.dismissView()
                }
                if channel_des != self.descriptionTV.text{
                    self.notifyChannel(type:"channel_des")
                    self.dismissView()
                }
                if channelIconUpdated{
                    self.uploadChannelIcon(id: self.channel_id)
                }
                
            }else{
                if !channelCreated{
                channelSocket.sharedInstance.createChannel(name: self.nameTF.text!, des: self.descriptionTV.text!, type: self.selection)
                    channelCreated = true
                }
            }
        }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    func dismissView()  {
        if exitType == "1"{
            self.dismiss(animated: true, completion: nil)
        }else if exitType == "2"{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    @IBAction func profilepicBtnTapped(_ sender: Any) {
        self.removeKeyboard()
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
    func moveToCamera(){
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .camera
        self.imagePicker.modalPresentationStyle = .fullScreen
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
        self.channelDP.image = #imageLiteral(resourceName: "profile_placeholder")
        if let pickedImage = info[.originalImage] as? UIImage {
            self.channelDP.image = pickedImage
            self.imageData = pickedImage.jpegData(compressionQuality: 0)! as NSData//UIImageJPEGRepresentation(pickedImage, 0)! as NSData
            self.channelIconUpdated = true
            
        }
        self.dismiss(animated: true, completion: nil)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func publicBtnTapped(_ sender: Any) {
        self.removeKeyboard()
        self.publicSelView.applyGradient()
        self.privateSelView.removeGrandient()
        self.selection = "public"
    }
    
    @IBAction func privateBtnTapped(_ sender: Any) {
        self.removeKeyboard()
        self.publicSelView.removeGrandient()
        self.privateSelView.applyGradient()
        self.selection = "private"
    }
    
    func removeKeyboard(){
        self.nameTF.resignFirstResponder()
        self.descriptionTV.resignFirstResponder()
    }
    //channel delegate
    func gotChannelInfo(dict: NSDictionary, type: String) {
        if type == "channelcreated"{
            let id:String = dict.value(forKey: "_id") as! String
            if !UserModel.shared.channelIDs().contains(id){
                let totalCount:NSNumber = dict.value(forKey: "total_subscribers") as! NSNumber
                channelDB.addNewChannel(channel_id:id, title: dict.value(forKey: "channel_name") as! String, description: dict.value(forKey: "channel_des") as! String, created_time: dict.value(forKey: "created_time") as! String, channel_type: dict.value(forKey: "channel_type") as! String, created_by: dict.value(forKey: "channel_admin_id") as! String, subCount:"\(totalCount)",status:"1")
                self.addInitialMsg(channel_id: id)
                if channelIconUpdated {
                    self.uploadChannelIcon(id: id)
                }else{
                    let successObj = SuccessPage()
                    successObj.detailsDict = dict
                    successObj.channel_id = id
                    successObj.viewType = "3"
                    self.navigationController?.pushViewController(successObj, animated: true)
                }
            }
        }
    }
    
    //MARK: Textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTF.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let full_string = textField.text!+string
            if full_string.count>30{
                return false
            }
        return true
    }
    //MARK: Textview delgate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let full_string = textView.text!
        if text == "\n" {
            self.descriptionTV.resignFirstResponder()
            return false
        }
        if full_string.count>250{
            return false
        }
        return true
    }
    
    //MARK: Upload profile picture
    func uploadChannelIcon(id:String)  {
        let uploadObj = UploadServices()
        uploadObj.uploadChannelIcon(iconImage: self.imageData as Data, channel_id: id, onSuccess: {response in
            let status:NSString = response.value(forKey: "status") as! NSString
            if status.isEqual(to: STATUS_TRUE){
                let channel_image:String =  response.value(forKey: "channel_image") as! String
                self.channelDB.updateChannelIcon(channel_id: id, channel_icon: channel_image)
                if self.viewType == "1"{
                    self.notifyChannel(type:"channel_image")
                    self.dismissView()
                }else{
                    DispatchQueue.main.async{
                        let channelDict = self.channelDB.getChannelInfo(channel_id: id)
                        let successObj = SuccessPage()
                        successObj.channel_id = id
                        successObj.detailsDict = channelDict
                        successObj.viewType = "2"
                        self.navigationController?.pushViewController(successObj, animated: true)
                    }
                }
            }
        })
    }

    func notifyChannel(type:String){
        let dict = channelDB.getChannelInfo(channel_id: self.channel_id)
        let attachment:String = dict.value(forKey: "channel_image") as! String
        let name : String = dict.value(forKey: "channel_name") as! String
        let des : String = dict.value(forKey: "channel_des") as! String

        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("channel", forKey: "chat_type")
        msgDict.setValue (msg_id, forKey: "message_id")
        msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
        msgDict.setValue(name, forKey: "channel_name")
        msgDict.setValue(self.channel_id, forKey: "channel_id")
        msgDict.setValue(attachment, forKey: "attachment")
        msgDict.setValue(des, forKey: "message")
        msgDict.setValue(type, forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        channelSocket.sharedInstance.sendChannelMsg(requestDict: msgDict)
    }
    
    func addInitialMsg(channel_id:String)  {
        channelDB.addChannelMsg(msg_id: channel_id,
                                channel_id:channel_id ,
                                admin_id: UserModel.shared.userID()! as String,
                                msg_type: "added",
                                msg:(Utility.shared.getLanguage()?.value(forKey: "you_created_channel") as? String)! ,
                                time: Utility.shared.getTime(),
            lat: "",
            lon: "",
            contact_name: "",
            contact_no: "",
            country_code: "",
            attachment: "",
            thumbnail: "",read_status:"0", msg_date: "")
        if  UserModel.shared.channelIDs().contains(channel_id) {
            channelDB.updateChannelDetails(channel_id: channel_id, mute: "0", report: "0",  message_id: channel_id, timestamp: Utility.shared.getTime(), unread_count: "1")
        }
    }
    
    func showAlert(msg:String)  {
        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: msg, completion: { (index, title) in
        })
    }
}
