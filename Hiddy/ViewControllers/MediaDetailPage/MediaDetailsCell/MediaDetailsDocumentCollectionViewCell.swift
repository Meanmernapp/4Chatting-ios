//
//  MediaDetailsDocumentCollectionViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 25/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit

class MediaDetailsDocumentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var docView: UIView!
    @IBOutlet weak var docIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var docTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.docTypeLabel.config(color: TEXT_PRIMARY_COLOR, size: 19, align: .left, text: EMPTY_STRING)
        self.typeLabel.config(color: .white, size: 14, align: .center, text: EMPTY_STRING)
        // Initialization code
    }
    func configSingleChat(dict: messageModel.message) {
        let path:String = dict.message_data.value(forKeyPath: "attachment") as! String
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(path)")
        self.typeLabel.text = docURL?.pathExtension.uppercased()
        let type = dict.message_data.value(forKeyPath: "message_type") as! String
        if type == "audio" {
            self.docIcon.image = #imageLiteral(resourceName: "mp3")
            self.docIcon.tintColor = .lightGray
            self.typeLabel.isHidden = true
            let docuName:String = path
            self.docTypeLabel.text = docuName
        }
        else {
            self.docIcon.image = #imageLiteral(resourceName: "document_icon")
            self.typeLabel.isHidden = false
            let docuName:String = dict.message_data.value(forKeyPath: "message") as! String
            self.docTypeLabel.text = docuName

        }
        
    }
    func configGroupChat(dict: groupMsgModel.message) {
        let path:String = dict.attachment
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(path)")
        self.typeLabel.text = docURL?.pathExtension.uppercased()
        let type = dict.message_type
        if type == "audio" {
            self.docIcon.image = #imageLiteral(resourceName: "mp3")
            self.docIcon.tintColor = .lightGray
            self.typeLabel.isHidden = true
            let docuName:String = path
            self.docTypeLabel.text = docuName
        }
        else {
            self.docIcon.image = #imageLiteral(resourceName: "document_icon")
            self.typeLabel.isHidden = false
            let docuName:String = dict.message
            self.docTypeLabel.text = docuName
        }
    }
    func configChannelChat(dict: channelMsgModel.message) {
        let path:String = dict.attachment
        let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(path)")
        self.typeLabel.text = docURL?.pathExtension.uppercased()
        let type = dict.message_type
        if type == "audio" {
            self.docIcon.image = #imageLiteral(resourceName: "mp3")
            self.docIcon.tintColor = .lightGray
            self.typeLabel.isHidden = true
            let docuName:String = path
            self.docTypeLabel.text = docuName
        }
        else {
            self.docIcon.image = #imageLiteral(resourceName: "document_icon")
            self.typeLabel.isHidden = false
            let docuName:String = dict.message
            self.docTypeLabel.text = docuName
        }
    }
}
