//
//  menuContainerPage.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 15/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit
import SidebarOverlay


class menuContainerPage: SOContainerViewController {

    var viewType = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        let homeObj = TabBarPage()
        let sideBar = SideMenuPage()
        if self.viewType == "share"{
            homeObj.selectedIndex = 0
        }
        self.topViewController = homeObj
        self.sideViewController = sideBar
        setNeedsStatusBarAppearanceUpdate()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.menuSide = .right
        }
        else {
            self.menuSide = .left
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
