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
            
            try? rover.addAction(.moveForward)
            
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
        
        try? rover.addAction(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 N")
        
        try? rover.addAction(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 W")
        
        try? rover.addAction(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 S")
        
        try? rover.addAction(.spinLeft)
        XCTAssertEqual(rover.finalPosition.string, "1 1 E")
    }
    
    func testSpinRight() {
        let rover = Rover(name: "Rover R",
                          position: Position(coordinate: Coordinate(x: 1, y: 1), heading: .E))
        
        XCTAssertEqual(rover.initialPosition.string, "1 1 E")
        
        try? rover.addAction(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 S")
        
        try? rover.addAction(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 W")
        
        try? rover.addAction(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 N")
        
        try? rover.addAction(.spinRight)
        XCTAssertEqual(rover.finalPosition.string, "1 1 E")
    }
    
    func testGetCommandString() {
        let rover = Rover(name: "Rover 1",
                          position: Position(coordinate: Coordinate(x: 1, y: 1), heading: .E))
        
        let actions: [Action] = [
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
        
        for action in actions {
            do {
                try rover.addAction(action)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
        
        XCTAssertEqual(rover.commandString, "MLRMRLLLLMM")
    }
    
    func testSetCommandString() {
        let rover = Rover(name: "Rover 1",
                          position: Position(coordinate: Coordinate(x: 1, y: 1), heading: .E))
        
        try? rover.setCommandString("MLRMRLLLLMM")
        
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
        try? rover1.setCommandString("MLRMRLXXXLZZZMM")
        
        XCTAssertTrue(rover1.actions.isEmpty)
        XCTAssertEqual(rover1.commandString, "")
    }
    
    func testCommandStringOutOfBoundX() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.upperBound = Coordinate(x: 5, y: 5)
        rover1.lowerBound = .origin
        
        do {
            try rover1.setCommandString("RMMMMMMMMLLMMMMM")
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, ("Rover 1 is running out of bound (6 2) after step 6."))
        }
        
        XCTAssertEqual(rover1.commandString, "")
        XCTAssertEqual(rover1.finalPosition.string, "1 2 N")
    }
    
    func testCommandStringOutOfBoundY() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.upperBound = Coordinate(x: 5, y: 5)
        rover1.lowerBound = .origin
        
        do {
            try rover1.setCommandString("MMMMMMMMLLMMMMMMMMM")
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is running out of bound (1 6) after step 4.")
        }
        
        XCTAssertEqual(rover1.commandString, "")
        XCTAssertEqual(rover1.finalPosition.string, "1 2 N")
    }
    
    func testCommandStringNoBound() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        
        do {
            try rover1.setCommandString("MMMMMMMMLLMMMMMMMMMMMRMMM")
        } catch {
            XCTFail(error.localizedDescription)
        }
    
        XCTAssertEqual(rover1.commandString, "MMMMMMMMLLMMMMMMMMMMMRMMM")
        XCTAssertEqual(rover1.finalPosition.string, "-2 -1 W")
    }
    
    func testCommandStringOutOfBoundNegative() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 3, y: 3), heading: .E))
        let _ = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        do {
            try rover1.setCommandString("LMMMLLMMM")
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is running out of bound (-1 2) after step 3.")
        }
        XCTAssertEqual(rover1.commandString, "")
        XCTAssertEqual(rover1.finalPosition.string, "1 2 N")
        
        do {
            try rover2.setCommandString("RMMMMMMRRMMMMM")
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 2 is running out of bound (3 -1) after step 5.")
        }
        XCTAssertEqual(rover2.commandString, "")
        XCTAssertEqual(rover2.finalPosition.string, "3 3 E")
    }
    
    func testRemoveAllActions() {
         let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        
        try? rover1.addAction(.moveForward)
        XCTAssertEqual(rover1.finalPosition.string, "1 3 N")
        
        rover1.removeAllActions()
        XCTAssertEqual(rover1.finalPosition.string, "1 2 N")
    }
    
    func testAddActionOutOfBoundError() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 0, y: 2), heading: .W))
        let _ = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1])

        do {
            try rover1.addAction(.moveForward)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is running out of bound.")
        }
        XCTAssertEqual(rover1.finalPosition.string, "0 2 W")
    }
    
    func testAddActionCollisionError() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 0, y: 2), heading: .W))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 0, y: 1), heading: .N))
        let site = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        do {
            try rover2.addAction(.moveForward, in: site)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 2 is running into another rover.")
        }
        XCTAssertEqual(rover2.finalPosition.string, "0 1 N")
    }
    
    func testAddActionFollowerCollisionError() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 0, y: 0), heading: .N))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 0, y: 1), heading: .E))
        let site = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        do {
            try rover1.addAction(.moveForward, in: site)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is running into another rover.")
        }
        XCTAssertEqual(rover1.finalPosition.string, "0 0 N")
    }
    
    func testAddRoverError() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 0, y: 1), heading: .W))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 0, y: 1), heading: .N))
        let site = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1])
        
        XCTAssertEqual(site.rovers.count, 1)
        do {
            try site.addRover(rover2)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 2's initial position is already occupied.")
        }
        XCTAssertEqual(site.rovers.count, 1)
    }
    
    func testResolveMultiLineCommand() {
        let command =
        """
        15 50
        1 2 N
        LMLMLMLMM
        3 3 E
        MMRMMRMRRM
        """
        
        do {
            let site = try CommandHelper.resolveMultiLineCommand(command)
            
            XCTAssertEqual(site.grid.x, 15)
            XCTAssertEqual(site.grid.y, 50)
            XCTAssertEqual(site.rovers.count, 2)
            
            XCTAssertEqual(site.rovers[0].initialPosition.coordinate.x, 1)
            XCTAssertEqual(site.rovers[0].initialPosition.coordinate.y, 2)
            XCTAssertEqual(site.rovers[0].initialPosition.heading, Heading.N)
            
            XCTAssertEqual(site.rovers[1].initialPosition.coordinate.x, 3)
            XCTAssertEqual(site.rovers[1].initialPosition.coordinate.y, 3)
            XCTAssertEqual(site.rovers[1].initialPosition.heading, Heading.E)
            
            //assert output
            XCTAssertEqual(site.rovers[0].finalPosition.string, "1 3 N")
            XCTAssertEqual(site.rovers[1].finalPosition.string, "5 1 E")
            
            XCTAssertEqual(site.commandString, command)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testInvalidMultiLineCommand() {
        let command =
        """
        X 5
        X 2 N
        LMLMLMLMM
        3 X E
        MMRMMRMRRM
        """
        
        do {
            try CommandHelper.resolveMultiLineCommand(command)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "No site coordinate is found.")
        }
    }
    
    func testMultiLineCommandRoverPlacedOutOfBound() {
        let command =
        """
        5 5
        1 6 N
        LL
        3 3 E
        RR
        """
        
        do {
            try CommandHelper.resolveMultiLineCommand(command)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1's initial position is out of bound.")
        }
    }
    
    func testMultiLineCommandNoRover() {
        let command =
        """
        5 5
        X 2 N
        LMLMLMLMM
        3 X E
        MMRMMRMRRM
        """
        
        do {
            let site = try CommandHelper.resolveMultiLineCommand(command)
            XCTAssertEqual(site.grid.x, 5)
            XCTAssertEqual(site.grid.x, 5)
            
            XCTAssertEqual(site.rovers.count, 0)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testMultiLineCommandRoverOutOfBound() {
        let command =
        """
        5 5
        1 2 N
        LMLMLMLMM
        3 3 E
        MMRMMRMRRMM
        """
        
        do {
            let _ = try CommandHelper.resolveMultiLineCommand(command)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 2 is running out of bound (6 1) after step 11.")
        }
    }
    
    func testMultiLineCommandRunningIntoLeader() {
        let command =
        """
        11 11
        0 0 N
        MMMMRRRRRRLMM
        0 0 N
        MMRRLMMLMM
        """
        
        do {
            let _ = try CommandHelper.resolveMultiLineCommand(command)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 2's initial position is already occupied.")
        }
    }
    
    func testMultiLineCommandRunningIntoFollower() {
        let command =
        """
        11 11
        0 0 N
        MM
        0 2 N
        M
        """
        
        do {
            let _ = try CommandHelper.resolveMultiLineCommand(command)
            XCTFail("an error is expected")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is causing a collision at (0 2) after step 2.")
        }
    }
    
    func testExampleModel() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 3, y: 3), heading: .E))
        let site = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        try? rover1.setCommandString("LMLMLMLMM")
        try? rover2.setCommandString("MMRMMRMRRM")
        
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
    
    func testMultiLineCommandExample() {
        let command =
        """
        5 5
        1 2 N
        LMLMLMLMM
        3 3 E
        MMRMMRMRRM
        """
        
        do {
            let site = try CommandHelper.resolveMultiLineCommand(command)
            XCTAssertEqual(site.rovers.first?.finalPosition.string, "1 3 N")
            XCTAssertEqual(site.rovers.last?.finalPosition.string, "5 1 E")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
