//
//  ContactModel.swift
//  Hiddy
//
//  Created by Hitasoft on 09/06/21.
//  Copyright © 2021 HITASOFT. All rights reserved.
//

import Foundation


class ContactModel {
    var contactName: String!
    var contactNumber = [String]()
    init(contactName: String = "", contactNumber: [String] = [String]()) {
        self.contactName = contactName
        self.contactNumber = contactNumber
    }
}
