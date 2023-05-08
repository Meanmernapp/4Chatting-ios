//
//  AllChannels.swift
//  Hiddy
//
//  Created by APPLE on 08/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class AllChannels: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate {

    @IBOutlet var channelTableView: UITableView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var noView: UIView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var barBtnView: UIView!
    
    @IBOutlet var moreBtn: UIButton!
    
    var channelArray = NSMutableArray()
    var isSearch = Bool()
    var searchString = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initalSetup()
        UserModel().setChannelDeleted(id: "1")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        activity.color = SECONDARY_COLOR
        if UserModel().deleteChannelID() != "1"{
            self.channelArray.removeAllObjects()
            self.getChannelList(offset:"0", search: searchString)
            UserModel().removeChannelID()
        }
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.textAlignment = .right
            self.searchTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            // self.noLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.searchTF.textAlignment = .left
            self.searchTF.transform = .identity
            self.titleLbl.transform = .identity
            self.titleLbl.textAlignment = .left
            self.noLbl.transform = .identity
            // self.noLbl.textAlignment = .left
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    //initial setup
    func initalSetup()  {
        isSearch = false
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "all_channel")
        channelTableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
        self.searchTF.isHidden = true
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_contact")
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.noView.isHidden = true
        searchString = "all"
        activity.startAnimating()
        self.getChannelList(offset:"0", search: searchString)
    }
    
    //get channel list
    func getChannelList(offset:String,search:String)  {
        let  channelObj = ChannelServices()
        channelObj.allPublicChannels(offset: offset,search:search , onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let channels:NSArray = response.value(forKey: "result") as! NSArray
                self.channelArray.removeAllObjects()
                for i in channels {
                    let dict = i as! NSDictionary
                    let status:Int = dict.value(forKey: "block_status") as? Int ?? 0
                    if status == 0 {
                        self.channelArray.add(i)
                    }
                    let channelObj = ChannelStorage()
                    channelObj.blockChannelMsg(channel_id: dict.value(forKey: "_id") as? String ?? "0", blockStatus: "\(status)")
                }
                self.checkAvailablity()
            }else{
                self.activity.stopAnimating()
                self.checkAvailablity()

            }
        })
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if isSearch {
            self.searchTF.resignFirstResponder()
            self.searchTF.text = EMPTY_STRING
            self.barBtnView.isHidden = false
            self.titleLbl.isHidden = false
            self.searchTF.isHidden = true
            self.isSearch =  false
//            self.channelArray.removeAllObjects()
            searchString = "all"
            self.getChannelList(offset: "0", search: searchString)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func moreBtnTapped(_ sender: Any) {
        let menuArray:NSArray = ["\(Utility.shared.getLanguage()?.value(forKey: "refresh") as! String)"]
        var frame = CGRect.init(x: self.barBtnView.frame.origin.x+self.moreBtn.frame.origin.x, y: self.barBtnView.frame.origin.y+self.moreBtn.frame.origin.y, width: 11, height: 21)
        if UserModel.shared.getAppLanguage() == "عربى" {
            frame = CGRect(x: self.view.frame.origin.x + 5, y: self.moreBtn.frame.origin.y, width: self.moreBtn.frame.width, height: self.moreBtn.frame.height)
        }
        FTPopOverMenu.show(fromSenderFrame:frame , withMenuArray: menuArray as? [Any], doneBlock: { selectedIndex in
                if selectedIndex == 0{
                    self.getChannelList(offset:"0", search: self.searchString)
                }
            }, dismiss: {
                
            })

    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                self.searchTF.isHidden = false
                self.barBtnView.isHidden = true
                self.titleLbl.isHidden = true
                self.isSearch =  true
                self.searchTF.becomeFirstResponder()
            }, completion: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.channelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
        if self.channelArray.count != 0{

        let dict:NSDictionary =  self.channelArray.object(at: indexPath.row) as! NSDictionary
        cell.config(channelDict: dict, type: "des")
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.isUserInteractionEnabled = false
//        cell.profileBtn.addTarget(self, action: #selector(goToChatPage), for: .touchUpInside)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchTF.resignFirstResponder()
        let dict:NSDictionary =  self.channelArray.object(at: indexPath.row) as! NSDictionary
        let channel_id = dict.value(forKey: "_id") as! String
        if UserModel.shared.channelIDs().contains(channel_id) {
            let channelDB = ChannelStorage()
            let channelDict = channelDB.getChannelInfo(channel_id: channel_id)
            let status:String = channelDict.value(forKey: "subscribtion_status") as! String
            if status == "0" {
                let subscriberObj = SuccessPage()
                subscriberObj.detailsDict = channelDict
                subscriberObj.viewType = "1"
                UserModel.shared.setNavType(type: "4")
                self.navigationController?.pushViewController(subscriberObj, animated: true)
            }else{
                let detailObj = ChannelChatPage()
                detailObj.channel_id = channel_id
                self.navigationController?.pushViewController(detailObj, animated: true)
            }
        }else{
            let reqDict = NSMutableDictionary.init(dictionary: dict)
            reqDict.setValue(channel_id, forKey: "channel_id")
            reqDict.setValue(dict.value(forKey: "total_subscribers"), forKey: "subscriber_count")
            
            let subscriberObj = SuccessPage()
            subscriberObj.detailsDict = reqDict
            subscriberObj.viewType = "1"
            UserModel.shared.setNavType(type: "4")
            self.navigationController?.pushViewController(subscriberObj, animated: true)
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 70.0 {
            self.getChannelList(offset: "\(self.channelArray.count)", search: searchString)
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.channelArray.removeAllObjects()
        searchString = "all"
        self.getChannelList(offset: "0", search: searchString)
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
            self.searchTF.resignFirstResponder()
            self.channelArray.removeAllObjects()
            self.channelTableView.reloadData()
            UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = false
            self.activity.startAnimating()
            self.searchString = self.searchTF.text!
            let escapedString = self.searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            self.getChannelList(offset: "0", search: escapedString!)
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let full_string = textField.text!+string
//        let escapedString = full_string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

      
        self.channelArray.removeAllObjects()
        self.activity.startAnimating()
        self.searchString = full_string

        if let text = textField.text,
              let textRange = Range(range, in: text) {
              let updatedText = text.replacingCharacters(in: textRange,
                                                          with: string)
            let escapedString = updatedText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            self.getChannelList(offset: "0", search: escapedString!)


           }
        return true
    }
    
    //check contacts available or not
    func checkAvailablity()  {
        if channelArray.count == 0 {
            self.channelTableView.isHidden = true
            self.noView.isHidden = false
        }else{
            self.channelTableView.isHidden = false
            self.channelTableView.reloadData()
            self.noView.isHidden = true
        }
        self.activity.stopAnimating()
        UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = true
    }
    
    //channel chat
    @objc func goToChatPage(_ sender: UIButton!)  {
        var dict = NSDictionary()
        dict = self.channelArray.object(at: sender.tag) as! NSDictionary
        let status:String = dict.value(forKey: "subscribtion_status") as! String
        if status == "0" {
            let subscriberObj = SuccessPage()
            subscriberObj.detailsDict = dict
            self.navigationController?.pushViewController(subscriberObj, animated: true)
        }else{
            let detailObj = ChannelChatPage()
            detailObj.channel_id = dict.value(forKey: "channel_id") as! String
            self.navigationController?.pushViewController(detailObj, animated: true)
        }
    }
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.channelTableView.frame.size.height = FULL_HEIGHT-self.navigationView.frame.size.height
        
        self.channelTableView.frame.size.height -= keyboardFrame.height
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.channelTableView.frame.size.height += keyboardFrame.height
    }
    
}
