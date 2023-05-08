//
//  storyStorage.swift
//  Hiddy
//
//  Created by Hitasoft on 05/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import Foundation
import SQLite3

class storyStorage: NSObject {
    
    let localObj = LocalStorage()
    static let sharedInstance = storyStorage()

    func createStory()  {
        //CHANNEL TABLE
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS STORIES (story_id VARCHAR(40) PRIMARY KEY,sender_id TEXT,story_members TEXT,message TEXT, story_type TEXT,attachment TEXT,story_date TEXT DEFAULT '0',story_time TEXT DEFAULT '0',expiry_time TEXT DEFAULT '0', isViewed TEXT DEFAULT '0', thumbNail TEXT DEFAULT '0', local_path TEXT DEFAULT '0')", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS STORYVIEWERS (member_key VARCHAR(40) PRIMARY KEY,receiver_id VARCHAR(40) ,sender_id TEXT, timestamp TEXT DEFAULT '0', story_id TEXT, FOREIGN KEY(story_id) REFERENCES STORIES(story_id))", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }

    }
    
    
    
    // Add Story
    func addStory(story_id:String,sender_id:String,story_members:String,message:String,story_type:String,attachment:String,story_date:String,story_time:String,expiry_time:String, thumbNail: String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "INSERT OR REPLACE INTO STORIES (story_id,sender_id,story_members, message,story_type,attachment,story_date,story_time,expiry_time,thumbNail) VALUES ('\(story_id)','\(sender_id)','\(story_members)','\(message)','\(story_type)','\(attachment)','\(story_date)','\(story_time)','\(expiry_time)','\(thumbNail)');"
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
    
    // updateVideo Duration
    
    func updateLocalPath(storyID: String, local_path: String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE STORIES SET local_path='\(local_path)' WHERE story_id='\(storyID)';"
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
    
    func deleteAfterOneDay() {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        self.cleanUp()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let utcTime = Utility.shared.getTime()
//            let queryString = "DELETE FROM STORIES WHERE expiry_time <= (strftime('%s','now')*1000);"
            let queryString = "DELETE FROM STORIES WHERE expiry_time <= '\(utcTime)';"

             print("DELETE******** SQL QUERY : \(queryString)")
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
//                 print("DELETE******** error preparing insert: \(errmsg)")
                return
            }
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
//                 print("DELETE******** failure inserting hero: \(errmsg)")
                return
            }
            //finalize query
            if sqlite3_finalize(stmt) != SQLITE_OK {
                let errmsg =  String(cString: sqlite3_errmsg(db)!)
//                 print("DELETE******** error finalizing prepared statement: \(errmsg)")
            }
        }
        //close db
        if sqlite3_close(db) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error closing database \(errmsg)")
        }
        db = nil
    }
    
    //get Story information
    func getUserInfo(userID:String) -> [statusModel] {
        var  storyArray = [statusModel]()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM STORIES WHERE sender_id = '\(userID)'" //
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    var storyDict1 = [String:String]()
                    storyDict1["story_id"] = String(cString: sqlite3_column_text(stmt, 0))
                    storyDict1["sender_id"] = String(cString: sqlite3_column_text(stmt, 1))
                    storyDict1["story_members"] = String(cString: sqlite3_column_text(stmt, 2))
                    storyDict1["message"] = String(cString: sqlite3_column_text(stmt, 3))
                    storyDict1["story_type"] = String(cString: sqlite3_column_text(stmt, 4))
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 5)), key: ENCRYPT_KEY)
 
                    storyDict1["attachment"] = decryptedMsg ?? ""
                    storyDict1["story_date"] = String(cString: sqlite3_column_text(stmt, 6))
                    storyDict1["story_time"] = String(cString: sqlite3_column_text(stmt, 7)) 
                    storyDict1["expiry_time"] = ""// String(cString: sqlite3_column_text(stmt, 8))
                    storyDict1["isViewed"] = String(cString: sqlite3_column_text(stmt, 9))
                    storyDict1["thumbNail"] = String(cString: sqlite3_column_text(stmt, 10))
                    storyDict1["local_path"] = String(cString: sqlite3_column_text(stmt, 11))

                    let storyVal = statusModel.init(attachment: storyDict1["attachment"] ?? "" , expiry_time: storyDict1["expiry_time"] ?? "", message: storyDict1["message"] ?? "", sender_id: storyDict1["sender_id"] ?? "", story_date: storyDict1["story_date"] ?? "", story_id: storyDict1["story_id"] ?? "", story_members: storyDict1["story_members"] ?? "", story_time: storyDict1["story_time"] ?? "", story_type: storyDict1["story_type"] ?? "", thumbNail: storyDict1["thumbNail"] ?? "", is_Viewed: storyDict1["isViewed"] ?? "", local_path: storyDict1["local_path"] ?? "")
                    storyArray.append(storyVal)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return storyArray
    }
    
    func checkIfExsit(story_id:String) -> [statusModel] {
        var  storyArray = [statusModel]()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT * FROM STORIES WHERE story_id = '\(story_id)';" //
            // print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    var storyDict1 = [String:String]()
                    storyDict1["story_id"] = String(cString: sqlite3_column_text(stmt, 0))
                    storyDict1["sender_id"] = String(cString: sqlite3_column_text(stmt, 1))
                    storyDict1["story_members"] = String(cString: sqlite3_column_text(stmt, 2))
                    storyDict1["message"] = String(cString: sqlite3_column_text(stmt, 3))
                    storyDict1["story_type"] = String(cString: sqlite3_column_text(stmt, 4))
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 5)), key: ENCRYPT_KEY)
                    
                    storyDict1["attachment"] = decryptedMsg ?? ""
                    storyDict1["story_date"] = String(cString: sqlite3_column_text(stmt, 6))
                    storyDict1["story_time"] = String(cString: sqlite3_column_text(stmt, 7))
                    storyDict1["expiry_time"] = ""// String(cString: sqlite3_column_text(stmt, 8))
                    storyDict1["isViewed"] = String(cString: sqlite3_column_text(stmt, 9))
                    storyDict1["local_path"] = String(cString: sqlite3_column_text(stmt, 11))
                    let storyVal = statusModel.init(attachment: storyDict1["attachment"] ?? "" , expiry_time: storyDict1["expiry_time"] ?? "", message: storyDict1["message"] ?? "", sender_id: storyDict1["sender_id"] ?? "", story_date: storyDict1["story_date"] ?? "", story_id: storyDict1["story_id"] ?? "", story_members: storyDict1["story_members"] ?? "", story_time: storyDict1["story_time"] ?? "", story_type: storyDict1["story_type"] ?? "", thumbNail: "", is_Viewed: storyDict1["isViewed"] ?? "", local_path: storyDict1["local_path"] ?? "")
                    storyArray.append(storyVal)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return storyArray
    }
    func deleteFromDocument(response: String, fileName: String) {
        // get the documents directory url
        var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // create the destination file url to save your image
        documentsDirectory.appendPathComponent(DOCUMENT_PATH)
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("file saved: \(fileURL)")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    func cleanUp() {
        let maximumDays = 1.0
        let minimumDate = Date().addingTimeInterval(-maximumDays*24*60*60)
        func meetsRequirement(date: Date) -> Bool { return date < minimumDate }

        func meetsRequirement(name: String) -> Bool { return name.hasPrefix(DOCUMENT_PATH) && name.hasSuffix("log") }

        let fileManager = FileManager.default
        var documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            documentsURL.appendPathComponent(DOCUMENT_PATH)
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            for file in fileURLs {
                let creationDate = try fileManager.attributesOfItem(atPath: file.path)[FileAttributeKey.creationDate] as! Date
                if meetsRequirement(date: creationDate) {
                    try fileManager.removeItem(atPath: file.path)
                }
            }
            // process files
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    func deleteStory(story_id:String, fileName: String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM STORIES WHERE story_id = '\(story_id)';"
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
    func storyViewList(story_id: String) -> [viewListModel] {
        var  storyArray = [viewListModel]()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            // SELECT * FROM STORIES GROUP BY sender_id ORDER BY story_time DESC
            
            let queryString = "SELECT * FROM STORYVIEWERS WHERE story_id = '\(story_id)'"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    var storyDict1 = [String:String]()
                    storyDict1["member_key"] = String(cString: sqlite3_column_text(stmt, 0))
                    storyDict1["receiver_id"] = String(cString: sqlite3_column_text(stmt, 1))
                    storyDict1["sender_id"] = String(cString: sqlite3_column_text(stmt, 2))
                    storyDict1["story_id"] = String(cString: sqlite3_column_text(stmt, 4))
                    storyDict1["timestamp"] = String(cString: sqlite3_column_text(stmt, 3))
                    
                    let storyVal = viewListModel.init(member_key: storyDict1["member_key"] ?? "", sender_id: storyDict1["sender_id"] ?? "", story_id: storyDict1["story_id"] ?? "", receiver_id: storyDict1["receiver_id"] ?? "", timestamp: storyDict1["timestamp"] ?? "")
                    storyArray.append(storyVal)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return storyArray

    }
    func addViewList(sender_id: String, receiver_id: String, story_id: String, timestamp: String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        let member_key = story_id + sender_id
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO STORYVIEWERS (member_key,sender_id,story_id,receiver_id,timestamp) VALUES ('\(member_key)','\(sender_id)','\(story_id)','\(receiver_id)','\(timestamp)');"
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
    func updateViewStatus(storyID: String) {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE STORIES SET isViewed=1 WHERE story_id='\(storyID)';"
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
    func getGroupRecentList(isViewed: String) -> [RecentStoryModel] {
        var  storyArray = [RecentStoryModel]()
        self.deleteAfterOneDay()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            var queryString = String()
            // SELECT * FROM STORIES GROUP BY sender_id ORDER BY story_time DESC
            queryString = "SELECT STORIES.sender_id, STORIES.story_id, STORIES.message, STORIES.story_type, STORIES.attachment, STORIES.story_date, STORIES.story_time, STORIES.expiry_time, userName, phoneNumber, userImage, aboutUs, blockedMe, blockedByMe, mute, mutual_status, privacy_lastseen, privacy_about, privacy_image, favourite, contactName,isDelete FROM STORIES INNER JOIN USERS ON STORIES.sender_id == USERS.userID WHERE isViewed = '\(isViewed)' AND isDelete = '0' AND STORIES.sender_id != '\(UserModel.shared.userID() as String? ?? "")' GROUP BY STORIES.sender_id ORDER BY STORIES.story_time DESC"
            
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    var storyDict1 = [String:String]()
                    storyDict1["sender_id"] = String(cString: sqlite3_column_text(stmt, 0))
                    storyDict1["story_id"] = String(cString: sqlite3_column_text(stmt, 1))
                    storyDict1["message"] = String(cString: sqlite3_column_text(stmt, 2))
                    storyDict1["story_type"] = String(cString: sqlite3_column_text(stmt, 3))
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    
                    storyDict1["attachment"] = decryptedMsg ?? ""
                    storyDict1["story_date"] = String(cString: sqlite3_column_text(stmt, 5))
                    storyDict1["story_time"] = String(cString: sqlite3_column_text(stmt, 6))
                    storyDict1["expiry_time"] = String(cString: sqlite3_column_text(stmt, 7))
                    storyDict1["userName"] = String(cString: sqlite3_column_text(stmt, 8))
                    storyDict1["phoneNumber"] = String(cString: sqlite3_column_text(stmt, 9))
                    storyDict1["userImage"] = String(cString: sqlite3_column_text(stmt, 10))
                    storyDict1["aboutUs"] = String(cString: sqlite3_column_text(stmt, 11))
                    storyDict1["blockedMe"] = String(cString: sqlite3_column_text(stmt, 12))
                    storyDict1["blockedByMe"] = String(cString: sqlite3_column_text(stmt, 13))
                    storyDict1["mute"] = String(cString: sqlite3_column_text(stmt, 14))
                    storyDict1["mutual_status"] = String(cString: sqlite3_column_text(stmt, 15))
                    storyDict1["privacy_lastseen"] = String(cString: sqlite3_column_text(stmt, 16))
                    storyDict1["privacy_about"] = String(cString: sqlite3_column_text(stmt, 17))
                    storyDict1["privacy_image"] = String(cString: sqlite3_column_text(stmt, 18))
                    storyDict1["favourite"] = String(cString: sqlite3_column_text(stmt, 19))
                    storyDict1["contactName"] = String(cString: sqlite3_column_text(stmt, 20))
                    let storyVal = RecentStoryModel.init(sender_id: storyDict1["sender_id"] ?? "", story_id: storyDict1["story_id"] ?? "", message: storyDict1["message"] ?? "", story_type: storyDict1["story_type"] ?? "", attachment: storyDict1["attachment"] ?? "", story_date: storyDict1["story_date"] ?? "", story_time: storyDict1["story_time"] ?? "", expiry_time: storyDict1["expiry_time"] ?? "", contactName: storyDict1["contactName"] ?? "", userName: storyDict1["userName"] ?? "", phoneNumber: storyDict1["phoneNumber"] ?? "", userImage: storyDict1["userImage"] ?? "", aboutUs: storyDict1["aboutUs"] ?? "", blockedMe: storyDict1["blockedMe"] ?? "", blockedByMe: storyDict1["blockedByMe"] ?? "", mute: storyDict1["mute"] ?? "", mutual_status: storyDict1["mutual_status"] ?? "", privacy_lastseen: storyDict1["privacy_lastseen"] ?? "", privacy_about: storyDict1["privacy_about"] ?? "", privacy_image: storyDict1["privacy_image"] ?? "", favourite: storyDict1["favourite"] ?? "")
                    if storyVal.phoneNumber != storyVal.contactName {
                        storyArray.append(storyVal)
                    }
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return storyArray
    }
    func getFavStoryList() -> [RecentStoryModel] {
        var  storyArray = [RecentStoryModel]()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM STORIES JOIN USERS WHERE STORIES.sender_id=USERS.user_id ORDER BY STORIES.story_time ASC"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    var storyDict1 = [String:String]()
                    storyDict1["sender_id"] = String(cString: sqlite3_column_text(stmt, 0))
                    storyDict1["story_id"] = String(cString: sqlite3_column_text(stmt, 1))
                    storyDict1["message"] = String(cString: sqlite3_column_text(stmt, 2))
                    storyDict1["story_type"] = String(cString: sqlite3_column_text(stmt, 3))
                    let cryptLib = CryptLib()
                    let decryptedMsg = cryptLib.decryptCipherTextRandomIV(withCipherText: String(cString: sqlite3_column_text(stmt, 4)), key: ENCRYPT_KEY)
                    
                    storyDict1["attachment"] = decryptedMsg ?? ""
                    storyDict1["story_date"] = String(cString: sqlite3_column_text(stmt, 5))
                    storyDict1["story_time"] = String(cString: sqlite3_column_text(stmt, 6))
                    storyDict1["expiry_time"] = String(cString: sqlite3_column_text(stmt, 7))
                    storyDict1["userName"] = String(cString: sqlite3_column_text(stmt, 8))
                    storyDict1["phoneNumber"] = String(cString: sqlite3_column_text(stmt, 9))
                    storyDict1["userImage"] = String(cString: sqlite3_column_text(stmt, 10))
                    storyDict1["aboutUs"] = String(cString: sqlite3_column_text(stmt, 11))
                    storyDict1["blockedMe"] = String(cString: sqlite3_column_text(stmt, 12))
                    storyDict1["blockedByMe"] = String(cString: sqlite3_column_text(stmt, 13))
                    storyDict1["mute"] = String(cString: sqlite3_column_text(stmt, 14))
                    storyDict1["mutual_status"] = String(cString: sqlite3_column_text(stmt, 15))
                    storyDict1["privacy_lastseen"] = String(cString: sqlite3_column_text(stmt, 16))
                    storyDict1["privacy_about"] = String(cString: sqlite3_column_text(stmt, 17))
                    storyDict1["privacy_image"] = String(cString: sqlite3_column_text(stmt, 18))
                    storyDict1["favourite"] = String(cString: sqlite3_column_text(stmt, 19))
                    let storyVal = RecentStoryModel.init(sender_id: storyDict1["sender_id"] ?? "", story_id: storyDict1["story_id"] ?? "", message: storyDict1["message"] ?? "", story_type: storyDict1["story_type"] ?? "", attachment: storyDict1["attachment"] ?? "", story_date: storyDict1["story_date"] ?? "", story_time: storyDict1["story_time"] ?? "", expiry_time: storyDict1["expiry_time"] ?? "", contactName: storyDict1["contactName"] ?? "", userName: storyDict1["userName"] ?? "", phoneNumber: storyDict1["phoneNumber"] ?? "", userImage: storyDict1["userImage"] ?? "", aboutUs: storyDict1["aboutUs"] ?? "", blockedMe: storyDict1["blockedMe"] ?? "", blockedByMe: storyDict1["blockedByMe"] ?? "", mute: storyDict1["mute"] ?? "", mutual_status: storyDict1["mutual_status"] ?? "", privacy_lastseen: storyDict1["privacy_lastseen"] ?? "", privacy_about: storyDict1["privacy_about"] ?? "", privacy_image: storyDict1["privacy_image"] ?? "", favourite: storyDict1["favourite"] ?? "")
                    storyArray.append(storyVal)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return storyArray
    }
    // Get all Story
    func getRecentList(id: String) -> NSMutableArray {
        let contactArray = NSMutableArray()

        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            var queryString = String()
            queryString = "SELECT * FROM USERS WHERE userID = '\(id)'"
            
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
                    contactArray.add(userDict)
                    
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return contactArray
    }
    
    func getRecentStory() -> NSMutableArray {
        let contactArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT * FROM USERS LEFT JOIN STORIES ON USERS.user_id = STORIES.sender_id ORDER BY RECENT.timestamp ASC"
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
                    contactArray.add(userDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return contactArray
    }
}
