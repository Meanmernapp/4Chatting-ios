//
//  UserWebService.swift
//  Hiddy
//
//  Created by APPLE on 08/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class UserWebService: BaseWebService {
    
    //MARK: Signup web service
    public func signUpService(user_name:String,phone_no:String,country_code:String,country_name: String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        if user_name != EMPTY_STRING {
            requestDict.setValue(user_name, forKey: "user_name")
        }
        requestDict.setValue(phone_no, forKey: "phone_no")
        requestDict.setValue(country_code, forKey: "country_code")
        requestDict.setValue(country_name, forKey: "country")
        self.baseService(subURl: SIGN_IN_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: check user deleted
    public func checkDeleted(user_id:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(user_id, forKey: "user_id")
        self.baseService(subURl: USER_DELETED_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: update web service
    public func updateProfile(user_name:String,about:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(UserModel.shared.lastSeen(), forKey: "privacy_last_seen")
        requestDict.setValue(UserModel.shared.profilePicPrivacy(), forKey: "privacy_profile_image")
        requestDict.setValue(UserModel.shared.aboutPrivacy(), forKey: "privacy_about")
        requestDict.setValue(user_name, forKey: "user_name")
        let currentLocale = NSLocale.current.regionCode
        requestDict.setValue(currentLocale, forKey: "country")
        requestDict.setValue(about, forKey: "about")
        
        self.baseService(subURl: UPDATE_PROFILE_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: update privacy service
    public func updatePrivacyDetails(onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(UserModel.shared.lastSeen(), forKey: "privacy_last_seen")
        requestDict.setValue(UserModel.shared.aboutPrivacy(), forKey: "privacy_about")
        requestDict.setValue(UserModel.shared.profilePicPrivacy(), forKey: "privacy_profile_image")
        
        self.baseService(subURl: UPDATE_PRIVACY_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: set my contactcs
    public func setContacts(contacts:NSMutableArray, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(UserModel.shared.phoneNo(), forKey: "phone_no")
        requestDict.setValue(self.json(from: contacts), forKey: "contacts")
        self.baseService(subURl: UPDATE_CONTACTS_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
            self.updateBadgeStatus()
        }, onFailure: {errorResponse in
        })
    }
    
    public func saveContacts(contacts:NSMutableArray, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(self.json(from: contacts), forKey: "contacts")
        self.baseService(subURl: SAVE_MY_CONTACT, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
            self.updateBadgeStatus()
        }, onFailure: {errorResponse in
        })
    }
    public func updateBadgeStatus() {
        if UserModel.shared.getAPNSToken() != nil{
            self.getBaseService(subURl: RESET_BADGE + "/\(UserModel.shared.getAPNSToken()! as String)", onSuccess: { (response) in
                print("\(response)")
            }) { (error) in
                print("\(error)")
            }
        }
        
    }
    //MARK: get help content
    public func helpDetails(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: HELP_API, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: get blocked user list
    public func otherUserDetail(contact_id:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        if UserModel.shared.phoneNo() != nil{
        self.getBaseService(subURl: ("\(OTHER_USER_DETAIL_API)/\((UserModel.shared.phoneNo())!)/\(contact_id)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
        }
    }
    
    //MARK: verify phone availablity
    public func verfifyNo(phone_no:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(VERIFY_NO_API)/\((UserModel.shared.userID())!)/\(phone_no)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: change phone number
    public func changePhoneNo(phone_no:String,country_code:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(CHANGE_NO_API)/\((UserModel.shared.userID())!)/\(phone_no)/\(country_code)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: version Update
    public func versionUpdate(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: VERSION_API, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: get blocked user list
    public func blockedList(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(BLOCKED_USERLIST_API)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: get recent chat list
    public func recentChat(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(RECENT_CHATS_API)/\(UserModel.shared.userID()!)"), onSuccess: {response in
        
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: CHAT RECEIVED
    public func chatReceived(msgDict:NSDictionary, onSuccess success: @escaping (NSDictionary) -> Void) {
        // Prepare params
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(msgDict.value(forKey: "sender_id"), forKey: "sender_id")
        requestDict.setValue(msgDict.value(forKey: "receiver_id"), forKey: "receiver_id")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(msgDict.value(forKeyPath: "message_data.message_id"), forKey: "message_id")
        
        print("params \(requestDict)")
        
        //make base method call
        self.baseService(subURl: CHAT_RECEIVED_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
            print("chat received api respone \(response)")
        }, onFailure: {errorResponse in
        })
    }
    //MARK: GROUP CHAT RECEIVED
    public func groupchatReceived(msgDict:NSDictionary, onSuccess success: @escaping (NSDictionary) -> Void) {
        // Prepare params
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(msgDict.value(forKey: "message_id"), forKey: "message_id")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                
        //make base method call
        self.baseService(subURl: GROUP_CHAT_RECEIVED_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
            print("chat received api respone \(response)")
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: CHANNEL MSG RECEIVED
    public func channelChatReceived(msgDict:NSDictionary, onSuccess success: @escaping (NSDictionary) -> Void) {
        // Prepare params
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(msgDict.value(forKey: "message_id"), forKey: "message_id")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
                
        //make base method call
        self.baseService(subURl: CHANNEL_CHAT_RECEIVED_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
            print("chat received api respone \(response)")
        }, onFailure: {errorResponse in
        })
    }
    //check device information
    public func checkDeviceInfo(onSuccess success: @escaping (NSDictionary) -> Void) {
        // Prepare params
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UIDevice.current.identifierForVendor!.uuidString, forKey: "device_id")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        //make base method call
        self.baseService(subURl: CHECK_DEVICE_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //register for push services
    public func registerForNotification(onSuccess success: @escaping (NSDictionary) -> Void) {
        // Prepare params
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UIDevice.current.identifierForVendor!.uuidString, forKey: "device_id")
        requestDict.setValue("0", forKey: "device_type")
        requestDict.setValue(DEVICE_MODE, forKey: "device_mode")
        if UserModel.shared.getPushToken() != nil{
            requestDict.setValue(UserModel.shared.getPushToken()! as String, forKey: "device_token")
        }
        requestDict.setValue(UserModel.shared.LANGUAGE_CODE, forKey: "lang_type")
        if UserModel.shared.getAPNSToken() != nil{
            requestDict.setValue(UserModel.shared.getAPNSToken()! as String, forKey: "apns_token")
        }
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        // print("user id\(UserModel.shared.userID() ?? EMPTY_STRING as NSString)")
        //make base method call
        self.baseService(subURl: PUSH_SIGNIN_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
            
        })
    }
    
    //unregister for notification
    public func pushSignoutService(onSuccess success: @escaping (NSDictionary) -> Void) {
        // Prepare params
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UIDevice.current.identifierForVendor!.uuidString, forKey: "device_id")
        //make base method call
        self.deleteMethod(subURl: PUSH_SIGNOUT_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
            
        })
    }
    
    //get formatted json from array
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
