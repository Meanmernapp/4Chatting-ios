//
//  GroupMessage.swift
//  Hiddy
//
//  Created by APPLE on 10/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation

// single msg
struct messageModel {
    
    struct message {
        let sender_id:String
        let receiver_id: String
        let message_data: NSDictionary
        let date: String
    }
    func groupedMsg(msgArray:[message]) -> [String: [messageModel.message]] {
        let grouped = msgArray.group(by: { $0.date})
        return grouped
    }
}
struct RecentStoryModel {
    let sender_id: String
    let story_id: String
    let message: String
    let story_type: String
    let attachment: String
    let story_date: String
    let story_time: String
    let expiry_time: String
    let contactName: String
    let userName: String
    let phoneNumber: String
    let userImage: String
    let aboutUs: String
    let blockedMe: String
    let blockedByMe: String
    let mute: String
    let mutual_status: String
    let privacy_lastseen: String
    let privacy_about: String
    let privacy_image: String
    let favourite: String

    init(sender_id: String,story_id: String,message: String,story_type: String,attachment: String,story_date: String,story_time: String,expiry_time: String,contactName: String, userName: String,phoneNumber: String,userImage: String,aboutUs: String,blockedMe: String,blockedByMe: String,mute: String,mutual_status: String,privacy_lastseen: String,privacy_about: String,privacy_image: String,favourite: String) {
        self.sender_id = sender_id
        self.story_id = story_id
        self.message = message
        self.story_type = story_type
        self.attachment = attachment
        self.story_date = story_date
        self.story_time = story_time
        self.expiry_time = expiry_time
        self.contactName = contactName
        self.userName = userName
        self.phoneNumber = phoneNumber
        self.userImage = userImage
        self.aboutUs = aboutUs
        self.blockedMe = blockedMe
        self.blockedByMe = blockedByMe
        self.mute = mute
        self.mutual_status = mutual_status
        self.privacy_lastseen = privacy_lastseen
        self.privacy_about = privacy_about
        self.privacy_image = privacy_image
        self.favourite = favourite
    }
}
struct viewListModel {
    let member_key: String
    let sender_id: String
    let story_id: String
    let receiver_id: String
    let timestamp: String
    init(member_key: String, sender_id: String, story_id: String, receiver_id: String, timestamp: String) {
        self.member_key = member_key
        self.sender_id = sender_id
        self.story_id = story_id
        self.receiver_id = receiver_id
        self.timestamp = timestamp
    }

}
struct statusModel {
    let attachment: String
    let expiry_time: String
    let message: String
    let sender_id: String
    let story_date: String
    let story_id: String
    let story_members: String
    let thumbNail: String
    let story_time: String
    let story_type: String
    let is_Viewed: String
    let local_path: String
    init(attachment: String,expiry_time: String,message: String,sender_id: String,story_date: String,story_id: String,story_members: String,story_time: String,story_type: String, thumbNail: String, is_Viewed: String,local_path: String) {
        self.attachment = attachment
        self.expiry_time = expiry_time
        self.message = message
        self.sender_id = sender_id
        self.story_date = story_date
        self.story_id = story_id
        self.story_members = story_members
        self.story_time = story_time
        self.story_type = story_type
        self.thumbNail = thumbNail
        self.is_Viewed = is_Viewed
        self.local_path = local_path
    }
}
struct userStatusModel {
    let sender_id: String
    let receiver_id: String
    let contact_name: String
    let profile_image: String
    var StatusDict: [statusModel] = []
    init(sender_id: String, contact_name: String, profile_image: String,receiver_id: String, StatusDict: [statusModel]) {
        self.sender_id = sender_id
        self.contact_name = contact_name
        self.profile_image = profile_image
        self.StatusDict = StatusDict
        self.receiver_id = receiver_id
    }
}
//group msg
struct groupMsgModel {
    struct message {
        let message_id:String
        let group_id: String
        let member_id: String
        let message_type:String
        var message: String
        let timestamp: String
        let lat:String
        let lon: String
        let contact_name: String
        let contact_no: String
        let country_code:String
        let attachment: String
        let thumbnail: String
        let isDownload: String
        let local_path: String
        let date: String
        let admin_id: String
        let translated_status: String
        let translated_msg: String

    }
    func groupedGroupMsg(msgArray:[message]) -> [String: [groupMsgModel.message]] {
        var grouped = msgArray.group(by: { $0.date})
        return grouped
}
}
// channel msg
struct channelMsgModel {
    struct message {
        let message_id:String
        let channel_id: String
        let message_type:String
        var message: String
        let timestamp: String
        let lat:String
        let lon: String
        let contact_name: String
        let contact_no: String
        let country_code:String
        let attachment: String
        let thumbnail: String
        let isDownload: String
        let local_path: String
        let date: String
        let admin_id: String
        let translated_status: String
        let translated_msg: String
        let msg_date: String

    }
    func groupedGroupMsg(msgArray:[message]) -> [String: [channelMsgModel.message]] {
        let grouped = msgArray.group(by: { $0.date})
        return grouped
    }
}



extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
    
    func groupAll<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        // print("what array \(self)")
        var categories: [U: [Iterator.Element]] = [:]
        
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
             categories[key] = [element]
            }
        }

        return categories
    }
    
 
   
    
}
