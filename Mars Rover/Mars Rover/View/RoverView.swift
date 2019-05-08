//
//  RoverView.swift
//  Mars Rover
//
//  Created by Antonio Yip on 8/05/19.
//

import UIKit

class RoverView: UIImageView {

//    var rover: Rover!
//    var position: Position!
//    var animations: [() -> Void] = []
    
//
//    /*
//    // Only override draw() if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//    }
//    */
//    
//   
//
    init(rover: Rover) {
        super.init(image: UIImage(imageLiteralResourceName: "rover-top"))
//        self.rover = rover
//        self.position = rover.initialPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
//
//
//    func move(distance: CGFloat, angle: CGFloat) {
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       options: [],
//                       animations: {
//                        self.center = self.center.applying(
//                            CGAffineTransform(translationX: distance * cos(-angle),
//                                              y: distance * sin(-angle)))
//        })
//    }
//    
//    func rotate(angle: CGFloat) {
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       options: [],
//                       animations: {
//                        
//                        self.transform = self.transform.concatenating(CGAffineTransform(rotationAngle: -angle))
//        })
//    }
}

extension RoverView {
    func moveAnimationBlock(distance: CGFloat, angle: CGFloat) -> () -> Void {
        return { [weak self] in
            if self == nil { return }
            self!.center = self!.center.applying(
                CGAffineTransform(translationX: distance * cos(-angle),
                                  y: distance * sin(-angle)))
        }
    }
    
    func rotateAnimationBlock(angle: CGFloat) -> () -> Void {
        return { [weak self] in
            if self == nil { return }
            self!.transform = self!.transform.concatenating(CGAffineTransform(rotationAngle: -angle))
        }
    }
}
