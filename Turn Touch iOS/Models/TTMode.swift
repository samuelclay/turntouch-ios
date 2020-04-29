//
//  TTMode.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

let DEBUG_PREFS = true
let DEBUG_PREFS_NIL = true

enum ActionLayout {
    case action_LAYOUT_TITLE
    case action_LAYOUT_IMAGE_TITLE
    case action_LAYOUT_PROGRESSBAR
}

enum ModeChangeType {
    case modeTab
    case remoteButton
}

protocol TTModeProtocol {
    func deactivate()
    func activate()
    static func title() -> String
    static func imageName() -> String
    static func subtitle() -> String
    static func actions() -> [String]
}

infix operator >!<
func >!< (object1: Any!, object2: Any!) -> Bool {
    return (object_getClassName(object1) == object_getClassName(object2))
}

@objcMembers
class TTMode : NSObject, TTModeProtocol {
    var modeDirection: TTModeDirection = .no_DIRECTION
    var action: TTAction!
    var modeChangeType: ModeChangeType = .remoteButton
    
    required override init() {
        super.init()
//        NSLog("Initializing mode: \(self)")
    }
    
     init(modeDirection: TTModeDirection) {
        super.init()
        self.modeDirection = modeDirection
    }
    
    func deactivate() {
        
    }
    
    func activate(_ direction: TTModeDirection) {
        modeDirection = direction
        
        self.activate()
    }
    
    func activate() {
        
    }
    
    // MARK: Mode settings
    
    class func title() -> String {
        return "Mode"
    }
    
    class func imageName() -> String {
        return ""
    }
    
    class func subtitle() -> String {
        return ""
    }
    
    class func actions() -> [String] {
        return []
    }
    
    // MARK: Defaults
    
    func defaultNorth() -> String {
        return "TTAction1"
    }
    
    func defaultEast() -> String {
        return "TTAction2"
    }
    
    func defaultWest() -> String {
        return "TTAction3"
    }
    
    func defaultSouth() -> String {
        return "TTAction4"
    }
    
    func defaultInfo() -> String? {
        return nil
    }
    
    // MARK: Map directions to actions
    
    func runDirection(_ direction: TTModeDirection) {
        let actionName = self.actionNameInDirection(direction)
        _ = self.runAction(actionName, direction: direction, funcAction: "run")
    }
    
    func runAction(_ actionName: String, direction: TTModeDirection) {
        _ = self.runAction(actionName, direction: direction, funcAction: "run")
    }
    
    func runDoubleDirection(_ direction: TTModeDirection) {
        if !self.runDirection(direction, funcAction: "doubleRun") {
            self.runDirection(direction)
        }
    }
    
    func runHoldDirection(_ direction: TTModeDirection) {
        if !self.runDirection(direction, funcAction: "holdRun") {
            self.runDirection(direction)
        }
    }
    
    func runDirection(_ direction: TTModeDirection, funcAction: String) -> Bool {
        let actionName = self.actionNameInDirection(direction)
        return self.runAction(actionName, direction: direction, funcAction: funcAction)
    }
    
    func runAction(_ actionName: String, direction: TTModeDirection, funcAction: String) -> Bool {
        var success = false
        let mode = self.modeInDirection(direction)

        print(" ---> Running \(mode.nameOfClass): \(funcAction)\(actionName)")

        if mode.action == nil || mode.action.batchActionKey == nil {
            mode.action = TTAction(actionName: actionName, direction: direction)
            mode.action.mode = mode
        }
        
        // runAction:direction
        let titleSelector = Selector("\(funcAction)\(actionName)WithDirection:")
        if mode.responds(to: titleSelector) {
            mode.perform(titleSelector, with: NSNumber(value: direction.rawValue))
            success = true
        } else {
            // runAction
            let titleSelector = NSSelectorFromString("\(funcAction)\(actionName)")
            if mode.responds(to: titleSelector) {
                mode.perform(titleSelector)
                success = true
            }
        }
        
        if mode.action.batchActionKey == nil {
//            self.action = nil
        }
        
        if !success {
            print(" ---> Error: could not find `\(titleSelector)` method in \(self)")
        }
        return success
    }
    
    func setCustomTitle(_ title: String?, direction: TTModeDirection) {
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let actionName = self.actionNameInDirection(direction)
        let prefKey = "TT:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(actionDirectionName):customTitle"
        
        if title == nil {
            prefs.removeObject(forKey: prefKey)
        } else {
            prefs.set(title, forKey: prefKey)
        }
        prefs.synchronize()
    }
    
    func modeInDirection(_ direction: TTModeDirection) -> TTMode {
        var mode = self
        if mode.action != nil && mode.action.batchActionKey != nil {
            return mode;
        }
        if appDelegate().modeMap.buttonAppMode() == .TwelveButtons {
            switch direction {
            case .north:
                mode = appDelegate().modeMap.northMode
            case .east:
                mode = appDelegate().modeMap.eastMode
            case .west:
                mode = appDelegate().modeMap.westMode
            case .south:
                mode = appDelegate().modeMap.southMode
            default:
                mode = self
            }
        }
        
        return mode
    }
    
    func titleInDirection(_ direction: TTModeDirection, buttonMoment: TTButtonMoment) -> String {
        let actionName = self.actionNameInDirection(direction)
        let mode = self.modeInDirection(direction)
        if actionName == "" {
            print(" ---> Set title for \(direction)")
            return "Set \(direction)"
        }
        
        // First check if given custom title
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let prefKey = "TT:\(mode.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(actionDirectionName):customTitle"
        if let customTitle = prefs.string(forKey: prefKey) {
            return customTitle
        }
        
        var funcAction = "title"
        if buttonMoment == .button_MOMENT_DOUBLE {
            funcAction = "doubleTitle"
        }
        
        // runAction:direction
        let titleSelector = Selector("\(funcAction)\(actionName)WithDirection:")
        if mode.responds(to: titleSelector) {
            return mode.perform(titleSelector, with: NSNumber(value: direction.rawValue)).takeUnretainedValue() as! String
        }
        
        return mode.titleForAction(actionName, buttonMoment:buttonMoment)
    }
    
    func titleForAction(_ actionName: String, buttonMoment: TTButtonMoment) -> String {
        var runAction = "title"
        if buttonMoment == .button_MOMENT_DOUBLE {
            runAction = "doubleTitle"
        }
        
        let selector = NSSelectorFromString("\(runAction)\(actionName)")
        if !self.responds(to: selector) && buttonMoment != .button_MOMENT_PRESSUP {
            // print(" ---> No double click title: \(actionName)")
            return self.titleForAction(actionName, buttonMoment: .button_MOMENT_PRESSUP)
        }
        
        if !self.responds(to: selector) {
            print(" ---> Set title for \(selector)")
            return "Set \(selector)"
        }
        
        let actionTitle = self.perform(selector, with: self).takeUnretainedValue() as! String
        return actionTitle
    }
    
    func actionTitleForAction(_ actionName: String, buttonMoment: TTButtonMoment) -> String? {
        let mode = self
        var runAction = "actionTitle"
        if buttonMoment == .button_MOMENT_DOUBLE {
            runAction = "doubleActionTitle"
        }
        let titleSelector = NSSelectorFromString("\(runAction)\(actionName)")
        if !mode.responds(to: titleSelector) {
            return mode.titleForAction(actionName, buttonMoment: buttonMoment)
        }
        
        let actionTitle = mode.perform(titleSelector, with: mode).takeUnretainedValue() as! String
        return actionTitle
    }
    
    func actionNameInDirection(_ direction: TTModeDirection) -> String {
        if action?.batchActionKey != nil {
            return action.actionName
        }
        
        let prefs = preferences()
        
        let mode = self.modeInDirection(direction)
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let prefKey = "TT:\(mode.nameOfClass)-\(modeDirectionName):action:\(actionDirectionName)"
        let prefDirectionAction = prefs.string(forKey: prefKey)
        var directionAction: String!
        
        if prefDirectionAction == nil {
            switch direction {
            case .north:
                directionAction = mode.defaultNorth()
            case .east:
                directionAction = mode.defaultEast()
            case .west:
                directionAction = mode.defaultWest()
            case .south:
                directionAction = mode.defaultSouth()
            case .info:
                directionAction = mode.defaultInfo()
            default:
                directionAction = ""
            }
        } else {
            directionAction = prefDirectionAction!
        }
//        print(" ---> Direction action: \(prefKey) - \(directionAction ?? "nil")")
        
        return directionAction
    }
    
    // Don't run a button's single tap action until confirmed that it's not a double tap
    func shouldIgnoreSingleBeforeDouble(_ direction: TTModeDirection) -> Bool {
        let actionName = self.actionNameInDirection(direction)
        let titleSelectorWithDirection = NSSelectorFromString("doubleRun\(actionName)WithDirection:")
        if !self.responds(to: titleSelectorWithDirection) {
            let titleSelector = NSSelectorFromString("doubleRun\(actionName)")
            if !self.responds(to: titleSelector) {
                return false
            }
        }
        
        return true
    }
    
    // Run a button's action on press *down* and not on standard press *up*
    func shouldFireImmediateOnPress(_ direction: TTModeDirection) -> Bool {
        if appDelegate().modeMap.buttonAppMode() == .TwelveButtons {
            return false
        }
        
        let actionName = self.actionNameInDirection(direction)
        let titleSelector = NSSelectorFromString("shouldFireImmediate\(actionName)")
        if !self.responds(to: titleSelector) {
            return false
        }
        
        let immediate = self.perform(titleSelector).takeUnretainedValue() as! NSNumber
        return immediate.boolValue
    }
    
    func shouldUseModeOptionsFor(_ action: String) -> Bool {
        return false
    }
    
    // MARK: Mode options
    
    func modeOptionValue(_ optionName: String) -> Any? {
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        
        if modeDirection == .no_DIRECTION {
            // Rotate through directions looking for prefs
            for direction: TTModeDirection in [.north, .east, .west, .south] {
                let directionName = appDelegate().modeMap.directionName(direction)
                let optionKey = "TT:mode:\(self.nameOfClass)-\(directionName):option:\(optionName)"
                guard let pref = prefs.object(forKey: optionKey) else {
                    if DEBUG_PREFS_NIL {
                        print(" -> Getting mode options (\(directionName)) \(optionKey): nil")
                    }
                    continue
                }
                if DEBUG_PREFS {
                    print(" -> Getting mode options (\(directionName)) \(optionKey): \(pref)")
                }
                return pref
            }
        }
        
        var optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):option:\(optionName)"
        
        if let action = self.action,
           let batchActionKey = action.batchActionKey {
            let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
            let actionDirectionName = appDelegate().modeMap.directionName(self.action.direction)
            optionKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions:\(batchActionKey):modeoption:\(optionName)"
        }
        
        if let pref = prefs.object(forKey: optionKey) {
            if DEBUG_PREFS {
                print(" -> Getting mode options \(optionKey): \(pref)")
            }
            return pref
        }

        return self.defaultOption(optionName)
    }

    // MARK: Changing mode settings
    
    func changeDirection(_ direction: TTModeDirection, toAction actionClassName: String) {
        let prefs = preferences()
        
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let prefKey = "TT:\(self.nameOfClass)-\(modeDirectionName):action:\(actionDirectionName)"

        let directionAction = prefs.string(forKey: prefKey)
        print(" ---> Change direction action: \(prefKey) - \(String(describing: directionAction)) to \(actionClassName)")
        
        prefs.set(actionClassName, forKey: prefKey)
        prefs.synchronize()
    }
    
    func changeModeOption(_ optionName: String, to optionValue: Any) {
        if optionName == "" {
            print(" ---> BUSTED: \(optionValue)")
            return
        }
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        var optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):option:\(optionName)"
        
        if let action = self.action,
            let batchActionKey = action.batchActionKey {
            let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
            let actionDirectionName = appDelegate().modeMap.directionName(self.action.direction)
            optionKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions:\(batchActionKey):modeoption:\(optionName)"
        }
        
        let pref = prefs.object(forKey: optionKey)
        print(" -> Setting mode option \(optionKey) from (\(String(describing: pref))) to (\(optionValue))")
        
        prefs.set(optionValue, forKey: optionKey)
        prefs.synchronize()
    }
    
    // MARK: Action options
    
    func actionOptionValue(_ optionName: String, actionName: String, direction: TTModeDirection) -> Any? {
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        
        if direction == .no_DIRECTION {
            // Rotate through directions looking for prefs
            for modeDirection: TTModeDirection in [.north, .east, .west, .south] {
                let modeActionDirectionName = appDelegate().modeMap.directionName(modeDirection)
                let optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(modeActionDirectionName):option:\(optionName)"
                guard let pref = prefs.object(forKey: optionKey) else {
                    continue
                }
                if DEBUG_PREFS {
                    print(" -> Getting action options (\(modeActionDirectionName)) \(optionKey): \(pref)")
                }
                return pref
            }
        }
        
        let optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(actionDirectionName):option:\(optionName)"
        if let pref = prefs.object(forKey: optionKey) {
            if DEBUG_PREFS {
                print(" -> Getting action options \(optionKey): \(pref)")
            }
            return pref
        }
        
        if let pref = self.defaultOption(actionName, optionName: optionName) {
            if DEBUG_PREFS {
                print(" -> Getting action default \(optionKey): \(pref)")
            }
            return pref
        }

        if let pref = self.defaultOption(optionName) {
            if DEBUG_PREFS {
                print(" -> Getting action mode default \(optionKey): \(pref)")
            }
            return pref
        }
        
        if DEBUG_PREFS_NIL {
            print(" -> Getting nil action options \(optionKey): nil")
        }
        return nil
    }
    
    func batchActionOptionValue(_ batchAction: TTAction, optionName: String, direction: TTModeDirection) -> Any? {
        return self.batchActionOptionValue(batchActionKey: batchAction.batchActionKey!,
                                           optionName: optionName,
                                           actionName: batchAction.actionName,
                                           actionDirection: direction)
    }
    
    func batchActionOptionValue(batchActionKey: String, optionName: String, actionName: String,
                                actionDirection: TTModeDirection) -> Any? {
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(actionDirection)
        let optionKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions:\(batchActionKey):actionoption:\(optionName)"
        var pref = prefs.object(forKey: optionKey)
        if DEBUG_PREFS {
            print(" -> Getting batch action options \(optionKey): \(String(describing: pref))")
        }
        if pref == nil {
            pref = self.defaultOption(actionName, optionName: optionName)
        }
        if pref == nil {
            pref = self.defaultOption(optionName)
        }
        
        return pref
    }
    
    func defaultOption(_ optionName: String) -> Any? {
        let defaultPrefsFile = Bundle.main.path(forResource: self.nameOfClass, ofType: "plist")
        if defaultPrefsFile == nil {
            if DEBUG_PREFS_NIL {
                print(" -> Getting mode option default \(optionName): can't find default prefs file: \(self.nameOfClass).plist")
            }
            return nil
        }
        let modeDefaults: Dictionary<String, Any>? = NSDictionary(contentsOfFile: defaultPrefsFile!) as? Dictionary<String, Any>
        if let pref = modeDefaults?[optionName] {
            if DEBUG_PREFS {
                print(" -> Getting mode option default \(optionName): \(pref)")
            }
            return pref
        }
        
        if DEBUG_PREFS_NIL {
            print(" -> Getting mode option default \(optionName): nil")
        }
        return nil
    }
    
    func defaultOption(_ actionName: String, optionName: String) -> Any? {
        let defaultPrefsFile = Bundle.main.path(forResource: self.nameOfClass, ofType: "plist")
        if defaultPrefsFile == nil {
            return nil
        }
        let modeDefaults: Dictionary<String, Any>? = NSDictionary(contentsOfFile: defaultPrefsFile!) as? Dictionary<String, Any>
        let optionKey = "\(actionName):\(optionName)"
        if let pref = modeDefaults?[optionKey] {
            if DEBUG_PREFS {
                print(" -> Getting mode action option default \(optionKey): \(pref)")
            }
            return modeDefaults?[optionKey]
        }
        
        if DEBUG_PREFS_NIL {
            print(" -> Getting mode action option default \(optionKey): nil")
        }
        return nil
    }
    
    // MARK: Setting action options
    
    func changeActionOption(_ optionName: String, to optionValue: Any, direction: TTModeDirection?=nil) {
        if optionName == "" {
            print(" ---> BUSTED: \(optionValue)")
            return
        }
        let prefs = preferences()
        let inspectingModeDirection = direction ?? appDelegate().modeMap.inspectingModeDirection
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(inspectingModeDirection)
        let actionName = self.actionNameInDirection(inspectingModeDirection)
        let optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(actionDirectionName):option:\(optionName)"
        let pref = prefs.object(forKey: optionKey)
        print(" -> Setting action options \(optionKey) from (\(pref ?? "nil")) to (\(optionValue))")
        
        prefs.set(optionValue, forKey: optionKey)
        prefs.synchronize()
    }
    
    func changeBatchActionOption(_ batchActionKey: String, optionName: String, to optionValue: Any,
                                 direction: TTModeDirection? = nil, actionDirection: TTModeDirection? = nil) {
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(direction ?? modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(actionDirection ?? appDelegate().modeMap.inspectingModeDirection)
        let optionKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions:\(batchActionKey):actionoption:\(optionName)"
        let pref = prefs.object(forKey: optionKey)
        print(" -> Setting batch action options \(optionKey) from (\(pref ?? "nil")) to (\(optionValue))")
        
        prefs.set(optionValue, forKey: optionKey)
        prefs.synchronize()
    }
    
    func removeActionOption(_ optionName: String, direction: TTModeDirection?=nil) {
        let prefs = preferences()
        let inspectingModeDirection = direction ?? appDelegate().modeMap.inspectingModeDirection
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(inspectingModeDirection)
        let actionName = self.actionNameInDirection(inspectingModeDirection)
        let optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(actionDirectionName):option:\(optionName)"
        let pref = prefs.object(forKey: optionKey)
        print(" -> Deleting action option \(optionKey) (\(pref ?? "nil"))")
        
        prefs.removeObject(forKey: optionKey)
        prefs.synchronize()
    }
    
    func removeBatchActionOption(_ batchActionKey: String, optionName: String,
                                 direction: TTModeDirection? = nil, actionDirection: TTModeDirection? = nil) {
        let prefs = preferences()
        let modeDirectionName = appDelegate().modeMap.directionName(direction ?? modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(actionDirection ?? appDelegate().modeMap.inspectingModeDirection)
        let optionKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions:\(batchActionKey):actionoption:\(optionName)"
        let pref = prefs.object(forKey: optionKey)
        print(" -> Deleting batch action option \(optionKey) (\(pref ?? "nil"))")
        
        prefs.removeObject(forKey: optionKey)
        prefs.synchronize()
    }
    
    // MARK: Images
    
    func imageNameInDirection(_ direction: TTModeDirection) -> String? {
        let actionName = self.actionNameInDirection(direction)
        return self.imageNameForAction(actionName)
    }
    
    func imageNameForAction(_ actionName: String) -> String? {
        let titleSelector = NSSelectorFromString("image\(actionName)")
        if !self.responds(to: titleSelector) {
            return nil
        }
        
        let actionImageName = self.perform(titleSelector, with: self).takeUnretainedValue() as! String
        return actionImageName
        
    }
}
