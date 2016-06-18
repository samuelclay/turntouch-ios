//
//  TTMode.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

enum ActionLayout {
    case ACTION_LAYOUT_TITLE
    case ACTION_LAYOUT_IMAGE_TITLE
    case ACTION_LAYOUT_PROGRESSBAR
}

protocol TTModeProtocol {
    func deactivate()
    func activate()
    func title() -> String
    func imageName() -> String
    func subtitle() -> String
    func actions() -> [String]
}

infix operator >!< {}
func >!< (object1: AnyObject!, object2: AnyObject!) -> Bool {
    return (object_getClassName(object1) == object_getClassName(object2))
}

class TTMode : NSObject, TTModeProtocol {
    var modeDirection: TTModeDirection = .NO_DIRECTION
    var action: TTAction!
    
    required override init() {
        super.init()
//        NSLog("Initializing mode: \(self)")
    }
    
    func deactivate() {
        
    }
    
    func activate(direction: TTModeDirection) {
        modeDirection = direction
        
        self.activate()
    }
    
    func activate() {
        
    }
    
    // MARK: Mode settings
    
    func title() -> String {
        return "Mode"
    }
    
    func imageName() -> String {
        return ""
    }
    
    func subtitle() -> String {
        return ""
    }
    
    func actions() -> [String] {
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
    
    func runDirection(direction: TTModeDirection) {
        let actionName = self.actionNameInDirection(direction)!
        self.runAction(actionName, direction: direction, funcAction: "run")
    }
    
    func runAction(actionName: String, direction: TTModeDirection) {
        self.runAction(actionName, direction: direction, funcAction: "run")
    }
    
    func runDoubleDirection(direction: TTModeDirection) {
        if !self.runDirection(direction, funcAction: "doubleRun") {
            self.runDirection(direction)
        }
    }
    
    func runDirection(direction: TTModeDirection, funcAction: String) -> Bool {
        let actionName = self.actionNameInDirection(direction)!
        return self.runAction(actionName, direction: direction, funcAction: funcAction)
    }
    
    func runAction(actionName: String, direction: TTModeDirection, funcAction: String) -> Bool {
        var success = false
        print(" ---> Running \(direction): \(funcAction)\(actionName)")
        if self.action == nil || self.action.batchActionKey == nil {
            self.action = TTAction(actionName: actionName)
        }
        
        // runAction:direction
        let titleSelector = NSSelectorFromString("\(funcAction)\(actionName):")
        if self.respondsToSelector(titleSelector) {
            self.performSelector(titleSelector, withObject: self)
            success = true
        } else {
            // runAction
            let titleSelector = NSSelectorFromString("\(funcAction)\(actionName)")
            if self.respondsToSelector(titleSelector) {
                self.performSelector(titleSelector, withObject: self)
                success = true
            }
        }
        
        if self.action.batchActionKey == nil {
            self.action = nil
        }
        
        return success
    }
    
    func titleInDirection(direction: TTModeDirection, buttonMoment: TTButtonMoment) -> String {
        let actionName = self.actionNameInDirection(direction)
        
        if actionName == nil {
            print(" ---> Set title for \(direction)")
            return "Set \(direction)"
        }
        
        return self.titleForAction(actionName!, buttonMoment:buttonMoment)
    }
    
    func titleForAction(actionName: String, buttonMoment: TTButtonMoment) -> String {
        var runAction = "title"
        if buttonMoment == .BUTTON_MOMENT_DOUBLE {
            runAction = "doubleTitle"
        }
        
        let selector = NSSelectorFromString("\(runAction)\(actionName)")
        if !self.respondsToSelector(selector) && buttonMoment != .BUTTON_MOMENT_PRESSUP {
            print(" ---> No double click title: \(actionName)")
            return self.titleForAction(actionName, buttonMoment: .BUTTON_MOMENT_PRESSUP)
        }
        
        if !self.respondsToSelector(selector) {
            print(" ---> Set title for \(selector)")
            return "Set \(selector)"
        }
        
        let actionTitle = self.performSelector(selector, withObject: self).takeUnretainedValue() as! String
        return actionTitle
    }
    
    func actionTitleForAction(actionName: String, buttonMoment: TTButtonMoment) -> String? {
        var runAction = "actionTitle"
        if buttonMoment == .BUTTON_MOMENT_DOUBLE {
            runAction = "doubleActionTitle"
        }
        let titleSelector = NSSelectorFromString("\(runAction)\(actionName)")
        if !self.respondsToSelector(titleSelector) {
            return self.titleForAction(actionName, buttonMoment: buttonMoment)
        }
        
        let actionTitle = self.performSelector(titleSelector, withObject: self).takeUnretainedValue() as! String
        return actionTitle
    }
    
    func actionNameInDirection(direction: TTModeDirection) -> String? {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let prefKey = "TT:\(self.nameOfClass)-\(modeDirectionName):action:\(actionDirectionName)"
        var directionAction = prefs.stringForKey(prefKey)
        
        if directionAction == nil {
            switch direction {
            case .NORTH:
                directionAction = self.defaultNorth()
            case .EAST:
                directionAction = self.defaultEast()
            case .WEST:
                directionAction = self.defaultWest()
            case .SOUTH:
                directionAction = self.defaultSouth()
            case .INFO:
                directionAction = self.defaultInfo()
            default:
                directionAction = nil
            }
        }
//        print("Direction action: \(prefKey) - \(directionAction)")
        
        return directionAction
    }
    
    func shouldIgnoreSingleBeforeDouble(direction: TTModeDirection) -> Bool {
        let actionName = self.actionNameInDirection(direction)
        let titleSelector = NSSelectorFromString("shouldIgnoreSingleBeforeDouble\(actionName)")
        if !self.respondsToSelector(titleSelector) {
            return false
        }
        
        let ignore = self.performSelector(titleSelector, withObject: self).takeUnretainedValue() as! Bool
        return ignore
    }
    
    func shouldFireImmediateOnPress(direction: TTModeDirection) -> Bool {
        let actionName = self.actionNameInDirection(direction)
        let titleSelector = NSSelectorFromString("shouldFireImmediate\(actionName)")
        if !self.respondsToSelector(titleSelector) {
            return false
        }
        
        let immediate = self.performSelector(titleSelector, withObject: self).takeUnretainedValue() as! Bool
        return immediate
    }

    // MARK: Changing mode settings
    
    func changeDirection(direction: TTModeDirection, toAction actionClassName: String) {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let prefKey = "TT:\(self.nameOfClass)-\(modeDirectionName):action:\(actionDirectionName)"

//        let directionAction = prefs.stringForKey(prefKey)
//        print("Direction action: \(prefKey) - \(directionAction) to \(actionClassName)")
        
        prefs.setObject(actionClassName, forKey: prefKey)
        prefs.synchronize()
    }
    
    // MARK: Action options
    
    func actionOptionValue(optionName: String, actionName: String, direction: TTModeDirection) -> AnyObject? {
        let prefs = NSUserDefaults.standardUserDefaults()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        
        if direction == .NO_DIRECTION {
            // Rotate through directions looking for prefs
            for modeDirection: TTModeDirection in [.NORTH, .EAST, .WEST, .SOUTH] {
                let modeActionDirectionName = appDelegate().modeMap.directionName(modeDirection)
                let optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(modeActionDirectionName):option:\(optionName)"
                let pref = prefs.objectForKey(optionKey)
                print(" -> Getting action options \(optionKey): \(pref)")
                if pref == nil {
                    continue
                }
                return pref
            }
        }
        
        let optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(actionDirectionName):option:\(optionName)"
        var pref = prefs.objectForKey(optionKey)
        print(" -> Getting action options \(optionKey): \(pref)")
        if pref == nil {
            pref = self.defaultOption(actionName, optionName: optionName)
        }
        if pref == nil {
            pref = self.defaultOption(optionName)
        }
        
        return pref
    }
    
    func batchActionOptionValue(batchAction: TTAction, optionName: String, direction: TTModeDirection) -> AnyObject? {
        let prefs = NSUserDefaults.standardUserDefaults()
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let optionKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions:\(action.batchActionKey):actionoption:\(optionName)"
        var pref = prefs.objectForKey(optionKey)
        print(" -> Getting batch action options \(optionKey): \(pref)")
        if pref == nil {
            pref = self.defaultOption(action.actionName, optionName: optionName)
        }
        if pref == nil {
            pref = self.defaultOption(optionName)
        }
        
        return pref
    }
    
    func defaultOption(optionName: String) -> AnyObject? {
        let defaultPrefsFile = NSBundle.mainBundle().pathForResource(self.nameOfClass, ofType: "plist")
        if defaultPrefsFile == nil {
            return nil
        }
        let modeDefaults: Dictionary<String, AnyObject>? = NSDictionary(contentsOfFile: defaultPrefsFile!) as? Dictionary<String, AnyObject>
        print(" -> Getting mode option default \(optionName): \(modeDefaults?[optionName])")
        
        return modeDefaults?[optionName]
    }
    
    func defaultOption(actionName: String, optionName: String) -> AnyObject? {
        let defaultPrefsFile = NSBundle.mainBundle().pathForResource(self.nameOfClass, ofType: "plist")
        if defaultPrefsFile == nil {
            return nil
        }
        let modeDefaults: Dictionary<String, AnyObject>? = NSDictionary(contentsOfFile: defaultPrefsFile!) as? Dictionary<String, AnyObject>
        let optionKey = "\(actionName):\(optionName)"
        print(" -> Getting mode action option default \(optionKey): \(modeDefaults?[optionKey])")
        
        return modeDefaults?[optionKey]
    }
    
    // MARK: Setting action options
    
    func changeActionOption(optionName: String, to optionValue: AnyObject) {
        if optionName == "" {
            print(" ---> BUSTED: \(optionValue)")
            return
        }
        let prefs = NSUserDefaults.standardUserDefaults()
        let inspectingModeDirection = appDelegate().modeMap.inspectingModeDirection
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(inspectingModeDirection)
        let actionName = self.actionNameInDirection(inspectingModeDirection)!
        let optionKey = "TT:mode:\(self.nameOfClass)-\(modeDirectionName):action:\(actionName)-\(actionDirectionName):option:\(optionName)"
        let pref = prefs.objectForKey(optionKey)
        print(" -> Setting action options \(optionKey) from (\(pref)) to (\(optionValue))")
        
        prefs.setObject(optionValue, forKey: optionKey)
        prefs.synchronize()
    }
    
    func changeBatchActionOption(batchActionKey: String, optionName: String, to optionValue: AnyObject) {
        let prefs = NSUserDefaults.standardUserDefaults()
        let inspectingModeDirection = appDelegate().modeMap.inspectingModeDirection
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(inspectingModeDirection)
        let optionKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions:\(batchActionKey):actionoption:\(optionName)"
        let pref = prefs.objectForKey(optionKey)
        print(" -> Setting batch action options \(optionKey) from (\(pref)) to (\(optionValue))")
        
        prefs.setObject(optionValue, forKey: optionKey)
        prefs.synchronize()
    }
    
    // MARK: Images
    
    func imageNameInDirection(direction: TTModeDirection) -> String? {
        let actionName = self.actionNameInDirection(direction)!
        return self.imageNameForAction(actionName)
    }
    
    func imageNameForAction(actionName: String) -> String? {
        let titleSelector = NSSelectorFromString("image\(actionName)")
        if !self.respondsToSelector(titleSelector) {
            return nil
        }
        
        let actionImageName = self.performSelector(titleSelector, withObject: self).takeUnretainedValue() as! String
        return actionImageName
        
    }
}