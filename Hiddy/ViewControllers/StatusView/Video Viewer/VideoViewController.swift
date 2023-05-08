/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit
import AVFoundation
import AVKit
import Alamofire
import MobileCoreServices
import PryntTrimmerView
import Photos

class VideoViewController: AssetSelectionViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var messageTextview: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var oneView: UIView!
    @IBOutlet weak var twoView: UIView!
    @IBOutlet weak var firstPlayerView: UIView!
    @IBOutlet weak var startTimeTitleLabel: UILabel!
    @IBOutlet weak var endTimeTitleLabel: UILabel!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shaodowView: UIView!
    @IBOutlet weak var frameContainerView: UIView!
    @IBOutlet weak var imageFrameView: TrimmerView!
    
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var startTimeText: UITextField!
    
    @IBOutlet weak var endView: UIView!
    @IBOutlet weak var endTimeText: UITextField!
    @IBOutlet var bottomConstant: NSLayoutConstraint!

    
    var firstPlayer: AVPlayer!
    var videoLayer: AVPlayerLayer!
    private var videoURL: URL
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    var pageDirectionCheckForFileUpload : String = ""
    var playbackTimeCheckerTimer: Timer?
    
    var timeObserver: AnyObject!
    var startTime = 0.0;
    var endTime = 0.0;
    var progressTime = 0.0;
    var shouldUpdateProgressIndicator = true
    var isSeeking = false

    var videoPlaybackPosition: CGFloat = 0.0
    var cache:NSCache<AnyObject, AnyObject>!
    var rangeSlider: RangeSlider! = nil
    var videoTimer = Timer()


    var url:NSURL! = nil
    var stopTime: CGFloat  = 0.0
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int!
    var asset: AVAsset!

    var isPlaying = true
    var isSliderEnd = true
    let playerObserver: Any? = nil

    init(videoURL: URL) {
        
        self.videoURL = videoURL
        
        // print("self.usrl \(self.videoURL)")
        super.init(nibName: nil, bundle: nil)
    }
    func PHAssetForFileURL(url: URL) -> PHAsset? {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.version = .current
        imageRequestOptions.deliveryMode = .fastFormat
        imageRequestOptions.resizeMode = .fast
        imageRequestOptions.isSynchronous = true

        let fetchResult = PHAsset.fetchAssets(with: nil)
        for index in 0..<fetchResult.count {
            if let asset = fetchResult[index] as? PHAsset {
                var found = false
                PHImageManager.default().requestImageData(for: asset,
                    options: imageRequestOptions) { (_, _, _, info) in
                        if let urlkey = info?["PHImageFileURLKey"] as? NSURL {
                            if urlkey.absoluteString! == url.absoluteString {
                                found = true
                            }
                        }
                }
                if (found) {
                    return asset
                }
            }
        }
        return nil
    }

    override func loadAsset(_ asset: AVAsset) {

        imageFrameView.asset = asset
        imageFrameView.delegate = self
        self.imageFrameView.moveRightHandle(to: CMTime(seconds: 30, preferredTimescale: 1000))
        self.imageFrameView.moveLeftHandle(to: CMTime(seconds: 0, preferredTimescale: 1000))

//        addVideoPlayer(with: asset, playerView: firstPlayerView)
    }
    @objc func itemDidFinishPlaying() {
        if let startTime = imageFrameView.startTime {
            player?.seek(to: startTime)
        }
        shaodowView.isHidden = false
        firstPlayer?.pause()
        self.videoBtn.tag = 0
        self.videoBtn.setImage(UIImage(named: "video_play"), for: .normal)

    }
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        

        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
//        layer.frame = playerView.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    func loadAsset() {
        asset = AVURLAsset.init(url: self.videoURL)
        
        thumbTime = asset.duration
        thumbtimeSeconds = Int(CMTimeGetSeconds(thumbTime))
        
        if firstPlayer.currentItem?.duration != nil {
            self.endTime = 30.0
        }
        startView.isHidden          = false
        endView.isHidden            = false
        frameContainerView.isHidden = false
        
        isSliderEnd = true
        self.imageFrameView.maxDuration = Double(CMTimeGetSeconds(thumbTime))
    }
    
    func seekVideo(toPos pos: CGFloat) {
        self.videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.firstPlayer.currentTime().timescale)
        self.firstPlayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if(pos == CGFloat(thumbtimeSeconds))
        {
            self.firstPlayer.pause()
            videoBtn.tag = 1
            self.playPauseBtnAct(videoBtn)
        }
    }
    @objc func updateVideoPlayerSlider() {
        // 1 . Guard got compile error because `videoPlayer.currentTime()` not returning an optional. So no just remove that.
        if firstPlayer != nil {
            let currentTimeInSeconds = CMTimeGetSeconds(firstPlayer.currentTime())
            // 2 Alternatively, you could able to get current time from `currentItem` - videoPlayer.currentItem.duration
            
            let mins = currentTimeInSeconds / 60
            let secs = currentTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }
            
            // 3 My suggestion is probably to show current progress properly
            if let currentItem = firstPlayer.currentItem {
                let duration = currentItem.duration
                if (CMTIME_IS_INVALID(duration)) {
                    // Do sth
                    return;
                }
                let currentTime = currentItem.currentTime()
            }
        }
    }

    var isLoop: Bool = true
    @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var loaderview: UIView!
    private var animating: Bool = false
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
     @IBOutlet weak var circleView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        circleView.layer.cornerRadius = circleView.frame.size.width/2
        circleView.clipsToBounds = true
//        circleView.backgroundColor = UIColor.white
        circleView.cacheShadow()
        self.shaodowView.cornerViewRadius()
        self.configureActivityIndicators()
        self.shaodowView.isHidden = true
        let layer = Utility.shared.gradient(size: sendButton.frame.size)
        layer.cornerRadius = sendButton.frame.size.height / 2
        sendButton.layer.addSublayer(layer)
        sendButton.bringSubviewToFront(sendButton.imageView!)
        self.configMsgField()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            // print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        self.startTimeTitleLabel.config(color:#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), size: 11, align: .natural, text: "start_time")
        self.endTimeTitleLabel.config(color:#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), size: 11, align: .natural, text: "end_time")

        self.loadViews()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.gestureAct)))
        videoBtn.setImage(UIImage(named: "video_play"), for: .normal)
        self.cache = NSCache()
        self.imageFrameView.handleColor = UIColor.white
        self.imageFrameView.positionBarColor = UIColor.white
        self.imageFrameView.mainColor = UIColor.darkGray
        self.imageFrameView.minDuration = 1.0
        self.firstvideoplay()
        self.videoBtn.tag = 0
    }
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if videoLayer != nil {
            videoLayer.frame = self.firstPlayerView.bounds
        }
    }
    //Loading Views
    func loadViews()
    {
        //Whole layout view
        startView.isHidden          = true
        endView.isHidden            = true
        frameContainerView.isHidden = true
        
        //Style for startTime
        startTimeText.layer.cornerRadius = 5.0
        startTimeText.layer.borderWidth  = 1.0
        startTimeText.layer.borderColor  = UIColor.white.cgColor
        
        //Style for endTime
        endTimeText.layer.cornerRadius = 5.0
        endTimeText.layer.borderWidth  = 1.0
        endTimeText.layer.borderColor  = UIColor.white.cgColor
        
        imageFrameView.layer.cornerRadius = 5.0
        imageFrameView.layer.borderWidth  = 1.0
        imageFrameView.layer.borderColor  = UIColor.darkGray.cgColor
        imageFrameView.layer.masksToBounds = true
        
        player = AVPlayer()
        
        
        //Allocating NsCahe for temp storage
        self.cache = NSCache()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Set initial position of Start Indicator
//        trimmerView.setStartPosition(seconds: 0.0)
//
//        // Set initial position of End Indicator
//        trimmerView.setEndPosition(seconds: 30.0)
    }
    @objc func gestureAct() {
        self.view.endEditing(true)
        playPauseBtnAct(self.videoBtn)
    }
    func cropVideo(sourceURL1: URL, startTime:Float, endTime:Float)
    {
        let manager                 = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            print(documentDirectory)
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                outputURL = outputURL.appendingPathComponent("1.mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    self.videoURL = outputURL
                    self.createStory()
//                    self.saveToCameraRoll(URL: outputURL as NSURL!)
                case .failed:
                    print("failed \(exportSession.error)")
                    
                case .cancelled:
                    print("cancelled \(exportSession.error)")
                    
                default: break
                }
            }
        }
    }
    @IBAction func playPauseBtnAct(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            if firstPlayer != nil {
                if (firstPlayer.currentTime().seconds > self.endTime){
                    let timescale = self.firstPlayer.currentItem?.asset.duration.timescale
                    let time = CMTimeMakeWithSeconds(self.startTime, preferredTimescale: timescale!)
                    firstPlayer.seek(to: time)
                }
                stopPlaybackTimeChecker()
                self.firstPlayer?.pause()
                shaodowView.isHidden = false
                sender.setImage(UIImage(named: "video_play"), for: .normal)
            }
        }
        else {
            startPlaybackTimeChecker()
            sender.tag = 1
            self.firstPlayer?.play()
            sender.setImage(UIImage(named: "pause_receive.png"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shaodowView.isHidden = true
            }
        }
    }
    func configMsgField()  {
        messageTextview.layer.borderWidth  = 1.0
        messageTextview.layer.borderColor = TEXT_TERTIARY_COLOR.cgColor
        messageTextview.font = UIFont.systemFont(ofSize: 18)
        messageTextview.textContainer.lineFragmentPadding = 20
        messageTextview.delegate = self
        messageTextview.layer.cornerRadius = 20.0
        messageTextview.textAlignment = .left
        messageTextview.textColor = TEXT_TERTIARY_COLOR
        messageTextview.isUserInteractionEnabled = true
        messageTextview.text = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String
    }

    private func resetPlayer()
    {
        if firstPlayer != nil {
            firstPlayer.pause()
            firstPlayer.replaceCurrentItem(with: nil)
            firstPlayer = nil
        }
    }
    
    @objc func firstvideoplay()
    {
        resetPlayer()
        self.firstPlayer = AVPlayer(url: videoURL)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.firstPlayer.currentItem)
        videoLayer = AVPlayerLayer(player: self.firstPlayer)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = .resizeAspect
        self.firstPlayerView.layer.addSublayer(videoLayer)
        self.firstPlayer.play()
        if (firstPlayer.rate != 0 && firstPlayer.error == nil) {
            // print("playing")
        }
        asset = AVURLAsset.init(url: self.videoURL)
        if asset != nil {
            self.loadAssetRandomly(asset: asset)
        }
        loadAsset()
    }
    private func observeTime(elapsedTime: CMTime) {
        _ = CMTimeGetSeconds(elapsedTime)
        if (firstPlayer.currentTime().seconds > self.endTime){
            firstPlayer.pause()
        }
        if self.shouldUpdateProgressIndicator{
            print("update progress indicator....")
        }
    }
    @objc func reachTheEndOfTheVideo(_ notification: NSNotification) {
        self.firstPlayer?.pause()
        self.firstPlayer?.seek(to: CMTime.zero)
        self.firstPlayer?.play()
    }
    
    func configureActivityIndicators() {
        self.activityIndicator.color = RECIVER_BG_COLOR
        loaderview.isHidden = true
        self.activityIndicator.stopAnimating()
    }

    
    @objc func startLoading(string : String)
    {
        loaderview.isHidden = false
        self.activityIndicator.startAnimating()
        
    }
    @objc func stopLoading()
    {
        loaderview.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if videoBtn.imageView?.image == UIImage(named: "pause_receive.png")  {
            self.firstPlayer?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shaodowView.isHidden = true
            }
        }
        else {
            videoBtn.setImage(UIImage(named: "video_play"), for: .normal)
            self.firstPlayer?.pause()
            shaodowView.isHidden = false
        }
        self.changeRTLView()
    }
    func changeRTLView() {
        if UserModel.shared.getAppLanguage() == "عربى" {
            self.messageTextview.textAlignment = .right
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }
            self.shaodowView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.videoBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.sendButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.imageFrameView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.imageFrameView.rtlView(status: true)
        }
        else {
            self.shaodowView.transform = .identity
            self.videoBtn.transform = .identity
            self.view.transform = .identity
            self.imageFrameView.transform = .identity
            self.imageFrameView.rtlView(status: false)
            self.messageTextview.textAlignment = .left
            self.sendButton.transform = .identity
            for view in self.view.subviews {
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.transform = .identity
                }
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        isLoop = false
        self.firstPlayer?.pause()
        if self.videoTimer != nil {
            self.videoTimer.invalidate()
        }
    }
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnClose_Act(_ sender: Any) {
        self.player?.pause()
        resetPlayer()
        self.homePageCall()
        
    }
    
    @IBAction func btnShareStory(_ sender: Any) {
        self.view.endEditing(true)
        pageDirectionCheckForFileUpload = "SharedStory"
        self.cropVideo(sourceURL1: videoURL, startTime: Float(startTime), endTime: Float(endTime))
    }
     @objc func FileUpload(){
        self.player?.pause()
        self.startLoading(string: "UpLoading")
        let dummyMediaDict = NSMutableDictionary()
        dummyMediaDict.setValue("user", forKey: "type")
        dummyMediaDict.setValue(videoURL, forKey: "videos")
        dummyMediaDict.setValue(".mp4",forKey: "mime_type")
        var movieData:Data?
        do{
            movieData = try Data.init(contentsOf: videoURL)
        }catch{
            
        }
        dummyMediaDict.setValue(movieData, forKey: "media_data")
        let data = dummyMediaDict.value(forKey: "media_data") as! NSData
        let mimeStr = dummyMediaDict .value(forKey: "mime_type") as! String
        self.uploadFiles(fileData: data as Data, type: mimeStr, upload_type: "user", user_id: UserModel.shared.userID()! as String, onSuccess:
            {
                response in
                self.stopLoading()
                // print(response)
        })
    }
    
    @IBAction func btnYourStory_Act(_sender : Any)
    {
        pageDirectionCheckForFileUpload = "MyStory"
       self.createStory()

    }
    
    public func uploadFiles(fileData:Data,type:String,upload_type:String,user_id:String, onSuccess success: @escaping (NSDictionary) -> Void)
    {
        let uploadObj = UploadServices()
        uploadObj.uploadFiles(fileData: fileData, type: type, user_id: UserModel.shared.userID()! as String, docuName: upload_type, msg_id: "", api_type: "private") { (response) in
            // print(response)
            self.stopLoading()
            self.createStory()
            // print(response)

        }
    }
    func createStory() {
        DispatchQueue.main.async {
            let msgDict = NSMutableDictionary()
            //        let msg_id = Utility.shared.random()
            msgDict.setValue(UserModel.shared.userID(), forKey: "sender_id")
            if self.messageTextview.tag == 1 {
                msgDict.setValue(self.messageTextview.text!, forKey: "message")
            }
            else {
                msgDict.setValue("", forKey: "message")
            }
            msgDict.setValue("video", forKey: "story_type")
            
            let vc = ShareStoryViewController()
            vc.requestDict = msgDict
            vc.videoURL = self.videoURL
            vc.storyType = "video"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    //get mime type
    
    @IBAction func btnSaveLocalVideo_Act(_ sender: Any) {
        PhotoAlbum.sharedInstance.saveVideo(url: videoURL, msg_id: "", type: "")
       // self.showToast(message: "Video Saved")
        self.player?.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 03.0, execute: {
            self.homePageCall()
        })
    }
    
     fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            //self.player!.seek(to: CMTime.zero)
            self.player!.play()
        }
    }
    @objc func homePageCall() {
        self.player = nil
        self.navigationController?.popViewController(animated: true)
    }
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(self.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    @objc func onPlaybackTimeChecker() {

        guard let startTime = imageFrameView.startTime, let endTime = imageFrameView.endTime, let player = firstPlayer else {
            return
        }

        let playBackTime = player.currentTime()
        imageFrameView.seek(to: playBackTime)

        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            imageFrameView.seek(to: startTime)
            shaodowView.isHidden = false
            firstPlayer?.pause()
            self.videoBtn.tag = 0
            self.videoBtn.setImage(UIImage(named: "video_play"), for: .normal)

        }
    }
    func stopPlaybackTimeChecker() {

        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
}

extension VideoViewController: UITextViewDelegate {
    //MARK: Keyboard hide/show
        @objc func keyboardWillShow(sender: NSNotification) {
            let info = sender.userInfo!
         print("keyboard log")
            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         self.bottomConstant.constant = (keyboardFrame.height-50)
     
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
        videoBtn.tag = 1
        self.playPauseBtnAct(videoBtn)

        self.textViewAct(textView)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        videoBtn.tag = 1
        self.playPauseBtnAct(videoBtn)

        self.textViewAct(textView)
    }
    func textViewAct(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.tag = 1
            textView.text = ""
            textView.textColor = UIColor.white
            
        }
        else {
            if textView.text == "" {
                textView.tag = 0
                textView.text = Utility.shared.getLanguage()?.value(forKey: "say_something") as? String
                textView.textColor = TEXT_TERTIARY_COLOR
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
        else if numberOfChars > 250 || Int(numLines) > 50{// per line 15 -> 34 lines & 500 chars
            textView.endEditing(true)
            print("\(numberOfChars) \(numLines)")
            self.view.makeToast("Only 250 Characters are allowed")
            return false
        }
        self.textViewDidChange(textView)
        return true
    }
}
extension VideoViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        firstPlayer?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        startPlaybackTimeChecker()
        print("postion 1")

        self.startTime = imageFrameView.startTime?.seconds ?? Double(0)
        self.endTime = imageFrameView.endTime?.seconds ?? Double(0)
        startTimeText.text = "\(Int(imageFrameView.startTime?.seconds ?? Double(0)))"
        endTimeText.text = "\(Int(imageFrameView.endTime?.seconds ?? Double(0)) + 1)"
        if self.videoBtn.tag == 1 {
            self.videoBtn.setImage(UIImage(named: "pause_receive.png"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shaodowView.isHidden = true
            }
            firstPlayer?.play()
        }
    }

    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        firstPlayer?.pause()
        firstPlayer?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (imageFrameView.endTime! - imageFrameView.startTime!).seconds
        self.startTime = imageFrameView.startTime?.seconds ?? Double(0)
        self.endTime = imageFrameView.endTime?.seconds ?? Double(0)
        
        startTimeText.text = "\(Int(imageFrameView.startTime?.seconds ?? Double(0)))"
        endTimeText.text = "\(Int(imageFrameView.endTime?.seconds ?? Double(0)) + 1)"
        shaodowView.isHidden = false
        self.videoBtn.setImage(UIImage(named: "video_play"), for: .normal)
    }
}
