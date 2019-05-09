//
//  UIHelper.swift
//  Mars Rover
//
//  Created by Antonio Yip on 8/05/19.
//

import Foundation
import UIKit

let gridSize: CGFloat = 84

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

extension UIView {
    func convertCoordinateToPoint(_ coordinate: Coordinate, unitSize: CGSize) -> CGPoint {
        return CGPoint(
            x: CGFloat(coordinate.x) * unitSize.width,
            y: self.bounds.height - CGFloat( coordinate.y + 1) * unitSize.height
        )
    }

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

extension UIColor {
    static var lightBlue = UIColor(red: 52/255, green: 120/255, blue: 246/255, alpha: 1)
}
