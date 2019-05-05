//
//  Coordinate.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

struct Coordinate {
    static var format: String = "%.0f"

    var x: Double
    var y: Double
    
    var string: String {
        return String(format: "\(Coordinate.format) \(Coordinate.format)", x, y)
    }
}
