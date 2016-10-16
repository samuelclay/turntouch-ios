//
//  TTBatchActions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTBatchActions: NSObject {
    
    var northActions: [TTAction] = []
    var eastActions: [TTAction] = []
    var westActions: [TTAction] = []
    var southActions: [TTAction] = []
    
    func assemble() {
        
    }
    
    func assembleBatchAction(in direction: TTModeDirection) -> [TTAction] {
        let prefs = UserDefaults.standard
        var batchActions: [TTAction] = []
        let batchActionKeys: [String]? = prefs.object(forKey: self.batchActionKey(in: direction)) as? [String]
        
        if let keys = batchActionKeys {
            for batchActionKey in keys {
                let batchAction = TTAction(batchActionKey: batchActionKey)
                batchActions.append(batchAction)
            }
        }
        
        return batchActions
    }
    
    func deactivate() {
        for action in [northActions, eastActions, westActions, southActions] {
            for batchAction in action {
                batchAction.deactivate()
            }
        }
    }
    
    func batchActionKey(in direction: TTModeDirection) -> String {
        let modeDirectionName = appDelegate().modeMap.directionName(appDelegate().modeMap.selectedModeDirection)
        let actionDirectionName = appDelegate().modeMap.directionName(direction)
        let batchKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions"
        
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
    
}
