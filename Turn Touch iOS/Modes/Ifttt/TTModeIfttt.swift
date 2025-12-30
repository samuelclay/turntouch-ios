//
//  TTModeIfttt.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import SafariServices

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
    
    var delegate: TTModeIftttDelegate!
    static var IftttState = TTIftttState.disconnected
    var oauthViewController: SFSafariViewController!
    
    required init() {
        super.init()
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

        Task {
            await postJSON(url: "https://turntouch.com/ifttt/button_trigger", params: params) { response in
                print(" ---> IFTTT Button trigger: \(response)")
            }
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
        oauthViewController = SFSafariViewController(url: URL(string: url)!, configuration: SFSafariViewController.Configuration())
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
        
        oauthViewController = SFSafariViewController(url: URL(string: url)!, configuration: SFSafariViewController.Configuration())
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
        Task {
            await postFormEncoded(url: "https://turntouch.com/ifttt/purge_trigger", params: params) { response in
                print(" ---> Purged: \(response)")
                callback?()
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
        Task {
            await postJSON(url: "https://turntouch.com/ifttt/register_triggers", params: params) { response in
                print(" ---> Registered: \(response)")
                callback?()
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
                    let tapType = self.actionOptionValue(TTModeIftttConstants.kIftttTapType,
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
        
        for modeDirection: TTModeDirection in [.single, .double, .hold] {
            for actionDirection: TTModeDirection in [.north, .east, .west, .south] {
                if let directionModeName = prefs.string(forKey: "TT:mode-\(appDelegate().modeMap.directionName(modeDirection)):\(appDelegate().modeMap.directionName(actionDirection))") {
                    let className = "Turn_Touch_iOS.\(directionModeName)"
                    let modeClass = NSClassFromString(className) as! TTMode.Type
                    let mode = modeClass.init()
                    mode.modeDirection = actionDirection;
                    let modeName = type(of: mode).title()
                    let actionName = mode.actionNameInDirection(actionDirection)
                    if actionName == "TTModeIftttTriggerAction" {
                        let tapType = self.actionOptionValue(TTModeIftttConstants.kIftttTapType,
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

    // MARK: - HTTP Helpers

    private func postJSON(url: String, params: [String: Any], completion: @escaping (Any?) -> Void) async {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            await MainActor.run {
                completion(json)
            }
        } catch {
            print(" ---> IFTTT request error: \(error)")
            await MainActor.run {
                completion(nil)
            }
        }
    }

    private func postFormEncoded(url: String, params: [String: String], completion: @escaping (Any?) -> Void) async {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = params.map { key, value in
            "\(key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
        }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            await MainActor.run {
                completion(json)
            }
        } catch {
            print(" ---> IFTTT request error: \(error)")
            await MainActor.run {
                completion(nil)
            }
        }
    }

}
