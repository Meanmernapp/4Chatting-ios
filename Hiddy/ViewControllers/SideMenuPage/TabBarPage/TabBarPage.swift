//
//  TabBarPage.swift
//  Hiddy
//
//  Created by APPLE on 29/05/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import AVFoundation

class TabBarPage: UITabBarController,UITabBarControllerDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var navigationView: UIView!
    var type = String()
    var id = String()
    var isSelectedNotification = "0"
    var darkMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        self.configureTabBarView()
        
    }
    override func viewDidLayoutSubviews() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.darkMode = false
        if UserModel.shared.getAppLanguage() == "عربى" {
//            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.tabBar.semanticContentAttribute = .unspecified
        }
        else {
//            self.view.transform = .identity
            self.tabBar.semanticContentAttribute = .unspecified
        }
        // print("viewwillappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.updateTheme()

        // print("viewdidappear")
    }
    // MARK: setup tab bar colors
    func configureTabBarView()  {
        self.tabBar.backgroundColor = BACKGROUND_COLOR
        self.tabBar.barTintColor = BACKGROUND_COLOR
        self.ConfigureView()
    }
    //MARK: setup bottom tab bar
    func ConfigureView() {
        //home view
        let homeViewController = HomePage()
        self.config(viewController: homeViewController, selImg:#imageLiteral(resourceName: "tab_selected_home"),unselectImg:#imageLiteral(resourceName: "tab_unselect_home"), index: 0)
        //group view
        let gropVC = GroupPage()
        self.config(viewController: gropVC, selImg: #imageLiteral(resourceName: "tab_selected_user"),unselectImg:#imageLiteral(resourceName: "tab_unselect_user"), index: 1)
        // channel view
        let channelVC = ChannelPage()
        self.config(viewController:channelVC,selImg:#imageLiteral(resourceName: "tab_selected_channel"),unselectImg:#imageLiteral(resourceName: "tab_unselect_channel"), index: 2)
        // call view
        let callVC = CallsPage()
        self.config(viewController:callVC,selImg:#imageLiteral(resourceName: "tab_selected_call"),unselectImg:#imageLiteral(resourceName: "tab_unselect_call"), index: 3)
//        //profile view
//        let profileVC = HomePage()
//        self.config(viewController: profileVC,  selImg: #imageLiteral(resourceName: "tab_selected_profile"),unselectImg:#imageLiteral(resourceName: "tab_unselect_profile"))

        // add view controller to tab bar array
        let tabBarList = [homeViewController,gropVC,channelVC,callVC]
        viewControllers = tabBarList
        
        self.isSelectedNotification = UserModel.shared.notificationID() as String? ?? "0"
        self.selectedIndex  = UserModel.shared.tabIndex()
        self.checkNotificationStatus()

    }
    func checkNotificationStatus() {
        if isSelectedNotification == "1" {
            UserModel.shared.setnotificationID(id: "0")
            if self.selectedIndex == 0 {
                let detailObj = ChatDetailPage()
                detailObj.contact_id = UserModel.shared.notificationPrivateID() as String? ?? ""
                detailObj.viewType = "0"
                self.navigationController?.pushViewController(detailObj, animated: true)
                
            }
            else if self.selectedIndex == 1 {
                let detailObj = GroupChatPage()
                detailObj.viewType = "2"
                detailObj.group_id = UserModel.shared.notificationGroupID() as String? ?? ""
                self.navigationController?.pushViewController(detailObj, animated: true)
            }
            else if self.selectedIndex == 2 {
                let detailObj = ChannelChatPage()
                detailObj.channel_id = UserModel.shared.notificationChannelID() as String? ?? ""
                self.navigationController?.pushViewController(detailObj, animated: true)
            }
            else {
            }

        }
    }

    //configure tabBarItem
    func config(viewController:UIViewController,selImg:UIImage, unselectImg:UIImage,index:Int) {
        let iconImageView = UIImageView()
        iconImageView.image = unselectImg
       let customBarItem = UITabBarItem.init(title: "", image: unselectImg, selectedImage: selImg.withRenderingMode(.alwaysOriginal))
        // change and adjust center icon by using image insets
        customBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        viewController.tabBarItem = customBarItem
    }
    
   //table view delegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        DispatchQueue.main.async {
        //apply spring animation
        let index = self.tabBar.items?.index(of: item)
        let subView = tabBar.subviews[index!+1].subviews.first as! UIImageView
        self.performSpringAnimation(imgView: subView)
        }
    }
    
    //func to perform spring animation on imageview
    func performSpringAnimation(imgView: UIImageView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            imgView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            //reducing the size
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in
        }
    }
   
}
