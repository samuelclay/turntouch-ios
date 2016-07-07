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
        self.batchActionKey = batchActionKey
        print("Need chunks")
    }
    
    func deactivate() {
        if mode.respondsToSelector(NSSelectorFromString("activate")) {
            mode.deactivate()
        }
    }
    
    // MARK: Options
    
    func optionValue(optionName: String, direction: TTModeDirection) -> AnyObject? {
        if batchActionKey == nil {
            return mode.actionOptionValue(optionName, actionName: actionName, direction: direction)
        } else {
            return mode.batchActionOptionValue(self, optionName: optionName, direction: direction)
        }
    }
    
    func changeActionOption(optionName: String, to optionValue: AnyObject) {
        if batchActionKey == nil {
            mode.changeActionOption(optionName, to: optionValue, direction: direction)
        } else {
            mode.changeBatchActionOption(batchActionKey!, optionName: optionName, to: optionValue)
        }
    }
}