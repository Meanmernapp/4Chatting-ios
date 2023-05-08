//
//  HelpPage.swift
//  Hiddy
//
//  Created by APPLE on 29/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit

class HelpPage: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet var navigationView: UIView!
    @IBOutlet var helpTableView: UITableView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var noView: UIView!
    @IBOutlet var noLbl: UILabel!
    
    var helpArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        setNeedsStatusBarAppearanceUpdate()
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            // self.noLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.noLbl.transform = .identity
            // self.noLbl.textAlignment = .left
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
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "help")
        self.noView.isHidden = true
        helpTableView.register(UINib(nibName: "HelpCell", bundle: nil), forCellReuseIdentifier: "HelpCell")
        let serviceObj = UserWebService()
        serviceObj.helpDetails(onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                self.addToArray(name: "terms", list: response.value(forKey: "terms") as! NSArray)
                self.addToArray(name: "help", list: response.value(forKey: "faq") as! NSArray)
                self.checkAvailablity()
            }
        })
    }
    func addToArray(name:String,list:NSArray)  {
        let dict = NSMutableDictionary()
        dict.setValue(Utility.shared.getLanguage()?.value(forKey: name), forKey: "title")
        dict.setValue(list, forKey: "list")
        self.helpArray.add(dict)
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.helpArray.count
    }
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        let msgDict:NSDictionary = self.helpArray.object(at: section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msgDict:NSDictionary = self.helpArray.object(at: indexPath.section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath) as! HelpCell
        let contactDict:NSDictionary =  listArray.object(at: indexPath.row) as! NSDictionary
        cell.helpTitleLbl.text = contactDict.value(forKey: "title") as? String
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msgDict:NSDictionary = self.helpArray.object(at: indexPath.section) as! NSDictionary
        let listArray:NSArray = msgDict.value(forKey: "list") as! NSArray
        let dict:NSDictionary =  listArray.object(at: indexPath.row) as! NSDictionary
        let webView = ContentWebPage()
        webView.helpDict = dict
        webView.modalPresentationStyle = .fullScreen
        self.navigationController?.present(webView, animated: true, completion: nil)
        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dict:NSDictionary = self.helpArray.object(at: section) as! NSDictionary

        let headerView = UIView()
        headerView.backgroundColor = BACKGROUND_COLOR
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 20, width:
            tableView.bounds.size.width, height: 20))
        headerLabel.font = UIFont(name: APP_FONT_REGULAR, size: 22)
        headerLabel.textColor = TEXT_TERTIARY_COLOR
        headerLabel.text = dict.value(forKey: "title") as? String
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    //check contacts available or not
    func checkAvailablity()  {
        if helpArray.count == 0 {
            self.helpTableView.isHidden = true
            self.noView.isHidden = false
        }else{
            self.helpTableView.isHidden = false
            self.helpTableView.reloadData()
            self.noView.isHidden = true
        }
    }

}
