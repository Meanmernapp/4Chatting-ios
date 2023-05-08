//
//  typStatusViewController.swift
//  Hiddy
//
//  Created by Hitasoft on 02/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
import GrowingTextView


class typStatusViewController: UIViewController {
    @IBOutlet weak var colorChooserButton: UIButton!
    @IBOutlet weak var backArrowIcon: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bottomStackView: UIStackView!

    @IBOutlet weak var textStackView: UIStackView!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var textViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var textLabelHeight: NSLayoutConstraint!
    let gradientLayer = CAGradientLayer()
    var statusBarState = false
    var fullWidth = 0.0
    var numberOfLines = 0
    var textViewHeight = 0.0
    var lineHeight = 0.0
    let del = UIApplication.shared.delegate as! AppDelegate
    var keyboardHeight = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusTextView.config(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), size: 50, align: .center, text: "type_Status")
        self.statusTextView.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.textLabel.config(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), size: 50, align: .center, text: "type_Status")
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelGestureAct)))
        textViewHeight = Double(self.statusTextView.contentSize.height)
        lineHeight = Double(self.statusTextView.font?.lineHeight ?? 0.0)
        numberOfLines = Int(Double(textViewHeight) / lineHeight)
        self.loaderView.color = RECIVER_BG_COLOR
        self.loaderView.isHidden = true
        statusTextView.adjustsFontForContentSizeCategory = true
        self.statusTextView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewGestureAct)))
        self.loadRandomColor()
        self.bottomConst.priority = .defaultHigh
        let layer = Utility.shared.gradient(size: shareButton.frame.size)
        layer.cornerRadius = shareButton.frame.size.height / 2
        shareButton.layer.addSublayer(layer)
        shareButton.bringSubviewToFront(shareButton.imageView!)
        self.statusTextView.centerVertically()
//        self.adjustUITextViewHeight(arg: self.statusTextView)
        self.fullWidth = Double(self.view.frame.height)
//        numberOfLines = ((self.view.frame.height - 100) / (statusTextView.font?.lineHeight ?? 0)) as? Int 
        self.statusTextView.adjustsFontForContentSizeCategory = true
        self.changeRTLView()
        // Do any additional setup after loading the view.
    }
    
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
            self.shareButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
            self.shareButton.transform = .identity
        }
    }
    @objc func labelGestureAct() {
        if self.textLabel.tag == 1 {
            self.textLabel.tag = 0
            self.textLabel.isHidden = true
            self.statusTextView.isHidden = false
            self.statusTextView.becomeFirstResponder()
        }
        else {
            self.textLabel.tag = 1
            self.textLabel.isHidden = false
            self.statusTextView.isHidden = true
            self.textLabel.adjustsFontSizeToFitWidth = true
            self.textLabel.minimumScaleFactor = 0.5
            self.statusTextView.resignFirstResponder()
        }
    }
    
    @IBAction func backButtonAct(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
//        self.del.setInitialViewController(initialView: menuContainerPage())
    }
    @objc func viewGestureAct() {
        self.view.endEditing(true)
    }
    override var prefersStatusBarHidden: Bool{
        return statusBarState
    }
    override func viewWillAppear(_ animated: Bool) {
        statusBarState = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.statusTextView.delegate = self
        UIView.animate(withDuration: 0.30) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        self.shareButton.isUserInteractionEnabled = true
        self.topConst.constant = 15
        self.bottomConst.constant = 15
        self.bottomStackView.isHidden = false
//        self.colorChooserButton.isHidden = false
        self.backView.isHidden = false

    }
    override func viewWillDisappear(_ animated: Bool) {
        statusBarState = false
        self.setNeedsStatusBarAppearanceUpdate()
        UIView.animate(withDuration: 0.30) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        NotificationCenter.default.removeObserver(self)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = self.view.bounds
//        self.adjustUITextViewHeight(arg: self.statusTextView)
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomConst.constant = 15 + keyboardFrame.height
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        print(self.bottomConst.constant)
        self.viewDidLayoutSubviews()
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.bottomConst.priority = .defaultHigh
        self.bottomConst.constant = 15
        print(self.bottomConst.constant)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
//        self.bgView.frame.size.height = self.view.frame.size.height + keyboardFrame.height
    }

    func loadRandomColor() {
        let color = UIColor().setRandomColor()
        self.setGradientBackground(colorTop: color.lighter(by: 30) ?? #colorLiteral(red: 0.3283956647, green: 0.7543603182, blue: 0.6880655289, alpha: 1), colorBottom: color.darker(by: 30) ?? #colorLiteral(red: 0.7895931602, green: 0.9489462972, blue: 0.9072339535, alpha: 1))
    }
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor){
        gradientLayer.removeFromSuperlayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.9, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.1, y: 0.0)
        gradientLayer.locations = [0, 1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    @IBAction func colorPickerButtonAct(_ sender: UIButton) {
        self.loadRandomColor()
    }
    @IBAction func shareAct(_ sender: UIButton) {
        self.shareButton.isUserInteractionEnabled = false
        self.view.hideToast()
        if self.statusTextView.tag == 1 {
            self.statusTextView.endEditing(true)
            sender.isUserInteractionEnabled = false
            self.bottomStackView.isHidden = true
            self.backView.isHidden = true
            self.bottomConst.constant = 100
            self.topConst.constant = 100
//            self.loaderView.isHidden = false
//            self.loaderView.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                let image = self.view.takeScreenshot()
                self.shareImage(image: image)
//                let newVC = PhotoViewController(image: image)
//                self.navigationController?.pushViewController(newVC, animated: true)
            }
        }
    }
    func shareImage(image: UIImage) {
        let msgDict = NSMutableDictionary()
        //        let msg_id = Utility.shared.random()
        msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        msgDict.setValue("", forKey: "message")
        //        msgDict.setValue(msg_id, forKey: "story_id")
        msgDict.setValue("image", forKey: "story_type")
        
        let requestDict = NSMutableDictionary()
        requestDict.setValue(UserModel.shared.userID(), forKey: "user_id")
        requestDict.setValue(msgDict, forKey: "stories")
        
        
        let vc = ShareStoryViewController()
        vc.requestDict = msgDict
        vc.image = image
        vc.storyType = "image"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension typStatusViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        resize(textView: textView)
//        self.textLabel.text = textView.text! //+ "  |"
//        textView.fitTextToBounds()
        if textView.frame.height >= (self.textStackView.frame.height - 100) {
            textView.isScrollEnabled = true
            self.textLabelHeight.constant = (self.textStackView.frame.height - 150)
        }
        else {
            textView.isScrollEnabled = false
            self.textLabelHeight.constant = textView.frame.height
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewAct(textView)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewAct(textView)
        self.textLabel.text = textView.text
        labelGestureAct()
        textViewDidChange(textView)
    }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    func textViewAct(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.text = ""
            textView.tag = 1
        }
        else {
            if textView.text == "" && textView.tag == 1{
                textView.text = "Type a text"
                textView.tag = 0
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        let numLines = (textView.contentSize.height / (textView.font?.lineHeight ?? 0))
        
        // Check BackSpacee
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        }
        else if numberOfChars > 500 || Int(numLines) > 50{// per line 15 -> 34 lines & 500 chars
            textView.endEditing(true)
            print("\(numberOfChars) \(numLines)")
            self.view.makeToast(Utility.language?.value(forKey: "text_status_limit") as? String )
            return false
        }
         return true
    }
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let currentText = textView.text ?? ""
//        guard let stringRange = Range(range, in: currentText) else { return false }
//
//        _ = currentText.replacingCharacters(in: stringRange, with: text)
//
//        return textView.text.count + (text.count - range.length) <= 400
//    }
}
extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }

}
