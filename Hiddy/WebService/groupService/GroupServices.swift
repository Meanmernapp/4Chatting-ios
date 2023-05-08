//
//  GroupServices.swift
//  Hiddy
//
//  Created by APPLE on 12/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class GroupServices: BaseWebService {
    //MARK: GET MY GROUPS
    public func myGroups(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(MY_GROUPS)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }

    //MARK: GET NEW GROUPS
    public func newGroups(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(GROUP_INVITES)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //add new members
    public func addNewMembers(group_id:String,members:NSMutableArray, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(self.json(from: members), forKey: "group_members")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(group_id, forKey: "group_id")
        self.baseService(subURl: ADD_NEW_MEMBERS, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: get recent group chat list
    public func recentGroupChat(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(GROUP_RECENT_CHATS)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: delete account
    public func deleteAccount(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(DELETE_ACCOUNT)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: Modify group subject
    public func modifySubject(group_id:String,group_name:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(group_name, forKey: "group_name")
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(group_id, forKey: "group_id")
        self.baseService(subURl: MODIFY_GROUP_INFO, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //modify group members
    public func groupInfo(groupArray:NSArray, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(self.json(from: groupArray), forKey: "group_list")
        self.baseService(subURl: GROUP_INFO_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //modify group members
    public func modifyMember(group_id:String,memberArray:NSArray, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(group_id, forKey: "group_id")
        requestDict.setValue(self.json(from: memberArray), forKey: "group_members")
        self.baseService(subURl: MODIFY_GROUP_INFO, params: requestDict as? Parameters, onSuccess: {response in
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
