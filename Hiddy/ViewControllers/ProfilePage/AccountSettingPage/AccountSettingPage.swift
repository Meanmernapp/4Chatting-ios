//
//  AccountSettingPage.swift
//  Hiddy
//
//  Created by APPLE on 11/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class AccountSettingPage: UIViewController,languageDelegate {

  
    @IBOutlet var navigationView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var privacyLbl: UILabel!
    @IBOutlet var changeNoLbl: UILabel!
    @IBOutlet var deleteAcLbl: UILabel!
    @IBOutlet var languageTitleLbl: UILabel!
    @IBOutlet var languageLbl: UILabel!
    
    @IBOutlet var themeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        print("cjdsvcvjdvcd")
        self.changeRTLView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.changeRTLView()
    }

    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            print("here comes cjdsvcvjdvcd")
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.privacyLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.privacyLbl.textAlignment = .right
            self.changeNoLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.changeNoLbl.textAlignment = .right
            self.deleteAcLbl.textAlignment = .right
            self.deleteAcLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.languageTitleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.languageTitleLbl.textAlignment = .right
            self.languageLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.languageLbl.textAlignment = .right
            self.themeLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.themeLbl.textAlignment = .right

        }
        else {
            self.view.transform = .identity
            self.themeLbl.textAlignment = .left
            self.themeLbl.transform = .identity

            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.privacyLbl.transform = .identity
            self.privacyLbl.textAlignment = .left
            self.languageTitleLbl.transform = .identity
            self.languageTitleLbl.textAlignment = .left
            self.changeNoLbl.textAlignment = .left
            self.changeNoLbl.transform = .identity
            self.deleteAcLbl.transform = .identity
            self.deleteAcLbl.textAlignment = .left
            self.languageLbl.transform = .identity
            self.languageLbl.textAlignment = .left

        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    //MARK: Initial setup
    func initialSetUp(){

        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 22, align: .left, text: "account")
        if !UIDevice.current.hasNotch {
//            self.titleLbl.frame = CGRect(x: self.titleLbl.frame.origin.x, y: self.titleLbl.frame.origin.y, width: self.titleLbl.frame.width, height: 32)
            self.navigationView.frame = CGRect(x: self.navigationView.frame.origin.x, y: self.navigationView.frame.origin.y, width: self.navigationView.frame.width, height:70)
        }
        self.themeLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "change_theme")
        self.changeNoLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "change_no")
        self.privacyLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "privacy")
        self.deleteAcLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "delete_ac")
        self.languageTitleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "language")
        self.languageLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .left, text: EMPTY_STRING)
        self.languageLbl.text = UserModel.shared.getAppLanguage()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func privacyBtnTapped(_ sender: Any) {
        let privacyObj = PrivacyPage()
        self.navigationController?.pushViewController(privacyObj, animated: true)
    }
    
    @IBAction func deleteAcBtnTapped(_ sender: Any) {
        let deleteObj = DeleteAccount()
        self.navigationController?.pushViewController(deleteObj, animated: true)
    }
    @IBAction func changeNoBtnTapped(_ sender: Any) {
        let noObj = ChangeNumber()
        self.navigationController?.pushViewController(noObj, animated: true)
    }
    @IBAction func languageBtnTapped(_ sender: Any) {

        let language = ChooseLanguage()
        language.delegate = self
        language.modalPresentationStyle = .fullScreen
        self.navigationController?.present(language, animated: true, completion:nil)
    }
      
    @IBAction func themeBtnTapped(_ sender: Any) {
        let language = ChooseLanguage()
        language.delegate = self
        language.viewType = "theme"
        language.modalPresentationStyle = .fullScreen
        self.navigationController?.present(language, animated: true, completion:nil)
    }
    
    func selectedLanguage(language: String) {
        DispatchQueue.main.async {
        //setup language
            if let languageCode = NSLinguisticTagger.dominantLanguage(for: language) {
                UserModel.shared.setAppLanguageCode(Language: languageCode)
                print(language)
            } else {
                print("Unknown language")
            }
        
        UserModel.shared.setAppLanguage(Language: language)
        Utility.shared.configureLanguage()
        Utility.shared.registerPushServices()
        self.languageLbl.text = UserModel.shared.getAppLanguage()
        self.initialSetUp()
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.setInitialViewController(initialView: menuContainerPage())
        }
    }
}
