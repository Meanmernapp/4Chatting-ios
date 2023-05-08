//
//  groupSocket.swift
//  Hiddy
//
//  Created by APPLE on 12/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
protocol groupDelegate {
    func gotGroupInfo(dict:NSDictionary,type:String)
}


protocol groupDelegateChat {
    func gotGroupInfo(dict:NSDictionary,type:String)
}


class groupSocket  {
    static let sharedInstance = groupSocket()
    var delegate : groupDelegate?
    var delegateChat : groupDelegateChat?
    let groupDB = groupStorage()
    let localDB = LocalStorage()
    
    
    //join group
    func joinGroups(){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        let groupList = self.groupDB.getGroupList()
        if groupList.count != 0 {
            for group in groupList{
                let groupDict:NSDictionary = group as! NSDictionary
                let exit = groupDict.value(forKey: "exit") as! String
                print("exit \(exit)")
                if exit == "0"{
                    let requestDict = NSMutableDictionary()
                    requestDict.setValue(groupDict.value(forKey: "group_id"), forKey: "group_id")
                    requestDict.setValue(UserModel.shared.userID(), forKey: "member_id")
                    socket.defaultSocket.emit("joingroup", requestDict)
                }
            }
        }
    }
    
    //group creation
    func createGroup(name:String,group_members:NSArray)  {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(name, forKey: "group_name")
        requestDict.setValue(group_members, forKey: "group_members")
        requestDict.setValue("0", forKey: "group_image")
        socket.defaultSocket.emit("creategroup", requestDict)
    }
    //clear group invites
    func clearGroupInvites(group_id:String)  {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(group_id, forKey: "group_id")
        socket.defaultSocket.emit("cleargroupinvites", requestDict)
        
    }
    //refresh
    func refresh()  {
        let dict = NSDictionary()
        self.delegate?.gotGroupInfo(dict: dict, type: "refreshGroup")
    }
    //send msg
    func sendGroupMsg(requestDict:NSDictionary) {
        socket.defaultSocket.emit("messagetogroup", requestDict)
    }
    //exit group
    func exitGroup(group_id:String,user_id:String,msgDict:NSDictionary) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(group_id, forKey: "group_id")
        requestDict.setValue(user_id, forKey: "member_id")
        requestDict.setValue(UserModel.shared.userID()!, forKey: "user_id")
        requestDict.setValue(msgDict, forKey: "message")
        socket.defaultSocket.emit("exitfromgroup", requestDict)
//        self.removeFromServer(group_id: group_id, user_id: user_id)
    }
    func removeFromServer(group_id:String,user_id:String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(group_id, forKey: "group_id")
        requestDict.setValue(user_id, forKey: "user_id")
        socket.defaultSocket.emit("memberleft", requestDict)
    }
    func groupChatReceived() {
        let requestDict = NSMutableDictionary()
        if UserModel.shared.userID() != nil{
            requestDict.setValue(UserModel.shared.userID()!, forKey: "user_id")
        }
        socket.defaultSocket.emit("groupchatreceived", requestDict)
    }
    //typing group
    func typingGroup(reqDict:NSDictionary) {
        socket.defaultSocket.emit("grouptyping", reqDict)
    }
    
    func infoMsg(admin_id:String,group_id:String,type:String,member_id:String,time:String)  {
        // print("msg dict \(type)")
        let msg_id = Utility.shared.random()
        let groupObj = groupStorage()
        var msg = String()
        let dict = groupObj.getGroupInfo(group_id: group_id)
        
        if dict.count > 0 {
            if type == "create_group"{
                msg = dict.value(forKey: "group_name") as! String
            }else{
                msg = EMPTY_STRING
            }
            groupObj.addGroupChat(msg_id: msg_id, group_id: group_id, member_id: member_id, msg_type: type, msg: msg, time:time, lat: "", lon: "", contact_name: "", contact_no: "", country_code: "", attachment: "", thumbnail: "", admin_id: admin_id, read_status: "0")
            groupObj.updateGroupDetails(group_id: group_id, mute: dict.value(forKey: "mute") as! String, exit: dict.value(forKey: "exit") as! String, message_id: msg_id, timestamp: time, unread_count: "0")
            if  UserModel.shared.groupIDs().contains(group_id) {
                let unreadcount = groupDB.getGroupUnreadCount(group_id: group_id)
                let groupDict = groupDB.getGroupInfo(group_id: group_id)
                let lastMsgInfo = groupDB.getLastMsgInfo(group_id: group_id)
                
                groupDB.updateGroupDetails(group_id: group_id, mute: groupDict.value(forKey: "mute") as! String, exit: groupDict.value(forKey: "exit") as! String, message_id: lastMsgInfo.value(forKey: "message_id") as! String, timestamp: time, unread_count: "\(unreadcount)")
                groupSocket.sharedInstance.groupChatReceived()
                self.delegate?.gotGroupInfo(dict: dict, type: "refreshGroup")
            }
        }
        
    }
    
    //get rencent group message
    //its called when come from offline mode
    func getRecentGroupMsg()  {
        let groupObj = GroupServices()
        groupObj.recentGroupChat(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            print("********Groupmsg \(response)")

            if status == STATUS_TRUE{
                let allGroupDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let msgArray = NSMutableArray()
                msgArray.addObjects(from: allGroupDict.allValues)
                for msg in msgArray {
                    let msgTempDict:NSDictionary = msg as! NSDictionary
                    self.checkAndAddGroupMsg(detailDict:msgTempDict )
                    let userObj = UserWebService()
                    userObj.groupchatReceived(msgDict: msgTempDict, onSuccess: {response in
                    })
                }
                self.delegate?.gotGroupInfo(dict: response, type: "groupRecentMsg")
                self.groupChatReceived()
            }
        })
    }
    // get my old groups
    func myGroups() {
        let groubObj = GroupServices()
        groubObj.myGroups(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let groupArray:NSArray = response.value(forKey: "result") as! NSArray
                for group in groupArray{
                    self.addNewGroup(detailDict: group as! NSDictionary)
                }
            }
        })
    }
    
    // get new groups
    func getNewGroup(){
        let groubObj = GroupServices()
        groubObj.newGroups(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let allGroupDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let groupArray = NSMutableArray()
                groupArray.addObjects(from: allGroupDict.allValues)
                for group in groupArray{
                    self.addNewGroup(detailDict: group as! NSDictionary)
                }
                if groupArray.count == 0{
                    self.getRecentGroupMsg()
                }
            }else{
                self.getRecentGroupMsg()
            }
        })
    }
    
    // add msg to group
    func msgToGroupDB(msgDict:NSDictionary,group_id:String){
        // print("msgDict \(msgDict)")
        let msg_type:String = msgDict.value(forKey: "message_type") as! String
        let member_id:String = msgDict.value(forKey: "member_id") as! String
        if msg_type == "isDelete" {
            let msg_id:String = msgDict.value(forKey: "message_id") as! String
            groupDB.updateGroupMessage(msg_id: msg_id, msg_type: msg_type)
            return
        }else if msg_type == "admin"{
            let attach = msgDict.value(forKey: "attachment") as! String
            if member_id == "\(UserModel.shared.userID()!)"{
                Utility.shared.addGroupMsgToLocal(group_id:group_id,requestDict:msgDict)
            }
            groupDB.makeAdmin(member_key: "\(group_id)\(member_id)",status:attach)
        }else{
            Utility.shared.addGroupMsgToLocal(group_id:group_id,requestDict:msgDict)
        }
    }
    /*
    func checkAndAddGroupMsg(detailDict:NSDictionary){
        let group_id:String = detailDict.value(forKey: "group_id") as! String
        if UserModel.shared.groupIDs().contains(group_id){
            self.msgToGroupDB(msgDict: detailDict, group_id: group_id)
        }else{
            let groupArray = NSMutableArray()
            groupArray.add(group_id)
            let groupObj = GroupServices()
            groupObj.groupInfo(groupArray: groupArray, onSuccess: {response in
                let groupList:NSArray = response.value(forKey: "result") as! NSArray
                for groupDict in groupList{
                    let groupDetails :NSDictionary = groupDict as! NSDictionary
                    let group_id:String = groupDetails.value(forKey: "_id") as! String
                    let group_admin:String = groupDetails.value(forKey: "group_admin_id") as! String
                    self.groupDB.addNewGroup(group_id:group_id , group_name:groupDetails.value(forKey: "group_name") as! String , createAt: groupDetails.value(forKey: "created_at") as! String , createdBy: group_admin)
                    let group_members:NSArray = groupDetails.value(forKey: "group_members") as! NSArray
                    self.addGroupMembers(groupId: group_id, members: group_members, type: "1")
                    self.msgToGroupDB(msgDict: detailDict, group_id: group_id)
                }
            })
        }
    }
    */
    func checkAndAddGroupMsg(detailDict:NSDictionary){
        let group_id:String = detailDict.value(forKey: "group_id") as! String
        if UserModel.shared.groupIDs().contains(group_id){
            self.msgToGroupDB(msgDict: detailDict, group_id: group_id)
        }else{
            let groupArray = NSMutableArray()
            groupArray.add(group_id)
            let groupObj = GroupServices()
            groupObj.groupInfo(groupArray: groupArray, onSuccess: {response in
                let groupList:NSArray = response.value(forKey: "result") as! NSArray
                for groupDict in groupList{
                    let groupDetails :NSDictionary = groupDict as! NSDictionary
                    let group_id:String = groupDetails.value(forKey: "_id") as! String
                    let group_admin:String = groupDetails.value(forKey: "group_admin_id") as! String
                    let group_icon:String = groupDetails.value(forKey: "group_image") as! String
                    self.groupDB.addNewGroup(group_id:group_id , group_name:groupDetails.value(forKey: "group_name") as! String , createAt: groupDetails.value(forKey: "created_at") as! String , createdBy: group_admin, group_icon: group_icon)
                    let group_members:NSArray = groupDetails.value(forKey: "group_members") as! NSArray
                    self.addGroupMembers(groupId: group_id, members: group_members, type: "1")
                    self.msgToGroupDB(msgDict: detailDict, group_id: group_id)
                }
            })
        }
    }
    
    func addGroupHandler()  {
        //chat read response
        socket.defaultSocket.on("groupinvitation") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            self.addNewGroup(detailDict: detailDict)
            self.delegate?.gotGroupInfo(dict: detailDict, type: "groupinvitation")
            print("Ajmal_1")
        }
        
        socket.defaultSocket.on("messagefromgroup") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            self.checkAndAddGroupMsg(detailDict: detailDict)
            self.delegateChat?.gotGroupInfo(dict: detailDict, type: "messagefromgroup")
            print("Ajmal_2")
        }
        socket.defaultSocket.on("memberexited") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            let member_id:String = detailDict.value(forKey: "member_id") as! String
            let group_id:String = detailDict.value(forKey: "group_id") as! String
            if member_id == UserModel.shared.userID()! as String{
                self.removeFromServer(group_id: group_id, user_id: UserModel.shared.userID()! as String)
                socketClass.sharedInstance.goLive()
            }
            print("Ajmal_3")
        }
        socket.defaultSocket.on("listengrouptyping") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            self.delegate?.gotGroupInfo(dict: detailDict, type: "listengrouptyping")
            print("Ajmal_4")
        }
        
        socket.defaultSocket.on("groupdeleted") { ( data, ack) -> Void in
            let listArray:NSArray = data as NSArray
            let detailDict:NSDictionary = listArray.object(at: 0) as! NSDictionary
            self.delegate?.gotGroupInfo(dict: detailDict, type: "groupdeleted")
            print("Ajmal_5")
        }
    }
    
    //add new group
    /*
    func addNewGroup(detailDict:NSDictionary)  {
        // print("detail \(detailDict)")
        let group_id:String = detailDict.value(forKey: "_id") as! String
        let group_admin:String = detailDict.value(forKey: "group_admin_id") as! String
        
        if UserModel.shared.groupIDs().contains(group_id){
            print("*******Group already available")
            let groupDict = self.groupDB.getGroupInfo(group_id: group_id)
            let exit =  groupDict.value(forKey: "exit") as! String
            print("*******Group exit\(exit)")

            if exit == "1"{
                self.groupDB.updateGroupDetails(group_id: group_id, mute: groupDict.value(forKey: "mute") as! String, exit: "0", message_id: groupDict.value(forKey: "message_id") as! String, timestamp: groupDict.value(forKey: "timestamp") as! String, unread_count: groupDict.value(forKey: "unread_count") as! String)
                if group_admin != "\(UserModel.shared.userID()!)"{
                    self.infoMsg(admin_id: group_admin, group_id: group_id, type: "user_added", member_id: "", time: Utility.shared.getTime())
                }
            }else{
                self.groupDB.updateGroupDetails(group_id: group_id, mute: groupDict.value(forKey: "mute") as! String, exit: "0", message_id: groupDict.value(forKey: "message_id") as! String, timestamp: groupDict.value(forKey: "timestamp") as! String, unread_count: groupDict.value(forKey: "unread_count") as! String)
                if !self.groupDB.checkAdded(group_id: group_id){
                    if group_admin != "\(UserModel.shared.userID()!)"{
                        self.infoMsg(admin_id: group_admin, group_id: group_id, type: "user_added", member_id: "", time: detailDict.value(forKey: "created_at") as! String)
                    }
                }
            }
        }else{
            print("*******Group not available")
            
            self.groupDB.addNewGroup(group_id:group_id , group_name:detailDict.value(forKey: "group_name") as! String , createAt: detailDict.value(forKey: "created_at") as! String , createdBy: group_admin)
            self.clearGroupInvites(group_id: group_id)
            socketClass.sharedInstance.goLive()
            let group_members:NSArray = detailDict.value(forKey: "group_members") as! NSArray
            self.addGroupMembers(groupId: group_id, members: group_members, type: "1")
            if !self.groupDB.checkAdded(group_id: group_id){
                if group_admin != "\(UserModel.shared.userID()!)"{
                    self.infoMsg(admin_id: group_admin, group_id: group_id, type: "user_added", member_id: "", time: detailDict.value(forKey: "created_at") as! String)
                }
                self.infoMsg(admin_id: group_admin, group_id: group_id, type: "create_group", member_id: "", time: detailDict.value(forKey: "created_at") as! String)
            }
        }
        groupSocket.sharedInstance.joinGroups()
        groupSocket.sharedInstance.refresh()
        self.getRecentGroupMsg()
    }
    */
    func addNewGroup(detailDict:NSDictionary)  {
        // print("detail \(detailDict)")
        let group_id:String = detailDict.value(forKey: "_id") as! String
        let group_admin:String = detailDict.value(forKey: "group_admin_id") as! String
        let group_icon:String = detailDict.value(forKey: "group_image") as! String
        
        if UserModel.shared.groupIDs().contains(group_id){
            print("*******Group already available")
            let groupDict = self.groupDB.getGroupInfo(group_id: group_id)
            let exit =  groupDict.value(forKey: "exit") as! String
            print("*******Group exit\(exit)")

            if exit == "1"{
                self.groupDB.updateGroupDetails(group_id: group_id, mute: groupDict.value(forKey: "mute") as! String, exit: "0", message_id: groupDict.value(forKey: "message_id") as! String, timestamp: groupDict.value(forKey: "timestamp") as! String, unread_count: groupDict.value(forKey: "unread_count") as! String)
                if group_admin != "\(UserModel.shared.userID()!)"{
                    self.infoMsg(admin_id: group_admin, group_id: group_id, type: "user_added", member_id: "", time: Utility.shared.getTime())
                }
            }else{
                self.groupDB.updateGroupDetails(group_id: group_id, mute: groupDict.value(forKey: "mute") as! String, exit: "0", message_id: groupDict.value(forKey: "message_id") as! String, timestamp: groupDict.value(forKey: "timestamp") as! String, unread_count: groupDict.value(forKey: "unread_count") as! String)
                if !self.groupDB.checkAdded(group_id: group_id){
                    if group_admin != "\(UserModel.shared.userID()!)"{
                        self.infoMsg(admin_id: group_admin, group_id: group_id, type: "user_added", member_id: "", time: detailDict.value(forKey: "created_at") as! String)
                    }
                }
            }
        }else{
            print("*******Group not available")
            
            self.groupDB.addNewGroup(group_id:group_id , group_name:detailDict.value(forKey: "group_name") as! String , createAt: detailDict.value(forKey: "created_at") as! String , createdBy: group_admin, group_icon: group_icon)
            self.clearGroupInvites(group_id: group_id)
            socketClass.sharedInstance.goLive()
            let group_members:NSArray = detailDict.value(forKey: "group_members") as! NSArray
            self.addGroupMembers(groupId: group_id, members: group_members, type: "1")
            if !self.groupDB.checkAdded(group_id: group_id){
                if group_admin != "\(UserModel.shared.userID()!)"{
                    self.infoMsg(admin_id: group_admin, group_id: group_id, type: "user_added", member_id: "", time: detailDict.value(forKey: "created_at") as! String)
                }
                self.infoMsg(admin_id: group_admin, group_id: group_id, type: "create_group", member_id: "", time: detailDict.value(forKey: "created_at") as! String)
            }
        }
        groupSocket.sharedInstance.joinGroups()
        groupSocket.sharedInstance.refresh()
        self.getRecentGroupMsg()
    }
    // add group memebers
    func addGroupMembers(groupId:String,members:NSArray,type:String)  {
        for people in members  {
            let peopleTempArray = NSMutableArray.init(array: [people])
            
            if peopleTempArray.object(at: 0) is NSDictionary{
                
                let  peopleTempDict:NSDictionary = peopleTempArray.object(at: 0) as! NSDictionary
                var member_id = String()
                var member_role = String()
                if type == "1"{
                    member_id = peopleTempDict.value(forKey: "member_id") as! String
                    member_role = peopleTempDict.value(forKey: "member_role") as! String
                }else{
                    member_id = peopleTempDict.value(forKey: "user_id") as! String
                    member_role = "0"
                }
                if member_id == (UserModel.shared.userID() as String? ?? ""){
                    self.groupDB.groupRemoveExit(group_id: groupId)
                    self.groupDB.addGroupMembers(group_id: groupId, member_id: member_id, member_role: member_role)
                    
                }
                if (UserModel.shared.contactIDs()?.contains(member_id))!{
                    self.groupDB.addGroupMembers(group_id: groupId, member_id: member_id, member_role: member_role)
                }else{
                    let userObj = UserWebService()
                    userObj.otherUserDetail(contact_id: member_id, onSuccess: {response in
                        let status:String = response.value(forKey: "status") as! String
                        if status == STATUS_TRUE{
                            var contact_status = String()
                            if response.value(forKey: "contactstatus")  != nil{
                                contact_status = response.value(forKey: "contactstatus") as! String
                            }
                            let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                            let cc = response.value(forKey: "country_code") as! Int
                            
                            self.localDB.addContact(userid: member_id,
                                                    contactName: ("+\(cc) " + "\(phone_no)"),
                                                    userName: response.value(forKey: "user_name") as? String ?? "",
                                                    phone: "\(phone_no)",
                                                    img: response.value(forKey: "user_image") as! String,
                                                    about: response.value(forKey: "about") as? String ?? "",
                                                    type: EMPTY_STRING,
                                                    mutual:contact_status,
                                                    privacy_lastseen: response.value(forKey: "privacy_last_seen") as! String,
                                                    privacy_about: response.value(forKey: "privacy_about") as! String,
                                                    privacy_picture: response.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
                            
                            self.groupDB.addGroupMembers(group_id: groupId, member_id: member_id, member_role: member_role)
                        }
                    })
                }
            }
        }
    }
    
    
    //upload video
    func uploadGroupChatVideo(fileData:Data,type:String,msg_id:String,requestDict:NSDictionary)  {
        self.groupDB.updateGroupMediaDownload(msg_id: msg_id, status: "2")
        let uploadObj = UploadServices()
        uploadObj.uploadFiles(fileData: fileData, type: type, user_id: UserModel.shared.userID()! as String, docuName: "Video",msg_id: msg_id,api_type:"group", onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                self.groupDB.updateGroupVideoURL(msg_id: msg_id, attachment: response.value(forKey: "user_image") as! String)
                self.groupDB.updateGroupMediaDownload(msg_id: msg_id, status: "1")
                let msgdict = NSMutableDictionary.init(dictionary: requestDict)
                msgdict.removeObject(forKey: "attachment")
                msgdict.removeObject(forKey: "chat_time")
                let cryptLib = CryptLib()
                
                let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:response.value(forKey: "user_image") as? String, key: ENCRYPT_KEY)
                
                msgdict.setValue(encryptedMsg, forKey: "attachment")
                msgdict.setValue(Utility.shared.getTime(), forKey: "chat_time")
                groupSocket.sharedInstance.sendGroupMsg(requestDict: msgdict)
                self.delegate?.gotGroupInfo(dict: msgdict, type: "groupUploadVideo")
            }
        })
    }
}

