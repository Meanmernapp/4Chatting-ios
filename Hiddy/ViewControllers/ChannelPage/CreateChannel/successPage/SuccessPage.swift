//
//  SuccessPage.swift
//  Hiddy
//
//  Created by APPLE on 06/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class SuccessPage: UIViewController {
    @IBOutlet var channelDP: UIImageView!
    @IBOutlet var backArrowImgView: UIImageView!
    @IBOutlet var successLbl: UILabel!
    @IBOutlet var desLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    
    @IBOutlet var acceptBtn: UIButton!
    @IBOutlet var denyBtn: UIButton!
    
    @IBOutlet var btnView: UIView!
    var detailsDict = NSDictionary()
    var viewType = String()
    var channelDB = ChannelStorage()
    var channel_id = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
        self.changeRTL()
    }
    func changeRTL() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.desLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.successLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.acceptBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.denyBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.titleLbl.transform = .identity
            self.desLbl.transform = .identity
            self.successLbl.transform = .identity
            self.acceptBtn.transform = .identity
            self.denyBtn.transform = .identity
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        self.acceptBtn.applyGradient()
        self.acceptBtn.bringSubviewToFront(self.acceptBtn.titleLabel!)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func heightForView(text:String, font:UIFont, isDelete: CGFloat) -> CGRect {
        let width = (self.view.frame.width * 0.8) - isDelete
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame
    }

    func initialSetup()  {
        self.channelDP.rounded()
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: EMPTY_STRING)
        self.desLbl.config(color: TEXT_TERTIARY_COLOR, size: 20, align: .center, text: EMPTY_STRING)
        self.successLbl.config(color: SECONDARY_COLOR, size: 20, align: .center, text: EMPTY_STRING)

        self.desLbl.numberOfLines = 0
        let description =  self.detailsDict.value(forKey: "channel_des") as? String
        self.desLbl.text = description
        if self.detailsDict.value(forKey: "channel_image") != nil{
        let imageName:String = self.detailsDict.value(forKey: "channel_image") as! String
        self.channelDP.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        self.acceptBtn.cornerRoundRadius()
        self.denyBtn.cornerRoundRadius()
        self.denyBtn.config(color: .white, size: 20, align: .center, title: "cancel")
        self.denyBtn.backgroundColor = .lightGray
        let size =  self.heightForView(text: description!, font: UIFont.init(name:APP_FONT_REGULAR, size: 20)!, isDelete: 0)

//        let size = HPLActivityHUD.getExactSize(description, withFont: APP_FONT_REGULAR, andSize: 20)
        self.desLbl.frame = CGRect.init(x: 20, y: self.titleLbl.frame.size.height+self.titleLbl.frame.origin.y+5, width: FULL_WIDTH-40, height: size.height)

        self.btnView.frame = CGRect.init(x: 0, y: self.desLbl.frame.size.height+self.desLbl.frame.origin.y+5, width: FULL_WIDTH, height: 45)

        if viewType == "1" {
            self.getChatDetails(_id:self.detailsDict.value(forKey: "channel_id") as? String ?? "")
            self.acceptBtn.config(color: .white, size: 20, align: .center, title: "join")
            self.successLbl.text = self.detailsDict.value(forKey: "channel_name") as? String
            self.titleLbl.text = "\((self.detailsDict.value(forKey: "subscriber_count"))!) \((Utility.shared.getLanguage()?.value(forKey:"subscribers"))!)"
        }else{
            self.successLbl.text = Utility.shared.getLanguage()?.value(forKey:"channel_success") as? String
            self.titleLbl.text = self.detailsDict.value(forKey: "channel_name") as? String
            self.acceptBtn.config(color: .white, size: 20, align: .center, title: "invite_sub")
            self.denyBtn.isHidden = true
            
            let padding = FULL_WIDTH - 220
            self.acceptBtn.frame = CGRect.init(x:padding/2 , y: 2, width: 220, height: 50)
            self.acceptBtn.cornerRoundRadius()
        }
    }
    
    func getChatDetails(_id:String)  {
        let channelObj = ChannelServices()
        channelObj.channelInfo(channelList: [_id], onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let channelArray:NSArray = response.value(forKey: "result") as! NSArray
                for channel in channelArray{
                    let detailDict:NSDictionary = channel as! NSDictionary
                    let totalCount:NSNumber = detailDict.value(forKey: "total_subscribers") as! NSNumber
                    self.titleLbl.text = "\(totalCount) \((Utility.shared.getLanguage()?.value(forKey:"subscribers"))!)"
                }
            }
        })
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if viewType == "2"{
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of:MyChannelList.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }else if viewType == "3"{
            if UserModel.shared.navType() == "1"{
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of:MyChannelList.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
            }else{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of:menuContainerPage.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func joinBtnTapped(_ sender: Any) {
        if viewType == "1" {
            
            let adminID = self.detailsDict.value(forKey: "channel_admin_id") as? String ?? ""
            
            let userDict:NSDictionary = LocalStorage().getContact(contact_id: adminID)
            let blockedMe = userDict.value(forKey: "blockedByMe") as? String ?? "0"
            
            if blockedMe == "0"{
                let channelId = self.detailsDict.value(forKey: "channel_id") as? String ?? ""
                if !UserModel.shared.channelIDs().contains(channelId){
                    channelSocket.sharedInstance.channelsForYou(channel_id: channelId, detailDict: self.detailsDict, status: "1")
                }
                channelSocket.sharedInstance.addInitialMsg(channel_id: channelId)
                channelDB.updateSubscribtion(channel_id: channelId,status:"1")
                channelSocket.sharedInstance.subscribe(channel_id: channelId)
                UserModel.shared.setNavType(type: "2")

                let detailObj = ChannelChatPage()
                detailObj.channel_id = self.detailsDict.value(forKey: "channel_id") as! String
                detailObj.viewType = "2"
                self.navigationController?.pushViewController(detailObj, animated: true)
            }
            else {
                let contact_name = userDict.value(forKey: "contact_name") as! String
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "could_not_add"))!) \(contact_name)")
            }
        }else{
            let addMemberObj = addChannelMembers()
            addMemberObj.channel_id = self.channel_id
            self.navigationController?.pushViewController(addMemberObj, animated: true)
        }
    }

    @IBAction func cancelBtnTapped(_ sender: Any) {
        if viewType == "1" {
            channelDB.deleteChannel(channel_id:self.detailsDict.value(forKey: "channel_id") as! String )
        }
        self.navigationController?.popViewController(animated: true)
    }
}
