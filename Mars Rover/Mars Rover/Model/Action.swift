//
//  Action.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

struct Action {
    var command: String
    var transform: (Position) -> Position
    
    static let moveForward = Action(command: "M") { (position) -> Position in
        return Position(
            coordinate: Coordinate(
                x: position.coordinate.x + cos(position.heading.angle),
                y: position.coordinate.y + sin(position.heading.angle)
            ),
            heading: position.heading
        )
    }
    
    static let spinLeft = Action(command: "L") { (position) -> Position in
        return Position(
            coordinate: position.coordinate,
            heading: position.heading.left
        )
    }
    
    static let spinRight = Action(command: "R") { (position) -> Position in
        return Position(
            coordinate: position.coordinate,
            heading: position.heading.right
        )
    }
}