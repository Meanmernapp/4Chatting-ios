//
//  ProfileHeaderPage.swift
//  Hiddy
//
//  Created by APPLE on 25/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import GSImageViewerController
import AVKit

class ProfileHeaderPage: UIViewController,UIScrollViewDelegate,alertDelegate {
    
    @IBOutlet weak var detailVideoImgView: UIImageView!
    @IBOutlet weak var detailMsgImgView: UIImageView!
    @IBOutlet weak var detailedAudioImgView: UIImageView!
    @IBOutlet weak var edit_icon: UIImageView!
    @IBOutlet weak var encryptionContentLabel: UILabel!
    @IBOutlet weak var encryptionTitleLabel: UILabel!
    @IBOutlet weak var encryptionView: UIView!
    @IBOutlet var profileImgView: UIImageView!
    @IBOutlet var contentViewHeight: NSLayoutConstraint!
    @IBOutlet var headerImageViewHeight: NSLayoutConstraint!
    @IBOutlet var bottomViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var bottomScroll: UIScrollView!
    @IBOutlet var topScroll: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var topContainerView: UIView!
    @IBOutlet var transparentPic: UIImageView!
    @IBOutlet var navigationView: UIView!
    
    
    // MediaView
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaCountLabel: UILabel!
    @IBOutlet weak var forwardArrowIcon: UIImageView!
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    var scrollDirectionValue = Float()
    var yoffset = Float()
    var alphaValue = CGFloat()
    var type = String()
    var backType = String()
    var user_id = String()
    var blockedType = String()
    var privacy_about = String()
    var mutual = String()
    let localObj = LocalStorage()
    let callDB = CallStorage()
    var mediaDict = NSArray()
    
    
    @IBOutlet var editIcon: UIImageView!
    @IBOutlet var backIcon: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var aboutTxtView: UILabel!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var muteNotficationLbl: UILabel!
    @IBOutlet var otherProfileView: UIView!
    @IBOutlet var phoneNoLbl: UILabel!
    @IBOutlet var muteSwitch: UISwitch!
    @IBOutlet var muteView: UIView!
    @IBOutlet weak var mobileLblPlaceHolder: UILabel!
    @IBOutlet weak var aboutLblPlaceHolder: UILabel!
    @IBOutlet weak var muteViewTopLbl: UILabel!
    @IBOutlet weak var nameLblBottomLbl: UILabel!
    @IBOutlet weak var aboutTextBottomLbl: UILabel!
    var chat_ID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configParallaxView()
        self.mediaCollectionView.delegate = self
        self.mediaCollectionView.dataSource = self
        self.mediaCollectionView.register(UINib(nibName: "profileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profileCollectionViewCell")
        self.mediaCountLabel.isUserInteractionEnabled = true
        self.mediaCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.mediaCountButtonAct)))
        self.forwardArrowIcon.isUserInteractionEnabled = true
        self.forwardArrowIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.mediaCountButtonAct)))
        //        UIApplication.shared.isStatusBarHidden = true
        
    }
    @objc func mediaCountButtonAct() {
        let vc = MediaDetailsViewController()
        vc.mediaDict = self.mediaDict
        vc.chatType = "single"
        vc.chat_id = self.chat_ID
        vc.image = self.profileImgView.image ?? #imageLiteral(resourceName: "profile_popup_bg")
        vc.userName = self.nameLbl.text!
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            self.topScroll.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        self.updateTheme()
        self.topContainerView.backgroundColor = BACKGROUND_COLOR
        self.contentView.backgroundColor = BACKGROUND_COLOR
        self.changeRTLView()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    func changeRTLView() {
        
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.aboutTxtView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutTxtView.textAlignment = .right
            self.muteNotficationLbl.textAlignment = .right
            self.muteNotficationLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.phoneNoLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.phoneNoLbl.textAlignment = .right
            self.mobileLblPlaceHolder.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mobileLblPlaceHolder.textAlignment = .right
            self.aboutLblPlaceHolder.textAlignment = .right
            self.aboutLblPlaceHolder.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteViewTopLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteViewTopLbl.textAlignment = .right
            self.nameLblBottomLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLblBottomLbl.textAlignment = .right
            self.mediaTitleLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mediaTitleLabel.textAlignment = .right
            self.mediaCountLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mediaCountLabel.textAlignment = .left
            self.aboutTextBottomLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutTextBottomLbl.textAlignment = .right
            self.edit_icon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.profileImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.detailedAudioImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.detailMsgImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.detailVideoImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.nameLbl.transform = .identity
            self.nameLbl.textAlignment = .left
            self.aboutTxtView.transform = .identity
            self.aboutTxtView.textAlignment = .left
            self.muteNotficationLbl.textAlignment = .left
            self.muteNotficationLbl.transform = .identity
            self.phoneNoLbl.transform = .identity
            self.phoneNoLbl.textAlignment = .left
            self.mobileLblPlaceHolder.transform = .identity
            self.mobileLblPlaceHolder.textAlignment = .left
            self.aboutLblPlaceHolder.textAlignment = .left
            self.aboutLblPlaceHolder.transform = .identity
            self.muteViewTopLbl.transform = .identity
            self.muteViewTopLbl.textAlignment = .left
            self.nameLblBottomLbl.transform = .identity
            self.nameLblBottomLbl.textAlignment = .left
            self.mediaTitleLabel.transform = .identity
            self.mediaTitleLabel.textAlignment = .left
            self.mediaCountLabel.transform = .identity
            self.mediaCountLabel.textAlignment = .right
            self.aboutTextBottomLbl.transform = .identity
            self.aboutTextBottomLbl.textAlignment = .left
            self.edit_icon.transform = .identity
            self.profileImgView.transform = .identity
            self.detailedAudioImgView.transform = .identity
            self.detailMsgImgView.transform = .identity
            self.detailVideoImgView.transform = .identity
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //        UIApplication.shared.isStatusBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initialSetup(type:String,id:String,exit:String){
        
        self.type = type
        self.user_id = id
        self.backType = exit
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 30, align: .left, text: EMPTY_STRING)
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        self.phoneNoLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        self.mobileLblPlaceHolder.config(color: TEXT_TERTIARY_COLOR, size:22 , align: .left, text: "mobile")
        self.aboutLblPlaceHolder.config(color: TEXT_PRIMARY_COLOR, size:22 , align: .left, text: "about")
        //        mediaTitleLabel.config(color: TEXT_PRIMARY_COLOR, size:22 , align: .left, text: "Media")
        self.contentView.frame = CGRect.init(x: 0, y: headerImageViewHeight.constant - 50, width: FULL_WIDTH, height: FULL_HEIGHT)
        self.contentView.specificCornerRadius(radius: 20)
        self.titleLbl.isHidden =  true
        
        self.encryptionTitleLabel.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "encryption_title")
        self.encryptionContentLabel.config(color: TEXT_PRIMARY_COLOR, size: 16, align: .left, text: "encryption_content")
        
        self.mediaTitleLabel.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "media_title")
        self.mediaCountLabel.config(color: TEXT_PRIMARY_COLOR, size: 16, align: .left, text: "view_all")
        
        
        if IS_IPHONE_PLUS && UIScreen.main.nativeBounds.width != 1080.0{
            self.editBtn.frame = CGRect.init(x: FULL_WIDTH-50, y: self.backBtn.frame.origin.y, width: 38, height: 38)
            self.editIcon.frame = CGRect.init(x: self.editBtn.frame.origin.x+16, y: self.editBtn.frame.origin.y+9, width: 10, height: 20)
        }
        else {
            //            self.editBtn.frame = CGRect.init(x: FULL_WIDTH-50, y: self.backBtn.frame.origin.y, width: 38, height: 38)
            //            self.editIcon.frame = CGRect.init(x: self.editBtn.frame.origin.x+16, y: self.editBtn.frame.origin.y+9, width: 10, height: 20)
        }
        
        if type != "own"{
            let localObj = LocalStorage()
            let userDict = localObj.getContact(contact_id: self.user_id)
            let muteStatus:String = userDict.value(forKey: "mute") as! String
            blockedType = userDict.value(forKey: "blockedMe") as! String
            privacy_about = userDict.value(forKey: "privacy_about") as! String
            self.nameLbl.text = userDict.value(forKey: "contact_name") as? String
            self.titleLbl.text = userDict.value(forKey: "contact_name") as? String
            let cc = (userDict.value(forKey: "countrycode") as? String ?? "")
            let mobileNo = (userDict.value(forKey: "user_phoneno") as? String ?? "")
            self.phoneNoLbl.text = "+" + cc + " " + mobileNo
            mutual = userDict.value(forKey: "mutual_status") as! String
            
            if muteStatus == "0" {
                self.muteSwitch.isOn = false
                muteSwitch.thumbTintColor = UIColor().hexValue(hex: "EEE5E8")
                muteSwitch.onTintColor = UIColor().hexValue(hex: "A6A1A5")
            }else{
                self.muteSwitch.isOn = true
                muteSwitch.thumbTintColor = SECONDARY_COLOR
                muteSwitch.onTintColor = UIColor().hexValue(hex: "#D2ACF4")
            }
            
            self.muteNotficationLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "mute_notification")
            self.setDesign(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height)
            self.editIcon.image = #imageLiteral(resourceName: "chat_menu")
            self.editIcon.contentMode = .scaleAspectFit
        }else{
            self.editIcon.image = #imageLiteral(resourceName: "edit_white")
            self.editIcon.contentMode = .scaleAspectFill
            
        }
        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
        self.editIcon.tintColor = .white
        self.changeRTLView()
    }
    override func viewDidLayoutSubviews() {
        //        self.aboutTxtView.sizeToFit()
        aboutTxtView.frame.size.width = FULL_WIDTH-40
        aboutTxtView.frame.size = aboutTxtView.bounds.size
        self.view.bounds = self.parent?.view.bounds ?? UIScreen.main.bounds
    }
    //configure parallax view
    func configParallaxView()  {
        let newView = Bundle.main.loadNibNamed("ParallaxViewController", owner: self, options: nil)?[0] as? UIView
        newView?.frame = self.view.bounds
        //for iPhone5 & 5S
        if IS_IPHONE_5{
            newView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width+55, height: UIScreen.main.bounds.size.height+100)
        }
        if let aView = newView {
            self.view.insertSubview(aView, at: 0)
        }
        if responds(to: #selector(getter: self.edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }
        bottomScroll.delegate = self
        
        
        if UIDevice.current.hasNotch{
            headerImageViewHeight.constant = FULL_HEIGHT - 100 //225
        }else if IS_IPHONE_PLUS{
            headerImageViewHeight.constant = FULL_HEIGHT - 90 // 150
        }else{
            headerImageViewHeight.constant = FULL_HEIGHT - 60 //100
        }
        self.contentView.frame = CGRect.init(x: 0, y: headerImageViewHeight.constant - 50, width: FULL_WIDTH, height: FULL_HEIGHT)
        self.changeRTLView()
    }
    
    @IBAction func viewFullImgAction(_ sender: Any) {
        let localObj = LocalStorage()
        let profileDict = localObj.getContact(contact_id: self.user_id)
        let privacy_image:String? = profileDict.value(forKey: "privacy_image") as? String
        let mutual:String? = profileDict.value(forKey: "mutual_status") as? String
        
        let imageInfo = GSImageInfo.init(image: profileImgView.image!, imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: self.view)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        if blockedType != "1"{
            if privacy_image == "everyone"{
                self.present(imageViewer, animated: true, completion: nil)
            }else if privacy_image == "mycontacts"{
                if mutual == "true"{
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }
        }
        if self.type == "own"{
            self.present(imageViewer, animated: true, completion: nil)
        }
        
    }
    
    
    func adjustContentViewHeight() {
        bottomViewTopConstraint.constant = (headerImageViewHeight.constant - 80) //(self.view.frame.height / 3))
        let height = FULL_HEIGHT - bottomViewTopConstraint.constant
        if UIDevice.current.hasNotch{
            contentViewHeight.constant = UIScreen.main.bounds.size.height+height - 80//UIScreen.main.bounds.size.height+height
        }else if IS_IPHONE_PLUS{
            contentViewHeight.constant = UIScreen.main.bounds.size.height+height - 35//UIScreen.main.bounds.size.height+height
        }else{
            contentViewHeight.constant = UIScreen.main.bounds.size.height+height //UIScreen.main.bounds.size.height+height
        }
        
        
        
    }
    // MARK: UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGFloat = scrollView.contentOffset.y
        let percentage: CGFloat = offset / headerImageViewHeight.constant
        let value: CGFloat = headerImageViewHeight.constant * percentage
        // negative when scrolling up more than the top
        alphaValue = CGFloat(abs(Float(percentage)))
        scrollDirectionValue = Float(value)
        if percentage < 0.00 {
            bottomScroll.contentOffset = CGPoint(x: 0, y: 0)
        } else { // scroll to up
            yoffset = Float(bottomScroll.contentOffset.y * 0.3)
            //for iPhone5 & 5S
            if IS_IPHONE_5{
                if yoffset > 120{
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                        self.transparentPic.isHidden = true
                        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.editIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.backIcon.image = self.backIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.backIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.navigationView.backgroundColor = BACKGROUND_COLOR
                        self.navigationView.elevationEffect()
                        self.setDesignNavigtn(topHeight: self.navigationView.frame.origin.y+self.navigationView.frame.size.height+25)
                        self.titleLbl.isHidden = false
                        self.nameLbl.isHidden = true
                    }, completion: nil)
                }else{// scroll to down
                    if yoffset > 110{
                        self.contentView.removeCornerRadius()
                        //// print("Scrolled above 110")
                    }else{
                        self.contentView.viewRadius(radius: 25)
                        //// print("Scrolled below 110")
                    }
                    self.setDesignScroll(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height)
                    
                    self.titleLbl.isHidden = true
                    self.nameLbl.isHidden = false
                    self.transparentPic.isHidden = false
                    self.editIcon.tintColor = .white
                    self.backIcon.tintColor = .white
                    self.navigationView.backgroundColor = .clear
                }
            }else {
                //for other iPhones
                if yoffset > 120 {
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                        self.transparentPic.isHidden = true
                        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.editIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.backIcon.image = self.backIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.backIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.navigationView.backgroundColor = BACKGROUND_COLOR
                        self.navigationView.elevationEffect()
                        
                        self.setDesignNavigtn(topHeight: self.navigationView.frame.origin.y+self.navigationView.frame.size.height+5)
                        self.titleLbl.isHidden = false
                        self.nameLbl.isHidden = true
                    }, completion: nil)
                }else{// scroll to down
                    if yoffset > 110{
                        self.contentView.removeCornerRadius()
                        //// print("Scrolled above 110")
                    }else{
                        self.contentView.viewRadius(radius: 25)
                        //// print("Scrolled below 110")
                    }
                    self.setDesignScroll(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height)
                    
                    self.titleLbl.isHidden = true
                    self.nameLbl.isHidden = false
                    self.transparentPic.isHidden = false
                    self.editIcon.tintColor = .white
                    self.backIcon.tintColor = .white
                    self.navigationView.backgroundColor = .clear
                }
            }
            topScroll.setContentOffset(CGPoint(x: topScroll.contentOffset.x, y: CGFloat(yoffset)), animated: false)
        }
        self.changeRTLView()
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
    
    func setDesign(topHeight:CGFloat)  {
        //        let size =  HPLActivityHUD.getExactLabelSize(self.aboutTxtView.text, withFont: APP_FONT_REGULAR, andSize: 25)
        let size =  self.heightForView(text: self.aboutTxtView.text!, font: UIFont.init(name:APP_FONT_REGULAR, size: 20)!, isDelete: 0)
        
        if self.type != "own"{
            self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: FULL_WIDTH-40, height: 50)
            if blockedType == "1"{
                self.nameLbl.frame = CGRect.init(x: 20, y: 20, width: FULL_WIDTH-80, height: 30)
                self.aboutTxtView.isHidden = true
                self.aboutLblPlaceHolder.isHidden = true
                self.muteViewTopLbl.isHidden = true
                self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-5, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-69, width: FULL_WIDTH-40, height: 50)
                self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-80, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-41, width: self.muteSwitch.bounds.size.width, height: 50)
                
                //                self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                if self.mediaDict.count == 0 {
                    self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                    self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH - 40, height: 47)
                    self.mediaView.isHidden = true
                }
                else {
                    self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH , height: 140)
                    self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 47)
                    self.mediaCollectionView.isHidden = false
                    
                }
                self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                
                self.nameLblBottomLbl.isHidden = true
                self.aboutTextBottomLbl.isHidden = true
            }else{
                
                //privacy last seen
                if privacy_about == "nobody"{
                    self.nameLbl.frame = CGRect.init(x: 20, y: 20, width: FULL_WIDTH-80, height: 30)
                    self.aboutTxtView.isHidden = true
                    self.aboutLblPlaceHolder.isHidden = true
                    self.muteViewTopLbl.isHidden = true
                    self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-5, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                    self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-69, width: FULL_WIDTH-40, height: 50)
                    self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-80, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-41, width: self.muteSwitch.bounds.size.width, height: 50)
                    if self.mediaDict.count == 0 {
                        
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH , height: 0)
                        self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH - 40, height: 47)
                        
                        self.mediaView.isHidden = true
                        
                    }
                    else {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH , height: 140)
                        self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+30, width: FULL_WIDTH - 40, height: 47)
                        self.mediaCollectionView.isHidden = false
                        
                    }
                    self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                    
                    self.nameLblBottomLbl.isHidden = true
                    self.aboutTextBottomLbl.isHidden = true
                }else if privacy_about == "everyone"{
                    self.nameLbl.frame = CGRect.init(x: 20, y: 20, width: FULL_WIDTH-80, height: 30)
                    self.aboutTxtView.isHidden = false
                    self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-5, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                    self.aboutTxtView.sizeToFit()
                    self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight+100, width: FULL_WIDTH-40, height: 23)
                    self.aboutTxtView.frame = CGRect.init(x: 20, y: self.aboutLblPlaceHolder.frame.origin.y+self.aboutLblPlaceHolder.frame.size.height+5, width: FULL_WIDTH-40, height: size.height)
                    if self.mediaDict.count == 0 {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                        self.muteView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH - 40, height: 67)
                        
                        self.mediaView.isHidden = true
                        
                    }
                    else {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH, height: 140)
                        self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+30, width: FULL_WIDTH - 40, height: 67)
                        self.mediaCollectionView.isHidden = false
                        
                    }
                    self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                    
                    self.nameLblBottomLbl.isHidden = true
                    self.aboutTextBottomLbl.isHidden = true
                }else if privacy_about == "mycontacts"{
                    if mutual == "true"{
                        self.nameLbl.frame = CGRect.init(x: 20, y: 20, width: FULL_WIDTH-80, height: 30)
                        self.aboutTxtView.isHidden = false
                        self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-5, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                        self.aboutTxtView.sizeToFit()
                        self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight+100, width: FULL_WIDTH-40, height: 23)
                        self.aboutTxtView.frame = CGRect.init(x: 20, y: self.aboutLblPlaceHolder.frame.origin.y+self.aboutLblPlaceHolder.frame.size.height+5, width: FULL_WIDTH-40, height: size.height)
                        if self.mediaDict.count == 0 {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                            self.muteView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH - 40, height: 67)
                            
                            self.mediaView.isHidden = true
                            
                        }
                        else {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH, height: 140)
                            self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+30, width: FULL_WIDTH - 40, height: 67)
                            self.mediaCollectionView.isHidden = false
                            
                        }
                        self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                        
                        self.nameLblBottomLbl.isHidden = true
                        self.aboutTextBottomLbl.isHidden = true
                    }else{
                        self.nameLbl.frame = CGRect.init(x: 20, y: 20, width: FULL_WIDTH-80, height: 30)
                        self.aboutTxtView.isHidden = true
                        self.aboutLblPlaceHolder.isHidden = true
                        self.muteViewTopLbl.isHidden = true
                        self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-5, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                        self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-69, width: FULL_WIDTH-40, height: 50)
                        self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-80, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-41, width: self.muteSwitch.bounds.size.width, height: 50)
                        if self.mediaDict.count == 0 {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                            self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH - 40, height: 47)
                            
                            self.mediaView.isHidden = true
                            
                        }
                        else {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 140)
                            self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+30, width: FULL_WIDTH - 40, height: 47)
                            self.mediaCollectionView.isHidden = false
                            
                        }
                        self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                        
                        self.nameLblBottomLbl.isHidden = true
                        self.aboutTextBottomLbl.isHidden = true
                    }
                }
            }
            self.mediaView.isHidden = false
            
        }else if self.type == "own"{
            self.nameLbl.frame = CGRect.init(x: 20, y: 25, width: FULL_WIDTH-40, height: 30)
            self.nameLblBottomLbl.frame = CGRect.init(x: 0, y: 80, width: FULL_WIDTH, height: 1)
            self.aboutTxtView.sizeToFit()
            self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: 105, width: FULL_WIDTH-40, height: 23)
            self.aboutTxtView.frame = CGRect.init(x: 20, y: 150, width: FULL_WIDTH-40, height: size.height)
            self.aboutTextBottomLbl.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+15, width: FULL_WIDTH, height: 1)
            self.aboutTextBottomLbl.isHidden = false
            self.encryptionView.isHidden = true
            self.mediaView.isHidden = true
        }
        self.changeRTLView()
    }
    func setDesignNavigtn(topHeight:CGFloat)  {
        //        let size =  HPLActivityHUD.getExactLabelSize(self.aboutTxtView.text, withFont: APP_FONT_REGULAR, andSize: 25)
        if self.type != "own"{
            self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: FULL_WIDTH-40, height: 50)
            if blockedType == "1"{
                self.aboutTxtView.isHidden = true
                self.aboutLblPlaceHolder.isHidden = true
                self.muteViewTopLbl.isHidden = true
                self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-28, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-73, width: FULL_WIDTH-40, height: 50)
                self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-40, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-41, width: self.muteSwitch.bounds.size.width, height: 50)
                if self.mediaDict.count == 0 {
                    self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                    self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH - 40, height: 47)
                    
                    self.mediaView.isHidden = true
                    
                }
                else {
                    self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH, height: 140)
                    self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+22, width: FULL_WIDTH - 40, height: 47)
                    self.mediaCollectionView.isHidden = false
                    
                }
                self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                
                self.nameLblBottomLbl.isHidden = true
                self.aboutTextBottomLbl.isHidden = true
            }else{
                
                //privacy last seen
                if privacy_about == "nobody"{
                    self.aboutTxtView.isHidden = true
                    self.aboutLblPlaceHolder.isHidden = true
                    self.muteViewTopLbl.isHidden = true
                    self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-28, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                    self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-73, width: FULL_WIDTH-40, height: 50)
                    self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-40, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-41, width: self.muteSwitch.bounds.size.width, height: 50)
                    if self.mediaDict.count == 0 {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH - 40, height: 0)
                        self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH , height: 47)
                        
                        self.mediaView.isHidden = true
                        
                    }
                    else {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH, height: 140)
                        self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+22, width: FULL_WIDTH - 40, height: 47)
                        self.mediaCollectionView.isHidden = false
                        
                    }
                    self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                    
                    self.nameLblBottomLbl.isHidden = true
                    self.aboutTextBottomLbl.isHidden = true
                }else if privacy_about == "everyone"{
                    self.aboutTxtView.isHidden = false
                    self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-28, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                    self.aboutTxtView.sizeToFit()
                    self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight+67, width: FULL_WIDTH-40, height: 23)
                    self.aboutTxtView.frame = CGRect.init(x: 20, y: topHeight+93, width: self.aboutTxtView.frame.size.width, height: self.aboutTxtView.frame.size.height)
                    if self.mediaDict.count == 0 {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                        self.muteView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+14, width: FULL_WIDTH - 40, height: 67)
                        
                        self.mediaView.isHidden = true
                        
                    }
                    else {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+14, width: FULL_WIDTH, height: 140)
                        self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 67)
                        self.mediaCollectionView.isHidden = false
                        
                    }
                    self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                    
                    self.nameLblBottomLbl.isHidden = true
                    self.aboutTextBottomLbl.isHidden = true
                }else if privacy_about == "mycontacts"{
                    if mutual == "true"{
                        self.aboutTxtView.isHidden = false
                        self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-28, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                        self.aboutTxtView.sizeToFit()
                        self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight+67, width: FULL_WIDTH-40, height: 23)
                        self.aboutTxtView.frame = CGRect.init(x: 20, y: topHeight+93, width: self.aboutTxtView.frame.size.width, height: self.aboutTxtView.frame.size.height)
                        if self.mediaDict.count == 0 {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                            self.muteView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+14, width: FULL_WIDTH - 40, height: 67)
                            
                            self.mediaView.isHidden = true
                            
                        }
                        else {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+14, width: FULL_WIDTH, height: 140)
                            self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 67)
                            self.mediaCollectionView.isHidden = false
                            
                        }
                        self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                        
                        
                        self.nameLblBottomLbl.isHidden = true
                        self.aboutTextBottomLbl.isHidden = true
                    }else{
                        self.aboutTxtView.isHidden = true
                        self.aboutLblPlaceHolder.isHidden = true
                        self.muteViewTopLbl.isHidden = true
                        self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight-28, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                        self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-73, width: FULL_WIDTH-40, height: 50)
                        self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-40, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-41, width: self.muteSwitch.bounds.size.width, height: 50)
                        if self.mediaDict.count == 0 {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH , height: 0)
                            self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH - 40, height: 47)
                            
                            self.mediaView.isHidden = true
                            
                        }
                        else {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH , height:140)
                            self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 47)
                            self.mediaCollectionView.isHidden = false
                            
                        }
                        self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                        
                        self.nameLblBottomLbl.isHidden = true
                        self.aboutTextBottomLbl.isHidden = true
                    }
                }
            }
        }else if self.type == "own"{
            self.aboutTxtView.sizeToFit()
            self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight-10, width: FULL_WIDTH-40, height: 23)
            self.aboutTxtView.frame = CGRect.init(x: 20, y: topHeight+25, width: self.aboutTxtView.frame.size.width, height: self.aboutTxtView.frame.size.height)
            self.aboutTextBottomLbl.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+20, width: FULL_WIDTH, height: 1)
            self.nameLblBottomLbl.isHidden = true
            self.encryptionView.isHidden = true
            self.mediaView.isHidden = true
        }
        self.changeRTLView()
    }
    
    func setDesignScroll(topHeight:CGFloat)  {
        //        let size =  HPLActivityHUD.getExactLabelSize(self.aboutTxtView.text, withFont: APP_FONT_REGULAR, andSize: 25)
        if self.type != "own"{
            self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: FULL_WIDTH-40, height: 50)
            if blockedType == "1"{
                self.nameLbl.frame = CGRect.init(x: 20, y: 25, width: FULL_WIDTH-40, height: 35)
                self.aboutTxtView.isHidden = true
                self.aboutLblPlaceHolder.isHidden = true
                self.muteViewTopLbl.isHidden = true
                self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-73, width: FULL_WIDTH-40, height: 50)
                self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-40, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-44, width: self.muteSwitch.bounds.size.width, height: 50)
                if self.mediaDict.count == 0 {
                    self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH , height: 0)
                    self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH - 40, height: 47)
                    
                    self.mediaView.isHidden = true
                    
                }
                else {
                    self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH , height: 140)
                    self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 47)
                    self.mediaCollectionView.isHidden = false
                    
                }
                self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                
                self.nameLblBottomLbl.isHidden = true
                self.aboutTextBottomLbl.isHidden = true
            }else{
                
                //privacy last seen
                if privacy_about == "nobody"{
                    self.nameLbl.frame = CGRect.init(x: 20, y: 25, width: FULL_WIDTH-40, height: 35)
                    self.aboutTxtView.isHidden = true
                    self.aboutLblPlaceHolder.isHidden = true
                    self.muteViewTopLbl.isHidden = true
                    self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                    self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-73, width: FULL_WIDTH-40, height: 50)
                    self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-40, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-44, width: self.muteSwitch.bounds.size.width, height: 50)
                    if self.mediaDict.count == 0 {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH , height: 0)
                        self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH - 40, height: 47)
                        
                        self.mediaView.isHidden = true
                        
                    }
                    else {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH , height: 140)
                        self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 47)
                        self.mediaCollectionView.isHidden = false
                        
                    }
                    self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                    
                    self.nameLblBottomLbl.isHidden = true
                    self.aboutTextBottomLbl.isHidden = true
                }else if privacy_about == "everyone"{
                    self.nameLbl.frame = CGRect.init(x: 20, y: 25, width: FULL_WIDTH-40, height: 35)
                    self.aboutTxtView.isHidden = false
                    self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                    self.aboutTxtView.sizeToFit()
                    self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight+100, width: FULL_WIDTH-40, height: 23)
                    self.aboutTxtView.frame = CGRect.init(x: 20, y: topHeight+125, width: self.aboutTxtView.frame.size.width, height: self.aboutTxtView.frame.size.height)
                    if self.mediaDict.count == 0 {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                        self.muteView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH - 40, height: 67)
                        
                        self.mediaView.isHidden = true
                        
                    }
                    else {
                        self.mediaView.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH, height: 140)
                        self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 67)
                        self.mediaCollectionView.isHidden = false
                        
                    }
                    self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                    
                    self.nameLblBottomLbl.isHidden = true
                    self.aboutTextBottomLbl.isHidden = true
                }else if privacy_about == "mycontacts"{
                    if mutual == "true"{
                        self.nameLbl.frame = CGRect.init(x: 20, y: 25, width: FULL_WIDTH-40, height: 35)
                        self.aboutTxtView.isHidden = false
                        self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                        self.aboutTxtView.sizeToFit()
                        self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight+90, width: FULL_WIDTH-40, height: 23)
                        self.aboutTxtView.frame = CGRect.init(x: 20, y: topHeight+115, width: self.aboutTxtView.frame.size.width, height: self.aboutTxtView.frame.size.height)
                        if self.mediaDict.count == 0 {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH, height: 0)
                            self.muteView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH - 40, height: 67)
                            
                            self.mediaView.isHidden = true
                            
                        }
                        else {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+12, width: FULL_WIDTH, height: 140)
                            self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 67)
                            self.mediaCollectionView.isHidden = false
                            
                        }
                        self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                        
                        self.nameLblBottomLbl.isHidden = true
                        self.aboutTextBottomLbl.isHidden = true
                    }else{
                        self.nameLbl.frame = CGRect.init(x: 20, y: 25, width: FULL_WIDTH-40, height: 35)
                        self.aboutTxtView.isHidden = true
                        self.aboutLblPlaceHolder.isHidden = true
                        self.muteViewTopLbl.isHidden = true
                        self.otherProfileView.frame = CGRect.init(x: 20, y: topHeight, width: self.otherProfileView.bounds.size.width, height: self.otherProfileView.bounds.size.height+25)
                        self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.mobileLblPlaceHolder.frame.origin.y+self.mobileLblPlaceHolder.frame.size.height-73, width: FULL_WIDTH-40, height: 50)
                        self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-40, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-44, width: self.muteSwitch.bounds.size.width, height: 50)
                        if self.mediaDict.count == 0 {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+30, width: FULL_WIDTH , height: 0)
                            self.muteView.frame = CGRect.init(x: 20, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH - 40, height: 47)
                            
                            self.mediaView.isHidden = true
                            
                        }
                        else {
                            self.mediaView.frame = CGRect.init(x: 0, y: self.otherProfileView.frame.origin.y+self.otherProfileView.frame.size.height+22, width: FULL_WIDTH , height: 140)
                            self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.height+14, width: FULL_WIDTH - 40, height: 47)
                            self.mediaCollectionView.isHidden = false
                            
                        }
                        self.encryptionView.frame = CGRect.init(x: 20, y: self.muteView.frame.origin.y+self.muteView.frame.size.height+10, width: FULL_WIDTH - 40, height: 85)
                        
                        self.nameLblBottomLbl.isHidden = true
                        self.aboutTextBottomLbl.isHidden = true
                    }
                }
            }
        }else if self.type == "own"{
            self.nameLbl.frame = CGRect.init(x: 20, y: 30, width: FULL_WIDTH-40, height: 30)
            self.nameLblBottomLbl.frame = CGRect.init(x: 0, y: 80, width: FULL_WIDTH, height: 1)
            self.aboutTxtView.sizeToFit()
            self.aboutLblPlaceHolder.frame = CGRect.init(x: 20, y: topHeight+45, width: FULL_WIDTH-40, height: 23)
            self.aboutTxtView.frame = CGRect.init(x: 20, y: topHeight+80, width: self.aboutTxtView.frame.size.width, height: self.aboutTxtView.frame.size.height)
            self.nameLblBottomLbl.isHidden = false
            self.aboutTextBottomLbl.frame = CGRect.init(x: 0, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+20, width: FULL_WIDTH, height: 1)
            self.encryptionView.isHidden = true
            self.mediaView.isHidden = true
            
        }
        self.changeRTLView()
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if self.backType == "1" || self.backType == "2" {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else if self.backType == "0"{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func muteBtnTapped(_ sender: Any) {
        let localDB = LocalStorage()
        if muteSwitch.isOn {
            localDB.updateMute(cotact_id: self.user_id, status: "1")
            socketClass.sharedInstance.muteStatus(chat_id: self.user_id, type:"single" , status: "mute")
            
            muteSwitch.isOn = true
            muteSwitch.thumbTintColor = SECONDARY_COLOR
            muteSwitch.onTintColor = UIColor().hexValue(hex: "#D2ACF4")
            
        }else{
            localDB.updateMute(cotact_id: self.user_id, status: "0")
            socketClass.sharedInstance.muteStatus(chat_id: self.user_id, type:"single" , status: "unmute")
            muteSwitch.isOn = false
            muteSwitch.thumbTintColor = UIColor().hexValue(hex: "EEE5E8")
            muteSwitch.onTintColor = UIColor().hexValue(hex: "A6A1A5")
            
        }
    }
    
    @IBAction func editBtnTapped(_ sender: Any) {
        if type == "own"{
            let detailsObj = DetailsPage()
            detailsObj.viewType = EDIT_VIEW
            detailsObj.userDict = UserModel.shared.userDict()
            self.navigationController?.pushViewController(detailsObj, animated: true)
        }else{
            let userDict = localObj.getContact(contact_id: self.user_id)
            let muteStatus:String = userDict.value(forKey: "blockedByMe") as! String
            var menuArray = NSMutableArray()
            if muteStatus == "0"{
                menuArray = ["\(Utility.shared.getLanguage()?.value(forKey: "block") as! String)"]
            }else{
                menuArray = ["\(Utility.shared.getLanguage()?.value(forKey: "unblock") as! String)"]
            }
            
            let alert = CustomAlert()
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.delegate = self
            var frame = self.editIcon.frame
            if UserModel.shared.getAppLanguage() == "عربى" {
                frame = CGRect(x: self.view.frame.origin.x + 5, y: self.editIcon.frame.origin.y, width: self.editIcon.frame.width, height: self.editIcon.frame.height)
                alert.alignmentTag = 1
            }
            FTPopOverMenu.show(fromSenderFrame:frame , withMenuArray: menuArray as? [Any], doneBlock: { selectedIndex in
                if selectedIndex == 0{
                    if muteStatus == "0"{
                        alert.viewType = "1"
                        alert.msg = "block_msg"
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        alert.viewType = "2"
                        alert.msg = "unblock_msg"
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }, dismiss: {
                
            })
        }
    }
    func alertActionDone(type: String) {
        if type == "1"{
            socketClass.sharedInstance.blockContact(contact_id: self.user_id, type: "block")
        }else if type == "2"{
            socketClass.sharedInstance.blockContact(contact_id: self.user_id, type: "unblock")
        }
    }
    @IBAction func callBtnTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork() {
            
            let userDict = localObj.getContact(contact_id: self.user_id)
            let blockByMe = userDict.value(forKey: "blockedByMe") as! String
            
            if blockByMe == "1"{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
            }else{
                DispatchQueue.main.async {
                    let random_id = Utility.shared.random()
                    let pageobj = CallPage()
                    pageobj.receiverId = self.user_id
                    pageobj.userdict = userDict
                    pageobj.senderFlag = true
                    pageobj.random_id = random_id
                    pageobj.call_type = "audio"
                    pageobj.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                    self.callDB.addNewCall(call_id: random_id, contact_id: self.user_id, status: "outgoing", call_type: "audio", timestamp: Utility.shared.getTime(), unread_count: "0")
                    self.present(pageobj, animated: true, completion: nil)
                }
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    @IBAction func videoCallBtnTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork() {
            let userDict = localObj.getContact(contact_id: self.user_id)
            let blockByMe = userDict.value(forKey: "blockedByMe") as! String
            
            if blockByMe == "1"{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
            }else{
                let random_id = Utility.shared.random()
                let pageobj = CallPage()
                pageobj.receiverId = self.user_id
                pageobj.random_id = random_id
                pageobj.senderFlag = true
                pageobj.call_type = "video"
                pageobj.userdict = userDict
                pageobj.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.callDB.addNewCall(call_id: random_id, contact_id: self.user_id, status: "outgoing", call_type: "video", timestamp: Utility.shared.getTime(), unread_count: "0")
                self.present(pageobj, animated: true, completion: nil)
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    @IBAction func msgBtnTapped(_ sender: Any) {
        if self.backType == "0" {
            self.dismiss(animated: true, completion: nil)
        }else if self.backType == "1" || self.backType == "2"{
            let detailObj = ChatDetailPage()
            detailObj.contact_id = self.user_id
            detailObj.viewType = "1"
            detailObj.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(detailObj, animated: true, completion: nil)
        }
    }
}
extension ProfileHeaderPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mediaDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.mediaCollectionView.dequeueReusableCell(withReuseIdentifier: "profileCollectionViewCell", for: indexPath) as! profileCollectionViewCell
        let dict:messageModel.message = self.mediaDict.object(at: indexPath.row) as! messageModel.message
        let type:String = dict.message_data.value(forKeyPath: "message_type") as! String
        cell.typeLbl.isHidden = true
        
        if type == "image" {
            let imageName:String = dict.message_data.value(forKey: "attachment") as? String ?? ""
            cell.playView.isHidden = true
            cell.tag = indexPath.row + 10000
            cell.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else if type == "video" {
            cell.playView.isHidden = false
            let imageName:String = dict.message_data.value(forKey: "thumbnail") as? String ?? ""
            cell.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else if type == "document" {
            cell.typeLbl.isHidden = false
            cell.playView.isHidden = true
            cell.imageView.image = #imageLiteral(resourceName: "document_icon")
            cell.imageView.contentMode = .scaleAspectFit
            let path:String = dict.message_data.value(forKey: "attachment") as! String
            let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(path)")
            cell.typeLbl.text = docURL?.pathExtension.uppercased()
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict:messageModel.message = self.mediaDict.object(at: indexPath.row) as! messageModel.message
        let type = dict.message_data.value(forKeyPath: "message_type") as! String
        if type == "image"  {
            let message_id:String = dict.message_data.value(forKeyPath: "message_id") as! String
            let local_path:String = dict.message_data.value(forKeyPath: "local_path") as! String
            let updatedDict = self.localObj.getMsg(msg_id: message_id)
            self.openPic(identifier: local_path, msgDict: updatedDict, tagNum: indexPath.row)
         
        }
        else if type == "video" {
            self.openVideo(index: indexPath)
        }
        else if type == "document" {
            self.openDocument(index: indexPath)
        }
        else {
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
extension ProfileHeaderPage {
    //move to gallery
    func openPic(identifier:String,msgDict:NSDictionary,tagNum:Int){
        let cell = view.viewWithTag(tagNum + 10000) as? profileCollectionViewCell

        DispatchQueue.main.async {
            if identifier != "0" {
                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
                if galleryPic == nil && cell?.imageView.image == nil {
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "item_not_found") as? String)
                }else{

                    let imageInfo = GSImageInfo.init(image:cell?.imageView.image ?? #imageLiteral(resourceName: "no_chat"), imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView: self.view)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                    imageViewer.modalPresentationStyle = .fullScreen
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                let imageInfo = GSImageInfo.init(image:cell?.imageView.image ?? #imageLiteral(resourceName: "no_chat"), imageMode: .aspectFit)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
//    func openGroupPic(identifier:String,msgDict:groupMsgModel.message){
//        DispatchQueue.main.async {
//            if identifier != "0" {
//                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
//                if galleryPic == nil{
//                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "item_not_found") as? String)
//                }else{
//                    let imageInfo = GSImageInfo.init(image: galleryPic!, imageMode: .aspectFit)
//                    let transitionInfo = GSTransitionInfo(fromView: self.view)
//                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
//                    imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//                    self.present(imageViewer, animated: true, completion: nil)
//                }
//            }else{
//                let imageName = msgDict.attachment
//                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
//                let data = try? Data(contentsOf: imageURL!)
//                var image =  UIImage()
//                if let imageData = data {
//                    image = UIImage(data: imageData)!
//                }
//                let imageInfo = GSImageInfo.init(image: image, imageMode: .aspectFit, imageHD: nil)
//                let transitionInfo = GSTransitionInfo(fromView: self.view)
//                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
//                imageViewer.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//                self.present(imageViewer, animated: true, completion: nil)
//            }
//        }
//    }
    func openVideo(index: IndexPath) {
        let dict:messageModel.message = mediaDict.object(at: index.row) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        let message_id:String = msgDict.value(forKeyPath: "message_data.message_id") as! String
        
        let updatedDict = self.localObj.getMsg(msg_id: message_id)
        var videoName:String = updatedDict.value(forKeyPath: "message_data.local_path") as! String
        if videoName == "0"{
            let serverLink = msgDict.value(forKeyPath: "message_data.attachment") as! String
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(serverLink)"
        }
        let videoURL = URL.init(string: videoName)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func openDocument(index: IndexPath) {
        let dict:messageModel.message = self.mediaDict.object(at: index.row) as! messageModel.message
        let msgDict =  NSMutableDictionary()
        msgDict.setValue(dict.message_data, forKey: "message_data")
        
        DispatchQueue.main.async {
            let docuName:String = msgDict.value(forKeyPath: "message_data.attachment") as! String
            // print("\(docuName)")
            let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
            webVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(webVC, animated: true, completion: nil)
        }
    }
}
