//
//  LocalStorage.swift
//  Hiddy
//
//  Created by APPLE on 12/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import SQLite3
import FMDB
import TrueTime

//var db: OpaquePointer?
//
let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "").Notification")?.appendingPathComponent("Hiddy.sqlite")

var database = FMDatabase(url:fileURL)

class LocalStorage{
    var dateArray = NSMutableArray()
    static let sharedInstance = LocalStorage()
    
    // create db
    func createDB()  {
        //opening the database
        if sqlite3_open(DBConfig().filePath(), &db) != SQLITE_OK {
            // print("error opening database")
        }
    }
    func openDatabase() -> Bool {
        if database.open() {
            return true
        }
        return false
    }
    //create all tables
    func createTable()  {
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS USERS (userID VARCHAR(40) PRIMARY KEY,contactName TEXT,userName TEXT,phoneNumber TEXT, userImage TEXT,aboutUs TEXT,blockedMe TEXT DEFAULT '0',blockedByMe TEXT DEFAULT '0',mute TEXT DEFAULT '0',mutual_status TEXT,privacy_lastseen TEXT,privacy_about TEXT,privacy_image TEXT,favourite TEXT DEFAULT '0', countryCode TEXT,isDelete TEXT DEFAULT '0')", nil, nil, nil) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS RECENT (contact_id VARCHAR(40) PRIMARY KEY,chat_id TEXT, message_id TEXT,unread_count TEXT,typing TEXT DEFAULT '0',timestamp TEXT)", nil, nil, nil) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS CHATS (message_id VARCHAR(80) PRIMARY KEY, chat_id TEXT,sender_id TEXT,receiver_id TEXT, message_type TEXT,message TEXT, timestamp TEXT,read_status TEXT,lat TEXT,lon TEXT,contact_name TEXT,contact_no TEXT, country_code TEXT, attachment TEXT, thumbnail TEXT,isDownload TEXT DEFAULT '0',date TEXT,local_path TEXT DEFAULT '0', status_data TEXT,translated_status TEXT DEFAULT '0', translated_msg TEXT DEFAULT '', blocked TEXT DEFAULT '0')", nil, nil, nil) != SQLITE_OK {
            _ = String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
        
        let groupObj =  groupStorage()
        groupObj.createGroup()
        let callObj =  CallStorage()
        callObj.createCallTable()
        let channelObj =  ChannelStorage()
        channelObj.createChannel()
        let storyObj =  storyStorage()
        storyObj.createStory()
        
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            
        }
    }
    
    // ADD PHONE CONTACT
    func addContact(userid:String,contactName:String,userName:String,phone:String,img:String,about:String?,type:String,mutual:String,privacy_lastseen:String,privacy_about:String,privacy_picture:String, countryCode: String)  {
        //creating a statement
        var stmt: OpaquePointer?
        let userDict:NSDictionary = self.getContact(contact_id: userid)
        var blockedMe = String()
        var blockedByMe = String()
        var mute = String()
        var fav = String()
        var abt = String()
        var isDelete = String()

        if userDict.value(forKey: "blockedMe") == nil {
            blockedMe  = "0"
        }else{
            blockedMe  = userDict.value(forKey: "blockedMe") as! String
        }
        if about == nil {
            abt  = ""
        }else{
            abt = about!
        }
        
        if userDict.value(forKey: "blockedByMe") == nil {
            blockedByMe  = "0"
        }else{
            blockedByMe  = userDict.value(forKey: "blockedByMe") as! String
        }
        if userDict.value(forKey: "mute") == nil {
            mute  = "0"
        }else{
            mute  = userDict.value(forKey: "mute") as! String
        }
        
        if userDict.value(forKey: "favourite") == nil {
            fav  = "0"
        }else{
            fav  = userDict.value(forKey: "favourite") as! String
        }
        if userDict.value(forKey: "isDelete") == nil {
            isDelete  = "0"
        }else{
            isDelete  = userDict.value(forKey: "isDelete") as! String
        }
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO USERS (userID, contactName,userName,phoneNumber,userImage,aboutUs,blockedMe,blockedByMe,mute,mutual_status,privacy_lastseen,privacy_about,privacy_image,favourite,countryCode,isDelete) VALUES ('\(userid)','\(contactName)','\(userName)','\(phone)','\(img)','\(abt)','\(blockedMe)','\(blockedByMe)','\(mute)','\(mutual)','\(privacy_lastseen)','\(privacy_about)','\(privacy_picture)','\(fav)','\(countryCode)','\(isDelete)');"
            print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ = String(cString: sqlite3_errmsg(db)!)
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
        self.getContactID()
    }
    
    //get over all contactid
    func getContactID()  {
        let idArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT userID FROM USERS"
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
        UserModel.shared.setContactIDs(IDs:idArray)
    }
    
    //get user info
    func getAllNumbers()-> NSMutableArray  {
        let idArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            let queryString = "SELECT userID,phoneNumber FROM USERS"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    let number = String(cString: sqlite3_column_text(stmt, 1))
                    print("adding \(id) numm \(number)")
                    idArray.add(DuplicateList.init(user_id: id, phone: number))
          
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        print("idarray \(idArray)")
        return idArray
    }
    
    func getAllNumbers1()-> NSMutableArray  {
        let idArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            let queryString = "SELECT USERS.userID,USERS.phoneNumber FROM RECENT LEFT JOIN USERS ON RECENT.contact_id = USERS.userID"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    let number = String(cString: sqlite3_column_text(stmt, 1))
                    print("adding \(id) numm \(number)")
                    idArray.add(DuplicateList.init(user_id: id, phone: number))
          
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        print("idarray \(idArray)")
        return idArray
    }
    
    //get my local phone numbers
    func getLocalPhoneNumbers() -> NSMutableArray  {
        let phoneNumbers = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT phoneNumber FROM USERS"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    phoneNumbers.add(id)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return phoneNumbers
    }
    //get over all contact
    func getContact(contact_id:String) -> NSMutableDictionary {
        let  msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM USERS WHERE userID = '\(contact_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "user_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "contact_name")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "user_name")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "user_phoneno")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "user_image")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "user_about")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "blockedMe")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "blockedByMe")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "mute")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "mutual_status")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "privacy_lastseen")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "privacy_about")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "privacy_image")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "favourite")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "countrycode")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDelete")

                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return msgDict
    }
    
    
    
    // ADD RECENT CHAT LIST
    func addRecent(contact_id:String,msg_id:String,unread_count:String,time:String)  {
        
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            //            "CREATE TABLE IF NOT EXISTS RECENT (contact_id VARCHAR(40) PRIMARY KEY,chat_id TEXT, message_id TEXT,unread_count TEXT,typing TEXT DEFAULT '0',timestamp TEXT)"
            let chatID = "\(UserModel.shared.userID()!)\(contact_id)"
            let queryString = "INSERT OR REPLACE INTO RECENT (contact_id,chat_id,message_id,unread_count,timestamp) VALUES ('\(contact_id)','\(chatID)','\(msg_id)','\(unread_count)','\(time)');"
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
    func getUnreadCount(contact_id:String)->Int  {
        var count = Int()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT count(*) FROM CHATS WHERE read_status = '1' AND sender_id = '\(contact_id)'"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    count = Int(sqlite3_column_int(stmt, 0));
                }
                sqlite3_finalize(stmt)
            }else{
                // print("Failed from sqlite3_prepare_v2. Error is:" );
            }
            
            sqlite3_close(db)
        }
        // print("count \(count)")
        return count
    }
    //get unread msg
    func getAllUnreadMsg(contact_id:String)-> NSMutableArray {
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHATS WHERE read_status = '1' AND sender_id = '\(contact_id)' ORDER BY timestamp DESC"
            // print("QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    let  msgDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "message_type")
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 5)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "chat_time")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "read_status")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "lat")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "lon")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "contact_name")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "contact_no")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "country_code")
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 13)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 14)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDownload")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 17)), forKey: "local_path")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "status_data")
                    
                    //                    let  resultDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "sender_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "receiver_id")
                    //                    resultDict.setValue(msgDict, forKey: "message_data")
                    //
                    //                    let msgDate = String(cString: sqlite3_column_text(stmt, 16))
                    resultArray.add(msgDict)
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        let reveresdArray:NSMutableArray = NSMutableArray.init(array: resultArray.reverseObjectEnumerator().allObjects)
        return reveresdArray
    }
    
    //get unread count
    func overAllUnreadMsg()->Int  {
        var count = Int()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT SUM(unread_count) AS Total FROM RECENT"
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
    
    //get over all contact
    func getContactList() -> NSMutableArray {
        let contactArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM USERS WHERE isDelete = '0' ORDER BY contactName ASC"
            var stmt:OpaquePointer?
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    let contact_name = String(cString: sqlite3_column_text(stmt, 1))
                    let user_name = String(cString: sqlite3_column_text(stmt, 2))
                    let phoneNo = String(cString: sqlite3_column_text(stmt, 3))
                    let cc = String(cString: sqlite3_column_text(stmt, 14))
                    let userImg = String(cString: sqlite3_column_text(stmt, 4))
                    let aboutUs = String(cString: sqlite3_column_text(stmt, 5))
                    let blockedMe = String(cString: sqlite3_column_text(stmt, 6))
                    let blockedByMe = String(cString: sqlite3_column_text(stmt, 7))
                    
                    let  userDict = NSMutableDictionary()
                    userDict.setValue(id, forKey: "user_id")
                    userDict.setValue(contact_name, forKey: "contact_name")
                    userDict.setValue(user_name, forKey: "user_name")
                    userDict.setValue(phoneNo, forKey: "user_phoneno")
                    userDict.setValue(userImg, forKey: "user_image")
                    userDict.setValue(aboutUs, forKey: "user_aboutus")
                    userDict.setValue(blockedMe, forKey: "blockedMe")
                    userDict.setValue(blockedByMe, forKey: "blockedByMe")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "mutual_status")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "privacy_lastseen")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "privacy_about")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "privacy_image")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "countrycode")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDelete")

                    let phoneContName = "+" + cc + " " + phoneNo
                    if id != UserModel.shared.userID()! as String{
                        if contact_name != phoneContName  {
                            contactArray.add(userDict)
                        }
                    }
                }
                sqlite3_finalize(stmt)
            }
            
            sqlite3_close(db)
        }
        return contactArray
    }
    
    //get over all contact
    func getFavList() -> NSMutableArray {
        let contactArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM USERS WHERE favourite = '1' ORDER BY contactName ASC"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    let contact_name = String(cString: sqlite3_column_text(stmt, 1))
                    let user_name = String(cString: sqlite3_column_text(stmt, 2))
                    let phoneNo = String(cString: sqlite3_column_text(stmt, 3))
                    let userImg = String(cString: sqlite3_column_text(stmt, 4))
                    let aboutUs = String(cString: sqlite3_column_text(stmt, 5))
                    let blockedMe = String(cString: sqlite3_column_text(stmt, 6))
                    let blockedByMe = String(cString: sqlite3_column_text(stmt, 7))
                    
                    let  userDict = NSMutableDictionary()
                    userDict.setValue(id, forKey: "user_id")
                    userDict.setValue(contact_name, forKey: "contact_name")
                    userDict.setValue(user_name, forKey: "user_name")
                    userDict.setValue(phoneNo, forKey: "user_phoneno")
                    userDict.setValue(userImg, forKey: "user_image")
                    userDict.setValue(aboutUs, forKey: "user_aboutus")
                    userDict.setValue(blockedMe, forKey: "blockedMe")
                    userDict.setValue(blockedByMe, forKey: "blockedByMe")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "mutual_status")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "privacy_lastseen")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "privacy_about")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "privacy_image")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "countrycode")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDelete")

                    contactArray.add(userDict)
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return contactArray
    }
    //get blocked contact
    func getBlockedList() -> NSMutableArray {
        let contactArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM USERS WHERE blockedByMe = '1'"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    let contact_name = String(cString: sqlite3_column_text(stmt, 1))
                    let user_name = String(cString: sqlite3_column_text(stmt, 2))
                    let phoneNo = String(cString: sqlite3_column_text(stmt, 3))
                    let userImg = String(cString: sqlite3_column_text(stmt, 4))
                    let aboutUs = String(cString: sqlite3_column_text(stmt, 5))
                    let blockedMe = String(cString: sqlite3_column_text(stmt, 6))
                    let blockedByMe = String(cString: sqlite3_column_text(stmt, 7))
                    
                    let  userDict = NSMutableDictionary()
                    userDict.setValue(id, forKey: "user_id")
                    userDict.setValue(contact_name, forKey: "contact_name")
                    userDict.setValue(user_name, forKey: "user_name")
                    userDict.setValue(phoneNo, forKey: "user_phoneno")
                    userDict.setValue(userImg, forKey: "user_image")
                    userDict.setValue(aboutUs, forKey: "user_aboutus")
                    userDict.setValue(blockedMe, forKey: "blockedMe")
                    userDict.setValue(blockedByMe, forKey: "blockedByMe")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "mutual_status")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "privacy_lastseen")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "privacy_about")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "privacy_image")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "countrycode")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDelete")

                    contactArray.add(userDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return contactArray
    }
    //get recent chat list
    func getRecentList(isFavourite: String) -> NSMutableArray {
        let recentArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            var queryString = String()
            queryString = "SELECT RECENT.contact_id,RECENT.chat_id,RECENT.message_id,message_type,message,RECENT.timestamp,read_status,unread_count,contactName,userName,phoneNumber,userImage,sender_id,blockedMe,blockedByMe,typing,isDownload,mute,mutual_status,privacy_lastseen,privacy_about,privacy_image,favourite,countrycode,isDelete FROM RECENT INNER JOIN USERS ON RECENT.contact_id = USERS.userID LEFT JOIN CHATS ON RECENT.message_id = CHATS.message_id where favourite = '\(isFavourite)' ORDER BY RECENT.timestamp DESC"

            
            //            queryString = "SELECT * FROM RECENT"
            //ORDER BY timestamp ASC"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let  userDict = NSMutableDictionary()
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "user_id")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "message_id")
                    if sqlite3_column_text(stmt, 3) != nil {
                        
                        userDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "message_type")
                        let cryptLib = CryptLib()
                        let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                        userDict.setValue(decryptedMsg, forKey: "message")
                        
                        //                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "message")
                        userDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "read_status")
                        userDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "sender_id")
                        userDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "isDownload")
                        
                    }
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "timestamp")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "unread_count")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "contact_name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "user_name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "user_phoneno")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "user_image")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "blockedMe")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "blockedByMe")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "typing")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 17)), forKey: "mute")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "mutual_status")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 19)), forKey: "privacy_lastseen")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 20)), forKey: "privacy_about")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 21)), forKey: "privacy_image")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 22)), forKey: "favourite")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 23)), forKey: "countrycode")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 24)), forKey: "isDelete")

                    recentArray.add(userDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return recentArray
    }
    
    
    //get contact recent
    func getSearchContact() -> NSMutableArray {
        let contactArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM USERS WHERE isDelete = '0' ORDER BY contactName ASC"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let id = String(cString: sqlite3_column_text(stmt, 0))
                    let contact_name = String(cString: sqlite3_column_text(stmt, 1))
                    let user_name = String(cString: sqlite3_column_text(stmt, 2))
                    let phoneNo = String(cString: sqlite3_column_text(stmt, 3))
                    let userImg = String(cString: sqlite3_column_text(stmt, 4))
                    let aboutUs = String(cString: sqlite3_column_text(stmt, 5))
                    let blockedMe = String(cString: sqlite3_column_text(stmt, 6))
                    let blockedByMe = String(cString: sqlite3_column_text(stmt, 7))
                    
                    let  userDict = NSMutableDictionary()
                    userDict.setValue(id, forKey: "user_id")
                    userDict.setValue(id, forKey: "search_id")
                    userDict.setValue(contact_name, forKey: "search_name")
                    userDict.setValue(user_name, forKey: "user_name")
                    userDict.setValue(phoneNo, forKey: "user_phoneno")
                    userDict.setValue(userImg, forKey: "search_image")
                    userDict.setValue("contact", forKey: "search_type")
                    userDict.setValue(aboutUs, forKey: "user_aboutus")
                    userDict.setValue(blockedMe, forKey: "blockedMe")
                    userDict.setValue(blockedByMe, forKey: "blockedByMe")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "mutual_status")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "privacy_lastseen")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "privacy_about")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "privacy_image")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "countrycode")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDelete")

                    if (contact_name != phoneNo) || (id != (UserModel.shared.userID() as String? ?? "")){
                        contactArray.add(userDict)
                    }
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return contactArray
    }
    
    func filterContactFrom(recent:NSMutableArray) -> NSMutableArray {
        let tempArray = self.getSearchContact()
        let contactArray = NSMutableArray()
        for people in tempArray{
            let dict:NSDictionary = people as! NSDictionary
            if !recent.contains(dict.value(forKey: "user_id") as! String){
                contactArray.add(dict)
            }
        }
        return contactArray
    }
    
    //get search recent
    func getSearchRecent() -> NSMutableArray {
        let recentArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT RECENT.contact_id,RECENT.chat_id,RECENT.message_id,message_type,message,RECENT.timestamp,read_status,unread_count,contactName,userName,phoneNumber,userImage,sender_id,blockedMe,blockedByMe,typing,isDownload,mute,mutual_status,privacy_lastseen,privacy_about,privacy_image FROM RECENT INNER JOIN USERS ON RECENT.contact_id = USERS.userID LEFT JOIN CHATS ON RECENT.message_id = CHATS.message_id ORDER BY RECENT.timestamp DESC"
            //ORDER BY timestamp ASC"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                
                    let  userDict = NSMutableDictionary()
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "user_id")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "search_id")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "search_name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "user_name")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "user_phoneno")
                    
                    userDict.setValue("contact", forKey: "search_type")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "search_image")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "blockedMe")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "blockedByMe")
                    
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "mutual_status")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 19)), forKey: "privacy_lastseen")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 20)), forKey: "privacy_about")
                    userDict.setValue(String(cString: sqlite3_column_text(stmt, 21)), forKey: "privacy_image")
                    recentArray.add(userDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return recentArray
    }
    
    // update profile pic
    func replacePic(contact_id:String,img:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE USERS SET userImage = '\(img)' WHERE userID = '\(contact_id)';"
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
    
    func addStickyDate(chat_id:String,timestamp:String)  {
        let msg_id = Utility.shared.random()
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "INSERT OR REPLACE INTO CHATS (message_id,chat_id,sender_id, receiver_id,message_type,message,timestamp,read_status,lat,lon,contact_name,contact_no,country_code,attachment,thumbnail,date,status_data) VALUES ('\(msg_id)','\(chat_id)','','','date_sticky','','\(timestamp)','','','','','','','','','\(timestamp)','');"
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
    func addChat(msg_id:String,chat_id:String,sender_id:String,receiver_id:String,msg_type:String,msg:String,time:String,lat:String,lon:String,contact_name:String,contact_no:String,country_code:String,attachment:String,thumbnail:String,read_count:String,statusData:String,blocked:String) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let currentMsgTime = formatter.date(from: time)
        let timeStr = self.getLastMsgTime(chat_id: chat_id)
        
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var dateString = String()
            dateString = Utility.shared.chatDateInEnglish(stamp: Utility.shared.convertToDouble(string: time))
            
            let queryString = "INSERT OR REPLACE INTO CHATS (message_id,chat_id,sender_id, receiver_id,message_type,message,timestamp,read_status,lat,lon,contact_name,contact_no,country_code,attachment,thumbnail,date,status_data,blocked) VALUES ('\(msg_id)','\(chat_id)','\(sender_id)','\(receiver_id)','\(msg_type)','\(msg)','\(time)','\(read_count)','\(lat)','\(lon)','\(contact_name)','\(contact_no)','\(country_code)','\(attachment)','\(thumbnail)','\(dateString)','\(statusData)','\(blocked)');"
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
        //        }
        if currentMsgTime != nil {
            print("currentMsgTime \(String(describing: currentMsgTime))")
            if timeStr != "" {
                let lastMsgTime = formatter.date(from: timeStr)
                let currentDate = Utility.shared.timeStamp(time: currentMsgTime!, format: "MMMM dd yyyy")
                let lastDate = Utility.shared.timeStamp(time: lastMsgTime! , format: "MMMM dd yyyy")
                if currentDate != lastDate {
                    /*
                     //old
                    self.addStickyDate( chat_id: chat_id, timestamp: time)
                    */
                    let date = Utility.shared.getCurrentDate(time)
                    self.addStickyDate( chat_id: chat_id, timestamp: date)
                    
                }
            }else{
                /*
                 //old
                self.addStickyDate( chat_id: chat_id, timestamp: time)
                 */
                let date = Utility.shared.getCurrentDate(time)
                self.addStickyDate( chat_id: chat_id, timestamp: date)
                
            }
        }else{
            print("currentMsgTime is NIL")
        }
        
    }
    func updateMessage(message_type: String, msg_id: String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHATS SET message_type = '\(message_type)' WHERE message_id = '\(msg_id)';"
            
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
    // get Over all media files
    func getPerticularMediaChat(chat_id:String, message_type:String) -> NSMutableArray {
        
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHATS WHERE chat_id = '\(chat_id)' AND message_type IN (\(message_type)) AND (sender_id == '\(UserModel.shared.userID()! as String)' OR isDownload == 1) ORDER BY timestamp ASC"
            //            let queryString = "SELECT * FROM CHATS WHERE chat_id = '\(chat_id)' ORDER BY timestamp DESC LIMIT 20 OFFSET '\(offset)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    let  msgDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "message_type")
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 5)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "chat_time")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "read_status")
                    
                    let decryptLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                    let decryptLong = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptLat, forKey: "lat")
                    msgDict.setValue(decryptLong, forKey: "lon")
                    
                    let decryptContactName = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 10)), key: ENCRYPT_KEY)
                    let decryptContactNo = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptContactName, forKey: "cName")
                    msgDict.setValue(decryptContactNo, forKey: "cNo")
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "country_code")
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 13)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 14)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDownload")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 17)), forKey: "local_path")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "status_data")
                    
                    let  resultDict = NSMutableDictionary()
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "sender_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "receiver_id")
                    resultDict.setValue(msgDict, forKey: "message_data")
                    
                    let msgDate = String(cString: sqlite3_column_text(stmt, 16))
                    resultArray.add(messageModel.message.init(sender_id:String(cString: sqlite3_column_text(stmt, 2)) , receiver_id: String(cString: sqlite3_column_text(stmt, 3)), message_data: msgDict, date: msgDate))
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        let reveresdArray:NSMutableArray = NSMutableArray.init(array: resultArray.reverseObjectEnumerator().allObjects)
        return reveresdArray
    }
    
    
    //get over all contact
    func getParticularMsg(msg_id:String) -> messageModel.message? {
        
        var result : messageModel.message?
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHATS WHERE message_id = '\(msg_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    let  msgDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "message_type")
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 5)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "chat_time")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "read_status")
                    
                    let decryptLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                    let decryptLong = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                    
                    msgDict.setValue(decryptLat, forKey: "lat")
                    msgDict.setValue(decryptLong, forKey: "lon")
                    
                    let decryptContactName = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 10)), key: ENCRYPT_KEY)
                    let decryptContactNo = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptContactName, forKey: "cName")
                    msgDict.setValue(decryptContactNo, forKey: "cNo")
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "country_code")
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 13)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 14)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDownload")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "date")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 17)), forKey: "local_path")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "status_data")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 19)), forKey: "translated_status")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 20)), forKey: "translated_msg")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 21)), forKey: "blocked")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")

                    let  resultDict = NSMutableDictionary()
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "sender_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "receiver_id")
                    resultDict.setValue(msgDict, forKey: "message_data")
                    
                    let msgDate = String(cString: sqlite3_column_text(stmt, 16))
                    result = messageModel.message.init(sender_id:String(cString: sqlite3_column_text(stmt, 2)) , receiver_id: String(cString: sqlite3_column_text(stmt, 3)), message_data: msgDict, date: msgDate)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        return result
    }
    
    //get over all contact
    func getChat(chat_id:String,offset:String) -> NSMutableArray? {
        
        let resultArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHATS WHERE chat_id = '\(chat_id)' ORDER BY timestamp DESC LIMIT 20 OFFSET '\(offset)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    
                    let  msgDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "message_type")
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 5)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "chat_time")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "read_status")
                    
                    let decryptLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                    let decryptLong = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                    
                    msgDict.setValue(decryptLat, forKey: "lat")
                    msgDict.setValue(decryptLong, forKey: "lon")
                    
                    let decryptContactName = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 10)), key: ENCRYPT_KEY)
                    let decryptContactNo = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptContactName, forKey: "cName")
                    msgDict.setValue(decryptContactNo, forKey: "cNo")
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "country_code")
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 13)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 14)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDownload")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 16)), forKey: "date")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 17)), forKey: "local_path")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "status_data")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 19)), forKey: "translated_status")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 20)), forKey: "translated_msg")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 21)), forKey: "blocked")
                    
                    let  resultDict = NSMutableDictionary()
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "sender_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "receiver_id")
                    resultDict.setValue(msgDict, forKey: "message_data")
                    
                    let msgDate = String(cString: sqlite3_column_text(stmt, 16))
                    resultArray.add(messageModel.message.init(sender_id:String(cString: sqlite3_column_text(stmt, 2)) , receiver_id: String(cString: sqlite3_column_text(stmt, 3)), message_data: msgDict, date: msgDate))
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        
        //        print("before msg array \(resultArray)")
        
        let reveresdArray:NSMutableArray? = NSMutableArray.init(array: resultArray.reverseObjectEnumerator().allObjects)
        
        //        print("after msg array \(reveresdArray)")
        
        return reveresdArray
    }
    //get last message
    func getLastMsgTime(chat_id:String) -> String {
        var  timeStr = ""
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHATS WHERE chat_id = '\(chat_id)' ORDER BY timestamp DESC LIMIT 1"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    timeStr = String(cString: sqlite3_column_text(stmt, 6))
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return timeStr
    }
    
    //get last message
    func getLastMsgInfo(chat_id:String) -> NSDictionary {
        var  msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHATS WHERE chat_id = '\(chat_id)' ORDER BY timestamp DESC LIMIT 1"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "chat_time")
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return msgDict
    }
    //get particular message
    func getMsg(msg_id:String) -> NSMutableDictionary {
        let  resultDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM CHATS WHERE message_id = '\(msg_id)'"
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let  msgDict = NSMutableDictionary()
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "message_id")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "message_type")
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 5)), key: ENCRYPT_KEY)
                    
                    msgDict.setValue(decryptedMsg, forKey: "message")
                    if sqlite3_column_text(stmt, 6) != nil{
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "chat_time")
                    }
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "read_status")
                    let decryptLat = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 8)), key: ENCRYPT_KEY)
                    let decryptLong = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 9)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptLat, forKey: "lat")
                    msgDict.setValue(decryptLong, forKey: "lon")
                    
                    let decryptContactName = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 10)), key: ENCRYPT_KEY)
                    let decryptContactNo = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 11)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptContactName, forKey: "cName")
                    msgDict.setValue(decryptContactNo, forKey: "cNo")
                    
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "country_code")
                    let decryptedAttachment = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 13)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedAttachment, forKey: "attachment")
                    let decryptedThumbnail = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 14)), key: ENCRYPT_KEY)
                    msgDict.setValue(decryptedThumbnail, forKey: "thumbnail")
                    if sqlite3_column_text(stmt, 15) != nil{
                        msgDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "isDownload")
                    }
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 17)), forKey: "local_path")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 18)), forKey: "status_data")
                    msgDict.setValue(String(cString: sqlite3_column_text(stmt, 21)), forKey: "blocked")
                    
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "chat_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "sender_id")
                    resultDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "receiver_id")
                    resultDict.setValue(msgDict, forKey: "message_data")
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return resultDict
    }
    
    // UPDATE CHATS TABLE
    func readStatus(id:String,status:String,type:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            var queryString = String()
            if type == "message"{
                queryString = "UPDATE CHATS SET read_status = '\(status)' WHERE message_id = '\(id)';"
            }else if type == "sender"{
                queryString = "UPDATE CHATS SET read_status = '\(status)' WHERE sender_id = '\(id)';"
            }else{
                queryString = "UPDATE CHATS SET read_status = '\(status)' WHERE chat_id = '\(id)' AND read_status = '2';" 
            }
            
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
    func updateRecent(chat_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE RECENT SET unread_count = '0' WHERE chat_id = '\(chat_id)';"
            
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
    
    func updateTranslated(msg_id: String,msg: String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHATS SET translated_status = '1',translated_msg = '\(msg)' WHERE message_id = '\(msg_id)';"
            
            // print("SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                _ =  String(cString: sqlite3_errmsg(db)!)
                //                    print("error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                _ =  String(cString: sqlite3_errmsg(db)!)
                //                    print("failure inserting hero: \(errmsg)")
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
            queryString = "UPDATE CHATS SET translated_status = '0';"
            
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
    
    // Update Recent Message ID
    func updateRecentMessage(chat_id:String, message_id:String,time: String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE RECENT SET message_id = '\(message_id)',timestamp = '\(time)' WHERE chat_id = '\(chat_id)';"
            
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
    
    // ADD RECENT CHAT LIST
    func deleteMsg(msg_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM CHATS WHERE message_id IN (\(msg_id));"
            // print("SQL QUERY : \(queryString)")x
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
    // ADD RECENT LIST
    func deleteRecent(chat_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM RECENT WHERE chat_id = '\(chat_id)';"
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
    
    // ADD RECENT CHAT LIST
    func deleteChat(chat_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM CHATS WHERE chat_id = '\(chat_id)';"
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
    
    //MARK: *********** BLOCK/UNBLOCK USER **************
    
    // UPDATE BLOCKED STATUS
    func updateBlockedStatus(contact_id:String,type:String,value:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            if type == "blockedMe"{
                queryString = "UPDATE USERS SET blockedMe = '\(value)' WHERE userID = '\(contact_id)';"
            }else{
                queryString = "UPDATE USERS SET blockedByMe = '\(value)' WHERE userID = '\(contact_id)';"
            }
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
    // MARK ALL UNBLOCKED
    func markAllUnblocked()  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            
            queryString = "UPDATE USERS SET blockedMe = '0';"
            
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
    func updateAllDownloadStatus()  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHATS SET isDownload = '4' WHERE isDownload = '2';"
            
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
    func updateDownload(msg_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHATS SET isDownload = '\(status)' WHERE message_id = '\(msg_id)';"
            
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
    func updateVideoURL(msg_id:String,attachment:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHATS SET attachment = '\(attachment)' WHERE message_id = '\(msg_id)';"
            
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
    
    // UPDATE Privacy
    func updatePrivacy(user_id:String,lastseen:String,about:String,profile_pic:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE USERS SET (privacy_lastseen,privacy_about,privacy_image) = ('\(lastseen)','\(about)','\(profile_pic)') WHERE userID = '\(user_id)';"
            
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
    func updateLocalURL(msg_id:String,url:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHATS SET local_path = '\(url)' WHERE message_id = '\(msg_id)';"
            
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
    func updateThumbnailURL(msg_id:String, attachment: String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE CHATS SET thumbnail = \(attachment) WHERE message_id = '\(msg_id)';"
            
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
    // UPDATE TYPING
    func updateTyping(contact_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE RECENT SET typing = '\(status)' WHERE contact_id = '\(contact_id)';"
            
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
    
    // UPDATE CONTACT NAME
    func updateName(cotact_id:String,name:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE USERS SET contactName = '\(name)' WHERE userID = '\(cotact_id)';"
            
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
    
    // UPDATE delete name
    func updateDelete(user_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE USERS SET isDelete = '1' WHERE userID = '\(user_id)';"
            
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
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    // UPDATE CONTACT number
    func updateNumber(contact_id:String,no:String,name:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE USERS SET (contactName,phoneNumber) = ('\(name)','\(no)') WHERE userID = '\(contact_id)';"
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
    // UPDATE MUTE
    func updateMute(cotact_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE USERS SET mute = '\(status)' WHERE userID = '\(cotact_id)';"
            
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
    
    // UPDATE FAVOURITE
    func updateFavourite(cotact_id:String,status:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            var queryString = String()
            queryString = "UPDATE USERS SET favourite = '\(status)' WHERE userID = '\(cotact_id)';"
            
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
struct DuplicateList {
    let user_id: String
    let phone: String
}
