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
        
        delegate?.changeState(TTModeHomeKit.homeKitState, mode: self)
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
            "TTModeHomeKitTriggerScene",
        ]
    }
    
    // MARK: Action titles
    
    func titleTTModeHomeKitTriggerScene() -> String {
        return "Trigger scene"
    }
    
    // MARK: Action images
    
    func imageTTModeHomeKitTriggerScene() -> String {
        return "trigger"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeHomeKitTriggerScene"
    }
    
    override func defaultEast() -> String {
        return "TTModeHomeKitTriggerScene"
    }
    
    override func defaultWest() -> String {
        return "TTModeHomeKitTriggerScene"
    }
    
    override func defaultSouth() -> String {
        return "TTModeHomeKitTriggerScene"
    }
    
    // MARK: Action methods
    
    override func activate() {
        if homeManager == nil {
            homeManager = HMHomeManager()
            homeManager.delegate = self
            TTModeHomeKit.homeKitState = .connecting
        }
        
        delegate?.changeState(TTModeHomeKit.homeKitState, mode: self)
    }
    
    override func deactivate() {
        
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("HomeKit: \(String(describing: homeManager.primaryHome?.accessories))")
        
        TTModeHomeKit.homeKitState = .connected
        delegate?.changeState(TTModeHomeKit.homeKitState, mode: self)
    }
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        print("HomeKit: \(String(describing: homeManager.primaryHome?.accessories))")
        
        TTModeHomeKit.homeKitState = .connected
        delegate?.changeState(TTModeHomeKit.homeKitState, mode: self)
    }
    
    func runTTModeHomeKitTriggerScene() {
        self.trigger(doubleTap: false)
    }
    
    func doubleRunTTModeHomeKitTriggerScene() {
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
