//
//  channelSocket.swift
//  Hiddy
//
//  Created by APPLE on 01/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
protocol channelDelegate {
    func gotChannelInfo(dict:NSDictionary,type:String)
}
class channelSocket  {
    static let sharedInstance = channelSocket()
    var delegate : channelDelegate?
    let channelDB = ChannelStorage()
    
    //create channel
    func createChannel(name:String,des:String,type:String)  {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(name, forKey: "channel_name")
        requestDict.setValue(des, forKey: "channel_des")
        requestDict.setValue(type, forKey: "channel_type")
        socket.defaultSocket.emit("createchannel", requestDict)
    }
    //leave channel
    func leaveChannel(channel_id:String)  {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(channel_id, forKey: "channel_id")
        socket.defaultSocket.emit("leavechannel", requestDict)
    }
    
    //send invitation
    func sendInvitation(channel_id:String,subscriber:NSMutableArray)  {
        let requestDict = NSMutableDictionary()
        let jsonString:String = Utility.shared.convertJson(from: subscriber)!
        requestDict.setValue(channel_id, forKey: "channel_id")
        requestDict.setValue(jsonString, forKey: "invite_subscribers")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        socket.defaultSocket.emit("sendchannelinvitation", requestDict)
    }
    //send msg
    func sendChannelMsg(requestDict:NSDictionary) {
        socket.defaultSocket.emit("messagetochannel", requestDict)
    }
    //subscribe channel
    func subscribe(channel_id:String)  {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(channel_id, forKey: "channel_id")
        socket.defaultSocket.emit("subscribechannel", requestDict)
    }
    //unsubscribe channel
    func unSubscribe(channel_id:String)  {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(channel_id, forKey: "channel_id")
        socket.defaultSocket.emit("unsubscribechannel", requestDict)
    }
    //clear new invitation
    func clearInvitation(channel_id:String)  {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(channel_id, forKey: "channel_id")
        socket.defaultSocket.emit("clearchannelinvites", requestDict)
    }
    func getNewChannel() {
        self.getAdminChannels()
        self.getRecentInvites()
    }
    
    func refreshChannelMsg()  {
        let dict = NSDictionary()
        self.delegate?.gotChannelInfo(dict: dict, type: "refreshChannel")
    }
    //recent invites and msgs
    func getRecentInvites()  {
        let channelObj = ChannelServices()
        //recent new invites
        channelObj.recentChannels(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                
                let allChannelDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let channelArray = NSMutableArray()
                channelArray.addObjects(from: allChannelDict.allValues)
                for channel in channelArray{
                    let dict:NSDictionary = channel as! NSDictionary
                    let channelID:String = dict.value(forKey: "_id") as! String
                    self.channelsForYou(channel_id: channelID, detailDict: dict, status: "0")
                    self.clearInvitation(channel_id: channelID)
                    self.addInitialMsg(channel_id: channelID)
                }
            }
        })
        
        //recent msg list
        channelObj.recentChannelMsg(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let allChannelDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let msgArray = NSMutableArray()
                msgArray.addObjects(from: allChannelDict.allValues)
                for msg in msgArray{
                    let dict:NSDictionary = msg as! NSDictionary
                    let channelID:String = dict.value(forKey: "channel_id") as! String
                    self.channelMsgForYou(channel_id: channelID, detailDict: dict)
                    let userObj = UserWebService()
                    userObj.channelChatReceived(msgDict: dict, onSuccess: {response in
                    })
                }
            }
        })
    }
    
    //get old channels
    func getMyChannels()  {
        let channelObj = ChannelServices()
        //OWN CHANNELS
        channelObj.myChannels(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let channelArray:NSArray = response.value(forKey: "result") as! NSArray
                for channel in channelArray{
                    let dict:NSDictionary = channel as! NSDictionary
                    let channelID:String = dict.value(forKey: "_id") as! String
                    self.channelsForYou(channel_id: channelID, detailDict: dict, status: "1")
                }
            }
        })
        //SUBSCRIBED CHANNEL
        channelObj.mySubscribedChannels(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let channelArray:NSArray = response.value(forKey: "result") as! NSArray
                for channel in channelArray{
                    let dict:NSDictionary = channel as! NSDictionary
                    let channelID:String = dict.value(forKey: "_id") as! String
                    self.channelsForYou(channel_id: channelID, detailDict: dict, status: "1")
                    self.addInitialMsg(channel_id: channelID)
                }
            }
        })
    }
    
    //get new admin channels
    func getAdminChannels() {
        let channelObj = ChannelServices()
        channelObj.adminChannels(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let channelArray:NSArray = response.value(forKey: "result") as! NSArray
                for channel in channelArray{
                    let channelDict:NSDictionary = channel as! NSDictionary
                    print("Admin channel details \(channelDict)")
                    let channel_id = channelDict.value(forKey: "_id") as! String
                    self.channelDB.addNewChannel(channel_id:channel_id ,
                                                 title: channelDict.value(forKey: "title") as! String,
                                                 description: channelDict.value(forKey: "description") as! String,
                                                 created_time: channelDict.value(forKey: "created_at") as! String,
                                                 channel_type: "admin",
                                                 created_by: "admin", subCount:"0",status:"1")
                    if channelDict.value(forKey: "channel_image") != nil{
                        self.channelDB.updateChannelIcon(channel_id: channel_id, channel_icon:channelDict.value(forKey: "channel_image") as! String)
                    }
                }
                self.newAdminMsg()
            }
        })
    }
    //new admin msgs
    func newAdminMsg()  {
        var timeStamp = String()
        let timeStr = self.channelDB.channelLastMsg()
        if  Utility.shared.checkEmptyWithString(value:timeStr ){
            timeStamp = Utility.shared.getTime()
        }else{
            timeStamp = timeStr
        }
        let channelObj = ChannelServices()
        
        channelObj.adminChannelMsg(timestamp: timeStamp, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let msgArray:NSArray = response.value(forKey: "result") as! NSArray
                for msg in msgArray{
                    let msgDict:NSDictionary = msg as! NSDictionary
                    let channel_id:String = msgDict.value(forKey: "channel_id") as! String
                    Utility.shared.addChannelMsgToLocal(channel_id: channel_id, requestDict:msgDict, msg_id:msgDict.value(forKey: "_id") as! String, time: msgDict.value(forKey: "message_at")! as! String,admin:"admin")
                    self.delegate?.gotChannelInfo(dict: msgDict, type: "messagefromadminchannels")
                }
            }
        })
    }
    //Report Channels
    func reportChannel(user_id:String,channel_id: String, report: String, status: String, onSuccess success: @escaping (NSDictionary) -> Void)  {
        let channelObj = ChannelServices()
        
        channelObj.reportChannel(user_id: user_id, channel_id: channel_id, report: report, status: status) { (response) in
            // print(response)
            success(response)
        }
    }
    
    
    func addChannelHandler()  {
        //chat read response
        socket.defaultSocket.on("msgfromadminchannels") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            // print("ADMIN MSG \(detailDict)")
            let channel_id:String = detailDict.value(forKey: "channel_id") as! String
            let userObj = UserWebService()
            userObj.channelChatReceived(msgDict: detailDict, onSuccess: {response in
            })
            Utility.shared.addChannelMsgToLocal(channel_id: channel_id, requestDict: detailDict,msg_id:detailDict.value(forKey: "_id") as! String, time: detailDict.value(forKey: "message_at")! as! String, admin: "admin")
            self.delegate?.gotChannelInfo(dict: detailDict, type: "messagefromadminchannels")
        }
        socket.defaultSocket.on("messagefromchannel") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            // print("CHANNEL MSG \(detailDict)")
            let channel_id:String = detailDict.value(forKey: "channel_id") as! String
            let userObj = UserWebService()
            userObj.channelChatReceived(msgDict: detailDict, onSuccess: {response in
            })
            self.channelMsgForYou(channel_id: channel_id, detailDict: detailDict)
        }
        
        socket.defaultSocket.on("channelcreated") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            print("CHANNEL CREATED \(detailDict)")
            self.delegate?.gotChannelInfo(dict: detailDict, type: "channelcreated")
        }
        
        socket.defaultSocket.on("receivechannelinvitation") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            // print("INVITATION \(detailDict)")
            let channel_id = detailDict.value(forKey: "_id") as! String
            self.channelsForYou(channel_id: channel_id, detailDict: detailDict, status: "0")
            self.addInitialMsg(channel_id: channel_id)
        }
        
        socket.defaultSocket.on("deletechannel") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let channel_id:String = listArray.object(at: 0) as! String
            self.channelDB.deleteChannelMsg(channel_id: channel_id)
            self.channelDB.deleteChannel(channel_id: channel_id)
            let dict = NSMutableDictionary()
            dict.setValue(channel_id, forKey: "channel_id")
            self.delegate?.gotChannelInfo(dict: dict, type: "deletechannel")
        }
        socket.defaultSocket.on("blockchannel") { ( data, ack) -> Void in
            let listArray:NSArray = (data as NSArray)
            // print(listArray)
            let dictVal = listArray.object(at: 0) as! NSDictionary
            let channel_id:String = dictVal.value(forKey: "channel_id") as? String ?? ""
            let blockStatus:String = dictVal.value(forKey: "status") as? String ?? ""
            self.channelDB.blockChannelMsg(channel_id: channel_id, blockStatus: blockStatus)
            //            self.channelDB.deleteChannel(channel_id: channel_id)
            let dict = NSMutableDictionary()
            dict.setValue(channel_id, forKey: "channel_id")
            self.delegate?.gotChannelInfo(dict: dict, type: "blockchannel")
        }
        
    }
    
    //common for all chnneles
    func channelsForYou(channel_id:String,detailDict:NSDictionary,status:String)  {
        let totalCount:NSNumber = detailDict.value(forKey: "total_subscribers") as! NSNumber
        let admin = detailDict.value(forKey: "channel_admin_id") as! String
        self.channelDB.addNewChannel(channel_id:channel_id ,
                                     title: detailDict.value(forKey: "channel_name") as! String,
                                     description: detailDict.value(forKey: "channel_des") as! String,
                                     created_time: detailDict.value(forKey: "created_time") as! String,
                                     channel_type: detailDict.value(forKey: "channel_type") as! String,
                                     created_by: admin, subCount: "\(totalCount)", status: status)
        
        if detailDict.value(forKey: "channel_image") != nil{
            self.channelDB.updateChannelIcon(channel_id: channel_id, channel_icon:detailDict.value(forKey: "channel_image") as! String )
        }
        if !(UserModel.shared.contactIDs()?.contains(admin))! {
            let userObj = UserWebService()
            let localDB = LocalStorage()
            userObj.otherUserDetail(contact_id: admin, onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                    let cc = response.value(forKey: "country_code") as! Int
                    
                    localDB.addContact(userid: admin,
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
                }
            })
        }
        self.delegate?.gotChannelInfo(dict: detailDict, type: "receivechannelinvitation")
    }
    //add msg to channel
    func channelMsgForYou(channel_id:String,detailDict:NSDictionary)  {
        let msgType:String = detailDict.value(forKey: "message_type") as! String
        var admin_id = String()
        if msgType == "subject" || msgType == "channel_image" || msgType == "channel_des" {
            admin_id = EMPTY_STRING
        }else{
            admin_id = detailDict.value(forKey: "admin_id") as! String
        }
        
        Utility.shared.addChannelMsgToLocal(channel_id: channel_id, requestDict: detailDict, msg_id: detailDict.value(forKey: "message_id") as! String,time: detailDict.value(forKey: "chat_time")! as! String, admin:admin_id)
        self.delegate?.gotChannelInfo(dict: detailDict, type: "messagefromadminchannels")
    }
    
    func addInitialMsg(channel_id:String)  {
        if !self.channelDB.checkAdded(channel_id: channel_id) {
            
            channelDB.addChannelMsg(msg_id: channel_id,
                                    channel_id:channel_id ,
                                    admin_id: UserModel.shared.userID()! as String,
                                    msg_type: "added",
                                    msg: (Utility.shared.getLanguage()?.value(forKey: "you_added_channel") as? String)!,
                                    time: Utility.shared.getTime(),
                                    lat: "",
                                    lon: "",
                                    contact_name: "",
                                    contact_no: "",
                                    country_code: "",
                                    attachment: "",
                                    thumbnail: "",read_status:"0", msg_date: "")
        }
        
        if  UserModel.shared.channelIDs().contains(channel_id) {
            channelDB.updateChannelDetails(channel_id: channel_id, mute: "0", report: "0",  message_id: channel_id, timestamp: Utility.shared.getTime(), unread_count: "1")
        }
    }
    //upload video
    func uploadChatVideo(fileData:Data,type:String,msg_id:String,channel_id:String, requestDict:NSDictionary)  {
        let uploadObj = UploadServices()
        self.channelDB.updateChannelMediaDownload(msg_id: msg_id, status: "2")
        uploadObj.uploadChannelFiles(fileData: fileData, type: type, channel_id: channel_id, docuName:"Video" , msg_id: msg_id, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                self.channelDB.updateChannelMediaDownload(msg_id: msg_id, status: "1")
                self.channelDB.updateChannelVideoURL(msg_id: msg_id, attachment: response.value(forKey: "user_image") as! String)
                let msgdict = NSMutableDictionary.init(dictionary: requestDict)
                msgdict.removeObject(forKey: "attachment")
                msgdict.removeObject(forKey: "chat_time")
                let cryptLib = CryptLib()
                
                let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                
                msgdict.setValue(encryptedMsg, forKey: "attachment")
                msgdict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                channelSocket.sharedInstance.sendChannelMsg(requestDict: msgdict)
                
                self.delegate?.gotChannelInfo(dict: msgdict, type: "channelUploadVideo")
            }
        })
        
    }
}
