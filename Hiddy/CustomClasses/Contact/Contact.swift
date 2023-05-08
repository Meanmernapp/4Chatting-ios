//
//  Contact.swift
//  Hiddy
//
//  Created by APPLE on 03/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
import Contacts
import PhoneNumberKit

class Contact{
    static let sharedInstance = Contact()
    let contactStore = CNContactStore()
    let phoneNoArray = NSMutableArray()
    let phoneNumberKit = PhoneNumberKit()
    let phoneContacts = NSMutableArray()
    var isAlreadyLoaded = false

    //get all contact list
    func synchronize() {

        if !self.isAlreadyLoaded {
            print("RequestTimeOut of mine0")
            self.phoneNoArray.removeAllObjects()
            self.phoneContacts.removeAllObjects()
            UserModel.shared.removeContactList()
            self.isAlreadyLoaded = true
            let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey]
            print("Test before")
            let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
            try? self.contactStore.enumerateContacts(with: request1) { (contact, error) in
                print("Test Current")
                if contact.phoneNumbers.count != 0{
                    for people in contact.phoneNumbers {
                        // Whatever you want to do with it
                        let phoneStr = people.value.stringValue.replacingOccurrences(of: "-", with:"")
                        do {
                            let phoneNumber = try self.phoneNumberKit.parse(phoneStr, withRegion: "GB", ignoreType: true)
                            print("ContactName:: \(contact.givenName) phone_no:: \(phoneStr)")
                            //                    if contact.givenName != ""{
                            self.phoneNoArray.add(phoneNumber.nationalNumber)
                            
                            let dict = ["phone_no":"\(phoneNumber.nationalNumber)","contact_name":"\(contact.givenName)"]
                            self.phoneContacts.add(dict)
                            //                    }
                        }
                        catch {
                            let numberSet = CharacterSet(charactersIn: "0123456789")
                            if phoneStr.rangeOfCharacter(from: numberSet.inverted) != nil {
                                print("string contains special characters")
                            }else{
                                if phoneStr.length > 5 {
                                    //                            if contact.givenName != ""{
                                    self.phoneNoArray.add(phoneStr)
                                    print("phone_no:: \(phoneStr)")
                                    let dict = ["phone_no":"\(phoneStr)","contact_name":"\(contact.givenName)"]
                                    self.phoneContacts.add(dict)
                                    //                            }
                                }
                            }
                        }
                    }
                }
            }
            // save my conatcts
            let userObj = UserWebService()
            userObj.saveContacts(contacts: self.phoneNoArray, onSuccess: {response in
                let status:String = response.value(forKey: "status") as! String
                if status == STATUS_TRUE{
                    print("RequestTimeOut of mine1")
                    let localDB = LocalStorage()
                    let localArray = localDB.getLocalPhoneNumbers()
                    if localArray.count != 0 {
                        self.phoneNoArray.addObjects(from: localArray as! [Any])
                        self.updateMyContacts(success: { success1 in
                            NotificationCenter.default.post(name: Notification.Name("ContactRefresh"), object: nil)
                        })
                    }
                }else{
                    print("RequestTimeOut of mine2")
                }
                self.isAlreadyLoaded = false
            })
            UserModel.shared.setAllContacts(contacts: self.phoneContacts as! [[String : String]])
        }
    }
    //update my contacts
    func updateMyContacts(success: @escaping (Bool) -> Void)  {
        if self.phoneNoArray.count != 0{
        let userObj = UserWebService()
            userObj.setContacts(contacts: self.phoneNoArray, onSuccess: {response in
                DispatchQueue.main.async {
                    let status:String = response.value(forKey: "status") as! String
                    self.isAlreadyLoaded = false
                    if status == STATUS_TRUE{
                        let tempArray = NSMutableArray()
                        tempArray.addObjects(from: (response.value(forKey: "result") as! NSArray) as! [Any])
                        self.addToDB(contact: tempArray, success: { success1 in
                            success(true)
                        })
                    }else{

                    }
                }
            })
        }
    }
    
    //add contat to local db
    func addToDB(contact:NSMutableArray, success: @escaping (Bool) -> Void)  {
        let localObj = LocalStorage()
        for contactDict in contact {
            let userDict:NSDictionary = contactDict as! NSDictionary
            let phoneNo:NSNumber = userDict.value(forKey: "phone_no") as! NSNumber
            let cc = userDict.value(forKey: "country_code") as! Int
            var name = String()
            let contactName = Utility.shared.searchPhoneNoAvailability(phoneNo: "\(phoneNo)")
            if contactName == EMPTY_STRING{
                name = "+\(cc) " + "\(phoneNo)"
            }else{
                name = contactName
            }
            let type = String()
            var username = String()
            if userDict.value(forKey: "user_name") != nil{
                username = userDict.value(forKey: "user_name") as! String
                localObj.addContact(userid: userDict.value(forKey: "_id") as! String,
                                    contactName: name,
                                    userName:username,
                                    phone:String(describing: phoneNo) ,
                                    img: userDict.value(forKey: "user_image") as! String,
                                    about: userDict.value(forKey: "about") as? String ?? "",
                                    type:type,
                                    mutual:userDict.value(forKey: "contactstatus") as! String,
                                    privacy_lastseen: userDict.value(forKey: "privacy_last_seen") as! String,
                                    privacy_about: userDict.value(forKey: "privacy_about") as! String,
                                    privacy_picture: userDict.value(forKey: "privacy_profile_image") as! String, countryCode: String(cc))
            }else {
                username = EMPTY_STRING
            }
        }
        Utility.shared.checkDeletedList({ success in
            print("called pls three")
           
        })
        print("called pls one")
        success(true)
        print("called pls two")

    }
}

