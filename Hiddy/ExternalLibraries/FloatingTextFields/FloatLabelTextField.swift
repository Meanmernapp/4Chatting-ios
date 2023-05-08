//
//  FloatLabelTextField.swift
//  FloatLabelFields
//
//  Created by Fahim Farook on 28/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Objective-C version by Jared Verdi
//  https://github.com/jverdi/JVFloatLabeledTextField
//

import UIKit

let POP_UP_SHOW_TIME = 10.0
let POP_UP_BG_COLOR = UIColor(red: (248.0 / 255.0), green: (65.0 / 255.0), blue: (65.0 / 255.0), alpha: 1.0)

@IBDesignable class FloatLabelTextField: UITextField {
	let animationDuration = 0.3
	var title = UILabel()
    var message = String()
    var alertParentView: UIView?
	// MARK:- Properties
	override var accessibilityLabel:String? {
		get {
			if let txt = text , txt.isEmpty {
				return title.text
			} else {
				return text
			}
		}
		set {
			self.accessibilityLabel = newValue
		}
	}
	
	override var placeholder:String? {
		didSet {
			title.text = placeholder
			title.sizeToFit()
		}
	}
	
	override var attributedPlaceholder:NSAttributedString? {
		didSet {
			title.text = attributedPlaceholder?.string
			title.sizeToFit()
		}
	}
	
	var titleFont:UIFont = UIFont.systemFont(ofSize: 12.0) {
		didSet {
			title.font = titleFont
			title.sizeToFit()
		}
	}
	
	@IBInspectable var hintYPadding:CGFloat = 0.0

	@IBInspectable var titleYPadding:CGFloat = 0.0 {
		didSet {
			var r = title.frame
			r.origin.y = titleYPadding
			title.frame = r
		}
	}
	
	@IBInspectable var titleTextColour:UIColor = UIColor.gray {
		didSet {
			if !isFirstResponder {
				title.textColor = titleTextColour
			}
		}
	}
	
	@IBInspectable var titleActiveTextColour:UIColor! {
		didSet {
			if isFirstResponder {
				title.textColor = TEXT_PRIMARY_COLOR
			}
		}
	}
		
	// MARK:- Init
	required init?(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)
		setup()
	}
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		setup()
	}
	
	// MARK:- Overrides
	override func layoutSubviews() {
		super.layoutSubviews()
		setTitlePositionForTextAlignment()
		let isResp = isFirstResponder
       
		if let txt = text , !txt.isEmpty && isResp {
			title.textColor = TEXT_PRIMARY_COLOR
		} else {
			title.textColor = titleTextColour
		}
		// Should we show or hide the title label?
		if let txt = text , txt.isEmpty {
			// Hide
			hideTitle(isResp)
		} else {
			// Show
			showTitle(isResp)
		}

	}
	
	override func textRect(forBounds bounds:CGRect) -> CGRect {
		var r = super.textRect(forBounds: bounds)
		if let txt = text , !txt.isEmpty {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
//            r = UIEdgeInsetsInsetRect(r, UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
		}
		return r.integral
	}
	
	override func editingRect(forBounds bounds:CGRect) -> CGRect {
		var r = super.editingRect(forBounds: bounds)
		if let txt = text , !txt.isEmpty {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
//            r = UIEdgeInsetsInsetRect(r, UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
		}
		return r.integral
	}
	
	override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
		var r = super.clearButtonRect(forBounds: bounds)
		if let txt = text , !txt.isEmpty {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
			r = CGRect(x:r.origin.x, y:r.origin.y + (top * 0.5), width:r.size.width, height:r.size.height)
		}
		return r.integral
	}
	
	// MARK:- Public Methods
	
	// MARK:- Private Methods
	fileprivate func setup() {
        borderStyle = UITextField.BorderStyle.none
		titleActiveTextColour = TEXT_PRIMARY_COLOR
		// Set up title label
		title.alpha = 0.0
		title.font = titleFont
		title.textColor = titleTextColour
		if let str = placeholder , !str.isEmpty {
			title.text = str
			title.sizeToFit()
		}
		self.addSubview(title)
	}

	fileprivate func maxTopInset()->CGFloat {
		if let fnt = font {
			return max(0, floor(bounds.size.height - fnt.lineHeight - 4.0))
		}
		return 0
	}
	
	fileprivate func setTitlePositionForTextAlignment() {
		let r = textRect(forBounds: bounds)
		var x = r.origin.x
		if textAlignment == NSTextAlignment.center {
			x = r.origin.x + (r.size.width * 0.5) - title.frame.size.width
		} else if textAlignment == NSTextAlignment.right {
			x = r.origin.x + r.size.width - title.frame.size.width
		}
		title.frame = CGRect(x:x, y:title.frame.origin.y, width:title.frame.size.width, height:title.frame.size.height)
	}
	
	fileprivate func showTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
				// Animation
				self.title.alpha = 1.0
				var r = self.title.frame
				r.origin.y = self.titleYPadding
				self.title.frame = r
			}, completion:nil)
	}
	
	fileprivate func hideTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
			// Animation
			self.title.alpha = 0.0
			var r = self.title.frame
			r.origin.y = self.title.font.lineHeight + self.hintYPadding
			self.title.frame = r
			}, completion:nil)
	}
    
    func setAsInvalidTF(_ message: String, in view: UIView) {
        self.message = Utility.shared.getLanguage()?.value(forKey: message) as! String
        alertParentView = view
        // add info button as right view of textfield
        let buttonSide: CGFloat = frame.size.height - (2 * 2.0)
        if rightView != nil {
            rightView = nil
            rightViewMode = .never
        }
        let infoButton = UIButton(frame: CGRect(x: frame.size.width - (buttonSide + 2.0), y: 2.0, width: buttonSide + 2.0, height: buttonSide))
        infoButton.setImage(#imageLiteral(resourceName: "info_alert"), for: .normal)
        infoButton.imageView?.contentMode = .center
        infoButton.addTarget(self, action: #selector(self.presentPopUpAlertView), for: .touchUpInside)
        rightView = infoButton
        rightViewMode = .always
    }
    
    func setAsValidTF() {
        // remove info button
        if rightView != nil {
            rightView = nil
            rightViewMode = .never
        }
    }
    func isValidField() -> Bool {
        var validField = true
        if rightView != nil {
            validField = false
        }
        return validField
    }
    
    @objc func presentPopUpAlertView() {
        let popTipView = HSTipView(message: message)
        popTipView?.backgroundColor = SECONDARY_COLOR
        popTipView?.textColor = UIColor.white
        popTipView?.animation = CMPopTipAnimation(rawValue: arc4random() % 2)
        popTipView?.has3DStyle = false
        popTipView?.dismissTapAnywhere = true
        popTipView?.borderColor = UIColor.clear
        popTipView?.autoDismiss(animated: true, atTimeInterval: POP_UP_SHOW_TIME)
        popTipView?.presentPointing(at: rightView, in: alertParentView, animated: true)
    }

}
