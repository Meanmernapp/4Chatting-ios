//
//  GroupStorage.swift
//  Hiddy
//
//  Created by APPLE on 12/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
import SQLite3
class groupStorage: NSObject {
    let localObj = LocalStorage()
    static let sharedInstance = groupStorage()
    
    func createGroup()  {
        //GROUP TABLE
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS ALLGROUP (group_id VARCHAR(40) PRIMARY KEY,created_by TEXT,group_name TEXT,created_at TEXT,group_icon TEXT,mute TEXT DEFAULT '0',exit TEXT DEFAULT '0',message_id TEXT,timestamp TEXT,typing TEXT DEFAULT '0',unread_count TEXT)", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS GROUP_MEMBER (member_key VARCHAR(40) PRIMARY KEY, group_id VARCHAR(40),member_id TEXT,member_role TEXT)", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS GROUP_CHATS (message_id VARCHAR(80) PRIMARY KEY, group_id TEXT,member_id TEXT, message_type TEXT,message TEXT, timestamp TEXT,lat TEXT,lon TEXT,contact_name TEXT,contact_no TEXT, country_code TEXT, attachment TEXT, thumbnail TEXT,isDownload TEXT DEFAULT '0',date TEXT,local_path TEXT DEFAULT '0',admin_id TEXT DEFAULT '0',read_status TEXT,translated_status TEXT DEFAULT '0',translated_msg TEXT DEFAULT '')", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
    }
    
    //update group details
    func updateGroupDetails(group_id:String,mute:String,exit:String,message_id:String,timestamp:String,unread_count:String)  {
        
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "UPDATE ALLGROUP SET (mute,exit,message_id,timestamp,unread_count) = ('\(mute)','\(exit)','\(message_id)','\(timestamp)','\(unread_count)') WHERE group_id = '\(group_id)';"
            
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
    
    //get unread count
    func checkAdded(group_id:String)->Bool  {
        var available:Bool = false
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM GROUP_CHATS WHERE message_type = 'user_added' AND group_id = '\(group_id)'"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    print("checknewadd record available")
                    available = true
                }
                sqlite3_finalize(stmt)
            }else{
                print("checknewadd record not available")
                // print("Failed from sqlite3_prepare_v2. Error is:\(sqlite3_errmsg(db))" );
            }
            sqlite3_close(db)
        }
        return available
    }
    /*
    func addNewGroup(group_id:String,group_name:String,createAt:String,createdBy:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO ALLGROUP (group_id,created_by,group_name,created_at) VALUES ('\(group_id)','\(createdBy)','\(group_name)','\(createAt)');"
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
        self.getgroupID()
        
    }
    */
    func addNewGroup(group_id:String,group_name:String,createAt:String,createdBy:String,group_icon:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO ALLGROUP (group_id,created_by,group_name,created_at,group_icon) VALUES ('\(group_id)','\(createdBy)','\(group_name)','\(createAt)','\(group_icon)');"
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
        self.getgroupID()
        
    }
    //get over all group
    func getgroupID()  {
        let idArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT group_id FROM ALLGROUP"
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
        UserModel.shared.setGroupIDs(IDs: idArray)
    }
    
    //get over all group
    func getActiveGroups()  {
        let idArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT group_id FROM ALLGROUP WHERE exit = '0'"
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
        UserModel.shared.setActiveGroup(IDs: idArray)
    }
    // UPDATE GROUP ICON
    func updateGroupIcon(group_id:String,group_icon:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE ALLGROUP SET group_icon = '\(group_icon)' WHERE group_id = '\(group_id)';"
            
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
    
    // UPDATE GROUP NAME
    func updateGroupName(group_id:String,group_name:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE ALLGROUP SET group_name = '\(group_name)' WHERE group_id = '\(group_id)';"
            
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
            //close db
            if sqlite3_close(db) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error closing database \(errmsg)")
            }
        }
        
        db = nil
    }
    
    // add group members
    func addGroupMembers(group_id:String,member_id:String,member_role:String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let member_key:String = "\(group_id)\(member_id)"
            let queryString = "INSERT OR REPLACE INTO GROUP_MEMBER (member_key,group_id,member_id,member_role) VALUES ('\(member_key)','\(group_id)','\(member_id)','\(member_role)');"
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
            
            //close db
            if sqlite3_close(db) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                // print("error closing database \(errmsg)")
            }
        }
        
        db = nil
    }
    func addStickyDate(group_id:String,timestamp:String)  {
        let msg_id = Utility.shared.random()
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {

            let queryString = "INSERT OR REPLACE INTO GROUP_CHATS (message_id,group_id,member_id,message_type,message,timestamp,lat,lon,contact_name,contact_no,country_code,attachment,thumbnail,date,admin_id,read_status) VALUES ('\(msg_id)','\(group_id)','','date_sticky','','\(timestamp)','','','','','','','','\(timestamp)','','');"
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
    
    // ADD RECENT CHAT LIST
       func addGroupChat(msg_id:String,group_id:String,member_id:String,msg_type:String,msg:String,time:String,lat:String,lon:String,contact_name:String,contact_no:String,country_code:String,attachment:String,thumbnail:String,admin_id:String,read_status:String) {
        let timeStr = self.getLastMsgTime(group_id: group_id)
        
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
              
               let queryString = "INSERT OR REPLACE INTO GROUP_CHATS (message_id,group_id,member_id,message_type,message,timestamp,lat,lon,contact_name,contact_no,country_code,attachment,thumbnail,date,admin_id,read_status) VALUES ('\(msg_id)','\(group_id)','\(member_id)','\(msg_type)','\(msg)','\(time)','\(lat)','\(lon)','\(contact_name)','\(contact_no)','\(country_code)','\(attachment)','\(thumbnail)','\(dateString)','\(admin_id)','\(read_status)');"
                print("SQL QUERY : \(queryString)")
               //preparing the query
               if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
               }
               //executing the query to insert values
               if sqlite3_step(stmt) != SQLITE_DONE {
                   let errmsg =  String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting hero: \(errmsg)")
               }
               //finalize query
               if sqlite3_finalize(stmt) != SQLITE_OK {
                   _ =  String(cString: sqlite3_errmsg(db)!)
                   // print("error finalizing prepared statement: \(errmsg)")
               }
           }
           //close db
           if sqlite3_close(db) != SQLITE_OK {
               let errmsg =  String(cString: sqlite3_errmsg(db)!)
                print("error closing database \(errmsg)")
           }
           db = nil
        

        if currentMsgTime != nil {
            print("currentMsgTime \(String(describing: currentMsgTime))")

        if timeStr != "" {
            let lastMsgTime = formatter.date(from: timeStr)
            let currentDate = Utility.shared.timeStamp(time: currentMsgTime!, format: "MMMM dd yyyy")
            let lastDate = Utility.shared.timeStamp(time: lastMsgTime! , format: "MMMM dd yyyy")        
            if currentDate != lastDate {
                /*
                self.addStickyDate( group_id: group_id, timestamp: time)
                */
                let date = Utility.shared.getCurrentDate(time)
                self.addStickyDate( group_id: group_id, timestamp: date)
            }
        }else{
            /*
            self.addStickyDate( group_id: group_id, timestamp: time)
            */
            let date = Utility.shared.getCurrentDate(time)
            self.addStickyDate( group_id: group_id, timestamp: date)
        }
        }else{
            print("currentMsgTime is NIL")
        }

       }
    
  
    //get unread count
    func checkGroupMember(group_id:String)->Bool  {
        var available:Bool = false
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM GROUP_MEMBER WHERE member_role = '1' AND group_id = '\(group_id)'"
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
    //get unread count
    func getGroupUnreadCount(group_id:String)->Int  {
        var count = Int()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT count(*) FROM GROUP_CHATS WHERE read_status = '0' AND group_id = '\(group_id)' AND member_id != '\(UserModel.shared.userID()!)'"
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
    func getGroupUnreadMessage(group_id:String)->NSMutableArray  {
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM GROUP_CHATS WHERE read_status = '0' AND group_id = '\(group_id)' AND member_id != '\(UserModel.shared.userID()!)'"
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
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 17)), forKey: "read_status")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "lat")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "lon")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "contact_name")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "contact_no")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "country_code")
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "isDownload")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "local_path")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "date")
                    
                    //                    let  resultDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "group_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "member_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "admin_id")
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
    func groupOverAllUnreadMsg()->Int  {
        var count = Int()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT SUM(unread_count) AS Total FROM ALLGROUP"
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
    func groupChatReceived() {
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID()!, forKey: "user_id")
        socket.defaultSocket.emit("groupchatreceived", requestDict)
    }
    func updateTranslated(msg_id: String,msg: String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_CHATS SET translated_status = '1',translated_msg = '\(msg)' WHERE message_id = '\(msg_id)';"
            
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
            queryString = "UPDATE GROUP_CHATS SET translated_status = '0';"
            
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
    func getGroupChat(group_id:String,offset:String) -> NSMutableArray? {
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM GROUP_CHATS WHERE group_id = '\(group_id)' ORDER BY timestamp DESC LIMIT 20 OFFSET '\(offset)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    let decryptedLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 6)), key: ENCRYPT_KEY)
                    let decryptedLon = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 7)), key: ENCRYPT_KEY)
                    let decryptedcontactname = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,  8)), key: ENCRYPT_KEY)
                    let decryptedcontactno = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,  9)), key: ENCRYPT_KEY)
                    let decryptedcountrycode = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,10)), key: ENCRYPT_KEY)
                    
                    let decryptedthumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                    
                    resultArray.add(groupMsgModel.message.init(message_id: String(cString: sqlite3_column_text(stmt, 0)),
                                                               group_id: String(cString: sqlite3_column_text(stmt, 1)),
                                                               member_id: String(cString: sqlite3_column_text(stmt, 2)),
                                                               message_type: String(cString: sqlite3_column_text(stmt, 3)),
                                                               message: decryptedMsg ?? "",
                                                               timestamp: String(cString: sqlite3_column_text(stmt, 5)),
                                                               lat: decryptedLat ?? "",
                                                               lon: decryptedLon ?? "",
                                                               contact_name: decryptedcontactname ?? "",
                                                               contact_no: decryptedcontactno ?? "",
                                                               country_code: decryptedcountrycode ?? "",
                                                               attachment: decryptedAttachment ?? "",
                                                               thumbnail: decryptedthumbnail ?? "",
                                                               isDownload: String(cString: sqlite3_column_text(stmt, 13)),
                                                               local_path: String(cString: sqlite3_column_text(stmt, 15)),
                                                               date: String(cString: sqlite3_column_text(stmt, 14)),
                                                               admin_id: String(cString: sqlite3_column_text(stmt, 16)),
                                                               translated_status: String(cString: sqlite3_column_text(stmt, 18)),
                                                               translated_msg: String(cString: sqlite3_column_text(stmt, 19))))
                    
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let reveresdArray:NSMutableArray? = NSMutableArray.init(array: resultArray.reverseObjectEnumerator().allObjects)
        
        return reveresdArray
    }
    
    // delete group msg
    func deleteGroupSingleMsg(msg_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM GROUP_CHATS WHERE message_id IN (\(msg_id));"
            print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                _ =  String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            print("error closing database ")
        }
        db = nil
    }
    
    // delete group msg
    func deleteGroupMsg(group_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM GROUP_CHATS WHERE group_id = '\(group_id)';"
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
    // delete  group
    func deleteGroup(group_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM ALLGROUP WHERE group_id = '\(group_id)';"
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
    //get last message
    func getLastMsgTime(group_id:String) -> String {
        var  timeStr = ""
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM GROUP_CHATS WHERE group_id = '\(group_id)' ORDER BY timestamp DESC LIMIT 1"
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
    //get last message
    func getLastMsgInfo(group_id:String) -> NSDictionary {
        let  msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM GROUP_CHATS WHERE group_id = '\(group_id)' ORDER BY timestamp DESC LIMIT 1"
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
    //get single msg
    func getGroupMsg(msg_id:String) -> groupMsgModel.message? {
        var groupMsg:groupMsgModel.message? = nil
        
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM GROUP_CHATS WHERE message_id = '\(msg_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let cryptLib = CryptLib()
                    
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    let decryptedLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 6)), key: ENCRYPT_KEY)
                    let decryptedLon = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 7)), key: ENCRYPT_KEY)
                    let decryptedcontactname = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,  8)), key: ENCRYPT_KEY)
                    let decryptedcontactno = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,  9)), key: ENCRYPT_KEY)
                    let decryptedcountrycode = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,10)), key: ENCRYPT_KEY)
                    
                    let decryptedthumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                    
                    groupMsg = groupMsgModel.message.init(message_id: String(cString: sqlite3_column_text(stmt, 0)),
                                                          group_id: String(cString: sqlite3_column_text(stmt, 1)),
                                                          member_id: String(cString: sqlite3_column_text(stmt, 2)),
                                                          message_type: String(cString: sqlite3_column_text(stmt, 3)),
                                                          message: decryptedMsg ?? "",
                                                          timestamp: String(cString: sqlite3_column_text(stmt, 5)),
                                                          lat: decryptedLat ?? "",
                                                          lon: decryptedLon ?? "",
                                                          contact_name: decryptedcontactname ?? "",
                                                          contact_no: decryptedcontactno ?? "",
                                                          country_code: decryptedcountrycode ?? "",
                                                          attachment: decryptedAttachment ?? "",
                                                          thumbnail: decryptedthumbnail ?? "",
                                                          isDownload: String(cString: sqlite3_column_text(stmt, 13)),
                                                          local_path: String(cString: sqlite3_column_text(stmt, 15)),
                                                          date: String(cString: sqlite3_column_text(stmt, 14)),
                                                          admin_id: String(cString: sqlite3_column_text(stmt, 16)),
                                                          translated_status: String(cString: sqlite3_column_text(stmt, 18)),
                                                          translated_msg: String(cString: sqlite3_column_text(stmt, 19)))                    
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return groupMsg
    }
    
    //get over all contact
    func getGroupForwardMsg(msg_id:String) -> NSMutableDictionary {
        let msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            let queryString = "SELECT * FROM GROUP_CHATS WHERE message_id = '\(msg_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "message_type")
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    
                    //                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "message")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "chat_time")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "lat")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "lon")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "cName")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "cNo")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "country_code")
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
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
    //get group list
    func getGroupList() -> NSMutableArray {
        let groupArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT ALLGROUP.group_id,created_by,group_name,created_at,group_icon,mute,exit,ALLGROUP.message_id,ALLGROUP.timestamp,typing,unread_count,member_id,message_type,message,isDownload,admin_id,attachment FROM ALLGROUP LEFT JOIN GROUP_CHATS ON ALLGROUP.message_id = GROUP_CHATS.message_id ORDER BY ALLGROUP.timestamp DESC"
            
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                
                
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    var group_icon = String()
                    let  groupDict = NSMutableDictionary()
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "group_id")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "created_by")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "group_name")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "created_at")
                    
                    if sqlite3_column_text(stmt, 10) != nil{
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "unread_count")
                    }else{
                        groupDict.setValue("0", forKey: "unread_count")
                    }
                    if sqlite3_column_text(stmt, 9) != nil{
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "typing")
                    }else{
                        groupDict.setValue("0", forKey: "typing")
                    }
                    
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "mute")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "exit")
                    if sqlite3_column_text(stmt, 8) != nil{
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "timestamp")
                    }else{
                        groupDict.setValue("", forKey: "timestamp")
                    }
                    
                    if sqlite3_column_text(stmt, 4) != nil {
                        group_icon = String(cString: sqlite3_column_text(stmt, 4))
                    }
                    groupDict.setValue(group_icon, forKey: "group_icon")
                    if sqlite3_column_text(stmt, 12) != nil {
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "message_id")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "member_id")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "message_type")
                        print("sgggg \(String(cString: sqlite3_column_text(stmt, 13)))")
                        let cryptLib = CryptLib()
                        let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 13)), key: ENCRYPT_KEY)
                        groupDict.setValue(decryptedMsg, forKey: "message")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "isDownload")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "admin_id")
                        groupDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "attachment")
                    }
                    groupArray.add(groupDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        self.getgroupID()
        return groupArray
    }
    
    // UPDATE CHATS TABLE
    func readStatus(group_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE GROUP_CHATS SET read_status = '1' WHERE group_id = '\(group_id)' AND read_status = '0';"
            
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
    
    
    // UPDATE CHATS TABLE
    func readMsgStatus(id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_CHATS SET read_status = '4' WHERE message_id = '\(id)';"
            
            
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
    
    // UPDATE CHATS TABLE
    func updateUnreadCount(group_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE ALLGROUP SET unread_count = '0' WHERE group_id = '\(group_id)';"
            
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
    // update Recent Msg
    func updateRecentMsg(group_id:String, msgID:String,timestamp: String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE ALLGROUP SET message_id = '\(msgID)',timestamp = '\(timestamp)' WHERE group_id = '\(group_id)';"
            
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
    
    func getSearchGroupList() -> NSMutableArray {
        let groupArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM ALLGROUP WHERE exit = '0' ORDER BY created_at DESC"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    print("exit status \(String(cString: sqlite3_column_text(stmt, 6)))")
                    let group_id = String(cString: sqlite3_column_text(stmt, 0))
                    let created_by = String(cString: sqlite3_column_text(stmt, 1))
                    let group_name = String(cString: sqlite3_column_text(stmt, 2))
                    let created_at = String(cString: sqlite3_column_text(stmt, 3))
                    var group_icon = String()
                    if sqlite3_column_text(stmt, 4) != nil {
                        group_icon = String(cString: sqlite3_column_text(stmt, 4))
                    }
                    let mute = String(cString: sqlite3_column_text(stmt, 5))
                    
                    let  groupDict = NSMutableDictionary()
                    groupDict.setValue(group_id, forKey: "group_id")
                    groupDict.setValue(group_id, forKey: "search_id")
                    groupDict.setValue(created_by, forKey: "created_by")
                    groupDict.setValue(group_name, forKey: "search_name")
                    groupDict.setValue("group", forKey: "search_type")
                    groupDict.setValue(created_at, forKey: "created_at")
                    groupDict.setValue(group_icon, forKey: "search_image")
                    groupDict.setValue(mute, forKey: "mute")
                    groupArray.add(groupDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return groupArray
    }
    
    //get group infor
    func getGroupInfo(group_id:String) -> NSMutableDictionary {
        let  msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM ALLGROUP WHERE group_id = '\(group_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "group_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "created_by")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "group_name")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "created_at")
                    if sqlite3_column_text(stmt, 4) != nil{
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "group_icon")
                    }else{
                        msgDict.setValue(EMPTY_STRING, forKey: "group_icon")
                    }
                    if sqlite3_column_text(stmt, 5) != nil{
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "mute")
                    }else{
                        msgDict.setValue("0", forKey: "mute")
                    }
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "exit")
                    if sqlite3_column_text(stmt, 7) != nil{
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "message_id")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "timestamp")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "unread_count")
                    }
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return msgDict
    }
    
    //get group MediaInfo
    func getGroupMediaInfo(group_id:String, message_type:String) -> NSMutableArray {
        let  msgDict = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM GROUP_CHATS WHERE group_id = '\(group_id)'AND message_type IN (\(message_type)) AND (member_id == '\(UserModel.shared.userID()! as String)' OR isDownload == 1) ORDER BY timestamp ASC"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let cryptLib = CryptLib()
                    
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    let decryptedLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 6)), key: ENCRYPT_KEY)
                    let decryptedLon = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 7)), key: ENCRYPT_KEY)
                    let decryptedcontactname = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,  8)), key: ENCRYPT_KEY)
                    let decryptedcontactno = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,  9)), key: ENCRYPT_KEY)
                    let decryptedcountrycode = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt,10)), key: ENCRYPT_KEY)
                    
                    let decryptedthumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 12)), key: ENCRYPT_KEY)
                    
                    msgDict.add(groupMsgModel.message.init(message_id: String(cString: sqlite3_column_text(stmt, 0)),
                                                           group_id: String(cString: sqlite3_column_text(stmt, 1)),
                                                           member_id: String(cString: sqlite3_column_text(stmt, 2)),
                                                           message_type: String(cString: sqlite3_column_text(stmt, 3)),
                                                           message: decryptedMsg ?? "",
                                                           timestamp: String(cString: sqlite3_column_text(stmt, 5)),
                                                           lat: decryptedLat ?? "",
                                                           lon: decryptedLon ?? "",
                                                           contact_name: decryptedcontactname ?? "",
                                                           contact_no: decryptedcontactno ?? "",
                                                           country_code: decryptedcountrycode ?? "",
                                                           attachment: decryptedAttachment ?? "",
                                                           thumbnail: decryptedthumbnail ?? "",
                                                           isDownload: String(cString: sqlite3_column_text(stmt, 13)),
                                                           local_path: String(cString: sqlite3_column_text(stmt, 15)),
                                                           date: String(cString: sqlite3_column_text(stmt, 14)),
                                                           admin_id: String(cString: sqlite3_column_text(stmt, 16)),
                                                           translated_status: String(cString: sqlite3_column_text(stmt, 18)),
                                                           translated_msg: String(cString: sqlite3_column_text(stmt, 19))))
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        let reveresdArray:NSMutableArray = NSMutableArray.init(array: msgDict.reverseObjectEnumerator().allObjects)
        
        return reveresdArray
    }
    //get member infor
    func getMemberInfo(member_key:String) -> NSMutableDictionary {
        let  msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT member_id,member_role,contactName,userName,phoneNumber,userImage,blockedMe,blockedByMe,aboutUs FROM GROUP_MEMBER INNER JOIN USERS ON GROUP_MEMBER.member_id = USERS.userID WHERE member_key = '\(member_key)'"
            print("meember infor \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "member_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "member_role")
                    print("data come or not \(String(describing: sqlite3_column_text(stmt, 2)))")
                    if sqlite3_column_text(stmt, 2) != nil {
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "contact_name")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "member_name")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "member_no")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "member_image")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "blocked_me")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "blocked_by_me")
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "member_about")
                    }
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return msgDict
    }
    //get group member list
    func getGroupMembers(group_id:String) -> NSMutableArray {
        let groupArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT member_id,member_role,contactName,userName,phoneNumber,userImage,blockedMe,blockedByMe,aboutUs,mutual_status,privacy_lastseen,privacy_about,privacy_image FROM GROUP_MEMBER INNER JOIN USERS ON GROUP_MEMBER.member_id = USERS.userID WHERE group_id = '\(group_id)'"
            
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let groupDict = NSMutableDictionary()
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "member_id")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "member_role")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "contact_name")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "member_name")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "member_no")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "member_image")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "blocked_me")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "blocked_by_me")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "member_about")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "mutual_status")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "privacy_lastseen")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "privacy_about")
                    groupDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "privacy_image")
                    
                    groupArray.add(groupDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return groupArray
    }
    
    // UPDATE GROUP MUTE
    func groupMute(group_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE ALLGROUP SET mute = '\(status)' WHERE group_id = '\(group_id)';"
            
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
    
    // MAKE ADMIN
    func makeAdmin(member_key:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_MEMBER SET member_role = '\(status)' WHERE member_key = '\(member_key)';"
            
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
    
    // remove member from group
    func deleteAllMember(group_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "DELETE FROM GROUP_MEMBER WHERE group_id = '\(group_id)';"
            
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
        db = nil

    }
    
    // remove member from group
    func removeMember(member_key:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "DELETE FROM GROUP_MEMBER WHERE member_key = '\(member_key)';"
            
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
    
    // UPDATE GROUP EXIT
    func groupExit(group_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE ALLGROUP SET exit = '1' WHERE group_id = '\(group_id)';"
            
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
    // UPDATE GROUP EXIT
    func groupRemoveExit(group_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE ALLGROUP SET exit = '0' WHERE group_id = '\(group_id)';"
            
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
    func updateAllGroupMediaDownload()  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_CHATS SET isDownload = '4' WHERE isDownload = '2';"
            
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
    func updateGroupMediaDownload(msg_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_CHATS SET isDownload = '\(status)' WHERE message_id = '\(msg_id)';"
            
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
    // UPDATE group Message
    func updateGroupMessage(msg_id:String,msg_type:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_CHATS SET message_type = '\(msg_type)' WHERE message_id = '\(msg_id)';"
            
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
    // UPDATE group video
    func updateGroupVideoURL(msg_id:String,attachment:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_CHATS SET attachment = '\(attachment)' WHERE message_id = '\(msg_id)';"
            
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
    
    // UPDATE media url
    func updateGroupMediaLocalURL(msg_id:String,url:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE GROUP_CHATS SET local_path = '\(url)' WHERE message_id = '\(msg_id)';"
            
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
    
    
    // UPDATE GROUP TYPING
    func updateGroupTyping(group_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE ALLGROUP SET typing = '\(status)' WHERE group_id = '\(group_id)';"
            
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

