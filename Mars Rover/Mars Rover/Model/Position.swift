//
//  Position.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

struct Position {
    var coordinate: Coordinate
    var heading : Heading
    
    var string: String {
        return String(format: "%@ %@", coordinate.string, heading.rawValue)
    }
}
