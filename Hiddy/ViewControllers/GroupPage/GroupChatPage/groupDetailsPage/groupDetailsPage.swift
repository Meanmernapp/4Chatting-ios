//
//  groupDetailsPage.swift
//  Hiddy
//
//  Created by APPLE on 17/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

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

class groupDetailsPage: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,alertDelegate,optionDelegate,addmemberdelegate {
   
    @IBOutlet weak var forwardArrowIcon: UIImageView!

    @IBOutlet weak var encrytionContentLabel: UILabel!
    @IBOutlet weak var encryptionTitleLAbel: UILabel!
    @IBOutlet weak var encrytionView: UIView!
    @IBOutlet weak var topScrollViewWidth: NSLayoutConstraint!
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
    @IBOutlet var editIcon: UIImageView!
    @IBOutlet var backIcon: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var aboutTxtView: UILabel!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var muteNotficationLbl: UILabel!
    @IBOutlet var muteSwitch: UISwitch!
    @IBOutlet var muteView: UIView!
    @IBOutlet var memberTableView: UITableView!
    @IBOutlet var memberView: UIView!
    @IBOutlet var memberCountLbl: UILabel!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet weak var muteViewTopLbl: UILabel!
    @IBOutlet weak var muteViewBottomLbl: UILabel!
    @IBOutlet var addIcon: UIImageView!
    @IBOutlet var addMenuBtn: UIButton!
    
    // media View
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaCollectionVie: UICollectionView!
    @IBOutlet weak var mediaCountLabel: UILabel!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    var mediaDict = NSArray()
    
    var menuArray = NSMutableArray()
    var scrollDirectionValue = Float()
    var yoffset = Float()
    var alphaValue = CGFloat()
    var showStatusBar = true
    var designEnable = false

    var type = String()
    var backType = String()
    var group_id = String()
    var groupDict = NSDictionary()
    var memberDict = NSDictionary()
    let groupDB = groupStorage()
    var exitType = String()
    var exitStatus = String()
    var mediaArray = NSMutableArray()
    var memberArray = NSMutableArray()
    var viewType = String()
    var memberId = NSMutableArray()
    var group_admin = String()
    var group_main_admin = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mediaCollectionVie.delegate = self
        self.mediaCollectionVie.dataSource = self
        self.mediaCollectionVie.register(UINib(nibName: "profileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profileCollectionViewCell")
UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        self.configParallaxView()
        adjustContentViewHeight()
        
        self.mediaCountLabel.isUserInteractionEnabled = true
        self.mediaCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.mediaCountButtonAct)))
        self.forwardArrowIcon.isUserInteractionEnabled = true
        self.forwardArrowIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.mediaCountButtonAct)))
        //        UIApplication.shared.isStatusBarHidden = true
        
    }
    @objc func mediaCountButtonAct() {
        let vc = MediaDetailsViewController()
        vc.mediaDict = self.mediaDict
        vc.chatType = "group"
        vc.chat_id = self.group_id
        vc.image = self.profileImgView.image ?? #imageLiteral(resourceName: "profile_popup_bg")
        vc.userName = self.nameLbl.text!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    //check contact access permission
    @objc func checkPermission()  {
        DispatchQueue.main.async {
            Contact.sharedInstance.synchronize()
        }
    }
    
    @objc func refreshContact() {
        DispatchQueue.main.async {
            self.loadMembers()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
//        UIApplication.shared.isStatusBarHidden = true
        self.updateTheme()
        self.topContainerView.backgroundColor = BACKGROUND_COLOR
        self.contentView.backgroundColor = BACKGROUND_COLOR
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.initialSetup()
        self.setGroupDetails()
        self.changeRTLView()
        

        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshContact), name: Notification.Name("ContactRefresh"), object: nil)
                
        self.scrollViewDidScroll(bottomScroll)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermission), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermission), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.nameLbl.textAlignment = .right
            self.nameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutTxtView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.aboutTxtView.textAlignment = .right
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteNotficationLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteNotficationLbl.textAlignment = .right
            self.memberCountLbl.textAlignment = .right
            self.memberCountLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteViewTopLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.muteViewTopLbl.textAlignment = .right
            self.muteViewBottomLbl.textAlignment = .right
            self.muteViewBottomLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mediaTitleLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mediaCountLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.mediaCountLabel.textAlignment = .left
            self.profileImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.encryptionTitleLAbel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.encryptionTitleLAbel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.encryptionTitleLAbel.textAlignment = .right
            self.encryptionTitleLAbel.textAlignment = .right
            self.addBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.nameLbl.textAlignment = .left
            self.nameLbl.transform = .identity
            self.aboutTxtView.transform = .identity
            self.aboutTxtView.textAlignment = .left
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.muteNotficationLbl.transform = .identity
            self.muteNotficationLbl.textAlignment = .left
            self.memberCountLbl.textAlignment = .left
            self.memberCountLbl.transform = .identity
            self.muteViewTopLbl.transform = .identity
            self.muteViewTopLbl.textAlignment = .left
            self.muteViewBottomLbl.textAlignment = .left
            self.muteViewBottomLbl.transform = .identity
            self.mediaTitleLabel.transform = .identity
            self.mediaCountLabel.transform = .identity
            self.mediaCountLabel.textAlignment = .right
            self.profileImgView.transform = .identity
            self.encryptionTitleLAbel.transform = .identity
            self.encryptionTitleLAbel.transform = .identity
            self.encryptionTitleLAbel.textAlignment = .left
            self.encryptionTitleLAbel.textAlignment = .left
            self.addBtn.transform = .identity
        }
        
        let groupObj = groupStorage()
        let groupDict = groupObj.getGroupInfo(group_id: group_id)
        let muteStatus:String = groupDict.value(forKey: "mute") as! String
        if muteStatus == "0" {
            self.muteSwitch.isOn = false
            muteSwitch.thumbTintColor = UIColor().hexValue(hex: "EEE5E8")
            muteSwitch.onTintColor = UIColor().hexValue(hex: "A6A1A5")
        }else{
            self.muteSwitch.isOn = true
            muteSwitch.thumbTintColor = SECONDARY_COLOR
            muteSwitch.onTintColor = UIColor().hexValue(hex: "#D2ACF4")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
//        UIApplication.shared.isStatusBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var prefersStatusBarHidden: Bool {
        return showStatusBar
    }
    
    override func viewDidLayoutSubviews() {
//        self.memberTableView.frame.size = memberTableView.contentSize
        self.nameLbl.frame = CGRect.init(x: 20, y: 25, width: FULL_WIDTH-40, height: 30)
        self.memberTableView.frame = CGRect.init(x: 0, y: memberCountLbl.frame.origin.y+memberCountLbl.frame.size.height+10, width: FULL_WIDTH, height: self.memberTableView.contentSize.height+40)
        self.addBtn.frame = CGRect.init(x: self.memberCountLbl.frame.origin.x+self.memberCountLbl.frame.size.width+105, y: self.memberCountLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-50, width: self.addBtn.bounds.size.width, height: self.addBtn.bounds.size.height)
        self.encrytionView.frame = CGRect.init(x: 20, y: muteView.frame.origin.y+muteView.frame.size.height+35, width: FULL_WIDTH - 40, height: 85)
        self.memberView.frame = CGRect.init(x: 0, y: encrytionView.frame.origin.y+encrytionView.frame.size.height+15, width: FULL_WIDTH , height: self.memberTableView.frame.size.height+40)
        topScrollViewWidth.constant = FULL_WIDTH
        let height = self.bottomViewTopConstraint.constant + self.memberView.frame.origin.y + self.memberView.frame.size.height + 10
        if height < 1300 {
            bottomScroll.contentSize = CGSize.init(width: 100, height:1300)
        }else{
            bottomScroll.contentSize = CGSize.init(width: 100, height:height)
        }
        contentViewHeight.constant = UIScreen.main.bounds.size.height+height
    }

    func initialSetup()  {
        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
        self.editIcon.tintColor = .white
        
        self.addIcon.image = self.addIcon.image!.withRenderingMode(.alwaysTemplate)
        self.addIcon.tintColor = .white
        self.groupDict = self.groupDB.getGroupInfo(group_id: self.group_id)
        self.group_main_admin = self.groupDict.value(forKey: "created_by") as! String
        exitStatus = self.groupDict.value(forKey: "exit") as! String
        if exitStatus != "1" {
            self.memberDict = self.groupDB.getMemberInfo(member_key: "\(self.group_id)\(UserModel.shared.userID()!)")
            self.mediaDict = self.groupDB.getGroupMediaInfo(group_id: self.group_id, message_type: "'image','video','document'")
            self.mediaCollectionVie.reloadData()
            if self.memberDict.value(forKey: "member_role") != nil{
            group_admin = self.memberDict.value(forKey: "member_role") as! String
            }else {
            group_admin = "0"
            }
        }
        self.nameLbl.config(color: TEXT_PRIMARY_COLOR, size: 30, align: .left, text: EMPTY_STRING)
        self.memberCountLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: EMPTY_STRING)

        self.aboutTxtView.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        self.contentView.specificCornerRadius(radius: 20)
        self.encryptionTitleLAbel.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "encryption_title")
        self.encrytionContentLabel.config(color: TEXT_PRIMARY_COLOR, size: 16, align: .left, text: "encryption_content")
        self.mediaTitleLabel.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "media_title")
        self.mediaCountLabel.config(color: TEXT_PRIMARY_COLOR, size: 16, align: .left, text: "view_all")

        self.titleLbl.isHidden =  true
        self.nameLbl.isHidden = false
        
        memberTableView.register(UINib(nibName: "memberCell", bundle: nil), forCellReuseIdentifier: "memberCell")
        self.loadMembers()
        
        if group_admin == "1" {
            self.addBtn.isHidden = false
            self.addIcon.isHidden = false
            self.addMenuBtn.isHidden = false
        }else{
            self.addBtn.isHidden = true
            self.addIcon.isHidden = true
            self.addMenuBtn.isHidden = true
        }
//        self.getAndUpdateGroupDetails()
    }
    //config members
    func loadMembers(){
        self.memberArray = self.groupDB.getGroupMembers(group_id: self.group_id)
        self.memberTableView.reloadData()

        self.memberCountLbl.text = Utility.shared.countInAppLanguage(count: self.memberArray.count) + " \((Utility.shared.getLanguage()?.value(forKey: "participant"))!)"
        self.configMemberId()
        self.viewDidLayoutSubviews()
    }
    
    //get data from server and update
    func getAndUpdateGroupDetails()  {
        let groupArray = NSMutableArray()
        groupArray.add(group_id)
        let groupObj = GroupServices()
        groupObj.groupInfo(groupArray: groupArray, onSuccess: {response in
            let groupList:NSArray = response.value(forKey: "result") as! NSArray
            for groupDict in groupList{
                let groupDetails :NSDictionary = groupDict as! NSDictionary
                let group_id:String = groupDetails.value(forKey: "_id") as! String
                let group_members:NSArray = groupDetails.value(forKey: "group_members") as! NSArray
                groupSocket.sharedInstance.addGroupMembers(groupId: group_id, members: group_members, type: "1")
                self.memberArray.removeAllObjects()
                self.loadMembers()
            }
        })
    }
    
    @IBAction func viewFullImgAction(_ sender: Any) {
        let imageName:String = self.groupDict.value(forKey: "group_icon")! as! String
        if !Utility.shared.checkEmptyWithString(value:imageName) {
            let data = try? Data(contentsOf: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")!)
            var image =  UIImage()
            if let imageData = data {
                image = UIImage(data: imageData)!
            }
            else {
                image = #imageLiteral(resourceName: "profile_popup_bg")
            }
            let imageInfo = GSImageInfo.init(image: image, imageMode: .aspectFit, imageHD: nil)
            let transitionInfo = GSTransitionInfo(fromView: self.view)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            imageViewer.modalPresentationStyle = .fullScreen
            self.present(imageViewer, animated: true, completion: nil)
        }
        else{
            let imageInfo = GSImageInfo.init(image: #imageLiteral(resourceName: "group_popup"), imageMode: .aspectFit, imageHD: nil)
            let transitionInfo = GSTransitionInfo(fromView: self.view)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            imageViewer.modalPresentationStyle = .fullScreen
            self.present(imageViewer, animated: true, completion: nil)
        }
    }
    //set group details
   func setGroupDetails()  {
        // created time
        let localObj = LocalStorage()
        let created_id:String = self.groupDict.value(forKey: "created_by") as! String
        let userDict = localObj.getContact(contact_id: created_id)
        let time:String = groupDict.value(forKey: "created_at") as! String
        let created_time = Utility.shared.timeStamp(stamp: time, format: "dd/MM/yyyy")
    
    if created_id == UserModel.shared.userID()! as String {
        self.aboutTxtView.text = "\((Utility.shared.getLanguage()?.value(forKey: "created_by"))!) You \(created_time)"
        }else{
        var username =  String()
        if userDict.value(forKey: "user_name") != nil{
            username = userDict.value(forKey: "user_name")! as! String
        }else{
            username = EMPTY_STRING
        }
        self.aboutTxtView.text = "\((Utility.shared.getLanguage()?.value(forKey: "created_by"))!) \(username) \(created_time)"
        }
        self.groupDict = self.groupDB.getGroupInfo(group_id: group_id)
        self.nameLbl.text = self.groupDict.value(forKey: "group_name") as? String
        self.titleLbl.text = self.groupDict.value(forKey: "group_name") as? String
        self.muteNotficationLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: "mute_notification")
        self.addBtn.config(color: TEXT_PRIMARY_COLOR, size: 19, align: .center, title: "add")
        self.profileImgView.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(self.groupDict.value(forKey: "group_icon")!)"), placeholderImage: #imageLiteral(resourceName: "group_popObj"))
        if !designEnable {
            self.setViewDesign(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height+5)
            designEnable = true;
        }
    }
    
   
    //add member id
    func configMemberId()  {
        for member in memberArray{
            let memberDict:NSDictionary = member as! NSDictionary
            self.memberId.add(memberDict.value(forKey: "member_id") as Any)
        }
    }
    //configure parallax view
    func configParallaxView(){
        if responds(to: #selector(getter: self.edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }
        bottomScroll.delegate = self
        self.contentView.frame = CGRect.init(x: 0, y: headerImageViewHeight.constant - 50, width: FULL_WIDTH, height: FULL_HEIGHT)
        if UIDevice.current.hasNotch{
            headerImageViewHeight.constant = FULL_HEIGHT - 225
        }else if IS_IPHONE_PLUS{
            headerImageViewHeight.constant = FULL_HEIGHT - 150
        }else{
            headerImageViewHeight.constant = FULL_HEIGHT - 100
        }
    }
    
    func adjustContentViewHeight(){
        bottomViewTopConstraint.constant = headerImageViewHeight.constant - 80
        contentViewHeight.constant = self.memberTableView.contentSize.height + 500 + 160
    }
    
    // MARK: UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollMethod(scrollView: scrollView)
    }
    
    func scrollMethod(scrollView:UIScrollView){
        showStatusBar = false
        self.setNeedsStatusBarAppearanceUpdate()
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
                if yoffset > 150{
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                        self.transparentPic.isHidden = true
                        self.editIcon.image = self.editIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.editIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.addIcon.image = self.addIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.addIcon.tintColor = TEXT_PRIMARY_COLOR
                        
                        self.backIcon.image = self.backIcon.image!.withRenderingMode(.alwaysTemplate)
                        self.backIcon.tintColor = TEXT_PRIMARY_COLOR
                        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
                        self.navigationView.elevationEffect()
                        self.setViewDesign(topHeight: self.navigationView.frame.origin.y+self.navigationView.frame.size.height+5)
                        
                        self.titleLbl.isHidden = false
                        self.nameLbl.isHidden = true
                    }, completion: nil)
                }else{// scroll to down
                    if yoffset > 110{
                        self.contentView.removeCornerRadius()
                    }else{
                        self.contentView.specificCornerRadius(radius: 20)
                    }
                    self.setViewDesign(topHeight: self.nameLbl.frame.origin.y+self.nameLbl.frame.size.height+5)
                    self.titleLbl.isHidden = true
                    self.nameLbl.isHidden = false
                    self.transparentPic.isHidden = false
                    self.editIcon.tintColor = .white
                    self.backIcon.tintColor = .white
                    self.addIcon.tintColor = .white
                    self.navigationView.backgroundColor = .clear
                }
                topScroll.setContentOffset(CGPoint(x: topScroll.contentOffset.x, y: CGFloat(yoffset)), animated: false)
            }
        }
    @IBAction func addMemberTapped(_ sender: Any){
        if self.memberArray.count <= 50 {
            let addMember = createGroup()
            addMember.viewType = "1"
            addMember.group_id = self.group_id
            addMember.previousID = self.memberId
            addMember.delegate = self
            addMember.modalPresentationStyle = .fullScreen
            self.present(addMember, animated: true, completion: nil)
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "max_limit") as? String)
        }

    }
    func dismissMemberView() {
//        DispatchQueue.main.async {
       self.initialSetup()
        self.setGroupDetails()
        bottomScroll.setContentOffset(CGPoint(x: 0, y: 0), animated: false)

//        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
       if self.exitType == "2"{
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func muteBtnTapped(_ sender: Any) {
       let groupDB = groupStorage()
        if muteSwitch.isOn {
            groupDB.groupMute(group_id: self.group_id, status: "1")
            socketClass.sharedInstance.muteStatus(chat_id: self.group_id, type:"group" , status: "mute")

            muteSwitch.isOn = true
            muteSwitch.thumbTintColor = SECONDARY_COLOR
            muteSwitch.onTintColor = UIColor().hexValue(hex: "#D2ACF4")
       
        }else{
            socketClass.sharedInstance.muteStatus(chat_id: self.group_id, type:"group" , status: "unmute")
            groupDB.groupMute(group_id: self.group_id, status: "0")
            muteSwitch.isOn = false
            muteSwitch.thumbTintColor = UIColor().hexValue(hex: "EEE5E8")
            muteSwitch.onTintColor = UIColor().hexValue(hex: "A6A1A5")
        }
    }
    
    @IBAction func editBtnTapped(_ sender: Any) {
        exitStatus = groupDict.value(forKey: "exit") as! String
        if exitStatus == "1"{
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "delete_group_menu") as! String]
        }else{
            self.menuArray = [Utility.shared.getLanguage()?.value(forKey: "edit_group_menu") as! String,Utility.shared.getLanguage()?.value(forKey: "exit_group_menu") as! String]
        }
        let alert = CustomAlert()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        
        let configMenu = FTPopOverMenuConfiguration()
        configMenu.textColor =  TEXT_PRIMARY_COLOR
        configMenu.shadowColor = .white
        configMenu.allowRoundedArrow = false
        configMenu.tintColor = .red
        var frame = self.editIcon.frame
        if UserModel.shared.getAppLanguage() == "عربى" {
            frame = CGRect(x: self.view.frame.origin.x + 5, y: self.editBtn.frame.origin.y, width: self.editBtn.frame.width, height: self.editBtn.frame.height)
            alert.alignmentTag = 1
        }
        FTPopOverMenu.show(fromSenderFrame: frame, withMenuArray: self.menuArray as? [Any], doneBlock: { selectedIndex in
            if self.exitStatus == "1"{ // exit from the group
                if selectedIndex == 0{
                    alert.viewType = "1"
                    alert.msg = "delete_group"
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
            if selectedIndex == 0{
                let groupEdit = GroupInfoPage()
                groupEdit.viewType = "1"
                groupEdit.backType = "1"
                groupEdit.group_id = self.group_id
                groupEdit.modalPresentationStyle = .fullScreen
                self.present(groupEdit, animated: true, completion: nil)
                
            }else if selectedIndex == 1{
                if Utility.shared.isConnectedToNetwork(){
                    alert.viewType = "2"
                    alert.msg = "exit_group"
                    self.present(alert, animated: true, completion: nil)
                }else{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
                }
            }
            }
        }, dismiss: {
            
        })
        
    }
    
    func alertActionDone(type: String) {
        if type == "1"{
            self.groupDB.deleteGroupMsg(group_id:self.group_id)
            self.groupDB.deleteGroup(group_id: self.group_id)
            //reloading GroupPage tableView
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            
            //dismiss animation
//            let transition: CATransition = CATransition()
//            transition.duration = 0.6
//            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            transition.type = kCATransitionMoveIn
//            transition.subtype = kCATransitionFromLeft
//            self.view.window!.layer.add(transition, forKey: nil)
            self.view!.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }else if type == "2"{
            self.groupDB.groupExit(group_id: group_id)
            self.groupDB.removeMember(member_key: "\(group_id)\(UserModel.shared.userID()!)")
            
            self.memberArray.removeAllObjects()
            self.memberArray = self.groupDB.getGroupMembers(group_id: group_id)
            self.notifyExitToGroup()
        }
    }
    
    func setViewDesign(topHeight:CGFloat)  {
        
        self.aboutTxtView.frame = CGRect.init(x: 20, y: topHeight-5, width: FULL_WIDTH-40, height: 35)
        if mediaDict.count == 0 {
            self.mediaView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+5, width: FULL_WIDTH-40, height: 0)
            self.muteView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+5, width: FULL_WIDTH-40, height: 50)
            self.mediaView.isHidden = true
        }
        else {
            self.mediaView.frame = CGRect.init(x: 20, y: self.aboutTxtView.frame.origin.y+self.aboutTxtView.frame.size.height+5, width: FULL_WIDTH-40, height: 135)
            self.muteView.frame = CGRect.init(x: 20, y: self.mediaView.frame.origin.y+self.mediaView.frame.size.height+5, width: FULL_WIDTH-40, height: 50)
        }
        self.muteNotficationLbl.frame = CGRect.init(x: 0, y: self.muteViewTopLbl.frame.origin.y+self.muteViewTopLbl.frame.size.height+10, width: FULL_WIDTH-40, height: 50)
        self.muteSwitch.frame = CGRect.init(x: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.width-57, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height-44, width: self.muteSwitch.bounds.size.width, height: 50)
        self.muteViewBottomLbl.frame = CGRect.init(x: self.muteViewBottomLbl.frame.origin.x, y: self.muteNotficationLbl.frame.origin.y+self.muteNotficationLbl.frame.size.height+5, width: FULL_WIDTH, height: 1)
        self.viewDidLayoutSubviews()
        
    }
  
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.memberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! memberCell
        let contactDict:NSDictionary =  self.memberArray.object(at: indexPath.row) as! NSDictionary
        cell.config(contactDict:contactDict)
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.addTarget(self, action: #selector(goToProfilePopup), for: .touchUpInside)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
        let contactDict:NSDictionary =  self.memberArray.object(at: indexPath.row) as! NSDictionary
            let member_id :String = contactDict.value(forKey: "member_id") as! String
        if member_id == "\(UserModel.shared.userID()!)"{
        }else{
            let menu = OptionMenu()
            menu.memberDict = contactDict
            if self.group_admin == "1"{
               menu.viewType = "1"
            }else{
                menu.viewType = "0"
            }
            menu.group_id = self.group_id
            menu.delegate = self
            menu.modalPresentationStyle = .overCurrentContext
            menu.modalTransitionStyle = .crossDissolve
            self.present(menu, animated: true, completion: nil)
        }
        }
    }
    
    //profile popup
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        var profileDict = NSDictionary()
        profileDict = self.memberArray.object(at: sender.tag) as! NSDictionary
        
        let member_id :String = profileDict.value(forKey: "member_id") as! String
        if member_id == "\(UserModel.shared.userID()!)"{
        }else{
        let popup = ProfilePopup()
        popup.profileDict = profileDict
        popup.barType = "1"
        popup.viewType = "2"
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.present(popup, animated: false, completion: nil)
        }
    }
    
   
    func dismissWith(type: String) {
        self.initialSetup()
        self.setGroupDetails()
        bottomScroll.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    //exit group
    func notifyExitToGroup()  {
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(memberDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(memberDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(memberDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(UserModel.shared.userID(), forKey: "member_id")
        msgDict.setValue("Member Left", forKey: "message")
        msgDict.setValue("left", forKey: "message_type")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        
        if !self.groupDB.checkGroupMember(group_id: group_id) {
            if self.memberArray.count != 0 {
                self.makeSomeOneAsAdmin()
            }
        }
        self.groupDict = self.groupDB.getGroupInfo(group_id: group_id)
        self.initialSetup()
        groupSocket.sharedInstance.exitGroup(group_id: self.group_id, user_id: UserModel.shared.userID()! as String, msgDict: msgDict)
        socketClass.sharedInstance.goLive()
    }
    
    //make  admin
    func makeSomeOneAsAdmin()  {
        let newAdminDict:NSDictionary = self.memberArray.object(at: 0) as! NSDictionary
        let member_id = newAdminDict.value(forKey: "member_id") as! String
        let msgDict = NSMutableDictionary()
        let msg_id = Utility.shared.random()
        msgDict.setValue("group", forKey: "chat_type")
        msgDict.setValue(msg_id, forKey: "message_id")
        msgDict.setValue(group_id, forKey: "group_id")
        msgDict.setValue(newAdminDict.value(forKey: "member_role"), forKey: "member_role")
        msgDict.setValue(newAdminDict.value(forKey: "member_no"), forKey: "member_no")
        msgDict.setValue(newAdminDict.value(forKey: "member_name"), forKey: "member_name")
        msgDict.setValue(member_id, forKey: "member_id")
        msgDict.setValue(member_id, forKey: "group_admin_id")
        msgDict.setValue("Admin", forKey: "message")
        msgDict.setValue("admin", forKey: "message_type")
        msgDict.setValue("1", forKey: "attachment")
        msgDict.setValue(Utility.shared.getTime(), forKey: "chat_time")
        //send socket
        groupSocket.sharedInstance.sendGroupMsg(requestDict: msgDict)
        groupDB.makeAdmin(member_key: "\(group_id)\(member_id)",status:"1")
    }
}
extension groupDetailsPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mediaDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.mediaCollectionVie.dequeueReusableCell(withReuseIdentifier: "profileCollectionViewCell", for: indexPath) as! profileCollectionViewCell
        let dict:groupMsgModel.message = self.mediaDict.object(at: indexPath.row) as! groupMsgModel.message
        cell.typeLbl.isHidden = true

        if dict.message_type == "image" {
            let imageName:String = dict.attachment
            cell.playView.isHidden = true
            cell.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else if dict.message_type == "video" {
            cell.playView.isHidden = false
            let imageName:String = dict.thumbnail
            cell.imageView.sd_setImage(with: URL(string:"\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        else if dict.message_type == "document" {
            cell.playView.isHidden = true
            cell.imageView.image = #imageLiteral(resourceName: "document_icon")
            cell.imageView.contentMode = .scaleAspectFit
            cell.typeLbl.isHidden = false
            let docURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(dict.attachment)")
            cell.typeLbl.text = docURL?.pathExtension.uppercased()
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict:groupMsgModel.message = self.mediaDict.object(at: indexPath.row) as! groupMsgModel.message
        let type = dict.message_type
        if type == "image"  {
            let message_id:String = dict.message_id
            let local_path:String = dict.local_path
            let updatedDict = self.groupDB.getGroupMsg(msg_id: message_id)
            self.openGroupPic(identifier: local_path, msgDict: updatedDict!)
        }
        else if type == "video" {
            self.openGroupVideo(index: indexPath)
        }
        else if type == "document" {
            self.openGroupDocument(index: indexPath)
        }
    }
}
extension groupDetailsPage {
    //move to gallery
    func openGroupPic(identifier:String,msgDict:groupMsgModel.message){
        DispatchQueue.main.async {
            if identifier != "0" {
                let galleryPic = PhotoAlbum.sharedInstance.getImage(local_ID: identifier)
                if galleryPic == nil{
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "item_not_found") as? String)
                }else{
                    let imageInfo = GSImageInfo.init(image: galleryPic!, imageMode: .aspectFit)
                    let transitionInfo = GSTransitionInfo(fromView: self.view)
                    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                    imageViewer.modalPresentationStyle = .fullScreen
                    self.present(imageViewer, animated: true, completion: nil)
                }
            }else{
                let imageName = msgDict.attachment
                let imageURL = URL.init(string: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(imageName)")
//                let data = try? Data(contentsOf: imageURL!)
//                var image =  UIImage()
//                if let imageData = data {
//                    image = UIImage(data: imageData)!
//                }
                let imageView = UIImageView(image: #imageLiteral(resourceName: "profile_placeholder"))
                imageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))

                let imageInfo = GSImageInfo.init(image: imageView.image!, imageMode: .aspectFit, imageHD: nil)
                let transitionInfo = GSTransitionInfo(fromView: self.view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                imageViewer.modalPresentationStyle = .fullScreen
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
    
    func openGroupVideo(index: IndexPath) {
        let model:groupMsgModel.message = self.mediaDict.object(at: index.row) as! groupMsgModel.message
        let updatedModel = self.groupDB.getGroupMsg(msg_id: model.message_id)
        var videoName:String = updatedModel!.local_path
        if videoName == "0"{
            videoName = "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(model.attachment)"
        }
        let videoURL = URL.init(string: videoName)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func openGroupDocument(index: IndexPath) {
        let model:groupMsgModel.message = self.mediaDict.object(at: index.row) as! groupMsgModel.message
        
        DispatchQueue.main.async {
            let docuName:String = model.attachment
            // print("\(docuName)")
            let webVC = SwiftModalWebVC(urlString: "\(IMAGE_BASE_URL)\(IMAGE_SUB_URL)\(docuName)")
            webVC.modalPresentationStyle = .fullScreen
            self.present(webVC, animated: true, completion: nil)
        }
    }
}
