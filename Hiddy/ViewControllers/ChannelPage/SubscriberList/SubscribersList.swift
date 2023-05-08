//
//  SubscribersList.swift
//  Hiddy
//
//  Created by APPLE on 09/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class SubscribersList: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var subscriberTableView: UITableView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var noView: UIView!
    @IBOutlet var menuIcon: UIImageView!
    
    @IBOutlet var loader: UIActivityIndicatorView!
    var subscriberArray = NSMutableArray()
    var isSearch = Bool()
    var channel_id = String()
    var dataFetched = Bool()
    var showAlert = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalSetup()
        // Do any additional setup after loading the view.
        
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.noView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.noView.transform = .identity
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.subscriberTableView.backgroundColor = BACKGROUND_COLOR
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func menuBtnTapped(_ sender: Any) {
        let menuArray:NSArray = ["\(Utility.shared.getLanguage()?.value(forKey: "refresh") as! String)"]
        var frame = self.menuIcon.frame
        if UserModel.shared.getAppLanguage() == "عربى" {
            frame = CGRect(x: self.view.frame.origin.x + 5, y: self.menuIcon.frame.origin.y, width: self.menuIcon.frame.width, height: self.menuIcon.frame.height)
        }
        FTPopOverMenu.show(fromSenderFrame: frame , withMenuArray: menuArray as? [Any], doneBlock: { selectedIndex in
            if selectedIndex == 0{
                UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = false
                self.loader.startAnimating()
                self.getSubscriberList(offset: "0")
            }
        }, dismiss: {
            
        })
    }
    
    //initial setup
    func initalSetup()  {
        loader.color = SECONDARY_COLOR

        self.showAlert = false
        isSearch = false
        self.noView.isHidden = true
        self.dataFetched =  false
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "subscribers")
        subscriberTableView.register(UINib(nibName: "BlockCell", bundle: nil), forCellReuseIdentifier: "BlockCell")

        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_contact")
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.loader.startAnimating()
        self.getSubscriberList(offset: "0")
    }
    
    //get subscriber list
    func getSubscriberList(offset:String)  {
        let  channelObj = ChannelServices()
        channelObj.subscriberList(channel_id: channel_id, phone: UserModel.shared.phoneNo()! as String, offset: offset, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let members:NSArray = response.value(forKey: "result") as! NSArray
                if members.count < 20{
                    self.dataFetched = true
                    DispatchQueue.main.async {
                        if self.showAlert{
                        self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_more") as? String)
                        }
                        self.showAlert = true
                    }
                }
                if members.count != 0{
                    self.subscriberArray.removeAllObjects()
                    self.subscriberArray.addObjects(from: members as! [Any])
                    self.checkAvailablity()
                }
            }else{
                self.dataFetched = true
                DispatchQueue.main.async {
                    self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "no_more") as? String)
                }
            }
        })
    }
    //back btn tapped
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.subscriberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath) as! BlockCell
        let dict:NSDictionary =  self.subscriberArray.object(at: indexPath.row) as! NSDictionary
        cell.configSubscriber(contactDict: dict)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict:NSDictionary =  self.subscriberArray.object(at: indexPath.row) as! NSDictionary
        let channel_id = dict.value(forKey: "_id") as! String
        if UserModel.shared.channelIDs().contains(channel_id) {
            let channelDB = ChannelStorage()
            let channelDict = channelDB.getChannelInfo(channel_id: channel_id)
            let status:String = channelDict.value(forKey: "subscribtion_status") as! String
            if status == "0" {
                let subscriberObj = SuccessPage()
                subscriberObj.detailsDict = channelDict
                subscriberObj.viewType = "1"
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
            self.navigationController?.pushViewController(subscriberObj, animated: true)
        }
        
    }
    //scroll view delegate
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if !dataFetched {
            if maximumOffset - currentOffset <= 70.0 {
                self.getSubscriberList(offset: "\(self.subscriberArray.count)")
            }
        }
        
    }
    
    //check contacts available or not
    func checkAvailablity()  {
        if subscriberArray.count == 0 {
            self.subscriberTableView.isHidden = true
            self.noView.isHidden = false
        }else{
            self.subscriberTableView.isHidden = false
            self.subscriberTableView.reloadData()
            self.noView.isHidden = true
        }
        self.loader.stopAnimating()
        UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = true

    }
    
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.subscriberTableView.frame.size.height = FULL_HEIGHT-self.navigationView.frame.size.height
        self.subscriberTableView.frame.size.height -= keyboardFrame.height
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.subscriberTableView.frame.size.height += keyboardFrame.height
    }
    
}
