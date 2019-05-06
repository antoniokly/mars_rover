//
//  Mars_RoverTests.swift
//  Mars RoverTests
//
//  Created by Antonio Yip on 5/05/19.
//

import XCTest
@testable import Mars_Rover

class Mars_RoverTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMoveForward() {
        
        let headings: [Heading] = [.E, .N, .W, .S]
        
        let rovers = headings.map({ heading -> Rover in
            let rover = Rover(name: "Rover \(heading.rawValue)",
                position: Position(coordinate: Coordinate(x: 1, y: 1), heading: heading)
            )
            
            rover.actions.append(.moveForward)
            
            return rover
        })
        
        XCTAssertEqual(rovers[0].initialPosition.string, "1 1 E")
        XCTAssertEqual(rovers[0].finalPosition.string, "2 1 E")
        
        XCTAssertEqual(rovers[1].initialPosition.string, "1 1 N")
        XCTAssertEqual(rovers[1].finalPosition.string, "1 2 N")
        
        XCTAssertEqual(rovers[2].initialPosition.string, "1 1 W")
        XCTAssertEqual(rovers[2].finalPosition.string, "0 1 W")
        
        XCTAssertEqual(rovers[3].initialPosition.string, "1 1 S")
        XCTAssertEqual(rovers[3].finalPosition.string, "1 0 S")
    }
    
    func testSpinLeft() {
        let rover = Rover(name: "Rover L",
                          position: Position(coordinate: Coordinate(x: 1, y: 1), heading: .E))
        
        XCTAssertEqual(rover.initialPosition.string, "1 1 E")
        
        rover.actions.append(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 N")
        
        rover.actions.append(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 W")
        
        rover.actions.append(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 S")
        
        rover.actions.append(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 E")
    }
    
    func testSpinRight() {
        let rover = Rover(name: "Rover R",
                          position: Position(coordinate: Coordinate(x: 1, y: 1), heading: .E))
        
        XCTAssertEqual(rover.initialPosition.string, "1 1 E")
        
        rover.actions.append(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 S")
        
        rover.actions.append(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 W")
        
        rover.actions.append(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 N")
        
        rover.actions.append(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 E")
    }
    
    func testCommandString() {
        let rover = Rover(name: "Rover 1",
                          position: Position(coordinate: Coordinate(x: 1, y: 1), heading: .E))
        
        rover.actions = [
            .moveForward,
            .spinLeft,
            .spinRight,
            .moveForward,
            .spinRight,
            .spinLeft,
            .spinLeft,
            .spinLeft,
            .spinLeft,
            .moveForward,
            .moveForward
        ]
        
        XCTAssertEqual(rover.commandString, "MLRMRLLLLMM")
    }
    
    func testSetCommandString() {
        let rover = Rover(name: "Rover 1",
                          position: Position(coordinate: Coordinate(x: 1, y: 1), heading: .E))
        
        rover.commandString = "MLRMRLLLLMM"
        
        let expected: [Action] = [
            .moveForward,
            .spinLeft,
            .spinRight,
            .moveForward,
            .spinRight,
            .spinLeft,
            .spinLeft,
            .spinLeft,
            .spinLeft,
            .moveForward,
            .moveForward
        ]
        
        XCTAssertEqual(rover.actions, expected)
        XCTAssertEqual(rover.commandString, "MLRMRLLLLMM")
    }
    
    func testInvalidCommandString() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.commandString = "MLRMRLXXXLZZZMM"
        
        XCTAssertTrue(rover1.actions.isEmpty)
        XCTAssertEqual(rover1.commandString, "")
    }
    
    func testOutOfBoundX() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.bound = Coordinate(x: 5, y: 5)
        rover1.commandString = "RMMMMMMMMLLMMMMM"
        
        XCTAssertEqual(rover1.commandString, "RMMMM")
        XCTAssertEqual(rover1.finalPosition.string, "5 2 E")
    }
    
    func testOutOfBoundY() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.bound = Coordinate(x: 5, y: 5)
        rover1.commandString = "MMMMMMMMLLMMMMMMMMM"
        
        XCTAssertEqual(rover1.commandString, "MMM")
        XCTAssertEqual(rover1.finalPosition.string, "1 5 N")
    }
    
    func testNoBound() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.commandString = "MMMMMMMMLLMMMMMMMMMMMRMMM"
        
        XCTAssertEqual(rover1.commandString, "MMMMMMMMLLMMMMMMMMMMMRMMM")
        XCTAssertEqual(rover1.finalPosition.string, "-2 -1 W")
    }
    
    func testOutOfBoundNegative() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 3, y: 3), heading: .E))
        let _ = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        rover1.commandString = "LMMMLLMMM"
        rover2.commandString = "RMMMMMMRRMMMMM"
        
        XCTAssertEqual(rover1.commandString, "LM")
        XCTAssertEqual(rover1.finalPosition.string, "0 2 W")
        
        XCTAssertEqual(rover2.commandString, "RMMM")
        XCTAssertEqual(rover2.finalPosition.string, "3 0 S")
    }
    
    func testExample() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 3, y: 3), heading: .E))
        let site = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        rover1.commandString = "LMLMLMLMM"
        rover2.commandString = "MMRMMRMRRM"
    
        //assert input
        XCTAssertEqual(site.grid.string, "5 5")
        XCTAssertEqual(rover1.initialPosition.string, "1 2 N")
        XCTAssertEqual(rover1.actions, [.spinLeft,
                                        .moveForward,
                                        .spinLeft,
                                        .moveForward,
                                        .spinLeft,
                                        .moveForward,
                                        .spinLeft,
                                        .moveForward,
                                        .moveForward]
        )
        XCTAssertEqual(rover2.initialPosition.string, "3 3 E")
        XCTAssertEqual(rover2.actions, [.moveForward,
                                        .moveForward,
                                        .spinRight,
                                        .moveForward,
                                        .moveForward,
                                        .spinRight,
                                        .moveForward,
                                        .spinRight,
                                        .spinRight,
                                        .moveForward]
        )
        
        //assert output
        XCTAssertEqual(rover1.finalPosition.string, "1 3 N")
        XCTAssertEqual(rover2.finalPosition.string, "5 1 E")
    }
}
