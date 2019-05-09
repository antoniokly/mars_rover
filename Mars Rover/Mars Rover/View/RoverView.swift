//
//  RoverView.swift
//  Mars Rover
//
//  Created by Antonio Yip on 8/05/19.
//

import UIKit

class RoverView: UIImageView {

    var rover: Rover!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var square: UIView!
    
    init(rover: Rover) {
        self.rover = rover
        super.init(image: UIImage(imageLiteralResourceName: "rover-top"))
        
        square = UIView(frame: CGRect(origin: .zero, size: CGSize(width: gridSize, height: gridSize)))
        
        square.layer.borderColor = UIColor.lightBlue.cgColor
        square.layer.borderWidth = 3
        square.layer.opacity = 0
        
        addSubview(square)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startFlashing() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0
        animation.toValue = 0.5
        animation.duration = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        square.layer.add(animation, forKey: "opacity")
        square.isHidden = false
    }
    
    func stopFlashing() {
        square.layer.removeAllAnimations()
        square.isHidden = true
    }
}
