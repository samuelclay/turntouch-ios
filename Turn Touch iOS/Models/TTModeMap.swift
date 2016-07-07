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
    
    var tempModeName: String = ""
    dynamic var openedModeChangeMenu: Bool = false
    dynamic var openedActionChangeMenu: Bool = false
    dynamic var openedAddActionChangeMenu: Bool = false
    
    dynamic var selectedMode: TTMode = TTMode()
    var northMode: TTMode!
    var eastMode: TTMode!
    var westMode: TTMode!
    var southMode: TTMode!
    dynamic var tempMode: TTMode!
    
    // var batchActions: TTBatchActions
    
    dynamic var availableModes: [String] = []
    dynamic var availableActions: [String] = []
    dynamic var availableAddModes: [String] = []
    dynamic var availableAddActions: [String] = []
    
    var waitingForDoubleClick = false
    
    override init() {
        self.availableModes = [
            "TTModePhone",
            "TTModeAlarmClock",
            "TTModeMusic",
            "TTModeHue",
            "TTModeWemo",
            "TTModeSonos",
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
            
//            self.switchMode(self.selectedModeDirection)
        }
    }
    
    // MARK: Actions
    
    func reset() {
        inspectingModeDirection = .NO_DIRECTION
        hoverModeDirection = .NO_DIRECTION
    }

    func setupModes() {
        let prefs = NSUserDefaults.standardUserDefaults()

        for direction: String in ["north", "east", "west", "south"] {
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
        
//        self.selectedModeDirection = TTModeDirection(rawValue: prefs.integerForKey("TT:selectedModeDirection"))!
//        self.switchMode(self.selectedModeDirection)
    }
    
    func activateModes() {
        let prefs = NSUserDefaults.standardUserDefaults()

        let direction = TTModeDirection(rawValue: prefs.integerForKey("TT:selectedModeDirection"))!
        self.switchMode(direction)
        self.selectedModeDirection = direction
    }
    
    func activateTimers() {
//        for mode in [northMode, eastMode, westMode, southMode] {
//            if mode.respondsToSelector(#selector("activateTimers")) {
//                mode.activateTimers()
//            }
//        }
    }
    
    func switchMode(direction: TTModeDirection) {
        // batchActions.deactivate()
        self.selectedMode.deactivate()
        
        if direction != .NO_DIRECTION {
            self.selectedMode = self.modeInDirection(direction)
        } else {
//            let className = "Turn_Touch_iOS.\(modeName)"
//            let modeClass = NSClassFromString(className) as! TTMode.Type
            print(" ---> Can't switch into non-direciton mode. Easy fix right here...")
        }
        
        self.availableActions = selectedMode.dynamicType.actions()
        selectedMode.activate(direction)
        self.reset()
        //        if self.selectedModeDirection != direction {
//        self.selectedModeDirection = direction
        //        }
    }
    
    func runActiveButton() {
        let direction = activeModeDirection
        activeModeDirection = .NO_DIRECTION
        
        if selectedMode.shouldIgnoreSingleBeforeDouble(direction) {
            waitingForDoubleClick = true
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(DOUBLE_CLICK_ACTION_DURATION * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                if self.waitingForDoubleClick {
                    self.runDirection(direction)
                }
            })
        } else {
            self.runDirection(direction)
        }
        
        activeModeDirection = .NO_DIRECTION
    }
    
    func runDirection(direction: TTModeDirection) {
        if !selectedMode.shouldFireImmediateOnPress(direction) {
            selectedMode.action = TTAction(actionName: selectedMode.actionNameInDirection(direction), direction: direction)
            selectedMode.runDirection(direction)
        }
        
        // Batch actions
//        let actions = self.selectedModeBatchActions(direction)
//        for batchAction: TTAction in actions {
//            batchAction.mode.runDirection(direction)
//        }
    }
    
    func runDoubleButton(direction: TTModeDirection) {
        waitingForDoubleClick = false
        activeModeDirection = .NO_DIRECTION
        if selectedMode.shouldFireImmediateOnPress(direction) {
            return
        }
        
        selectedMode.runDoubleDirection(direction)
        
        // Batch actions
//        let actions = self.selectedModeBatchActions(direction)
//        for batchAction: TTAction in actions {
//            batchAction.mode.runDoubleDirection(direction)
//        }
    }
    
    // MARK: Batch actions
    
    func selectedModeBatchActions(direction: TTModeDirection) {
        
    }
    
    func addBatchAction(actionName: String) {
        
    }
    
    func removeBatchAction(batchActionKey: String) {
        
    }
    
    // MARK: Changing modes, actions, batch actions
    
    func changeDirection(direction: TTModeDirection, toMode modeClassName: String) {
        let prefs = NSUserDefaults.standardUserDefaults()
        let directionName = self.directionName(direction)
        let prefKey = "TT:mode:\(directionName)"
        
        prefs.setObject(modeClassName, forKey: prefKey)
        prefs.synchronize()
        
        self.setupModes()
        self.activateModes()
    }
    
    func changeDirection(direction: TTModeDirection, toAction actionClassName: String) {
        selectedMode.changeDirection(direction, toAction:actionClassName)
    }
    
    // MARK: Direction helpers
    
    
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
    
    func toggleInspectingModeDirection(direction: TTModeDirection) {
        if self.inspectingModeDirection == direction {
            if self.openedModeChangeMenu {
                self.openedModeChangeMenu = false
            }
            if self.openedActionChangeMenu {
                self.openedActionChangeMenu = false
            }
            if self.openedAddActionChangeMenu {
                self.openedAddActionChangeMenu = false
            }
            self.inspectingModeDirection = .NO_DIRECTION
        } else {
            self.inspectingModeDirection = direction
        }
    }
    
}
