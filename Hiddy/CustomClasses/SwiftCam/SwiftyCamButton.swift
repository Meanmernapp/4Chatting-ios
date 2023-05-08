
import UIKit

public protocol SwiftyCamButtonDelegate: class {
    func buttonWasTapped()
    func buttonDidBeginLongPress()
    func buttonDidEndLongPress()
    func longPressDidReachMaximumDuration()
    func setMaxiumVideoDuration() -> Double
}
open class SwiftyCamButton: UIButton {
    public weak var delegate: SwiftyCamButtonDelegate?
    public var buttonEnabled = true
    fileprivate var timer : Timer?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createGestureRecognizers()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createGestureRecognizers()
    }
    @objc fileprivate func Tap() {
        guard buttonEnabled == true else {
            return
        }
        buttonEnabled = false
       delegate?.buttonWasTapped()
    }
    @objc fileprivate func LongPress(_ sender:UILongPressGestureRecognizer!)  {
        guard buttonEnabled == true else {
            return
        }
        
        switch sender.state {
        case .began:
            delegate?.buttonDidBeginLongPress()
            startTimer()
        case .cancelled, .ended, .failed:
            invalidateTimer()
            delegate?.buttonDidEndLongPress()
        default:
            break
        }
    }
    
    /// Timer Finished
    
    @objc fileprivate func timerFinished() {
        invalidateTimer()
        delegate?.longPressDidReachMaximumDuration()
    }
    
    /// Start Maximum Duration Timer
    
    fileprivate func startTimer() {
        if let duration = delegate?.setMaxiumVideoDuration() {
            //Check if duration is set, and greater than zero
            if duration != 0.0 && duration > 0.0 {
                timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector:  #selector(SwiftyCamButton.timerFinished), userInfo: nil, repeats: false)
            }
        }
    }
    
    // End timer if UILongPressGestureRecognizer is ended before time has ended
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Add Tap and LongPress gesture recognizers
    
    fileprivate func createGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SwiftyCamButton.Tap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SwiftyCamButton.LongPress))
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(longGesture)
    }
}
