//
//  UIHelper.swift
//  Mars Rover
//
//  Created by Antonio Yip on 8/05/19.
//

import Foundation
import UIKit

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func convertToPoint(_ coordinate: Coordinate, in grid: Coordinate, unitSize: CGSize) -> CGPoint {
    return CGPoint(
        x: CGFloat(coordinate.x) * unitSize.width,
        y: CGFloat(grid.y - coordinate.y - 1) * unitSize.height)
}

extension UIView {
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
