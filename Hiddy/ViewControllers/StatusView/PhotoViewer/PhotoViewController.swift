import UIKit
import Alamofire
import GrowingTextView
import IQKeyboardManagerSwift

class PhotoViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var messageTextView: UITextView!
    private var backgroundImage: UIImage
    @IBOutlet weak var baseview: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstant: NSLayoutConstraint!
    
    init(image: UIImage) {
        self.backgroundImage = image
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var pageDirectionCheckForFileUpload : String = ""
    let del = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loaderview: UIView!
    private var animating: Bool = false
    
    @IBOutlet weak var circleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.contentMode = UIView.ContentMode.scaleToFill
        backgroundImageView.image = backgroundImage
        bgImage.image = backgroundImage
        circleView.layer.cornerRadius = circleView.frame.size.width/2
        circleView.clipsToBounds = true
//        circleView.backgroundColor = UIColor.white
        //  baseview.addSubview(backgroundImageView)
        self.configureActivityIndicators()
        
        let layer = Utility.shared.gradient(size: sendButton.frame.size)
        layer.cornerRadius = sendButton.frame.size.height / 2
        sendButton.layer.addSublayer(layer)
        sendButton.bringSubviewToFront(sendButton.imageView!)
        self.configMsgField()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.gestureAct)))
        self.changeRTLView()

    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)

                IQKeyboardManager.shared.enable = false
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.messageTextView.textAlignment = .right
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
            self.sendButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        else {
            self.messageTextView.textAlignment = .left
            self.sendButton.transform = .identity
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
        }
    }
    
    @objc func gestureAct() {
        self.view.endEditing(true)
    }
    func configMsgField()  {
        messageTextView.layer.borderWidth  = 1.0
        messageTextView.layer.borderColor = UIColor.white.cgColor
        messageTextView.font = UIFont.systemFont(ofSize: 18)
        messageTextView.textContainer.lineFragmentPadding = 20
        messageTextView.delegate = self
        messageTextView.layer.cornerRadius = 20.0
        messageTextView.textAlignment = .left
        messageTextView.textColor = .white
        messageTextView.isUserInteractionEnabled = true
        messageTextView.text = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String
        messageTextView.textColor = TEXT_TERTIARY_COLOR
    }

    func configureActivityIndicators() {
        loaderview.isHidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.color = RECIVER_BG_COLOR
    }
    @objc func startLoading(string : String)
    {
        loaderview.isHidden = false
        self.activityIndicator.startAnimating()
    }
    @objc func stopLoading()
    {
        loaderview.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func btnClose_Act(_ sender: Any) {
        self.homePageCall()
    }
    
    @objc func homePageCall() {
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        appDelegate.settingRootViewControllerFunction()
        //        let pageobj = StoryHomeViewController()
        //        self.present(pageobj, animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
//        self.del.setInitialViewController(initialView: menuContainerPage())
    }
    
    @IBAction func btnSaveLocalImage_Act(_ sender: Any) {
        PhotoAlbum.sharedInstance.save(image: backgroundImage, msg_id: "",type:"")
        //        self.showToast(message: "Photos Saved In Gallery")
    }
    
    @IBAction func btnYourStory_Act(_ sender: Any) {
        self.view.endEditing(true)
        pageDirectionCheckForFileUpload = "MyStory"
//        self.FileUpload()
        self.createStory()
    }
    
    
    func createStory() {
        let msgDict = NSMutableDictionary()
//        let msg_id = Utility.shared.random()
        msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
        if messageTextView.tag == 1 {
            msgDict.setValue(self.messageTextView.text!, forKey: "message")
        }
        else {
            msgDict.setValue("", forKey: "message")
        }
//        msgDict.setValue(msg_id, forKey: "story_id")
        msgDict.setValue("image", forKey: "story_type")
        
        
        let vc = ShareStoryViewController()
        vc.requestDict = msgDict
        vc.image = backgroundImage
        vc.storyType = "image"
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func btnShareStory(_ sender: Any) {
        self.view.endEditing(true)
        pageDirectionCheckForFileUpload = "StorySharePage"
        self.createStory()
        
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

extension UIImage {
    
    func fixedOrientation() -> UIImage? {
        
        guard imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    class func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
extension PhotoViewController: GrowingTextViewDelegate,UITextViewDelegate {
    
    //MARK: Keyboard hide/show
        @objc func keyboardWillShow(sender: NSNotification) {
            let info = sender.userInfo!
         print("keyboard log")
            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            if IS_IPHONE_5 || IS_IPHONE_678 || IS_IPHONE_PLUS {
                self.bottomConstant.constant = (keyboardFrame.height-20)
            } else {
                self.bottomConstant.constant = (keyboardFrame.height-50)
            }
     
        }
        
        @objc func keyboardWillHide(sender: NSNotification) {
            self.bottomConstant.constant = 0
        }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.frame.height >= 150 {
            textView.isScrollEnabled = true
            messageTextViewHeight.priority = .defaultHigh
        }
        else {
            textView.isScrollEnabled = false
            messageTextViewHeight.priority = .defaultLow
        }
//        self.textViewAct(textView)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textViewAct(textView)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.textViewAct(textView)
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
        else if numberOfChars > 250 || Int(numLines) > 50{// per line 15 -> 34 lines & 500 chars
            textView.endEditing(true)
            print("\(numberOfChars) \(numLines)")
            self.view.makeToast("Only 250 Characters are allowed")
            return false
        }
//        self.textViewDidChange(textView)
        return true
    }
    
//    func textViewAct(_ textView: UITextView) {
//        if textView.tag == 0 {
//            textView.text = ""
//            textView.tag = 1
//        }
//        else {
//            if textView.text == "" && textView.tag == 1{
//                textView.text = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String
//                textView.tag = 0
//            }
//        }
//    }
    func textViewAct(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.tag = 1
            textView.text = ""
            textView.textColor = UIColor.white
        }
        else {
            if textView.text == "" {
                if textView.tag == 1 {
                    textView.tag = 0
                    textView.text = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String
                    textView.textColor = TEXT_TERTIARY_COLOR
                }
            }
        }
    }
}

