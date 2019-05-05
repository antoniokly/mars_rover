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
        return actions.transform(initialPosition)
    }
    
    var commandString: String {
        get {
            return actions.map({$0.command}).joined()
        }
        set {
            var newActions: [Action] = []
            
            for char in newValue {
                if let action = Action(command: "\(char)") {
                    newActions.append(action)
                }
            }
            
            self.actions = newActions
        }
    }
}
