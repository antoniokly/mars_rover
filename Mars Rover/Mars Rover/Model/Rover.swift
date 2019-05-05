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
    var actions: [Action] = []
    
    init(name: String, position: Position) {
        self.name = name
        self.initialPosition = position
    }
    
    var finalPosition: Position {
        var newPosition = initialPosition
        
        for action in actions {
            newPosition = action.transform(newPosition)
        }
        
        return newPosition
    }
}
