//
//  CallPage.swift
//  Hiddy
//
//  Created by HTS-Product on 10/04/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class CallPage: ARDVideoCallViewController,callSocketDelegate,ARDVideoCallViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var enlargeBtn: UIButton!
    var call_type : String!
    var random_id :String!
    var receiverId : String!
    var senderFlag: Bool!
    var previewAdded: Bool!
    var hideEnabled = Bool()
    var userdict = NSDictionary()
    var room_id :String!
    var viewType :String!
    var av_Player : AVAudioPlayer!
    var poorConnection : Bool = false
    var timerStart : Bool = false
    var countTimer = Timer()
    var startTime = 0
    var muteFlag : Bool = false
    var call_status :String!
    var speakerMode = false
    var blockedMe = String()
    var localCallDB = CallStorage()
    var captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    var platform = String()
    var blueToothFlag : Bool = false
    var addedToMissed : Bool = false
    
    @IBOutlet var container: UIView!
    @IBOutlet var cutBtn: UIButton!
    @IBOutlet var muteBtn: UIButton!
    @IBOutlet var cameraOrSpeakerBtn: UIButton!
    @IBOutlet var profileImgView: UIImageView!
    @IBOutlet var backgroundImgView: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var callingLbl: UILabel!
    @IBOutlet var attenBtn: UIButton!
    @IBOutlet weak var propertiesView: UIView!
    @IBOutlet weak var preview: UIView!
    
    
    var updateCallStatus: (() -> Void)?
    var isCallKitAnswer = false
    var callanother = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configWebRTC()
        self.changeRTLView()
        self.initialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.appResignActivity), name: UIApplication.willTerminateNotification, object: nil)
        UserModel.shared.setAlreadyInCall(status: "true")
    }
    
    @objc func appResignActivity() {
    
    self.viewdis()
    
    }

    override func viewDidAppear(_ animated: Bool) {
        self.updateTheme()

        if call_type == "video" {
            self.cameraOrSpeakerBtn.isUserInteractionEnabled = false
            UIApplication.shared.isIdleTimerDisabled = true
      
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        if av_Player != nil {
            av_Player.stop()

        }
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        /*
        if call_type == "video" {
            self.captureSession.stopRunning()
            if previewAdded{
                self.previewLayer.removeFromSuperlayer()
                self.previewLayer = nil
            }
        }
        */
    }
    override func viewDidLayoutSubviews() {
        self.enlargeBtn.frame = CGRect.init(x: FULL_WIDTH - 150, y: 40, width: 150, height: 150)
    }
    func initialSetup() {

        self.enlargeBtn.frame = CGRect.init(x: FULL_WIDTH - 150, y: 40, width: 150, height: 150)
        self.detectHeadphonePlugged()
        NotificationCenter.default.addObserver(self, selector: #selector(detectHeadphonePlugged), name: AVAudioSession.routeChangeNotification, object: nil)
        hideEnabled = false
        //        previewAdded = false
        call_status = "waiting"
        callSocket.sharedInstance.delegate = self
        self.delegate = self
        self.blockedMe = self.userdict.value(forKey: "blockedMe") as! String
        
        //set values
        self.usernameLbl.config(color:.white , size: 25, align: .center, text: EMPTY_STRING)
        self.usernameLbl.text = self.userdict.value(forKey: "contact_name") as? String
        self.profileImgView.rounded()
        if self.userdict.value(forKey: "user_image") != nil{
            let imageName:String = self.userdict.value(forKey: "user_image") as! String
            self.profileImgView.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_popup_bg"))
        }else{
            self.profileImgView.image = #imageLiteral(resourceName: "profile_popup_bg")
        }
        
        //calling from sender / receiver
        if(senderFlag){
            let del = UIApplication.shared.delegate as! AppDelegate
            del.callKitPopup = true
            del.currentCallerID = receiverId
            // print("delegate current user \(del.currentCallerID)")
            room_id = Utility.shared.random()
            platform = "ios"
            self.makeCallToReceiver()
            self.join(toNextRoom: room_id, platform: platform, calltype: call_type)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let username = self.userdict.value(forKey: "contact_name") as! String
            appDelegate.registerOutgoingCall(username)
            
        }else{
            if viewType == "2" {
                self.join(toNextRoom: room_id, platform: platform, calltype: call_type)
            }
        }
        self.showPreview()
        self.container.bringSubviewToFront(self.propertiesView)
        self.view.bringSubviewToFront(enlargeBtn)
        self.performSelector(inBackground: #selector(self.makeRinging), with: nil)
        //call ui changes method
        self.setUIDesigns()
    }
    
    //handle
    @objc func hideProperties(sender: UITapGestureRecognizer? = nil) {
        // handling code
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            if self.hideEnabled {
                self.hideEnabled = false
                self.propertiesView.frame.origin.y = 0
            }else{
                self.hideEnabled = true
                self.propertiesView.frame.origin.y = 200
            }
        }, completion: nil)
    }
    
    @objc func detectHeadphonePlugged(){
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        print("route count \(outputs.count)")
        for output in outputs{
            print("HEADPHONE CHECK \(output.portType)")
            if output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP || output.portType == AVAudioSession.Port.bluetoothLE || output.portType == AVAudioSession.Port.headphones{
                print("HEADPHONE ADDED")
                self.blueToothFlag = true
                self.enableSpeaker(status: false)
            }
        }
    }
    
    func enableSpeaker(status:Bool)  {
        if status{
            self.speakerMode = true
            self.speakerOn()
            
        }else{
            self.speakerMode = false
            self.speakerOff()
        }
    }
    //ui changes method
    func setUIDesigns() {
        self.configButtons()
        //sender receiver based ui changes
        if senderFlag {
            self.attenBtn.isHidden = true
            self.cameraOrSpeakerBtn.isHidden = false
            self.muteBtn.isHidden = false
        }else{
            if viewType == "2" {
                self.attenBtn.isHidden = true
                self.cameraOrSpeakerBtn.isHidden = false
                self.muteBtn.isHidden = false
            }else{
                self.attenBtn.isHidden = false
                self.cameraOrSpeakerBtn.isHidden = true
                self.muteBtn.isHidden = true
            }
        }
        
        //call type based ui changes
        if call_type == "audio" {
            self.container.isHidden = false
            self.callingLbl.config(color:.green , size: 20, align: .center, text: "audio_calling")
        }else{
            self.callingLbl.config(color:.green , size: 20, align: .center, text: "video_calling")
            self.backgroundImgView.isHidden = true
            self.preview.backgroundColor = .clear
            self.container.backgroundColor = .clear
            self.propertiesView.backgroundColor = .clear
            self.profileImgView.isHidden = true
            if !blueToothFlag{
                self.enableSpeaker(status: true)
            }else{
                self.enableSpeaker(status: false)
            }
        }
        if viewType == "2" {
            callingLbl.text = "Connecting...."
        }
        self.view.bringSubviewToFront(container)
        self.view.bringSubviewToFront(enlargeBtn)
        
    }
    
    func configButtons()  {
        cutBtn.cornerRoundRadius()
        let cutImage = #imageLiteral(resourceName: "call_cancel").withRenderingMode(.alwaysTemplate)
        cutBtn.setImage(cutImage, for: .normal)
        cutBtn.tintColor = UIColor.white
        cutBtn.backgroundColor = .red
        cutBtn.imageEdgeInsets = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 17)
        attenBtn.cornerRoundRadius()
        var attenImage = UIImage()
        var changeCamera = UIImage()
        
        if self.call_type == "video"{
            attenImage = #imageLiteral(resourceName: "video").withRenderingMode(.alwaysTemplate)
            attenBtn.imageEdgeInsets = UIEdgeInsets(top: 17, left: 12, bottom: 17, right: 12)
            changeCamera = #imageLiteral(resourceName: "change_camera").withRenderingMode(.alwaysTemplate)
        }else{
            attenImage = #imageLiteral(resourceName: "audio").withRenderingMode(.alwaysTemplate)
            attenBtn.imageEdgeInsets = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 17)
            changeCamera = #imageLiteral(resourceName: "speaker").withRenderingMode(.alwaysTemplate)
        }
        attenBtn.setImage(attenImage, for: .normal)
        attenBtn.tintColor = UIColor.white
        attenBtn.backgroundColor = .green
//        if AppDelegate.Speackertesting == "Active"{
//
//        }
        let muteImage = #imageLiteral(resourceName: "mute").withRenderingMode(.alwaysTemplate)
        muteBtn.cornerRoundRadius()
        muteBtn.setBorder(color: .white)
        muteBtn.setImage(muteImage, for: .normal)
        muteBtn.imageEdgeInsets = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 17)
        muteBtn.tintColor = UIColor.white
        
        cameraOrSpeakerBtn.cornerRoundRadius()
        cameraOrSpeakerBtn.setImage(changeCamera, for: .normal)
        cameraOrSpeakerBtn.imageEdgeInsets = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 17)
        cameraOrSpeakerBtn.tintColor = UIColor.white
        cameraOrSpeakerBtn.setBorder(color: .white)
        
    }
    
    
    func makeCallToReceiver()  {
        let userid = UserModel.shared.userID()! as String
        let callerId = receiverId as String
        if self.blockedMe != "1"{
            callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"created",room_id: room_id)
        }
        self.perform(#selector(automaticallyDisConnectCall), with: nil, afterDelay: 30.0)
        
    }
    
    @IBAction func enlargeBtn(_ sender: Any) {
        self.enlargeView()
        DispatchQueue.main.async {
            self.propertiesView.isHidden = false
            self.view.bringSubviewToFront(self.container)
        }
    }
    @IBAction func attenBtnTapped(_ sender: Any) {
        let callerId = receiverId as String
        self.localCallDB.addNewCall(call_id: random_id, contact_id: callerId, status: "incoming", call_type: call_type, timestamp: Utility.shared.getTime(), unread_count: "0")
        callingLbl.text = "Connecting...."
        self.attenBtn.isHidden = true
        self.cameraOrSpeakerBtn.isHidden = false
        self.muteBtn.isHidden = false
        if av_Player != nil {
            av_Player.stop()
        }
        self.join(toNextRoom: room_id, platform: platform, calltype: call_type)
        
        //        self.join(toCall: room_id, platform: platform, call_type: call_type)
        
    }
    
    /*
     //old
    @IBAction func cutBtnTapped(_ sender: Any) {
        let userid = UserModel.shared.userID()! as String
        let callerId = receiverId as String
        if self.blockedMe != "1"{
            callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"ended", room_id: room_id)
        }
        if (call_status == "waiting"){
            if senderFlag{
                let userid = UserModel.shared.userID()! as String
                let receiver_id = receiverId as String
                callSocket.sharedInstance.registerCalls(callId: random_id, user_id:userid , receiver_id:receiver_id , type: call_type,call_type:"missed")
            }
        }
        self.disconnectCall()
    }
    */
    
    
    @IBAction func cutBtnTapped(_ sender: Any) {
        let userid = UserModel.shared.userID()! as String
        let callerId = receiverId as String
        if self.blockedMe != "1"{
            print("userend_11")
            print("newnew6")
            
            if self.callanother == "waiting"{
                print("callanotherwaiting")
                callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"", room_id: room_id)
            }else{
                print("callanotherended")
                callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"ended", room_id: room_id)
            }
            
            print("newnew:endcall:callid:\(random_id)")
            print("newnew:endcall:user_id:\(userid)")
            print("newnew:endcall:caller_id:\(callerId)")
            print("newnew:endcall:type:\(call_type)")
            print("newnew:endcall:call_status:\("outgoing")")
            print("newnew:endcall:chat_type:\("call")")
            print("newnew:endcall:call_type:\("ended")")
            print("newnew:endcall:room_id:\(room_id)")
            
        }
        
        if (call_status == "waiting"){
            print("userend_12")
            if senderFlag{
                if self.blockedMe != "1"{
                    print("userend_13")
                    let userid = UserModel.shared.userID()! as String
                    let receiver_id = receiverId as String
                    callSocket.sharedInstance.registerCalls(callId: random_id, user_id:userid , receiver_id:receiver_id , type: call_type,call_type:"missed")
                }
            }
        }
        self.disconnectCall()
    }

    func viewdis(){
        let userid = UserModel.shared.userID()! as String
        let callerId = receiverId as String
        if self.blockedMe != "1"{
            print("userend_11")
            print("newnew6")
            
            if self.callanother == "waiting"{
                print("callanotherwaiting")
                callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"", room_id: room_id)
            }else{
                print("callanotherended")
                callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"ended", room_id: room_id)
            }
            print("newnew:endcall:callid:\(random_id)")
            print("newnew:endcall:user_id:\(userid)")
            print("newnew:endcall:caller_id:\(callerId)")
            print("newnew:endcall:type:\(call_type)")
            print("newnew:endcall:call_status:\("outgoing")")
            print("newnew:endcall:chat_type:\("call")")
            print("newnew:endcall:call_type:\("ended")")
            print("newnew:endcall:room_id:\(room_id)")
            
        }
        if (call_status == "waiting"){
            print("userend_12")
            if senderFlag{
                print("userend_13")
                let userid = UserModel.shared.userID()! as String
                let receiver_id = receiverId as String
                callSocket.sharedInstance.registerCalls(callId: random_id, user_id:userid , receiver_id:receiver_id , type: call_type,call_type:"missed")
            }
        }
        self.disconnectCall()
    }
    
    @IBAction func muteBtnTapped(_ sender: Any) {
        if (muteFlag){
            muteFlag = false
            muteBtn.backgroundColor = .clear
            self.muteBtn.tintColor = .white
            self.muteOn()
        }else{
            muteFlag = true
            muteBtn.backgroundColor = .white
            self.muteBtn.tintColor = .black
            self.muteOff()
            
        }
    }
    
    @objc func automaticallyDisConnectCall(){
        if (call_status == "waiting"){
            
            let userid = UserModel.shared.userID()! as String
            let receiver_id = receiverId as String
            callSocket.sharedInstance.registerCalls(callId: random_id, user_id: userid, receiver_id: receiver_id, type: call_type,call_type:"missed")
            
            if self.blockedMe != "1"{
                callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: receiver_id, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"ended", room_id: room_id)
            }
            self.disconnectCall()
        }
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIButton {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
            self.usernameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.callingLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIButton {
                    imageView.transform = .identity
                }
            }
            self.usernameLbl.transform = .identity
            self.callingLbl.transform = .identity
        }
    }
    @IBAction func cameraBtnTapped(_ sender: Any) {
        print("camer action")
        if self.call_type == "video"{ // video camera switch
            self.switchCamera()
            
        }else{ //audio speaker
            if speakerMode {
                self.cameraOrSpeakerBtn.backgroundColor = .clear
                self.cameraOrSpeakerBtn.tintColor = .white
                self.enableSpeaker(status: false)
            } else {
                self.cameraOrSpeakerBtn.backgroundColor = .white
                self.cameraOrSpeakerBtn.tintColor = .black
                self.enableSpeaker(status: true)
            }
        }
    }
    /*
     //old
    func disconnectMissedCall() {
        self.countTimer.invalidate()
        av_Player.stop()
        if !senderFlag {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.endCall()
        }else{
            let del = UIApplication.shared.delegate as! AppDelegate
            del.callKitPopup = false
        }
        self.hangup()
        self.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "call_decline") as? String)
        
        //missed call view
        if (call_status == "waiting" && !senderFlag){
            let callerId = receiverId as String
            if !addedToMissed{
                addedToMissed = true
                self.localCallDB.addNewCall(call_id: random_id, contact_id: callerId, status: "missed", call_type: call_type, timestamp: Utility.shared.getTime(), unread_count: "1")
            }
        }
    }
    */
    
    func disconnectMissedCall() {
        print("userend_16")
        self.countTimer.invalidate()
        if av_Player != nil {

        av_Player.stop()
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let state = UIApplication.shared.applicationState
        if state != .background {
            if !senderFlag {
                print("userend_17")
                appDelegate.endCall()
            }else if (appDelegate.callKitPopup){
                print("userend_18")
                appDelegate.callKitPopup = false
                appDelegate.endCall(!self.isCallKitAnswer)
            }
        }
        self.hangup()
        self.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "call_decline") as? String)
        
        //missed call view
        if (call_status == "waiting" && !senderFlag){
            let callerId = receiverId as String
            if !addedToMissed{
                addedToMissed = true
                self.localCallDB.addNewCall(call_id: random_id, contact_id: callerId, status: "missed", call_type: call_type, timestamp: Utility.shared.getTime(), unread_count: "1")
            }
        }
    }
    
    /*
    //old
    func disconnectCall() {
        self.countTimer.invalidate()
        av_Player.stop()
        if !senderFlag {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.endCall()
        }else{
            let del = UIApplication.shared.delegate as! AppDelegate
            del.callKitPopup = false
        }
        self.hangup()
        self.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "call_end") as? String)
        
        //missed call view
        if (call_status == "waiting" && !senderFlag){
            let callerId = receiverId as String
            if !addedToMissed{
                addedToMissed = true
                self.localCallDB.addNewCall(call_id: random_id, contact_id: callerId, status: "missed", call_type: call_type, timestamp: Utility.shared.getTime(), unread_count: "1")
            }
        }
        
    }
    */
    
    func disconnectCall() {
        
        self.countTimer.invalidate()
        if av_Player != nil {

        av_Player.stop()
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let state = UIApplication.shared.applicationState
        if state != .background {
            if !senderFlag {
                appDelegate.endCall(!self.isCallKitAnswer)
            }else{
                print("userend_14")
                let del = UIApplication.shared.delegate as! AppDelegate
                del.callKitPopup = false
                appDelegate.endCall()
            }
        }
        self.hangup()
        self.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "call_end") as? String)
        
        //missed call view
        if (call_status == "waiting" && !senderFlag){
            let callerId = receiverId as String
            if !addedToMissed{
                addedToMissed = true
                self.localCallDB.addNewCall(call_id: random_id, contact_id: callerId, status: "missed", call_type: call_type, timestamp: Utility.shared.getTime(), unread_count: "1")
            }
        }
        
    }
    
    /*
     //old
     
    //call socket delegate
    func gotCallSocketInfo(dict: NSDictionary, type: String) {
        // print("RECEIVED NEW CALL SOCKET TYPE \(type)")
        if type == "bye" {
            let del = UIApplication.shared.delegate as! AppDelegate
            let caller_id = dict.value(forKey: "caller_id") as! String
            if del.currentCallerID == caller_id{
                av_Player.stop()
                if call_status == "connected" {
                    self.disconnectCall()
                }
                else {
                    UIApplication.shared.keyWindow?.rootViewController?.view.hideToast()
                    self.disconnectMissedCall()
                }
            }
        }else if type == "waiting" {
            let username = self.userdict.value(forKey: "contact_name") as! String
            self.callingLbl.isHidden = false
            self.callingLbl.text = "\(username) is an another call"
        }else if type == "platform" {
            let platf = dict.value(forKey: "platform") as! String
            self.addPlatform(platf)
        }else if type == "recentcalls"{
            
        }
    }
    //apprtc state delegate
    func streamDetails(_ state: Int) {
        // print("ICE STATE \(state)")
        if state == 2 { // CONNECTED STATE
            
            call_status = "connected"
            av_Player.stop()
            self.callingLbl.textColor = .white
            self.poorConnection = false
            if call_type == "audio"{
                //DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.updateTimer()
                    if !self.timerStart{
                        self.countTimer = Timer.scheduledTimer(timeInterval: 1.0, target:self,selector:#selector(self.updateTimer), userInfo: nil, repeats: true)
                        self.timerStart = true
                    }
                //}
                if blueToothFlag{
                    self.enableSpeaker(status: false)
                }else if self.speakerMode{
                    self.enableSpeaker(status: true)
                }
                
                let userid = UserModel.shared.userID()! as String
                let receiver_id = receiverId as String
                //                callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"created",room_id: room_id)
                callSocket.sharedInstance.registerCalls(callId: random_id, user_id: userid, receiver_id: receiver_id, type: call_type,call_type:"success")
            }else{
        
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideProperties(sender:)))
                self.view.addGestureRecognizer(tap)
//                self.captureSession.stopRunning()
                self.preview.isHidden = true
                self.usernameLbl.isHidden = true
                self.callingLbl.text = ""
                speakerMode = true
                if !blueToothFlag{
                    self.enableSpeaker(status: true)
                }else{
                    self.enableSpeaker(status: false)
                }
                self.cameraOrSpeakerBtn.isUserInteractionEnabled = true
                self.videoCallView.enlargeEnable = true
                self.videoCallView.remoteVideoView.isHidden = false
                self.videoCallView.localVideoView.frame = CGRect.init(x: FULL_WIDTH - 150, y: 40, width: 150, height: 150)
                self.videoCallView.remoteVideoView.frame = CGRect.init(x: 0 , y: 0, width: FULL_WIDTH, height: FULL_HEIGHT)
                self.container.bringSubviewToFront(self.propertiesView)
                self.view.bringSubviewToFront(enlargeBtn)
                
            }
        }else if state == 4{
            self.poorConnection = false
        }else if state == 5{ // SLOW CONNECTION
            self.poorConnection = true
            self.callingLbl.textColor = .white
            self.callingLbl.isHidden = false
            self.callingLbl.text = "Poor Network! Connecting..."
        }else if state == 6{ // DISCONNECTED STATE
            UIApplication.shared.keyWindow?.rootViewController?.view.hideToast()
            if call_status == "connected" {
                call_status = "disconnected"
                self.disconnectCall()
            }
            else {
                call_status = "disconnected"
                self.disconnectMissedCall()
            }
        }
    }
     */
    
    
    //call socket delegate
    func gotCallSocketInfo(dict: NSDictionary, type: String) {
        // print("RECEIVED NEW CALL SOCKET TYPE \(type)")
        if type == "bye" {
            let del = UIApplication.shared.delegate as! AppDelegate
            let caller_id = dict.value(forKey: "caller_id") as! String
            if del.currentCallerID == caller_id{
                if av_Player != nil {
                    av_Player.stop()
                }
                
                if call_status == "connected" {
                    self.disconnectCall()
                }
                else {
                    print("callstatusissue:\(String(describing: call_status))")
                    UIApplication.shared.keyWindow?.rootViewController?.view.hideToast()
                    self.disconnectMissedCall()
                }
            }
        }else if type == "waiting" {
            self.callanother = type
            let username = self.userdict.value(forKey: "contact_name") as! String
            self.callingLbl.isHidden = false
            self.callingLbl.text = "\(username) is an another call"
            
        }else if type == "platform" {
            let platf = dict.value(forKey: "platform") as! String
            self.addPlatform(platf)
        }else if type == "recentcalls"{
            
        }
    }
    
    //apprtc state delegate
    func streamDetails(_ state: Int) {
        print("ICE STATE \(state)")
        if state == 1 {
            self.callingLbl.text = "Checking ..."
        }
        else if state == 2 { // CONNECTED STATE
            
            call_status = "connected"
            if av_Player != nil {
                av_Player.stop()
            }
            self.callingLbl.textColor = .white
            self.poorConnection = false
            self.updateCallStatus!()
            if call_type == "audio"{
                //MARK:CALL ISSUE
               // DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.updateTimer()
                    if !self.timerStart{
                        self.countTimer = Timer.scheduledTimer(timeInterval: 1.0, target:self,selector:#selector(self.updateTimer), userInfo: nil, repeats: true)
                        self.timerStart = true
                    }
              //  }
                self.enableSpeaker(status: false)
                if blueToothFlag{
                    
                    self.enableSpeaker(status: false)
                }else if self.speakerMode{
                    self.enableSpeaker(status: true)
                }
//                self.muteOff()
                let userid = UserModel.shared.userID()! as String
                let receiver_id = receiverId as String
                //                callSocket.sharedInstance.createCall(callId: random_id, user_id:userid , caller_id: callerId, type: call_type,call_status: "outgoing", chat_type: "call",call_type:"created",room_id: room_id)
                callSocket.sharedInstance.registerCalls(callId: random_id, user_id: userid, receiver_id: receiver_id, type: call_type,call_type:"success")
                
            }else{
        
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideProperties(sender:)))
                self.view.addGestureRecognizer(tap)
//                self.captureSession.stopRunning()
                self.preview.isHidden = true
                self.usernameLbl.isHidden = true
                self.callingLbl.text = ""
                speakerMode = true
                if !blueToothFlag{
                    self.enableSpeaker(status: true)
                }else{
                    self.enableSpeaker(status: false)
                }
                self.cameraOrSpeakerBtn.isUserInteractionEnabled = true
                self.videoCallView.enlargeEnable = true
                self.videoCallView.remoteVideoView.isHidden = false
                self.videoCallView.localVideoView.frame = CGRect.init(x: FULL_WIDTH - 150, y: 40, width: 150, height: 150)
                self.videoCallView.remoteVideoView.frame = CGRect.init(x: 0 , y: 0, width: FULL_WIDTH, height: FULL_HEIGHT)
                self.container.bringSubviewToFront(self.propertiesView)
                self.view.bringSubviewToFront(enlargeBtn)
                
            }
        }else if state == 4{
            self.poorConnection = false
        }else if state == 5{ // SLOW CONNECTION
            /*
            self.poorConnection = true
            */
            self.poorConnection = false
            
            self.callingLbl.textColor = .white
            self.callingLbl.isHidden = false
            self.callingLbl.text = "Poor Network! Connecting..."
        }else if state == 6{ // DISCONNECTED STATE
            UIApplication.shared.keyWindow?.rootViewController?.view.hideToast()
            if call_status == "connected" {
                call_status = "disconnected"
                self.disconnectCall()
            }
            else {
                print("callstatusissue1:\(call_status)")
                call_status = "disconnected"
                self.disconnectMissedCall()
            }
        }
    }

    
    //set timer count
    @objc func updateTimer()  {
        self.startTime += 1
        self.callingLbl.text = self.timeString(time: TimeInterval(self.startTime))
        /*
        self.startTime += 1
        DispatchQueue.main.async {
            if !self.poorConnection{
                self.callingLbl.text = self.timeString(time: TimeInterval(self.startTime))
            }
        }
        */
    }
    func timeString(time:TimeInterval)-> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    
    
    /*
    @objc func makeRinging(){
        var audioName = String()
        var audioType = String()
        
        if senderFlag{
            audioName = "sound2"
            audioType = "caf"
        }else{
            audioName = "RingTone"
            audioType = "mp3"
        }
        
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: audioName, ofType: audioType)!)
        let session = AVAudioSession.sharedInstance()
        
        var availbleInput = NSArray()
        availbleInput = AVAudioSession.sharedInstance().availableInputs! as NSArray
        var port = AVAudioSessionPortDescription()
        port = availbleInput.object(at: 0) as! AVAudioSessionPortDescription
        
        var _: Error?
        try? session.setPreferredInput(port)
        
        try? session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
        
        if !blueToothFlag{
            if call_type == "video" || viewType == "1" || viewType == "2" {
                try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                speakerMode = true
                self.enableSpeaker(status: true)
            } else {
                try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            }
        }else{
            self.enableSpeaker(status: false)
            //            try? session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .allowBluetooth)
            
            
        }
        try? session.setActive(true)
        try! av_Player = AVAudioPlayer(contentsOf: alertSound)
        av_Player!.prepareToPlay()
        av_Player.numberOfLoops = -1
        av_Player!.play()
    }
    */
    
    
    @objc func makeRinging(){
        if !isCallKitAnswer {
            var audioName = String()
            var audioType = String()
            
            if senderFlag{
                audioName = "sound2"
                audioType = "caf"
                let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: audioName, ofType: audioType)!)
                let session = AVAudioSession.sharedInstance()
                
                var availbleInput = NSArray()
                availbleInput = AVAudioSession.sharedInstance().availableInputs! as NSArray
                var port = AVAudioSessionPortDescription()
                port = availbleInput.object(at: 0) as! AVAudioSessionPortDescription
                
                var _: Error?
                try? session.setPreferredInput(port)
                
                try? session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
                
                if !blueToothFlag{
                    if call_type == "video" || viewType == "1" || viewType == "2" {
                        try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                        speakerMode = true
                        self.enableSpeaker(status: true)
                    } else {
                        try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                    }
                }else{
                    self.enableSpeaker(status: false)
                    //            try? session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .allowBluetooth)
                    
                    
                }
                try? session.setActive(true)
                try! av_Player = AVAudioPlayer(contentsOf: alertSound)
                av_Player!.prepareToPlay()
                av_Player.numberOfLoops = -1
                av_Player!.play()
            }else{
                self.muteOn()
                audioName = "RingTone1"
                audioType = "mp3"
            }
            
            
        }
    }
    
    //show preview camera screen
    func videoPreview(){
        DispatchQueue.main.async {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.medium
            let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
            self.captureDevice = availableDevices.first
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: self.captureDevice)
                self.captureSession.addInput(captureDeviceInput)
            } catch {
                print("error.localizedDescription in Call \(error.localizedDescription)")
            }
            self.captureSession.startRunning()
            let pL = AVCaptureVideoPreviewLayer(session: self.captureSession)
            pL.videoGravity = .resizeAspectFill
            self.previewLayer = pL
            self.previewLayer.frame = CGRect.init(x: 0, y: 0, width: FULL_WIDTH, height: FULL_HEIGHT)
            self.preview.layer.addSublayer(self.previewLayer)
            self.previewAdded = true
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            if self.captureSession.canAddOutput(dataOutput) {
                self.captureSession.addOutput(dataOutput)
            }
            self.captureSession.commitConfiguration()
        }
    }
    
}
