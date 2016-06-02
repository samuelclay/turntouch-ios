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
}