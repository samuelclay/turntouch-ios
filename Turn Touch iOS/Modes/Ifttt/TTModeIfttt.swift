//
//  TTModeIfttt.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SafariServices
import Alamofire

struct TTModeIftttConstants {
    static let kIftttUserIdKey = "TT:IFTTT:shared_user_id"
    static let kIftttDeviceIdKey = "TT:IFTTT:device_id"
    static let kIftttIsActionSetup = "isActionSetup"
    static let kIftttTapType = "tapType"
}

enum TTIftttState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeIftttDelegate {
    func changeState(_ state: TTIftttState, mode: TTModeIfttt)
}


class TTModeIfttt: TTMode {
    
    static var reachability: Reachability!
    var delegate: TTModeIftttDelegate!
    static var IftttState = TTIftttState.disconnected
    var oauthViewController: SFSafariViewController!
    
    required init() {
        super.init()
        
        self.watchReachability()
    }
    
    override class func title() -> String {
        return "IFTTT"
    }
    
    override class func subtitle() -> String {
        return "Buttons for If This Then That"
    }
    
    override class func imageName() -> String {
        return "mode_ifttt.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return [
            "TTModeIftttTriggerAction",
        ]
    }
    
    // MARK: Action titles
    
    func titleTTModeIftttTriggerAction() -> String {
        return "Trigger action"
    }
    
    // MARK: Action images
    
    func imageTTModeIftttTriggerAction() -> String {
        return "trigger"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    override func defaultEast() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    override func defaultWest() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    override func defaultSouth() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    // MARK: Action methods
    
    override func activate() {

    }
    
    override func deactivate() {

    }
    
    
    func runTTModeIftttTriggerAction() {
        self.trigger(doubleTap: false)
    }
    
    func doubleRunTTModeIftttTriggerAction() {
        self.trigger(doubleTap: true)
    }
    
    func trigger(doubleTap: Bool) {
        let modeName = type(of: self).title()
        let modeDirection = appDelegate().modeMap.directionName(self.modeDirection)
        let actionName = self.action.actionName
        let actionTitle = self.actionTitleForAction(actionName!, buttonMoment: .button_MOMENT_PRESSUP)!
        let actionDirection = appDelegate().modeMap.directionName(self.action.direction)
        let tapType = self.action.optionValue(TTModeIftttConstants.kIftttTapType) as! String
        let trigger = ["app_label": modeName,
                       "app_direction": modeDirection,
                       "button_label": actionTitle,
                       "button_direction": actionDirection,
                       "button_tap_type": tapType,
                       ]
    
        let params: [String: Any] = [
            "user_id": self.iftttUserId(),
            "device_id": self.iftttDeviceId(),
            "triggers": [trigger],
        ]
        
        Alamofire.request("https://turntouch.com/ifttt/button_trigger", method: .post,
                          parameters: params, encoding: JSONEncoding.default).responseJSON
            { response in
                print(" ---> Button trigger: \(response)")
            }
    }
    
    // MARK: Ifttt Reachability
    
    func watchReachability() {
        if TTModeIfttt.reachability != nil {
            return
        }
        
        TTModeIfttt.reachability = Reachability()
        
        TTModeIfttt.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if TTModeIfttt.IftttState != .connected {
                    print(" ---> Reachable, re-connecting to Ifttt...")
//                    self.beginConnectingToIfttt()
                }
            }
        }
        
        TTModeIfttt.reachability.whenUnreachable = { reachability in
            if TTModeIfttt.IftttState != .connected {
                print(" ---> Unreachable, not connected")
            }
        }
        
        do {
            try TTModeIfttt.reachability.startNotifier()
        } catch {
            print("Unable to start Ifttt notifier")
        }
    }
    
    func beginConnectingToIfttt() {
        self.registerTriggers()
        self.authorizeIfttt()
        
        TTModeIfttt.IftttState = .connecting
        delegate?.changeState(TTModeIfttt.IftttState, mode: self)
    }
    
    func iftttDeviceAttrs() -> [String: String] {
        let userId = self.iftttUserId()
        let deviceId = self.iftttDeviceId()
        let deviceName = UIDevice.current.name
        let deviceModel = UIDevice.current.model
        let devicePlatform = UIDevice.current.systemName
        let deviceVersion = UIDevice.current.systemVersion
        let devices = appDelegate().bluetoothMonitor.foundDevices.devices
        var remoteName: String?
        if devices.count >= 1 {
            remoteName = devices[0].nickname
        }
        let attrs: [String: String] = [
            "user_id": userId,
            "device_id": deviceId,
            "device_name": deviceName,
            "device_platform": devicePlatform,
            "device_model": deviceModel,
            "device_version": deviceVersion,
            "remote_name": remoteName ?? "",
            ]
        
        return attrs
    }
    
    func authorizeIfttt() {
        let attrs = self.iftttDeviceAttrs()
        let params = (attrs.flatMap({ (key, value) -> String in
            return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)"
        }) as Array).joined(separator: "&")
        let url = "https://turntouch.com/ifttt/begin?\(params)"
        oauthViewController = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: false)
        oauthViewController.modalPresentationStyle = .formSheet
        appDelegate().mainViewController.present(oauthViewController, animated: true, completion: nil)
    }
    
    func openRecipe(actionDirection: TTModeDirection) {
        let modeDirection = appDelegate().modeMap.directionName(self.modeDirection)
        let actionDirection = appDelegate().modeMap.directionName(actionDirection)
        
        var attrs = self.iftttDeviceAttrs()
        attrs["app_direction"] = modeDirection
        attrs["button_direction"] = actionDirection

        let params = (attrs.flatMap({ (key, value) -> String in
            return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)"
        }) as Array).joined(separator: "&")
        let url = "https://turntouch.com/ifttt/open_recipe?\(params)"
        
        oauthViewController = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: false)
        oauthViewController.modalPresentationStyle = .formSheet
        appDelegate().mainViewController.present(oauthViewController, animated: true, completion: nil)
    }
    
    func registerTriggers(callback: (() -> Void)? = nil) {
        let triggers = self.collectTriggers()
        
        let params: [String: Any] = [
            "user_id": self.iftttUserId(),
            "device_id": self.iftttDeviceId(),
            "triggers": triggers,
        ]
        print(" ---> Registering: \(params)")
        Alamofire.request("https://turntouch.com/ifttt/register_triggers", method: .post,
                          parameters: params, encoding: JSONEncoding.default).responseJSON
            { response in
                print(" ---> Registered: \(response)")
                if let callback = callback {
                    callback()
                }
            }
    }
    
    func collectTriggers() -> [[String: String]] {
        var triggers: [[String: String]] = []
        let prefs = UserDefaults.standard
        
        // Primary modes first
        for modeDirection: TTModeDirection in [.north, .east, .west, .south] {
            let mode = appDelegate().modeMap.modeInDirection(modeDirection)
            let modeName = type(of: mode).title()
            for actionDirection: TTModeDirection in [.north, .east, .west, .south] {
                let actionName = mode.actionNameInDirection(actionDirection)
                if actionName == "TTModeIftttTriggerAction" {
                    let tapType = mode.actionOptionValue(TTModeIftttConstants.kIftttTapType,
                                                         actionName: actionName, direction: actionDirection) as! String
                    triggers.append(["app_label": modeName,
                                     "app_direction": appDelegate().modeMap.directionName(modeDirection),
                                     "button_label": self.actionTitleForAction(actionName, buttonMoment: .button_MOMENT_PRESSUP)!,
                                     "button_direction": appDelegate().modeMap.directionName(actionDirection),
                                     "button_tap_type": tapType,
                                     ])
                }
                
                let modeBatchActionKey = appDelegate().modeMap.batchActions.modeBatchActionKey(modeDirection: modeDirection,
                                                                                               actionDirection: actionDirection)
                let batchActionKeys: [String]? = prefs.object(forKey: modeBatchActionKey) as? [String]
                if let keys = batchActionKeys {
                    for batchActionKey in keys {
                        if batchActionKey.contains("TTModeIftttTriggerAction") {
                            let action = TTAction(batchActionKey: batchActionKey, direction: actionDirection)
                            action.mode.modeDirection = modeDirection
                            let tapType = action.mode.batchActionOptionValue(batchActionKey: batchActionKey,
                                                                             optionName: TTModeIftttConstants.kIftttTapType,
                                                                             actionName: action.actionName,
                                                                             actionDirection: actionDirection) as! String
                            triggers.append(["app_label": modeName,
                                             "app_direction": appDelegate().modeMap.directionName(modeDirection),
                                             "button_label": mode.actionTitleForAction(actionName, buttonMoment: .button_MOMENT_PRESSUP)!,
                                             "button_direction": appDelegate().modeMap.directionName(actionDirection),
                                             "button_tap_type": tapType,
                                             ])
                        }
                    }
                }
            }
        }
        
        return triggers
    }
    
    func cancelConnectingToIfttt() {
            TTModeIfttt.IftttState = .disconnected
            delegate?.changeState(TTModeIfttt.IftttState, mode: self)
    }
    
    func IftttReady() {
        TTModeIfttt.IftttState = .connected
        delegate?.changeState(TTModeIfttt.IftttState, mode: self)
    }
    
    func logMessage(_ message: String) {
        print(" ---> Ifttt API: \(message)")
    }
    
    // MARK: Device info
    
    func iftttUserId() -> String {
        var uuid: NSUUID!
        let prefs = UserDefaults.standard
        
        if let uuidString = NSUbiquitousKeyValueStore.default().string(forKey: TTModeIftttConstants.kIftttUserIdKey) {
            uuid = NSUUID(uuidString: uuidString)
            
            prefs.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            prefs.synchronize()
        } else if let uuidString = prefs.string(forKey: TTModeIftttConstants.kIftttUserIdKey) {
            uuid = NSUUID(uuidString: uuidString)
            
            NSUbiquitousKeyValueStore.default().set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            NSUbiquitousKeyValueStore.default().synchronize()
        } else {
            uuid = NSUUID()
            
            prefs.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            prefs.synchronize()
            
            NSUbiquitousKeyValueStore.default().set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            NSUbiquitousKeyValueStore.default().synchronize()
        }
        
        return uuid.uuidString
    }
    
    func iftttDeviceId() -> String {
        var uuid: NSUUID!
        let prefs = UserDefaults.standard
        
        if let uuidString = prefs.string(forKey: TTModeIftttConstants.kIftttDeviceIdKey) {
            uuid = NSUUID(uuidString: uuidString)
        } else {
            uuid = NSUUID()
            
            prefs.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttDeviceIdKey)
            prefs.synchronize()
        }
        
        return uuid.uuidString
    }
    
}
