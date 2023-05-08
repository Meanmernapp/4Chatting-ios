//
//  GroupPage.swift
//  Hiddy
//
//  Created by APPLE on 30/05/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class GroupPage: UIViewController,UITableViewDataSource,UITableViewDelegate,groupDelegate,picPopUpDelegate,socketClassDelegate,channelDelegate,alertDelegate {
    
    @IBOutlet weak var grplbl: UILabel!
    @IBOutlet var logoImgView: UIImageView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var groupTableView: UITableView!
    @IBOutlet var noView: UIView!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var sideMenuIcon: UIImageView!
    
    @IBOutlet var loader: UIActivityIndicatorView!
    var groupArray = NSMutableArray()
    let groupDB = groupStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.groupTableView.isHidden = true
        self.groupTableView.backgroundColor = BACKGROUND_COLOR
        // Do any additional setup after loading the view.
        self.configFloatingBtn()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            self.refreshList()
        }
        //Reloading after delete the group in groupDetailsPage
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.logoImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
        }
        else {
            self.view.transform = .identity
            self.logoImgView.transform = .identity
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
        }
    }
    
    @objc func reloadTableView(){
        self.refreshList()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.groupDB.updateDefaultTranslation()
        self.updateTheme()

        self.initialSetup()
        setNeedsStatusBarAppearanceUpdate()
        groupTableView.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 60, right: 0); //values
        self.changeRTLView()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
//        self.navigationView.applyGradient()
        self.navigationView.layer.cornerRadius = 25
        self.navigationView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.navigationView.bringSubviewToFront(logoImgView)
        self.navigationView.bringSubviewToFront(searchIcon)
        self.navigationView.bringSubviewToFront(searchBtn)
        self.navigationView.bringSubviewToFront(sideMenuIcon)
    }
    override func viewDidAppear(_ animated: Bool) {
        if UserModel.shared.notificationGroupID() != nil && !Utility.shared.checkEmptyWithString(value: UserModel.shared.notificationGroupID()!) {
            let detailObj = GroupChatPage()
            detailObj.group_id = UserModel.shared.notificationGroupID()!
            self.navigationController?.pushViewController(detailObj, animated: true)
            UserModel.shared.setNotificationGroupID(id: EMPTY_STRING)
        }
    }
    //set up initial details
    func initialSetup()  {
        loader.color = SECONDARY_COLOR

        UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = false
        loader.startAnimating()
        self.noView.isHidden = true
        socketClass.sharedInstance.delegate = self
        groupSocket.sharedInstance.delegate =  self
        channelSocket.sharedInstance.delegate = self
        
        self.navigationController?.isNavigationBarHidden = true
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_group")
        self.grplbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "group1")
        grplbl.font = UIFont.boldSystemFont(ofSize: 22.0)
        grplbl.textColor = UIColor.init(named: "Color")
        groupTableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
        self.refreshList()
        Utility.shared.setBadge(vc: self)
        
    }
    @IBAction func sideMenuBtnTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    //config floating chat new btn
    func configFloatingBtn()  {
        let actionButton = JJFloatingActionButton()
        if UIDevice.current.hasNotch{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-155, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-125, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.buttonImage = #imageLiteral(resourceName: "group_float_icon")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(groupCreationTapped), for: .touchUpInside)
        if UserModel.shared.getAppLanguage() == "عربى" {
            actionButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            actionButton.transform = .identity
        }
        view.addSubview(actionButton)
        
    }
    
    //floating btn action
    @objc func groupCreationTapped()  {
        DispatchQueue.main.async {
            let groupObj = createGroup()
            groupObj.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(groupObj, animated: true)
//            self.navigationController?.present(groupObj, animated: true, completion: nil)
        }
    }
    @IBAction func searchBtnTapped(_ sender: Any) {
        let searchObj = SearchAll()
        self.navigationController?.pushViewController(searchObj, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.groupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        let groupDict:NSDictionary =  self.groupArray.object(at: indexPath.row) as! NSDictionary
        cell.config(groupDict: groupDict)
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.addTarget(self, action: #selector(goToGroupPopup), for: .touchUpInside)
        if groupArray.count == 1 {
            cell.separatorLbl.isHidden = true
        } else {
            cell.separatorLbl.isHidden = false
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 90
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupDict:NSDictionary = self.groupArray.object(at: indexPath.row) as! NSDictionary
        let detailObj = GroupChatPage()
        detailObj.viewType = "2"
        detailObj.group_id = groupDict.value(forKey: "group_id") as! String
        self.navigationController?.pushViewController(detailObj, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            let headerView = UIView()
//            headerView.backgroundColor = BACKGROUND_COLOR
//            let headerLabel = UILabel(frame: CGRect(x: 20, y: 2, width: tableView.bounds.size.width, height: 10))
////            headerLabel.font = UIFont(name: APP_FONT_REGULAR, size: 22)
//            headerLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
//            headerLabel.textColor = UIColor.init(named: "Color")
//            headerLabel.text = Utility.shared.getLanguage()?.value(forKey: "group1") as? String
//            headerLabel.sizeToFit()
//            headerView.addSubview(headerLabel)
//            return headerView
//        }
//
//
//        return nil
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 30
//        }
        return 0
    }
    
    
    
      func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     let groupDict:NSDictionary =  self.groupArray.object(at: indexPath.row) as! NSDictionary
     let group_id:String = groupDict.value(forKey: "group_id") as! String
     //mute
     let mute:String = groupDict.value(forKey: "mute") as! String
     let muteAction = UITableViewRowAction(style: .normal, title: "") { (rowAction, indexPath) in
     if mute == "0"{
        socketClass.sharedInstance.muteStatus(chat_id: group_id, type:"group" , status: "mute")
        self.groupDB.groupMute(group_id: group_id, status: "1")
     }else{
        socketClass.sharedInstance.muteStatus(chat_id: group_id, type:"group" , status: "unmute")
        self.groupDB.groupMute(group_id: group_id, status: "0")
     }
     self.refreshList()
     }
     if mute == "0"{
     muteAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "mute", btnImg: #imageLiteral(resourceName: "swipe_unmute")))
     }else{
     muteAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "mute", btnImg: #imageLiteral(resourceName: "swipe_mute")))
     }
     
     //delete
     let deleteAction = UITableViewRowAction(style: .normal, title: "") { (rowAction, indexPath) in
     let alert = CustomAlert()
     alert.modalPresentationStyle = .overCurrentContext
     alert.modalTransitionStyle = .crossDissolve
     alert.delegate = self
     alert.viewType = group_id
     alert.msg = "delete_group"
     self.present(alert, animated: true, completion: nil)
     }
     deleteAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "delete", btnImg: #imageLiteral(resourceName: "swipe_delete")))
     return [deleteAction,muteAction]
     }
    func alertActionDone(type: String) {
        self.groupDB.deleteGroupMsg(group_id:type)
        self.groupDB.deleteGroup(group_id: type)
        self.refreshList()
    }
    
    func swipeBackGroundView(indexPath:IndexPath,type:String,btnImg:UIImage)->UIImage {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 90))
        let myImage = UIImageView(frame: CGRect(x: 23, y: 30, width: 24, height: 24))
        myImage.contentMode = .scaleAspectFill
        if type == "mute"{
            backView.backgroundColor = UIColor.init(named: "swipe1")
        }else{
            backView.backgroundColor = UIColor.init(named: "swipe2")
        }
        

        myImage.image = btnImg
        backView.addSubview(myImage)
        let imgSize: CGSize = groupTableView.frame.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        backView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func refreshList()  {
        self.groupArray = self.groupDB.getGroupList()
        // print("group count \(self.groupArray.count)")
        self.groupTableView.reloadData()
        if self.groupArray.count == 0 {
            self.noView.isHidden = false
            self.groupTableView.isHidden = true
        }else{
            self.noView.isHidden = true
            self.groupTableView.isHidden = false
        }
        self.loader.stopAnimating()
        UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = true
    }
    
    //profile popup
    @objc func goToGroupPopup(_ sender: UIButton!)  {
        var groupDict = NSDictionary()
        groupDict = self.groupArray.object(at: sender.tag) as! NSDictionary
        let popup = ProfilePopup()
        popup.group_id = groupDict.value(forKey: "group_id") as! String
        popup.delegate = self
        popup.viewType = "1"
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
    func popupDismissed() {
        groupSocket.sharedInstance.delegate =  self
    }
    func gotGroupInfo(dict: NSDictionary, type: String) {
        if type == "messagefromgroup"{
            Utility.shared.setBadge(vc: self)
        }
        if type == "groupinvitation" || type == "messagefromgroup" || type == "refreshGroup" || type == "groupRecentMsg"{
            self.refreshList()
        }else if type == "listengrouptyping"{
            let type:String = dict.value(forKey: "type") as! String
            let group_id:String = dict.value(forKey: "group_id") as! String
            let member_id:String = dict.value(forKey: "member_id") as! String
            let memberDict = self.groupDB.getMemberInfo(member_key: "\(group_id)\(member_id)")
            let name:String = memberDict.value(forKey: "contact_name") as? String ?? ""
            if type == "untyping"{
                self.groupDB.updateGroupTyping(group_id: group_id, status: "0")
            }else if type == "typing"{
                self.groupDB.updateGroupTyping(group_id: group_id, status: name)
            }
            else if type == "recording" {
                self.groupDB.updateGroupTyping(group_id: group_id, status: "\(name) recording")
            }
            self.refreshList()
            
            /*for group in self.groupArray{
             let dict:NSDictionary = group as! NSDictionary
             let id:String = dict.value(forKey: "group_id") as! String
             if group_id == id{
             let index = self.groupArray.index(of: dict)
             let newDict = NSMutableDictionary.init(dictionary: dict)
             let memberDict = self.groupDB.getMemberInfo(member_key: "\(group_id)\(member_id)")
             let name:String = memberDict.value(forKey: "contact_name") as! String
             self.groupArray.removeObject(at: index)
             self.groupArray.insert(newDict, at: index)
             }
             }*/
        }
    }
    func gotChannelInfo(dict: NSDictionary, type: String) {
        if type == "messagefromadminchannels"{
            Utility.shared.setBadge(vc: self)
        }
    }
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "receivechat" {
            Utility.shared.setBadge(vc: self)
        }else if type == "refreshcount" {
            Utility.shared.setBadge(vc: self)
        }
    }
}
