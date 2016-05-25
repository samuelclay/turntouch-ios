//
//  TTModeMap.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

class TTModeMap: NSObject {
    
    var activeModeDirection: TTModeDirection = .NO_DIRECTION
    var selectedModeDirection: TTModeDirection = .NO_DIRECTION
    var inspectingModeDirection: TTModeDirection = .NO_DIRECTION
    var hoverModeDirection: TTModeDirection = .NO_DIRECTION
    
    var tempModeName: NSString = ""
    var openedModeChangeMenu: Bool = false
    var openedActionChangeMenu: Bool = false
    var openedAddActionChangeMenu: Bool = false
    
    var selectedMode: TTMode = TTMode()
    var northMode: TTMode = TTMode()
    var eastMode: TTMode = TTMode()
    var westMode: TTMode = TTMode()
    var southMode: TTMode = TTMode()
    var tempMode: TTMode = TTMode()
    
    // var batchActions: TTBatchActions
    
    var availableModes: AnyObject
    var availableAction: [NSString] = []
    var availableAddModes: [NSString] = []
    var availableAddActions: [NSString] = []
    
    override init() {
        
        self.availableModes = [
            "TTModePhone": TTMode.self,
            "TTModeAlarmClock": TTMode.self,
            "TTModeMusic": TTMode.self,
            "TTModeHue": TTMode.self,
        ]

        super.init()

    }
    
    // MARK: KVO
    
    // MARK: Actions

    func setupModes() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let south = prefs.stringForKey("TT:mode:south")
        NSLog("Prefs: \(south)")
        
        for direction: NSString in ["north", "east", "west", "south"] {
            if let directionModeName = prefs.stringForKey("TT:mode:\(direction)") {
                let modeClass = self.availableModes[directionModeName]
                self.setValue(modeClass, forKey: "\(direction)Mode")
            }
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.selectedModeDirection = TTModeDirection(rawValue: defaults.integerForKey("TT:selectedModeDirection"))!
        self.switchMode()
    }
    
    func switchMode() {
        // batchActions.deactivate()
        
        if self.selectedMode.respondsToSelector(Selector("deactivate")) {
            self.selectedMode.deactivate()
        }
        
        if self.selectedModeDirection != .NO_DIRECTION {
            self.selectedMode = self.modeInDirection(self.selectedModeDirection)
        }
    }
    
    func modeInDirection(direction: TTModeDirection) -> (TTMode) {
        switch direction {
        case .NORTH:
            return self.northMode
        case .EAST:
            return self.eastMode
        case .WEST:
            return self.westMode
        case .SOUTH:
            return self.southMode
        default:
            return self.northMode
        }
    }
    
}