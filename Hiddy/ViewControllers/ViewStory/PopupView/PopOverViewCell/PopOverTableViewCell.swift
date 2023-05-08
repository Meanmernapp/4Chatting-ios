//
//  PopOverTableViewCell.swift
//  Hiddy
//
//  Created by Hitasoft on 08/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit

class PopOverTableViewCell: UITableViewCell {

    @IBOutlet weak var userTimeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userNameLabel.config(color:TEXT_PRIMARY_COLOR, size: 16, align: .natural, text: EMPTY_STRING)
        self.userTimeLabel.config(color:.lightGray, size: 14, align: .natural, text: EMPTY_STRING)
        self.userImageView.rounded()
        self.contentView.backgroundColor = BOTTOM_BAR_COLOR

        // Initialization code
    }
    func config(_ viewList: viewListModel) {
        if let value = storyStorage().getRecentList(id: viewList.sender_id).firstObject  {
            let contactDict = value as! NSDictionary
            self.userNameLabel.text = contactDict.value(forKey: "contact_name") as? String ?? "You"
            
            let imageName:String = contactDict.value(forKey: "user_image") as? String ?? ""
            let blockedStatus:String = contactDict.value(forKey: "blockedMe") as? String ?? ""
            let privacy_image:String = contactDict.value(forKey: "privacy_image") as? String ?? ""
            let mutual:String = contactDict.value(forKey: "mutual_status") as? String ?? ""
            let dateString = Utility.shared.chatDate(stamp: viewList.timestamp)
            
//            let dateString = Utility.shared.chatTime(stamp: viewList.timestamp)
            let dateformat =  DateFormatter()
            
           // dateformat.locale = Locale(identifier: "en_US")
            dateformat.locale = Locale(identifier: "en_US_POSIX")
            dateformat.dateFormat = "dd MMM yyyy"
            let dateNew = dateformat.string(from: Date())
            if dateNew == dateString  {
                self.userTimeLabel.text = Utility.shared.getLanguage()?.value(forKey: "today") as? String ?? "Today"
            }else{
                self.userTimeLabel.text = Utility.shared.getLanguage()?.value(forKey: "yesterday") as? String ?? "Yesterday"
            }
            self.userTimeLabel.text = self.userTimeLabel.text! + " " + Utility.shared.chatTime(stamp: viewList.timestamp)
            
            if blockedStatus == "1"{
                self.userImageView.image = #imageLiteral(resourceName: "profile_placeholder")
            }else if blockedStatus == "0"{
                if privacy_image == "nobody"{
                    self.userImageView.image = #imageLiteral(resourceName: "profile_placeholder")
                }else if privacy_image == "everyone"{
                    self.userImageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else if privacy_image == "mycontacts"{
                    if mutual == "true"{
                        self.userImageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                    }else{
                        self.userImageView.image = #imageLiteral(resourceName: "profile_placeholder")
                    }
                }
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
