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
    
    func setCommandString(_ command: String, avoids: [Coordinate] = []) throws {
        guard var newActions: [Action] = Array(commandString: command) else {
            return
        }
        
        if let limit = bound {
            NSLog("Validating site boundary: %@", limit.string)
            
            var newPosition = initialPosition
            for i in 0 ..< newActions.count {
                newPosition = newActions[i].transform(newPosition)
                
                if avoids.contains(newPosition.coordinate) {
                    let message = String(format: "%@ is running into avoiding position (%@) after step %d.", name, newPosition.coordinate.string, i)
                    
                    newActions = Array(newActions.prefix(upTo: i))
                    
                    throw NSError(domain: commandErrorDomain,
                                  code: -1,
                                  userInfo: ["message": message])
                }
                
                if newPosition.coordinate.isOutside(upper: limit, lower: .origin) {
                    let message = String(format: "%@ is running out of bound (%@) after step %d.", name, newPosition.coordinate.string, i)
                    
                    newActions = Array(newActions.prefix(upTo: i))
                    
                    throw NSError(domain: commandErrorDomain,
                                  code: -1,
                                  userInfo: ["message": message])
                }
            }
        }
        
        self.actions = newActions
    }
    
    func addAction(_ action: Action, in site: Site? = nil) throws {
        if action == .moveForward, let limit = bound  {
            var avoids: [Coordinate] = []
            
            if let site = site, let i = site.rovers.index(of: self) {
                avoids =
                    // leaders' final positions
                    site.rovers.prefix(upTo: i).map({$0.finalPosition.coordinate}) +
                    // followers' initial positions
                    site.rovers.suffix(from: i + 1).map({$0.initialPosition.coordinate})
            }
            
            let positionAfter = action.transform(finalPosition)
            
            if avoids.contains(positionAfter.coordinate) {
                let message = String(format: "%@ is running into avoiding position (%@).", name, positionAfter.coordinate.string)
                
                throw NSError(domain: commandErrorDomain,
                              code: -1,
                              userInfo: ["message": message])
            }
            
            if positionAfter.coordinate.isOutside(upper: limit, lower: .origin) {
                let message = String(format: "%@ is running out of bound.", name)
                
                throw NSError(domain: commandErrorDomain,
                              code: -1,
                              userInfo: ["message": message])
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
