//
//  CommandHelper.swift
//  Mars Rover
//
//  Created by Antonio Yip on 8/05/19.
//

import Foundation

let gridPattern = #"^(\d+)\h(\d+)"#
let roverPattern = #"(\d+)\h(\d+)\h((N|E|S|W))\n((M|L|R)*)"#

class CommandHelper {
    
    static func resolveMultiLineCommand(_ command: String) -> Site? {
        
        //site
        guard let regex = try? NSRegularExpression(pattern: gridPattern),
            let match = regex.firstMatch(in: command,
                                           range: NSRange(command.startIndex..., in: command)) else {
                                            return nil
        }
        
        
        let grid = String(command[Range(match.range, in: command)!])
            .components(separatedBy: [" ", "\n"])
            .compactMap({Int($0)})
        
        let site = Site(name: "Site", grid: Coordinate(x: grid[0], y: grid[1]), rovers: [])
        
        
        //Rovers
        guard let regex1 = try? NSRegularExpression(pattern: roverPattern) else {
            return site
        }
        
        let roversMatch = regex1.matches(in: command,
                                         range: NSRange(command.startIndex..., in: command))
        
        for match in roversMatch {
            let r = String(command[Range(match.range, in: command)!]).components(separatedBy: [" ", "\n"])
            
            guard let x = Int(r[0]), let y = Int(r[1]), let h = Heading(rawValue: r[2]) else {
                continue
            }
            
            let position = Position(coordinate: Coordinate(x: x, y: y), heading: h)
            
            let rover = Rover(name: "Rover \(site.rovers.count + 1)", position: position)
            
            rover.commandString = r[3]
            
            site.rovers.append(rover)
        }
        
        return site
    }
}
