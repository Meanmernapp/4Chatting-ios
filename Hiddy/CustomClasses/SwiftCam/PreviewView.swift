import UIKit
import AVFoundation
public enum SwiftyCamVideoGravity {
    case resize
    case resizeAspect
    case resizeAspectFill
}

class PreviewView: UIView {
    
    private var gravity: SwiftyCamVideoGravity = .resizeAspect
    
    init(frame: CGRect, videoGravity: SwiftyCamVideoGravity) {
        gravity = videoGravity
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewlayer = layer as! AVCaptureVideoPreviewLayer
        switch gravity {
        case .resize:
            previewlayer.videoGravity = AVLayerVideoGravity.resize
        case .resizeAspect:
            previewlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        case .resizeAspectFill:
            previewlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        return previewlayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    // MARK: UIView
    
    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
