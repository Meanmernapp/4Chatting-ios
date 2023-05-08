//
//  Album.swift
//  Hiddy
//
//  Created by APPLE on 02/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
import Photos


class PhotoAlbum {
    
    static let albumName = "Hiddy"
    static let sharedInstance = PhotoAlbum()
    let localObj = LocalStorage()
    let groupObj = groupStorage()
    let channelObj = ChannelStorage()
    
    var assetCollection: PHAssetCollection!
    
    init() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            // print("trying again to create the album")
            self.createAlbum()
        } else {
            // print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoAlbum.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
                print(" albummmmm success ")
                
            } else {
                print(" albummmmm error \(error.debugDescription)")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage,msg_id:String,type:String) {
        if msg_id != "" && type != ""{
            var placeHolder : PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeHolder = assetChangeRequest.placeholderForCreatedAsset
                let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                if self.assetCollection != nil{
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    let enumeration: NSArray = [assetPlaceHolder!]
                    albumChangeRequest!.addAssets(enumeration)
                }
            }, completionHandler: {
                success, error in
                if success{
                    // print("success")
                    if placeHolder != nil{
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: [placeHolder!.localIdentifier], options: nil)
                        if let asset = result.firstObject {
                            //here you have the PHAsset
                            asset.getURL(completionHandler: {url in
                                let localObj = LocalStorage()
                                let groupObj = groupStorage()
                                let channelObj = ChannelStorage()
                                if type == "group"{
                                    groupObj.updateGroupMediaLocalURL(msg_id: msg_id, url: "\(placeHolder!.localIdentifier)")
                                }else if type == "single"{
                                    localObj.updateLocalURL(msg_id: msg_id, url: "\(placeHolder!.localIdentifier)")
                                }else if type == "channel"{
                                    channelObj.updateChannelMediaLocalURL(msg_id: msg_id, url: "\(placeHolder!.localIdentifier)")
                                }
                            })
                        }
                    }
                }else{
                    // print("error upload video \(String(describing: error?.localizedDescription))")
                }
            })
        }
        
    }
    
    func saveVideo(url:URL,msg_id:String,type:String)  {
        var placeHolder : PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
            if self.assetCollection != nil{
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                let enumeration: NSArray = [assetPlaceHolder!]
                albumChangeRequest!.addAssets(enumeration)
                placeHolder = assetChangeRequest?.placeholderForCreatedAsset
            }
            
        }, completionHandler: {
            success, error in
            if success{
                // print("success")
                if placeHolder != nil {
                    
                    let result = PHAsset.fetchAssets(withLocalIdentifiers: [placeHolder!.localIdentifier], options: nil)
                    
                    if let asset = result.firstObject {
                        //here you have the PHAsset
                        // print("asseturl \(asset.duration)")
                        asset.getURL(completionHandler: {url in
                            let localObj = LocalStorage()
                            let groupObj = groupStorage()
                            let channelObj = ChannelStorage()
                            if type == "group"{
                                groupObj.updateGroupMediaLocalURL(msg_id: msg_id, url: "\((url)!)")
                            }else if type == "single"{
                                localObj.updateLocalURL(msg_id: msg_id, url: "\((url)!)")
                            }else if type == "channel"{
                                channelObj.updateChannelMediaLocalURL(msg_id: msg_id, url: "\((url)!)")
                            }
                        })
                    }
                }else{
                    // print("error upload video \(String(describing: error?.localizedDescription))")
                }
            }
        })
    }
    func saveForwordVideo(url:URL,msg_id:String,type:String, requestDict: NSDictionary,attachemntData: NSData,newDict: NSDictionary, onSuccess successVal: @escaping (NSDictionary) -> Void) {
        var placeHolder : PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
            if self.assetCollection != nil{
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                let enumeration: NSArray = [assetPlaceHolder!]
                albumChangeRequest!.addAssets(enumeration)
                placeHolder = assetChangeRequest?.placeholderForCreatedAsset
            }
            
        }, completionHandler: {
            success, error in
            if success{
                // print("success")
                let result = PHAsset.fetchAssets(withLocalIdentifiers: [placeHolder!.localIdentifier], options: nil)
                
                if let asset = result.firstObject {
                    //here you have the PHAsset
                    
                    // print("asseturl \(asset.duration)")
                    asset.getURL(completionHandler: {url in
                        let image = Utility.shared.thumbnailForVideoAtURL(url: url!)
                        let flippedImage = UIImage(cgImage: (image?.cgImage)!, scale: (image?.scale)!, orientation: .right)
                        let thumbData = flippedImage.jpegData(compressionQuality: 0.5)//UIImageJPEGRepresentation(flippedImage, 0.5)!
                        if type == "group"{
                            self.groupObj.updateGroupMediaLocalURL(msg_id: msg_id, url: "\((url)!)")
                        }else if type == "single"{
                            self.localObj.updateLocalURL(msg_id: msg_id, url: "\((url)!)")
                        }else if type == "channel"{
                            self.channelObj.updateChannelMediaLocalURL(msg_id: msg_id, url: "\((url)!)")
                        }
                    })
                }
            }else{
                // print("error upload video \(String(describing: error?.localizedDescription))")
            }
        })
    }
    func uploadThumbimage(url:URL,msg_id:String,type:String, requestDict: NSDictionary,thumbData:Data?, onSuccess success: @escaping (NSDictionary) -> Void) {
        let userObj = UploadServices()
        
        userObj.uploadFiles(fileData: thumbData!, type: ".jpg", user_id: UserModel.shared.userID()! as String, docuName: "video", msg_id: msg_id, api_type: "private", onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            let msg_id = Utility.shared.random()
            requestDict.setValue(msg_id, forKey: "message_id")
            
            if status == STATUS_TRUE{
                //                                    msgDict.setValue(response.value(forKey: "user_image"), forKey: "thumbnail")
                if type == "group"{
                    //                    self.groupObj.updateGroupMediaLocalURL(msg_id: msg_id, url: response.value(forKey: "user_image") as! String)
                }else if type == "single"{
                    requestDict.setValue(response.value(forKey: "user_image") as! String, forKey: "thumbnail")
                    //                                        localObj.updateThumbnailURL(msg_id: msg_id, attachment: response.value(forKey: "user_image") as! String)
                }else if type == "channel"{
                    //                    self.channelObj.updateChannelMediaLocalURL(msg_id: msg_id, url: response.value(forKey: "user_image") as! String)
                }
            }
            success(requestDict)
            //                                self.addToLocal(requestDict: requestDict)
        })
    }
    //get image from PHAsset
    func getImage(local_ID : String) ->UIImage? {
        let requestOptions = PHImageRequestOptions()
        var image = UIImage()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        // this one is key
        requestOptions.isSynchronous = true
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [local_ID], options: nil)
        let asset = result.firstObject
        if asset == nil {
            return nil
        }else{
            PHImageManager.default().requestImage(for: asset!, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (pickedImage, info) in
                image = pickedImage!
            })
        }
        return image
    }
    func delete(local_ID: [String], onSuccess success: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            let result = PHAsset.fetchAssets(withLocalIdentifiers: local_ID, options: nil)
            PHAssetChangeRequest.deleteAssets(result)
        }) { (status, error) in
            print(status)
            success(status)
        }
        
    }
    
    func getVideo(local_ID : URL,msg_id:String, requestData:NSDictionary,type:String) {
        var videoData:NSData?
        let requestOptions = PHVideoRequestOptions()
        requestOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.fastFormat
        
        let result = PHAsset.fetchAssets(withALAssetURLs: [local_ID], options: nil)
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: result.firstObject!, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl: URL = urlAsset.url as URL
                // print("local url  \(localVideoUrl)")
                videoData = NSData.init(contentsOf: localVideoUrl)
                socketClass.sharedInstance.uploadChatVideo(fileData: videoData! as Data, type: type, msg_id:msg_id , requestDict: requestData,blockedbyMe: nil,blockedMe: nil)
            }
        })
    }
    func getChannelVideo(local_ID : URL,msg_id:String, requestData:channelMsgModel.message,type:String, channel_id:String, channel_name:String) {
        var videoData:NSData?
        let requestOptions = PHVideoRequestOptions()
        requestOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.fastFormat
        
        let result = PHAsset.fetchAssets(withALAssetURLs: [local_ID], options: nil)
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        if result.firstObject != nil {
            PHImageManager.default().requestAVAsset(forVideo: result.firstObject!, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    // print("local url  \(localVideoUrl)")
                    videoData = NSData.init(contentsOf: localVideoUrl)
                    let msgDict = NSMutableDictionary()
                    let msg_id = Utility.shared.random()
                    msgDict.setValue("channel", forKey: "chat_type")
                    msgDict.setValue(requestData.message_id, forKey: "message_id")
                    msgDict.setValue(UserModel.shared.userID(), forKey: "admin_id")
                    msgDict.setValue(requestData.timestamp, forKey: "chat_time")
                    msgDict.setValue(channel_name, forKey: "channel_name")
                    msgDict.setValue(requestData.channel_id, forKey: "channel_id")
                    msgDict.setValue("video", forKey: "message_type")
                    msgDict.setValue("Video", forKey: "message")
                    msgDict.setValue(requestData.thumbnail, forKey: "thumbnail")
                    msgDict.setValue(requestData.admin_id, forKey: "sender_id")
                    channelSocket.sharedInstance.uploadChatVideo(fileData: videoData! as Data, type: type, msg_id: msg_id, channel_id: channel_id, requestDict: msgDict)
                }
            })
        }
    }
    func getGroupVideo(local_ID : URL,msg_id:String, requestData:groupMsgModel.message,type:String,role:String,phone:String,group_id:String,group_name:String) {
        var videoData:NSData?
        let requestOptions = PHVideoRequestOptions()
        requestOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.fastFormat
        
        let result = PHAsset.fetchAssets(withALAssetURLs: [local_ID], options: nil)
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        if result.firstObject != nil {
            PHImageManager.default().requestAVAsset(forVideo: result.firstObject!, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    // print("local url  \(localVideoUrl)")
                    videoData = NSData.init(contentsOf: localVideoUrl)
                    let msgDict = NSMutableDictionary()
                    msgDict.setValue("group", forKey: "chat_type")
                    msgDict.setValue(requestData.message_id, forKey: "message_id")
                    msgDict.setValue(requestData.member_id, forKey: "member_id")
                    msgDict.setValue(role, forKey: "member_role")
                    msgDict.setValue(phone, forKey: "member_no")
                    msgDict.setValue(UserModel.shared.userName(), forKey: "member_name")
                    msgDict.setValue(requestData.timestamp, forKey: "chat_time")
                    msgDict.setValue(group_name, forKey: "group_name")
                    msgDict.setValue(group_id, forKey: "group_id")
                    msgDict.setValue("video", forKey: "message_type")
                    msgDict.setValue("Video", forKey: "message")
                    msgDict.setValue(requestData.thumbnail, forKey: "thumbnail")
                    
                    groupSocket.sharedInstance.uploadGroupChatVideo(fileData:videoData! as Data , type: type, msg_id: msg_id, requestDict: msgDict)
                    
                }
            })
        }
        
    }
    
    func checkExist(identifier: String) -> Bool? {
        if assetCollection == nil {
            return false
        }
        var available:Bool = false
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", identifier)
        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        if fetchResult.count > 0 {
            if let asset = fetchResult.firstObject {
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = true
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (pickedImage, info) in
                    available = true
                })
                return available
            }
        }
        return available
    }
}
