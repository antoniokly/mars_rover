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
            rover.bound = grid
        }
    }
    
    func addRover(_ rover: Rover) throws {
        let avoids = rovers.map({$0.initialPosition.coordinate})
        
        if avoids.contains(rover.initialPosition.coordinate) {
            let message = String(format: "There is already a rover at %@", rover.initialPosition.coordinate.string)
            
            throw NSError(domain: commandErrorDomain,
                          code: -1,
                          userInfo: ["message" : message])
        }
        
        rovers.append(rover)
        rover.bound = grid
    }
}
