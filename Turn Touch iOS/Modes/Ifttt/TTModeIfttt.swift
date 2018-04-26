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
        return "lightning"
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
            "user_id": appDelegate().modeMap.userId(),
            "device_id": appDelegate().modeMap.deviceId(),
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
    
    func authorizeIfttt() {
        let attrs = appDelegate().modeMap.deviceAttrs() as! [String: String]
        let params = (attrs.compactMap({ (key, value) -> String in
            return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)"
        }) as Array).joined(separator: "&")
        let url = "https://turntouch.com/ifttt/begin?\(params)"
        oauthViewController = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: false)
        oauthViewController.modalPresentationStyle = .formSheet
        appDelegate().mainViewController.present(oauthViewController, animated: true, completion: nil)
    }
     
    func openRecipe(direction: TTModeDirection) {
        let modeDirection = appDelegate().modeMap.directionName(self.modeDirection)
        let actionDirection = appDelegate().modeMap.directionName(direction)
        
        var attrs = appDelegate().modeMap.deviceAttrs() as! [String: String]
        attrs["app_direction"] = modeDirection
        attrs["button_direction"] = actionDirection

        let params = (attrs.compactMap({ (key, value) -> String in
            return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)"
        }) as Array).joined(separator: "&")
        let url = "https://turntouch.com/ifttt/open_recipe?\(params)"
        
        oauthViewController = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: false)
        oauthViewController.modalPresentationStyle = .formSheet
        appDelegate().mainViewController.present(oauthViewController, animated: true, completion: nil)
    }
    
    func purgeRecipe(direction: TTModeDirection, callback: (() -> Void)? = nil) {
        let modeDirection = appDelegate().modeMap.directionName(self.modeDirection)
        let actionDirection = appDelegate().modeMap.directionName(direction)
        
        var params = appDelegate().modeMap.deviceAttrs() as! [String: String]
        params["app_direction"] = modeDirection
        params["button_direction"] = actionDirection

        print(" ---> Purging: \(params)")
        Alamofire.request("https://turntouch.com/ifttt/purge_trigger", method: .post,
                          parameters: params, encoding: URLEncoding.default).responseJSON
            { response in
                print(" ---> Purged: \(response)")
                if let callback = callback {
                    callback()
                }
        }
    }
    
    func registerTriggers(callback: (() -> Void)? = nil) {
        let triggers = self.collectTriggers()
        
        let params: [String: Any] = [
            "user_id": appDelegate().modeMap.userId(),
            "device_id": appDelegate().modeMap.deviceId(),
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
        
}
