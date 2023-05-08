//
//  AppDelegate.swift
//  Hiddy
//
//  Created by APPLE on 29/05/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import UserNotifications
import PushKit
import CallKit
import GSImageViewerController
import AVFoundation
import WebRTC
import FirebaseUI
import Firebase
import FirebaseMessaging
import TrueTime
import IQKeyboardManagerSwift

let client = TrueTimeClient.sharedInstance

@UIApplicationMain
class AppDelegate: UIResponder,UIApplicationDelegate,PKPushRegistryDelegate,CXProviderDelegate,updateDelegate {
    var window: UIWindow?
    var badgeNo:Int = 0
    var getData = Bool()
    var callStarted = Bool()
    var baseUUId = UUID()
    var callStatus : String = ""
    var localCallDB = CallStorage()
    var callNotificationDict = NSMutableDictionary()
    //inital data set up
    var contactArray = NSMutableArray()
    var groupArray = NSMutableArray()
    var ownChannelArray = NSMutableArray()
    var allChannelArray = NSMutableArray()
    var callsArray = NSMutableArray()
    var callController = CXCallController()
    
    static let providerConfiguration: CXProviderConfiguration = {
        let localizedName = NSLocalizedString("Calling From", comment: "Hiddy")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)
        // Prevents multiple calls from being grouped.
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportsVideo = true
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
//        providerConfiguration.ringtoneSound = "Ringtone.aif"
//        let iconMaskImage = #imageLiteral(resourceName: "IconMask")
//        providerConfiguration.iconTemplateImageData = iconMaskImage.pngData()
        return providerConfiguration
    }()
    
    var provider: CXProvider!
    var callKitPopup = false
    var Voip_apns_Status = 0
    var currentCallerID = String()
    var isRemoteEnded = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        //        let dict = NSMutableDictionary()
        //        dict.setValue("ddd", forKey: "dd")
        //        UserModel.shared.setCallDict(callDict: dict)
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        FirebaseApp.configure()
        UserModel.shared.setCallSocket(status: nil)
        UserModel.shared.setAlreadyInCall(status: "false")
        // Fetch data once an hour.
        UIApplication.shared.setMinimumBackgroundFetchInterval(1)
        Thread.sleep(forTimeInterval: 3.0)
        if (launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL) != nil {
            // TODO: handle URL from here
        }
        else {
            
        }
        
        if UserModel.shared.translatedLanguage() == nil{
                   UserModel.shared.setTranslated(language: "none")
               }
        self.initialSetup()
        self.checkUserLoggedStatus()
        self.getData = false
        
        //config push notification
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
        }
        application.registerForRemoteNotifications()
        
        //Added Code to display notification when app is in Foreground
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
        voipRegistry.delegate = self;
        self.createDocument()
        // Config firebase
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            print("notificationReceived\(notification)")
        }
        
        return true
    }
    func createDocument() {
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let logsPath = documentsDirectoryURL.appendingPathComponent(DOCUMENT_PATH)
        do
        {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        let localObj = LocalStorage()
        let groupObj = groupStorage()
        let channelObj = ChannelStorage()
        
        let badgeNumber = localObj.overAllUnreadMsg() + groupObj.groupOverAllUnreadMsg() + channelObj.channelOverAllUnreadMsg()
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
        
        let userval = UserDefaults(suiteName: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "").Notification")
        userval?.set(badgeNumber, forKey: "badge")
        print("badge count \(userval?.object(forKey: "badge") as? Int ?? 0)")

        self.badgeNo = 0
        self.getData = false

        //        socketClass.sharedInstance.disconnect()
        // print("*******RESIGN ACTIVE********")
        
    }

    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //connect socket
        //        if !callStarted {
        //            socketClass.sharedInstance.disconnect()
        //        }
        // print("*******BACKGROUND********")
        self.getData = false
        socketClass.sharedInstance.goAway()
        socketClass.sharedInstance.connect()
        if activeTimer.isValid {
            activeTimer.invalidate()
        }
    }
   
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UserWebService().updateBadgeStatus()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let localObj = LocalStorage()
        UIApplication.shared.applicationIconBadgeNumber = localObj.overAllUnreadMsg()
        let userval = UserDefaults(suiteName: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "").Notification")
        print("badge count \(userval?.object(forKey: "badge") as? Int ?? 0)")

        userval?.set(localObj.overAllUnreadMsg(), forKey: "badge")

        self.badgeNo = 0
        //connect socket
        if(UserModel.shared.userID() != nil) {
            if !callStarted{
                socketClass.sharedInstance.connect()
            }
            if !self.getData{
                socketClass.sharedInstance.getRecentMsg()
                groupSocket.sharedInstance.getNewGroup()
                channelSocket.sharedInstance.getNewChannel()
                StorySocket.sharedInstance.getRecentStories()

                if UserModel.shared.isRegistered() == "1"{
                    self.checkDeviceInfo()
                }
                self.getData = true
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: initial setup
    func initialSetup(){
        client.start()
        UserModel.shared.setSocket(status:"0")
        //setup language
        if UserModel.shared.getAppLanguage() == nil{
            UserModel.shared.LANGUAGE_CODE = "en"
            UserModel.shared.setAppLanguage(Language: DEFAULT_LANGUAGE)
        }else{
            UserModel.shared.setAppLanguage(Language: UserModel.shared.getAppLanguage()!)
        }
        Utility.shared.configureLanguage()
        
        if UserModel.shared.theme() == nil{
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark{
                    let dark = Utility.language?.value(forKey: "Dark") ?? "Dark"
                    UserModel.shared.set(theme:dark as! NSString)
                }else{
                    let light = Utility.language?.value(forKey: "Light") ?? "Light"
                    UserModel.shared.set(theme:light as! NSString)
                }
            } else {
                // Fallback on earlier versions
            }
        }

        /*
        if UserModel.shared.theme() == nil{
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark{
                    let dark = Utility.language?.value(forKey: "dark")
                    UserModel.shared.set(theme:dark as! NSString)
                }else{
                    let light = Utility.language?.value(forKey: "light")
                    UserModel.shared.set(theme:light as! NSString)
                }
            } else {
                // Fallback on earlier versions
            }
        }
        DispatchQueue.global(qos: .background).async{
            Contact.sharedInstance.synchronize()
        }
        */
        
        //keyborad manager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.configWebRTC()
        microPhonePermission()
    }
    
    //initialise webrtc
    func configWebRTC()  {
        let fieldTrials: [AnyHashable : Any] = [:]
        RTCInitFieldTrialDictionary(fieldTrials as? [String : String])
        RTCInitializeSSL()
        RTCSetupInternalTracer()
        #if NDEBUG
        // In debug builds the default level is LS_INFO and in non-debug builds it is
        // disabled. Continue to log to console in non-debug builds, but only
        // warnings and errors.
        RTCSetMinDebugLogLevel(RTCLoggingSeverityWarning)
        #endif
    }    //MARK: check user status
    func checkUserLoggedStatus()  {
        if(UserModel.shared.userID() == nil) {
            self.setInitialViewController(initialView: LoginPage())
        }else{
            LocalStorage.sharedInstance.updateDefaultTranslation()
            self.setInitialViewController(initialView: menuContainerPage())
        }
        if Utility.shared.isConnectedToNetwork(){
            
            let userObj = UserWebService()
            userObj.versionUpdate(onSuccess: {response in
                let status:Int = response.value(forKey: "status") as! Int
                if status == 1{
                    let currentVersion:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    let newVersion:String = response.value(forKey: "ios_version") as! String
                        UserModel.shared.setAntMedia(dict: response)
                   
                    if newVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                        // print("store version is newer")
                        let forceUpdate:NSNumber = response.value(forKey: "ios_update") as! NSNumber
                        let alert = AppUpdate()
                        alert.delegate = self
                        alert.viewType = "\(forceUpdate)"
                        DispatchQueue.main.async {
                            self.setInitialViewController(initialView: alert)
                        }
                    }
                    
                }
            })
        }
    }
    
    func updateDismiss(){
        if(UserModel.shared.userID() == nil) {
            self.setInitialViewController(initialView: LoginPage())
        }else{
            self.setInitialViewController(initialView: menuContainerPage())
        }
    }
    // MARK:set initial view controller
    func setInitialViewController(initialView: UIViewController)  {
        
        UserModel.shared.setTab(index: 0)
        window = UIWindow(frame: UIScreen.main.bounds)
        let homeViewController = initialView
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.isNavigationBarHidden = true
        window!.rootViewController = nav
        window!.makeKeyAndVisible()
    }
    
    func setAfterStatusViewController(initialView: UIViewController)  {
        UserModel.shared.setTab(index: 0)
        window = UIWindow(frame: UIScreen.main.bounds)
        let homeViewController = initialView
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.isNavigationBarHidden = true
        window!.rootViewController = nav
        //        window!.makeKeyAndVisible()
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        // print("pushRegistry didInvalidatePushTokenFor \(type)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        let deviceTokenString = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1)})
        print("PUSH KIT TOKEN \(deviceTokenString)")
        UserModel.shared.setPushToken(voip_token: deviceTokenString as NSString)
        
        self.callPushNotification()
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
         print("PUSHKIT NOTIFICATION \(payload.dictionaryPayload)")
        if(UserModel.shared.userID() != nil) {
            badgeNo = badgeNo + 1
            //get msg from notification
            let msgDict:NSDictionary = payload.dictionaryPayload["message_data"] as! NSDictionary
            let chat_type:String = msgDict.value(forKey: "chat_type") as! String
            if chat_type == "call"{
                self.callStarted = true
                      socket.defaultSocket.connect()
                      socket.defaultSocket.on(clientEvent: .connect){data, ack in
                          socketClass.sharedInstance.connectChat()
                          if UserModel.shared.callSocketStatus() == nil{
                              callSocket.sharedInstance.CallSocketHandler()
                              UserModel.shared.setCallSocket(status: "1")
                          }
                      }
                      callNotificationDict.removeAllObjects()
                      callNotificationDict.addEntries(from: msgDict as! [AnyHashable : Any])
                      // init call kit for incoming call UI
                      let call_status =  self.callNotificationDict.object(forKey: "call_type") as? String
                      if call_status == "created"{
                          if !callKitPopup{
                              callStatus = "incoming"
                              let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
                              if (UserModel.shared.contactIDs()?.contains(receiver_id))! {
                                  let localObj = LocalStorage()
                                  let userDict = localObj.getContact(contact_id: receiver_id)
                                  self.makeIncomingCall(userDict: userDict, receiver_id: receiver_id)
                              }else{ // if user not availble
                                self.makeIncomingCall(userDict: self.callNotificationDict, receiver_id: receiver_id)
                                addToLocalDB(receiver_id: receiver_id)

                              }
                              self.currentCallerID = receiver_id
                              self.sendPlatform()
                              
                          }else{//send another call option
                              let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
                              let call_id = self.callNotificationDict.object(forKey: "call_id")as! String
                              let room_id = self.callNotificationDict.object(forKey: "room_id")as! String
                              let type = self.callNotificationDict.object(forKey: "type") as! String
                              self.ignorePushNotification()
                              let userid = UserModel.shared.userID()! as String
                              callSocket.sharedInstance.createCall(callId: call_id, user_id:userid , caller_id: receiver_id, type: type,call_status: "outgoing", chat_type: "call",call_type:"waiting", room_id: room_id)
                          }
                      }else if call_status == "ended"{
                          self.callStatus = "ended"
                          let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
                          if self.currentCallerID == receiver_id{
                              self.callKitPopup = false
                              self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                              self.endCall()
                          }
                          else {
                              self.ignorePushNotification()
                          }
                      }
            }
        }
    }
    
    func ignorePushNotification() {
        provider.reportCall(with: self.baseUUId, updated: CXCallUpdate())
    }
    
    //generate notification
    func triggerNotification(msgDict:NSDictionary,userDict:NSDictionary,type:String)  {
        let content = UNMutableNotificationContent()
        var identifier = String()
        let cryptLib = CryptLib()
        
        if type == "single"{
            let localObj = LocalStorage()
            let contact_id:String = msgDict.value(forKey: "sender_id") as? String ?? ""
            let unreadcount = localObj.getUnreadCount(contact_id: contact_id)
            let body = msgDict.value(forKey: "message") as? String ?? ""
            let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: body, key: ENCRYPT_KEY)
            
            if userDict.value(forKey: "contact_name") != nil{
                content.title = userDict.value(forKey: "contact_name") as! String
            }else{
                content.title = userDict.value(forKey: "contact_no") as? String ?? ""
            }
            if unreadcount == 0{
                content.body = decryptedMsg ?? ""
            }else{
                //                content.body = "\(unreadcount) \((msgDict.value(forKey: "message"))!)"
                content.body = decryptedMsg ?? ""
            }
            identifier = msgDict.value(forKey: "message_id") as! String
            content.threadIdentifier = content.title
            content.summaryArgument = content.title
            content.summaryArgumentCount = 2
            content.categoryIdentifier = "single:\(contact_id)"
        }else if type == "group"{
            let groupObj = groupStorage()
            let group_id = msgDict.value(forKey: "group_id") as! String
            let unreadcount = groupObj.getGroupUnreadCount(group_id: group_id)
            content.title = userDict.value(forKey: "group_name") as? String ?? ""
            let member_id = msgDict.value(forKey: "member_id") as! String
            let body = msgDict.value(forKey: "message") as? String ?? ""
            let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: body, key: ENCRYPT_KEY)
            
            if unreadcount == 0{
                content.body = "\(Utility.shared.getUsername(user_id: member_id)) : \(decryptedMsg!)"
            }else{
                //                content.body = "\(unreadcount) \(Utility.shared.getUsername(user_id: member_id)) : \(decryptedMsg!)"
                content.body = "\(Utility.shared.getUsername(user_id: member_id)) : \(decryptedMsg!)"
            }
            identifier = msgDict.value(forKey: "message_id") as! String
            content.threadIdentifier = content.title
            content.summaryArgument = content.title
            content.categoryIdentifier = "group:\(group_id)"
        }else if type == "channel"{
            let channelObj = ChannelStorage()
            let channel_id:String = userDict.value(forKey: "channel_id") as! String
            let unreadcount = channelObj.getChannelUnreadCount(channel_id: channel_id)
            content.title = "Channel: \(userDict.value(forKey: "channel_name") as! String)"
            
            let body = msgDict.value(forKey: "message") as? String ?? ""
            let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: body, key: ENCRYPT_KEY)
            
            if unreadcount == 0{
                content.body = "\(decryptedMsg!)"
            }else{
                content.body = "\(decryptedMsg!)"
                //                content.body = "\(unreadcount) \((msgDict.value(forKey: "message"))!)"
            }
            identifier = msgDict.value(forKey: "message_id") as! String
            content.threadIdentifier = content.title
            content.summaryArgument = content.title
            content.categoryIdentifier = "channel:\(channel_id)"
        }else if type == "groupinvitation"{
            content.body = "You added to this group"
            content.title = userDict.value(forKey: "group_name") as? String ?? ""
            identifier = msgDict.value(forKey: "group_id") as! String
            content.categoryIdentifier = "groupinvitation:\(identifier)"
        }else if type == "channelinvitation"{
            content.body = "Channel Invitation"
            content.title = msgDict.value(forKey: "title") as! String
            identifier = msgDict.value(forKey: "id") as! String
            content.categoryIdentifier = "channelinvitation:\(identifier)"
        }
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.add(request) { (error) in
        }
    }
    
    //microphone permission
    func microPhonePermission()  {
        DispatchQueue.main.async {
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                
            })
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                
            }
            PhotoAlbum.init()//  create album
        }
    }
    // one to one chat
    func loadAllUnreadMessages() {
        let localObj = LocalStorage()
        let recentArray = localObj.getRecentList(isFavourite: "0")
        let favArray = localObj.getRecentList(isFavourite: "1")
        recentArray.addObjects(from: favArray as [AnyObject])
        
        for i in recentArray {
            let recentDict:NSDictionary = i as! NSDictionary
            let contactID = recentDict.value(forKey: "sender_id") as? String ?? ""
            let recentCount = recentDict.value(forKey: "unread_count") as? String ?? ""
            let mute:String = recentDict.value(forKey: "mute") as! String
            
            if recentCount != "0" && mute == "0" {
                let recentArrayVal = localObj.getAllUnreadMsg(contact_id: contactID)
                let userDict = localObj.getContact(contact_id: contactID)
                for msg in recentArrayVal {
                    let msgDict:NSDictionary = msg as! NSDictionary
                    let msgType:String = msgDict.value(forKey: "message_type") as! String
                    if msgType == "isDelete" {
                        msgDict.setValue("This message was deleted", forKey: "message")
                    }
                    self.triggerNotification(msgDict: msgDict, userDict: userDict,type:"single")
                    
                }
            }
        }
        let groupObj = groupStorage()
        let groupArray = groupObj.getGroupList()
        for i in groupArray {
            let recentDict:NSDictionary = i as! NSDictionary
            let recentCount = recentDict.value(forKey: "unread_count") as? String ?? ""
            let groupID = recentDict.value(forKey: "group_id") as? String ?? ""
            let mute:String = recentDict.value(forKey: "mute") as! String
            if recentCount != "0" && mute == "0"{
                let recentArrayVal = groupObj.getGroupUnreadMessage(group_id: groupID)
                let groupDict = groupObj.getGroupInfo(group_id: groupID)
                
                for msg in recentArrayVal {
                    let msgDict:NSDictionary = msg as! NSDictionary
                    let groupType = msgDict.value(forKey: "message_type") as! String
                    if groupType == "isDelete" {
                        msgDict.setValue("This message was deleted", forKey: "message")
                    }
                    if groupType != "create_group" && groupType != "user_added" {
                        self.triggerNotification(msgDict: msgDict, userDict: groupDict,type:"group")
                    }
                    else {
                        self.triggerNotification(msgDict: msgDict, userDict: msgDict, type:"groupinvitation")
                    }
                }
            }
        }
        
        let channelObj = ChannelStorage()
        let ChannelArr = channelObj.getChannelNewList(type: "all")
        for i in ChannelArr {
            let recentDict:NSDictionary = i as! NSDictionary
            //            let contactID = recentDict.value(forKey: "admin_id") as? String ?? ""
            let recentCount = recentDict.value(forKey: "unread_count") as? String ?? ""
            let channel_id = recentDict.value(forKey: "channel_id") as? String ?? ""
            let mute:String = recentDict.value(forKey: "mute") as! String
            
            if recentCount != "0" && mute == "0"{
                let recentArrayVal = channelObj.getChannelUnreadMSg(channel_id: channel_id)
                let channelDict = channelObj.getChannelInfo(channel_id: channel_id)
                for msg in recentArrayVal {
                    let msgDict:NSDictionary = msg as! NSDictionary
                    let msgType:String = msgDict.value(forKey: "message_type") as! String
                    if msgType == "isDelete" {
                        msgDict.setValue("This message was deleted", forKey: "message")
                    }
                    self.triggerNotification(msgDict: msgDict, userDict: channelDict,type:"channel")
                    
                }
            }
        }
    }


    
    func setInitialCache(){
        //        let recents = LocalStorage.sharedInstance.getRecentList()
        self.contactArray = LocalStorage.sharedInstance.getContactList()
        //        let groups = groupStorage.sharedInstance.getGroupList()
        //        self.groupArray =  UserDefaults.standard.object(forKey: "cache_groups") as! NSMutableArray
        // print("gorup array count \(self.groupArray)")
        //        let all_channels = ChannelStorage.sharedInstance.getChannelList(type: "all")
        //        let own_channels = ChannelStorage.sharedInstance.getChannelList(type: "own")
    }
    
    
    func callMsg(msgDict:NSDictionary)    {
      
    }

    func sendPlatform()  {
        if self.callNotificationDict.object(forKey: "caller_id") != nil {
            let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
            let call_id = self.callNotificationDict.object(forKey: "call_id")as! String
            let room_id = self.callNotificationDict.object(forKey: "room_id")as! String
            let type = self.callNotificationDict.object(forKey: "type") as! String
            let userid = UserModel.shared.userID()! as String
            callSocket.sharedInstance.createCall(callId: call_id, user_id:userid , caller_id: receiver_id, type: type,call_status: "outgoing", chat_type: "call",call_type:"platform", room_id: room_id)
        }
    }
    
    func providerDidReset(_ provider: CXProvider) {
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction)
    {
        // accepted call save in localDB
        let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
        
        self.localCallDB.addNewCall(call_id: callNotificationDict.object(forKey: "call_id") as! String, contact_id: receiver_id, status: "incoming", call_type: callNotificationDict.object(forKey: "type")as! String, timestamp: Utility.shared.getTime(), unread_count: "0")
        callStatus = "callAccept"
        let localObj = LocalStorage()
        var userDict = localObj.getContact(contact_id: receiver_id)
        self.perform(#selector(automaticDisconnect), with: nil, afterDelay: 28.0)
        if socket.status == .connected{
            if userDict.value(forKey: "user_id") == nil{
                print("not getting")
                self.addToLocalDB(receiver_id: receiver_id)
                let tempDict = NSMutableDictionary()
                tempDict.setValue("false", forKey: "blockedMe")
                tempDict.setValue(self.callNotificationDict.value(forKey: "phone"), forKey: "contact_name")
                userDict = tempDict
            }
//            action.fulfill()
            self.configureAudioSession()
            let callSok = callSocket()
            callSok.acceptCall(callsender_id: callNotificationDict.object(forKey: "call_id") as! String, call_type: self.callNotificationDict.object(forKey: "type") as? String ?? "")
            let pageObj = CallPage()
            let platform = self.callNotificationDict.object(forKey: "platform") as! String
            let random_id = self.callNotificationDict.object(forKey: "call_id")
            pageObj.random_id = random_id as? String
            pageObj.receiverId = receiver_id
            pageObj.userdict = userDict
            pageObj.viewType = "2"
            pageObj.platform = platform
            pageObj.updateCallStatus = {
                
            }
            pageObj.modalPresentationStyle = .overFullScreen
            pageObj.call_type = self.callNotificationDict.object(forKey: "type") as? String
            pageObj.room_id = self.callNotificationDict.object(forKey: "room_id") as? String
            pageObj.senderFlag = false
            self.window!.makeKeyAndVisible()
            self.window?.rootViewController?.present(pageObj, animated: true, completion: nil)
        }
        else {
//            action.fulfill()
        }
//        self.localNotification("FullFil Action", message: "action option called")
        action.fulfill()
    }
    
     func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
         print ("call end action \(self.callNotificationDict)")
         print ("currentCallerID \(self.currentCallerID)")
         print ("callstausof \(self.callStatus)")
         if let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as? String {
             if self.currentCallerID == receiver_id {
                 callKitPopup = false
             }
             if self.callNotificationDict.object(forKey: "caller_id") != nil {
                 print("fam3")
                 let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
                 let call_id = "\(receiver_id)\(UserModel.shared.userID()!)"
                 let room_id = self.callNotificationDict.object(forKey: "room_id")as! String
                 let type = self.callNotificationDict.object(forKey: "type") as! String
                 
                 let userid = UserModel.shared.userID()! as String
                 if (callStatus == "incoming")
                 {
                     callSocket.sharedInstance.createCall(callId: call_id, user_id:userid , caller_id: receiver_id, type: type,call_status: "outgoing", chat_type: "call",call_type:"ended", room_id: room_id)
                 }
             }
         }
         action.fulfill()
     }
    
    func endCallAct() {
        let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
        let localObj = LocalStorage()
        let userDict = localObj.getContact(contact_id: receiver_id)
        self.perform(#selector(automaticDisconnect), with: nil, afterDelay: 28.0)
        
        let pageObj = CallPage()
        pageObj.updateCallStatus = { [weak self] in
        }
        let platform = self.callNotificationDict.object(forKey: "platform") as! String
        let random_id = self.callNotificationDict.object(forKey: "call_id")
        pageObj.random_id = random_id as? String
        pageObj.receiverId = receiver_id
        pageObj.userdict = userDict
        pageObj.viewType = "2"
        pageObj.platform = platform
        pageObj.modalPresentationStyle = .overFullScreen
        pageObj.call_type = self.callNotificationDict.object(forKey: "type") as? String
        pageObj.room_id = self.callNotificationDict.object(forKey: "room_id") as? String
        pageObj.senderFlag = false
        self.window!.makeKeyAndVisible()
        self.window?.rootViewController?.present(pageObj, animated: true, completion: nil)
    }
    @objc func automaticDisconnect()
    {
        if (callStatus == "incoming")
        {
            self.isRemoteEnded = true
            let endCallAction = CXEndCallAction(call:baseUUId)
            let transaction = CXTransaction(action: endCallAction)
            callController.request(transaction) { error in
                if error != nil {
                    // print("EndCallAction transaction request failed: \(error.localizedDescription).")
                    //self.cxCallProvider.reportCall(with: call, endedAt: Date(), reason: .remoteEnded)
                    return
                }
                else {
                    self.isRemoteEnded = false
                }
                // print("EndCallAction transaction request successful")
            }
           
            let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as! String
            if self.currentCallerID == receiver_id {
                callKitPopup = false
            }
        }
        self.callStarted = false
    }
    
    
    func endCall(_ isFromEndButton: Bool = false){
        UserModel.shared.setAlreadyInCall(status: "false")
        self.isRemoteEnded = true
        // print("end call uuid \(baseUUId)")
//        self.localNotification("End Call", message: "Call Ended")
        let endCallAction = CXEndCallAction(call:baseUUId)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { error in
            if error != nil {
                var isvalidcall = false
                if self.callController.callObserver.calls.count != 0{
                    for i in self.callController.callObserver.calls{
                        if i.uuid == self.baseUUId{
                            isvalidcall = true
                            break
                        }
                    }
                }
                if !isFromEndButton && isvalidcall{
//                    self.localNotification("Outgoing Call", message: "Call ended2")
                    self.provider.reportCall(with: self.baseUUId, endedAt: Date(), reason: .remoteEnded)
                    self.baseUUId = UUID()
                }
                // print("EndCallAction transaction request failed: \(error.localizedDescription).")
                return
            }
            // print("EndCallAction transaction request successful")
        }
        self.automaticDisconnect()
        self.callStarted = false
        if let receiver_id = self.callNotificationDict.object(forKey: "caller_id")as? String {
            if self.currentCallerID == receiver_id {
                callKitPopup = false
            }
        }
        else {
            callKitPopup = false
        }
        //        self.endCallAct()
    }
    
    
    func setHomeAsRootView(){
        self.setInitialViewController(initialView: menuContainerPage())
    }
    //if user not availble
    func addToLocalDB(receiver_id:String)  {
        
        let userObj = UserWebService()
        userObj.otherUserDetail(contact_id: receiver_id, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let localObj = LocalStorage()
                let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                let cc = response.value(forKey: "country_code") as! Int
                
                localObj.addContact(userid: receiver_id,
                                    contactName: ("+\(cc) " + "\(phone_no)"),
                                    userName: response.value(forKey: "user_name") as! String,
                                    phone: "\(phone_no)",
                    img: response.value(forKey: "user_image") as! String,
                    about: response.value(forKey: "about") as? String,
                    type: EMPTY_STRING,
                    mutual:response.value(forKey: "contactstatus") as! String,
                    privacy_lastseen: response.value(forKey: "privacy_last_seen") as! String,
                    privacy_about: response.value(forKey: "privacy_about") as! String,
                    privacy_picture: response.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                print("added locally")
            
            }
        })
    }
    
    func configureAudioSession() {
//        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//            let session = AVAudioSession.sharedInstance()
//
//            do{
//                try session.setCategory(AVAudioSession.Category.playAndRecord,
//                                        mode: AVAudioSession.Mode.voiceChat,
//                                         options: [])
//
//            } catch {
//                print("========== Error in setting category \(error.localizedDescription)")
//            }
//
//            do {
//                try session.setPreferredSampleRate(44100.0)
//            } catch {
//                print("======== Error setting rate \(error.localizedDescription)")
//            }
//            do {
//                try session.setPreferredIOBufferDuration(0.005)
//            } catch {
//                print("======== Error IOBufferDuration \(error.localizedDescription)")
//            }
//            do {
//                try session.setActive(true)
//            } catch {
//                print("========== Error starting session \(error.localizedDescription)")
//            }
//        })
    }
    
    func localNotification(_ title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = message
        content.sound = UNNotificationSound.default
        // choose a random identifier
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func makeIncomingCall(userDict:NSDictionary,receiver_id:String)  {
        
        // add our notification request
        let session = AVAudioSession.sharedInstance()
        var availbleInput = NSArray()
        availbleInput = AVAudioSession.sharedInstance().availableInputs! as NSArray
        var port = AVAudioSessionPortDescription()
        port = availbleInput.object(at: 0) as! AVAudioSessionPortDescription
        var _: Error?
        try? session.setPreferredInput(port)
        try? session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
        try? session.setMode(AVAudioSession.Mode.voiceChat)
        try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        try? session.setActive(true)
        self.configureAudioSession()
        baseUUId = UUID()
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        var username = String()
        if (UserModel.shared.contactIDs()?.contains(receiver_id))! {
            username = userDict.value(forKey: "contact_name") as! String
        }else{
            username = userDict.value(forKey: "phone") as! String
        }
        update.remoteHandle = CXHandle(type: .generic, value: username)
        if self.callNotificationDict.object(forKey: "type")as? String == "audio"{
            update.hasVideo = false
        }else{
            update.hasVideo = true
        }
        provider.reportNewIncomingCall(with: baseUUId, update: update, completion: { error in })
        //        }
        
        self.callKitPopup = true
    }
    
    func registerOutgoingCall(_ username: String){
//        self.isOutgoingCall = true
//        self.localNotification("Outgoing Call", message: "Call Initated")
        self.baseUUId = UUID()
        print("!outgoingUuid\(self.baseUUId)")
        provider.setDelegate(self, queue: nil)
        let action = CXStartCallAction(call: self.baseUUId, handle: CXHandle(type: .generic, value: username))
        action.isVideo = false
        let transaction = CXTransaction(action: action)
        callController.request(transaction, completion: { error in
            self.callKitPopup = true
        })
    }
    
    //regisert for push services
    func checkDeviceInfo()  {
        let pushObj = UserWebService()
        pushObj.checkDeviceInfo(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            
            if status == STATUS_FALSE{
                
                UIApplication.shared.applicationIconBadgeNumber = 0
                let userval = UserDefaults(suiteName: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "").Notification")
                userval?.set(0, forKey: "badge")
                print("badge count \(userval?.object(forKey: "badge") as? Int ?? 0)")
                if let defaults = UserDefaults(suiteName: NOTIFICATION_EXTENSION) {
                    defaults.removeObject(forKey: "user_id")
                }
                
                // clear local cache from nsuserdefault
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
                
                
            }else{
                if ( UserModel.shared.getAPNSToken() != nil && UserModel.shared.getPushToken() != nil) {
                    if(UserModel.shared.userID() != nil) {
                            Utility.shared.registerPushServices()
                    }
                }
            }
        })
    }
    
}
extension AppDelegate: forwardDelegate {
    func forwardMsg(type: String, idStr:String) {
        self.window?.makeToast(Utility.shared.getLanguage()?.value(forKey: "sending") as? String)
    }
    
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if Auth.auth().canHandle(url) {
            return true
        }
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        if(UserModel.shared.userID() != nil) {
            let homeVC = ForwardSelection()
            homeVC.msgFrom = "single"
            homeVC.delegate = self
            homeVC.shareTag = 1
            homeVC.modalPresentationStyle = .fullScreen
            let userDefaults = UserDefaults(suiteName: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "").Share")

            if let key = url.absoluteString.components(separatedBy: "=").last{
                if key == "image", let sharedArray = userDefaults?.object(forKey: "ImageSharePhotoKey") as? [Data]  {
                    var imageArray: [CellModel] = []
                    print("imagearray \(sharedArray.count)")
                    for i in 0..<sharedArray.count {
                        let urlArray = userDefaults?.object(forKey: "local_path") as? [String]
                        let model = CellModel(image: UIImage(data: sharedArray[i])!, imageData: sharedArray[i], imageURL: urlArray?[i] ?? "", type: "image")
                        imageArray.append(model)
                    }
                    homeVC.sharedCell = imageArray
                    homeVC.sharedType = key
                }
                else if key == "video", let sharedArray = userDefaults?.object(forKey: "ImageSharePhotoKey") as? [Data] {
                    var imageArray: [VideoCellModel] = []
                    print("videoarray \(sharedArray.count)")
                    for i in 0..<sharedArray.count {
                        let urlArray = userDefaults?.object(forKey: "local_path") as? [String]
                        let model = VideoCellModel(imageData: sharedArray[i], imageURL: urlArray?[i] ?? "", type: "video", thumb: "", localPath: urlArray?[i] ?? "")
                        imageArray.append(model)
                        
                    }
                    homeVC.sharedVideoCell = imageArray
                    homeVC.sharedType = key
                }
                else if key == "imageVideo", let sharedArray = userDefaults?.object(forKey: "ImageSharePhotoKey") as? [Data] {
                    var imageArray: [VideoCellModel] = []
                    for i in 0..<sharedArray.count {
                        let urlArray = userDefaults?.object(forKey: "local_path") as? [String]
                        let typeArray = userDefaults?.object(forKey: "imageType") as? [String]
                        let model = VideoCellModel(imageData: sharedArray[i], imageURL: urlArray?[i] ?? "", type: typeArray?[i] ?? "image", thumb: "", localPath: urlArray?[i] ?? "")
                        imageArray.append(model)
                        
                    }
                    print("imageVideoArray \(imageArray.count)")

                    homeVC.sharedVideoCell = imageArray
                    homeVC.sharedType = key
                }
                    
                else if key == "location" {
                    homeVC.sharedType = key
                    homeVC.selectedText = userDefaults?.object(forKey: "text") as? String ?? ""
                }
                else if key == "contact" {
                    homeVC.sharedType = key
                    homeVC.contactData = userDefaults?.object(forKey: "contactData") as! Data
                    
                }
                else {
                    homeVC.sharedType = key
                    homeVC.selectedText = userDefaults?.object(forKey: "text") as? String ?? ""
                }
                self.window?.rootViewController?.present(homeVC, animated: true, completion: nil)
                self.window?.makeKeyAndVisible()
                return true
            }
            else {
                if url.absoluteString.components(separatedBy: "=").last != nil{
                    self.window?.rootViewController?.present(homeVC, animated: true, completion: nil)
                    self.window?.makeKeyAndVisible()
                    return true
                    
                }
                
            }
        }
        return false
    }
    
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func callPushNotification() {
        if ( UserModel.shared.getAPNSToken() != nil && UserModel.shared.getPushToken() != nil) {
            if(UserModel.shared.userID() != nil) {
                if  UserModel.shared.isRegistered() != "1" {
                    Utility.shared.registerPushServices()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNS TOKEN \(deviceTokenString)",deviceToken)
        UserModel.shared.setAPNSToken(fcm_token: deviceTokenString as NSString)
        self.callPushNotification()
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNS FAILED \(error.localizedDescription)")
    }
    
   
    //BACKGROUND NOTIFICATION RECEIVE
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        print("notification received 2 \(userInfo)")
//                let msgDict: NSDictionary = userInfo["message_data"] as! NSDictionary
        //
        //        let type = msgDict.value(forKey: "chat_type") as! String
        //        let localObj = LocalStorage()
        //
        //        if type == "single"{
        //            let sender_id = msgDict.value(forKey: "sender_id") as! String
        //            let userDict = localObj.getContact(contact_id: sender_id)
        //               if (UserModel.shared.contactIDs()?.contains(sender_id))! {
        //                print("user dict \(userDict)")
        //                   let mute:String = userDict.value(forKey: "mute") as! String
        //                   if mute == "0" {
        ////                    completionHandler(.newData)
        //                   }
        //               }
        //        }
        completionHandler(.noData)
        
    }
    //FOREGROUND NOTIFICATION RECEIVE
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)    {
        
        print("notification received \(notification.request.content.userInfo)")
        let notificationDict: NSDictionary = notification.request.content.userInfo["data"] as! NSDictionary
        let msgDict: NSDictionary = notificationDict.value(forKey: "message_data") as! NSDictionary
        let localObj = LocalStorage()
        let groupObj = groupStorage()
        let channelObj = ChannelStorage()
        let badgeNumber = localObj.overAllUnreadMsg() + groupObj.groupOverAllUnreadMsg() + channelObj.channelOverAllUnreadMsg()
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
        let userval = UserDefaults(suiteName: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "").Notification")
        userval?.set(badgeNumber, forKey: "badge")
        print("badge count \(userval?.object(forKey: "badge") as? Int ?? 0)")

        print("notification received \(msgDict)")
        let type = msgDict.value(forKey: "chat_type") as! String
        let navigationCtrl = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        
//        if let currentVC = navigationCtrl?.visibleViewController as? CallPage {
//
//                print("user in current page: \(currentVC)")
//        }else{
            if type == "single"{
                let sender_id = msgDict.value(forKey: "sender_id") as! String
                let userDict = localObj.getContact(contact_id: sender_id)
                if (UserModel.shared.contactIDs()?.contains(sender_id))! {
                    if userDict.value(forKey: "mute") != nil{
                    let mute:String = userDict.value(forKey: "mute") as! String
                    if mute == "0" {
                        if let currentVC = navigationCtrl?.visibleViewController as? ChatDetailPage {
                            if currentVC.contact_id != sender_id {
                                print("triggered1")
                                completionHandler([.alert, .badge, .sound])
                            }
                        }else{
                            print("triggered2")
                            completionHandler([.alert, .badge, .sound])
                        }
                    }
                    }
                }
            }else if type == "group"{
                let group_id:String = msgDict.value(forKey: "group_id") as! String
                let member_id:String = msgDict.value(forKey: "member_id") as! String

                let groupObj = groupStorage()
                if UserModel.shared.groupIDs().contains(group_id) {
                    let groupDict = groupObj.getGroupInfo(group_id: group_id)
                    let mute:String = groupDict.value(forKey: "mute") as! String
                    if mute == "0" {
                        print("member \(member_id) userId \(String(describing: UserModel.shared.userID()))")
                        if member_id != UserModel.shared.userID()! as String{
                        if let currentVC = navigationCtrl?.visibleViewController as? GroupChatPage {
                            if currentVC.group_id != group_id {
                                completionHandler([.alert, .badge, .sound])
                            }
                        }else{
//                            completionHandler([.alert, .badge, .sound])
                            print("group is mute")
                        }
                        }
                    }
                }
                
            }else if type == "channel"{
                let channel_id:String = msgDict.value(forKey: "channel_id") as! String
                let channelObj = ChannelStorage()
                if UserModel.shared.channelIDs().contains(channel_id) {
                    let channelDict = channelObj.getChannelInfo(channel_id: channel_id)
                    let mute:String = channelDict.value(forKey: "mute") as! String
                    if mute == "0" {
                        if let currentVC = navigationCtrl?.visibleViewController as? ChannelChatPage {
                            if currentVC.channel_id != channel_id {
                                completionHandler([.alert, .badge, .sound])
                            }
                        }else{
                            completionHandler([.alert, .badge, .sound])
                        }
                    }
                }
            }else if type == "call"{
                let call_status = msgDict.value(forKey: "call_type") as! String
                print("check_call_status:\(call_status)")
                print("check_callkitpopup:\(callKitPopup)")
                print("herecomes call")
                if call_status == "missed"{
                    if callKitPopup{
                        self.localCallDB.addNewCall(call_id: msgDict.value(forKey: "call_id") as! String, contact_id: msgDict.value(forKey: "caller_id") as! String, status: "missed", call_type: msgDict.value(forKey: "type") as! String, timestamp: Utility.shared.getTime(), unread_count: "1")
                    }else{
                        completionHandler([.alert, .badge, .sound])
                        self.localCallDB.addNewCall(call_id: msgDict.value(forKey: "call_id") as! String, contact_id: msgDict.value(forKey: "caller_id") as! String, status: "missed", call_type: msgDict.value(forKey: "type") as! String, timestamp: Utility.shared.getTime(), unread_count: "1")
                    }
                }
                
                /*
                //completionHandler([.alert, .badge, .sound])
                if call_status == "missed" {
                    self.localCallDB.addNewCall(call_id: msgDict.value(forKey: "call_id") as! String, contact_id: msgDict.value(forKey: "caller_id") as! String, status: "missed", call_type: msgDict.value(forKey: "type") as! String, timestamp: Utility.shared.getTime(), unread_count: "1")
                }
                 */
            }else{
                completionHandler([.alert, .badge, .sound])
            }
       // }
        
        
        socketClass.sharedInstance.delegate?.gotSocketInfo(dict: msgDict, type: "refreshcount")
    }
    //notification tap redirection
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("TAPPED INFOR \(response)")
        socketClass.sharedInstance.connect()
        if let vc = self.window?.visibleViewController() {
            print("viewcontroller 12345")
            if vc is CallPage {
                
            }else {
                let category_type = response.notification.request.content.categoryIdentifier
                window = UIWindow(frame: UIScreen.main.bounds)
                let categoryArr = category_type.components(separatedBy: ":")
                UserModel.shared.setnotificationID(id:"1")
                
                
                print("notification received 1 \(response.notification.request.content.userInfo)")
                let notificationDict: NSDictionary = response.notification.request.content.userInfo["data"] as! NSDictionary
                let msgDict: NSDictionary = notificationDict.value(forKey: "message_data") as! NSDictionary
                let type = msgDict.value(forKey: "chat_type") as? String ?? ""
                let navigationCtrl = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController

                    if type == "call"{
                        UserModel.shared.setNotificationPrivateID(id:categoryArr[1])
                        let chatObj = menuContainerPage()
                        let nav = UINavigationController(rootViewController: chatObj)
                        nav.isNavigationBarHidden = true
                        window!.rootViewController = nav
                        window!.makeKeyAndVisible()
                        UserModel.shared.setTab(index: 2)
                    }else if categoryArr[0] == "single"{
                        UserModel.shared.setNotificationPrivateID(id:categoryArr[1])
                        let chatObj = menuContainerPage()
                        let nav = UINavigationController(rootViewController: chatObj)
                        nav.isNavigationBarHidden = true
                        window!.rootViewController = nav
                        window!.makeKeyAndVisible()
                        UserModel.shared.setTab(index: 0)
                        
                    }else if categoryArr[0] == "group"{
                        UserModel.shared.setNotificationGroupID(id:categoryArr[1])
                        let chatObj = menuContainerPage()
                        let nav = UINavigationController(rootViewController: chatObj)
                        nav.isNavigationBarHidden = true
                        window!.rootViewController = nav
                        window!.makeKeyAndVisible()
                        UserModel.shared.setTab(index: 1)
                        
                    }else if categoryArr[0] == "channel"{
                        UserModel.shared.setNotificationChannelID(id:categoryArr[1])
                        let chatObj = menuContainerPage()
                        let nav = UINavigationController(rootViewController: chatObj)
                        nav.isNavigationBarHidden = true
                        window!.rootViewController = nav
                        window!.makeKeyAndVisible()
                        UserModel.shared.setTab(index: 2)
                    }else if categoryArr[0] == "groupinvitation"{
                        let chatObj = menuContainerPage()
                        let nav = UINavigationController(rootViewController: chatObj)
                        nav.isNavigationBarHidden = true
                        window!.rootViewController = nav
                        window!.makeKeyAndVisible()
                        UserModel.shared.setTab(index: 1)
                        groupSocket.sharedInstance.getNewGroup()
                        
                    }else if categoryArr[0] == "channelinvitation"{
                        let chatObj = menuContainerPage()
                        let nav = UINavigationController(rootViewController: chatObj)
                        nav.isNavigationBarHidden = true
                        window!.rootViewController = nav
                        window!.makeKeyAndVisible()
                        UserModel.shared.setTab(index: 2)
                    }
            }
        }
        
       
        
    }
}
extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKind(of: UINavigationController.self) {
            
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
            
        } else if vc.isKind(of: UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
                
            } else {
                
                return vc;
            }
        }
    }
}

