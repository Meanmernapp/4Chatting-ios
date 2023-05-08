//
//  AppUpdate.swift
//  Hiddy
//
//  Created by APPLE on 30/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
protocol updateDelegate {
    func updateDismiss()
}
class AppUpdate: UIViewController {
    @IBOutlet var updateBtn: UIButton!
    @IBOutlet var infoLbl: UILabel!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var bgView: UIView!
  
    var viewType = String()
    var delegate:updateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func viewDidLayoutSubviews() {
        self.view.applyGradient()
        self.view.bringSubviewToFront(self.bgView)
        self.updateBtn.applyGradient()
        self.updateBtn.bringSubviewToFront(self.updateBtn.titleLabel!)
    }
    
    //initial set up
    func initialSetup()  {
        self.bgView.viewRadius(radius: 15)
        self.infoLbl.config(color: TEXT_PRIMARY_COLOR, size: 19, align: .center, text: "version_update")
        self.cancelBtn.config(color: .white, size: 19, align: .center, title: "cancel")
        self.updateBtn.config(color: .white, size: 19, align: .center, title: "update")
        
        self.updateBtn.cornerRoundRadius()
        self.cancelBtn.cornerRoundRadius()
        
        self.cancelBtn.backgroundColor = .lightGray
        if viewType == "1"{
            self.cancelBtn.isHidden = true
        }
        
    }
    

    @IBAction func updateBtnTapped(_ sender: Any) {
        
        if let url = URL(string: ITUNES_URL),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }

    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.delegate?.updateDismiss()
    }
    
}
