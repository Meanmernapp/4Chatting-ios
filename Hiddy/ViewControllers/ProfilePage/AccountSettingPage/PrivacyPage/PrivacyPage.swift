//
//  PrivacyPage.swift
//  Hiddy
//
//  Created by APPLE on 11/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class PrivacyPage: UIViewController,privacyDelegate {

    @IBOutlet var navigationView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var personalTitleLbl: UILabel!
    @IBOutlet var msgTitleLbl: UILabel!
    @IBOutlet var LSTitleLbl: UILabel!
    @IBOutlet var LSStatusLbl: UILabel!
    @IBOutlet var PPTitleLbl: UILabel!
    @IBOutlet var PPStatusLbl: UILabel!
    @IBOutlet var AboutTitleLbl: UILabel!
    @IBOutlet var AboutStatusLbl: UILabel!
    @IBOutlet var blockedLbl: UILabel!
    @IBOutlet var blockedInfoLbl: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var LSTitle: UILabel!
    @IBOutlet weak var listenLbl: UILabel!
    
    @IBOutlet weak var titleForSoon: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func onOffAction(_ sender: UISwitch) {
        UserModel.shared.setListen(Language: sender.isOn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        let listenButton = UserModel.shared.getListen()
        self.onOffSwitch.isOn = listenButton
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        setNeedsStatusBarAppearanceUpdate()
        self.initialSetUp()
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.personalTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.personalTitleLbl.textAlignment = .right
            self.LSStatusLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.LSStatusLbl.textAlignment = .right
            self.LSTitleLbl.textAlignment = .right
            LSTitle.textAlignment = .right
            LSTitle.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.LSTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.PPTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.PPTitleLbl.textAlignment = .right
            self.PPStatusLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.PPStatusLbl.textAlignment = .right
            self.AboutTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.AboutTitleLbl.textAlignment = .right
            self.AboutStatusLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.AboutStatusLbl.textAlignment = .right
            self.blockedLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.blockedLbl.textAlignment = .right
            self.blockedInfoLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.blockedInfoLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.personalTitleLbl.transform = .identity
            self.personalTitleLbl.textAlignment = .left
            self.LSTitleLbl.transform = .identity
            self.LSTitleLbl.textAlignment = .left
            self.LSTitle.transform = .identity
            self.LSTitle.textAlignment = .left
            self.LSStatusLbl.textAlignment = .left
            self.LSStatusLbl.transform = .identity
            self.PPTitleLbl.transform = .identity
            self.PPTitleLbl.textAlignment = .left
            self.AboutTitleLbl.transform = .identity
            self.AboutTitleLbl.textAlignment = .left
            self.PPStatusLbl.transform = .identity
            self.PPStatusLbl.textAlignment = .left
            self.AboutStatusLbl.transform = .identity
            self.AboutStatusLbl.textAlignment = .left
            self.blockedLbl.transform = .identity
            self.blockedLbl.textAlignment = .left
            self.blockedInfoLbl.transform = .identity
            self.blockedInfoLbl.textAlignment = .left
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    //MARK: Initial setup
    func initialSetUp(){
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "privacy")
//        self.titleLbl.frame = CGRect(x: self.titleLbl.frame.origin.x, y: self.titleLbl.frame.origin.y, width: self.titleLbl.frame.width, height: 35)
//        self.navigationView.frame = CGRect(x: self.navigationView.frame.origin.x, y: self.navigationView.frame.origin.y, width: self.navigationView.frame.width, height:70)
        self.personalTitleLbl.config(color: TEXT_SECONDARY_COLOR, size: 20, align: .left, text: "personal_info")
        //self.msgTitleLbl.config(color: TEXT_SECONDARY_COLOR, size: 20, align: .left, text: "messaging")
        
        self.LSTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "last_seen")
//        self.LSTitle.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "listen_speech")
        self.LSTitle.textColor = TEXT_PRIMARY_COLOR
        self.LSTitle.textAlignment = .left
        self.LSTitle.font = UIFont.init(name:APP_FONT_REGULAR, size: 20)
        self.LSStatusLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: UserModel.shared.lastSeen()! as String)

        self.PPTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "profile_pic")
        self.PPStatusLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: UserModel.shared.profilePicPrivacy()! as String)
        // print("profilePicPrivacy \(UserModel.shared.profilePicPrivacy()!)")
        
        self.AboutTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "about")
        self.AboutStatusLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: UserModel.shared.aboutPrivacy()! as String)
        // print("about \(UserModel.shared.aboutPrivacy()!)")
        
        self.blockedLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "blocked_contacts")
        if LocalStorage().getBlockedList().count != 0{
        self.blockedLbl.text = "\(self.blockedLbl.text!) \(LocalStorage().getBlockedList().count)"
        }
        self.blockedInfoLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: "blocked_info")
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func lastSeenBtnTapped(_ sender: Any) {
        let popupObj = ChoosePopup()
        popupObj.viewType = "1"
        popupObj.delegate = self
        popupObj.selection = self.LSStatusLbl.text!
        popupObj.modalPresentationStyle = .overCurrentContext
        popupObj.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popupObj, animated: true, completion: nil)
    }
    
    @IBAction func profilePhotoBtnTapped(_ sender: Any) {
        let popupObj = ChoosePopup()
        popupObj.viewType = "2"
        popupObj.selection = self.PPStatusLbl.text!
        popupObj.delegate = self
        popupObj.modalPresentationStyle = .overCurrentContext
        popupObj.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popupObj, animated: true, completion: nil)
    }
    
    @IBAction func aboutBtnTapped(_ sender: Any) {
        let popupObj = ChoosePopup()
        popupObj.viewType = "3"
        popupObj.selection = self.AboutStatusLbl.text!
        popupObj.delegate = self
        popupObj.modalPresentationStyle = .overCurrentContext
        popupObj.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popupObj, animated: true, completion: nil)
    }
    
    @IBAction func blockedListBtnTapped(_ sender: Any) {
        let blockObj = BlockedListPage()
        self.navigationController?.pushViewController(blockObj, animated: true)
    }
    
    func dismissWithDetails(viewType: String, selection: String) {
        var value = String()
        var key = String()
        key = ""

        if selection == Utility.shared.getLanguage()?.value(forKey: "everyone") as! String {
            value = "everyone"
        }else if selection == Utility.shared.getLanguage()?.value(forKey: "mycontacts") as! String {
            value = "mycontacts"
        }else if selection == Utility.shared.getLanguage()?.value(forKey: "nobody") as! String {
            value = "nobody"
        }
        if viewType == "1" {
            
            self.LSStatusLbl.text = selection
            UserModel.shared.setLastSeen(lastseen: value as NSString)
            key = "privacy_last_seen"
        }else if viewType == "2" {
            self.PPStatusLbl.text = selection
            key = "privacy_profile_image"
            UserModel.shared.setProfilePicPrivacy(picStatus: value as NSString)
        }else if viewType == "3" {
            self.AboutStatusLbl.text = selection
            key = "privacy_about"
            UserModel.shared.setAboutPrivacy(about: value as NSString)
        }
        
        
        let updateObj = UserWebService()
        updateObj.updatePrivacyDetails(onSuccess: {response in
                        let status:NSString = response.value(forKey: "status") as! NSString
                        if status.isEqual(to: STATUS_TRUE){
                            // print("updated")
                        }
        })
        
//        updateObj.updatePrivacyDetails(key:key , value: value, onSuccess: {response in
//            let status:NSString = response.value(forKey: "status") as! NSString
//            if status.isEqual(to: STATUS_TRUE){
//                UserModel.shared.setUserInfo(userDict: response)
//            }
//        })
    }
}
