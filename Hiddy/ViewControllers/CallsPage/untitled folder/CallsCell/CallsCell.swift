//
//  CallsCell.swift
//  Hiddy
//
//  Created by APPLE on 01/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class CallsCell: UITableViewCell {

    @IBOutlet var contactNameLbl: UILabel!
    @IBOutlet var typeImgView: UIImageView!
    @IBOutlet var statusImgView: UIImageView!
    @IBOutlet var contactDP: UIImageView!
    @IBOutlet var separatorLbl: UILabel!
    @IBOutlet var timeLbl: UILabel!
    
    @IBOutlet var makeCall: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contactNameLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: EMPTY_STRING)
        self.timeLbl.config(color: TEXT_SECONDARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.contactDP.rounded()
        self.separatorLbl.backgroundColor = SEPARTOR_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func config(callDict:NSDictionary) {
        
        self.contactNameLbl.frame = CGRect.init(x: 80, y: 25, width: 200, height: 25)
        self.contactDP.frame = CGRect.init(x: 15, y: 25, width: 50, height: 50)
        self.statusImgView.frame = CGRect.init(x: 80, y: self.contactNameLbl.frame.origin.y+self.contactNameLbl.frame.size.height+7, width: 15, height: 15)
        self.timeLbl.frame = CGRect.init(x: 100, y: self.contactNameLbl.frame.origin.y+self.contactNameLbl.frame.size.height+7, width: 200, height: 21)
        
        self.contactNameLbl.text = callDict.value(forKey: "contactName") as? String
        let time:String = callDict.value(forKey: "timestamp") as! String
        let timeString = Utility.shared.chatTime(stamp: time)
        let dateString = Utility.shared.dayDifference(from: time)
        
        /*
         //old
        self.timeLbl.text = "\(dateString) \(timeString)"
        */
        print("dateString:\(dateString)")
        print("timeString:\(timeString)")
        
        if dateString == "Today"{
            self.timeLbl.text = "\(timeString)"
        }else{
            self.timeLbl.text = "\(Utility.shared.chatTimecallspage(stamp: time))"
        }
        
        let imageName:String = callDict.value(forKey: "userImage") as! String
        self.contactDP.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        let type:String = callDict.value(forKey: "call_type") as! String
        if type == "audio"{
            typeImgView.image = #imageLiteral(resourceName: "audiophone")
        }else {
           typeImgView.image = #imageLiteral(resourceName: "videophone")
        }
        let status:String = callDict.value(forKey: "status") as! String
        if status == "outgoing"{
            self.statusImgView.image = #imageLiteral(resourceName: "outgoing")
        }else if status == "missed"{
            self.statusImgView.image = #imageLiteral(resourceName: "missed")
        }else if status == "incoming"{
            self.statusImgView.image = #imageLiteral(resourceName: "incoming")
        }
        
        let privacy_image:String = callDict.value(forKey: "privacy_image") as! String
        let mutual:String = callDict.value(forKey: "mutual_status") as! String
        let blockedStatus:String = callDict.value(forKey: "blockedMe") as! String
        
        if blockedStatus == "1"{
            self.contactDP.image = #imageLiteral(resourceName: "profile_placeholder")
        }else if blockedStatus == "0"{
            if privacy_image == "nobody"{
                self.contactDP.image = #imageLiteral(resourceName: "profile_placeholder")
            }else if privacy_image == "everyone"{
                self.contactDP.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
            }else if privacy_image == "mycontacts"{
                if mutual == "true"{
                    self.contactDP.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
                }else{
                    self.contactDP.image = #imageLiteral(resourceName: "profile_placeholder")
                }
            }
        }
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.contactNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.contactNameLbl.textAlignment = .right
            self.timeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timeLbl.textAlignment = .right
            self.separatorLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.separatorLbl.textAlignment = .right
            for view in self.contentView.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
        }
        else {
            self.contactNameLbl.transform = .identity
            self.contactNameLbl.textAlignment = .left
            self.timeLbl.transform = .identity
            self.timeLbl.textAlignment = .left
            self.separatorLbl.transform = .identity
            self.separatorLbl.textAlignment = .left
            for view in self.contentView.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
        }
        let callObj = CallStorage()
        callObj.callUpdateUnreadCount(call_id: callDict.value(forKey: "call_id") as? String ?? "")
    }
}
