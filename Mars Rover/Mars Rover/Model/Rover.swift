//
//  Rover.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

class Rover {
    private (set) var initialPosition: Position
    var name: String
    
    init(name: String, position: Position) {
        self.name = name
        self.initialPosition = position
    }
}
