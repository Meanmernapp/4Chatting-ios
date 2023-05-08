//
//  ChooseLanguage.swift
//  Hiddy
//
//  Created by APPLE on 16/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import Alamofire

protocol languageDelegate {
    func selectedLanguage(language:String)
}

protocol noneDelegate {
    func forcheck(type:String)
}

class ChooseLanguage: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var selectLbl: UILabel!
    @IBOutlet var languageTableView: UITableView!
    var languageArray = NSMutableArray()
    var selectedLanguage = String()
    var delegate:languageDelegate?
    var languageCodeArr = ["en","fr"]
    var viewType = String()
    
    var translateLanguageCode = String()

    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var navigationView: UIView!
    var translateArray:[SwiftGoogleTranslate.Language]?
    
    var noneDelegate:noneDelegate?
    var newVal = ""
    let chatDetail = ChatDetailPage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.selectLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.selectLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.selectLbl.transform = .identity
            self.selectLbl.textAlignment = .left
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialSetup()  {
        loader.color = SECONDARY_COLOR

        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.languageTableView.backgroundColor = BACKGROUND_COLOR
        self.translateLanguageCode = UserModel().translatedLanguage()!
        self.navigationView.elevationEffect()
        if !UIDevice.current.hasNotch{
//            self.titleLbl.frame = CGRect(x: self.titleLbl.frame.origin.x, y: self.titleLbl.frame.origin.y, width: self.titleLbl.frame.width, height: 30)
            self.navigationView.frame = CGRect(x: self.navigationView.frame.origin.x, y: self.navigationView.frame.origin.y, width: self.navigationView.frame.width, height:70)
        }
        self.selectLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: "select_language")
        languageTableView.register(UINib(nibName: "languageCell", bundle: nil), forCellReuseIdentifier: "languageCell")
        
        if viewType == "translate"{
            self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "language")
            print("translate")
            self.getSupportedLanguages()
        }else if viewType == "theme"{
            self.selectLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: "select_theme")
            self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "change_theme")
            print("translate")
            languageArray = [Utility.language?.value(forKey: "dark")! ?? "",Utility.language?.value(forKey: "light")! ?? "",Utility.language?.value(forKey: "system_default")! ?? ""]
            self.languageTableView.delegate = self
            self.languageTableView.dataSource = self
            self.languageTableView.reloadData()
            self.selectedLanguage = UserModel.shared.theme()! as String
        }else{
            self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "app_language")
            languageArray = ["English","Française"]
            self.languageTableView.delegate = self
            self.languageTableView.dataSource = self
            self.languageTableView.reloadData()
            self.selectedLanguage = UserModel.shared.getAppLanguage()!
        }
    }
    
    
    func getSupportedLanguages(){
        SwiftGoogleTranslate.shared.start(with: GOOGLE_API_KEY)
        SwiftGoogleTranslate.shared.languages { (languages, error) in
            if let languages = languages {
                DispatchQueue.main.async {
                    self.translateArray = languages
                    print("call tranlate \(languages)")
                    self.languageTableView.delegate = self
                    self.languageTableView.dataSource = self
                    self.languageTableView.reloadData()
                }
                
            }else{
                print("error tranlate \(error?.localizedDescription)")
            }
        }
        
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        /*
        if viewType == "translate"{
            return self.translateArray!.count
        }
        
        return self.languageArray.count
         */
        
        if viewType == "translate"{
            if section == 0 {
            return 1
            }
            return self.translateArray!.count
        }
         else if viewType == "theme"{
            if section == 0 {
            return 0
            }
        } else {
            if section == 0 {
            return 0
            }
        }
        return self.languageArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath) as! languageCell
        if viewType == "translate"{
            /*
            let modal = self.translateArray![indexPath.row]
            cell.languageNameLbl.text = modal.name
            if self.translateLanguageCode == modal.language{
                cell.selctionView.applyGradient()
            }else if self.translateLanguageCode != modal.language{
                cell.selctionView.removeGrandient()
            }
             */
            if indexPath.section == 0{
                cell.languageNameLbl.text = "None"
                self.chatDetail.isTranslate = false
                if self.translateLanguageCode == "none"{
                    self.chatDetail.isTranslate = false
                    cell.selctionView.applyGradient()
                }
            }else{
                let modal = self.translateArray![indexPath.row]
                cell.languageNameLbl.text = modal.name
                if self.translateLanguageCode == modal.language{
                    cell.selctionView.applyGradient()
                }else if self.translateLanguageCode != modal.language{
                    cell.selctionView.removeGrandient()
                }
            }
        }else{
            let language :String = self.languageArray.object(at: indexPath.row) as! String
            cell.languageNameLbl.text = language
            if self.selectedLanguage == language{
                cell.selctionView.applyGradient()
            }else if self.selectedLanguage != language{
                cell.selctionView.removeGrandient()
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewType == "translate"{
            /*
            let modal = self.translateArray![indexPath.row]
            self.translateLanguageCode = modal.language
            UserModel.shared.setTranslated(language: modal.language)
             */
            if indexPath.section == 0 {
                self.chatDetail.isTranslate = false
                self.newVal = "none"
                self.translateLanguageCode = "none"
                UserModel.shared.setNone(language: "none")
                UserModel.shared.setTranslated(language: "none")
                self.noneDelegate?.forcheck(type: "none")
            }else{
                let modal = self.translateArray![indexPath.row]
                self.translateLanguageCode = modal.language
                UserModel.shared.setTranslated(language: modal.language)
                self.noneDelegate?.forcheck(type: modal.language)
            }
        }else if viewType == "theme"{
            let theme :String = self.languageArray.object(at: indexPath.row) as! String
            self.selectedLanguage = theme
            UserModel.shared.set(theme:theme as NSString)
        }else{
            self.loader.startAnimating()
            let language :String = self.languageArray.object(at: indexPath.row) as! String
            self.selectedLanguage = language
            UserModel.shared.setLanguage(lang: self.languageCodeArr[indexPath.row])
//            UserModel.shared.LANGUAGE_CODE = self.languageCodeArr[indexPath.row]
            UserModel.shared.LANGUAGE_CODE = UserModel.shared.getLanguage() ?? "en"
            self.delegate?.selectedLanguage(language: language)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
