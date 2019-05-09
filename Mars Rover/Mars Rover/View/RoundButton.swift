//
//  RoundButton.swift
//  Mars Rover
//
//  Created by Antonio Yip on 9/05/19.
//

import UIKit


@IBDesignable
class RoundButton: UIButton {
    
    @IBInspectable
    var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var mirrored: Bool = false {
        didSet {
            self.transform = CGAffineTransform(scaleX: mirrored ? -1 : 1, y: 1 )
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.layer.opacity = super.isHighlighted ? 0.5 : 1
        }
    }
}

