//
//  InfoCell.swift
//  Hiddy
//
//  Created by APPLE on 22/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var labelHeight: NSLayoutConstraint!
    @IBOutlet var infoLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.cornerViewMiniumRadius()
        self.containerView.backgroundColor = UIColor().hexValue(hex: "#DCDCDC")
        self.infoLbl.config(color: UIColor().hexValue(hex: "#9E9D9D")
            , size: 15, align: .center, text: EMPTY_STRING)
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.infoLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.infoLbl.transform = .identity
        }

    }
    override func layoutSubviews() {
////        self.containerView.applyGradient()
//        self.containerView.bringSubviewToFront(self.infoLbl)
//        let size = HPLActivityHUD.getExactLabelSize(self.infoLbl.text, withFont: APP_FONT_REGULAR, andSize: 15)
//        self.infoLbl.numberOfLines = 0
//        let orgin = FULL_WIDTH - size.width
//        self.containerView.frame = CGRect.init(x: orgin/2-20, y: 10, width: size.width+40, height: size.height+10)
//        self.infoLbl.frame = CGRect.init(x: 10, y: 7, width: self.containerView.frame.size.width-20, height: size.height)
//        self.containerView.cornerViewRadius()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func config(model:groupMsgModel.message)  {
//        let groupDB = groupStorage()
//        let groupDict = groupDB.getGroupInfo(group_id: model.group_id)
        if model.message_type == "create_group"{
            if model.admin_id == "\(UserModel.shared.userID()!)"{ // group created
                self.infoLbl.text = "\((Utility().getLanguage()?.value(forKey: "you_created_group"))!) \"\(model.message)\""
            }else{
                self.infoLbl.text = "\(Utility.shared.getUsername(user_id: model.admin_id)) \((Utility().getLanguage()?.value(forKey: "crated_group"))!) \"\(model.message)\""
            }
        }else if model.message_type == "user_added"{  //user added
            self.infoLbl.text = "\(Utility.shared.getUsername(user_id: model.admin_id)) \((Utility().getLanguage()?.value(forKey: "added_you"))!)"
        }else if model.message_type == "left"{ // member exited
            if model.member_id == "\(UserModel.shared.userID()!)"{
                self.infoLbl.text = Utility().getLanguage()?.value(forKey: "you_left") as? String
            }else{
                self.infoLbl.text = "\(Utility.shared.getUsername(user_id: model.member_id)) \((Utility().getLanguage()?.value(forKey: "left"))!)"
            }
        }else if model.message_type == "group_image"{// group icon changed
            if model.member_id == "\(UserModel.shared.userID()!)"{
                self.infoLbl.text = Utility().getLanguage()?.value(forKey: "you_changed_group_icon") as? String
            }else{
                self.infoLbl.text = "\(Utility.shared.getUsername(user_id: model.member_id)) \((Utility().getLanguage()?.value(forKey: "group_icon_changed"))!)"
            }
        }else if model.message_type == "subject"{// group icon changed
            if model.member_id == "\(UserModel.shared.userID()!)"{
                self.infoLbl.text = "\((Utility().getLanguage()?.value(forKey: "you"))!) \(model.message)"
            }else{
                self.infoLbl.text = "\(Utility.shared.getUsername(user_id: model.member_id)) \(model.message)"
            }
        }else if model.message_type == "add_member"{
            let names  = Utility.shared.getNames(membersStr: model.attachment)

            if model.admin_id == "\(UserModel.shared.userID()!)"{
                self.infoLbl.text = "\((Utility().getLanguage()?.value(forKey: "you_group_added"))!) \(names)"
            }else{
                self.infoLbl.text = "\(Utility.shared.getUsername(user_id: model.admin_id)) \((Utility().getLanguage()?.value(forKey: "added"))!) \(names)"
            }
        }else if model.message_type == "admin"{
            if model.member_id == "\(UserModel.shared.userID()!)"{
                if model.attachment == "1"{
                    self.infoLbl.text = Utility().getLanguage()?.value(forKey: "you_are_admin") as? String
                }else{
                    self.infoLbl.text = Utility().getLanguage()?.value(forKey: "no_longer_admin") as? String
                }
            }
        }else if model.message_type == "remove_member"{
            if model.admin_id == "\(UserModel.shared.userID()!)"{
                self.infoLbl.text = "\((Utility().getLanguage()?.value(forKey: "you_removed"))!) \((Utility.shared.getUsername(user_id: model.member_id)))"
            }else if model.member_id == "\(UserModel.shared.userID()!)"{
                self.infoLbl.text = "\((Utility.shared.getUsername(user_id: model.admin_id))) \((Utility().getLanguage()?.value(forKey: "removed_you"))!)"
            }else {
                self.infoLbl.text = "\((Utility.shared.getUsername(user_id: model.admin_id))) \((Utility().getLanguage()?.value(forKey: "removed"))!) \((Utility.shared.getUsername(user_id: model.member_id)))"
            }
        }else if model.message_type == "change_number"{
            // print("model \(model)")
            if model.member_id == "\(UserModel.shared.userID()!)"{
                self.infoLbl.text = Utility().getLanguage()?.value(forKey: "changed_new_no") as? String
            }else {
                var old_no_name = Utility.shared.searchPhoneNoAvailability(phoneNo: model.attachment)
                var new_no_name = Utility.shared.searchPhoneNoAvailability(phoneNo: model.contact_no)
                if old_no_name == EMPTY_STRING{
                    old_no_name = model.attachment
                }
                if new_no_name == EMPTY_STRING{
                    new_no_name = model.contact_no
                }
                self.infoLbl.text = "\(old_no_name) \(model.message)"
            }
        }
        self.labelHeight.constant = heightForView(text: self.infoLbl.text!, font: UIFont.init(name:APP_FONT_REGULAR, size: 15)!, isDelete: 0).height//        self.layoutSubviews()
    }
    
    func configChannel(model:channelMsgModel.message)  {
        if model.message_type == "added" {
            self.infoLbl.text = Utility().getLanguage()?.value(forKey: "you_added_channel") as? String
        }else if model.message_type == "subject"{
            self.infoLbl.text = Utility().getLanguage()?.value(forKey: "subject_changed") as? String
        }else if model.message_type == "channel_image"{
            self.infoLbl.text = Utility().getLanguage()?.value(forKey: "channel_icon_changed") as? String
        }else if model.message_type == "channel_des"{
            self.infoLbl.text = Utility().getLanguage()?.value(forKey: "description_changed") as? String
        }
        self.labelHeight.constant = heightForView(text: self.infoLbl.text!, font: UIFont.init(name:APP_FONT_REGULAR, size: 15)!, isDelete: 0).height//        self.layoutSubviews()
    }
    func heightForView(text:String, font:UIFont, isDelete: CGFloat) -> CGRect {
        let width = (self.frame.width * 0.8) - isDelete
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame
    }

}
