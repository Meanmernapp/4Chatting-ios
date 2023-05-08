//
//  NotificationService.swift
//  Notification
//
//  Created by Roby on 26/07/20.
//  Copyright © 2020 HITASOFT. All rights reserved.
//

import UserNotifications
import SQLite3
import UIKit
import Alamofire

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var badgeCount = 0
    var localCallDB = CallStorage()
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let notificationDict: NSDictionary = request.content.userInfo["data"] as! NSDictionary
            
            let msgDict: NSDictionary = notificationDict.value(forKey: "message_data") as! NSDictionary
            print("NOTIFICATION MSG INFO \(notificationDict)")
            let type = msgDict.value(forKey: "chat_type") as! String
            
            if type == "single"{
                let body = notificationDict.value(forKey: "body") as! String
                let sender_id = msgDict.value(forKey: "sender_id") as! String
                let receiver_id = msgDict.value(forKey: "receiver_id") as! String
                let newDict = NSMutableDictionary.init(dictionary: notificationDict)
                newDict.setValue(sender_id, forKey: "sender_id")
                newDict.setValue(receiver_id, forKey: "receiver_id")
                newDict.setValue("\(receiver_id)\(sender_id)", forKey: "chat_id")
                Utility.shared.addToLocal(requestDict: newDict, chat_id: "\(receiver_id)\(sender_id)", contact_id: sender_id)
                let contact_name = DBConfig().getContactName(contact_id: sender_id)
                if contact_name == ""{
                    let phone_no = msgDict.value(forKey: "phone") as! String
                    bestAttemptContent.title = phone_no
                }else{
                    bestAttemptContent.title = contact_name
                }
                bestAttemptContent.body = body
                socketClass.sharedInstance.chatReceivedAPI(msgDict: newDict)
 
//                self.chatReceived(msgDict: newDict)
            }else if type == "group"{
                let member_id = msgDict.value(forKey: "member_id") as! String
                var contact_name = DBConfig().getContactName(contact_id: member_id)
                if contact_name == ""{
                    contact_name = msgDict.value(forKey: "member_no") as! String
                }
                var body = String()
                if notificationDict.value(forKey: "body") == nil{
                    let message_type = msgDict.value(forKey: "message_type") as! String
                    if message_type == "add_member"{
                        body = "Added participants."
                    }
                }else{
                    body = notificationDict.value(forKey: "body") as! String
                }
                if notificationDict.value(forKey: "title") == nil{
                    bestAttemptContent.title = "Group Invitation"
                }else{
                    bestAttemptContent.title = notificationDict.value(forKey: "title") as! String
                }
                bestAttemptContent.body = "\(contact_name): \(body)"
                
            }else if type == "call"{
                let status = msgDict.value(forKey: "call_type") as! String
                if status == "missed"{
                    let caller_id = msgDict.value(forKey: "caller_id") as! String
                    bestAttemptContent.title = "\(DBConfig().getContactName(contact_id: caller_id))"
                    let call_type = msgDict.value(forKey: "type") as! String
                    if call_type == "audio"{
                        bestAttemptContent.body = "Missed voice call"
                    }else{
                        bestAttemptContent.body = "Missed video call"
                    }
                    self.localCallDB.addNewCall(call_id: msgDict.value(forKey: "call_id") as! String, contact_id: msgDict.value(forKey: "caller_id") as! String, status: "missed", call_type: msgDict.value(forKey: "type") as! String, timestamp: Utility.shared.getTime(), unread_count: "1")
                }
            }else if type == "channel"{
                
                let body = notificationDict.value(forKey: "body") as! String
                
                let title = notificationDict.value(forKey: "title") as! String
                bestAttemptContent.title = title
                bestAttemptContent.body = body
            }else{
                let body = notificationDict.value(forKey: "body") as! String
                let title = notificationDict.value(forKey: "title") as! String
                bestAttemptContent.title = title
                bestAttemptContent.body = body
            }
            badgeCount = 0
            let userval = UserDefaults(suiteName: NOTIFICATION_EXTENSION)
            badgeCount = userval?.object(forKey: "badge") as? Int ?? 0
            print("badge count \(userval?.object(forKey: "badge") as? Int ?? 0)")
            badgeCount = (badgeCount + 1)
            bestAttemptContent.badge = NSNumber(value: badgeCount)
            userval?.set(self.badgeCount, forKey: "badge")
            contentHandler(bestAttemptContent)
            
            
        }
    }
    func chatReceived(msgDict: NSDictionary!) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(msgDict.value(forKey: "sender_id"), forKey: "sender_id")
        requestDict.setValue(msgDict.value(forKey: "receiver_id"), forKey: "receiver_id")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(msgDict.value(forKeyPath: "message_data.message_id"), forKey: "message_id")
        
        let BaseUrl = URL(string: BASE_URL+CHAT_RECEIVED_API)
        print("BASE URL : \(BASE_URL+CHAT_RECEIVED_API)")
        print("PARAMETER : \(requestDict)")
        if Utility().isConnectedToNetwork(){
            var header:HTTPHeaders? =  nil
            if(DBConfig().getAccessToken() != nil) {
                header = self.getHeaders()
            }
            //webservice call
            Alamofire.request(BaseUrl!, method:.post, parameters:(requestDict as! Parameters), encoding: URLEncoding.httpBody, headers: header).responseJSON { response in
                //sucesss block
                let JSON = response.result.value as? NSDictionary
                switch response.result {
                case .success:
                    print("RESPONSE SUCCESS: \(JSON!)")
                    break
                case .failure(let error):
                    print("FAILURE RESPONSE: \(error.localizedDescription)")
                }
            }
        }
        
       

    }
    //MARK: http headers
    func getHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Authorization": DBConfig().getAccessToken()! as String,
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        return headers
    }
    override func serviceExtensionTimeWillExpire() {
        print("checkking expired")
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        //        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
        //            contentHandler(bestAttemptContent)
        //        }
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
    
    
}
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
