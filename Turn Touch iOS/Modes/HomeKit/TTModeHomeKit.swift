//
//  TTModeHomeKit.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 9/15/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit
import HomeKit
import Reachability
import SafariServices

struct TTModeHomeKitConstants {
    static let kHomeKitHomeIdentifier = "homeIdentifier"
    static let kHomeKitSceneIdentifier = "sceneIdentifier"
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
        return self.titleTTModeHomeKitTriggerScene(direction: NSNumber(integerLiteral: TTModeDirection.no_DIRECTION.rawValue))
    }
    
    func titleTTModeHomeKitTriggerScene(direction: NSNumber) -> String {
        let direction = TTModeDirection(rawValue: direction.intValue)!
        if direction != .no_DIRECTION {
            let scene = self.selectedScene(in: direction)
            return scene?.name ?? "Trigger scene"
        }
        
        return "Trigger scene"
    }
    
    // MARK: Action images
    
    func imageTTModeHomeKitTriggerScene() -> String {
        return "lightning"
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
        self.ensureHomeSelected()
        
        if let home = self.selectedHome(),
            let scene = self.selectedScene() {
            home.executeActionSet(scene, completionHandler: { (error) in
                print(" ---> Executed action set. (\(String(describing: error)))")
            })
        }
    }
    
    func ensureHomeSelected() {
        if homeManager.homes.count == 0 {
            return
        }
        
        if self.action == nil {
            // Used when retrieving title of action
            return
        }
        
        let selectedHomeIdentifier = self.action.optionValue(TTModeHomeKitConstants.kHomeKitHomeIdentifier) as? String
        if selectedHomeIdentifier == nil {
            if let primaryHome = homeManager.primaryHome {
                self.action.changeActionOption(TTModeHomeKitConstants.kHomeKitHomeIdentifier,
                                               to: primaryHome.uniqueIdentifier.uuidString)
            }
        }
    }
    
    func selectedHome(_ direction: TTModeDirection = .no_DIRECTION) -> HMHome? {
        self.ensureHomeSelected()
        
        if homeManager.homes.count == 0 {
            return nil
        }

        let selectedHomeIdentifier: String?
        if direction == .no_DIRECTION {
             selectedHomeIdentifier = self.action.optionValue(TTModeHomeKitConstants.kHomeKitHomeIdentifier) as? String
        } else {
            let actionName = self.actionNameInDirection(direction)
            selectedHomeIdentifier = self.actionOptionValue(TTModeHomeKitConstants.kHomeKitHomeIdentifier,
                                                            actionName: actionName, direction: direction) as? String
        }
        for home in homeManager.homes {
            if home.uniqueIdentifier.uuidString == selectedHomeIdentifier {
                return home
            }
        }
        
        return nil
    }
    
    // If a scene either has not yet been chosen or the scene doesn't exist in the selected home,
    // which can happen when switching homes, then choose the first scene.
    func ensureSceneSelected() {
        if homeManager.homes.count == 0 {
            return
        }
        
        if self.action == nil {
            return
        }

        var selectedSceneIdentifier = self.action.optionValue(TTModeHomeKitConstants.kHomeKitSceneIdentifier) as? String
        if selectedSceneIdentifier != nil {
            if let home = self.selectedHome() {
                for scene in home.actionSets {
                    if scene.uniqueIdentifier.uuidString == selectedSceneIdentifier {
                        return
                    }
                }
                
                // If we made it this far then clear out the scene because it's not part of the home
                selectedSceneIdentifier = nil
            }
        }
        
        if selectedSceneIdentifier == nil {
            if let home = self.selectedHome() {
                if home.actionSets.count > 0 {
                    self.action.changeActionOption(TTModeHomeKitConstants.kHomeKitSceneIdentifier,
                                                   to: home.actionSets[0].uniqueIdentifier.uuidString)
                }
            }
        }
    }
    
    func selectedScene() -> HMActionSet? {
        self.ensureSceneSelected()
        
        guard let home = self.selectedHome() else {
            return nil
        }
        
        let selectedSceneIdentifier = self.action.optionValue(TTModeHomeKitConstants.kHomeKitSceneIdentifier) as? String
        for scene in home.actionSets {
            if scene.uniqueIdentifier.uuidString == selectedSceneIdentifier {
                return scene
            }
        }
        
        return nil
    }
    
    func selectedScene(in direction: TTModeDirection) -> HMActionSet? {
        guard let home = self.selectedHome(direction) else {
            return nil
        }
        
        let actionName = self.actionNameInDirection(direction)
        let selectedSceneIdentifier = self.actionOptionValue(TTModeHomeKitConstants.kHomeKitSceneIdentifier, actionName: actionName, direction: direction) as? String
        for scene in home.actionSets {
            if scene.uniqueIdentifier.uuidString == selectedSceneIdentifier {
                return scene
            }
        }
        
        return nil
    }
}
