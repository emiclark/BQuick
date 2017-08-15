//
//  PaddedLabel.swift
//  BQuick
//
//  Created by Emiko Clark on 5/24/17.
//  Copyright © 2017 Emiko Clark. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class PaddedLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 30.0
    @IBInspectable var bottomInset: CGFloat = 30.0
    @IBInspectable var leftInset: CGFloat = 30.0
    @IBInspectable var rightInset: CGFloat = 30.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}

extension UILabel {
    func setSizeFont (sizeFont: CGFloat) {
        self.font =  UIFont(name: self.font.fontName, size: sizeFont)!
        self.sizeToFit()
    }
}
