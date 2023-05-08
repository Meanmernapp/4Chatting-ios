//
//  UserModel.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 10/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    static let shared = UserModel()
    var LANGUAGE_CODE = "en"
    //Listen Soon
    func setListen(Language: Bool){
        UserDefaults.standard.set(Language, forKey: "listen_soon")
    }

    func getListen() -> Bool {
        return UserDefaults.standard.value(forKey: "listen_soon") as? Bool ?? true
    }
    //MARK: app language
    func setAppLanguage(Language: String){
        UserDefaults.standard.set(Language, forKey: "language_name")
    }

    func getAppLanguage() -> String? {
        return UserDefaults.standard.value(forKey: "language_name") as? String ?? "English"
    }
    func setAppLanguageCode(Language: String){
        UserDefaults.standard.set(Language, forKey: "language_code")
    }
    func getAppLanguageCode() -> String {
        return UserDefaults.standard.value(forKey: "language_code") as? String ?? LANGUAGE_CODE
    }
    
    //MARK: set theme 
    func set(theme: NSString){
        UserDefaults.standard.set(theme, forKey: "app_theme")
    }
    func theme()-> NSString? {
        return UserDefaults.standard.value(forKey: "app_theme") as! NSString?
    }
    
    //MARK: set language
    func setLanguage(lang: String){
        UserDefaults.standard.set(lang, forKey: "language_sel")
    }
    func getLanguage() -> String? {
        return UserDefaults.standard.value(forKey: "language_sel") as? String
    }
    
    //MARK: store & get translated langugage
       func setNone(language: String){
           UserDefaults.standard.set(language, forKey: "none")
       }
       func getNone() -> String? {
           return UserDefaults.standard.value(forKey: "none") as? String
       }
    
    //MARK: POINT first call

    func setFirstCall(call: NSString){
        UserDefaults.standard.set(call, forKey: "first_hiddy_call")
    }
    func firstHiddyCall()-> NSString? {
        return UserDefaults.standard.value(forKey: "first_hiddy_call") as? NSString
    }
    
    //MARK:  call socketenable
    func setCallSocket(status: NSString?){
        UserDefaults.standard.set(status, forKey: "call_socket_handler_status")
    }
    func callSocketStatus()-> NSString? {
        return UserDefaults.standard.value(forKey: "call_socket_handler_status") as? NSString
    }
    
    //MARK: store & get user id
    func setUserID(userID: NSString){
        if let defaults = UserDefaults(suiteName: NOTIFICATION_EXTENSION) {
            defaults.set(userID, forKey: "user_id")
        }
    }
    func userID() -> NSString? {
        if let defaults = UserDefaults(suiteName: NOTIFICATION_EXTENSION) {
            let defaults = defaults.string(forKey: "user_id")
            return defaults as NSString?
        }
        return ""
    }
    func setnotificationID(id: NSString){
        UserDefaults.standard.set(id, forKey: "notificationID")
    }

    func notificationID() -> NSString? {
        return UserDefaults.standard.value(forKey: "notificationID") as? NSString
    }

    //MARK: store & get tab index
    func setTab(index: Int){
        UserDefaults.standard.set(index, forKey: "tab_index")
    }
    func tabIndex() -> Int {
        return UserDefaults.standard.value(forKey: "tab_index") as! Int
    }
   
    //MARK: store & get notifiy group
    func setNotificationGroupID(id: String){
        UserDefaults.standard.set(id, forKey: "notify_groupid")
    }
    func notificationGroupID() -> String? {
        return UserDefaults.standard.value(forKey: "notify_groupid") as? String
    }
    //MARK: store & get notifiy calls
    func setNotificationCallID(id: String){
        UserDefaults.standard.set(id, forKey: "notify_callid")
    }
    func notificationCallID() -> String? {
        return UserDefaults.standard.value(forKey: "notify_callid") as? String
    }
    func setNotificationCallType(type: String){
        UserDefaults.standard.set(type, forKey: "notify_calltype")
    }
    func notificationCallType() -> String? {
        return UserDefaults.standard.value(forKey: "notify_calltype") as? String
    }
    
    //MARK: store & get notifiy private
    func setNotificationPrivateID(id: String){
        UserDefaults.standard.set(id, forKey: "notify_privateid")
    }
    func notificationPrivateID() -> String? {
        return UserDefaults.standard.value(forKey: "notify_privateid") as? String
    }
    //MARK: store & get notifiy channel
    func setNotificationChannelID(id: String){
        UserDefaults.standard.set(id, forKey: "notify_channelid")
    }
    func notificationChannelID() -> String? {
        return UserDefaults.standard.value(forKey: "notify_channelid") as? String
    }
    //MARK: store & get user accesstoken
    func setAccessToken(userToken: NSString){
        if let defaults = UserDefaults(suiteName: NOTIFICATION_EXTENSION) {
            defaults.set(userToken, forKey: "user_accessToken")
        }
    }

    //MARK: store & get user details
    func setUserModels(userDict: NSDictionary){
        UserDefaults.standard.set(userDict, forKey: "user_dict")
    }
    func userDict() -> NSDictionary {
        if UserDefaults.standard.value(forKey: "user_dict") != nil{
            return UserDefaults.standard.value(forKey: "user_dict") as! NSDictionary
        }
        return NSDictionary()
    }
    //MARK: store & get translated langugage
       func setTranslated(language: String){
           UserDefaults.standard.set(language, forKey: "translated_language")
       }
       func translatedLanguage() -> String? {
           return UserDefaults.standard.value(forKey: "translated_language") as? String
       }
    //MARK: store & get antmedia
      func setAntMedia(dict: NSDictionary){
        let data = try? NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true)
          UserDefaults.standard.set(data, forKey: "ant_media_dict")
      }
      func antMedia() -> NSDictionary {
        let outData = UserDefaults.standard.data(forKey: "ant_media_dict")
        let dict = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(outData!)
        return dict as! NSDictionary
      }
    
    //MARK: set cache
    func setCache(){
        UserDefaults.standard.removeObject(forKey: "recent_chats")
        let recents = LocalStorage.sharedInstance.getRecentList(isFavourite: "0")
        UserDefaults.standard.set(recents, forKey: "cache_recents")
        
        let contacts = LocalStorage.sharedInstance.getContactList()
        UserDefaults.standard.set(contacts, forKey: "cache_contacts")

        let groups = groupStorage.sharedInstance.getGroupList()
        UserDefaults.standard.set(groups, forKey: "cache_groups")
        
        let all_channels = ChannelStorage.sharedInstance.getChannelList(type: "all")
        UserDefaults.standard.set(all_channels, forKey: "cache_all_channels")
        
        let own_channels = ChannelStorage.sharedInstance.getChannelList(type: "own")
        UserDefaults.standard.set(own_channels, forKey: "cache_own_channels")
        
        
    }
    
    
    //MARK: set contactid
    func setContactIDs(IDs: NSMutableArray){
        UserDefaults.standard.removeObject(forKey: "contact_ids")
        UserDefaults.standard.set(IDs, forKey: "contact_ids")
    }
    func contactIDs() -> NSArray? {
        var contactArray = NSArray()

        if UserModel.shared.userID() != nil{
        if UserDefaults.standard.value(forKey: "contact_ids") != nil{
            contactArray = UserDefaults.standard.value(forKey: "contact_ids") as! NSArray
        }else{
            let defaultValue = NSMutableArray()
            defaultValue.add(UserModel.shared.userID()!)
            contactArray = defaultValue
        }
        }
        return contactArray
    }
    
    //MARK: set group ids
    func setGroupIDs(IDs: NSMutableArray){
        UserDefaults.standard.removeObject(forKey: "group_ids")
        UserDefaults.standard.set(IDs, forKey: "group_ids")
    }
    func groupIDs() -> NSArray {
        var groupArray = NSArray()
        if UserDefaults.standard.value(forKey: "group_ids") != nil{
            groupArray = UserDefaults.standard.value(forKey: "group_ids") as! NSArray
        }else{
                if(UserModel.shared.userID() != nil) {
                let defaultValue = NSMutableArray()
                defaultValue.add(UserModel.shared.userID()!)
                groupArray = defaultValue
            }
        }
        return groupArray
    }
    
    //MARK: set active group ids
    func setActiveGroup(IDs: NSMutableArray){
        UserDefaults.standard.removeObject(forKey: "active_group_ids")
        UserDefaults.standard.set(IDs, forKey: "active_group_ids")
    }
    func activeGroupIDs() -> NSArray? {
        var groupArray = NSArray()
        if UserDefaults.standard.value(forKey: "active_group_ids") != nil{
            groupArray = UserDefaults.standard.value(forKey: "active_group_ids") as! NSArray
        }
        return groupArray
    }
    
    //MARK: set active channel ids
    func setActiveChannels(IDs: NSMutableArray){
        UserDefaults.standard.removeObject(forKey: "active_channel_ids")
        UserDefaults.standard.set(IDs, forKey: "active_channel_ids")
    }
    func activeChannelIDs() -> NSArray? {
        var channelArray = NSArray()
        if UserDefaults.standard.value(forKey: "active_channel_ids") != nil{
            channelArray = UserDefaults.standard.value(forKey: "active_channel_ids") as! NSArray
        }
        return channelArray
    }
    //set all contacts
    func setAllContacts(contacts: [[String:String]]){
        UserDefaults.standard.removeObject(forKey: "contact_list")
        UserDefaults.standard.set(contacts, forKey: "contact_list")
    }
    func contactList() -> [[String:String]]? {
        return UserDefaults.standard.value(forKey: "contact_list") as? [[String:String]]
    }
    func removeContactList() {
        UserDefaults.standard.removeObject(forKey: "contact_list")
    }
    //MARK: set channel ids
    func setChannelIDs(IDs: NSMutableArray){
        UserDefaults.standard.removeObject(forKey: "channel_ids")
        UserDefaults.standard.set(IDs, forKey: "channel_ids")
    }
    func channelIDs() -> NSArray {
        var channelArray = NSArray()
        if UserDefaults.standard.value(forKey: "channel_ids") != nil{
            channelArray = UserDefaults.standard.value(forKey: "channel_ids") as! NSArray
        }else{
            if UserModel.shared.userID() != nil{
            let defaultValue = NSMutableArray()
            defaultValue.add(UserModel.shared.userID()!)
            channelArray = defaultValue
            }
        }
        return channelArray
    }

    //MARK: set msg date Sticky
    func setDateSticky(date: String){
        var array = NSMutableArray()
        if self.dateSticky() == nil {
            array.add(date)
        }else{
            array = NSMutableArray.init(array: self.dateSticky()!)
            array.add(date)
        }
        UserDefaults.standard.set(array, forKey: "date_Sticky")
    }
    
    func dateSticky() -> NSArray? {
        return UserDefaults.standard.value(forKey: "date_Sticky") as? NSArray
    }
    func removeDateSticky() {
        UserDefaults.standard.removeObject(forKey: "date_Sticky")
    }
    //MARK: set user info
    func setUserInfo(userDict:NSDictionary)  {
        UserModel.shared.setUserModels(userDict: userDict)
        UserModel.shared.setUserID(userID: userDict.value(forKey: "_id") as! NSString)
        UserModel.shared.setUserName(name: userDict.value(forKey: "user_name") as! NSString)
        let phoneno:NSNumber = userDict.value(forKey: "phone_no") as! NSNumber
        UserModel.shared.setPhoneNo(no:"\(phoneno)" as NSString)
        UserModel.shared.setProfilePic(URL: userDict.value(forKey: "user_image") as! NSString)
        if userDict.value(forKey: "token") != nil {
            UserModel.shared.setAccessToken(userToken: userDict.value(forKey: "token") as! NSString)
        }
        UserModel.shared.setLastSeen(lastseen: userDict.value(forKey: "privacy_last_seen") as! NSString)
        UserModel.shared.setProfilePicPrivacy(picStatus: userDict.value(forKey: "privacy_profile_image") as! NSString)
        UserModel.shared.setAboutPrivacy(about: userDict.value(forKey: "privacy_about") as! NSString)
    }
   
    //MARK: store & get profile pic
    func setProfilePic(URL: NSString){
        UserDefaults.standard.set(URL, forKey: "user_profilepic")
    }
    func getProfilePic() -> NSString? {
        return UserDefaults.standard.value(forKey: "user_profilepic") as? NSString
    }
    
    //MARK: store & get last seen
    func setLastSeen(lastseen: NSString){
        UserDefaults.standard.set(lastseen, forKey: "user_lastseen")
    }
    func lastSeen() -> NSString? {
        return UserDefaults.standard.value(forKey: "user_lastseen") as? NSString
    }
    //MARK: store & get user name
    func setUserName(name:NSString){
        UserDefaults.standard.set(name, forKey: "user_profile_name")
    }
    func userName() -> NSString? {
        return UserDefaults.standard.value(forKey: "user_profile_name") as? NSString
    }
    //MARK: store & get phone no
    func setPhoneNo(no:NSString){
        UserDefaults.standard.set(no, forKey: "user_profile_no")
    }
    func phoneNo() -> NSString? {
        return UserDefaults.standard.value(forKey: "user_profile_no") as? NSString
    }
    
    //MARK: store & get profile pic privacy
    func setProfilePicPrivacy(picStatus: NSString){
        UserDefaults.standard.set(picStatus, forKey: "user_profilePic_status")
    }
    func profilePicPrivacy() -> NSString? {
        return UserDefaults.standard.value(forKey: "user_profilePic_status") as? NSString
    }
    //MARK: add socket handler
    func setSocket(status: NSString){
        UserDefaults.standard.set(status, forKey: "socket_handler")
    }
    func socketStatus() -> NSString? {
        return UserDefaults.standard.value(forKey: "socket_handler") as? NSString
    }
    //MARK: store & get about
    func setAboutPrivacy(about: NSString){
        UserDefaults.standard.set(about, forKey: "user_about_status")
    }
    func aboutPrivacy() -> NSString? {
        return UserDefaults.standard.value(forKey: "user_about_status") as? NSString
    }
    
    //MARK: store & get VOIP notification token
    func setPushToken(voip_token: NSString){
        UserDefaults.standard.set(voip_token, forKey: "voip_token")
    }
    func getPushToken() -> NSString? {
        return UserDefaults.standard.value(forKey: "voip_token") as? NSString
    }
    //MARK: store & get fcm notification token
    func setAPNSToken(fcm_token: NSString){
        UserDefaults.standard.set(fcm_token, forKey: "apns_token")
    }
    func getAPNSToken() -> NSString? {
        return UserDefaults.standard.value(forKey: "apns_token") as? NSString
    }
    //MARK: store & get fcm notification token
    func pushRegistered(status: String){
        UserDefaults.standard.set(status, forKey: "push_register")
    }
    func isRegistered() -> String? {
        return UserDefaults.standard.value(forKey: "push_register") as? String
    }
    //MARK: socket listionar
    func setChatListen(status: Bool){
        UserDefaults.standard.set(status, forKey: "chat_listen")
    }
    func chatListen() -> Bool? {
        return UserDefaults.standard.value(forKey: "chat_listen") as? Bool
    }
    //homelisten
    func setHomeListen(status: Bool){
        UserDefaults.standard.set(status, forKey: "home_listen")
    }
    func homeListen() -> Bool? {
        return UserDefaults.standard.value(forKey: "home_listen") as? Bool
    }
    
    //MARK: store & get back direct
    func setNavType(type: String){
        UserDefaults.standard.set(type, forKey: "nav_type")
    }
    func navType() -> String? {
        return UserDefaults.standard.value(forKey: "nav_type") as? String
    }
    
    //MARK: store & get back direct
    func setContactSync(type: String){
        UserDefaults.standard.set(type, forKey: "contact_sync")
    }
    func contactSync() -> String? {
        return UserDefaults.standard.value(forKey: "contact_sync") as? String
    }
    
    //MARK: store,get & remove channel id
    func setChannelDeleted(id: String){
        UserDefaults.standard.set(id, forKey: "delete_channel_id")
    }
    func deleteChannelID() -> String {
        if UserDefaults.standard.value(forKey: "delete_channel_id") == nil{
            return EMPTY_STRING
        }else{
            return UserDefaults.standard.value(forKey: "delete_channel_id") as! String
        }
    }
    func removeChannelID() {
        return UserDefaults.standard.removeObject(forKey: "delete_channel_id")
    }
    
    //MARK: Already in call values
    func setAlreadyInCall(status: String){
        UserDefaults.standard.set(status, forKey: "call_checking")
    }
    func alreadyInCall() -> String? {
        return UserDefaults.standard.value(forKey: "call_checking") as? String
    }
    
}
