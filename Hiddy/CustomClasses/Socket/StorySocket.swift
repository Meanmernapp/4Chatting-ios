//
//  StorySocket.swift
//  Hiddy
//
//  Created by Hitasoft on 05/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import Foundation
protocol storyDelegate {
    func gotStoryInfo(dict:NSArray,type:String)
}
class StorySocket  {
    static let sharedInstance = StorySocket()
    var delegate : storyDelegate?
    let groupDB = storyStorage()
    let localDB = LocalStorage()
    
    //send request to story Viewer
    func viewStory(sender_id:String,receiver_id:String, story_id: String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(sender_id, forKey: "sender_id")
        requestDict.setValue(receiver_id, forKey: "receiver_id")
        requestDict.setValue(story_id, forKey: "story_id")
        socket.defaultSocket.emit("viewstory", requestDict)
    }
    func deleteStory(story_id: String, memberID: String) {
        let requestDict = NSMutableDictionary()
        let StrMembers = memberID.components(separatedBy: ",")
        let memberArr = getMemberId(selectedId: StrMembers)
        requestDict.setValue(story_id, forKey: "story_id")
        requestDict.setValue(memberArr, forKey: "story_members")
        print(requestDict)
        socket.defaultSocket.emit("deletestory", requestDict)
    }
    func getMemberId(selectedId: Array<Any>)->NSMutableArray{
        let mutableArray = NSMutableArray()
        for id in selectedId {
            let dict = NSMutableDictionary()
            dict.setValue(id, forKey: "member_id")
            dict.setValue("0", forKey: "member_role")
            let memberDict = ["member_id":id]
            mutableArray.add(memberDict)
        }
        return mutableArray
    }
    func postStory(user_id: String, story_id: String, stories: NSDictionary) {
        let requestDict = stories
        requestDict.setValue("ios", forKey: "device_type")
        socket.defaultSocket.emit("poststory", stories)
    }
    func updateReceivedSocket(story_id: String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(story_id, forKey: "story_id")
        requestDict.setValue(UserModel.shared.userID() as String? ?? "", forKey: "user_id")
        socket.defaultSocket.emit("storyofflineclear", requestDict)
    }
    func storyReceived(story_id: String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(story_id, forKey: "story_id")
        requestDict.setValue(UserModel.shared.userID() as String? ?? "", forKey: "user_id")
        socket.defaultSocket.emit("storyreceived", requestDict)
    }
    
    func clearStoryViewed(story_id: String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(story_id, forKey: "story_id")
        requestDict.setValue(UserModel.shared.userID() as String? ?? "", forKey: "user_id")
        socket.defaultSocket.emit("clearstoryviewed", requestDict)
    }
    
    func clearStoryDelete(story_id: String) {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(story_id, forKey: "story_id")
        requestDict.setValue(UserModel.shared.userID() as String? ?? "", forKey: "user_id")
        socket.defaultSocket.emit("clearofflinedeletedstories", requestDict)
    }
    
    //recent stories
    func getRecentStories()  {
        let serviceObj = StoryServices()
        //recent new invites
        serviceObj.recentOfflineStories(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let storyDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let storyArray = NSMutableArray()
                storyArray.addObjects(from: storyDict.allValues)
                for story in storyArray{
                    let dict:NSDictionary = story as! NSDictionary
                    self.addStoryToLocal(story: dict)
                    let storyID = dict.value(forKey: "story_id") as? String ?? ""
                    //story received socket
                    self.storyReceived(story_id: storyID)
                    //story received api
                    serviceObj.storyReceived(story_id: storyID, onSuccess:{response in
                    })
                }
            }
        })
        
        //recent viewers for my stories
        serviceObj.recentViewedStories(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let storyDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let storyArray = NSMutableArray()
                storyArray.addObjects(from: storyDict.allValues)
                self.updateStoryViewed(storyArray: storyArray)
            }
        })
        
        //recent deleted stories
        serviceObj.recentDeletedStories(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let storyDict:NSDictionary = response.value(forKey: "result") as! NSDictionary
                let storyArray = NSMutableArray()
                storyArray.addObjects(from: storyDict.allValues)
                self.updateStoryDelete(storyArray: storyArray)
            }
        })
    }
    
    //add story to local
    func addStoryToLocal(story:NSDictionary)  {
        let contacts = LocalStorage.sharedInstance.getContactList()
        let senderID = story.value(forKey: "sender_id") as? String ?? ""
        let storyID = story.value(forKey: "story_id") as? String ?? ""
        let message = story.value(forKey: "message") as? String ?? ""
        let storyType = story.value(forKey: "story_type") as? String ?? ""
        let attachment = story.value(forKey: "attachment") as? String ?? ""
        let storyDate = story.value(forKey: "story_date") as? String ?? ""
        let storyTime = story.value(forKey: "story_time") as? String ?? ""
        let expiryTime = story.value(forKey: "expiry_time") as? String ?? ""
        let thumbnail = story.value(forKey: "thumbnail") as? String ?? ""
        let storyMembers = story.value(forKey: "story_members") as! NSArray
        var selectedID = [String]()
        for i in storyMembers {
            selectedID.append(i as? String ?? "")
        }
        let strMembers = selectedID.joined(separator: ",")
        for contact in contacts {
            let userID = (contact as AnyObject).value(forKey: "user_id") as? String ?? ""
            if userID == senderID {
                let contactlist = self.localDB.getContact(contact_id: userID)
                let blockByMe = contactlist.value(forKey: "blockedByMe") as! String
                let blockedMe = contactlist.value(forKey: "blockedMe") as! String
                if blockedMe != "1" || blockByMe != "1"{
                    storyStorage.sharedInstance.addStory(story_id: storyID, sender_id: senderID, story_members: strMembers, message: message, story_type: storyType, attachment: attachment, story_date: storyDate, story_time: storyTime, expiry_time: expiryTime, thumbNail: thumbnail)
                }
            }
        }
    }
    //update story viewed
    func updateStoryViewed(storyArray:NSArray)  {
        let serviceObj = StoryServices()

        for viewStory in storyArray {
            print(viewStory)
            if viewStory is NSDictionary {
                let story = viewStory as! NSDictionary
                let senderID = story.value(forKey: "sender_id") as? String ?? ""
                let receiverID = story.value(forKey: "receiver_id") as? String ?? ""
                let storyID = story.value(forKey: "story_id") as? String ?? ""
                
                storyStorage.sharedInstance.addViewList(sender_id: senderID, receiver_id: receiverID, story_id: storyID, timestamp:Utility().getTime())
               
                //clear acknowledge for api and socket
                self.clearStoryViewed(story_id: storyID)
                serviceObj.clearStoryViewed(story_id: storyID, onSuccess:{response in
                })
            }
            else {
                if viewStory is NSArray {
                    let storyArray = viewStory as! NSArray
                    let story = storyArray[0] as! NSDictionary
                    let senderID = story.value(forKey: "sender_id") as? String ?? ""
                    let receiverID = story.value(forKey: "receiver_id") as? String ?? ""
                    let storyID = story.value(forKey: "story_id") as? String ?? ""
                    storyStorage.sharedInstance.addViewList(sender_id: senderID, receiver_id: receiverID, story_id: storyID, timestamp: Utility().getTime())
                    //clear acknowledge for api and socket
                    self.clearStoryViewed(story_id: storyID)
                    serviceObj.clearStoryViewed(story_id: storyID, onSuccess:{response in
                    })
                }
            }
        }
    }
    //story delete
    func updateStoryDelete(storyArray:NSArray)  {
        let serviceObj = StoryServices()

        for viewStory in storyArray {
            print(viewStory)
            if viewStory is NSDictionary {
                let story = viewStory as! NSDictionary
                let storyIDArr = story.value(forKey: "story_id") as? NSArray ?? [""]
                for i in storyIDArr {
                    let storyID = i as? String ?? ""
                    let storyList = storyStorage.sharedInstance.checkIfExsit(story_id: storyID)
                    let attachment = storyList.first?.attachment ?? ""
                    storyStorage.sharedInstance.deleteStory(story_id: storyID, fileName: attachment)
                    //clear acknowledge for api and socket
                    self.clearStoryDelete(story_id: storyID)
                    serviceObj.clearDeletedStories(story_id: storyID, onSuccess:{response in
                    })
                }
            }else {
                let story = jsonToString(value: viewStory as? String ?? "")
                let storyIDArr = story?["story_id"] as? NSArray ?? [""]
                for i in storyIDArr {
                    let storyID = i as? String ?? ""
                    let storyList = storyStorage.sharedInstance.checkIfExsit(story_id: storyID)
                    let attachment = storyList.first?.attachment ?? ""
                    storyStorage.sharedInstance.deleteStory(story_id: "\(storyID)", fileName: attachment)
                    //clear acknowledge for api and socket
                    self.clearStoryDelete(story_id: storyID)
                    serviceObj.clearDeletedStories(story_id: storyID, onSuccess:{response in
                    })

                }
            }
//            self.loadStory()
//            let dict = NSDictionary()
            self.delegate?.gotStoryInfo(dict: storyArray, type: "stroydeleted")

        }

    }
    
    func jsonToString(value: String) -> Dictionary<String, Any>? {
        let string = value
        let data = string.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
            {
                // print(jsonArray) // use the json here
                return jsonArray
            } else {
                // print("bad json")
            }
        } catch let _ as NSError { // let error as NSError
            // print(error)
        }
        return nil
    }
    
    //MARK: STORY HANDLERS
    func addStoryHandler() {
        socket.defaultSocket.on("receivestory") { (data, ack) in
             print("SOCKET NEW receive Status MESSAGE \(data)")
            let storyArray = data as NSArray
            for story in storyArray {

                let story = story as! NSDictionary
                let user_id = story.value(forKey: "user_id") as? String ?? ""
                
                if (UserModel.shared.contactIDs()?.contains(user_id))!{
                    self.addStoryToLocal(story: story)
                    let storyID = story.value(forKey: "story_id") as? String ?? ""
                    //story received socket
                    self.storyReceived(story_id: storyID)
                }else{
                    let userObj = UserWebService()
                    userObj.otherUserDetail(contact_id: user_id, onSuccess: {response in
                        let status:String = response.value(forKey: "status") as! String
                        if status == STATUS_TRUE{
                            let phone_no :NSNumber = response.value(forKey: "phone_no") as! NSNumber
                            let cc = response.value(forKey: "country_code") as! Int
                            self.localDB.addContact(userid: user_id,
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
                            
                            self.addStoryToLocal(story: story)
                            let storyID = story.value(forKey: "story_id") as? String ?? ""
                            //story received socket
                            self.storyReceived(story_id: storyID)
                        }
                    })
                }

            }
            self.delegate?.gotStoryInfo(dict: storyArray, type: "receivestory")
        }
//        socket.defaultSocket.on("getbackstatus") { ( data, ack) in
//            // print("SOCKET NEW getBack Status Status MESSAGE \(data)")
//            let value = data as NSArray
//            let storyDict = value[0] as? NSDictionary ?? ["stories":""]
//            self.delegate?.gotStoryInfo(dict: storyDict["stories"] as? NSArray ?? [""], type: "getbackstatus")
//        }
        socket.defaultSocket.on("storyviewed") { ( data, ack) in
             print("SOCKET NEW Status MESSAGE \(data)")
            let value = data as NSArray
            let storyDict = value[0] as? NSDictionary ?? ["viewers":""]
            let storyArray = storyDict["viewers"] as? NSArray
            self.updateStoryViewed(storyArray: storyArray!)
//            self.delegate?.gotStoryInfo(dict: storyDict["viewers"] as? NSArray ?? [""], type: "storyviewed")
        }
        socket.defaultSocket.on("storydeleted") { ( data, ack) in
            // print("SOCKET NEW Status MESSAGE \(data)")
            let value = data as NSArray
            self.updateStoryDelete(storyArray: value)

//            self.delegate?.gotStoryInfo(dict: value, type: "stroydeleted")
        }
//        socket.defaultSocket.on("storyofflinedelete") { ( data, ack) in
//            // print("SOCKET NEW Status MESSAGE \(data)")
//            let value = data as NSArray
//            self.delegate?.gotStoryInfo(dict: value, type: "storyofflinedelete")
//        }
    }
}
