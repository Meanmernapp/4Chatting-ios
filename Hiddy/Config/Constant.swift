//
//  Constant.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 09/03/18.
//  Copyright © 2018 APPLE. All rights reserved.

import Foundation
import UIKit

//MARK: Configure colors
//let PRIMARY_COLOR = [UIColor().hexValue(hex: "189089").cgColor, UIColor().hexValue(hex: "175674").cgColor]
//let SECONDARY_COLOR = UIColor().hexValue(hex: "#189089")
let PRIMARY_COLOR = [UIColor().hexValue(hex: "7232aa").cgColor, UIColor().hexValue(hex: "7232aa").cgColor]

let PRIMARY_COLORz = [UIColor().hexValue(hex: "#FFFFFF").cgColor, UIColor().hexValue(hex: "#FFFFFF").cgColor]

//"#FFFFFF"






let SECONDARY_COLOR = UIColor().hexValue(hex: "#7232aa")
let UNREAD_COLOR = UIColor().hexValue(hex: "#FF8004")
//let SENDER_BG_COLOR = UIColor.init(red: 221.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
//let RECIVER_BG_COLOR = UIColor.init(red: 21.0/255.0, green: 115.0/255.0, blue: 137.0/255.0, alpha: 1.0)


//let SENDER_BG_COLOR = UIColor.init(red: 232.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0)
//let SENDER_BG_COLOR = UIColor.init(red: 213.0/255.0, green: 194.0/255.0, blue: 230.0/255.0, alpha: 1.0)
let SENDER_BG_COLOR = UIColor.init(red: 227.0/255.0, green: 214.0/255.0, blue: 238.0/255.0, alpha: 1.0)


let RECIVER_BG_COLOR = UIColor.init(red: 114.0/255.0, green: 50.0/255.0, blue: 170.0/255.0, alpha: 1.0)

let PRIMARY = UIColor.init(named: "primary")!

let TEXT_PRIMARY_COLOR = UIColor.init(named: "primary_text_color")!
let TEXT_SECONDARY_COLOR = UIColor.init(named: "secondary_text_color")!
let BACKGROUND_COLOR = UIColor.init(named: "bg_color")!
let POPUP_COLOR = UIColor.init(named: "pop_color")!
let BOTTOM_BAR_COLOR = UIColor.init(named: "bottom_bar_color")!
let SEPARTOR_COLOR =  UIColor.init(named: "separetor_color")!
let CHAT_SELECTION_COLOR =  UIColor.init(named: "chat_selection_color")!
let NEW_COLOR = UIColor(named: "new")
let TEXT_TERTIARY_COLOR = UIColor().hexValue(hex:"#a3a3a3")
let LINE_COLOR = UIColor().hexValue(hex:"#c9c9c9")
let LITE_GREEN_COLOR = UIColor().hexValue(hex:"#00ff96")
let DARK_GREEN_COLOR = UIColor().hexValue(hex:"#2dc131")
let RED_COLOR = UIColor().hexValue(hex:"#f2163a")
let SELECTION_BORDER_COLOR = UIColor().hexValue(hex: "#D2ACF4")
let whiteTransperntColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.5)

let LIVE_COLOR = UIColor(red: 219.0/255.0, green: 32.0/255.0, blue: 70.0/255.0, alpha: 1.0)
let CIRCLE_BG_COLOR = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)

let NEW_MSG_BACKGROUND = UIColor().hexValue(hex: "#EDEDEE")

//MARK: Configure Font
let APP_FONT_REGULAR = "Tajawal-Regular"
//MARK: screen sizes
let FULL_WIDTH = UIScreen.main.bounds.size.width
let FULL_HEIGHT = UIScreen.main.bounds.size.height

//MARK: Device Models
let IS_IPHONE_X = UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
let IS_IPHONE_XR = UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 1624

let IS_IPHONE_PLUS = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 2208 || UIScreen.main.nativeBounds.height == 1920)
let IS_IPHONE_678 = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 1334)
let IS_IPHONE_5 = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 1136)


//MARK:FILE UPLOAD SIZE
let UPLOAD_SIZE = 50

//MARK:Validation
let ALPHA_PREDICT = "ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*'\",. "
let NUMERIC_PREDICT = "0123456789"
let COUNTRY_PREDICT = "+0123456789"
let NAME_CHARACTERS = "'*=+[]\\|;:'\",<>/?%!@#$^&(){}[].~-_£€₹"

let EMPTY_STRING = ""
let EDIT_VIEW = "1"
var RELOAD_CHAT = "0"

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}
