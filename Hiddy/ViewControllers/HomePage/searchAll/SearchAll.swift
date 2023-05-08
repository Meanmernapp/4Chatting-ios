//
//  SearchAll.swift
//  Hiddy
//
//  Created by APPLE on 28/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class SearchAll: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,picPopUpDelegate {
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var noView: UIView!
    
    var groupArray = NSMutableArray()
    var recentArray = NSMutableArray()
    var recentCopy = NSMutableArray()
    var groupCopy = NSMutableArray()
    var searchArray = NSMutableArray()
    var channelArray = NSMutableArray()

    var overAllArray = NSMutableArray()

    let localDB = LocalStorage()
    let groupDB =  groupStorage()
    let channelDB = ChannelStorage()
    var selectedSection = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initalSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.updateTheme()

        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            // self.noLbl.textAlignment = .right
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            // self.noLbl.textAlignment = .left
            self.noLbl.transform = .identity
            self.searchTF.transform = .identity
            self.searchTF.textAlignment = .left
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    //initial setup
    func initalSetup()  {
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.searchTableView.backgroundColor = BACKGROUND_COLOR
        selectedSection = 0;
        self.navigationView.elevationEffect()
        self.configList()
        self.overAllArray.addObjects(from: self.recentArray as! [Any])
        self.overAllArray.addObjects(from: self.groupArray as! [Any])
        self.overAllArray.addObjects(from: self.channelArray as! [Any])

        if self.recentArray.count != 0 || self.groupArray.count != 0 {
            self.searchTF.becomeFirstResponder()
        }
        searchTableView.register(UINib(nibName: "BlockCell", bundle: nil), forCellReuseIdentifier: "BlockCell")
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "no_contact")
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    func configList()  {
        self.recentArray.removeAllObjects()
        self.groupArray.removeAllObjects()
        self.searchArray.removeAllObjects()
        self.channelArray.removeAllObjects()
        self.recentArray = localDB.getSearchRecent()
        self.groupArray = groupDB.getSearchGroupList()
        self.channelArray = channelDB.getSearchChannel(type: "search")

        if self.recentArray.count != 0 && self.groupArray.count == 0 {
            self.addToArray(name:"recent" , list: self.recentArray)
        }else if self.recentArray.count == 0 && self.groupArray.count != 0{
            self.addToArray(name: "group", list: self.groupArray)
        }else if self.recentArray.count != 0 && self.groupArray.count != 0{
            self.addToArray(name:"recent" , list: self.recentArray)
            self.addToArray(name: "group", list: self.groupArray)
        }
        if self.channelArray.count != 0 {
            self.addToArray(name: "channel", list: self.channelArray)
        }
        self.checkAvailablity()
    }
    func addToArray(name:String,list:NSArray){
        let dict = NSMutableDictionary()
        dict.setValue(Utility.shared.getLanguage()?.value(forKey: name) as! String, forKey: "title")
        dict.setValue(list, forKey: "list")
        self.searchArray.add(dict)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.searchArray.count
    }
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        let msgDict:NSDictionary = self.searchArray.object(at: section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath) as! BlockCell
        if self.searchArray.count != 0{
        let msgDict:NSDictionary = self.searchArray.object(at: indexPath.section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        let contactDict:NSDictionary =  listArray.object(at: indexPath.row) as! NSDictionary
        cell.configSearch(contactDict: contactDict, index: indexPath, recentArray: self.recentArray, overAllArray: self.overAllArray)
        cell.profileBtn.tag = indexPath.row
        selectedSection = indexPath.section
        cell.profileBtn.addTarget(self, action: #selector(goToProfilePopup), for: .touchUpInside)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchTF.resignFirstResponder()
        let msgDict:NSDictionary = self.searchArray.object(at: indexPath.section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        let dict:NSDictionary =  listArray.object(at: indexPath.row) as! NSDictionary
        let viewType:String = dict.value(forKey: "search_type") as! String

        if viewType == "contact" {
            let detailObj = ChatDetailPage()
            detailObj.contact_id = dict.value(forKey: "user_id") as! String
            detailObj.viewType = "3"
            self.navigationController?.pushViewController(detailObj, animated: true)
        }else if viewType == "group"{
            let detailObj = GroupChatPage()
            detailObj.group_id = dict.value(forKey: "group_id") as! String
            self.navigationController?.pushViewController(detailObj, animated: true)
        }else if viewType == "channel"{
            let status:String = dict.value(forKey: "subscribtion_status") as! String
            if status == "0" {
                let subscriberObj = SuccessPage()
                subscriberObj.detailsDict = dict
                subscriberObj.viewType = "1"
                self.navigationController?.pushViewController(subscriberObj, animated: true)
            }else{
                let detailObj = ChannelChatPage()
                detailObj.channel_id = dict.value(forKey: "search_id") as! String
                self.navigationController?.pushViewController(detailObj, animated: true)
            }
        }
 
    }
    
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dict:NSDictionary = self.searchArray.object(at: section) as! NSDictionary
        return dict.value(forKey: "title") as? String
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if UserModel.shared.getAppLanguage() == "عربى" {
             let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
             header.textLabel?.textAlignment = NSTextAlignment.right
             header.transform = CGAffineTransform(scaleX: -1, y: 1)
            
        //header.textLabel?.font = UIFont(name: "YourFontname", size: 14.0)
             
        }
        else{
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            header.textLabel?.textAlignment = NSTextAlignment.left
            header.transform = .identity
            //header.textLabel?.font = UIFont(name: "YourFontname", size: 14.0)
        }

    }
    
    
    //profile popup
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        let popup = ProfilePopup()
        popup.delegate = self
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.searchTableView)
        let indexPath = self.searchTableView.indexPathForRow(at: buttonPosition)!
        let sectionDict:NSDictionary = self.searchArray.object(at: indexPath.section) as! NSDictionary
        let listArray:NSArray = sectionDict.value(forKey: "list") as! NSArray
       
        let msgDict:NSDictionary = listArray.object(at: sender.tag) as! NSDictionary
        let viewType:String = msgDict.value(forKey: "search_type") as! String
        
        if viewType == "contact" {
            popup.profileDict = msgDict
            popup.modalPresentationStyle = .overCurrentContext
            popup.modalTransitionStyle = .crossDissolve
            self.navigationController?.present(popup, animated: true, completion: nil)
        }else if viewType == "group"{
            popup.group_id = msgDict.value(forKey: "group_id") as! String
            popup.viewType = "1"
            popup.modalPresentationStyle = .overCurrentContext
            popup.modalTransitionStyle = .crossDissolve
            self.navigationController?.present(popup, animated: true, completion: nil)
        }
       
    }
    
    func popupDismissed() {
        //socketClass.sharedInstance.delegate =  self
    }
    
    //check contacts available or not
    func checkAvailablity()  {
        if searchArray.count == 0 {
            self.searchTableView.isHidden = true
            self.noView.isHidden = false
        }else{
            self.searchTableView.isHidden = false
            self.searchTableView.reloadData()
            self.noView.isHidden = true
        }
    }
    
    //MARK: Textfield delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchTableView.isHidden = false
        configList()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        if self.searchArray.count == 0 {
            self.searchTableView.isHidden = true
        }else{
            self.searchTableView.isHidden = false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if overAllArray.count == 0 {
        } else {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            searchTableView.isHidden = true
            recentArray.removeAllObjects()
            channelArray.removeAllObjects()
            groupArray.removeAllObjects()
            searchArray.removeAllObjects()
            // remove all data that belongs to previous search
            if (newString == "") || newString == nil {
                searchTableView.isHidden = false
                configList()
                return true
            }
            var counter: Int = 0
            for dict in overAllArray {
                let tempArray = NSMutableArray.init(array: [dict])
                var tempDict = NSDictionary()
                tempDict = tempArray.object(at: 0) as! NSDictionary
                let searchName = tempDict.value(forKey: "search_name") as! String
                let searchType = tempDict.value(forKey: "search_type") as! String

                let range = searchName.range(of: newString!, options: NSString.CompareOptions.caseInsensitive, range: nil,locale: nil)
                if range != nil {
                    if searchType == "contact"{
                        self.recentArray.add(dict)
                    }else if searchType == "group"{
                        self.groupArray.add(dict)
                    }else if searchType == "channel"{
                        self.channelArray.add(dict)
                    }
                }
                counter += 1
            }
            if self.recentArray.count != 0{
                self.addToArray(name: "recent", list:self.recentArray)
            }
            if self.groupArray.count != 0{
                self.addToArray(name: "group", list:self.groupArray)
            }
            if self.channelArray.count != 0{
                self.addToArray(name: "channel", list:self.channelArray)
            }
            self.checkAvailablity()
        }
        return true
    }
    
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.searchTableView.frame.size.height = FULL_HEIGHT-self.navigationView.frame.size.height
        self.searchTableView.frame.size.height -= keyboardFrame.height
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.searchTableView.frame.size.height += keyboardFrame.height
    }
}
