//
//  ChannelServices.swift
//  Hiddy
//
//  Created by APPLE on 01/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class ChannelServices: BaseWebService {

    
    // All public channels
    public func allPublicChannels(offset:String,search:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(ALL_CHANNELS)/\(UserModel.shared.userID()!)/\(search)/\(offset)/20"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    public func subscriberList(channel_id:String,phone:String,offset:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(ALL_SUBSCRIBER)/\(channel_id)/\(UserModel.shared.userDict().value(forKey: "phone_no")!)/\(offset)/20"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    public func subscriberids(channel_id:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(SUBSCRIBER_IDS)/\(channel_id)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //get new admin channel
    public func adminChannels( onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(ADMIN_CHANNELS)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    // admin channel recent msg
    public func adminChannelMsg(timestamp:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(GET_ADMIN_CHANNEL_MSG)/\(timestamp)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    // report channel
    public func reportChannel(user_id:String,channel_id: String, report: String, status: String, onSuccess success: @escaping (NSDictionary) -> Void) {
        // user_id, channel_id, report, status
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(channel_id, forKey: "channel_id")
        requestDict.setValue(report, forKey: "report")
        requestDict.setValue(status, forKey: "status")
        self.baseService(subURl: REPORT_CHANNEL, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }

    //get new channel
    public func recentChannels( onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(RECENT_CHANNEL_INVITES)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    // channel recent msg
    public func recentChannelMsg(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(RECENT_CHANNEL_CHATS)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //mychannels
    public func myChannels(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(MY_CHANNEL_API)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //subscribed channels
    public func mySubscribedChannels(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(MY_SUBSCRIBED_CHANNEL)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //channel info
    public func channelInfo(channelList:NSArray, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(Utility.shared.convertJson(from: channelList), forKey: "channel_list")
        print(requestDict)
        self.baseService(subURl: CHANNEL_INFO, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //update channel info
    public func updateChannel(channel_id:String,channel_name:String,channel_des:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(channel_id, forKey: "channel_id")
        requestDict.setValue(channel_name, forKey: "channel_name")
        requestDict.setValue(channel_des, forKey: "channel_des")
        self.baseService(subURl: UPDATE_CHANNEL_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
}
