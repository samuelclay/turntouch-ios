//
//  TTAction.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

class TTAction: NSObject {
    
    var mode: TTMode!
    var actionName: String!
    var batchActionKey: String?
    var direction: TTModeDirection!
    
    init(actionName: String, direction: TTModeDirection) {
        super.init()
        mode = appDelegate().modeMap.selectedMode
        self.actionName = actionName
        self.direction = direction
    }
    
    init(batchActionKey: String, direction: TTModeDirection) {
        super.init()
        self.batchActionKey = batchActionKey
        let chunks = batchActionKey.components(separatedBy: ":")
        let className = "Turn_Touch_iOS.\(chunks[0])"
        let modeClass = NSClassFromString(className) as! TTMode.Type
        mode = modeClass.init()
        mode.modeDirection = appDelegate().modeMap.selectedModeDirection
        mode.action = self
        actionName = chunks[1]
        self.direction = direction

        if mode.responds(to: NSSelectorFromString("activate")) {
            mode.activate()
        }
    }
    
    func deactivate() {
        if mode.responds(to: NSSelectorFromString("activate")) {
            mode.deactivate()
        }
    }
    
    // MARK: Options
    
    func optionValue(_ optionName: String) -> Any? {
        if batchActionKey == nil {
            return mode.actionOptionValue(optionName, actionName: actionName, direction: direction)
        } else {
            return mode.batchActionOptionValue(self, optionName: optionName, direction: direction)
        }
    }
    
    func changeActionOption(_ optionName: String, to optionValue: Any) {
        if batchActionKey == nil {
            mode.changeActionOption(optionName, to: optionValue, direction: direction)
        } else {
            mode.changeBatchActionOption(batchActionKey!, optionName: optionName, to: optionValue)
        }
    }
    
    func removeActionOption(_ optionName: String) {
        if batchActionKey == nil {
            mode.removeActionOption(optionName, direction: direction)
        } else {
            mode.removeBatchActionOption(batchActionKey!, optionName: optionName)
        }
    }
}
