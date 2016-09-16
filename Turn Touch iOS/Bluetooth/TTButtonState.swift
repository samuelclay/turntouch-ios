//
//  TTButtonState.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

class TTButtonState : NSObject {
    
    var north = false
    var east = false
    var west = false
    var south = false
    var count = 4
    
    override var description: String {
        return "N:\(north) E:\(east) W:\(west) S:\(south)"
    }
    
    func state(_ i: Int) -> Bool {
        switch i {
        case 0:
            return north
        case 1:
            return east
        case 2:
            return west
        case 3:
            return south
        default:
            break
        }
        
        return false
    }
    
    func replaceState(_ i: Int, state: Bool) {
        switch i {
        case 0:
            north = state
        case 1:
            east = state
        case 2:
            west = state
        case 3:
            south = state
        default:
            break
        }
    }
    
    func clearState() {
        north = false
        east = false
        west = false
        south = false
    }
    
    func anyPressedDown() -> Bool {
        return north || east || west || south
    }
    
    func inMultitouch() -> Bool {
        return ((north && east) || (north && west) || (north && south) ||
                (east && west) || (east && south) || (west && south))
    }
    
    func activatedCount() -> Int {
        return (north ? 1 : 0) + (east ? 1 : 0) + (west ? 1 : 0) + (south ? 1 : 0)
    }
    
}
