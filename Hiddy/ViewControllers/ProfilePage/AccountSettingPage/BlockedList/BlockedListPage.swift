//
//  BlockedListPage.swift
//  Hiddy
//
//  Created by APPLE on 12/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit


class BlockedListPage: UIViewController,UITableViewDelegate,UITableViewDataSource, picPopUpDelegate {

    @IBOutlet var navigationView: UIView!
    @IBOutlet var titileLbl: UILabel!
    @IBOutlet var blockedTableView: UITableView!
    var blockedArray = NSMutableArray()
    @IBOutlet var noResultView: UIView!
    @IBOutlet var noresultLbl: UILabel!
    
    let localDB = LocalStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titileLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titileLbl.textAlignment = .right
            self.noresultLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.titileLbl.textAlignment = .left
            self.titileLbl.transform = .identity
            self.noresultLbl.transform = .identity
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        // self.view.blurEffect()
        let profileDict =  self.blockedArray.object(at: sender.tag) as! NSDictionary
        let popup = ProfilePopup()
        popup.profileDict = profileDict
        popup.delegate = self
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
    func popupDismissed() {
        
    }
    //MARK: Initial setup
    func initialSetUp(){
        self.navigationView.elevationEffect()
        self.titileLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "blocked_contacts")
        blockedTableView.register(UINib(nibName: "BlockCell", bundle: nil), forCellReuseIdentifier: "BlockCell")
        self.noresultLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "user_not_blocked")
        self.blockedArray = localDB.getBlockedList()
        self.checkAvailablity()
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //check user availablity
    func checkAvailablity()  {
        if self.blockedArray.count == 0 {
            self.noResultView.isHidden = false
        }else{
            self.noResultView.isHidden = true
            self.blockedTableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.blockedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath) as! BlockCell
            let blockDict:NSDictionary =  self.blockedArray.object(at: indexPath.row) as! NSDictionary
        cell.config(contactDict: blockDict)
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.addTarget(self, action: #selector(goToProfilePopup(_:)), for: .touchUpInside)
        return cell
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return YES if you want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let blockDict:NSDictionary =  self.blockedArray.object(at: indexPath.row) as! NSDictionary
        
        let editAction = UITableViewRowAction(style: .normal, title: "Unblock") { (rowAction, indexPath) in
            //TODO: edit the row at indexPath here
            let contact_id:String = blockDict.value(forKey: "user_id") as! String
            socketClass.sharedInstance.blockContact(contact_id: contact_id, type: "unblock")
            self.blockedArray.remove(blockDict)
            self.blockedTableView.reloadData()
            self.checkAvailablity()
        }
        editAction.backgroundColor = SECONDARY_COLOR
        
        return [editAction]
    }
    
    
   
    
}
