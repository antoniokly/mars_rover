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
    
    func testCommandString() {
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
            try? rover.addAction(action)
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
    
    func testOutOfBoundX() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.bound = Coordinate(x: 5, y: 5)
        
        do {
            try rover1.setCommandString("RMMMMMMMMLLMMMMM")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains(commandErrorDomain))
        }
        
        XCTAssertEqual(rover1.commandString, "")
        XCTAssertEqual(rover1.finalPosition.string, "1 2 N")
    }
    
    func testOutOfBoundY() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        rover1.bound = Coordinate(x: 5, y: 5)
        
        do {
            try rover1.setCommandString("MMMMMMMMLLMMMMMMMMM")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is running out of bound (1 6) after step 3.")
        }
        
        XCTAssertEqual(rover1.commandString, "")
        XCTAssertEqual(rover1.finalPosition.string, "1 2 N")
    }
    
    func testNoBound() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        
        do {
            try rover1.setCommandString("MMMMMMMMLLMMMMMMMMMMMRMMM")
        } catch {
            XCTFail(error.localizedDescription)
        }
    
        XCTAssertEqual(rover1.commandString, "MMMMMMMMLLMMMMMMMMMMMRMMM")
        XCTAssertEqual(rover1.finalPosition.string, "-2 -1 W")
    }
    
    func testOutOfBoundNegative() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 1, y: 2), heading: .N))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 3, y: 3), heading: .E))
        let _ = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        do {
            try rover1.setCommandString("LMMMLLMMM")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is running out of bound (-1 2) after step 2.")
        }
        XCTAssertEqual(rover1.commandString, "")
        XCTAssertEqual(rover1.finalPosition.string, "1 2 N")
        
        do {
            try rover2.setCommandString("RMMMMMMRRMMMMM")
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 2 is running out of bound (3 -1) after step 4.")
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
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 2 is running into avoiding position (0 2).")
        }
        XCTAssertEqual(rover2.finalPosition.string, "0 1 N")
    }
    
    func testAddActionFollowerCollisionError() {
        let rover1 = Rover(name: "Rover 1", position: Position(coordinate: Coordinate(x: 0, y: 0), heading: .N))
        let rover2 = Rover(name: "Rover 2", position: Position(coordinate: Coordinate(x: 0, y: 1), heading: .E))
        let site = Site(name: "A Plateau", grid: Coordinate(x: 5, y: 5), rovers: [rover1, rover2])
        
        do {
            try rover1.addAction(.moveForward, in: site)
        } catch let error as NSError {
            XCTAssertEqual(error.message, "Rover 1 is running into avoiding position (0 1).")
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
        } catch let error as NSError {
            XCTAssertEqual(error.message, "There is already a rover at 0 1")
        }
        XCTAssertEqual(site.rovers.count, 1)
    }
    
    func testExample() {
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
            guard let site = try CommandHelper.resolveMultiLineCommand(command) else {
                XCTFail("No site")
                return
            }
            
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
            let site = try CommandHelper.resolveMultiLineCommand(command)
            XCTAssertNil(site, "no site should be created")
        } catch {
            XCTFail(error.localizedDescription)
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
            XCTAssertEqual(site?.grid.x, 5)
            XCTAssertEqual(site?.grid.x, 5)
            
            XCTAssertEqual(site?.rovers.count, 0)
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
            XCTAssertEqual(error.message, "Rover 2 is running out of bound (6 1) after step 10.")
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
            XCTAssertEqual(error.message, "Rover 2 is running into avoiding position (2 4) after step 9.")
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
            XCTAssertEqual(error.message, "Rover 1 is running into avoiding position (0 2) after step 1.")
        }
    }
    
}
