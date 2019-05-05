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
    
    init(name: String, grid: Coordinate, rovers: [Rover] ) {
        self.name = name
        self.grid = grid
        self.rovers = rovers
        
        for rover in self.rovers {
            rover.bound = grid
        }
    }
}
