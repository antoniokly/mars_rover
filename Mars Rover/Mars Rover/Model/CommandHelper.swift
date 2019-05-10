//
//  CommandHelper.swift
//  Mars Rover
//
//  Created by Antonio Yip on 8/05/19.
//

import Foundation

let gridPattern = #"^(\d+)\h(\d+)"#
let roverPattern = #"(\d+)\h(\d+)\h((N|E|S|W))\n((M|L|R)*)"#

let commandErrorDomain = "commandErrorDomain"

class CommandHelper {
    
    static func resolveMultiLineCommand(_ command: String) throws -> Site {
        
        //resolve site form the first line
        let regex = try NSRegularExpression(pattern: gridPattern)
        guard let match = regex.firstMatch(in: command, range: NSRange(command.startIndex..., in: command)) else {
            throw NSError(domain: commandErrorDomain,
                          code: -1,
                          userInfo: ["message": "No site coordinate is found."])
        }
        
        let grid = String(command[Range(match.range, in: command)!])
            .components(separatedBy: [" ", "\n"])
            .compactMap({Int($0)})
        
        let site = Site(name: "Site", grid: Coordinate(x: grid[0], y: grid[1]), rovers: [])
        
        
        //resolve rovers
        let regex1 = try NSRegularExpression(pattern: roverPattern)
        
        let roversMatch = regex1.matches(in: command, range: NSRange(command.startIndex..., in: command))
        
        var rovers: [Rover] = []
        var commands: [String] = []
        
        for match in roversMatch {
            let r = String(command[Range(match.range, in: command)!]).components(separatedBy: [" ", "\n"])
            
            if let x = Int(r[0]), let y = Int(r[1]), let h = Heading(rawValue: r[2])  {
                let position = Position(coordinate: Coordinate(x: x, y: y), heading: h)
                
                let rover = Rover(name: "Rover \(rovers.count + 1)", position: position)
                
                rover.upperBound = site.grid
                rover.lowerBound = site.origin
                
                rovers.append(rover)
                commands.append(r[3])
            }
        }
        
        //place all rovers first
        for rover in rovers {
            // throws error if rover is placed out of bounds or a occupied position
            try site.addRover(rover)
        }
        
        //test for collisions
        for i in 0 ..< rovers.count {
            let rover = rovers[i]
            
            let avoids =
                // leaders' final positions
                rovers.prefix(upTo: i).map({$0.finalPosition.coordinate}) +
                // followers' initial positions
                rovers.suffix(from: i + 1).map({$0.initialPosition.coordinate})
            
            // throws error if rover run out of bounds or causing collisions
            try rover.setCommandString(commands[i], avoids: avoids)
        }
        
        return site
    }
}

extension NSError {
    var message: String? {
        return userInfo["message"] as? String
    }
}

