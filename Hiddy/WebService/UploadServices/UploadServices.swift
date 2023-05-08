//
//  UploadServices.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 29/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit
import Alamofire

class UploadServices: BaseWebService {

    var dispatchGroup = DispatchGroup()
    //MARK: upload profiel pic service
    public func uploadProfilePic(profileimage:Data,user_id:String,onSuccess success: @escaping (NSDictionary) -> Void) {
        let BaseUrl = URL(string: BASE_URL+PROFILE_PIC_API)
        // print("BASE URL : \(BASE_URL+PROFILE_PIC_API)")
        let parameters = ["user_id": user_id]
        // print("REQUEST : \(parameters)")
        // print("data \(profileimage)")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(profileimage, withName: "user_image", fileName: "profilepic.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
            }
        }, to:BaseUrl!,method:.post,headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                })
                upload.responseJSON { response in
                    let JSON = response.result.value as? NSDictionary
                    // print("RESPONSE \(response)")
                    if JSON != nil{
                        success(JSON!)
                    }
                }
            case .failure(let error):
                // print("FAILURE RESPONSE: \(error.localizedDescription)")
                if error._code == NSURLErrorTimedOut{
//                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                }else if error._code == NSURLErrorNotConnectedToInternet{
                    Utility.shared.goToOffline()
                }else{
                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                }
            }
        }
    }
    
    
    //MARK: upload file service
    public func uploadFiles(fileData:Data,type:String,user_id:String,docuName:String,msg_id:String,api_type:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        var subURL = String()
        var fileKey = String()
        if api_type == "private"{
            subURL = UPLOAD_FILES_API
            fileKey = "attachment"
        }else if api_type == "group"{
            subURL = UPLOAD_GROUP_FILES_API
            fileKey = "group_attachment"
        }
        
        let BaseUrl = URL(string: BASE_URL+subURL)
        // print("BASE URL : \(BASE_URL+subURL)")
        let parameters = ["user_id": user_id]
        // print("REQUEST : \(parameters)")
        
        var mime_type = String()
        var file_name = String()
        
        if type.capitalized == ".jpg".capitalized || type == ""{
            mime_type = "image/jpeg"
            file_name = "attach.jpg"
        }else if type.capitalized == ".png".capitalized{
            mime_type = "image/png"
            file_name = "attach.png"
        }else if type == ".jpeg" {
            mime_type = "image/jpeg"
            file_name = "attach.jpeg"
        }else if type.capitalized == ".mov".capitalized{
            mime_type = "video/mp4"
            file_name = "attach.mp4"
        }else if type.capitalized == ".mp4".capitalized{
            mime_type = "video/mp4"
            file_name = "attach.mp4"
        }else if type.capitalized == ".m4a".capitalized{
            mime_type = "voice/m4a"
            file_name = "attach.m4a"
        }
        else if type == "" {
            mime_type = "video/mp4"
            file_name = "attach.mp4"
        }
        else if type.capitalized == ".pdf".capitalized{
            mime_type = "application/pdf"
            file_name = "attach.pdf"
        }
        else{
            file_name = docuName
            mime_type = self.mimeType(for: fileData)!
        }
        dispatchGroup.enter()
        print("docuName \(docuName), type \(type) mime type \(mime_type) filename \(file_name)")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData, withName:fileKey , fileName:file_name , mimeType: mime_type)
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
            }
        }, to:BaseUrl!,method:.post,headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                })
                upload.responseJSON { response in
                    let JSON = response.result.value as? NSDictionary
                    // print("RESPONSE \(response)")
                    if response.error?.localizedDescription == "The Internet connection appears to be offline."{
                        if api_type == "private"{
                            
                            let localObj = LocalStorage()
                            localObj.readStatus(id: msg_id, status: "4", type: "message")
                            localObj.updateDownload(msg_id: msg_id, status: "4")
                            
                        }else if api_type == "group"{
                            let groupObj = groupStorage()
                            groupObj.updateGroupMediaDownload(msg_id: msg_id, status: "4")
                            groupObj.readMsgStatus(id: msg_id)
                        }
                    }else{
                        if JSON != nil {
                            success(JSON!)
                        }
                    }
                }
            case .failure(let error):
                // print("FAILURE RESPONSE: \(error.localizedDescription)")
                if error._code == NSURLErrorTimedOut{
                    //                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                }else if error._code == NSURLErrorNotConnectedToInternet{
                    Utility.shared.goToOffline()
                }else{
                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                }
                self.dispatchGroup.leave()
            }
        }
    }
    
    public func uploadMultipleFiles(fileData:Data,type:String,user_id:String,docuName:String,api_type:String,onSuccess success: @escaping (NSDictionary) -> Void) {
        var subURL = String()
        var fileKey = String()
        if api_type == "private"{
            subURL = UPLOAD_FILES_API
            fileKey = "attachment"
        }else if api_type == "group"{
            subURL = UPLOAD_GROUP_FILES_API
            fileKey = "group_attachment"
        }
        
        let BaseUrl = URL(string: BASE_URL+subURL)
        // print("BASE URL : \(BASE_URL+subURL)")
        let parameters = ["user_id": user_id]
        // print("REQUEST : \(parameters)")
        
        var mime_type = String()
        var file_name = String()
        
        if type == ".jpg" || type == "" {
            mime_type = "image/jpeg"
            file_name = "attach.jpg"
        }else if type == ".png"{
            mime_type = "image/png"
            file_name = "attach.png"
        }else if type == ".jpeg" {
            mime_type = "image/jpeg"
            file_name = "attach.jpeg"
        }else if type.lowercased() == ".mov".lowercased() || type.lowercased() == "MOV".lowercased(){
            mime_type = "video/mp4"
            file_name = "attach.mp4"
        }else if type.lowercased() == ".mp4"{
            mime_type = "video/mp4"
            file_name = "attach.mp4"
        }
        else if type == ".pdf"{
            mime_type = "application/pdf"
            file_name = "attach.pdf"
        }
        else{
            file_name = docuName
            mime_type = self.mimeType(for: fileData)!
        }
         print("FILE UPLOAD REQUEST \(parameters)")
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData, withName:fileKey , fileName:file_name , mimeType: mime_type)
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
            }
        }, to:BaseUrl!,method:.post,headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                })
                upload.responseJSON { response in
                    let JSON = response.result.value as? NSDictionary
                     print("FILE UPLOAD RESPONSE \(response)")
                    if response.error?.localizedDescription == "The Internet connection appears to be offline."{
                        if api_type == "private"{
                            let localObj = LocalStorage()
//                            localObj.readStatus(id: msg_id, status: "4", type: "message")
//                            localObj.updateDownload(msg_id: msg_id, status: "4")
                            
                        }else if api_type == "group"{
                            let groupObj = groupStorage()
//                            groupObj.updateGroupMediaDownload(msg_id: msg_id, status: "4")
//                            groupObj.readMsgStatus(id: msg_id)
                        }
                    }else{
                        if JSON != nil {
                            success(JSON!)
                        }
                    }
                }
            case .failure(let error):
                 print("FAILURE RESPONSE: \(error.localizedDescription)")
                if error._code == NSURLErrorTimedOut{
                    //                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                }else if error._code == NSURLErrorNotConnectedToInternet{
                    Utility.shared.goToOffline()
                }else{
                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                }
            }
        }
    }
    public func uploadMultipleStatusImages(fileData:[Data] ,type:[String], user_id:String, docuName:[String], api_type:[String], onSuccess success: @escaping (NSDictionary) -> Void) {
        var subURL = [String]()
        var fileKey = [String]()
        var mime_type = [String]()
        var file_name = [String]()

        self.dispatchGroup.enter()
        
        for i in 0..<api_type.count {
            if api_type[i] == "private"{
                subURL[i] = UPLOAD_FILES_API
                fileKey[i] = "attachment"
            }else if api_type[i] == "group"{
                subURL[i] = UPLOAD_GROUP_FILES_API
                fileKey[i] = "group_attachment"
            }
            if type[i] == ".jpg" {
                mime_type[i] = "image/jpeg"
                file_name[i] = "attach.jpg"
            }else if type[i] == ".png"{
                mime_type[i] = "image/png"
                file_name[i] = "attach.png"
            }else if type[i] == ".mov" || type[i] == ".MOV" || type[i] == "MOV"{
                mime_type[i] = "video/mov"
                file_name[i] = "attach.mov"
            }else if type[i] == ".mp4"{
                mime_type[i] = "video/mp4"
                file_name[i] = "attach.mp4"
            }
//            else if type == ".pdf"{
//                mime_type = "application/pdf"
//                file_name = "attach.pdf"
//            }
            else{
                file_name[i] = docuName[i]
                mime_type[i] = self.mimeType(for: fileData[i])!
            }
            // print("docuName \(docuName), type \(type) mime type \(mime_type)")
        }
        let BaseUrl = URL(string: BASE_URL+UPLOAD_FILES_API)
        // print("BASE URL : \(BASE_URL+UPLOAD_FILES_API)")
        let parameters = ["user_id": user_id]
        // print("REQUEST : \(parameters)")

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for imageData in 0..<fileData.count {
                multipartFormData.append(fileData[imageData], withName:"private[]" , fileName:file_name[imageData] , mimeType: mime_type[imageData])
            }
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
            }
        }, to:BaseUrl!,method:.post,headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                })
                upload.responseJSON { response in
                    let JSON = response.result.value as? NSDictionary
                    // print("RESPONSE \(response)")
                    if response.error?.localizedDescription == "The Internet connection appears to be offline."{
                    }else{
                        success(JSON!)
                    }
                }
            case .failure(let error):
                // print("FAILURE RESPONSE: \(error.localizedDescription)")
                if error._code == NSURLErrorTimedOut{
                    //                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                }else if error._code == NSURLErrorNotConnectedToInternet{
                    Utility.shared.goToOffline()
                }else{
                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                }
                self.dispatchGroup.leave()
            }
        }
    }
    
    //MARK: *********  GROUP SERVICE ************
    //MARK: upload group icon
    public func uploadGroupIcon(iconImage:Data,group_id:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let BaseUrl = URL(string: BASE_URL+CHANGE_GROUP_ICON_API)
        // print("BASE URL : \(BASE_URL+CHANGE_GROUP_ICON_API)")
        let parameters = ["group_id": group_id]
        // print("REQUEST : \(parameters)")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(iconImage, withName: "group_image", fileName: "groupIcon.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
            }
        }, to:BaseUrl!,method:.post,headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                })
                upload.responseJSON { response in
                    let JSON = response.result.value as? NSDictionary
                     print("RESPONSE \(response)")
                    if JSON != nil {
                        success(JSON!)
                    }
                }
            case .failure(let error):
                 print("FAILURE RESPONSE: \(error.localizedDescription)")
                if error._code == NSURLErrorTimedOut{
//                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                }else if error._code == NSURLErrorNotConnectedToInternet{
                    Utility.shared.goToOffline()
                }else{
                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                }
            }
        }
    }
    
    //MARK: *********  CHANNEL SERVICE ************
    //MARK: upload channel dp
    public func uploadChannelIcon(iconImage:Data,channel_id:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let BaseUrl = URL(string: BASE_URL+CHANGE_CHANNEL_ICON_API)
        // print("BASE URL : \(BASE_URL+CHANGE_CHANNEL_ICON_API)")
        let parameters = ["channel_id": channel_id]
        // print("REQUEST : \(parameters)")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(iconImage, withName: "channel_attachment", fileName: "channelIcon.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
            }
        }, to:BaseUrl!,method:.post,headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                })
                upload.responseJSON { response in
                    let JSON = response.result.value as? NSDictionary
                    // print("RESPONSE \(response)")
                    success(JSON!)
                }
            case .failure(let error):
                // print("FAILURE RESPONSE: \(error.localizedDescription)")
                if error._code == NSURLErrorTimedOut{
//                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                }else if error._code == NSURLErrorNotConnectedToInternet{
                    Utility.shared.goToOffline()
                }else{
                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                }
            }
        }
    }
    
    public func uploadChannelFiles(fileData:Data,type:String,channel_id:String,docuName:String,msg_id:String, onSuccess success: @escaping (NSDictionary) -> Void) {
        let BaseUrl = URL(string: BASE_URL+UPLOAD_CHANNEL_FILES_API)
        // print("BASE URL : \(BASE_URL+UPLOAD_CHANNEL_FILES_API)")
        let user_id:String = UserModel.shared.userID()! as String
        let parameters = ["channel_id": channel_id,"user_id":user_id]
        // print("REQUEST : \(parameters)")
        
        var mime_type = String()
        var file_name = String()
        
        if type == ".jpg" || type == "" {
            mime_type = "image/jpeg"
            file_name = "attach.jpg"
        }else if type == ".jpeg" {
            mime_type = "image/jpeg"
            file_name = "attach.jpeg"
        }else if type == ".png"{
            mime_type = "image/png"
            file_name = "attach.png"
        }else if type == ".mov" || type == ".MOV" || type == "MOV"{
            mime_type = "video/mov"
            file_name = "attach.mov"
        }else if type == ".mp4"{
            mime_type = "video/mp4"
            file_name = "attach.mp4"
        }
        else if type == ".pdf"{
            mime_type = "application/pdf"
            file_name = "attach.pdf"
        }
        else{
            file_name = docuName
            mime_type = self.mimeType(for: fileData)!
        }
        
         print("docuNamechannel \(file_name), type \(type) mime type \(mime_type)")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData, withName:"channel_attachment" , fileName:file_name , mimeType: mime_type)
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
            }
        }, to:BaseUrl!,method:.post,headers:nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                })
                upload.responseJSON { response in
                    let JSON = response.result.value as? NSDictionary
                    // print("RESPONSE \(response)")
                    if response.error?.localizedDescription == "The Internet connection appears to be offline."{
//                        let localObj = LocalStorage()
//                        localObj.readStatus(id: msg_id, status: "4", type: "message")
//                        localObj.updateDownload(msg_id: msg_id, status: "4")
                    }else{
                        if JSON != nil
                        {
                            success(JSON!)
                        }
                    }
                }
            case .failure(let error):
                // print("FAILURE RESPONSE: \(error.localizedDescription)")
                if error._code == NSURLErrorTimedOut{
//                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                }else if error._code == NSURLErrorNotConnectedToInternet{
                    Utility.shared.goToOffline()
                }else{
                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                }
            }
        }
    }
    
    //get mime type
    func mimeType(for data: Data?) -> String? {
        var c = [UInt32](repeating: 0, count: 1)
        (data! as NSData).getBytes(&c, length: 1)
        switch (c[0]) {
        case 0xff:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4d:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xd0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return "application/octet-stream"
    }
  }
     public func uploadThumbnail(imgData:Data,stream_id:String,user_id:String,onSuccess success: @escaping (NSDictionary) -> Void) {
                let BaseUrl = URL(string: BASE_URL+UPLOAD_STREAM_API)
                 print("BASE URL : \(BASE_URL+UPLOAD_STREAM_API)")
            let parameters = ["name": stream_id,"publisher_id":user_id]
                 print("REQUEST : \(parameters)")
                // print("data \(profileimage)")
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(imgData, withName: "stream_image", fileName: "profilepic.jpeg", mimeType: "image/jpeg")

                    for (key, value) in parameters {
                        multipartFormData.append((value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!), withName: key)
                    }
                }, to:BaseUrl!,method:.post,headers:nil)
                { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (progress) in
                        })
                        upload.responseJSON { response in
    //                        let JSON = response.result.value as? NSDictionary
                             print("RESPONSE \(response)")
    //                        success(JSON!)
                        }
                    case .failure(let error):
                        // print("FAILURE RESPONSE: \(error.localizedDescription)")
                        if error._code == NSURLErrorTimedOut{
        //                    Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                        }else if error._code == NSURLErrorNotConnectedToInternet{
                            Utility.shared.goToOffline()
                        }else{
                            Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                        }
                    }
                }
            }
}

