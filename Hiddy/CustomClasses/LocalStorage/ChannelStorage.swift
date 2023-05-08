//
//  ChannelStorage.swift
//  Hiddy
//
//  Created by APPLE on 01/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
import SQLite3
import FMDB

class ChannelStorage: NSObject {
    
    let localObj = LocalStorage()
    static let sharedInstance = ChannelStorage()
    
    func createChannel()  {
        //CHANNEL TABLE
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS CHANNELS (channel_id VARCHAR(40) PRIMARY KEY,title TEXT,description TEXT,created_time TEXT,created_by TEXT,channel_icon TEXT,mute TEXT DEFAULT '0',message_id TEXT,timestamp TEXT,unread_count TEXT,channel_type TEXT,subscriber_count TEXT,subscribtion_status TEXT DEFAULT '0',admin_name TEXT DEFAULT '0',report TEXT DEFAULT '0',block_status TEXT DEFAULT '0')", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS CHANNEL_MESSAGE (message_id VARCHAR(80) PRIMARY KEY, channel_id TEXT,admin_id TEXT, message_type TEXT,message TEXT, timestamp TEXT,lat TEXT,lon TEXT,contact_name TEXT,contact_no TEXT, country_code TEXT, attachment TEXT, thumbnail TEXT,isDownload TEXT DEFAULT '0',date TEXT,local_path TEXT DEFAULT '0',read_status TEXT,translated_status TEXT DEFAULT '0',translated_msg TEXT DEFAULT '', message_date TEXT)", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
    }
    //get unread count
    func checkAdded(channel_id:String)->Bool  {
        var available:Bool = false
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE message_type = 'added' AND channel_id = '\(channel_id)'"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    available = true
                }
                sqlite3_finalize(stmt)
            }else{
                // print("Failed from sqlite3_prepare_v2. Error is:\(sqlite3_errmsg(db))" );
            }
            
            sqlite3_close(db)
        }
        return available
    }
    
    //add new channel
    func addNewChannel(channel_id:String,title:String,description:String,created_time:String,channel_type:String,created_by:String,subCount:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        let channelDict:NSDictionary =  self.getChannelInfo(channel_id: channel_id)
        var mute = String()
        if channelDict.value(forKey: "mute") == nil {
            mute  = "0"
        }else{
            mute  = channelDict.value(forKey: "mute") as! String
        }
        var report = String()
        if channelDict.value(forKey: "report") == nil {
            report  = "0"
        }else{
            report  = channelDict.value(forKey: "report") as! String
        }
        
        var subscribtion_status = String()
        if channelDict.value(forKey: "subscribtion_status") == nil {
            if status == "1"{
                subscribtion_status  = "1"
            }else{
                subscribtion_status  = "0"
            }
        }else{
            subscribtion_status  = channelDict.value(forKey: "subscribtion_status") as! String
        }
        
        
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO CHANNELS (channel_id,title,description,created_time,channel_type,created_by,mute,report,subscriber_count,subscribtion_status) VALUES ('\(channel_id)','\(title)','\(description)','\(created_time)','\(channel_type)','\(created_by)','\(mute)','\(report)','\(subCount)','\(subscribtion_status)');"
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
        self.getChannelID()
        
    }
    
    func updateChannelDetails(channel_id:String,mute:String,report:String,message_id:String,timestamp:String,unread_count:String)  {
        
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            //            INSERT OR REPLACE INTO RECENT
            let queryString = "UPDATE CHANNELS SET (mute,report,message_id,timestamp,unread_count) = ('\(mute)','\(report)','\(message_id)','\(timestamp)','\(unread_count)') WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    func updateChannelProfile(channel_id:String,title:String,description:String,subscriber_count:String)  {
        
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            //INSERT OR REPLACE INTO RECENT
            let queryString = "UPDATE CHANNELS SET (channel_id,title,description,subscriber_count) = ('\(channel_id)','\(title)','\(description)','\(subscriber_count)') WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    
    //get channel information
    func getChannelInfo(channel_id:String) -> NSMutableDictionary {
        let  channelDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM CHANNELS WHERE channel_id = '\(channel_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "channel_id")
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "channel_name")
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "channel_des")
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "created_time")
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "created_by")
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "channel_type")
                    var subscriberCount = String()
                    if sqlite3_column_text(stmt, 11) != nil{
                        subscriberCount = String(cString: sqlite3_column_text(stmt, 11))
                    }else{
                        subscriberCount = "0"
                    }
                    channelDict.setValue(subscriberCount, forKey: "subscriber_count")
                    
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "subscribtion_status")
                    
                    if sqlite3_column_text(stmt, 5) != nil{
                        channelDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "channel_image")
                    }else{
                        channelDict.setValue(EMPTY_STRING, forKey: "channel_image")
                    }
                    channelDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "mute")
                    if sqlite3_column_text(stmt, 14) == nil{
                        channelDict.setValue("0", forKey: "report")
                    }
                    else {
                        channelDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "report")
                    }
                    
                    if sqlite3_column_text(stmt, 7) != nil{
                        channelDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "message_id")
                        channelDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "timestamp")
                        channelDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "unread_count")
                    }
                    var admin_name = String()
                    if sqlite3_column_text(stmt, 13) != nil{
                        admin_name = String(cString: sqlite3_column_text(stmt, 13))
                    }else{
                        admin_name = ""
                    }
                    channelDict.setValue(admin_name, forKey: "admin_name")
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return channelDict
    }
    
    //get over all channel
    func getChannelID()  {
        let idArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT channel_id FROM CHANNELS"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    idArray.add(id)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        UserModel.shared.setChannelIDs(IDs: idArray)
    }
    //get active channels
    func getActiveChannels()  {
        let idArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT channel_id FROM CHANNELS WHERE subscribtion_status = '1'"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    idArray.add(id)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        UserModel.shared.setActiveChannels(IDs: idArray)
    }
    func addStickyDate(channel_id:String,timestamp:String)  {
        let msg_id = Utility.shared.random()
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {

            
            let queryString = "INSERT OR REPLACE INTO CHANNEL_MESSAGE (message_id,channel_id,admin_id,message_type,message,timestamp,lat,lon,contact_name,contact_no,country_code,attachment,thumbnail,date,read_status) VALUES ('\(msg_id)','\(channel_id)','','date_sticky','','\(timestamp)','','','','','','','','\(timestamp)','');"

             print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                 print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            let errmsg =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    //get last message
    func getLastMsgTime(channel_id:String) -> String {
        var  timeStr = ""
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE channel_id = '\(channel_id)' ORDER BY timestamp DESC LIMIT 1"
             print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    timeStr = String(cString: sqlite3_column_text(stmt, 5))
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return timeStr
    }
    
    // ADD GROUP CHAT LIST
    func addChannelMsg(msg_id:String,channel_id:String,admin_id:String,msg_type:String,msg:String,time:String,lat:String,lon:String,contact_name:String,contact_no:String,country_code:String,attachment:String,thumbnail:String,read_status:String,msg_date:String) {
     
        let timeStr = self.getLastMsgTime(channel_id: channel_id)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let currentMsgTime = formatter.date(from: time)

        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var dateString = String()
            dateString = Utility.shared.chatDateInEnglish(stamp: Utility.shared.convertToDouble(string: time))
            let queryString = "INSERT OR REPLACE INTO CHANNEL_MESSAGE (message_id,channel_id,admin_id,message_type,message,timestamp,lat,lon,contact_name,contact_no,country_code,attachment,thumbnail,date,read_status,message_date) VALUES ('\(msg_id)','\(channel_id)','\(admin_id)','\(msg_type)','\(msg)','\(time)','\(lat)','\(lon)','\(contact_name)','\(contact_no)','\(country_code)','\(attachment)','\(thumbnail)','\(dateString)','\(read_status)','\(msg_date)');"
             print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
        if currentMsgTime != nil {
            print("currentMsgTime \(String(describing: currentMsgTime))")
        if timeStr != "" {
            let lastMsgTime = formatter.date(from: timeStr)
            let currentDate = Utility.shared.timeStamp(time: currentMsgTime!, format: "MMMM dd yyyy")
            let lastDate = Utility.shared.timeStamp(time: lastMsgTime! , format: "MMMM dd yyyy")
            if currentDate != lastDate {
                self.addStickyDate( channel_id: channel_id, timestamp:time)
            }
        }else{
            self.addStickyDate( channel_id: channel_id, timestamp: time)
        }
        }else{
            print("currentMsgTime is NIL")
        }
    }
    
    
    //get unread count
    func getChannelUnreadCount(channel_id:String)->Int  {
        var count = Int()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT count(*) FROM CHANNEL_MESSAGE WHERE read_status = '0' AND channel_id = '\(channel_id)'"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    count = Int(sqlite3_column_int(stmt, 0));
                }
                sqlite3_finalize(stmt)
            }else{
                // print("Failed from sqlite3_prepare_v2. Error is:\(sqlite3_errmsg(db))" );
            }
            
            sqlite3_close(db)
        }
        // print("count \(count)")
        return count
    }
    
    //get last msg timestamp
    func channelLastMsg()->String  {
        var timeStamp = String()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT timestamp FROM CHANNEL_MESSAGE ORDER BY timestamp DESC LIMIT 1"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    timeStamp = String(cString: sqlite3_column_text(stmt, 0))
                }
                sqlite3_finalize(stmt)
            }else{
                // print("Failed from sqlite3_prepare_v2. Error is:\(sqlite3_errmsg(db))" );
            }
            sqlite3_close(db)
        }
        return timeStamp
    }
    func getChannelUnreadMSg(channel_id:String)->NSMutableArray  {
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE read_status = '0' AND channel_id = '\(channel_id)' AND admin_id != '\(UserModel.shared.userID()!)'"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    let  msgDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "message_type")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "timestamp")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "read_status")
                    
                    let decryptLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 6)), key: ENCRYPT_KEY)
                    let decryptLong = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 7)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptLat, forKey: "lat")
                    msgDict.setValue(decryptLong, forKey: "lon")
                    
                    let decryptContactName = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                    let decryptContactNo = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptContactName, forKey: "contact_name")
                    msgDict.setValue(decryptContactNo, forKey: "contact_no")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "country_code")
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "isDownload")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "local_path")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "date")
                    
                    //                    let  resultDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "channel_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "admin_id")
                    //                    resultDict.setValue(msgDict, forKey: "message_data")
                    //
                    //                    let msgDate = String(cString: sqlite3_column_text(stmt, 16))
                    resultArray.add(msgDict)
                    
                }
                sqlite3_finalize(stmt)
            }else{
                // print("Failed from sqlite3_prepare_v2. Error is:\(sqlite3_errmsg(db))" );
            }
            sqlite3_close(db)
        }
        // print("count \(count)")
        return resultArray
    }
    //get all count
    func channelOverAllUnreadMsg()->Int  {
        var count = Int()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT SUM(unread_count) AS Total FROM CHANNELS"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    count = Int(sqlite3_column_int(stmt, 0));
                }
                sqlite3_finalize(stmt)
            }else{
                // print("Failed from sqlite3_prepare_v2. Error is:\(sqlite3_errmsg(db))" );
            }
            sqlite3_close(db)
        }
        return count
    }
    func getChannelNewList(type:String) -> NSMutableArray  {
        let database = FMDatabase(url: URL.init(string: DBConfig().filePath()))
        let groupArray = NSMutableArray()
        guard database.open() else {
            // print("Unable to open database")
            return groupArray
        }
        do {
            var queryString = String()
            if type == "own" {
                queryString = "SELECT CHANNELS.channel_id,created_by,title,description,created_time,channel_icon,mute,CHANNELS.message_id,CHANNELS.timestamp,unread_count,admin_id,CHANNEL_MESSAGE.message_type,message,isDownload,subscriber_count,subscribtion_status,CHANNELS.channel_type,report FROM CHANNELS LEFT JOIN CHANNEL_MESSAGE ON CHANNELS.message_id = CHANNEL_MESSAGE.message_id WHERE created_by = '\(UserModel.shared.userID()!)' ORDER BY CHANNELS.timestamp DESC"
            }else{
                queryString = "SELECT CHANNELS.channel_id,created_by,title,description,created_time,channel_icon,mute,CHANNELS.message_id,CHANNELS.timestamp,unread_count,admin_id,CHANNEL_MESSAGE.message_type,message,isDownload,subscriber_count,subscribtion_status,CHANNELS.channel_type,report FROM CHANNELS LEFT JOIN CHANNEL_MESSAGE ON CHANNELS.message_id = CHANNEL_MESSAGE.message_id WHERE created_by != '\(UserModel.shared.userID()!)' AND CHANNELS.block_status !='1' ORDER BY CHANNELS.timestamp DESC"
            }
            let rs = try database.executeQuery(queryString, values: nil)
            
            while rs.next() {
                var group_icon = String()
                let  groupDict = NSMutableDictionary()
                groupDict.setValue(rs.string(forColumn: "channel_id"), forKey: "channel_id")
                groupDict.setValue(rs.string(forColumn: "created_by"), forKey: "created_by")
                groupDict.setValue(rs.string(forColumn: "title"), forKey: "channel_name")
                groupDict.setValue(rs.string(forColumn: "description"), forKey: "channel_des")
                groupDict.setValue(rs.string(forColumn: "created_time"), forKey: "created_time")
                groupDict.setValue(rs.string(forColumn: "mute"), forKey: "mute")
                groupDict.setValue(rs.string(forColumn: "report"), forKey: "report")
                
                groupDict.setValue(rs.string(forColumn: "subscriber_count"), forKey: "subscriber_count")
                groupDict.setValue(rs.string(forColumn: "subscribtion_status"), forKey: "subscribtion_status")
                groupDict.setValue(rs.string(forColumn: "channel_type"), forKey: "channel_type")
                
                if rs.string(forColumn: "message_id") != nil {
                    groupDict.setValue(rs.string(forColumn: "message_id"), forKey: "message_id")
                    groupDict.setValue(rs.string(forColumn: "message_type"), forKey: "message_type")
                    let cryptLib = CryptLib()
                    if rs.string(forColumn: "message") != nil {
                        let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: rs.string(forColumn: "message"), key: ENCRYPT_KEY)
                        groupDict.setValue(decryptedMsg, forKey: "message")
                    }
                    else {
                        groupDict.setValue("", forKey: "message")
                    }
                    
                    //                    groupDict.setValue(rs.string(forColumn: "message"), forKey: "message")
                    groupDict.setValue(rs.string(forColumn: "isDownload"), forKey: "isDownload")
                    groupDict.setValue(rs.string(forColumn: "admin_id"), forKey: "admin_id")
                }
                
                if rs.string(forColumn: "unread_count") != nil{
                    groupDict.setValue(rs.string(forColumn: "unread_count"), forKey: "unread_count")
                }else{
                    groupDict.setValue("0", forKey: "unread_count")
                }
                
                if rs.string(forColumn: "timestamp") != nil{
                    groupDict.setValue(rs.string(forColumn: "timestamp"), forKey: "timestamp")
                }else{
                    groupDict.setValue("", forKey: "timestamp")
                }
                if rs.string(forColumn: "channel_icon") != nil {
                    group_icon = rs.string(forColumn: "channel_icon")!
                }
                groupDict.setValue(group_icon, forKey: "channel_image")
                
                groupArray.add(groupDict)
                
            }
        } catch {
            // print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.getChannelID()
        return groupArray
    }
    
    //get channel list
    func getChannelList(type:String) -> NSMutableArray {
        let groupArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            if type == "own"{
                queryString = "SELECT CHANNELS.channel_id,created_by,title,description,created_time,channel_icon,mute,CHANNELS.message_id,CHANNELS.timestamp,unread_count,admin_id,message_type,message,isDownload,subscriber_count,subscribtion_status,CHANNELS.channel_type,report FROM CHANNELS LEFT JOIN CHANNEL_MESSAGE ON CHANNELS.message_id = CHANNEL_MESSAGE.message_id WHERE created_by = '\(UserModel.shared.userID()!)' ORDER BY CHANNELS.timestamp DESC"
            }else{
                queryString = "SELECT CHANNELS.channel_id,created_by,title,description,created_time,channel_icon,mute,CHANNELS.message_id,CHANNELS.timestamp,unread_count,admin_id,message_type,message,isDownload,subscriber_count,subscribtion_status,CHANNELS.channel_type,report FROM CHANNELS LEFT JOIN CHANNEL_MESSAGE ON CHANNELS.message_id = CHANNEL_MESSAGE.message_id WHERE created_by != '\(UserModel.shared.userID()!)' ORDER BY CHANNELS.timestamp DESC"
            }
            
            var stmt:OpaquePointer?
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    var group_icon = String()
                    let  groupDict = NSMutableDictionary()
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "channel_id")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "created_by")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "channel_name")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "channel_des")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "created_time")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "mute")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "report")
                    
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "subscriber_count")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "subscribtion_status")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "channel_type")
                    
                    if sqlite3_column_text(stmt, 11) != nil {
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "message_id")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "message_type")
                        let cryptLib = CryptLib()
                        let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                        groupDict.setValue(decryptedMsg, forKey: "message")
                        
                        //                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "message")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "isDownload")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "admin_id")
                    }
                    
                    if sqlite3_column_text(stmt, 9) != nil{
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "unread_count")
                    }else{
                        groupDict.setValue("0", forKey: "unread_count")
                    }
                    
                    if sqlite3_column_text(stmt, 8) != nil{
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "timestamp")
                    }else{
                        groupDict.setValue("", forKey: "timestamp")
                    }
                    if sqlite3_column_text(stmt, 5) != nil {
                        group_icon = String(cString: sqlite3_column_text(stmt, 5))
                    }
                    groupDict.setValue(group_icon, forKey: "channel_image")
                    
                    groupArray.add(groupDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        self.getChannelID()
        return groupArray
    }
    //get channel list
    func getSearchChannel(type:String) -> NSMutableArray {
        
        let channelArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            if UserModel.shared.userID() != nil {
                var queryString = String()
                if type == "forward"{
                    queryString = "SELECT CHANNELS.channel_id,created_by,title,description,created_time,channel_icon,mute,CHANNELS.message_id,CHANNELS.timestamp,unread_count,admin_id,message_type,message,isDownload,subscriber_count,subscribtion_status,report FROM CHANNELS LEFT JOIN CHANNEL_MESSAGE ON CHANNELS.message_id = CHANNEL_MESSAGE.message_id WHERE created_by = '\(UserModel.shared.userID()!)' ORDER BY CHANNELS.timestamp DESC"
                }else{
                    queryString = "SELECT CHANNELS.channel_id,created_by,title,description,created_time,channel_icon,mute,CHANNELS.message_id,CHANNELS.timestamp,unread_count,admin_id,message_type,message,isDownload,subscriber_count,subscribtion_status,report FROM CHANNELS LEFT JOIN CHANNEL_MESSAGE ON CHANNELS.message_id = CHANNEL_MESSAGE.message_id ORDER BY CHANNELS.timestamp DESC"
                }

                var stmt:OpaquePointer?
                if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                    while(sqlite3_step(stmt) == SQLITE_ROW){
                        var group_icon = String()
                        let  groupDict = NSMutableDictionary()
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "search_id")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "channel_id")

                        groupDict.setValue("channel", forKey: "search_type")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "search_name")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "created_by")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "channel_des")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "created_time")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "mute")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "subscriber_count")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "subscribtion_status")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "report")

                        if sqlite3_column_text(stmt, 5) != nil {
                            group_icon = String(cString: sqlite3_column_text(stmt, 5))
                        }
                        groupDict.setValue(group_icon, forKey: "search_image")
                        
                        channelArray.add(groupDict)
                    }
                    sqlite3_finalize(stmt)
                }
                sqlite3_close(db)
            }
        } 
        return channelArray
    }
    // UPDATE read status
    func channelReadStatus(channel_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE CHANNEL_MESSAGE SET read_status = '1' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    // UPDATE unread count
    func channelUpdateUnreadCount(channel_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE CHANNELS SET unread_count = '0' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    //get single msg
    func getChannelMsg(msg_id:String) -> channelMsgModel.message? {
        var groupMsg:channelMsgModel.message? = nil
        
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE message_id = '\(msg_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let cryptLib = CryptLib()
                    
                    
                    
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                                let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                                let decryptedno = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                                let decryptedname = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                                let decryptedlat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 6)), key: ENCRYPT_KEY)
                                let decryptedlon = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 7)), key: ENCRYPT_KEY)
                                let decryptedthumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)

                          groupMsg = channelMsgModel.message.init(message_id: String(cString: sqlite3_column_text(stmt, 0)),
                                                                             channel_id: String(cString: sqlite3_column_text(stmt, 1)),
                                                                             message_type: String(cString: sqlite3_column_text(stmt, 3)),
                                                                             message: decryptedMsg ?? "",
                                                                             timestamp: String(cString: sqlite3_column_text(stmt, 5)),
                                                                             lat: decryptedlat ?? "",
                                                                             lon: decryptedlon ?? "",
                                                                             contact_name: decryptedname ?? "",
                                                                             contact_no: decryptedno ?? "",
                                                                             country_code: String(cString: sqlite3_column_text(stmt, 10)),
                                                                             attachment: decryptedAttachment ?? "",
                                                                             thumbnail: decryptedthumbnail ?? "",
                                                                             isDownload: String(cString: sqlite3_column_text(stmt, 13)),
                                                                             local_path: String(cString: sqlite3_column_text(stmt, 15)),
                                                                             date: String(cString: sqlite3_column_text(stmt, 14)),
                                                                             admin_id: String(cString: sqlite3_column_text(stmt, 2)),
                                                                             translated_status: String(cString: sqlite3_column_text(stmt, 17)),
                                                                             translated_msg: String(cString: sqlite3_column_text(stmt, 18)), msg_date: String(cString: sqlite3_column_text(stmt, 19)))
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return groupMsg
    }
    
    
       func updateTranslated(msg_id: String,msg: String) {
                //creating a statement
                var stmt: OpaquePointer?
                //open db
                if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
                {
                    var queryString = String()
                    queryString = "UPDATE CHANNEL_MESSAGE SET translated_status = '1',translated_msg = '\(msg)' WHERE message_id = '\(msg_id)';"

                    // print("SQL QUERY : \(queryString)")
                    //preparing the query
                    if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                        _ =  String(cString: sqlite3_errmsg(db)!)
                        // print("error preparing insert: \(errmsg)")
                        return
                    }
                    //executing the query to insert values
                    if sqlite3_step(stmt) != SQLITE_DONE {
                        _ =  String(cString: sqlite3_errmsg(db)!)
                        // print("failure inserting hero: \(errmsg)")
                        return
                    }
                    //finalize query
                    if sqlite3_finalize(stmt) != SQLITE_OK {
                        _ =  String(cString: sqlite3_errmsg(db)!)
                        // print("error finalizing prepared statement: \(errmsg)")
                    }
                }
                //close db
                if sqlite3_close(db) != SQLITE_OK {
                    _ =  String(cString: sqlite3_errmsg(db)!)
                    // print("error closing database \(errmsg)")
                }
                db = nil
            }
       // UPDATE RECENT CHAT LIST
       func updateDefaultTranslation()  {
           //creating a statement
           var stmt: OpaquePointer?
           //open db
           if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
           {
               var queryString = String()
                   queryString = "UPDATE CHANNEL_MESSAGE SET translated_status = '0';"
               
               // print("SQL QUERY : \(queryString)")
               //preparing the query
               if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                   _ =  String(cString: sqlite3_errmsg(db)!)
                   // print("error preparing insert: \(errmsg)")
                   return
               }
               //executing the query to insert values
               if sqlite3_step(stmt) != SQLITE_DONE {
                   _ =  String(cString: sqlite3_errmsg(db)!)
                   // print("failure inserting hero: \(errmsg)")
                   return
               }
               //finalize query
               if sqlite3_finalize(stmt) != SQLITE_OK {
                   _ =  String(cString: sqlite3_errmsg(db)!)
                   // print("error finalizing prepared statement: \(errmsg)")
               }
           }
           //close db
           if sqlite3_close(db) != SQLITE_OK {
               _ =  String(cString: sqlite3_errmsg(db)!)
               // print("error closing database \(errmsg)")
           }
           db = nil
       }
    //get over all contact
    func getChannelForwardMsg(msg_id:String) -> NSMutableDictionary {
        let msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE message_id = '\(msg_id)'"
            
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "message_type")
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "chat_time")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "lat")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "lon")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "cName")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "cNo")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "country_code")
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    if sqlite3_column_text(stmt, 13) != nil{
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "isDownload")
                    }
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "local_path")
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return msgDict
    }
    //get last message
    func getLastMsgInfo(channel_id:String) -> NSDictionary {
        let  msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE channel_id = '\(channel_id)' ORDER BY timestamp DESC LIMIT 1"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    msgDict.setValue( String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "chat_time")
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return msgDict
    }
    
    //get over all channelmsg
    func getAllChannelMsg(channel_id:String,offset:String) -> NSMutableArray? {
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE channel_id = '\(channel_id)' ORDER BY timestamp DESC LIMIT 20 OFFSET '\(offset)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    let decryptedno = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                    let decryptedname = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                    let decryptedlat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 6)), key: ENCRYPT_KEY)
                    let decryptedlon = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 7)), key: ENCRYPT_KEY)
                    let decryptedthumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                    var msgDate =  String()
                    if sqlite3_column_text(stmt, 19) != nil{
                        msgDate = String(cString: sqlite3_column_text(stmt, 19))
                    }else{
                        msgDate = ""
                    }

                    resultArray.add(channelMsgModel.message.init(message_id: String(cString: sqlite3_column_text(stmt, 0)),
                                                                 channel_id: String(cString: sqlite3_column_text(stmt, 1)),
                                                                 message_type: String(cString: sqlite3_column_text(stmt, 3)),
                                                                 message: decryptedMsg ?? "",
                                                                 timestamp: String(cString: sqlite3_column_text(stmt, 5)),
                                                                 lat: decryptedlat ?? "",
                                                                 lon: decryptedlon ?? "",
                                                                 contact_name: decryptedname ?? "",
                                                                 contact_no: decryptedno ?? "",
                                                                 country_code: String(cString: sqlite3_column_text(stmt, 10)),
                                                                 attachment: decryptedAttachment ?? "",
                                                                 thumbnail: decryptedthumbnail ?? "",
                                                                 isDownload: String(cString: sqlite3_column_text(stmt, 13)),
                                                                 local_path: String(cString: sqlite3_column_text(stmt, 15)),
                                                                 date: String(cString: sqlite3_column_text(stmt, 14)),
                                                                 admin_id: String(cString: sqlite3_column_text(stmt, 2)),
                                                                 translated_status: String(cString: sqlite3_column_text(stmt, 17)),
                                                                 translated_msg: String(cString: sqlite3_column_text(stmt, 18)),msg_date:msgDate))
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let reveresdArray:NSMutableArray? = NSMutableArray.init(array: resultArray.reverseObjectEnumerator().allObjects)
        
        return reveresdArray
    }
    //get over all channel Media Msg
    func getAllChannelMediaMsg(channel_id:String, message_type:String) -> NSMutableArray {
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHANNEL_MESSAGE WHERE channel_id = '\(channel_id)' AND message_type IN (\(message_type)) AND (admin_id == '\(UserModel.shared.userID()! as String)' OR isDownload == 1) ORDER BY timestamp ASC"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let cryptLib = CryptLib()
                                       let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                                       let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                                       let decryptedno = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                                       let decryptedname = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                                       let decryptedlat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 6)), key: ENCRYPT_KEY)
                                       let decryptedlon = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 7)), key: ENCRYPT_KEY)
                                       let decryptedthumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)

                                       resultArray.add(channelMsgModel.message.init(message_id: String(cString: sqlite3_column_text(stmt, 0)),
                                                                                    channel_id: String(cString: sqlite3_column_text(stmt, 1)),
                                                                                    message_type: String(cString: sqlite3_column_text(stmt, 3)),
                                                                                    message: decryptedMsg ?? "",
                                                                                    timestamp: String(cString: sqlite3_column_text(stmt, 5)),
                                                                                    lat: decryptedlat ?? "",
                                                                                    lon: decryptedlon ?? "",
                                                                                    contact_name: decryptedname ?? "",
                                                                                    contact_no: decryptedno ?? "",
                                                                                    country_code: String(cString: sqlite3_column_text(stmt, 10)),
                                                                                    attachment: decryptedAttachment ?? "",
                                                                                    thumbnail: decryptedthumbnail ?? "",
                                                                                    isDownload: String(cString: sqlite3_column_text(stmt, 13)),
                                                                                    local_path: String(cString: sqlite3_column_text(stmt, 15)),
                                                                                    date: String(cString: sqlite3_column_text(stmt, 14)),
                                                                                    admin_id: String(cString: sqlite3_column_text(stmt, 2)),
                                                                                    translated_status: String(cString: sqlite3_column_text(stmt, 17)),
                                                                                    translated_msg: String(cString: sqlite3_column_text(stmt, 18)),msg_date: String(cString: sqlite3_column_text(stmt, 19))))
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let reveresdArray:NSMutableArray = NSMutableArray.init(array: resultArray.reverseObjectEnumerator().allObjects)
        
        return reveresdArray
    }
    
    
    // UPDATE CHANNEL MUTE
    func channelMute(channel_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNELS SET mute = '\(status)' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
    }
    // UPDATE CHANNEL Report
    func channelReport(channel_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNELS SET report = '\(status)' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    // delete group msg
    func deleteChannelSingleMsg(msg_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM CHANNEL_MESSAGE WHERE message_id IN (\(msg_id));"
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // Block channel message
    func blockChannelMsg(channel_id:String, blockStatus: String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE CHANNELS SET block_status = '\(blockStatus)' WHERE channel_id = '\(channel_id)';"
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // delete group msg
    func deleteChannelMsg(channel_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM CHANNEL_MESSAGE WHERE channel_id = '\(channel_id)';"
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // delete  channel
    func deleteChannel(channel_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM CHANNELS WHERE channel_id = '\(channel_id)';"
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        
        db = nil
        self.getChannelID()
    }
    
    // UPDATE CHANNEL ICON
    func updateChannelTime(channel_id:String,timestamp:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNELS SET timestamp = '\(timestamp)' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    // UPDATE CHANNEL ICON
    func updateChannelIcon(channel_id:String,channel_icon:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNELS SET channel_icon = '\(channel_icon)' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // UPDATE CHANNEL NAME DES
    func updateChannelName(channel_id:String,name:String,des:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE CHANNELS SET (title,description) = ('\(name)','\(des)') WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // UPDATE admin NAME DES
    func updateAdminName(channel_id:String,name:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE CHANNELS SET admin_name = '\(name)' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // UPDATE SUBSCRIBER
    func updateSubscribtion(channel_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNELS SET subscribtion_status = '\(status)' WHERE channel_id = '\(channel_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
        socketClass.sharedInstance.goLive()
    }
    func updateAllChannelMediaDownload()  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNEL_MESSAGE SET isDownload = '4' WHERE message_id = '2';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // UPDATE DOWNLOAD
    func updateChannelMediaDownload(msg_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNEL_MESSAGE SET isDownload = '\(status)' WHERE message_id = '\(msg_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    // UPDATE Message Type
    func updateChannelMessage(msg_id:String,msg_type:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNEL_MESSAGE SET message_type = '\(msg_type)' WHERE message_id = '\(msg_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    // UPDATE DOWNLOAD
    func updateChannelMediaLocalURL(msg_id:String,url:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNEL_MESSAGE SET local_path = '\(url)' WHERE message_id = '\(msg_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    // UPDATE channel video url
    func updateChannelVideoURL(msg_id:String,attachment:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHANNEL_MESSAGE SET attachment = '\(attachment)' WHERE message_id = '\(msg_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
}

