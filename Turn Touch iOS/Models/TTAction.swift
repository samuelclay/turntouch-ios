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
    var direction: TTModeDirection?
    
    init(actionName: String, direction: TTModeDirection?=nil) {
        super.init()
        mode = appDelegate().modeMap.selectedMode
        self.actionName = actionName
        self.direction = direction
    }
    
    init(batchActionKey: String) {
        super.init()
        self.batchActionKey = batchActionKey
        let chunks = batchActionKey.components(separatedBy: ":")
        let className = "Turn_Touch_iOS.\(chunks[0])"
        let modeClass = NSClassFromString(className) as! TTMode.Type
        mode = modeClass.init()
        mode.modeDirection = appDelegate().modeMap.selectedModeDirection
        mode.action = self
        if mode.responds(to: NSSelectorFromString("activate")) {
            mode.activate()
        }
        actionName = chunks[1]
    }
    
    func deactivate() {
        if mode.responds(to: NSSelectorFromString("activate")) {
            mode.deactivate()
        }
    }
    
    // MARK: Options
    
    func optionValue(_ optionName: String, direction: TTModeDirection) -> Any? {
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
}
