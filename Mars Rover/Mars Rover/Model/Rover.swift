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
    var bound: Coordinate?
    
    init(name: String, position: Position) {
        self.name = name
        self.initialPosition = position
    }
    
    var finalPosition: Position {
        return actions.transform(initialPosition)
    }
    
    var commandString: String {
        get {
            return actions.commandString
        }
        set {
            guard var newActions: [Action] = Array(commandString: newValue) else {
                return
            }
            
            if let limit = bound {
                NSLog("Validating site boundary: %@", limit.string)
                
                var newPosition = initialPosition
                for i in 0 ..< newActions.count {
                    let action = newActions[i]
                    newPosition = newActions[i].transform(newPosition)
                    
                    if newPosition.coordinate.x > limit.x || newPosition.coordinate.y > limit.y || newPosition.coordinate.x < 0 || newPosition.coordinate.y < 0 {
                        NSLog("Out of bound (%@) after step %d (%@). Warning: Command is truncated.", newPosition.string, i, action.command)
                        
                        newActions = Array(newActions.prefix(upTo: i))
                        break
                    }
                }
            }

            self.actions = newActions
        }
    }
}
