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
}
