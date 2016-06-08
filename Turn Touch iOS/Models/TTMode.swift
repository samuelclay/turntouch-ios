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
    var action: TTAction = TTAction()
    
    required override init() {
        super.init()
//        NSLog("Initializing mode: \(self)")
    }
    
    func deactivate() {
        
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
        print("Direction action: \(prefKey) - \(directionAction)")
        
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
        
        return directionAction
    }
    
    func changeDirection(direction: TTModeDirection, toAction actionClassName: String) {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let prefKey = "TT:\(self.nameOfClass)-\(modeDirectionName):action:\(actionDirectionName)"
        let directionAction = prefs.stringForKey(prefKey)
        print("Direction action: \(prefKey) - \(directionAction) to \(actionClassName)")
        
        prefs.setObject(actionClassName, forKey: prefKey)
        prefs.synchronize()
        
        
    }
    
    // MARK: Images
    
    func imageNameInDirection(direction: TTModeDirection) -> String? {
        let actionName = self.actionNameInDirection(direction)
        return self.imageNameForAction(actionName)
    }
    
    func imageNameForAction(actionName: String?) -> String? {
        let titleSelector = NSSelectorFromString("image\(actionName)")
        if !self.respondsToSelector(titleSelector) {
            return nil
        }
        
        let actionImageName = self.performSelector(titleSelector, withObject: self).takeUnretainedValue() as! String
        return actionImageName
        
    }
}