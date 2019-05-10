//
//  Site.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

class Site {
    var name: String
    var grid: Coordinate
    var origin: Coordinate = .origin
    private (set) var rovers: [Rover]
    
    var commandString: String {
        var strings = [ grid.string ]
        let r = rovers.map({"\($0.initialPosition.string)\n\($0.commandString)"})
        
        strings.append(contentsOf: r)
        
        return strings.joined(separator: "\n")
    }
    
    init(name: String, grid: Coordinate, rovers: [Rover] ) {
        self.name = name
        self.grid = grid
        self.rovers = rovers
        
        for rover in self.rovers {
            rover.upperBound = grid
            rover.lowerBound = origin
        }
    }
    
    func addRover(_ rover: Rover) throws {
        if rover.initialPosition.coordinate.isOutside(upper: grid, lower: origin) {
            let message = String(format: "%@'s initial position is out of bound.",
                                 rover.name)
            
            throw NSError(domain: commandErrorDomain,
                          code: -1,
                          userInfo: ["message" : message])
        }
        
        let avoids = rovers.map({$0.initialPosition.coordinate})
        
        if avoids.contains(rover.initialPosition.coordinate) {
            let message = String(format: "%@'s initial position is already occupied.",
                                 rover.name)
            
            throw NSError(domain: commandErrorDomain,
                          code: -1,
                          userInfo: ["message" : message])
        }
        
        rover.upperBound = grid
        rover.lowerBound = origin
        rovers.append(rover)
    }
}
