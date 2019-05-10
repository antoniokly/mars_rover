//
//  Coordinate.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

struct Coordinate {
    static let format: String = "%d"
    static let origin = Coordinate(x: 0, y: 0)

    var x: Int
    var y: Int
    
    var string: String {
        return String(format: "\(Coordinate.format) \(Coordinate.format)", x, y)
    }
    
    func isOutside(upper: Coordinate?, lower: Coordinate?) -> Bool {
        if let upper = upper {
            if x > upper.x || y > upper.y {
                return true
            }
        }
        
        if let lower = lower {
            if x < lower.x || y < lower.y {
                return true
            }
        }
        
        return false
    }
}

extension Coordinate: Equatable {
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
