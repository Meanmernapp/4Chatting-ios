//
//  socketClass.swift
//  Hiddy
//
//  Created by APPLE on 28/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

var socket = SocketManager(socketURL: URL(string: SOCKET_URL)!, config: [.log(true), .compress])

var activeTimer = Timer()
var msgIDs = NSMutableArray()
var isSocketConnected = false
protocol socketClassDelegate {
    func gotSocketInfo(dict:NSDictionary,type:String)
}

class socketClass {
    static let sharedInstance = socketClass()
    var delegate : socketClassDelegate?
    let localDB = LocalStorage()
    
    //connect socket
    func connect()  {
        if socket.defaultSocket.status.active {
//            isSocketConnected = true
        }else{
            isSocketConnected = false
            self.disconnect()//disconnect before connect
            socket.defaultSocket.connect()
            socket.defaultSocket.on(clientEvent: .connect) {data, ack in
                print("SOCKET CONNECTED SUCCESSFULLY")
                self.connectChat()
                self.addHandler()
                groupSocket.sharedInstance.joinGroups()
                groupSocket.sharedInstance.addGroupHandler()
                StorySocket.sharedInstance.addStoryHandler()
                channelSocket.sharedInstance.addChannelHandler()
                if UserModel.shared.callSocketStatus() == nil{
                    callSocket.sharedInstance.CallSocketHandler()
                    UserModel.shared.setCallSocket(status: "1")
                }
                self.ping()
                self.goLive()
                if !activeTimer.isValid {
                    activeTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.goLive), userInfo: nil, repeats: true)
                }
                isSocketConnected = true
            }
            socket.defaultSocket.on(clientEvent: .disconnect) { (data, ack) in
                self.connect()
            }
            socket.defaultSocket.on(clientEvent: .reconnect) { (data, ack) in
                
            }
        }
    }
    
    //disconnect socet
    func disconnect()  {
        self.offSocketEvents()
        socket.defaultSocket.disconnect()
    }
    
    func destorySocket()  {
        self.disconnect()
        socket.removeSocket(socket.defaultSocket)
    }
    //off all sockets
    func offSocketEvents()  {
        socket.defaultSocket.off("receivechat")
        socket.defaultSocket.off("receivedstatus")
        socket.defaultSocket.off("changeuserimage")
        socket.defaultSocket.off("listentyping")
        socket.defaultSocket.off("readstatus")
        socket.defaultSocket.off("onlinestatus")
        socket.defaultSocket.off("blockstatus")
        socket.defaultSocket.off("groupinvitation")
        socket.defaultSocket.off("messagefromgroup")
        socket.defaultSocket.off("memberexited")
        socket.defaultSocket.off("listengrouptyping")
        socket.defaultSocket.off("groupdeleted")
        socket.defaultSocket.off("makeprivate")
        socket.defaultSocket.off("messagefromadminchannels")
        socket.defaultSocket.off("channelcreated")
        socket.defaultSocket.off("receivechannelinvitation")
        socket.defaultSocket.off("deletechannel")
        socket.defaultSocket.off("receivestory")
        socket.defaultSocket.off("storyviewed")
        socket.defaultSocket.off("stroydeleted")
        socket.defaultSocket.off("getbackstatus")
        socket.defaultSocket.off("storyofflinedelete")
        socket.defaultSocket.off("pong")
    }
    func ping()  {
        socket.defaultSocket.emit("ping","")
    }
    //readreceipts
    func readReceipts(){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        socket.defaultSocket.emit("readreceipts", requestDict)
    }
    //connect chat
    func connectChat(){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        socket.defaultSocket.emit("chatbox", requestDict)
    }
    
    //make alive
    @objc func goLive(){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        groupStorage.sharedInstance.getActiveGroups()
        let groupActive = UserModel().activeGroupIDs()
        if groupActive != nil {
            requestDict.setValue(UserWebService().json(from:groupActive ?? []), forKey: "groups")
        }
        
        ChannelStorage.sharedInstance.getActiveChannels()
        let channelActive = UserModel().activeChannelIDs()
        if channelActive != nil {
            requestDict.setValue(UserWebService().json(from:channelActive ?? []), forKey: "channels")
        }
        socket.defaultSocket.emit("golive", requestDict)
    }
    //makemeaway
    @objc func goAway(){
        isSocketConnected = false
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        socket.defaultSocket.emit("goaway", requestDict)
    }
    //send msg
    func sendMsg(requestDict:NSDictionary) {
        print("SEND MSG \(requestDict)")
        let Dict = requestDict as NSDictionary
        Dict.setValue("\(UserModel.shared.userName() ?? "")", forKey: "sender_name")
        socket.defaultSocket.emit("startchat", requestDict)
    }
    //Delete msg
    func deleteMsg(msgDict:NSDictionary, message_id: String, type: String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(message_id, forKey: "message_id")
        requestDict.setValue(type, forKey: "delete_status")
        socket.defaultSocket.emit("deletechat", requestDict)
    }
    
    //block contact
    func blockContact(contact_id:String,type:String){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        requestDict.setValue(contact_id, forKey: "receiver_id")
        requestDict.setValue(type, forKey: "type")
        socket.defaultSocket.emit("block", requestDict)
        if type == "block" {
            localDB.updateBlockedStatus(contact_id: contact_id, type: "blockedByMe",value:"1")
        }else if type == "unblock"{
            localDB.updateBlockedStatus(contact_id: contact_id, type: "blockedByMe",value:"0")
        }
    }
    //send typing status
    func sendTypingStatus(requestDict:NSDictionary) {
        socket.defaultSocket.emit("typing", requestDict)
    }
    //send online status
    func sendOnlineStatus(contact_id:String){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(contact_id, forKey: "contact_id")
        socket.defaultSocket.emit("online", requestDict)
    }
    
    //send mute status
    func muteStatus(chat_id:String,type:String,status:String){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(type, forKey: "chat_type")
        requestDict.setValue(status, forKey: "type")
        requestDict.setValue(chat_id, forKey: "chat_id")
        
        socket.defaultSocket.emit("mutechat", requestDict)
    }
    //send request to chat received
    func chatReceived(msgDict:NSDictionary) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(msgDict.value(forKey: "sender_id"), forKey: "sender_id")
        requestDict.setValue(msgDict.value(forKey: "receiver_id"), forKey: "receiver_id")
        requestDict.setValue(msgDict.value(forKeyPath: "message_data.message_id"), forKey: "message_id")
        socket.defaultSocket.emit("chatreceived", requestDict)
    }
    //send request to chat read
    func chatRead(sender_id:String,receiver_id:String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(sender_id, forKey: "sender_id")
        requestDict.setValue(receiver_id, forKey: "receiver_id")
        requestDict.setValue("\(sender_id)\(receiver_id)", forKey: "chat_id")
        socket.defaultSocket.emit("chatviewed", requestDict)
    }
    
    //clear read msgs
    func clearRead(chat_id:String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        requestDict.setValue(chat_id, forKey: "chat_id")
        socket.defaultSocket.emit("clearreadmessages", requestDict)
    }
    //clear read msgs
    func clearReceived(msg_id:String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(msg_id, forKey: "message_id")
        requestDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        socket.defaultSocket.emit("clearreceivedmessages", requestDict)
    }
    //get rencent single message
    //its called when come from offline mode
    func getRecentMsg()  {
        let userObj = UserWebService()
        
        userObj.recentChat(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                print("******* before split \(response)")
                let allMsgDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let msgArray = NSMutableArray()
                msgArray.addObjects(from: allMsgDict.allValues)
                print("******* after split \(msgArray)")
                
//                do {
//                    let data =  try? JSONSerialization.data(withJSONObject: response, options: [])
//                    // do sth
//                    do {
//                        let jsonResponse = try JSON.init(data:data!)
//                        let newArray = NSMutableArray()
//
//                        print("******* jsonResponse \(jsonResponse["result"])")
//
//
//                    }catch {
//                        print("JSONSerialization error:", error)
//                    }
//                } catch{
//                    print(error)
//                }
                
                
                
                //                var msgTempDict = NSDictionary()
                for msg in msgArray {
                    
                    let msgTempDict = msg as! NSDictionary
                    if msgTempDict.value(forKey: "sender_id") != nil{
                        let contact_id:String = msgTempDict.value(forKey: "sender_id") as! String
                        if (UserModel.shared.contactIDs()?.contains(contact_id))!{
                            self.addMsg(contact_id: contact_id,msgDict:msgTempDict)
                            self.chatReceivedAPI(msgDict: msgTempDict)
                            
                        }else{ // if user not in contact
                            let userObj = UserWebService()
                            userObj.otherUserDetail(contact_id: contact_id, onSuccess: {response in
                                let status:String = response.value(forKey: "status") as! String
                                if status == STATUS_TRUE{
                                    let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                                    let cc = response.value(forKey: "country_code") as! Int
                                    
                                    self.localDB.addContact(userid: contact_id,
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
                                    self.addMsg(contact_id: contact_id,msgDict:msgTempDict )
                                    self.chatReceivedAPI(msgDict: msgTempDict)
                                    
                                }
                            })
                        }
                    }
                }
                self.delegate?.gotSocketInfo(dict: response,type: "recentMsg")
            }
        })
        
        
    }
    //chat received api
    func chatReceivedAPI(msgDict:NSDictionary)  {
        let userObj = UserWebService()
        userObj.chatReceived(msgDict: msgDict, onSuccess: {response in
        })
    }
    
    // add single message to local storage
    func addMsg(contact_id:String,msgDict: NSDictionary)  {
        
        let unreadcount = localDB.getUnreadCount(contact_id: msgDict.value(forKey: "sender_id")as! String)

        let chat_id:String = "\(UserModel.shared.userID()!)\(contact_id)"
        Utility.shared.addToLocal(requestDict: msgDict, chat_id: chat_id, contact_id: contact_id)
        socketClass.sharedInstance.chatReceived(msgDict: msgDict)
        let newDict = localDB.getLastMsgInfo(chat_id: chat_id)
        localDB.addRecent(contact_id:contact_id , msg_id: newDict.value(forKey: "message_id") as! String, unread_count: "\(unreadcount)",time: newDict.value(forKey: "chat_time") as! String)

        
        self.delegate?.gotSocketInfo(dict: msgDict,type: "checkCurrentChat")
    }
    
    
    //video upload
    func uploadChatVideo(fileData:Data,type:String,msg_id:String,requestDict:NSDictionary,blockedbyMe:String?,blockedMe:String?)  {
        let uploadObj = UploadServices()
        self.localDB.updateDownload(msg_id: msg_id,status:"2")
        print("******video upload video")

        uploadObj.uploadFiles(fileData: fileData, type: type, user_id: UserModel.shared.userID()! as String, docuName: "Video",msg_id: msg_id,api_type:"private", onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            print("******video upload response \(response)")

            if status == STATUS_TRUE{
                
                self.localDB.updateDownload(msg_id: msg_id,status:"1")
                self.localDB.updateVideoURL(msg_id: msg_id, attachment: response.value(forKey: "user_image") as! String)
                var msgdict = NSMutableDictionary()
                msgdict = requestDict.value(forKey: "message_data") as! NSMutableDictionary
                msgdict.removeObject(forKey: "attachment")
                msgdict.removeObject(forKey: "chat_time")
                let cryptLib = CryptLib()
                let encryptattachment = cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                msgdict.setValue(encryptattachment, forKey: "attachment")
                msgdict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                msgdict.setValue(requestDict.value(forKey: "sender_id"), forKey: "sender_id")
                msgdict.setValue(requestDict.value(forKey: "receiver_id"), forKey: "receiver_id")
                let newDict = NSMutableDictionary.init(dictionary: requestDict)
                newDict.removeObject(forKey: "message_data")
                newDict.setValue(msgdict, forKey: "message_data")
                if blockedMe != nil && blockedbyMe != nil {
                    if blockedMe == "0" && blockedbyMe == "0"{
                        socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                    }
                }else{
                    socketClass.sharedInstance.sendMsg(requestDict: requestDict)
                }

                self.delegate?.gotSocketInfo(dict: newDict,type: "videoUploadStatus")
            }
        })
    }
    
    // Response for receive, read message
    func addHandler()  {
        socket.defaultSocket.on("pong") { ( data, ack) -> Void in
            self.ping()
        }
        socket.defaultSocket.on("chatboxjoined") { ( data, ack) -> Void in
            self.readReceipts()
            //            Utility.shared.showAlert(msg: "chatboxjoined")
            //            UIApplication.shared.keyWindow?.rootViewController?.view.makeToast("chatboxjoined")
            
        }
        socket.defaultSocket.on("receivechat") { ( data, ack) -> Void in
            print("SOCKET NEW MESSAGE \(data)")
            if UserModel.shared.userID() != nil {
            let msgList:NSArray = data as NSArray
            let msgDict:NSDictionary = msgList.object(at: 0) as! NSDictionary
            let contact_id : String = msgDict.value(forKey: "sender_id") as! String
            let message_id : String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        let message_type : String = msgDict.value(forKeyPath: "message_data.message_type") as! String

            if msgIDs.contains(message_id) && message_type != "isDelete"{
               return
            }
            msgIDs.add(message_id)
            let chat_id:String = "\(UserModel.shared.userID()!)\(contact_id)"
            //            let msg_type:String = msgDict.value(forKeyPath: "message_data.message_type") as! String
            if (UserModel.shared.contactIDs()?.contains(contact_id))!{
                socketClass.sharedInstance.chatReceived(msgDict: msgDict)
                Utility.shared.addToLocal(requestDict: msgDict, chat_id: chat_id, contact_id: contact_id)
                self.delegate?.gotSocketInfo(dict: msgDict,type: "receivechat")
            }else{
                let userObj = UserWebService()
                userObj.otherUserDetail(contact_id: contact_id, onSuccess: {response in
                    let status:String = response.value(forKey: "status") as! String
                    if status == STATUS_TRUE{
                        let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                        let cc = response.value(forKey: "country_code") as! Int
                        self.localDB.addContact(userid: contact_id,
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
                        
                        socketClass.sharedInstance.chatReceived(msgDict: msgDict)
                        Utility.shared.addToLocal(requestDict: msgDict, chat_id: chat_id, contact_id: contact_id)
                        self.delegate?.gotSocketInfo(dict: msgDict,type: "receivechat")
                    }
                })
            }
            }
        }
        //change profile pic
        socket.defaultSocket.on("changeuserimage") { ( data, ack) -> Void in
            // print("SOCKET CHANGE PIC \(data)")
            let msgList:NSArray = data as NSArray
            let msgDict:NSDictionary = msgList.object(at: 0) as! NSDictionary
            self.localDB.replacePic(contact_id: msgDict.value(forKey: "user_id") as! String, img: msgDict.value(forKey: "user_image") as! String)
            self.delegate?.gotSocketInfo(dict: msgDict,type: "changeuserimage")
        }
        //typing listener
        socket.defaultSocket.on("listentyping") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            self.delegate?.gotSocketInfo(dict: detailDict,type: "listentyping")
        }
        
        //chat received response
        socket.defaultSocket.on("receivedstatus") { ( data, ack) -> Void in
            // update particular chat by message id
            // print("SOCKET DELIVERED RESPONSE \(data)")
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            let localDB = LocalStorage()
            if detailDict.value(forKey: "message_id") != nil{
                localDB.readStatus(id: detailDict.value(forKey: "message_id") as! String, status: "2", type: "message")
                self.delegate?.gotSocketInfo(dict: detailDict,type: "receivedstatus")
            }
        }
        
        //chat read response
        socket.defaultSocket.on("readstatus") { ( data, ack) -> Void in
            // print("SOCKET READ RESPONSE \(data)")
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            //            sleep(1)
            if detailDict.value(forKey: "chat_id") != nil{
                self.localDB.readStatus(id: detailDict.value(forKey: "chat_id") as! String, status: "3", type: "chat")
                self.delegate?.gotSocketInfo(dict: detailDict,type: "readstatus")
            }
        }
        
        //check contact online status
        socket.defaultSocket.on("onlinestatus") { ( data, ack) -> Void in
            let list:NSArray = data as NSArray
            let resultDict:NSDictionary = list.object(at: 0) as! NSDictionary
            self.delegate?.gotSocketInfo(dict: resultDict,type: "onlinestatus")
        }
        //check contact online status
        socket.defaultSocket.on("blockstatus") { ( data, ack) -> Void in
            let list:NSArray = data as NSArray
            let resultDict:NSDictionary = list.object(at: 0) as! NSDictionary
            let blockType = resultDict.value(forKey: "type") as! String
            print("******** TYPPPEEE \(blockType) dict \(resultDict)")
            if blockType == "block"{
                self.localDB.updateBlockedStatus(contact_id: resultDict.value(forKey: "sender_id") as! String, type: "blockedMe",value:"1" )
            }else if blockType == "unblock"{
                self.localDB.updateBlockedStatus(contact_id: resultDict.value(forKey: "sender_id") as! String, type: "blockedMe",value:"0" )
            }
            self.delegate?.gotSocketInfo(dict: resultDict,type: "blockstatus")
        }
        
        //check contact offline delivered status
        socket.defaultSocket.on("offlinereceivedstatus") { ( data, ack) -> Void in
            let list:NSArray = data as NSArray
            let resultDict:NSDictionary = list.object(at: 0) as! NSDictionary
            // print("delivery stt \(resultDict)")
            let msgArray = NSMutableArray()
            msgArray.addObjects(from: resultDict.allValues)
            
            for msg in msgArray{
                let dict : NSDictionary = msg as! NSDictionary
                let msgID = dict.value(forKey: "message_id") as? String
                self.localDB.readStatus(id:msgID!, status: "2", type: "message")
                self.clearReceived(msg_id: msgID!)
                self.delegate?.gotSocketInfo(dict: dict,type: "offlineRefresh")
                
            }
        }
        
        //check contact offline read status
        socket.defaultSocket.on("offlinereadstatus") { ( data, ack) -> Void in
            let list:NSArray = data as NSArray
            let resultDict:NSDictionary = list.object(at: 0) as! NSDictionary
            print("read stt \(resultDict)")
            let msgArray = NSMutableArray()
            msgArray.addObjects(from: resultDict.allValues)
            print("read msg st \(msgArray)")
            for chat in msgArray{
                let dict : NSDictionary = chat as! NSDictionary
                self.localDB.readStatus(id: dict.value(forKey: "chat_id") as! String, status: "3", type: "chat")
                self.clearRead(chat_id: dict.value(forKey: "chat_id") as! String)
                self.delegate?.gotSocketInfo(dict: dict,type: "offlineRefresh")
            }
            
        }
        
        //check privacy details
        socket.defaultSocket.on("makeprivate") { ( data, ack) -> Void in
            let list:NSArray = data as NSArray
            let dict:NSDictionary = list.object(at: 0) as! NSDictionary
            let user_id:String = dict.value(forKey: "user_id") as! String
            if user_id != UserModel.shared.userID()! as String {
                // print("PRIVACY DICT \(dict)")
                self.localDB.updatePrivacy(user_id: user_id,
                                           lastseen: dict.value(forKey: "privacy_last_seen") as! String,
                                           about: dict.value(forKey: "privacy_about") as! String,
                                           profile_pic: dict.value(forKey: "privacy_profile_image") as! String)
                self.delegate?.gotSocketInfo(dict: dict,type: "makeprivate")
            }
            
        }
    }
}
