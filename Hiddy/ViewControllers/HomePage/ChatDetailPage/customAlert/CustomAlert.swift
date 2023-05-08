//
//  CustomAlert.swift
//  Hiddy
//
//  Created by APPLE on 05/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

protocol alertDelegate {
    func alertActionDone(type:String)
}


class CustomAlert: UIViewController {

    @IBOutlet var alertPopView: UIView!
    @IBOutlet var msgLbl: UILabel!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var okayBtn: UIButton!
    
    var alertType = String()
    var msg = String()
    var alignmentTag = 0
    var delegate:alertDelegate?
    var viewType = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
        self.initialSetup()
        self.changeRTL()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.alertPopView.backgroundColor = BACKGROUND_COLOR
    }
    func changeRTL() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.msgLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.okayBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.cancelBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.view.transform = .identity
            self.msgLbl.transform = .identity
            self.okayBtn.transform = .identity
            self.cancelBtn.transform = .identity
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        self.okayBtn.applyGradient()
        self.okayBtn.bringSubviewToFront(self.okayBtn.titleLabel!)
    }
    
    //initial set up
    func initialSetup()  {
        self.alertPopView.viewRadius(radius: 15)
        self.msgLbl.config(color: TEXT_PRIMARY_COLOR, size: 19, align: .center, text: EMPTY_STRING)
        self.msgLbl.attributed(text:msg)        
        self.okayBtn.cornerRoundRadius()
        self.cancelBtn.cornerRoundRadius()

        self.okayBtn.config(color: .white, size: 17, align: .center, title: "sure")
        self.cancelBtn.config(color: .white, size: 17, align: .center, title: "nope")
        self.cancelBtn.backgroundColor = .lightGray
        
        //tap to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss (_:)))
        self.view.addGestureRecognizer(tap)
        }
   
    
    //dismiss view
    @objc func dismiss(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
            self.dismiss(animated: true, completion: nil)
        }, completion: nil)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.alertActionDone(type: self.viewType)
    }
}
