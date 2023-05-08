//
//  CallStorage.swift
//  Hiddy
//
//  Created by APPLE on 30/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
import SQLite3

class CallStorage: NSObject {
    let localObj = LocalStorage()
    static let sharedInstance = CallStorage()
    func createCallTable()  {
        //GROUP TABLE
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS CALLS (call_id VARCHAR(100) PRIMARY KEY,contact_id TEXT,status TEXT,call_type TEXT,timestamp TEXT, unread_count TEXT)", nil, nil, nil) != SQLITE_OK {
            _ =  String(cString: sqlite3_errmsg(db)!)
            // print("error creating table: \(errmsg)")
        }
    }
    
    func addNewCall(call_id:String,contact_id:String,status:String,call_type:String,timestamp:String,unread_count: String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "INSERT OR REPLACE INTO CALLS (call_id,contact_id,status,call_type,timestamp, unread_count) VALUES ('\(call_id)','\(contact_id)','\(status)','\(call_type)','\(timestamp)', '\(unread_count)');"
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
    func deleteCall(chatID:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "DELETE FROM CALLS WHERE call_id IN (\(chatID));"
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
    func callUpdateUnreadCount(call_id:String)  {
        //creating a statement
        var stmt: OpaquePointer?
        //open db
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "UPDATE CALLS SET unread_count = '0' WHERE call_id = '\(call_id)';"
            
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
    //get all count
    func callOverallUnreadMissedCalls()->Int  {
        var count = Int()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            let queryString = "SELECT SUM(unread_count) AS Total FROM CALLS"
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
    //get call list
    func getCallsList() -> NSMutableArray {
        let groupArray = NSMutableArray()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK)
        {
            
            let queryString = "SELECT call_id,CALLS.contact_id,CALLS.status,CALLS.call_type,CALLS.timestamp,userID,contactName,userName,phoneNumber,userImage,mutual_status,privacy_lastseen,privacy_about,privacy_image,blockedMe,blockedByMe FROM CALLS LEFT JOIN USERS ON CALLS.contact_id = USERS.userID ORDER BY CALLS.timestamp DESC"
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    let  callDict = NSMutableDictionary()
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 0)), forKey: "call_id")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 1)), forKey: "contact_id")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 2)), forKey: "status")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 3)), forKey: "call_type")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 4)), forKey: "timestamp")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 5)), forKey: "userID")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 6)), forKey: "contactName")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 7)), forKey: "userName")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 8)), forKey: "phoneNumber")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 9)), forKey: "userImage")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 10)), forKey: "mutual_status")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 11)), forKey: "privacy_lastseen")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 12)), forKey: "privacy_about")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 13)), forKey: "privacy_image")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 14)), forKey: "blockedMe")
                    callDict.setValue(String(cString: sqlite3_column_text(stmt, 15)), forKey: "blockedByMe")
                    groupArray.add(callDict)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return groupArray
    }
}

