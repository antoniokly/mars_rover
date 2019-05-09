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
    private (set) var actions: [Action] = []
    var bound: Coordinate?
    
    init(name: String, position: Position) {
        self.name = name
        self.initialPosition = position
    }
    
    var finalPosition: Position {
        return actions.transform(initialPosition)
    }
    
    var commandString: String {
        return actions.commandString
    }
    
    func setCommandString(_ command: String) throws {
        guard var newActions: [Action] = Array(commandString: command) else {
            return
        }
        
        if let limit = bound {
            NSLog("Validating site boundary: %@", limit.string)
            
            var newPosition = initialPosition
            for i in 0 ..< newActions.count {
                let action = newActions[i]
                newPosition = newActions[i].transform(newPosition)
                
                if newPosition.coordinate.isOutside(upper: limit, lower: .origin) {
                    NSLog("Out of bound (%@) after step %d (%@). Warning: Command is truncated.", newPosition.string, i, action.command)
                    
                    newActions = Array(newActions.prefix(upTo: i))
                    
                    throw NSError(domain: commandErrorDomain,
                                  code: -1,
                                  userInfo: nil)
                }
            }
        }
        
        self.actions = newActions
    }
    
    func addAction(_ action: Action) throws {
        if action == .moveForward, let limit = bound  {
            let positionAfter = action.transform(finalPosition)
            
            if positionAfter.coordinate.isOutside(upper: limit, lower: .origin) {
                throw NSError(domain: commandErrorDomain,
                              code: -1,
                              userInfo: nil)
            }
        }
        
        actions.append(action)
    }
    
    func removeAllActions() {
        actions.removeAll()
    }
}

extension Rover: Hashable {
    static func == (lhs: Rover, rhs: Rover) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
