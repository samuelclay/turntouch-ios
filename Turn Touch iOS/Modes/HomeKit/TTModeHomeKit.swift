//
//  TTModeHomeKit.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 9/15/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit
import HomeKit
import ReachabilitySwift
import SafariServices
import Alamofire

struct TTModeHomeKitConstants {
    static let kHomeKitUserIdKey = "TT:HomeKit:shared_user_id"
}

enum TTHomeKitState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeHomeKitDelegate {
    func changeState(_ state: TTHomeKitState, mode: TTModeHomeKit)
}

class TTModeHomeKit: TTMode, HMHomeManagerDelegate {

    static var reachability: Reachability!
    var delegate: TTModeHomeKitDelegate!
    static var homeKitState = TTHomeKitState.disconnected
    var homeManager: HMHomeManager!
    var homekitDelegate: HMHomeManagerDelegate!
    
    required init() {
        super.init()
    }
    
    override class func title() -> String {
        return "HomeKit"
    }
    
    override class func subtitle() -> String {
        return "Your home at your command."
    }
    
    override class func imageName() -> String {
        return "mode_homekit.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return [
            "TTModeHomeKitTriggerAction",
        ]
    }
    
    // MARK: Action titles
    
    func titleTTModeHomeKitTriggerAction() -> String {
        return "Trigger action"
    }
    
    // MARK: Action images
    
    func imageTTModeHomeKitTriggerAction() -> String {
        return "trigger"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeHomeKitTriggerAction"
    }
    
    override func defaultEast() -> String {
        return "TTModeHomeKitTriggerAction"
    }
    
    override func defaultWest() -> String {
        return "TTModeHomeKitTriggerAction"
    }
    
    override func defaultSouth() -> String {
        return "TTModeHomeKitTriggerAction"
    }
    
    // MARK: Action methods
    
    override func activate() {
        if homeManager == nil {
            homeManager = HMHomeManager()
            homeManager.delegate = self
        }
    }
    
    override func deactivate() {
        
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("HomeKit: \(String(describing: homeManager.primaryHome?.accessories))")
    }
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        print("HomeKit: \(String(describing: homeManager.primaryHome?.accessories))")
    }
    
    func runTTModeHomeKitTriggerAction() {
        self.trigger(doubleTap: false)
    }
    
    func doubleRunTTModeHomeKitTriggerAction() {
        self.trigger(doubleTap: true)
    }
    
    func trigger(doubleTap: Bool) {
//        let modeName = type(of: self).title()
//        let modeDirection = appDelegate().modeMap.directionName(self.modeDirection)
//        let actionName = self.action.actionName
//        let actionTitle = self.actionTitleForAction(actionName!, buttonMoment: .button_MOMENT_PRESSUP)!
//        let actionDirection = appDelegate().modeMap.directionName(self.action.direction)
        
    }
    
}
