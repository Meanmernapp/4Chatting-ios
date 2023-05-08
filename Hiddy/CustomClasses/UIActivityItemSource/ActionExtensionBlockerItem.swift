//
//  ActionExtensionBlockerItem.swift
//  Hiddy
//
//  Created by Hitasoft on 24/09/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import Foundation

class ActionExtensionBlockerItem: NSObject, UIActivityItemSource {
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        // remove this app from Activity View Controller
        return SHARE_EXTENSION;
    }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // Returning an NSObject here is safest, because otherwise it is possible for the activity item to actually be shared!
        return NSObject()
    }
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return ""
    }
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return nil
    }
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
}
