import UIKit
import AVFoundation
import Photos
import TLPhotoPicker
import MobileCoreServices
import HGCircularSlider

class CameraVideoController: SwiftyCamViewController, SwiftyCamViewControllerDelegate ,TLPhotosPickerViewControllerDelegate {
    
    @IBOutlet weak var closeIcon: UIImageView!
    @IBOutlet weak var flashIcon: UIImageView!
    @IBOutlet weak var cameraICon: UIImageView!
    @IBOutlet weak var typeStatusButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var colseButton: UIButton!
    @IBOutlet weak var uploaderView: CircularSlider!
    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flashButtonImage: UIImageView!
    @IBOutlet weak var loadTimeLabel: UILabel!
    //    let globalsharedDetails = GlobalDetails.getSharedUser()
    var percent = 0
    var timer: Timer!
    var selectedAssets = [TLPHAsset]()
    var startTime = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldPrompToAppSettings = true
        cameraDelegate = self
        self.maximumVideoDuration = 30
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
        flashMode = .off
        captureButton.buttonEnabled = false
        self.captureButton.layer.cornerRadius = self.captureButton.frame.height / 2
        self.captureButton.layer.borderWidth = 2
        self.captureButton.layer.borderColor = UIColor.white.cgColor
        self.setUploaderView()
    }
    func setUploaderView() {
        self.loadTimeLabel.config(color: .white, size: 14, align: .center, text: "")
        self.uploaderView.trackFillColor = UIColor.white
        self.uploaderView.diskColor = RED_COLOR
        self.loadTimeLabel.font = UIFont.init(name: APP_FONT_REGULAR, size: 20)
        self.loadTimeLabel.textColor = UIColor.white
        loadTimeLabel.layer.shadowColor = UIColor.black.cgColor
        loadTimeLabel.layer.shadowRadius = 3.0
        loadTimeLabel.layer.shadowOpacity = 1.0
        loadTimeLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        loadTimeLabel.layer.masksToBounds = false

    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startTime = 0
        uploaderView.minimumValue = 0
        uploaderView.maximumValue = CGFloat(30.0)
        self.loadTimeLabel.text = ""
        self.uploaderView.isHidden = true
        self.uploaderView.endPointValue = 0

        captureButton.delegate = self
        if let asset = self.selectedAssets.first {
            if asset.type == .video {
                if let asset = self.selectedAssets.first, asset.type == .video {
                    asset.exportVideoFile(progressBlock: { (progress) in
                        // print(progress)
                    }) { (url, mimeType) in
                        // print("completion\(url)")
                        // print(mimeType)
                    }
                }
            }
            else if let image = asset.fullResolutionImage {
                // print(image)
                //               globalsharedDetails.CAMERA_TAKEN_IMAGE = image
                let newVC = PhotoViewController(image: image)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        }
    }
    
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        captureButton.buttonEnabled = true
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        captureButton.buttonEnabled = false
    }
    
    @IBAction func btnClose_Act(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let newVC = PhotoViewController(image: photo)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        captureButton.growButton()
        hideButtons()
        self.uploaderView.isHidden = false
        self.updateTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    //set timer count
    @objc func updateTimer()  {
        self.startTime += 1
        if startTime <= 30 {
        DispatchQueue.main.async {
            self.uploaderView.endPointValue = CGFloat(self.startTime)
                self.loadTimeLabel.text = self.timeString(time: TimeInterval(self.startTime))
        }
        }
    }
    func timeString(time:TimeInterval)-> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        self.uploaderView.isHidden = true
        captureButton.shrinkButton()
        showButtons()
        self.timer.invalidate()
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
//        self.showEditor(for: url)
        print("Loaded url =\(url)")
        
        let newVC = VideoViewController(videoURL: url)
        self.navigationController?.pushViewController(newVC, animated: true)
        self.loadTimeLabel.text = ""


    }
    
    ///private/var/mobile/Containers/Data/Application/608A8F2F-172A-4464-93D0-386BBF26AB44/tmp/IMG_0828.mp4
    //file:///private/var/mobile/Containers/Data/Application/666F54A7-9740-4B9D-BCCA-41331BA08203/tmp/5B8ACA37-CB8E-4102-BB9D-E1ADD6A26FB1.mov
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // print("Did focus at point: \(point)")
        focusAnimationAt(point)
    }
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        // print("Zoom level did change. Level: \(zoom)")
        // print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        // print("Camera did change to \(camera.rawValue)")
        // print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        // print(error)
    }
    
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        self.selectedAssets = withTLPHAssets
        for asset in self.selectedAssets {
            if asset.type == .video {
                asset.exportVideoFile(progressBlock: { (progress) in
                    // print(progress)
                }) { (url, mimeType) in
                    // print("completion   \(url)")
                    // print(mimeType)
                    DispatchQueue.main.async {
//                        self.showEditor(for: url)
                        let newVC = VideoViewController(videoURL: url)
//                        newVC.assets = asset
                        self.navigationController?.pushViewController(newVC, animated: true)
                        self.loadTimeLabel.text = ""

                    }
                }
            }
            else if let image = asset.fullResolutionImage {
                // print(image)
                //               globalsharedDetails.CAMERA_TAKEN_IMAGE = image
                let newVC = PhotoViewController(image: image)
                self.navigationController?.pushViewController(newVC, animated: true)
            }
        }
    }
    @IBAction func btnGallery_Act(_ sender: Any) {
        
        //    globalsharedDetails.STR_PAGE_PUSH_PRESENT_INFO = "PUSH"
        
        let viewController = CustomPhotoPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.singleSelectedMode = false
        
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        viewController.logDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)

    }
    func exportVideo() {
        if let asset = self.selectedAssets.first, asset.type == .video {
            asset.exportVideoFile(progressBlock: { (progress) in
                // print(progress)
            }) { (url, mimeType) in
                // print("completion\(url)")
//                self.showEditor(for: url)
                let newVC = VideoViewController(videoURL: url)
                self.navigationController?.pushViewController(newVC, animated: true)
                // print(mimeType)
                self.loadTimeLabel.text = ""

            }
        }
    }
    func showEditor(for outputUrl: URL) {
        guard UIVideoEditorController.canEditVideo(atPath: outputUrl.path) else {
            print("Can't edit video at \(outputUrl.path)")
            return
        }
        
        print("Presenting video editor...")
        let vc = UIVideoEditorController()
        vc.videoPath = outputUrl.path
        vc.videoMaximumDuration = 30
        vc.videoQuality = UIImagePickerController.QualityType.typeIFrame960x540
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func editButtonAct(_ sender: UIButton) {
        let newVC = typStatusViewController()
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    func getAsyncCopyTemporaryFile() {
        if let asset = self.selectedAssets.first {
            asset.tempCopyMediaFile(convertLivePhotosToJPG: false, progressBlock: { (progress) in
                // print(progress)
            }, completionBlock: { (url, mimeType) in
                // print("completion\(url)")
                // print(mimeType)
            })
            
        }
    }
//    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
//        // if you want to used phasset.
//    }
    
    func photoPickerDidCancel() {
        selectedAssets = [TLPHAsset]()
        // cancel
    }
    
    func dismissComplete() {
        // picker dismiss completion
    }
    static func deleteAsset(at path: String) {
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            print("Deleted asset file at: \(path)")
        } catch {
            print("Failed to delete assete file at: \(path).")
            print("\(error)")
        }
    }
    
}
extension CameraVideoController: UIVideoEditorControllerDelegate, UINavigationControllerDelegate {
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        print("Result saved to path: \(editedVideoPath)")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            CameraVideoController.deleteAsset(at: editor.videoPath)
        })
        
//        let asset = AVAsset(url: URL(fileURLWithPath: editedVideoPath))
//        printAssetDetails(asset: asset)
        
        dismiss(animated:true, completion: {
            let urlVal = URL(fileURLWithPath: editedVideoPath)
            let newVC = VideoViewController(videoURL: urlVal)
            self.navigationController?.pushViewController(newVC, animated: true)

        })
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        dismiss(animated:true)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            CameraVideoController.deleteAsset(at: editor.videoPath)
        })
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        print("an error occurred: \(error.localizedDescription)")
        dismiss(animated:true)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            CameraVideoController.deleteAsset(at: editor.videoPath)
        })
    }
}
// UI Animations
extension CameraVideoController {
    
    fileprivate func hideButtons() {
        self.colseButton.isHidden = true
        self.galleryButton.isHidden = true
        self.typeStatusButton.isHidden = true
        UIView.animate(withDuration: 0.25) {
             self.flashButton.isHidden = true
            self.flipCameraButton.isHidden = true
            self.cameraICon.isHidden = true
            self.flashIcon.isHidden = true
            self.closeIcon.isHidden = true
        }
    }
    
    fileprivate func showButtons() {
        self.colseButton.isHidden = false
        self.galleryButton.isHidden = false
        self.typeStatusButton.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.flashButton.isHidden = false
            self.flipCameraButton.isHidden = false
            self.cameraICon.isHidden = false
            self.flashIcon.isHidden = false
            self.closeIcon.isHidden = false

        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
        //flashEnabled = !flashEnabled
        if flashMode == .auto{
            flashMode = .on
            // print("on")
            flashButtonImage.image = UIImage(named: "flash_act.png")
        }else if flashMode == .on{
            flashMode = .off
            // print("on")
            flashButtonImage.image = UIImage(named: "flash.png")
        }else if flashMode == .off{
            flashMode = .on
            // print("on")
            flashButtonImage.image = UIImage(named: "flash_act.png")
        }
    }
}
extension TimeInterval {
    var durationText: String {
        let hours:Int = Int(self / 3600)
        let minutes:Int = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(self.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
extension CameraVideoController: TLPhotosPickerLogDelegate {
    //For Log User Interaction
    func selectedCameraCell(picker: TLPhotosPickerViewController) {
        // print("selectedCameraCell")
    }
    
    func selectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        // print("selectedPhoto")
    }
    
    func deselectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        // print("deselectedPhoto")
    }
    
    func selectedAlbum(picker: TLPhotosPickerViewController, title: String, at: Int) {
        // print("selectedAlbum")
    }
    //Trim Video Function
    static func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil)
    {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
}
