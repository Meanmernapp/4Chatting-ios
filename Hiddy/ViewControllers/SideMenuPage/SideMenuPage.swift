//
//  SideMenuPage.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 15/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit
import Social
import JJFloatingActionButton

class SideMenuPage: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet var editdesLbl: UILabel!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var profileImgView: UIImageView!
    @IBOutlet var menuTableView: UITableView!
    var menuArray = NSMutableArray()
    var isLiveAdded = false
//    let actionButton = UIButton()
    let actionButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()

        self.setupInitialDetails()
        self.configureMenuDetails()
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.usernameLbl.frame = CGRect(x: 100, y: 53, width: 150, height: 30)
            self.editdesLbl.frame = CGRect(x: 100, y: 82, width: 150, height: 30)
            
            self.profileImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.usernameLbl.transform = .identity
            self.editdesLbl.transform = .identity
            self.profileImgView.transform = .identity
        }
    }
    
    //MARK: intital details
    func setupInitialDetails()  {
        self.menuTableView.backgroundColor = BACKGROUND_COLOR

        self.usernameLbl.config(color: .white, size: 27, align: .left, text: EMPTY_STRING)
        self.usernameLbl.text = UserModel.shared.userName() as String?
        self.editdesLbl.config(color: .white, size: 18, align: .left, text: "view_edit")
        if (UserModel.shared.getProfilePic() != nil) {
            self.profileImgView.sd_setImage(with: URL(string: "\(IMAGE_BASE_URL)\(USERS_SUB_URL)\(UserModel.shared.getProfilePic()! as String)"), placeholderImage: #imageLiteral(resourceName: "profile_placeholder"))
        }
        self.profileImgView.rounded()
//        self.configFloatingBtn()
        
    }
    func configFloatingBtn()  {
        
//        if actionButton != nil {
//        actionButton.removeFromSuperview()
//        }
        if IS_IPHONE_X{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-130, y: FULL_HEIGHT-70, width: 30, height: 30)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-130, y: FULL_HEIGHT-50, width: 30, height: 30)
        }
        //actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.backgroundColor = .clear
//        actionButton.contentMode = .scaleAspectFit
//        actionButton.buttonImage = #imageLiteral(resourceName: "SideClose")
        actionButton.setImage(#imageLiteral(resourceName: "SideClose"), for: .normal)
        actionButton.imageEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        //let layer = Utility.shared.gradient1(size: actionButton.frame.size)
        //layer.cornerRadius = actionButton.frame.size.height / 2
        //actionButton.layer.addSublayer(layer)
        //actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    @objc func cancelButtonTapped()  {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
//        print("jdkajfdklajdlk")
    }
    
    //MARK: custom menu details
    func configureMenuDetails()  {
        menuArray.removeAllObjects()
        menuTableView.register(UINib(nibName: "MenuTableCell", bundle: nil), forCellReuseIdentifier: "MenuTableCell")
        if isLiveAdded {
            self.addMenu(menu_name: "live")
            self.addMenu(menu_name: "my_videos")
        }
        self.addMenu(menu_name: "my_channels" )
        self.addMenu(menu_name: "ac_setting")
        self.addMenu(menu_name: "invite_frd")
        self.addMenu(menu_name: "help")
        menuTableView.reloadData()
    }
    
    // adding menu objects to array
    func addMenu(menu_name:String) {
        let menuDict  = NSMutableDictionary()
        menuDict.setValue(menu_name, forKey: "menu_name")
        menuArray.addObjects(from: [menuDict])
    }
    
    //go to profile page
    @IBAction func profileBtnTapped(_ sender: Any) {
        let profileObj = ProfilePage()
        profileObj.viewType = "own"
        profileObj.contactName = self.usernameLbl.text!
        self.navigationController?.pushViewController(profileObj, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profileCell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell", for: indexPath) as! MenuTableCell
        let menuDict:NSDictionary =  menuArray.object(at: indexPath.row) as! NSDictionary
        profileCell.configCell(menuDict: menuDict)
        return profileCell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        if isLiveAdded {
        
           /* if indexPath.row == 0{
                let liveObj = LiveListPage()
                self.navigationController?.pushViewController(liveObj, animated: true)
            }else if indexPath.row == 1{
                let videoObj = UserVideoListPage()
                self.navigationController?.pushViewController(videoObj, animated: true)
            }else if indexPath.row == 2{
                let myChannel = MyChannelList()
                self.navigationController?.pushViewController(myChannel, animated: true)
            }else  if indexPath.row == 3{
                let settingObj = AccountSettingPage()
                self.navigationController?.pushViewController(settingObj, animated: true)
            }else  if indexPath.row == 4{
                self.shareHiddy()
            }else  if indexPath.row == 5{
                let helpObj = HelpPage()
                self.navigationController?.pushViewController(helpObj, animated: true)
            }*/
        }else{
            if indexPath.row == 0{
                let myChannel = MyChannelList()
                self.navigationController?.pushViewController(myChannel, animated: true)
            }else  if indexPath.row == 1{
                let settingObj = AccountSettingPage()
                self.navigationController?.pushViewController(settingObj, animated: true)
            }else  if indexPath.row == 2{
                self.shareHiddy()
            }else  if indexPath.row == 3{
                let helpObj = HelpPage()
                self.navigationController?.pushViewController(helpObj, animated: true)
            }
        }
        
    }
    
    func shareHiddy()  {
        let textToShare:String = Utility.shared.getLanguage()?.value(forKey: "share_msg") as! String
        if let myWebsite = NSURL(string: ITUNES_URL) {
            let objectsToShare = [textToShare, myWebsite, ActionExtensionBlockerItem()] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
