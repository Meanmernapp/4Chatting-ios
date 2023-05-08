//
//  StoryServices.swift
//  Hiddy
//
//  Created by Roby on 29/07/21.
//  Copyright © 2021 HITASOFT. All rights reserved.
//

import Foundation

class StoryServices: BaseWebService {
    
    //MARK: GET NEW STORIES
    public func recentOfflineStories(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(RECENT_OFFLINE_STORIES)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    //MARK: GET NEW GROUPS
    public func recentViewedStories(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(RECENT_VIEWED_STORIES)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //MARK: GET DELETED STORIES
    public func recentDeletedStories(onSuccess success: @escaping (NSDictionary) -> Void) {
        self.getBaseService(subURl: ("\(RECENT_DELETED_STORIES)/\(UserModel.shared.userID()!)"), onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }

    // story received
    public func storyReceived(story_id: String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(story_id, forKey: "story_id")
        self.baseService(subURl: STORY_RECEIVED_API, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    //clear story viewed
    public func clearStoryViewed(story_id: String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(story_id, forKey: "story_id")
        self.baseService(subURl: CLEAR_STORY_VIEWED, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
    
    
    //clear deleted stories
    public func clearDeletedStories(story_id: String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let requestDict = NSMutableDictionary.init()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(story_id, forKey: "story_id")
        self.baseService(subURl: CLEAR_DELETED_STORIES, params: requestDict as? Parameters, onSuccess: {response in
            success(response)
        }, onFailure: {errorResponse in
        })
    }
//    // story viewed
//    public func storyViewed(story_id: String, onSuccess success: @escaping (NSDictionary) -> Void) {
//        let requestDict = NSMutableDictionary.init()
//        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
//        requestDict.setValue(story_id, forKey: "story_id")
//        self.baseService(subURl: STORY_VIEWED_API, params: requestDict as? Parameters, onSuccess: {response in
//            success(response)
//        }, onFailure: {errorResponse in
//        })
//    }
}
