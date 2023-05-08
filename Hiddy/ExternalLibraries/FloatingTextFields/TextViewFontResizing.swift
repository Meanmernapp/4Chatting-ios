//
//  TextViewFontResizing.swift
//  Hiddy
//
//  Created by Hitasoft on 05/08/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit
extension UIFont {
    /**
     Will return the best approximated font size which will fit in the bounds.
     If no font with name `fontName` could be found, nil is returned.
     */
    static func bestFitFontSize(for text: String, in bounds: CGRect, fontName: String) -> CGFloat? {
        var maxFontSize: CGFloat = 32.0 // UIKit best renders with factors of 2
        guard let maxFont = UIFont(name: fontName, size: maxFontSize) else {
            return nil
        }
        let textWidth = text.width(withConstraintedHeight: bounds.width, font: maxFont)
        let textHeight = text.height(withConstrainedWidth: bounds.height, font: maxFont)
        // Determine the font scaling factor that should allow the string to fit in the given rect
        let scalingFactor = min(bounds.height / textHeight, bounds.width / textWidth)
        // Adjust font size
        maxFontSize *= scalingFactor
        if Int(floor(maxFontSize)) < 50 && Int(floor(maxFontSize)) > 14 {
            return floor(maxFontSize)
        }
        else if Int(floor(maxFontSize)) > 50 {
            return CGFloat(50)
        }
        else {
            return CGFloat(20)
        }
    }
}
fileprivate extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}
extension UITextView {
    
    /// Will auto resize the contained text to a font size which fits the frames bounds
    /// Uses the pre-set font to dynamicly determine the proper sizing
    func fitTextToBounds() {
        guard let text = text, let currentFont = font else { return }
        
        if let dynamicFontSize = UIFont.bestFitFontSize(for: text, in: bounds, fontName: currentFont.fontName) {
            font = UIFont(name: currentFont.fontName, size: dynamicFontSize)
        }
    }
    
}
