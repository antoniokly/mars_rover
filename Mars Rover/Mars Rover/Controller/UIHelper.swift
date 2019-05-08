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


