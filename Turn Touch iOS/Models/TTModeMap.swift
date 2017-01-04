//
//  TTModeMap.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

class TTModeMap: NSObject {
    
    dynamic var activeModeDirection: TTModeDirection = .no_DIRECTION
    dynamic var selectedModeDirection: TTModeDirection = .no_DIRECTION
    dynamic var inspectingModeDirection: TTModeDirection = .no_DIRECTION
    dynamic var hoverModeDirection: TTModeDirection = .no_DIRECTION
    
    dynamic var tempModeName: String?
    dynamic var openedModeChangeMenu: Bool = false
    dynamic var openedActionChangeMenu: Bool = false
    dynamic var openedAddActionChangeMenu: Bool = false
    
    dynamic var selectedMode: TTMode = TTMode()
    var northMode: TTMode!
    var eastMode: TTMode!
    var westMode: TTMode!
    var southMode: TTMode!
    dynamic var tempMode: TTMode!
    
    var batchActions = TTBatchActions()
    
    dynamic var availableModes: [String] = []
    dynamic var availableActions: [String] = []
    dynamic var availableAddModes: [[String: Any]] = []
    dynamic var availableAddActions: [[String: Any]] = []
    
    var waitingForDoubleClick = false
    
    override init() {
        self.availableModes = [
            "TTModePhone",
            "TTModeCamera",
            "TTModeMusic",
            "TTModeHue",
            "TTModeWemo",
            "TTModeSonos",
            "TTModeNest",
//            "TTModeAlarmClock",
            "TTModeYoga",
            "TTModeCustom",
        ]
        
        super.init()
        
        self.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "selectedModeDirection")
    }
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            let prefs = UserDefaults.standard
            prefs.set(self.selectedModeDirection.rawValue, forKey: "TT:selectedModeDirection")
            prefs.synchronize()
        }
    }
    
    // MARK: Actions
    
    func reset() {
        inspectingModeDirection = .no_DIRECTION
        hoverModeDirection = .no_DIRECTION
    }

    func setupModes() {
        let prefs = UserDefaults.standard

        for direction: String in ["north", "east", "west", "south"] {
            if let directionModeName = prefs.string(forKey: "TT:mode:\(direction)") {
                let className = "Turn_Touch_iOS.\(directionModeName)"
                let modeClass = NSClassFromString(className) as! TTMode.Type
                switch (direction) {
                case "north":
                    northMode = modeClass.init()
                    northMode.modeDirection = .north
                case "east":
                    eastMode = modeClass.init()
                    eastMode.modeDirection = .east
                case "west":
                    westMode = modeClass.init()
                    westMode.modeDirection = .west
                case "south":
                    southMode = modeClass.init()
                    southMode.modeDirection = .south
                default:
                    break
                }
            }
        }
    }
    
    func activateModes() {
        let prefs = UserDefaults.standard

        let direction = TTModeDirection(rawValue: prefs.integer(forKey: "TT:selectedModeDirection"))!
        self.switchMode(direction)
    }
    
    func activateTimers() {
//        for mode in [northMode, eastMode, westMode, southMode] {
//            if mode.respondsToSelector(#selector("activateTimers")) {
//                mode.activateTimers()
//            }
//        }
    }
    
    func switchMode(_ direction: TTModeDirection, modeChangeType: ModeChangeType = .modeTab) {
        self.activeModeDirection = .no_DIRECTION

        batchActions.deactivate()
        self.selectedMode.deactivate()
        
        if direction != .no_DIRECTION {
            self.selectedMode = self.modeInDirection(direction)
        } else {
//            let className = "Turn_Touch_iOS.\(modeName)"
//            let modeClass = NSClassFromString(className) as! TTMode.Type
            print(" ---> Can't switch into non-direciton mode. Easy fix right here...")
        }
        
        self.availableActions = type(of: selectedMode).actions()
        self.selectedMode.modeChangeType = modeChangeType
        self.selectedMode.activate(direction)
        self.reset()
        self.selectedModeDirection = direction
        batchActions.assemble()
    }
    
    func runActiveButton() {
        let direction = activeModeDirection
        activeModeDirection = .no_DIRECTION
        
        if selectedMode.shouldIgnoreSingleBeforeDouble(direction) {
            waitingForDoubleClick = true
            let delayTime = DispatchTime.now() + Double(Int64(DOUBLE_CLICK_ACTION_DURATION * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                if self.waitingForDoubleClick {
                    self.runDirection(direction)
                }
            })
        } else {
            self.runDirection(direction)
        }
        
        activeModeDirection = .no_DIRECTION
    }
    
    func runDirection(_ direction: TTModeDirection) {
        if !selectedMode.shouldFireImmediateOnPress(direction) {
//            selectedMode.action = TTAction(actionName: selectedMode.actionNameInDirection(direction), direction: direction)
            selectedMode.runDirection(direction)
        }
        
        // Batch actions
        let actions = self.selectedModeBatchActions(in: direction)
        for batchAction in actions {
            batchAction.mode.runDirection(direction)
        }
    }
    
    func runDoubleButton(_ direction: TTModeDirection) {
        waitingForDoubleClick = false
        activeModeDirection = .no_DIRECTION
        if selectedMode.shouldFireImmediateOnPress(direction) {
            return
        }
        
        selectedMode.runDoubleDirection(direction)
        
        // Batch actions
        let actions = self.selectedModeBatchActions(in: direction)
        for batchAction: TTAction in actions {
            batchAction.mode.runDoubleDirection(direction)
        }
    }
    
    // MARK: Batch actions
    
    func provisionTempMode(name: String) {
        tempModeName = name
        let className = "Turn_Touch_iOS.\(name)"
        let modeClass = NSClassFromString(className) as! TTMode.Type
        tempMode = modeClass.init()
        
        var availableAddActions: [[String: Any]] = []
        for action in modeClass.actions() {
            availableAddActions.append(["id": action, "type": TTMenuType.menu_ADD_ACTION])
        }
        
        self.availableAddActions = availableAddActions
    }
    
    func provisionAvailableAddModes() {
        var availableAddModes: [[String: Any]] = []
        for mode in self.availableModes {
            availableAddModes.append(["id": mode, "type": TTMenuType.menu_ADD_MODE])
        }
        self.availableAddModes = availableAddModes
    }
    
    func selectedModeBatchActions(in direction: TTModeDirection) -> [TTAction] {
        return batchActions.batchActions(in: direction)
    }
    
    func addBatchAction(for actionName: String) {
        // Adding batch action using the menu, selecting and inspecting directions
        let prefs = UserDefaults.standard
        var batchActionKeys = self.batchActionKeys()
        let uuid = UUID().uuidString
        let newActionKey = "\(tempMode.nameOfClass):\(actionName):\(uuid.substring(to: uuid.index(uuid.startIndex, offsetBy: 8)))"
        batchActionKeys.append(newActionKey)
        prefs.set(batchActionKeys, forKey: self.batchKey())
        prefs.synchronize()
        
        batchActions.assemble()
        
        tempMode = nil
        tempModeName = nil
        
        self.didChangeValue(forKey: "inspectingModeDirection")
    }
    
    func addBatchAction(modeDirection: TTModeDirection, actionDirection: TTModeDirection, modeClassName: String, actionName: String) -> String {
        // Adding batch actions automatically
        let prefs = UserDefaults.standard
        var batchActionKeys = self.batchActionKeys(modeDirection: modeDirection, actionDirection: actionDirection)
        let uuid = UUID().uuidString
        let newActionKey = "\(modeClassName):\(actionName):\(uuid.substring(to: uuid.index(uuid.startIndex, offsetBy: 8)))"
        batchActionKeys.append(newActionKey)
        prefs.set(batchActionKeys, forKey: self.batchKey(modeDirection: modeDirection, actionDirection: actionDirection))
        prefs.synchronize()

        batchActions.assemble()
        
        return newActionKey
    }
    
    func removeBatchAction(for batchActionKey: String, silent: Bool = false, actionDirection: TTModeDirection? = nil) {
        let prefs = UserDefaults.standard
        let batchActionKeys = self.batchActionKeys(modeDirection: nil, actionDirection: actionDirection)
        var newBatchActionKeys: [String] = []
        
        for key in batchActionKeys {
            if key != batchActionKey {
                newBatchActionKeys.append(key)
            } else {
                print(" ---> Removing from \(batchActionKeys.count) batch actions in \(actionDirection?.rawValue): \(key)")
            }
        }
        
        prefs.set(newBatchActionKeys, forKey: self.batchKey(actionDirection: actionDirection))
        prefs.synchronize()
        
        if !silent {
            batchActions.assemble()
            self.didChangeValue(forKey: "inspectingModeDirection")
        }
    }
    
    func batchActionKeys(modeDirection: TTModeDirection? = nil, actionDirection: TTModeDirection? = nil) -> [String] {
        let prefs = UserDefaults.standard
        var batchActionKeys: [String] = []
        
        if let batchActionsPrefs = prefs.object(forKey: self.batchKey(modeDirection: modeDirection, actionDirection: actionDirection)) as? [String] {
            batchActionKeys = batchActionsPrefs
        }
        
        return batchActionKeys
    }
    
    func batchKey(modeDirection: TTModeDirection? = nil, actionDirection: TTModeDirection? = nil) -> String {
        let modeDirectionName = self.directionName(modeDirection ?? selectedModeDirection)
        let actionDirectionName = self.directionName(actionDirection ?? inspectingModeDirection)
        let batchKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions"
        
        return batchKey
    }
    
    // MARK: Changing modes, actions, batch actions
    
    func changeDirection(_ direction: TTModeDirection, toMode modeClassName: String) {
        let prefs = UserDefaults.standard
        let directionName = self.directionName(direction)
        let prefKey = "TT:mode:\(directionName)"
        
        prefs.set(modeClassName, forKey: prefKey)
        prefs.synchronize()
        
        self.setupModes()
        self.activateModes()
    }
    
    func changeDirection(_ direction: TTModeDirection, toAction actionClassName: String) {
        selectedMode.changeDirection(direction, toAction:actionClassName)
    }
    
    // MARK: Direction helpers
    
    
    func modeInDirection(_ direction: TTModeDirection) -> (TTMode) {
        switch direction {
        case .north:
            return self.northMode
        case .east:
            return self.eastMode
        case .west:
            return self.westMode
        case .south:
            return self.southMode
        default:
            return self.northMode
        }
    }
    
    func directionName(_ direction: TTModeDirection) -> String {
        switch direction {
        case .north:
            return "north"
        case .east:
            return "east"
        case .west:
            return "west"
        case .south:
            return "south"
        default:
            return ""
        }
    }
    
    func toggleInspectingModeDirection(_ direction: TTModeDirection) {
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
            self.inspectingModeDirection = .no_DIRECTION
        } else {
            self.inspectingModeDirection = direction
        }
    }
    
}
