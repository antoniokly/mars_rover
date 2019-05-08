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
    var rovers: [Rover]
    
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
}
