//
//  MyChannelList.swift
//  Hiddy
//
//  Created by APPLE on 07/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class MyChannelList:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
        var channelDB = ChannelStorage()
        let phoneNoArray = NSMutableArray()
        var myChannels = NSMutableArray()
        var channelCopy = NSMutableArray()
        var isSearch = Bool()
        var createChannel = Bool()
        var detailEnable = false
        @IBOutlet var noView: UIView!
        @IBOutlet var noLbl: UILabel!
        @IBOutlet var activity: UIActivityIndicatorView!
        @IBOutlet var titleLbl: UILabel!
        @IBOutlet var channelTableView: UITableView!
        @IBOutlet var navigationView: UIView!
        @IBOutlet var barBtnView: UIView!
        @IBOutlet var searchTF: UITextField!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            self.configFloatingBtn()
        }
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        override func viewWillAppear(_ animated: Bool) {
            setNeedsStatusBarAppearanceUpdate()
            self.updateTheme()
            self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
            self.initalSetup()
            createChannel = false
            detailEnable = false
            self.changeRTLView()
        }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.textAlignment = .right
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.searchTF.transform = .identity
            self.searchTF.textAlignment = .left
            self.noLbl.transform = .identity
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
        //initial setup
        func initalSetup()  {
            activity.color = SECONDARY_COLOR

            self.isSearch = false
            self.navigationView.elevationEffect()
            self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "my_channels")
           
            self.channelTableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
            self.searchTF.isHidden = true
            self.searchTF.clearButtonMode = .always
            self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
            self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_contact")
            //keyboard manager
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            self.noView.isHidden = true
            UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = false
            activity.startAnimating()
            DispatchQueue.main.async {
                self.channelCopy = self.channelDB.getChannelNewList(type: "own")
                self.myChannels = self.channelDB.getChannelNewList(type: "own")
                self.checkAvailablity()
            }
            
        }
    //config floating chat new btn
    func configFloatingBtn()  {
        let actionButton = JJFloatingActionButton()
        if UIDevice.current.hasNotch{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-125, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-90, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.buttonImage = #imageLiteral(resourceName: "channel_float_icon")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(channelCreation), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    
    //floating btn action
    @objc func channelCreation()  {
        if !createChannel {
        createChannel = true
        UserModel.shared.setNavType(type: "1")
        let createObj =  CreateChannel()
        self.navigationController?.pushViewController(createObj, animated: true)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
            if isSearch {
                self.searchTF.resignFirstResponder()
                self.barBtnView.isHidden = false
                self.titleLbl.isHidden = false
                self.searchTF.isHidden = true
                self.isSearch =  false
                self.refreshAgain()
            }else{
                self.navigationController?.popViewController(animated: true)
            }
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
            return self.myChannels.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
            if self.myChannels.count != 0{

            let dict:NSDictionary =  self.myChannels.object(at: indexPath.row) as! NSDictionary
            cell.config(channelDict: dict, type: "des")
            cell.profileBtn.tag = indexPath.row
            cell.profileBtn.addTarget(self, action: #selector(goToChatPage), for: .touchUpInside)
            cell.media_Icon.isHidden = true
            cell.channel_icon.frame = CGRect.init(x: 15, y: 25, width: 50, height: 50)
            cell.channelNameLbl.frame = CGRect.init(x: 80, y: 25, width: 200, height: 25)
            cell.descriptionLbl.frame = CGRect.init(x: cell.channelNameLbl.frame.origin.x, y: cell.descriptionLbl.frame.origin.y, width: cell.descriptionLbl.frame.width, height: cell.descriptionLbl.frame.height)
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
            if !detailEnable {
            detailEnable = true;
            let dict:NSDictionary =  self.myChannels.object(at: indexPath.row) as! NSDictionary
            let detailObj = ChannelChatPage()
            detailObj.channel_id = dict.value(forKey: "channel_id") as! String
            self.navigationController?.pushViewController(detailObj, animated: true)
            }

        }
        
    func refreshAgain(){
        channelTableView.isHidden = false
        myChannels = channelCopy.mutableCopy() as! NSMutableArray
        self.checkAvailablity()
    }
    
        //MARK: Textfield delegate
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            self.refreshAgain()
            return true
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.searchTF.resignFirstResponder()
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if channelCopy.count == 0 {
            } else {
                let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
                channelTableView.isHidden = true
                myChannels.removeAllObjects()
                // remove all data that belongs to previous search
                if (newString == "") || newString == nil {
                    channelTableView.isHidden = false
                    myChannels = channelCopy.mutableCopy() as! NSMutableArray
                    self.checkAvailablity()
                    return true
                }
                var counter: Int = 0
                for dict in channelCopy {
                    let tempArray = NSMutableArray.init(array: [dict])
                    var tempDict = NSDictionary()
                    tempDict = tempArray.object(at: 0) as! NSDictionary
                    let searchName = tempDict.value(forKey: "channel_name") as! String
                    
                    let range = searchName.range(of: newString!, options: NSString.CompareOptions.caseInsensitive, range: nil,locale: nil)
                    if range != nil {
                        self.myChannels.add(dict)
                    }
                    counter += 1
                }
                self.checkAvailablity()
            }
            return true
        }
        
        //check contacts available or not
        func checkAvailablity()  {
            if myChannels.count == 0 {
                self.channelTableView.isHidden = true
                self.noView.isHidden = false
            }else{
                self.channelTableView.isHidden = false
                self.channelTableView.reloadData()
                self.noView.isHidden = true
            }
            activity.stopAnimating()
        UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = true
        }
    //channel chat
    @objc func goToChatPage(_ sender: UIButton!)  {
        var dict = NSDictionary()
        dict = self.myChannels.object(at: sender.tag) as! NSDictionary
        let detailObj = ChannelChatPage()
        detailObj.channel_id = dict.value(forKey: "channel_id") as! String
        self.navigationController?.pushViewController(detailObj, animated: true)
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
