//
//  DBConfig.swift
//  Hiddy
//
//  Created by Roby on 27/07/20.
//  Copyright © 2020 HITASOFT. All rights reserved.
//

import Foundation
import SQLite3
import SocketIO

var db: OpaquePointer?


class DBConfig{
    var socket = SocketManager(socketURL: URL(string: SOCKET_URL)!, config: [.log(true), .compress])
    
    //get DB route path
    func filePath() -> String {
        sqlite3_shutdown();
//        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
        sqlite3_initialize();
        let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: NOTIFICATION_EXTENSION)?.appendingPathComponent("Hiddy.sqlite")
            
        return fileURL!.path
    }
    func getContactName(contact_id:String) -> String{
        var name = ""
        if (sqlite3_open(self.filePath(), &db)==SQLITE_OK){
            let queryString = "SELECT * FROM USERS WHERE userID = '\(contact_id)'"
            print("SQL QUERY \(queryString)")
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
                while(sqlite3_step(stmt) == SQLITE_ROW){
                    name = String(cString: sqlite3_column_text(stmt, 1))
                    sqlite3_finalize(stmt)
                    sqlite3_close(db)
                    return name
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return name
    }
    func getAccessToken() -> NSString? {
        if let defaults = UserDefaults(suiteName: NOTIFICATION_EXTENSION) {
            let defaults = defaults.string(forKey: "user_accessToken")
            return defaults as NSString?
        }
        return nil
    }
    //get over all contact
    func getContact(contact_id:String) -> NSMutableDictionary? {
        let  msgDict = NSMutableDictionary()
        if (sqlite3_open(DBConfig().filePath(), &db)==SQLITE_OK){
            let queryString = "SELECT * FROM USERS WHERE userID = '\(contact_id)'"
            print("SQL QUERY \(queryString)")
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
                    sqlite3_finalize(stmt)
                    sqlite3_close(db)
                    return msgDict
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
            print("RESULT CHECK TWO")
            return nil
        }
        return msgDict
    }

}
