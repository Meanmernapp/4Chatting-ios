//
//  callSocket.swift
//  Hiddy
//
//  Created by Hitasoft on 27/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation

protocol callSocketDelegate {
    func gotCallSocketInfo(dict:NSDictionary,type:String)
}


class callSocket
{
    static let sharedInstance = callSocket()
    var delegate : callSocketDelegate?
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //create or join the chat
    func createOrJoin(chatId:String){
        let requestArray = NSMutableArray()
        requestArray.add(chatId as NSString)
        socket.defaultSocket.emit("create or join", requestArray)
    }
    func disConnectCall(chatId:String)
    {
        socket.defaultSocket.emit("bye", chatId)
    }
    func createCall(callId:String,user_id:String,caller_id:String,type:String,call_status:String,chat_type:String,call_type:String,room_id:String){
        let requestDict = NSMutableDictionary()
        if call_type == "created"{
            requestDict.setValue(UserModel.shared.phoneNo(), forKey: "phone")
        }
        requestDict.setValue(callId, forKey: "call_id")
        requestDict.setValue(caller_id, forKey: "user_id")
        requestDict.setValue(user_id, forKey: "caller_id")
        requestDict.setValue(type, forKey: "type")
        requestDict.setValue("ios", forKey: "platform")
        requestDict.setValue(chat_type, forKey: "chat_type")
        requestDict.setValue(call_type, forKey: "call_type")
        requestDict.setValue(room_id, forKey: "room_id")
        requestDict.setValue(Utility.shared.getTime(), forKey: "created_at")
        socket.defaultSocket.emit("createcall", requestDict)
    }
    
    func registerCalls(callId:String,user_id:String,receiver_id:String,type:String,call_type:String){
        let requestDict = NSMutableDictionary()
        requestDict.setValue(user_id, forKey: "user_id")
        requestDict.setValue(receiver_id, forKey: "receiver_id")
        requestDict.setValue(call_type, forKey: "status")
        let msgDict = NSMutableDictionary()
        msgDict.setValue(user_id, forKey: "caller_id")
        msgDict.setValue(callId, forKey: "call_id")

        let cryptLib = CryptLib()
        let encryptedMsg = cryptLib.encryptPlainTextRandomIV(withPlainText:"Missed Call", key: ENCRYPT_KEY)
        msgDict.setValue(encryptedMsg, forKey: "message")
        msgDict.setValue(Utility.shared.getTime(), forKey: "created_at")
        msgDict.setValue(call_type, forKey: "call_type")
        msgDict.setValue(type, forKey: "type")
        msgDict.setValue("call", forKey: "chat_type")
        msgDict.setValue(call_type, forKey: "call_status")
        requestDict.setValue(msgDict, forKey: "message_data")
        socket.defaultSocket.emit("registercalls", requestDict)
    }
    
    func acceptCall(callsender_id: String, call_type: String) {
        let requestArray = NSMutableArray()
        requestArray.add(callsender_id as NSString)
        requestArray.add(call_type as NSString)

        socket.defaultSocket.emit("acceptcall", requestArray)

    }
    func RTCMessage(requestDict:NSMutableDictionary){
        socket.defaultSocket.emit("rtcmessage", requestDict)
    }
    
    func CallSocketHandler(){
        socket.defaultSocket.on("callcreated") { ( data, ack) -> Void in
            // print("SOCKET NEW MESSAGE \(data)")
            let callList:NSArray = data as NSArray
            var msgDict = NSDictionary()
            msgDict = callList.object(at: 0) as! NSDictionary
            var call_type = String()
            call_type = msgDict.value(forKey: "call_type") as! String
            if call_type == "ended"{
                self.delegate?.gotCallSocketInfo(dict: msgDict,type: "bye")
            }else if call_type == "waiting"{
                self.delegate?.gotCallSocketInfo(dict: msgDict,type: "waiting")
            }else if call_type == "platform"{
                self.delegate?.gotCallSocketInfo(dict: msgDict,type: "platform")
            }
        }
        socket.defaultSocket.on("join") { ( data, ack) -> Void in
            // print("SOCKET NEW MESSAGE \(data)")
            let msgDict = NSDictionary()

            self.delegate?.gotCallSocketInfo(dict: msgDict,type: "join")
        }
        socket.defaultSocket.on("joined") { ( data, ack) -> Void in
            // print("SOCKET NEW MESSAGE \(data)")
            let msgDict = NSDictionary()
            self.delegate?.gotCallSocketInfo(dict: msgDict, type: "joined")
        }
        socket.defaultSocket.on("bye") { ( data, ack) -> Void in
            // print("SOCKET NEW MESSAGE \(data)")
            let msgDict = NSDictionary()
            self.delegate?.gotCallSocketInfo(dict: msgDict,type: "bye")
        }
        
      
        socket.defaultSocket.on("created") { ( data, ack) -> Void in
            // print("SOCKET NEW MESSAGE \(data)")
            let msgDict = NSDictionary()
            self.delegate?.gotCallSocketInfo(dict: msgDict, type: "created")
        }
        socket.defaultSocket.on("rtcmessage") { ( data, ack) -> Void in
            // print("SOCKET NEW MESSAGE \(data)")
            let msgList:NSArray = data as NSArray
            //let dataStr : String = msgList.object(at: 0) as! String
            if(msgList.object(at: 0) is Dictionary<AnyHashable,Any>)
            {
                let msgDict:NSDictionary = msgList.object(at: 0) as! NSDictionary
                self.delegate?.gotCallSocketInfo(dict: msgDict, type: "rtcmessage")
            }
        }
        socket.defaultSocket.on("recentcalls") { ( data, ack) -> Void in
            print("recentcalls \(data)")
//               let msgDict = NSDictionary()
//
//               self.delegate?.gotCallSocketInfo(dict: msgDict,type: "recentcalls")
           }
    }
    
}

