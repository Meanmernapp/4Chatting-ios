//
//  CallsPage.swift
//  Hiddy
//
//  Created by APPLE on 30/05/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class CallsPage: UIViewController,UITableViewDataSource,UITableViewDelegate,socketClassDelegate,groupDelegate,channelDelegate {
    @IBOutlet var logoImgView: UIImageView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var callsTableView: UITableView!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var noView: UIView!
    @IBOutlet var sideMenuIcon: UIImageView!
    @IBOutlet var backArrowImage: UIImageView!

    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var backArrowImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectedCountLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    var selectedIDArr = [String]()
    let callDB = CallStorage()
    var callsArray = NSMutableArray()
    let actionButton = JJFloatingActionButton()

    var longPressGesture = UILongPressGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.backArrowImage.image = self.backArrowImage.image!.withRenderingMode(.alwaysTemplate)
//        self.backArrowImage.tintColor = TEXT_PRIMARY_COLOR
//        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.callsTableView.backgroundColor = BACKGROUND_COLOR
        self.configFloatingBtn()
        self.setupLongPressGesture()
    }

    @IBAction func deleteButtonAct(_ sender: UIButton) {
        let alert = CustomAlert()
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.delegate = self
        alert.viewType = "7"
        alert.msg = "delete_msg_Call"
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func backButtonAct(_ sender: UIButton) {
        self.deleteView.isHidden = true
        selectedIDArr = [String]()
        self.callsTableView.reloadData()
        Utility.shared.setBadge(vc: self)
    }
    
    func setupLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        self.callsTableView.addGestureRecognizer(longPressGesture)
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        //get touch point
        let touchPoint = gestureRecognizer.location(in: self.callsTableView)
        let selectedIndexPath = self.callsTableView.indexPathForRow(at: touchPoint)!
        //check if selected is empty or not
        if selectedIndexPath.count != 0 && self.selectedIDArr.count == 0{
            //get msg data based on the selection
            let callDict:NSDictionary =  self.callsArray.object(at: selectedIndexPath.row) as! NSDictionary
            //arrange msg values
            let id = callDict.value(forKey: "call_id") as! String
            if self.selectedIDArr.filter({$0 == id}).count == 0 {
                let cell:UITableViewCell = self.callsTableView.cellForRow(at: selectedIndexPath)!
                cell.tag = selectedIndexPath.row + 400
                cell.backgroundColor = CHAT_SELECTION_COLOR
                self.selectedCountLabel.text = "1"
                self.selectedIDArr.append(id)
                self.deleteView.isHidden = false
                //forward only downloaded media files
            }
        }
    }

    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.logoImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.selectedCountLabel.textAlignment = .right
            self.selectedCountLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            actionButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.selectedCountLabel.transform = .identity
            self.searchIcon.transform = .identity
            self.view.transform = .identity
            self.selectedCountLabel.textAlignment = .left
            self.logoImgView.transform = .identity
            actionButton.transform = .identity
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()

        self.initialSetup()
        setNeedsStatusBarAppearanceUpdate()
        self.deleteView.isHidden = true
        selectedIDArr = [String]()
        self.callsTableView.reloadData()
        self.changeRTLView()
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
//        self.navigationView.applyGradient()
        self.navigationView.layer.cornerRadius = 25
        self.navigationView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.deleteView.layer.cornerRadius = 25
        self.deleteView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.navigationView.bringSubviewToFront(logoImgView)
        self.navigationView.bringSubviewToFront(searchIcon)
        self.navigationView.bringSubviewToFront(searchBtn)
        self.navigationView.bringSubviewToFront(sideMenuIcon)
        self.navigationView.bringSubviewToFront(deleteView)

        self.deleteView.applyGradient()
        self.deleteView.bringSubviewToFront(selectedCountLabel)
        self.deleteView.bringSubviewToFront(backButton)
        self.deleteView.bringSubviewToFront(deleteButton)
        self.deleteView.bringSubviewToFront(deleteImageView)
        self.deleteView.bringSubviewToFront(backArrowImageView)
        self.deleteView.isHidden = true
    }


    //set up initial details
    func initialSetup(){
        socketClass.sharedInstance.delegate = self
        groupSocket.sharedInstance.delegate =  self
        channelSocket.sharedInstance.delegate = self
        
        callsTableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 60, right: 0); //values
        self.navigationController?.isNavigationBarHidden = true
        callsTableView.register(UINib(nibName: "CallsCell", bundle: nil), forCellReuseIdentifier: "CallsCell")
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_call")
        self.refreshList()
        //self.selectedCountLabel.config(color: TEXT_SECONDARY_COLOR, size: 20, align: .left, text: EMPTY_STRING)
        self.selectedCountLabel.textColor = .white

    }
    
    //config floating chat new btn
    func configFloatingBtn()  {
        if UIDevice.current.hasNotch {
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-155, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-125, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.buttonImage = #imageLiteral(resourceName: "call_float_icon")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(goToChatPage), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    //floating btn action
    @objc func goToChatPage()  {
        let contactList = SelectCallList()
        self.navigationController?.pushViewController(contactList, animated: false)
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
    //refresh page
    func refreshList()  {
        callsArray = callDB.getCallsList()
        
        callsTableView.reloadData()
        if callsArray.count == 0 {
            self.noView.isHidden = false
        }else{
            self.noView.isHidden = true
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.callsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallsCell", for: indexPath) as! CallsCell

        let callDict:NSDictionary =  self.callsArray.object(at: indexPath.row) as! NSDictionary
        let id = callDict.value(forKey: "call_id") as! String

        cell.config(callDict: callDict)
        cell.makeCall.tag = indexPath.row
        cell.makeCall.addTarget(self, action: #selector(makeCallToRecent), for: .touchUpInside)
        if self.selectedIDArr.filter({$0 == id}).count != 0 {
            cell.backgroundColor = SEPARTOR_COLOR
        }else{
            cell.backgroundColor = .clear
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let callDict:NSDictionary =  self.callsArray.object(at: indexPath.row) as! NSDictionary
        //arrange msg values
        let id = callDict.value(forKey: "call_id") as! String
        if self.selectedIDArr.count != 0 {
            if self.selectedIDArr.filter({$0 == id}).count != 0 {
                let cell:UITableViewCell = self.callsTableView.cellForRow(at: indexPath)!
                cell.backgroundColor = .clear
                let index = self.selectedIDArr.firstIndex(of: id)
                self.selectedIDArr.remove(at: index ?? 0)
                if self.selectedIDArr.count == 0 {
                    self.deleteView.isHidden = true
                }
            }
            else {
                let cell:UITableViewCell = self.callsTableView.cellForRow(at: indexPath)!
                cell.backgroundColor = SEPARTOR_COLOR
                self.deleteView.isHidden = false
                self.selectedIDArr.append(id)
            }
            self.selectedCountLabel.text = "\(self.selectedIDArr.count)"
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            headerView.backgroundColor = BACKGROUND_COLOR
            let headerLabel = UILabel(frame: CGRect(x: 20, y: 12, width:
                tableView.bounds.size.width, height: 20))
//            headerLabel.font = UIFont(name: APP_FONT_REGULAR, size: 22)
            headerLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
            headerLabel.textColor = UIColor.init(named: "Color")
            headerLabel.text = Utility.shared.getLanguage()?.value(forKey: "calls1") as? String
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
            return headerView
        }


        return nil
    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        }
        return 0
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 90
    }
    @objc func makeCallToRecent(_ sender: UIButton!)  {
        if self.selectedIDArr.count == 0{
            if Utility.shared.isConnectedToNetwork()  {
                var callDict = NSDictionary()
                callDict = self.callsArray.object(at: sender.tag) as! NSDictionary
                let type:String = callDict.value(forKey: "call_type") as! String
                let contact_id:String = callDict.value(forKey: "contact_id") as! String
                
                if type == "audio"{
                    self.makeAudioCall(user_id: contact_id)
                }else{
                    self.makeVideoCall(user_id: contact_id)
                }
            }else{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
            }
        }
        else {
            let index = IndexPath(row: sender.tag, section: 0)
            self.tableView(self.callsTableView, didSelectRowAt: index)
        }
    }
    
    func makeAudioCall(user_id:String) {
        let localObj = LocalStorage()
        let userDict = localObj.getContact(contact_id: user_id)
        let blockByMe = userDict.value(forKey: "blockedByMe") as! String
        if blockByMe == "1"{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
        }else{
            DispatchQueue.main.async {
                let random_id = Utility.shared.random()
                let pageobj = CallPage()
                pageobj.updateCallStatus = { [weak self] in
                }
                pageobj.receiverId = user_id
                pageobj.senderFlag = true
                pageobj.random_id = random_id
                pageobj.userdict = userDict
                pageobj.call_type = "audio"
                pageobj.modalPresentationStyle = .fullScreen
                // print(time.rounded().clean)
                self.callDB.addNewCall(call_id: random_id, contact_id: user_id, status: "outgoing", call_type: "audio", timestamp: Utility.shared.getTime(), unread_count: "0")
                self.present(pageobj, animated: true, completion: nil)
            }
        }
    }
    
    func makeVideoCall(user_id:String) {
        let localObj = LocalStorage()
        let userDict = localObj.getContact(contact_id: user_id)
        let blockByMe = userDict.value(forKey: "blockedByMe") as! String
        if blockByMe == "1"{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "unblock_call") as? String)
        }else{
            DispatchQueue.main.async {
                    let random_id = Utility.shared.random()
                    let pageobj = CallPage()
                pageobj.updateCallStatus = { [weak self] in
                }
                    pageobj.receiverId = user_id
                    pageobj.random_id = random_id
                    pageobj.senderFlag = true
                    pageobj.call_type = "video"
                    pageobj.userdict = userDict
                pageobj.modalPresentationStyle = .fullScreen
                self.callDB.addNewCall(call_id: random_id, contact_id: user_id, status: "outgoing", call_type: "video", timestamp: Utility.shared.getTime(), unread_count: "0")
                    self.present(pageobj, animated: true, completion: nil)
            }
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
    func gotGroupInfo(dict: NSDictionary, type: String) {
        if type == "messagefromgroup" || type == "refreshGroup"{
            Utility.shared.setBadge(vc: self)
        }
    }
}
extension CallsPage: alertDelegate {
    func alertActionDone(type: String) {
        var arrChatID = ""
        for id in 0..<self.selectedIDArr.count {
            if id == 0 {
                arrChatID = "'" + self.selectedIDArr[id] + "'"
            }
            else {
                arrChatID = arrChatID + ",'" + self.selectedIDArr[id] + "'"
            }
        }
        self.callDB.deleteCall(chatID: arrChatID)
        self.refreshList()
        self.deleteView.isHidden = true
        selectedIDArr = [String]()
    }
}
