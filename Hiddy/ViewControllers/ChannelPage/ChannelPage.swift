//
//  ChannelPage.swift
//  Hiddy
//
//  Created by APPLE on 30/05/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class ChannelPage: UIViewController,UITableViewDataSource,UITableViewDelegate,channelDelegate,groupDelegate,socketClassDelegate,UIGestureRecognizerDelegate,alertDelegate{
    
    @IBOutlet weak var channellbl: UILabel!
    @IBOutlet var logoImgView: UIImageView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet var noView: UIView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var channelTableView: UITableView!
    @IBOutlet var allChanneLbl: UILabel!
    @IBOutlet var allChannelView: UIView!
    @IBOutlet var sideMenuIcon: UIImageView!

    @IBOutlet var loader: UIActivityIndicatorView!
    var channelArray = NSMutableArray()
    let channelDB = ChannelStorage()
    var createChannel = Bool()
    let socket = channelSocket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configFloatingBtn()
        self.socket.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.channelDB.updateDefaultTranslation()
        self.updateTheme()
        self.allChannelView.backgroundColor = BACKGROUND_COLOR
        socketClass.sharedInstance.delegate = self
        groupSocket.sharedInstance.delegate =  self
        channelSocket.sharedInstance.delegate = self
        self.initialSetup()
        Utility.shared.setBadge(vc: self)
        setNeedsStatusBarAppearanceUpdate()
        createChannel = false
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.logoImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.allChanneLbl.textAlignment = .right
            self.allChanneLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
        }
        else {
            self.view.transform = .identity
            self.logoImgView.transform = .identity
            self.allChanneLbl.textAlignment = .left
            self.allChanneLbl.transform = .identity
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.channelTableView.reloadData()
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
        if UserModel.shared.notificationChannelID() != nil && !Utility.shared.checkEmptyWithString(value: UserModel.shared.notificationChannelID()!) {
            let detailObj = ChannelChatPage()
            detailObj.channel_id = UserModel.shared.notificationChannelID()!
            self.navigationController?.pushViewController(detailObj, animated: true)
            UserModel.shared.setNotificationChannelID(id: EMPTY_STRING)
        }
    }
    //set up initial details
    func initialSetup()  {
        loader.color = SECONDARY_COLOR

        channelTableView.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 60, right: 0); //values
        UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = true
        loader.startAnimating()
        self.noView.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_channel")
        channelTableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
        
        self.channellbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "channel1")
        channellbl.font = UIFont.boldSystemFont(ofSize: 22.0)
        channellbl.textColor = UIColor.init(named: "Color")
        self.refreshList()
       self.allChanneLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: "all_channel")
        //tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.goToAllChannel (_:)))
        tap.delegate = self
        self.allChannelView.addGestureRecognizer(tap)
    }
    
    @IBAction func sideMenuBtnTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    @IBAction func searchBtnTapped(_ sender: Any) {
        let searchObj =  SearchAll()
        self.navigationController?.pushViewController(searchObj, animated: true)
    }
    //go to all channel
    @objc func goToAllChannel (_ sender: UITapGestureRecognizer) {
        let myChannelObj = AllChannels()
        self.navigationController?.pushViewController(myChannelObj, animated: true)
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
        actionButton.buttonImage = #imageLiteral(resourceName: "channel_float_icon")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(channelCreation), for: .touchUpInside)
        if UserModel.shared.getAppLanguage() == "عربى" {
            actionButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            actionButton.transform = .identity
        }
        view.addSubview(actionButton)
        
    }
    
    //floating btn action
    @objc func channelCreation()  {
        if !createChannel {
            UserModel.shared.setNavType(type: "2")
            let createObj =  CreateChannel()
            self.navigationController?.pushViewController(createObj, animated: true)
            createChannel = true
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.channelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
        let dict:NSDictionary =  self.channelArray.object(at: indexPath.row) as! NSDictionary
        cell.config(channelDict: dict,type:"msg")
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.addTarget(self, action: #selector(goToChatPage), for: .touchUpInside)
        if channelArray.count == 1 {
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
        let dict:NSDictionary =  self.channelArray.object(at: indexPath.row) as! NSDictionary
        let status:String = dict.value(forKey: "subscribtion_status") as! String
        if status == "0" {
            let subscriberObj = SuccessPage()
            subscriberObj.detailsDict = dict
            subscriberObj.viewType = "1"
            self.navigationController?.pushViewController(subscriberObj, animated: true)
        }else{
            let detailObj = ChannelChatPage()
            detailObj.channel_id = dict.value(forKey: "channel_id") as! String
            self.navigationController?.pushViewController(detailObj, animated: true)
        }
    }
    
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            let headerView = UIView()
//            headerView.backgroundColor = BACKGROUND_COLOR
//            let headerLabel = UILabel(frame: CGRect(x: 20, y: 12, width:
//                tableView.bounds.size.width, height: 20))
////            headerLabel.font = UIFont(name: APP_FONT_REGULAR, size: 22)
//            headerLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
//            headerLabel.textColor = UIColor.init(named: "Color")
//            headerLabel.text = Utility.shared.getLanguage()?.value(forKey: "channel1") as? String
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
//            return 35
//        }
        return 0
    }
   func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let dict:NSDictionary =  self.channelArray.object(at: indexPath.row) as! NSDictionary
        let channel_id:String = dict.value(forKey: "channel_id") as! String
        let status:String = dict.value(forKey: "subscribtion_status") as! String
        if status == "1" {
        //mute
        let mute:String = dict.value(forKey: "mute") as! String
        let muteAction = UITableViewRowAction(style: .normal, title: "") { (rowAction, indexPath) in
            if mute == "0"{
                socketClass.sharedInstance.muteStatus(chat_id: channel_id, type:"channel" , status: "mute")

                self.channelDB.channelMute(channel_id: channel_id, status: "1")
            }else{
                socketClass.sharedInstance.muteStatus(chat_id: channel_id, type:"channel" , status: "unmute")

                self.channelDB.channelMute(channel_id: channel_id, status: "0")
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
            alert.viewType = channel_id
            alert.msg = "clear_msg"
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = UIColor(patternImage: self.swipeBackGroundView(indexPath: indexPath, type: "delete", btnImg: #imageLiteral(resourceName: "swipe_delete")))
        return [deleteAction,muteAction]
            
        }
        return []
    }
    func alertActionDone(type: String) {
        self.channelDB.deleteChannelMsg(channel_id: type)
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
        let imgSize: CGSize = channelTableView.frame.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        backView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //channel chat
    @objc func goToChatPage(_ sender: UIButton!)  {
        var dict = NSDictionary()
        dict = self.channelArray.object(at: sender.tag) as! NSDictionary
        let status:String = dict.value(forKey: "subscribtion_status") as! String
        if status == "0" {
            let subscriberObj = SuccessPage()
            subscriberObj.detailsDict = dict
            subscriberObj.viewType = "1"
            self.navigationController?.pushViewController(subscriberObj, animated: true)
        }else{
            let detailObj = ChannelChatPage()
            detailObj.channel_id = dict.value(forKey: "channel_id") as! String
            self.navigationController?.pushViewController(detailObj, animated: true)
        }
    }
    func refreshList()  {
        self.channelArray.removeAllObjects()
        self.channelArray = self.channelDB.getChannelNewList(type: "all")
        self.channelTableView.reloadData()
        if self.channelArray.count == 0 {
            self.noView.isHidden = false
        }else{
            self.noView.isHidden = true
        }
        self.loader.stopAnimating()
        UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = true
    }
    
    func gotChannelInfo(dict: NSDictionary, type: String) {
        
        if type == "messagefromadminchannels" || type == "deletechannel" || type == "refreshChannel" || type == "receivechannelinvitation"{
            self.refreshList()
        }
        if type == "messagefromadminchannels"{
            Utility.shared.setBadge(vc: self)
        }
        else if type == "blockchannel" {
            self.refreshList()
        }
    }
    
    func gotSocketInfo(dict: NSDictionary, type: String) {
        if type == "receivechat" {
            Utility.shared.setBadge(vc: self)
        }else if type == "refreshcount" {
            Utility.shared.setBadge(vc: self)
        }
    }
    func gotGroupInfo(dict: NSDictionary, type: String) {
        if type == "messagefromgroup" || type == "refreshGroup"{
            Utility.shared.setBadge(vc: self)
        }
    }
    
    

}
