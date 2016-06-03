//
//  TTModeMap.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

class TTModeMap: NSObject {
    
    dynamic var activeModeDirection: TTModeDirection = .NO_DIRECTION
    dynamic var selectedModeDirection: TTModeDirection = .NO_DIRECTION
    dynamic var inspectingModeDirection: TTModeDirection = .NO_DIRECTION
    dynamic var hoverModeDirection: TTModeDirection = .NO_DIRECTION
    
    var tempModeName: NSString = ""
    dynamic var openedModeChangeMenu: Bool = false
    dynamic var openedActionChangeMenu: Bool = false
    dynamic var openedAddActionChangeMenu: Bool = false
    
    dynamic var selectedMode: TTMode = TTMode()
    var northMode: TTMode = TTMode()
    var eastMode: TTMode = TTMode()
    var westMode: TTMode = TTMode()
    var southMode: TTMode = TTMode()
    var tempMode: TTMode = TTMode()
    
    // var batchActions: TTBatchActions
    
    var availableModes: [String] = []
    var availableAction: [String] = []
    var availableAddModes: [String] = []
    var availableAddActions: [String] = []
    
    override init() {
        self.availableModes = [
            "TTModePhone",
            "TTModeAlarmClock",
            "TTModeMusic",
            "TTModeHue",
        ]
        
        super.init()
        
        self.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "selectedModeDirection")
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setInteger(self.selectedModeDirection.rawValue, forKey: "TT:selectedModeDirection")
            prefs.synchronize()
            
            self.switchMode()
        }
    }
    
    // MARK: Actions

    func setupModes() {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        for direction: NSString in ["north", "east", "west", "south"] {
            if let directionModeName = prefs.stringForKey("TT:mode:\(direction)") {
                let className = "Turn_Touch_iOS.\(directionModeName)"
                let modeClass = NSClassFromString(className) as! TTMode.Type
                switch (direction) {
                case "north":
                    northMode = modeClass.init()
                    northMode.modeDirection = .NORTH
                case "east":
                    eastMode = modeClass.init()
                    eastMode.modeDirection = .EAST
                case "west":
                    westMode = modeClass.init()
                    westMode.modeDirection = .WEST
                case "south":
                    southMode = modeClass.init()
                    southMode.modeDirection = .SOUTH
                default:
                    break
                }
            }
        }
        
        self.selectedModeDirection = TTModeDirection(rawValue: prefs.integerForKey("TT:selectedModeDirection"))!
        self.switchMode()
    }
    
    func reset() {
        inspectingModeDirection = .NO_DIRECTION
        hoverModeDirection = .NO_DIRECTION
    }
    
    func switchMode() {
        // batchActions.deactivate()
        
        self.selectedMode.deactivate()
        
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
    
    func directionName(direction: TTModeDirection) -> String {
        switch direction {
        case .NORTH:
            return "north"
        case .EAST:
            return "east"
        case .WEST:
            return "west"
        case .SOUTH:
            return "south"
        default:
            return ""
        }
    }
    
    // MARK: Changing modes, actions, batch actions
    
    func changeDirection(direction: TTModeDirection, toMode modeClassName: NSString) {
        let prefs = NSUserDefaults.standardUserDefaults()
        let directionName = self.directionName(direction)
        let prefKey = "TT:mode:\(directionName)"
        
        prefs.setObject(modeClassName, forKey: prefKey)
        prefs.synchronize()
        
        self.setupModes()
        self.switchMode()
    }
}
