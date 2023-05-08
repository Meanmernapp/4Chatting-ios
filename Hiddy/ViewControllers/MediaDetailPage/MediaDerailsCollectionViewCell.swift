//
//  MediaDerailsCollectionViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 25/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit

class MediaDerailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.playerView.cornerViewRadius()
    }
    func configSingleChat(dict: messageModel.message) {
        if dict.message_data.value(forKeyPath: "message_type") as! String == "image" {
            let imageName:String = dict.message_data.value(forKey: "attachment") as? String ?? ""
            self.playerView.isHidden = true
            self.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else {
            let imageName:String = dict.message_data.value(forKey: "thumbnail") as? String ?? ""
            self.playerView.isHidden = false
            self.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }
    func configGroupChat(dict: groupMsgModel.message) {
        if dict.message_type == "image" {
            let imageName:String = dict.attachment
            self.playerView.isHidden = true
            self.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else {
            let imageName:String = dict.thumbnail
            self.playerView.isHidden = false
            self.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }
    func configChannelChat(dict: channelMsgModel.message) {
        if dict.message_type == "image" {
            let imageName:String = dict.attachment
            self.playerView.isHidden = true
            self.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else {
            let imageName:String = dict.thumbnail
            self.playerView.isHidden = false
            self.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
    }

}
