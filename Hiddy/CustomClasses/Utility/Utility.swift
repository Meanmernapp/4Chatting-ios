//
//  Utility.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 09/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit
import SystemConfiguration
import AVFoundation
import TrueTime

class Utility: NSObject {
    
    static let shared = Utility()
    static let language = Utility().getLanguage()
    //MARK: Configure app language
    func configureLanguage()  {
        if let path = Bundle.main.path(forResource:UserModel.shared.getAppLanguage(), ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                self.setDefaultLanguage(languageDict: jsonResult as! NSDictionary)
                if UserModel.shared.getAppLanguage() == "عربى" {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
//                    let configuration = FTPopOverMenuConfiguration.default()
//                    configuration?.textAlignment = .right
                }
                else {
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
//                    let configuration = FTPopOverMenuConfiguration.default()
//                    configuration?.textAlignment = .left
                }

            } catch {
                // handle error
            }
        }
    }
    
    //MARK: Convert string to dict
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                // print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //MARK: Get Random like heart color
    func likeHexColorCode() -> String {
        let likeColorArray = ["#05ac90","#ac5b05","#ac1905","#8305ac","#ac0577","#0563ac","#7bac05"]
        let randomIndex = Int(arc4random_uniform(UInt32(likeColorArray.count)))
        return (likeColorArray[randomIndex] )
    }
    //MARK: gradient
    func gradient(size:CGSize) -> CAGradientLayer{
            let gradientLayer:CAGradientLayer = CAGradientLayer()
            gradientLayer.frame.size = size
            gradientLayer.colors = PRIMARY_COLOR
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            //Use diffrent colors
        return gradientLayer
    }
    func Viewgradient(size:CGSize, FColor: UIColor, SColor: UIColor) -> CAGradientLayer{
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = size
        gradientLayer.colors = [FColor,SColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        //Use diffrent colors
        return gradientLayer
    }
    //MARK: get user name from contact
    func getUsername(user_id:String)->String  {
        let localObj = LocalStorage()
        var contact_name = String()
        if (UserModel.shared.contactIDs()?.contains(user_id))!{
        let userDict:NSDictionary = localObj.getContact(contact_id: user_id)
            contact_name = userDict.value(forKey: "contact_name") as! String
        let contact_no:String = userDict.value(forKey: "user_phoneno") as! String
        if contact_name == contact_no{
            contact_name = userDict.value(forKey: "user_phoneno") as! String
        }
        }else{
            let userObj = UserWebService()
            userObj.otherUserDetail(contact_id: user_id, onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                    let cc = response.value(forKey: "country_code") as! Int
                    if response.value(forKey: "user_name") != nil{
                        localObj.addContact(userid: user_id,
                                            contactName: ("+\(cc) " + "\(phone_no)"),
                            userName: response.value(forKey: "user_name") as! String,
                            phone: "\(phone_no)",
                            img: response.value(forKey: "user_image") as! String,
                            about: response.value(forKey: "about") as? String ?? "",
                            type: EMPTY_STRING,
                            mutual:response.value(forKey: "contactstatus") as! String,
                            privacy_lastseen: response.value(forKey: "privacy_last_seen") as! String,
                            privacy_about: response.value(forKey: "privacy_about") as! String,
                            privacy_picture: response.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                    }else{
                        localObj.addContact(userid: user_id,
                                            contactName: ("+\(cc) " + "\(phone_no)"),
                            userName: "",
                            phone: "\(phone_no)",
                            img: response.value(forKey: "user_image") as! String,
                            about: response.value(forKey: "about") as? String ?? "",
                            type: EMPTY_STRING,
                            mutual:response.value(forKey: "contactstatus") as! String,
                            privacy_lastseen: response.value(forKey: "privacy_last_seen") as! String,
                            privacy_about: response.value(forKey: "privacy_about") as! String,
                            privacy_picture: response.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                    }
                   
                }
            })
        }
        return contact_name
    }
    
 
    //regisert for push services
    func registerPushServices()  {
        let pushObj = UserWebService()
        pushObj.registerForNotification(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                UserModel.shared.pushRegistered(status: "1")
            }else if status ==  STATUS_FALSE{
                // print("not registered")
            }
        })
    }
    
    /*
     //old
    func checkDeletedList()  {
        let localObj = LocalStorage()
        let list = localObj.getAllNumbers() as! [DuplicateList]
        let groupingList = Dictionary(grouping: list, by: { $0.phone })
        for phoneKey in groupingList.keys {
            let duplicates = groupingList[phoneKey]!
            if duplicates.count > 1{
                for duplicate in duplicates {
                    let userObj = UserWebService()
                    userObj.checkDeleted(user_id:duplicate.user_id, onSuccess:{response in
                        print("check response \(response)")
                        let status:String = response.value(forKey: "status") as! String
                        if status == "false"{
                            localObj.updateDelete(user_id: duplicate.user_id)
                        }
                    })
                }
            }
        }
    }
    */
    
    
    func checkDeletedList(_ success: @escaping (Bool) -> Void)  {
        print("called checkDeletedList")
        let localObj = LocalStorage()
        let list = localObj.getAllNumbers() as! [DuplicateList]
        print("list_allnum:\(list)")
        let groupingList = Dictionary(grouping: list, by: { $0.phone })
        print("groupingList\(groupingList)")
        for phoneKey in groupingList.keys {
            print("called checkDeletedList1")
            let duplicates = groupingList[phoneKey]!
            print("duplicates\(duplicates)")
            print("duplicates.count\(duplicates.count)")
            if duplicates.count > 0{
                print("called checkDeletedList2")
                for duplicate in duplicates {
                    print("called checkDeletedList3")
                    let userObj = UserWebService()
                    print("duplicate.user_id:\(duplicate.user_id)")
                    userObj.checkDeleted(user_id:duplicate.user_id, onSuccess:{response in
                        print("check response \(response)")
                        let status:String = response.value(forKey: "status") as! String
                        if status == "false"{
                            print("called checkDeletedList6")
                            localObj.updateDelete(user_id: duplicate.user_id)
                        }
                    })
                }
            }
        }
    }
    
    func checkDeletedList1(onSuccess success: @escaping (Bool) -> Void){
         let localObj = LocalStorage()
         let list = localObj.getAllNumbers1() as! [DuplicateList]
         print("list_allnum:\(list)")
         let groupingList = Dictionary(grouping: list, by: { $0.phone })
         print("groupingList1\(groupingList)")
         for phoneKey in groupingList.keys {
             let duplicates = groupingList[phoneKey]!
             print("duplicates1\(duplicates)")
             print("duplicates.count1\(duplicates.count)")
             if duplicates.count > 0{
                 for duplicate in duplicates {
                     let userObj = UserWebService()
                     print("duplicate.user_id1:\(duplicate.user_id)")
                     userObj.checkDeleted(user_id:duplicate.user_id, onSuccess:{response in
                         print("check response1 \(response)")
                         let status:String = response.value(forKey: "status") as! String
                         if status == "false"{
                             print("called of mine dele")
                             localObj.updateDelete(user_id: duplicate.user_id)
                             success(Bool(status) ?? false)
                         }
                     })
                 }
             }
         }
     }
    
    func makeFormat(to:Date) -> String {
        let calendar = NSCalendar.current
        if calendar.isDateInToday(to) {
            return "Today, \(self.timeStamp(time: to, format: "hh:mm a"))"
        }else if calendar.isDateInYesterday(to){
            return "Yesterday, \(self.timeStamp(time: to, format: "hh:mm a"))"
        }else{
            return self.timeStamp(time: to, format: "dd/MM/yyyy hh:mm a")
        }
    }
    
    func getCurrentDate(_ time: String) -> String
    {
        let date = self.getUTC(date: time)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
       // calendar.locale = Locale(identifier: (UserModel.shared.getAppLanguageCode() ?? "en_US"))
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let date12 = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)
        return self.getDateTime(date12 ?? Date())
    }
    
    //convert timestamp with required format
    func timeStamp(time:Date,format:String) -> String {
        let dateFormat = DateFormatter()
//        dateFormat.timeZone = TimeZone.current //Set timezone that you want
//        dateFormat.locale = NSLocale.current
    
        dateFormat.timeZone = TimeZone.current
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormat.dateFormat = format
        return dateFormat.string(from: time)
    }
    
    //MARK: Convert string to double
    func convertToDouble(string:String) -> Double {
        let doubleValue = Double()
        if let distance = Double(string) {
            return distance
        } else {
            // print("Not a valid string for conversion")
        }
        return doubleValue
    }
    //get random number
    func random() -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< 10 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return "\(UserModel.shared.userID()!)\(randomString)"
    }
    func height(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    //convert timestamp with required format
    func timeStamp(stamp:String,format:String) -> String {
        
        let dateNew = self.getUTC(date: stamp)
        let calendar = NSCalendar.current
        if calendar.isDateInToday(dateNew) {
            let dateFormat = DateFormatter()
            //dateFormat.locale = Locale(identifier: (UserModel.shared.getAppLanguageCode() ?? "en_US"))
            dateFormat.locale = Locale(identifier: "en_US_POSIX")

            let dateForm = "hh:mm a"
            dateFormat.dateFormat = dateForm
            let dayWithWeek = "Today"  + " " + dateFormat.string(from: dateNew)
            return dayWithWeek

        }
        else {
            let dateFormat = DateFormatter()
           // dateFormat.locale = Locale(identifier: (UserModel.shared.getAppLanguageCode() ?? "en_US"))
            dateFormat.locale = Locale(identifier: "en_US_POSIX")

            let weekDay = calendar.component(.weekday, from: dateNew)
            let weekArr = ["Sun", "Mon", "Tue", "Wed", "thurs", "Fri", "Sat"]
            let dateForm = "MMM d, yyyy"
            dateFormat.dateFormat = dateForm
            let dateVal = dateFormat.string(from: dateNew)
            return weekArr[weekDay - 1] + ", " + dateVal
        }
    }
    func lastSeenTime(stamp:String,format:String) -> String {
        let dateNew = self.getUTC(date: stamp)
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone.current //Set timezone that you want
        //dateFormat.locale = Locale(identifier: (UserModel.shared.getAppLanguageCode() ?? "en_US"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")

        dateFormat.dateFormat = format
        return dateFormat.string(from: dateNew)
    }
  
    func chatTime(stamp:String) -> String {
        let dateNew = self.getUTC(date: stamp)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "hh:mm a"
        dateFormat.timeZone = TimeZone.current
        //dateFormat.locale = Locale(identifier: (UserModel.shared.getAppLanguageCode() ?? "en_US"))
        
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormat.string(from: dateNew)
    }
    
    
    func chatTimecallspage(stamp:String) -> String {
        let dateNew = self.getUTC(date: stamp)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "E,MMM d, h:mm a"
        dateFormat.timeZone = TimeZone.current
       // dateFormat.locale = Locale(identifier: (UserModel.shared.getAppLanguageCode() ?? "en_US"))
        
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.string(from: dateNew)
    }

    func chatDate(stamp:String) -> String {
        let dateNew = self.getUTC(date: stamp)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd MMM yyyy"
       // dateFormat.locale = Locale(identifier: (UserModel.shared.getAppLanguageCode() ?? "en_US"))
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormat.string(from: dateNew)
    }
    func chatDateInEnglish(stamp:Double) -> String {
        let dateNew = Date(timeIntervalSince1970:stamp)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd MMM yyyy"
        //dateFormat.locale = Locale(identifier: "en_US")
        dateFormat.locale = Locale(identifier: "en_US_POSIX")

        return dateFormat.string(from: dateNew)
    }
    
    func lastSeenDate(stamp:String) -> String {
        let dateNew = self.getUTC(date: stamp)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "E, MMM dd"
        dateFormat.timeZone = TimeZone.current
       // dateFormat.locale = Locale(identifier: "en_US")
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.string(from: dateNew)
    }
    
    //check today ,yesterday
    func dayDifference(from interval : String) -> String{
        let calendar = NSCalendar.current
        let date = self.getUTC(date: interval)

        if calendar.isDateInYesterday(date) { return "Yesterday" }
        else if calendar.isDateInToday(date) { return "Today" }
        else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        else {
            var now = Date()
            let client = TrueTimeClient.sharedInstance
            if client.referenceTime?.now() != nil{
                now = (client.referenceTime?.now())!
            }
            let startOfNow = calendar.startOfDay(for: now)
            let startOfTimeStamp = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = components.day!
            // print(day)
            // print(abs(day))
            if day < 1 { return "\(abs(day)) days ago" }
            else { return "In \(day) days" }
        }
    }
    //add sticky date to single msg
    func arrangeMsg(array:NSMutableArray)->NSMutableArray{
        UserModel.shared.removeDateSticky()
        let arrangedMsg = NSMutableArray()
        for msg in array {
            let model:messageModel.message = msg as! messageModel.message
            let dateMsgDict = NSMutableDictionary()
            if UserModel.shared.dateSticky() == nil {
                
                let chatTime = model.message_data.value(forKey: "chat_time")
//                let date = self.chatDate(stamp: chatTime)
                let date = Date()
                dateMsgDict.setValue(date, forKey: "date")
                dateMsgDict.setValue("date_sticky", forKey: "message_type")
                arrangedMsg.add(messageModel.message.init(sender_id:"",receiver_id: "",message_data: dateMsgDict, date: ""))
                UserModel.shared.setDateSticky(date: model.date)
            }else{
                if !(UserModel.shared.dateSticky()?.contains(model.date))!{
                    dateMsgDict.setValue(model.date, forKey: "date")
                    dateMsgDict.setValue("date_sticky", forKey: "message_type")
                    arrangedMsg.add(messageModel.message.init(sender_id:"",receiver_id: "",message_data: dateMsgDict, date: ""))
                    UserModel.shared.setDateSticky(date: model.date)
                }
            }
            arrangedMsg.add(msg)
        }
        return arrangedMsg
    }
    

    //add sticky date to grop msg
    func arrangeGroupMsg(array:NSMutableArray)->NSMutableArray  {
        UserModel.shared.removeDateSticky()
        let arrangedMsg = NSMutableArray()
        for msg in array {
            let model:groupMsgModel.message = msg as! groupMsgModel.message
            if UserModel.shared.dateSticky() == nil {
                arrangedMsg.add(groupMsgModel.message.init(message_id: "",group_id: "",member_id: "",message_type: "date_sticky",message: "",timestamp: "",lat: "",lon: "",contact_name: "",contact_no: "",country_code: "",attachment: "",thumbnail: "",isDownload: "",local_path: "",date: model.date, admin_id: "", translated_status: "0", translated_msg: ""))
                UserModel.shared.setDateSticky(date: model.date)
            }else{
                if !(UserModel.shared.dateSticky()?.contains(model.date))!{
                    arrangedMsg.add(groupMsgModel.message.init(message_id: "",group_id: "",member_id: "",message_type: "date_sticky",message: "",timestamp: "",lat: "",lon: "",contact_name: "",contact_no: "",country_code: "",attachment: "",thumbnail: "",isDownload: "",local_path: "",date: model.date, admin_id: "", translated_status: "0", translated_msg: ""))
                    UserModel.shared.setDateSticky(date: model.date)
                }
            }
            arrangedMsg.add(msg)
        }
        return arrangedMsg
    }
    
    
    //add sticky date to channel msg
    func arrangeChannelMsg(array:NSMutableArray)->NSMutableArray  {
        UserModel.shared.removeDateSticky()
        let arrangedMsg = NSMutableArray()
        for msg in array {
            let model:channelMsgModel.message = msg as! channelMsgModel.message
            if UserModel.shared.dateSticky() == nil {
                arrangedMsg.add(channelMsgModel.message.init(message_id: "",channel_id: "",message_type: "date_sticky",message: "",timestamp: "",lat: "",lon: "",contact_name: "",contact_no: "",country_code: "",attachment: "",thumbnail: "",isDownload: "",local_path: "",date: model.date, admin_id: "", translated_status: "", translated_msg: "",msg_date:""))
                UserModel.shared.setDateSticky(date: model.date)
            }else{
                if !(UserModel.shared.dateSticky()?.contains(model.date))!{
                    arrangedMsg.add(channelMsgModel.message.init(message_id: "",channel_id: "",message_type: "date_sticky",message: "",timestamp: "",lat: "",lon: "",contact_name: "",contact_no: "",country_code: "",attachment: "",thumbnail: "",isDownload: "",local_path: "",date: model.date, admin_id: "", translated_status: "", translated_msg: "", msg_date: ""))
                    UserModel.shared.setDateSticky(date: model.date)
                }
            }
            arrangedMsg.add(msg)
        }
        return arrangedMsg
    }
   
    //MARK: Show normal alertview
    func showAlert(msg:String)  {
//        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: msg, completion: { (index, title) in
//        })
    }
    func setBadge(vc:UIViewController)  {
        if let tabItems = vc.tabBarController?.tabBar.items as NSArray?
        {
            // In this case we want to modify the badge number of the third tab:
            let single = tabItems[0] as! UITabBarItem
            let group = tabItems[1] as! UITabBarItem
            let channel = tabItems[2] as! UITabBarItem
            let call = tabItems[3] as! UITabBarItem
            
            let groupObj = groupStorage()
            let singleObj = LocalStorage()
            let channelObj = ChannelStorage()
            let callObj = CallStorage()
            group.badgeValue = "\(groupObj.groupOverAllUnreadMsg())"
            single.badgeValue = "\(singleObj.overAllUnreadMsg())"
            channel.badgeValue = "\(channelObj.channelOverAllUnreadMsg())"
            call.badgeValue = "\(callObj.callOverallUnreadMissedCalls())"
            group.badgeColor = UNREAD_COLOR
            single.badgeColor = UNREAD_COLOR
            channel.badgeColor = UNREAD_COLOR
            call.badgeColor = UNREAD_COLOR
            if group.badgeValue == "0"{
                group.badgeValue = nil
            }
            if single.badgeValue == "0"{
                single.badgeValue = nil
            }
            if channel.badgeValue == "0"{
                channel.badgeValue = nil
            }
            if call.badgeValue == "0"{
                call.badgeValue = nil
            }
        }
        
     /*   for tabBarButton in (vc.tabBarController?.tabBar.subviews)!{
            for badgeView in tabBarButton.subviews{
                let className=NSStringFromClass(badgeView.classForCoder)
                if  className == "_UIBadgeView"{
                    badgeView.layer.transform = CATransform3DIdentity
                    badgeView.layer.transform = CATransform3DMakeTranslation(-17.0, 1.0, 1.0)
                }
            }
        }*/
    }
    
    //get current view controller
//    func chatDetail(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> Bool {
//        
//        if let navigationController = controller as? UINavigationController {
//            return chatDetail(controller: navigationController.visibleViewController)
//        }
//        if let tabController = controller as? UITabBarController {
//            if let selected = tabController.selectedViewController {
//                return chatDetail(controller: selected)
//            }
//        }
//        if let presented = controller?.presentedViewController {
//            return chatDetail(controller: presented)
//        }
//        if controller is ChatDetailPage{
//            return true
//        }
//        return false
//    }

    //MARK: Network rechability
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        if !ret {
            isSocketConnected = false
        }
        return ret
    }
    
    //MARK: Check string is empty
    func checkEmptyWithString(value:String) -> Bool {
        if  (value == "") || (value == "NULL") || (value == "(null)") || (value == "<null>") || (value == "Json Error")  || (value.isEmpty) ||  value.trimmingCharacters(in: .whitespaces).isEmpty || value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty  {
            return true
        }
        return false
    }
    
    //MARK:set App language
    func setDefaultLanguage(languageDict: NSDictionary){
        UserDefaults.standard.set(languageDict, forKey: "app_language")
    }
    func getLanguage() -> NSDictionary? {
        return UserDefaults.standard.value(forKey: "app_language") as? NSDictionary
    }
 
    func thumbnailForVideoAtURL(url: URL) -> UIImage? {
        let asset = AVURLAsset.init(url: url)
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
//        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero
        do{
            let time:CMTime = CMTimeMakeWithSeconds(Float64(0),preferredTimescale: Int32(200))
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: img)
            return image
        } catch _ {
            // print("*** Error generating thumbnail: \(error.localizedDescription)")
            return #imageLiteral(resourceName: "channel_detail_bg")
        }

    }
    func thumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        var time = asset.duration
        time.value = min(0, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage.init(cgImage: imageRef)
        } catch _ {
            // print("*** Error generating thumbnail: \(error.localizedDescription)")
            return #imageLiteral(resourceName: "channel_detail_bg")
        }
    }
    func videoThumbURL(url: URL, onSuccess success: @escaping (UIImage?) -> Void) {
        let path = url // some URL
        do {
            let contentString = path.absoluteURL
            let asset = AVAsset(url: contentString)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            var time = asset.duration
            time.value = min(0, 1)
            DispatchQueue.main.async {
                do {
                    let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                    success(UIImage.init(cgImage: imageRef))
                } catch _ {
                    // print("*** Error generating thumbnail: \(error.localizedDescription)")
                    success(#imageLiteral(resourceName: "channel_detail_bg"))
                }
            }
        } catch _ {
            // print("*** Error generating thumbnail: \(error.localizedDescription)")
            success(#imageLiteral(resourceName: "channel_detail_bg"))
        }
    }

    
    /*
    //check weather phone no available on phone book
    func searchPhoneNoAvailability(phoneNo: String)->String {
        let filter = UserModel.shared.contactList()?.filter({ $0["phone_no"] == phoneNo })
        if filter != nil {
            if filter?.count != 0{
            let result : [String: Any] = filter![0]
            return result["contact_name"] as! String
            }else{
                return EMPTY_STRING
            }
        }else{
            return EMPTY_STRING
        }
    }
     */
    
    //check weather phone no available on phone book
    func searchPhoneNoAvailability(phoneNo: String)->String {
        let filter = UserModel.shared.contactList()?.filter({ $0["phone_no"] == phoneNo })
        if filter != nil {
            if filter?.count != 0{
            var contactName = EMPTY_STRING
                for val in filter ?? [[String: String]]() {
                    let result : [String: Any] = val
                    if (val["contact_name"] as? String ?? EMPTY_STRING) != "" {
                        contactName = (result["contact_name"] as? String ?? "")
                    }
                }
            return contactName
            }else{
                return EMPTY_STRING
            }
        }else{
            return EMPTY_STRING
        }
    }
    
    
 
    //MARK: OS compatilbity Check
    func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                      options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
    }
    
    func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                      options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
    }
    
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                      options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
    }
    
    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                      options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
    }
    
    func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                      options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
    }
    func deleteImageAndVideoFromPhotoLibrary(msg_id: String,type: String) {
        let localDB = LocalStorage()
        let groupDB = groupStorage()
        let channelDB = ChannelStorage()

        var localPath = ""
        if type == "single" {
            let msgDict = localDB.getMsg(msg_id: msg_id)
            localPath = msgDict.value(forKey: "message_data.local_path") as? String ?? ""
        }
        else if type == "group" {
            let msgDict = groupDB.getGroupMsg(msg_id: msg_id)
            localPath = msgDict!.local_path
        }
        else {
            let msgDict = channelDB.getChannelMsg(msg_id: msg_id)
            localPath = msgDict!.local_path
        }
        PhotoAlbum.sharedInstance.delete(local_ID: [localPath], onSuccess: {response in
        })
    }
    func addToLocal(requestDict:NSDictionary,chat_id:String,contact_id:String)  {
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
        var statusData : String = EMPTY_STRING
        let localDB = LocalStorage()
        let msg_id:String = requestDict.value(forKeyPath: "message_data.message_id") as! String
        let type : String = requestDict.value(forKeyPath: "message_data.message_type") as? String ?? ""
        if type == "image"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as? String ?? "image"
        }else if type == "location"{
            lat = requestDict.value(forKeyPath: "message_data.lat") as! String
            lon = requestDict.value(forKeyPath: "message_data.lon") as! String
        }else if type == "contact"{
            //    cc = requestDict.value(forKeyPath: "message_data.cc") as! String
            cName = requestDict.value(forKeyPath: "message_data.contact_name") as! String
            cNo = requestDict.value(forKeyPath: "message_data.contact_phone_no") as! String
        }else if type == "video"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
            if (requestDict.value(forKeyPath: "message_data.thumbnail") != nil){
            thumbnail = requestDict.value(forKeyPath: "message_data.thumbnail") as! String
            }
        }else if type == "document"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
        }
        else if type == "audio"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
        }
        else if type == "story" {
            statusData = requestDict.value(forKeyPath: "message_data.status_data") as? String ?? ""
        }
        else if type == "isDelete" {
//            self.deleteImageAndVideoFromPhotoLibrary(msg_id: msg_id, type: "single")
            localDB.updateMessage(message_type: type, msg_id: msg_id)
            return
        }else if type == "gif"{
            attach = requestDict.value(forKeyPath: "message_data.attachment") as! String
        }

        //add local db
        let msgDict = localDB.getMsg(msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String)
        var readCount =  String()
        if msgDict.value(forKeyPath: "message_data.read_status") == nil{
            readCount = "1"
        }else{
            readCount = msgDict.value(forKeyPath: "message_data.read_status") as! String
        }
        
        let TxtMsg = requestDict.value(forKeyPath: "message_data.message") as! String
        
        localDB.addChat(msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String,
                     chat_id: chat_id,
                     sender_id:requestDict.value(forKeyPath: "sender_id") as? String ?? "",
                     receiver_id:requestDict.value(forKeyPath: "receiver_id") as? String ?? "",
                     msg_type: requestDict.value(forKeyPath: "message_data.message_type") as? String ?? "",
                     msg:TxtMsg.replacingOccurrences(of: "'", with: "''") ,
                     time: requestDict.value(forKeyPath: "message_data.chat_time") as! String,
                     lat: lat,
                     lon: lon,
                     contact_name: cName,
                     contact_no: cNo,
                     country_code: cc,
                     attachment: attach,thumbnail:thumbnail,read_count:readCount, statusData: statusData, blocked: "0")
        let sender_id = requestDict.value(forKeyPath: "message_data.sender_id")! as! String
        var unreadcount = Int()
        
        if sender_id == UserModel.shared.userID()! as String {
            unreadcount = 0
        }else{
         unreadcount = localDB.getUnreadCount(contact_id: requestDict.value(forKeyPath: "message_data.sender_id")! as! String)
        }
        
        localDB.addRecent(contact_id: contact_id, msg_id: requestDict.value(forKeyPath: "message_data.message_id") as! String, unread_count: "\(unreadcount)",time: requestDict.value(forKeyPath: "message_data.chat_time") as! String)
    }
    
    // add to local db
    func addGroupMsgToLocal(group_id:String,requestDict:NSDictionary)  {
        let groupDB = groupStorage()
        
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
        var admin : String = EMPTY_STRING
        var ignoreInsert : Bool = false
        let msg_id:String = requestDict.value(forKey: "message_id") as! String
        let type : String = requestDict.value(forKey: "message_type") as! String
        if type == "image"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "location"{
            lat = requestDict.value(forKey: "lat") as! String
            lon = requestDict.value(forKey: "lon") as! String
        }else if type == "contact"{
            cName = requestDict.value(forKey: "contact_name") as! String
            cNo = requestDict.value(forKey: "contact_phone_no") as! String
        }else if type == "video"{
            attach = requestDict.value(forKey: "attachment") as! String
            thumbnail = requestDict.value(forKey: "thumbnail") as? String ?? ""
            let member_id = requestDict.value(forKey: "member_id") as! String
            if member_id == UserModel.shared.userID()! as String {
                ignoreInsert = true
            }
        }else if type == "document"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "group_image"{
            attach = requestDict.value(forKey: "attachment") as! String
            groupDB.updateGroupIcon(group_id: group_id, group_icon: attach)
        }else if type == "audio"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "isDelete"{
            //            self.deleteImageAndVideoFromPhotoLibrary(msg_id: msg_id, type: "group")
            groupDB.updateGroupMessage(msg_id:msg_id,msg_type:type)
        }else if type == "admin"{
            admin = requestDict.value(forKey: "group_admin_id") as! String
            attach = requestDict.value(forKey: "attachment") as! String
            let member_id = requestDict.value(forKey: "member_id") as! String
            groupDB.makeAdmin(member_key: "\(group_id)\(member_id)",status:attach)
        }else if type == "add_member" {
            admin = requestDict.value(forKey: "group_admin_id") as! String
//            print("add member group msg \(requestDict)")
            var anyObj:Any?
            
            if let membersStr = requestDict.value(forKey: "attachment") as? String {
                print("*****this is string \(requestDict)")

                anyObj = membersStr.toJSONString()
                   // convert 'AnyObject' to Array<Business>
                attach =  membersStr

            }else{
                print("*****this is array \(requestDict)")
                attach =  Utility.shared.convertJson(from: (requestDict.value(forKey: "attachment"))!)!
                anyObj = attach.toJSONString()
            }
            // convert NSData to 'AnyObject'
        
            let member = NSMutableArray()
            member.addObjects(from: [anyObj as Any])
            print("anyobbbjjjj \(anyObj)")
            let newMembers:NSArray = member.object(at: 0) as! NSArray
            print("anyobbbjjjj 1 \(member)")

            // Will return an object or nil if JSON decoding fails
            groupSocket.sharedInstance.addGroupMembers(groupId: group_id, members: newMembers, type: "1")
        }else if type == "remove_member"{
            admin = requestDict.value(forKey: "group_admin_id") as! String
            let member_id = requestDict.value(forKey: "member_id") as! String
            groupDB.removeMember(member_key: "\(group_id)\(member_id)")
            if member_id == UserModel.shared.userID()! as String{
                groupDB.groupExit(group_id: group_id)
            }
        } else if type == "left"{
            admin = requestDict.value(forKey: "member_id") as! String//admin and user name are same
            groupDB.removeMember(member_key: "\(group_id)\(admin)")
        }else if type == "subject"{
            let group_name = requestDict.value(forKey: "group_name") as! String
            //            let group_name = requestDict.value(forKey: "member_name") as! String
            groupDB.updateGroupName(group_id: group_id, group_name: group_name)
        }else if type == "change_number"{
            let member_id = requestDict.value(forKey: "member_id") as! String
            cNo = requestDict.value(forKey: "contact_phone_no") as! String
            attach = requestDict.value(forKey: "attachment") as! String
            
            let name = Utility.shared.searchPhoneNoAvailability(phoneNo: cNo)
            let localDB = LocalStorage()
            if name == EMPTY_STRING{
                localDB.updateNumber(contact_id: member_id, no: cNo, name: cNo)
            }else{
                localDB.updateNumber(contact_id: member_id, no: cNo, name: name)
            }
        }else if type == "gif" {
            attach = requestDict.value(forKey: "attachment") as! String
        }
        
        if !ignoreInsert{
            let TxtMsg = requestDict.value(forKey: "message")! as! String
            
            //add local db
            groupDB.addGroupChat(msg_id: requestDict.value(forKey: "message_id") as! String,
                                 group_id: group_id,
                                 member_id: requestDict.value(forKey: "member_id")! as! String,
                                 msg_type: requestDict.value(forKey: "message_type")! as! String,
                                 msg: TxtMsg.replacingOccurrences(of: "'", with: "''"),
                                 time: requestDict.value(forKey: "chat_time") as? String ?? "",
                                 lat: lat,
                                 lon: lon,
                                 contact_name: cName,
                                 contact_no: cNo,
                                 country_code: cc,
                                 attachment: attach,
                                 thumbnail: thumbnail, admin_id: admin,read_status:"0")
            
            if  UserModel.shared.groupIDs().contains(group_id) {
                let unreadcount = groupDB.getGroupUnreadCount(group_id: group_id)
                let groupDict = groupDB.getGroupInfo(group_id: group_id)
                let lastMsgInfo = groupDB.getLastMsgInfo(group_id: group_id)

                groupDB.updateGroupDetails(group_id: group_id, mute: groupDict.value(forKey: "mute") as! String, exit: groupDict.value(forKey: "exit") as! String, message_id: lastMsgInfo.value(forKey: "message_id") as! String, timestamp: lastMsgInfo.value(forKey: "chat_time") as! String, unread_count: "\(unreadcount)")
                groupSocket.sharedInstance.groupChatReceived()
            }
        }
    }
    
    // add to channel db
    func addChannelMsgToLocal(channel_id:String,requestDict:NSDictionary,msg_id:String,time:String,admin:String)  {
        let channelDB = ChannelStorage()
        var lat : String = EMPTY_STRING
        var lon : String = EMPTY_STRING
        var cName : String = EMPTY_STRING
        let cc : String = EMPTY_STRING
        var cNo : String = EMPTY_STRING
        var attach : String = EMPTY_STRING
        var thumbnail : String = EMPTY_STRING
//        let msg_id:String = requestDict.value(forKey: "message_id") as? String ?? ""
        let type : String = requestDict.value(forKey: "message_type") as! String
        if type == "image"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "location"{
            lat = requestDict.value(forKey: "lat") as! String
            lon = requestDict.value(forKey: "lon") as! String
        }else if type == "isDelete" {
//            self.deleteImageAndVideoFromPhotoLibrary(msg_id: msg_id, type: "channel")
            channelDB.updateChannelMessage(msg_id:msg_id,msg_type:type)
            return 
        }else if type == "contact"{
            cName = requestDict.value(forKey: "contact_name") as! String
            cNo = requestDict.value(forKey: "contact_phone_no") as! String
        }else if type == "video"{
            attach = requestDict.value(forKey: "attachment") as! String
            thumbnail = requestDict.value(forKey: "thumbnail") as! String
        }else if type == "document"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "audio"{
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "subject" || type == "channel_des"{
            channelDB.updateChannelName(channel_id: channel_id, name: requestDict.value(forKey: "channel_name") as! String, des: requestDict.value(forKey: "message") as! String)
        }else if type == "channel_image"{
            channelDB.updateChannelIcon(channel_id: channel_id, channel_icon: requestDict.value(forKey: "attachment") as! String)
            attach = requestDict.value(forKey: "attachment") as! String
        }else if type == "gif"{
            attach = requestDict.value(forKey: "attachment") as! String
        }
        
        //add local db
        let TxtMsg = requestDict.value(forKey: "message")! as! String
        var msg_date = String()
        if requestDict[ "message_date"] != nil{
            msg_date = requestDict.value(forKey: "message_date")! as! String
        }else{
            msg_date = ""
        }
       

        channelDB.addChannelMsg(msg_id: msg_id,
                             channel_id:channel_id ,
                             admin_id: admin,
                             msg_type: requestDict.value(forKey: "message_type")! as! String,
                             msg:TxtMsg.replacingOccurrences(of: "'", with: "''"),
                             time: time,
                             lat: lat,
                             lon: lon,
                             contact_name: cName,
                             contact_no: cNo,
                             country_code: cc,
                             attachment: attach,
                             thumbnail: thumbnail,read_status:"0", msg_date: msg_date)
        
        if  UserModel.shared.channelIDs().contains(channel_id) {
            let unreadcount = channelDB.getChannelUnreadCount(channel_id: channel_id)
            let channelDict = channelDB.getChannelInfo(channel_id: channel_id)
            // print("channel info \(channelDict)")
            let lastMsgInfo = channelDB.getLastMsgInfo(channel_id: channel_id)

            channelDB.updateChannelDetails(channel_id: channel_id, mute: channelDict.value(forKey: "mute") as! String, report: channelDict.value(forKey: "report") as! String, message_id:  lastMsgInfo.value(forKey: "message_id") as! String, timestamp:  lastMsgInfo.value(forKey: "chat_time") as! String, unread_count: "\(unreadcount)")
        }
    }
    
    func translate(msg: String, callback:@escaping (_ translatedText:String) -> ()) {
            var request = URLRequest(url: URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(GOOGLE_API_KEY)")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

          let targetLanguage = UserModel().translatedLanguage()
//        let targetLanguage = "ar"

                let jsonRequest = [
                    "q": msg,
                    "target": targetLanguage as Any,
                    ] as [String : Any]

                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonRequest, options: .prettyPrinted) {
                    request.httpBody = jsonData
                    let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        guard error == nil else {
                            print("Something went wrong: \(String(describing: error?.localizedDescription))")
                            return
                        }

                        if let httpResponse = response as? HTTPURLResponse {
                                if let data = data {
                                    print("Response [\(httpResponse.statusCode)] - \(data)")
                                }
                            do {
                                if let data = data {
                                    if let json = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                        if let jsonData = json["data"] as? [String : Any] {
                                            if let translations = jsonData["translations"] as? [NSDictionary] {
                                                if let translation = translations.first as? [String : Any] {
                                                    if let translatedText = translation["translatedText"] as? String {
                                                        let replaced = translatedText.replacingOccurrences(of: "I&#39;m", with: "I'm")
                                                        callback(replaced)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } catch {
                                print("Serialization failed: \(error.localizedDescription)")
                            }
                        }
                    }

                    task.resume()
                }
        }
    
    
    //get formatted json from array
    func convertJson(from object:Any) -> String? {
      
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    //no network go offline
    func goToOffline(){
        //no network
    }
    
    func getDateTime(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    //get current time
    func getTime() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let client = TrueTimeClient.sharedInstance
        if client.referenceTime?.now() != nil{
            return formatter.string(from: (client.referenceTime?.now())!)
        }else{
            return formatter.string(from: Date())
        }
    }
    //Convert UTC String to UTC Date
    func getUTC(date:String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if formatter.date(from: date) == nil{
            
        }
        //return formatter.date(from: date)!
        return formatter.date(from: date) ?? Date()
    }
    func getSticky(date:String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
       // return formatter.date(from: date)!
        return formatter.date(from: date) ?? Date()
    }
    // Set Date
    func setChatDate(timeStamp:String) -> String {
        let calendar = NSCalendar.current
        let date = self.getUTC(date: timeStamp)
      
        let dateStr:String = Utility.shared.lastSeenDate(stamp: timeStamp)
        let time:String = Utility.shared.chatTime(stamp: timeStamp)
      
        let  yday:String = Utility.shared.getLanguage()!.value(forKey:"yesterday") as! String

        if calendar.isDateInYesterday(date) {
            return "\(yday)"
        }
        else if calendar.isDateInToday(date) {
            return "\(time)"
        }
        else {
            return "\(dateStr)"
        }
    }
    
    // get last seen 
    func setStatus(timeStamp:String) -> String {
        let calendar = NSCalendar.current
        let date = self.getUTC(date: timeStamp)
      
        let dateStr:String = Utility.shared.lastSeenTime(stamp: timeStamp, format: "dd-MMM-yyyy")
        let time:String = Utility.shared.lastSeenTime(stamp: timeStamp, format: "h:mm a")
      
        let  today:String = Utility.shared.getLanguage()!.value(forKey: "last_seen_today") as! String
        let  yday:String = Utility.shared.getLanguage()!.value(forKey: "last_seen_yday") as! String
        let  at:String = Utility.shared.getLanguage()!.value(forKey: "at") as! String
        let  lastSeenText:String = Utility.shared.getLanguage()!.value(forKey: "last_seen") as! String
        if calendar.isDateInYesterday(date) {
            return "\(yday) \(time)"
        }
        else if calendar.isDateInToday(date) {
            return "\(today) \(time)"
        }
        else {
            return "\(lastSeenText) \(dateStr) \(at) \(time)"
        }
    }
    func getPreviewStatusTime(timeStamp:String) -> String {
        let lastSeenDate = self.getUTC(date: timeStamp)
        let time:String = Utility.shared.lastSeenTime(stamp: timeStamp, format: "h:mm a")
        let checkDay:String = Utility.shared.timeCalculationSinceAgo(lastSeenDate, numericDates: false)
        let today:String = Utility.shared.getLanguage()!.value(forKey: "today") as! String
        let yday:String = Utility.shared.getLanguage()!.value(forKey: "yesterday") as! String
        let at:String = Utility.shared.getLanguage()!.value(forKey: "just_now") as! String
        if checkDay == "Today"{
            let calendar = NSCalendar.current
            if calendar.isDateInYesterday(lastSeenDate) {
                return "\(yday) \(time)"
            }
            else {
                return  "\(today) \(time)"
            }
            
        }else if checkDay == "Yesterday"{
            return "\(yday) \(time)"
        }
        else if checkDay == "Just Now" {
            return at
        }
        else{
            return checkDay
        }
    }
    func timeCalculationSinceAgo(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        var now = Date()
        
        let client = TrueTimeClient.sharedInstance
        if client.referenceTime?.now() != nil{
            now = (client.referenceTime?.now())!
        }
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            return "Yesterday"
        } else if (components.hour! >= 2) {
            return "Today"
        } else if (components.hour! >= 1){
            return "Today"
        } else if (components.minute! >= 2) {
            let minsAgo:String = Utility.shared.getLanguage()!.value(forKey: "ago") as! String
            return "\(components.minute!) \(minsAgo)"
        } else if (components.minute! >= 1) {
            let ago:String = Utility.shared.getLanguage()!.value(forKey: "min_ago") as! String
            return "\(components.minute!) \(ago)"
        } else if (components.second! >= 0) {
            return "Just Now"
        } else {
            return "Just Now"
        }
        
    }
    func timerInAppLanguage(count: String) -> String{
        let countArr = count.map({String($0)})
        print(countArr)
        var countLan = ""
        let countLanArr = (Utility.shared.getLanguage()?.value(forKey: "count")) as? NSArray ?? ["0","1","2","3","4","5","6","7","8","9","."]
        for count in countArr {
            if count == ":" || count == "."{
                countLan = countLan + count
            }
            else {
                countLan = countLan + (countLanArr[Int(count) ?? 0] as? String ?? "")
            }
        }
        return countLan
    }
    func countInAppLanguage(count: Int) -> String{
        let countArr = "\(count)".map({String($0)})
        print(countArr)
        var countLan = ""
        let countLanArr = (Utility.shared.getLanguage()?.value(forKey: "count")) as? NSArray ?? ["0","1","2","3","4","5","6","7","8","9","."]
        for count in countArr {
            countLan = countLan + (countLanArr[Int(count) ?? 0] as? String ?? "")
        }
        return countLan
    }
    //===============

    func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        var now = Date()
        
        let client = TrueTimeClient.sharedInstance
        if client.referenceTime?.now() != nil{
            now = (client.referenceTime?.now())!
        }
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            return "Yesterday"
        } else if (components.hour! >= 2) {
            return "Today"
        } else if (components.hour! >= 1){
            return "Today"
        } else if (components.minute! >= 2) {
            return "Today"
        } else if (components.minute! >= 1){
            return "Today"
        } else if (components.second! >= 3) {
            return "Today"
        } else {
            return "Today"
        }
        
    }
    
    func getNames(membersStr:String) ->String {
        print("chcccckkk \(membersStr)")
        if membersStr != ""{
        let membersArray = NSMutableArray()
        // convert NSData to 'AnyObject'
        let anyObj = membersStr.toJSONString()
        let member = NSMutableArray()
        member.addObjects(from: [anyObj as Any])
        let newMembers:NSArray = member.object(at: 0) as! NSArray
        // Will return an object or nil if JSON decoding fails
        for user in newMembers{
            let dict:NSDictionary = user as! NSDictionary
            let user_id:String = dict.value(forKey: "member_id") as! String
//            let member_no:String = dict.value(forKey: "member_no") as! String
            var name = String()
            if user_id == UserModel.shared.userID()! as String{
                name = "You"
            }else{
                name = Utility.shared.getUsername(user_id: user_id)
            }
            membersArray.add(name)
        }
            
        let finalString = membersArray.componentsJoined(by: ",")
        return finalString
        }else{
            return ""
        }
    }
}
