//
//  ChoosePopup.swift
//  Hiddy
//
//  Created by APPLE on 12/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

protocol privacyDelegate {
    func dismissWithDetails(viewType:String,selection:String)
}

class ChoosePopup: UIViewController {

    @IBOutlet var popupView: UIView!
    @IBOutlet var popupTitleLbl: UILabel!
    @IBOutlet var everyOneLbl: UILabel!
    @IBOutlet var mycontactsLbl: UILabel!
    @IBOutlet var nobodyLbl: UILabel!
    @IBOutlet var everyOneSelView: UIView!
    @IBOutlet var contactsSelView: UIView!
    @IBOutlet var nobodySelView: UIView!
    var viewType = String()
    var selection = String()
    var delegate:privacyDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.popupView.backgroundColor = BOTTOM_BAR_COLOR
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    //initial setup
    func initialSetup()  {
        self.popupView.cornerViewMiniumRadius()
        if self.viewType == "1"{
            self.popupTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "last_seen")
        }else if self.viewType == "2"{
            self.popupTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "profile_pic")
        }else if self.viewType == "3"{
            self.popupTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .center, text: "about")
        }
        
        self.everyOneLbl.config(color: TEXT_SECONDARY_COLOR, size: 18, align: .left, text: "everyone")
        self.nobodyLbl.config(color: TEXT_SECONDARY_COLOR, size: 18, align: .left, text: "nobody")
        self.mycontactsLbl.config(color: TEXT_SECONDARY_COLOR, size: 18, align: .left, text: "mycontacts")

        if selection == Utility.shared.getLanguage()?.value(forKey: "everyone") as! String {
            self.selectView(selview: everyOneSelView)
        }else if selection == Utility.shared.getLanguage()?.value(forKey: "mycontacts") as! String {
            self.selectView(selview: contactsSelView)
        }else if selection == Utility.shared.getLanguage()?.value(forKey: "nobody") as! String {
            self.selectView(selview: nobodySelView)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissView (_:)))
        self.view.addGestureRecognizer(tap)
    }

    func selectView(selview:UIView)  {
        self.everyOneSelView.backgroundColor = BACKGROUND_COLOR
        self.contactsSelView.backgroundColor = BACKGROUND_COLOR
        self.nobodySelView.backgroundColor = BACKGROUND_COLOR
        self.everyOneSelView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.contactsSelView.setViewBorder(color: SELECTION_BORDER_COLOR)
        self.nobodySelView.setViewBorder(color: SELECTION_BORDER_COLOR)
        selview.backgroundColor = SECONDARY_COLOR
    }

    @IBAction func everyOneBtnTapped(_ sender: Any) {
        self.selectView(selview: everyOneSelView)
        self.delegate?.dismissWithDetails(viewType: self.viewType, selection: Utility.shared.getLanguage()?.value(forKey: "everyone") as! String)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func myContactsBtnTapped(_ 
        sender: Any) {
        self.selectView(selview: contactsSelView)
        self.delegate?.dismissWithDetails(viewType: self.viewType, selection: Utility.shared.getLanguage()?.value(forKey: "mycontacts") as! String)
        self.dismiss(animated: true, completion: nil)
    }
  
    @IBAction func nobodyBtnTapped(_ sender: Any) {
        self.selectView(selview: nobodySelView)
        self.delegate?.dismissWithDetails(viewType: self.viewType, selection: Utility.shared.getLanguage()?.value(forKey: "nobody") as! String)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //dismiss view
    @objc func dismissView(_ sender: UITapGestureRecognizer) {
      self.dismiss(animated: true, completion: nil)
    }
    
}
