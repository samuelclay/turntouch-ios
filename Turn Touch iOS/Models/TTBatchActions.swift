//
//  TTBatchActions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

@objcMembers
class TTBatchActions: NSObject {
    
    var modeDirection: TTModeDirection = .no_DIRECTION
    var northActions: [TTAction] = []
    var eastActions: [TTAction] = []
    var westActions: [TTAction] = []
    var southActions: [TTAction] = []
    
    func assemble(modeDirection: TTModeDirection) {
        self.modeDirection = modeDirection
        northActions = self.assembleBatchAction(in: .north)
        eastActions = self.assembleBatchAction(in: .east)
        westActions = self.assembleBatchAction(in: .west)
        southActions = self.assembleBatchAction(in: .south)
    }
    
    func assembleBatchAction(in direction: TTModeDirection) -> [TTAction] {
        let prefs = preferences()
        var batchActions: [TTAction] = []
        let key = self.batchActionKey(in: direction)
        let batchActionKeys: [String]? = prefs.object(forKey: key) as? [String]
        
        if let keys = batchActionKeys {
            for batchActionKey in keys {
                let batchAction = TTAction(batchActionKey: batchActionKey, direction: direction)
                batchActions.append(batchAction)
            }
        }
        
        return batchActions
    }
    
    func batchActionKey(in direction: TTModeDirection) -> String {
        return self.modeBatchActionKey(modeDirection: modeDirection, actionDirection: direction)
    }
    
    func modeBatchActionKey(modeDirection: TTModeDirection, actionDirection: TTModeDirection) -> String {
        let modeDirectionName = appDelegate().modeMap.directionName(modeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(actionDirection)
        let batchKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions"
        
        print(" ---> modeBatchActionKey: \(batchKey)")
        return batchKey
    }
    
    func batchActions(in direction: TTModeDirection) -> [TTAction] {
        switch direction {
        case .north: return northActions
        case .east: return eastActions
        case .west: return westActions
        case .south: return southActions
        default: break
        }
        
        return []
    }
    
    func deactivate() {
        for action in [northActions, eastActions, westActions, southActions] {
            for batchAction in action {
                batchAction.deactivate()
            }
        }
    }
    
}
