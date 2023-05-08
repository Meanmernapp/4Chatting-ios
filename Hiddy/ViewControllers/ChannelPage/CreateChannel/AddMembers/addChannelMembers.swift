//
//  addChannelMembers.swift
//  Hiddy
//
//  Created by APPLE on 06/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class addChannelMembers: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,channelDelegate {
    var imageData:NSData?
    var name = String()
    var about = String()
    var type = String()
    var myContacts = NSMutableArray()
    var contactCopy = NSMutableArray()
    var isSearch = Bool()
    var selectedId = NSMutableArray()
    var selectedContacts = NSMutableArray()
    var previousID = NSMutableArray()
    var channel_id = String()
    let channelDB = ChannelStorage()
    var viewType = String()
    var backType = String()
    var memberAdded = false
    var subscriberArray = NSMutableArray()
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet weak var noView: UIView!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var contactTableView: UITableView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var barBtnView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var addContactLbl: UILabel!
    @IBOutlet var selectedCollectionView: UICollectionView!
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noView.isHidden = true
        //            let subscribers = channelDB.getSubscribedUsers(channel_id: self.channel_id)
        //            print(subscribers)
        // Do any additional setup after loading the view.
        self.initalSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.navigationView.backgroundColor = BOTTOM_BAR_COLOR
        self.topView.backgroundColor = BACKGROUND_COLOR
        self.bottomView.backgroundColor = BACKGROUND_COLOR
        self.contactTableView.backgroundColor = BACKGROUND_COLOR
        setNeedsStatusBarAppearanceUpdate()
        self.changeRTLView()
        if self.selectedContacts.count != 0 {
            let top = self.topView.frame.origin.y+self.topView.frame.size.height
            self.bottomView.frame = CGRect.init(x: 0, y: top, width: FULL_WIDTH, height: FULL_HEIGHT-top)
        }
        contactTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0); //values
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //initial setup
    func initalSetup(){
        loader.color = SECONDARY_COLOR

        channelSocket.sharedInstance.delegate = self
        isSearch = false
        self.getSubscriberList()
        self.navigationView.elevationEffect()
        self.titleLbl.config(color: TEXT_PRIMARY_COLOR, size: 20, align: .left, text: "create_channel")
        self.addContactLbl.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, text: "add_contact")
        self.countLbl.config(color: TEXT_PRIMARY_COLOR, size: 15, align: .left, text: EMPTY_STRING)
        
        self.searchTF.isHidden = true
        self.searchTF.clearButtonMode = .always
        self.searchTF.config(color: TEXT_PRIMARY_COLOR, size: 17, align: .left, placeHolder: "search")
        self.noLbl.config(color: TEXT_TERTIARY_COLOR, size: 17, align: .center, text: "no_contact")
        
        contactTableView.register(UINib(nibName: "createGroupCell", bundle: nil), forCellReuseIdentifier: "createGroupCell")
        selectedCollectionView.register(UINib(nibName: "selectedCell", bundle: nil), forCellWithReuseIdentifier: "selectedCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        selectedCollectionView.collectionViewLayout = flowLayout
        self.countLbl.text = "0 \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
        self.configFloatingBtn()
        
        //keyboard manager
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func getSubscriberList()  {
        let  channelObj = ChannelServices()
        self.loader.startAnimating()
        let localObj = LocalStorage()

        channelObj.subscriberids(channel_id: channel_id, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let ids:NSArray = response.value(forKey: "subscribers") as! NSArray
                if ids.count != 0{
                    self.subscriberArray.removeAllObjects()
                    self.subscriberArray.addObjects(from: ids as! [Any])
//                    self.checkAvailablity()
                    
                }
            }
            let myContact = localObj.getContactList()
            let copyContact = localObj.getContactList()

            for contact in myContact {
                let contactDict:NSDictionary =  contact as! NSDictionary
                let user_id :String = contactDict.value(forKey: "user_id") as? String ?? ""
                if self.subscriberArray.contains(user_id) {
                    myContact.remove(contact)
                    copyContact.remove(contact)
                }
//                for subscriber in self.subscriberArray {
//                    let sub = subscriber as! NSDictionary
//                    let subUserID = sub.value(forKey: "_id") as? String ?? ""
//                    if user_id == subUserID {
//                        myContact.remove(val)
//                        copyContact.remove(val)
//                    }
//                }
            }
            self.loader.stopAnimating()
            self.myContacts = myContact
            self.contactCopy = copyContact
            self.checkAvailablity()
        })
    }
    //config floating chat new btn
    func configFloatingBtn()  {
        let actionButton = JJFloatingActionButton()
        if UIDevice.current.hasNotch{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-120, width: 55, height: 55)
        }else{
            actionButton.frame = CGRect.init(x: FULL_WIDTH-75, y: FULL_HEIGHT-90, width: 55, height: 55)
        }
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.contentMode = .scaleAspectFit
        actionButton.buttonImage = #imageLiteral(resourceName: "next_arrow")
        let layer = Utility.shared.gradient(size: actionButton.frame.size)
        layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.addSublayer(layer)
        actionButton.bringSubviewToFront(actionButton.imageView)
        actionButton.addTarget(self, action: #selector(channelCreationTapped), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.titleLbl.textAlignment = .right
            self.titleLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.noLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            // self.noLbl.textAlignment = .right
            self.searchTF.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchTF.textAlignment = .right
            self.countLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.countLbl.textAlignment = .right
        }
        else {
            self.view.transform = .identity
            self.titleLbl.textAlignment = .left
            self.titleLbl.transform = .identity
            self.noLbl.transform = .identity
            // self.noLbl.textAlignment = .left
            self.searchTF.transform = .identity
            self.searchTF.textAlignment = .left
            self.countLbl.transform = .identity
            self.countLbl.textAlignment = .left
        }
    }
    //floating btn action
    @objc func channelCreationTapped()  {
        if Utility.shared.isConnectedToNetwork() {
            if selectedId.count == 0{
                self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "select_one") as? String)
            }else{
                if viewType == "1"{
                    channelSocket.sharedInstance.sendInvitation(channel_id: channel_id, subscriber: self.selectedId)
                    self.dismiss(animated: true, completion: nil)
                }else {
                    if !memberAdded{
                        channelSocket.sharedInstance.sendInvitation(channel_id: channel_id, subscriber: self.selectedId)
                        let chatPage = ChannelChatPage()
                        chatPage.viewType = "2"
                        chatPage.channel_id = channel_id
                        self.navigationController?.pushViewController(chatPage, animated: true)
                        memberAdded = true
                    }
                }
            }
        }else{
            self.view.makeToast(Utility.shared.getLanguage()?.value(forKey: "check_network") as? String)
        }
    }
    
    //back btn tapped
    @IBAction func backBtnTapped(_ sender: Any) {
        if isSearch {
            self.barBtnView.isHidden = false
            self.titleLbl.isHidden = false
            self.countLbl.isHidden = false
            self.searchTF.isHidden = true
            self.isSearch =  false
            self.searchTF.resignFirstResponder()
            contactTableView.isHidden = false
            myContacts = contactCopy.mutableCopy() as! NSMutableArray
            self.checkAvailablity()
            self.searchTF.resignFirstResponder()
        }else{
            if viewType == "1"{
                self.dismiss(animated: true, completion: nil)
            }else{
                for controller in self.navigationController!.viewControllers as Array {
                    if UserModel.shared.navType() == "1"{
                        if controller.isKind(of:MyChannelList.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }else{
                        if controller.isKind(of:menuContainerPage.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
        }
    }
    
    //search for contact
    @IBAction func searchBtnTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
            self.searchTF.isHidden = false
            self.barBtnView.isHidden = true
            self.titleLbl.isHidden = true
            self.countLbl.isHidden = true
            self.isSearch =  true
            self.searchTF.becomeFirstResponder()
        }, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        return self.myContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupCell", for: indexPath) as! createGroupCell
        if self.myContacts.count != 0{
        let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
        let user_id :String = contactDict.value(forKey: "user_id") as! String
        if self.selectedId.contains(user_id) {
            cell.selectionView.applyGradient()
        }else if !self.selectedId.contains(user_id){
            cell.selectionView.removeGrandient()
        }
        cell.tag = indexPath.row+100
        cell.config(contactDict:contactDict)
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.addTarget(self, action: #selector(goToProfilePopup), for: .touchUpInside)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactDict:NSDictionary =  self.myContacts.object(at: indexPath.row) as! NSDictionary
        let user_id :String = contactDict.value(forKey: "user_id") as! String
        let blockedMe = contactDict.value(forKey: "blockedByMe") as! String
        let isDeleted = contactDict.value(forKey: "isDelete") as! String
        if isDeleted == "0"{
        if blockedMe == "0"{
            let cell = view.viewWithTag(indexPath.row+100) as? createGroupCell
            if self.selectedId.contains(user_id) {
                self.selectedId.remove(user_id)
                cell?.selectionView.backgroundColor = .white
                cell?.selectionView.removeGrandient()
                self.selectedContacts.remove(contactDict)
            } else {
                self.selectedId.add(user_id)
                cell?.selectionView.applyGradient()
                self.selectedContacts.add(contactDict)
            }
            self.checkSelectionStatus()
        }
        else {
            self.searchTF.resignFirstResponder()
            let contact_name = contactDict.value(forKey: "contact_name") as! String
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "could_not_add"))!) \(contact_name)")
        }
        }else{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "deleted_account"))!)")
        }
    }
    
    func checkSelectionStatus()  {
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            if self.selectedContacts.count == 0 {
                self.topView.isHidden = true
                self.bottomView.frame = CGRect.init(x: 0, y: self.navigationView.frame.size.height+2, width: FULL_WIDTH, height: FULL_HEIGHT)
            }else{
                self.topView.isHidden = false
                let top = self.topView.frame.origin.y+self.topView.frame.size.height
                self.bottomView.frame = CGRect.init(x: 0, y: top, width: FULL_WIDTH, height: FULL_HEIGHT-top)
                self.selectedCollectionView.reloadData()
            }
            self.countLbl.text = "\(self.selectedContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "of"))!) \(self.myContacts.count) \((Utility.shared.getLanguage()?.value(forKey: "selected"))!)"
            
        }, completion: nil)
    }
    
    //profile popup
    @objc func goToProfilePopup(_ sender: UIButton!)  {
        var profileDict = NSDictionary()
        profileDict = self.myContacts.object(at: sender.tag) as! NSDictionary
        let popup = ProfilePopup()
        popup.profileDict = profileDict
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(popup, animated: true, completion: nil)
    }
    
    //MARK: Textfield delegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        contactTableView.isHidden = false
        myContacts = contactCopy.mutableCopy() as! NSMutableArray
        self.checkAvailablity()
        self.searchTF.resignFirstResponder()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if contactCopy.count == 0 {
        } else {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            contactTableView.isHidden = true
            myContacts.removeAllObjects()
            // remove all data that belongs to previous search
            if (newString == "") || newString == nil {
                contactTableView.isHidden = false
                myContacts = contactCopy.mutableCopy() as! NSMutableArray
                self.checkAvailablity()
                return true
            }
            var counter: Int = 0
            for dict in contactCopy {
                let tempArray = NSMutableArray.init(array: [dict])
                var tempDict = NSDictionary()
                tempDict = tempArray.object(at: 0) as! NSDictionary
                let searchName = tempDict.value(forKey: "contact_name") as! String
                
                let range = searchName.range(of: newString!, options: NSString.CompareOptions.caseInsensitive, range: nil,locale: nil)
                if range != nil {
                    print("available")
                    self.myContacts.add(dict)
                }
                counter += 1
            }
            self.checkAvailablity()
        }
        return true
    }
    
    //check contacts available or not
    func checkAvailablity()  {
        print("count \(myContacts.count)")

        if myContacts.count == 0 {
            addContactLbl.isHidden = true
            self.contactTableView.isHidden = true
            self.noView.isHidden = false
        }else{
            addContactLbl.isHidden = false
            self.contactTableView.isHidden = false
            self.contactTableView.reloadData()
            self.noView.isHidden = true
        }
        
    }
    
    
    //MARK: Collection view delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedCell", for: indexPath) as! selectedCell
        let userDict:NSDictionary =  selectedContacts.object(at: indexPath.row) as! NSDictionary
        cell.config(contactDict: userDict,type:"user")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userDict:NSDictionary =  selectedContacts.object(at: indexPath.row) as! NSDictionary
        let user_id :String = userDict.value(forKey: "user_id") as! String
        self.selectedContacts.remove(userDict)
        self.selectedId.remove(user_id)
        self.contactTableView.reloadData()
        self.checkSelectionStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    //MARK: Keyboard hide/show
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.contactTableView.frame.size.height = FULL_HEIGHT-self.navigationView.frame.size.height
        self.contactTableView.frame.size.height -= keyboardFrame.height
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.contactTableView.frame.size.height += keyboardFrame.height
    }
    
    //channel delegate
    func gotChannelInfo(dict: NSDictionary, type: String) {
       
    }
    
    
}



