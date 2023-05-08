//
//  Extension.swift
//  Hiddy
//
//  Created by Roby on 28/07/21.
//  Copyright © 2021 HITASOFT. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UIImage {
    var withGrayscale: UIImage {
        guard let ciImage = CIImage(image: self, options: nil) else { return self }
        let paramsColor: [String: AnyObject] = [kCIInputBrightnessKey: NSNumber(value: 0.0), kCIInputContrastKey: NSNumber(value: 1.0), kCIInputSaturationKey: NSNumber(value: 0.0)]
        let grayscale = ciImage.applyingFilter("CIColorControls", parameters: paramsColor)
        guard let processedCGImage = CIContext().createCGImage(grayscale, from: grayscale.extent) else { return self }
        return UIImage(cgImage: processedCGImage, scale: scale, orientation: imageOrientation)
    }
}


 extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBarManager"))) {
            return value(forKey: "statusBarManager") as? UIView
        }
        return nil
    }
}

extension UIColor {
    func hexValue(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func setRandomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
    }
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }

}

extension UILabel{
 
    //MARK: configure label
    public func config(color:UIColor,size:CGFloat, align:NSTextAlignment, text:String){
        self.textColor = color
        self.textAlignment = align
        self.text = Utility().getLanguage()?.value(forKey: text) as? String
        self.font = UIFont.init(name:APP_FONT_REGULAR, size: size)
    }
    
    //set attributed text
    func attributed(text:String)  {
        
        let attributedString = NSMutableAttributedString(string: Utility.shared.getLanguage()?.value(forKey: text) as! String)
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 10 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        // *** Set Attributed String to your label ***
        self.attributedText = attributedString;
    }
    
    //round corner
    func cornerRadius() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    //specific corner size
    func lblMinimumCornerRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    //background and main thread function
    func setContact(phoneNo:String,contact_id:String) {
        DispatchQueue.global(qos: .background).async {
            var name = String()
            let contactName = Utility.shared.searchPhoneNoAvailability(phoneNo: phoneNo)
            if contactName == EMPTY_STRING{
                name = phoneNo
                let localDB = LocalStorage()
                localDB.updateName(cotact_id: contact_id, name: name)
            }else{
                name = contactName
            }
            DispatchQueue.main.async {
                self.text = name
            }
        }
    }
        
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    
    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }
        
        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        
        if let insets = padding {
            textWidth -= insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
        }
        
        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)
        
        contentSize.height = ceil(newSize.size.height) + insetsHeight
        
        return contentSize
    }
}



extension UIButton{
    public func config(color:UIColor,size:CGFloat,align:UIControl.ContentHorizontalAlignment,title:String){
        self.setTitleColor(color, for: .normal)
        self.setTitle(Utility().getLanguage()?.value(forKey: title) as? String, for: .normal)
        self.contentHorizontalAlignment = align
        self.titleLabel?.font = UIFont.init(name:APP_FONT_REGULAR, size: size)
    }
    func cornerRoundRadius() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
    func cornerMiniumRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    func setBorder(color:UIColor) {
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }
    
    //MARK: shadow effect
    func floatingEffect() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.5;
    }
  
   func newEffect() {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0.0, height: 2)
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOpacity = 1;
    
    }
}



extension UITextField{

//MARK: configure textField
public func config(color:UIColor,size:CGFloat, align:NSTextAlignment,placeHolder:String){
    self.textColor = color
    self.textAlignment = align
    self.placeholder = Utility().getLanguage()?.value(forKey: placeHolder) as? String
    self.font = UIFont.init(name:APP_FONT_REGULAR, size: size)
    }
    //MARK: Rounded radius
    func cornerRoundRadius() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
    //minimum radius
    func cornerMiniumRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    // set border
    func setBorder() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    //MARK: email Validation
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text)
    }
    //MARK: left padding
    func setLeftPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
  
    //MARK: check textfield is empty
    func isEmpty() -> Bool {
        if  (self.text! == "") || (self.text! == "NULL") || (self.text! == "(null)")  || (self.text! == "<null>") || (self.text! == "Json Error") || (self.text! == "0") || (self.text!.isEmpty) ||  self.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
}
extension UITextView {
    // add Done button to keyboard
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    

}

extension CGFloat {
    func SecondsFromTimer() -> String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        let timeVal = String(format: "%02i:%02i", minutes, seconds)
        let dateString = Utility.shared.timerInAppLanguage(count: timeVal)
        return dateString
    }
}

extension UIView{
    //MARK: convert to image

    func asImage() -> UIImage {
        let defaultImage = #imageLiteral(resourceName: "profile_placeholder")
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        guard let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext() else { return  defaultImage}
           UIGraphicsEndImageContext()
        return snapshotImageFromMyView
        }
    //MARK: shadow effect
    func elevationEffect() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.2;
//        self.layer.borderWidth = 1
//        self.layer.borderColor = TEXT_PRIMARY_COLOR
    }
    func previewelevationEffect() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.5;
        //        self.layer.borderWidth = 1
        //        self.layer.borderColor = TEXT_PRIMARY_COLOR
    }
    func elevationEffectOnBottom() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0.5)
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.2;
        //        self.layer.borderWidth = 1
        //        self.layer.borderColor = TEXT_PRIMARY_COLOR
    }
    //MARK: round corner radius
    func cornerViewRadius() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    func blurEffect() {
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.bounds
        self.addSubview(blurView)
    }
    //MARK: minimum corner radius
    func cornerViewMiniumRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    //MARK: remove corner radius
    func removeCornerRadius() {
        self.layer.cornerRadius = 0.0
        self.layer.masksToBounds = false
        self.clipsToBounds =  false
    }
    func viewRadius(radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    //MARK: apply gradient effect
    func applyGradient()  {
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.frame.size
        gradientLayer.colors = PRIMARY_COLOR
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.addSublayer(gradientLayer)
        gradientLayer.frame = self.bounds
    }
    
    func removeGrandient()  {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    //MARK:Specific corner left
    func cornerLeft()  {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [ .topRight , .bottomRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        self.layer.mask = rectShape
    }
    
    
    //MARK:Specific corner radius
    func specificCorner(radius:CGFloat)  {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [ .topRight , .topLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.mask = rectShape
    }
    //MARK:Specific corner radius
    func specificCornerRadius(radius:Int)  {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight , .topLeft, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
//        self.layer.backgroundColor = UIColor.green.cgColor
        //Here I'm masking the textView's layer with rectShape layer
        self.layer.mask = rectShape
    }
    
    //MARK: Set border
    func setViewBorder(color:UIColor) {
        self.cornerViewRadius()
        self.layer.borderWidth = 2
        self.layer.borderColor = color.cgColor
    }
    
}

extension String {
    //check string contains emoji
    func containsEmoji() -> Bool {
        for character in self {
            if character.isEmoji {
                return true
            }
        }
        return false
    }

    func toJSONString() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}



extension UIImageView{
    func rounded() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    func setBorder(color:UIColor) {
        self.layer.borderWidth = 2
        self.layer.borderColor = color.cgColor
    }
    
    func blurImage() {
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.bounds
        self.addSubview(blurView)
    }
    func removeBlurImage()  {
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        for subview in blurView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    
    
}

extension TimeInterval {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}



extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            // print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


extension UITextView{
    //MARK: configure label
    public func config(color:UIColor,size:CGFloat, align:NSTextAlignment, text:String){
        self.textColor = color
        self.textAlignment = align
//        self.toolbarPlaceholder = Utility().getLanguage()?.value(forKey: text) as? String
        self.font = UIFont.init(name:APP_FONT_REGULAR, size: size)
    }
    //MARK: check textfield is empty
    func isEmpty() -> Bool {
        if  (self.text! == "") || (self.text! == "NULL") || (self.text! == "(null)")  || (self.text! == "<null>") || (self.text! == "Json Error") || (self.text! == "0") || (self.text!.isEmpty) ||  self.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
   

}


extension UIViewController{

    func updateTheme(){
        if #available(iOS 13.0, *) {
            if UserModel.shared.theme() == "Dark"{
                overrideUserInterfaceStyle = .dark
            }else if UserModel.shared.theme() == "Light"{
                overrideUserInterfaceStyle = .light
            }else if UITraitCollection.current.userInterfaceStyle == .dark{
                overrideUserInterfaceStyle = .dark
            }else if UITraitCollection.current.userInterfaceStyle == .light{
                overrideUserInterfaceStyle = .light
            }
        }
        self.view.backgroundColor = BACKGROUND_COLOR

    }
    func updateStatusBarStyle() -> UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            if UserModel.shared.theme() == "Dark"{
                return .lightContent
            }else if UserModel.shared.theme() == "Light"{
                return .default
            }else if UITraitCollection.current.userInterfaceStyle == .dark{
                return .lightContent
            }else if UITraitCollection.current.userInterfaceStyle == .light{
                return .default
            }
            else {
                return .default
            }
        } else {
            return .default
            // Fallback on earlier versions
        }
    }
}
