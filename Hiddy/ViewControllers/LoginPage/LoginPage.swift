//
//  LoginPage.swift
//  Hiddy
//
//  Created by APPLE on 07/06/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import FirebaseUI
import PhoneNumberKit

class LoginPage: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var termsView: UIView!
    @IBOutlet var checkBox: VKCheckbox!
    @IBOutlet var termsLbl: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageIndicator: UIPageControl!
    @IBOutlet var connectBtn: UIButton!
    
    var isViewed = 0
    var enableSendToFacebook = Bool()
    var enableGetACall = Bool()
    let imagelist = ["sliderImg1", "sliderImg2", "sliderImg3"]
    let sliderTitleList = ["channel", "group_event", "audio_video"]
    let sliderDesList = ["channel_des", "group_event_des", "audio_video_des"]

    var yPosition:CGFloat = 0
    var scrollViewContentSize:CGFloat=0;
    
    let authUI = FUIAuth.defaultAuthUI()
    var termsStr = String()
    var privacyStr = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getTermsPrivacy()
        self.activityindicator.color = RECIVER_BG_COLOR
        self.processingLabel.config(color:RECIVER_BG_COLOR, size: 16, align: .natural, text: "processing")
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
            ]
        self.authUI?.providers = providers
        // Do any additional setup after loading the view.
    }
    func firebaseLogin() {
        let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override  func viewDidLayoutSubviews() {
    
        self.view.applyGradient()
        self.initialSetup()
        self.termsView.frame.origin.y = self.pageIndicator.frame.origin.y + 30
        self.view.bringSubviewToFront(self.termsView)
        self.view.bringSubviewToFront(self.hideView)
    }
    override func viewWillAppear(_ animated: Bool) {
        if self.isViewed == 0 {
            self.hideView.isHidden = true
            self.activityindicator.stopAnimating()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    func initialSetup()  {
        self.hideView.backgroundColor = BACKGROUND_COLOR
        self.configurePageControl()
        self.configSliderPage()
        self.connectBtn.config(color: .white, size: 22, align: .center, title: "connect")
        self.connectBtn.cornerRoundRadius()
        self.connectBtn.backgroundColor  =  UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        self.view.bringSubviewToFront(scrollView)
        self.view.bringSubviewToFront(pageIndicator)
        self.view.bringSubviewToFront(connectBtn)
        self.view.bringSubviewToFront(hideView)
        self.termsLbl.config(color: .white, size: 17, align: .left, text: "terms_and_conditions")
        let fullTxt = Utility.language?.value(forKey: "terms_and_conditions") as! String
        let  privacyTxt = Utility.language?.value(forKey: "privacy_policy") as! String
        let termsTxt = Utility.language?.value(forKey: "terms_signup") as! String

        let termsAttributeString = NSMutableAttributedString(string: fullTxt)
        let termsRange = (fullTxt as NSString).range(of: termsTxt)
        let privacyRange = (fullTxt as NSString).range(of: privacyTxt)
        termsAttributeString.addAttribute(NSAttributedString.Key.foregroundColor, value:TEXT_SECONDARY_COLOR, range: privacyRange)
        termsAttributeString.addAttribute(NSAttributedString.Key.foregroundColor, value:TEXT_SECONDARY_COLOR, range: termsRange)
        self.termsLbl.attributedText = termsAttributeString
        self.termsLbl.isUserInteractionEnabled = true
        termsLbl.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapTerms(gesture:))))

        //terms check
        checkBox.line             = .thin
        checkBox.bgColorSelected  = SECONDARY_COLOR
        checkBox.bgColor          = SECONDARY_COLOR
        checkBox.color            = .white
        checkBox.borderColor      = LINE_COLOR
        checkBox.borderWidth      = 1
        checkBox.cornerRadius     = 5
        // Handle state update
        checkBox.checkboxValueChangedBlock = { isOn in
//            if isOn{
//                self.termsCheckBox.borderColor = .clear
//            }else{
//                self.termsCheckBox.borderColor = LINE_COLOR
//            }
//            self.isAgree = isOn
        }
    }

    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageIndicator.numberOfPages = imagelist.count
        self.pageIndicator.currentPage = 0
        self.pageIndicator.tintColor = UIColor.white
        self.pageIndicator.pageIndicatorTintColor = .lightGray
        self.pageIndicator.currentPageIndicatorTintColor =  .white
    }
    
    func configSliderPage()  {
        for  i in stride(from: 0, to: imagelist.count, by: 1) {
            var frame = CGRect.zero
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(i)
            frame.origin.y = 0
            frame.size = self.scrollView.frame.size
            self.scrollView.isPagingEnabled = true
            
            let myImage:UIImage = UIImage(named: imagelist[i])!
            let myImageView:UIImageView = UIImageView()
            myImageView.image = myImage
            myImageView.tag = i
            myImageView.contentMode = UIView.ContentMode.scaleAspectFit
            myImageView.frame = CGRect.init(x: frame.origin.x+50, y: 80, width: FULL_WIDTH-100, height: FULL_WIDTH-100)
            scrollView.addSubview(myImageView)
            
            let titleLbl:UILabel = UILabel()
            titleLbl.frame = CGRect.init(x: frame.origin.x, y: FULL_WIDTH, width: FULL_WIDTH, height:45)
            titleLbl.config(color: .white, size: 25, align: .center, text: sliderTitleList[i])
            scrollView.addSubview(titleLbl)
            
            let titleDes:UILabel = UILabel()
            titleDes.frame = CGRect.init(x: frame.origin.x+20, y: FULL_WIDTH+40, width: FULL_WIDTH-40, height:60)
            titleDes.numberOfLines = 4
            titleDes.config(color: .white, size: 17, align: .center, text: sliderDesList[i])
            scrollView.addSubview(titleDes)
            if UIDevice.current.hasNotch{
                self.pageIndicator.frame.origin.y = titleDes.frame.origin.y + 165
            }else{
                self.pageIndicator.frame.origin.y = titleDes.frame.origin.y + 65
            }

        }
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(imagelist.count), height: self.scrollView.frame.size.height-100)
    }
    
    //scroll view delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width) 
        pageIndicator.currentPage = Int(pageNumber)
    }
    
    @IBAction func connectBtnTapped(_ sender: Any) {
        if self.checkBox.isOn {
//            self.hideView.isHidden = false
//            self.activityindicator.startAnimating()
            self.isViewed = 1
            self.firebaseLogin()
//            self.loginService(phoneNo: "9659511469", countryCode: "91", country_name: "IN")
        }else{
            Utility.shared.showAlert(msg: Utility.language?.value(forKey: "must_agree") as! String)

        }
        
    }
    
    //go to terms page
    @objc func tapTerms(gesture: UITapGestureRecognizer) {
        let fullTxt = Utility.language?.value(forKey: "terms_and_conditions") as! String

        let  privacyTxt = Utility.language?.value(forKey: "privacy_policy") as! String
        let termsTxt = Utility.language?.value(forKey: "terms_signup") as! String

        let termsRange = (fullTxt as NSString).range(of: termsTxt)
        let privacyRange = (fullTxt as NSString).range(of: privacyTxt)
        let dict = NSMutableDictionary()
        // comment for now
        if gesture.didTapAttributedTextInLabel(label: self.termsLbl, inRange: termsRange) {
            dict.setValue(termsTxt, forKey: "title")
            dict.setValue(termsStr, forKey: "description")

            let webView = ContentWebPage()
            webView.helpDict = dict
            webView.modalPresentationStyle = .fullScreen
            self.navigationController?.present(webView, animated: true, completion: nil)
        }
        // comment for now
        if gesture.didTapAttributedTextInLabel(label: self.termsLbl, inRange: privacyRange) {
            dict.setValue(privacyTxt, forKey: "title")
            dict.setValue(privacyStr, forKey: "description")
            let webView = ContentWebPage()
            webView.helpDict = dict
            webView.modalPresentationStyle = .fullScreen
            self.navigationController?.present(webView, animated: true, completion: nil)
        }
    }
    
    //login web service
    func loginService(phoneNo:String,countryCode:String,country_name: String){
        let loginObj = UserWebService()
        loginObj.signUpService(user_name:EMPTY_STRING , phone_no:phoneNo , country_code: countryCode,country_name: country_name, onSuccess: {response in
            let status:String = response.value(forKey: "status") as! String
            if status == STATUS_TRUE{
                let detailObj = DetailsPage()
                detailObj.userDict = response
                self.isViewed = 0
                self.navigationController?.pushViewController(detailObj, animated: true)
            }
        })
    }
    
//    func getTermsPrivacy()  {
//        let Obj = BaseWebService()
//        //create stream api call
//        Obj.getBaseService(subURl: "\(TERMS_CONDITIONS)", onSuccess: {response in
//            let status = response.value(forKey: "status") as! String
//            if status == "true"{
//                if response.value(forKeyPath: "result.privacy_policy") != nil {
//                self.privacyStr = response.value(forKeyPath: "result.privacy_policy") as! String
//                self.termsStr = response.value(forKeyPath: "result.tos") as! String
//                }
//
//            }
//        }, onFailure: {error in
//
//        })
//
//    }
//}
    
    func getTermsPrivacy()  {
        let Obj = BaseWebService()
        //create stream api call
        Obj.getBaseService(subURl: "\(TERMS_CONDITIONS)", onSuccess: {response in
            let status = response.value(forKey: "status") as! String
            if status == "true"{
                if response.value(forKeyPath: "result.privacy_policy") != nil {
                    if response.value(forKeyPath: "result.tos") != nil {
                self.privacyStr = response.value(forKeyPath: "result.privacy_policy") as! String
                self.termsStr = response.value(forKeyPath: "result.tos") as! String
                }
                }

            }
        }, onFailure: {error in
            
        })

    }
}
extension LoginPage: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print(error?.localizedDescription ?? "")
        if error == nil {
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumbers = try phoneNumberKit.parse(authDataResult?.user.phoneNumber ?? "")
                self.loginService(phoneNo: "\(phoneNumbers.nationalNumber)", countryCode: "\(phoneNumbers.countryCode)", country_name: (phoneNumbers.regionID ?? ""))
            }
            catch {
                self.isViewed = 0
                print("Generic parser error")
            }
        }
        else {
            self.isViewed = 0
        }
    }
    
    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        print(error?.localizedDescription ?? "")
        self.isViewed = 1
    }
    
}


//MARK: GESTURE **********************************************

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
        //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
