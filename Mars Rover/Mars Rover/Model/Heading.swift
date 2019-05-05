//
//  Heading.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import Foundation

enum Heading: String {
    case E, N, W, S
    
    var angle: Double {
        switch self {
        case .E:
            return 0
        case .N:
            return Double.pi * 0.5
        case .W:
            return Double.pi
        case .S:
            return Double.pi * 1.5
        }
    }
    
    var left: Heading {
        switch self {
        case .E:
            return .N
        case .N:
            return .W
        case .W:
            return .S
        case .S:
            return .E
        }
    }
    
    var right: Heading {
        switch self {
        case .E:
            return .S
        case .N:
            return .E
        case .W:
            return .N
        case .S:
            return .W
        }
    }
}
