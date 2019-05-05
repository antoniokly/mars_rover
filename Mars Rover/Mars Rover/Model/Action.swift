//
//  Action.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

enum Action: String {
    case moveForward = "M"
    case spinLeft = "L"
    case spinRight = "R"
    
    var command: String {
        return self.rawValue
    }
    
    init?(command: String) {
        self.init(rawValue: command)
    }
    
    func transform(_ position: Position) -> Position {
        switch self {
        case .moveForward:
            return Position(
                coordinate: Coordinate(
                    x: position.coordinate.x + cos(position.heading.angle),
                    y: position.coordinate.y + sin(position.heading.angle)
                ),
                heading: position.heading
            )
        case .spinLeft:
            return Position(
                coordinate: position.coordinate,
                heading: position.heading.left
            )
        case .spinRight:
            return Position(
                coordinate: position.coordinate,
                heading: position.heading.right
            )
        }
    }
}

extension Array where Element == Action {
    func transform(_ position: Position) -> Position {
        var newPosition = position
        
        for action in self {
            newPosition = action.transform(newPosition)
        }
        
        return newPosition
    }
}
