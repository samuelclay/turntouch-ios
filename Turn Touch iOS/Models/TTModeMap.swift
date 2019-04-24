//
//  TTModeMap.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox
import Alamofire

class TTModeMap: NSObject {
    
    @objc dynamic var activeModeDirection: TTModeDirection = .no_DIRECTION
    @objc dynamic var selectedModeDirection: TTModeDirection = .no_DIRECTION
    @objc dynamic var inspectingModeDirection: TTModeDirection = .no_DIRECTION
    @objc dynamic var hoverModeDirection: TTModeDirection = .no_DIRECTION
    
    @objc dynamic var tempModeName: String?
    @objc dynamic var openedModeChangeMenu: Bool = false
    @objc dynamic var openedActionChangeMenu: Bool = false
    @objc dynamic var openedAddActionChangeMenu: Bool = false
    
    @objc dynamic var selectedMode: TTMode = TTMode()
    var northMode: TTMode!
    var eastMode: TTMode!
    var westMode: TTMode!
    var southMode: TTMode!
    var singleMode = TTMode(modeDirection: .single)
    var doubleMode = TTModeDouble(modeDirection: .double)
    var holdMode = TTMode(modeDirection: .hold)
    @objc dynamic var tempMode: TTMode!
    
    enum TTButtonAppMode: String {
        case SixteenButtons = "16_buttons"
        case TwelveButtons = "12_buttons"
    }
    
    var batchActions = TTBatchActions()
    
    @objc dynamic var availableModes: [String] = []
    @objc dynamic var availableActions: [String] = []
    @objc dynamic var availableAddModes: [[String: Any]] = []
    @objc dynamic var availableAddActions: [[String: Any]] = []
    
    var audioPlayer: AVAudioPlayer?

    override init() {
        self.availableModes = [
            "TTModePhone",
            "TTModeCamera",
            "TTModeMusic",
            "TTModeHue",
            "TTModeSpotify",
            "TTModeWemo",
            "TTModeSonos",
            "TTModeNest",
//            "TTModeAlarmClock",
            "TTModeBose",
            "TTModeYoga",
            "TTModeCustom",
            "TTModeIfttt",
            "TTModeHomeKit",
        ]
        
        super.init()
        
        self.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "selectedModeDirection")
    }
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            let prefs = UserDefaults.standard
            let original = prefs.integer(forKey: "TT:selectedModeDirection")
            if original != self.selectedModeDirection.rawValue {
                prefs.set(self.selectedModeDirection.rawValue, forKey: "TT:selectedModeDirection")
                print(" ---> Saving pref TT:selectedModeDirection: \(self.selectedModeDirection.rawValue)")
                prefs.synchronize()
            }
        }
    }
    
    // MARK: Actions
    
    func buttonAppMode() -> TTButtonAppMode {
        let prefs = UserDefaults.standard
        
        if let appModePref = prefs.string(forKey: "TT:buttonAppMode"),
            let appMode: TTButtonAppMode = TTButtonAppMode(rawValue: appModePref) {
            return appMode
        }
        
        return .SixteenButtons
    }
    
    func reset() {
        inspectingModeDirection = .no_DIRECTION
        hoverModeDirection = .no_DIRECTION
    }

    func setupModes() {
        let prefs = UserDefaults.standard
        let buttonAppMode = self.buttonAppMode()
        
        for direction: String in ["north", "east", "west", "south"] {
            if let directionModeName = prefs.string(forKey: "TT:\(self.modeRoot()):\(direction)") {
                let className = "Turn_Touch_iOS.\(directionModeName)"
                let modeClass = NSClassFromString(className) as! TTMode.Type
                switch (direction) {
                case "north":
                    northMode = modeClass.init()
                    northMode.modeDirection = buttonAppMode == .SixteenButtons ? .north : self.selectedModeDirection
                case "east":
                    eastMode = modeClass.init()
                    eastMode.modeDirection = buttonAppMode == .SixteenButtons ? .east : self.selectedModeDirection
                case "west":
                    westMode = modeClass.init()
                    westMode.modeDirection = buttonAppMode == .SixteenButtons ? .west : self.selectedModeDirection
                case "south":
                    southMode = modeClass.init()
                    southMode.modeDirection = buttonAppMode == .SixteenButtons ? .south : self.selectedModeDirection
                default:
                    break
                }
            }
        }
    }
    
    func modeRoot() -> String {
        if self.buttonAppMode() == .TwelveButtons {
            switch (self.savedSelectedModeDirection()) {
            case .single:
                return "mode-single"
            case .double:
                return "mode-double"
            case .hold:
                return "mode-hold"
            default:
                break
            }
        }
        
        return "mode"
    }
    
    func savedSelectedModeDirection() -> TTModeDirection {
        let prefs = UserDefaults.standard
        let direction = TTModeDirection(rawValue: prefs.integer(forKey: "TT:selectedModeDirection"))!
        
        if buttonAppMode() == .SixteenButtons {
            if ![.north, .east, .west, .south].contains(direction) {
                return .north
            }
        } else {
            if ![.single, .double, .hold].contains(direction) {
                return .single
            }
        }
        
        return direction
    }
    
    func activateModes() {
        let direction = self.savedSelectedModeDirection()
        self.switchMode(direction)
    }
    
    func activateOneAppMode(_ direction: TTModeDirection) {
        switch (direction) {
        case .north:
            self.selectedMode = self.northMode
        case .east:
            self.selectedMode = self.eastMode
        case .west:
            self.selectedMode = self.westMode
        case .south:
            self.selectedMode = self.southMode
        default:
            break
        }
    }
    
    func activateTimers() {
//        for mode in [northMode, eastMode, westMode, southMode] {
//            if mode.respondsToSelector(#selector("activateTimers")) {
//                mode.activateTimers()
//            }
//        }
    }
    
    func switchMode(_ direction: TTModeDirection, modeChangeType: ModeChangeType = .modeTab) {
        self.activeModeDirection = .no_DIRECTION

        batchActions.deactivate()
        self.selectedMode.deactivate()
        self.reset()

        self.selectedMode = self.modeInDirection(direction)
        self.selectedModeDirection = direction
        
        if [.north, .east, .west, .south, .info].contains(direction) {
            if modeChangeType == .remoteButton {
                self.notifyModeChange(direction: direction)
            }
            self.availableActions = type(of: selectedMode).actions()
            self.selectedMode.modeChangeType = modeChangeType
            self.selectedMode.activate(direction)
            batchActions.assemble(modeDirection: direction)
            self.recordButtonMoment(direction, .button_MOMENT_HELD)
        } else if [.single, .double, .hold].contains(direction) {
            self.setupModes()
            self.northMode.activate(direction)
            self.eastMode.activate(direction)
            self.westMode.activate(direction)
            self.southMode.activate(direction)
            batchActions.assemble(modeDirection: direction)
        } else {
//            let className = "Turn_Touch_iOS.\(modeName)"
//            let modeClass = NSClassFromString(className) as! TTMode.Type
            print(" ---> Can't switch into non-direction mode. Easy fix right here...")
        }
    }
    
    func notifyModeChange(direction: TTModeDirection) {
        let prefs = UserDefaults.standard
        
        var url: URL?
        switch direction {
        case .north:
            url = Bundle.main.url(forResource: "north tone", withExtension: "wav")!
        case .east:
            url = Bundle.main.url(forResource: "east tone", withExtension: "wav")!
        case .west:
            url = Bundle.main.url(forResource: "west tone", withExtension: "wav")!
        case .south:
            url = Bundle.main.url(forResource: "south tone", withExtension: "wav")!
        default:
            url = nil
        }
        
        if prefs.bool(forKey: "TT:pref:sound_on_app_change") {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    print(" ---> Audio active error: \(error.localizedDescription)")
                }
            } catch {
                print(" ---> Audio category error: \(error.localizedDescription)")
            }
            
            do {
                if let audioUrl = url {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioUrl, fileTypeHint: AVFileType.mp3.rawValue)

                    audioPlayer!.prepareToPlay()
                    audioPlayer!.play()
                    audioPlayer!.stop()
                    audioPlayer!.play()
                }
            } catch let error {
                print(" ---> Audio error: \(error.localizedDescription))")
            }
        }
        
        // Doesn't work in background
        //            if prefs.bool(forKey: "TT:pref:sound_on_app_change") {
        //                var soundId: SystemSoundID = 0
        //                AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
        //                AudioServicesPlaySystemSoundWithCompletion(soundId, {
        //                    AudioServicesDisposeSystemSoundID(soundId)
        //                })
        //            }
        
        if prefs.bool(forKey: "TT:pref:vibrate_on_app_change") {
            if #available(iOS 10.0, *) {
                // does nothing on iPhone 6s
                //                    if UIApplication.shared.applicationState == .active {
                //                        let generator = UINotificationFeedbackGenerator()
                //                        generator.notificationOccurred(.success)
                //                    } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                //                    }
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    func runActiveButton() {
        let direction = activeModeDirection
        
        if buttonAppMode() == .TwelveButtons {
            self.switchMode(.single, modeChangeType: .remoteButton)
        }
        
        self.runDirection(direction)
        
        activeModeDirection = .no_DIRECTION
    }
    
    func runDoubleButton(_ direction: TTModeDirection) {
        activeModeDirection = .no_DIRECTION

        if selectedMode.shouldFireImmediateOnPress(direction) {
            return
        }
        
        if buttonAppMode() == .TwelveButtons {
            if !(self.doubleMode.modeOptionValue(TTModeDoubleConstants.TTModeDoubleEnabled) as! Bool) {
                self.switchMode(.single, modeChangeType: .remoteButton)
            } else {
                self.switchMode(.double, modeChangeType: .remoteButton)
            }
        }
        
        selectedMode.runDoubleDirection(direction)
        
        // Batch actions
        let actions = self.selectedModeBatchActions(in: direction)
        for batchAction: TTAction in actions {
            batchAction.mode.runDoubleDirection(direction)
        }
        
        self.recordButtonMoment(direction, .button_MOMENT_DOUBLE)
    }
    
    func runHoldButton(_ direction: TTModeDirection) {
        activeModeDirection = .no_DIRECTION
        
        if self.selectedModeDirection != .hold {
            self.switchMode(.hold, modeChangeType: .remoteButton)
        }

        selectedMode.runHoldDirection(direction)
        
        // Batch actions
        let actions = self.selectedModeBatchActions(in: direction)
        for batchAction: TTAction in actions {
            batchAction.mode.runHoldDirection(direction)
        }
        
        self.recordButtonMoment(direction, .button_MOMENT_DOUBLE)
    }
    
    func runDirection(_ direction: TTModeDirection) {
        if buttonAppMode() == .TwelveButtons || !selectedMode.shouldFireImmediateOnPress(direction) {
//            selectedMode.action = TTAction(actionName: selectedMode.actionNameInDirection(direction), direction: direction)
            selectedMode.runDirection(direction)
        }
        
        // Batch actions
        let batchActions = self.selectedModeBatchActions(in: direction)
        for batchAction in batchActions {
            batchAction.mode.runDirection(direction)
        }
        
        self.vibrate()
        self.recordButtonMoment(direction, .button_MOMENT_PRESSUP)
    }
    
    func vibrate() {
        let prefs = UserDefaults.standard
        if prefs.bool(forKey: "TT:pref:vibrate_on_action") {
            if #available(iOS 10.0, *) {
                // does nothing on iPhone 6s
                //                if UIApplication.shared.applicationState == .active {
                //                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                //                    generator.impactOccurred()
                //                } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                //                }
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    func recordButtonMoment(_ direction: TTModeDirection, _ buttonMoment: TTButtonMoment) {
        let buttonPress = self.momentName(buttonMoment)
        var presses: [[String: Any]] = []
        
        presses.append([
            "app_name": self.selectedMode.nameOfClass,
            "app_direction": self.directionName(self.selectedMode.modeDirection),
            "button_name": self.selectedMode.actionNameInDirection(direction),
            "button_direction": self.directionName(direction),
            "button_moment": buttonPress,
            "batch_action": false,
            ])
        
        let batchActions = self.selectedModeBatchActions(in: direction)
        for batchAction in batchActions {
            presses.append([
                "app_name": batchAction.mode.nameOfClass,
                "app_direction": self.directionName(self.selectedMode.modeDirection),
                "button_name": batchAction.actionName ?? "button",
                "button_direction": self.directionName(direction),
                "button_moment": buttonPress,
                "batch_action": true,
                ])
        }
        
        self.recordUsage(additionalParams: ["button_actions": presses])
    }
    
    func recordUsageMoment(_ moment: String) {
        self.recordUsage(additionalParams: ["moment": moment])
    }
    
    func recordUsage(additionalParams: [String: Any]) {
        let prefs = UserDefaults.standard
        if !prefs.bool(forKey: "TT:pref:share_usage_stats") {
            return
        }
        
        var params = self.deviceAttrs()
        for (k, v) in additionalParams {
            params[k] = v
        }
        
        Alamofire.request("https://turntouch.com/usage/record", method: .post,
                          parameters: params, encoding: JSONEncoding.default).responseJSON
            { response in
//                print(" ---> Usage: \(params) \(response)")
            }
    }
    
    func deviceAttrs() -> [String: Any] {
        let userId = self.userId()
        let deviceId = self.deviceId()
        let deviceName = UIDevice.current.name
        let deviceModel = UIDevice.current.model
        let devicePlatform = UIDevice.current.systemName
        let deviceVersion = UIDevice.current.systemVersion
        let devices = appDelegate().bluetoothMonitor.foundDevices.devices
        var remoteName: String?
        if devices.count >= 1 {
            remoteName = devices[0].nickname
        }
        let params: [String: Any] = [
            "user_id": userId,
            "device_id": deviceId,
            "device_name": deviceName,
            "device_platform": devicePlatform,
            "device_model": deviceModel,
            "device_version": deviceVersion,
            "remote_name": remoteName ?? "",
            ]
        
        return params
    }
    
    // MARK: Batch actions
    
    func provisionTempMode(name: String) {
        tempModeName = name
        let className = "Turn_Touch_iOS.\(name)"
        let modeClass = NSClassFromString(className) as! TTMode.Type
        tempMode = modeClass.init()
        
        var availableAddActions: [[String: Any]] = []
        for action in modeClass.actions() {
            availableAddActions.append(["id": action, "type": TTMenuType.menu_ADD_ACTION])
        }
        
        self.availableAddActions = availableAddActions
    }
    
    func provisionAvailableAddModes() {
        var availableAddModes: [[String: Any]] = []
        for mode in self.availableModes {
            availableAddModes.append(["id": mode, "type": TTMenuType.menu_ADD_MODE])
        }
        self.availableAddModes = availableAddModes
    }
    
    func selectedModeBatchActions(in direction: TTModeDirection) -> [TTAction] {
        return batchActions.batchActions(in: direction)
    }
    
    func addBatchAction(for actionName: String) {
        // Adding batch action using the menu, selecting and inspecting directions
        let prefs = UserDefaults.standard
        let batchKey = self.batchKey()
        var batchActionKeys = self.batchActionKeys()
        let uuid = UUID().uuidString
        let newActionKey = "\(tempMode.nameOfClass):\(actionName):\(uuid[..<uuid.index(uuid.startIndex, offsetBy: 8)])"
        batchActionKeys.append(newActionKey)
        print(" ---> Adding batch action to \(batchKey): \(batchActionKeys)")
        prefs.set(batchActionKeys, forKey: batchKey)
        prefs.synchronize()
        
        batchActions.assemble(modeDirection: self.selectedModeDirection)
        
        tempMode = nil
        tempModeName = nil
        
        self.didChangeValue(forKey: "inspectingModeDirection")
        
        self.recordUsage(additionalParams: ["moment": "change:add-batch-action:\(selectedMode.nameOfClass):\(actionName)"])
    }
    
    func addBatchAction(modeDirection: TTModeDirection, actionDirection: TTModeDirection, modeClassName: String, actionName: String) -> String {
        // Adding batch actions automatically
        let prefs = UserDefaults.standard
        var batchActionKeys = self.batchActionKeys(modeDirection: modeDirection, actionDirection: actionDirection)
        let uuid = UUID().uuidString
        let newActionKey = "\(modeClassName):\(actionName):\(uuid[..<uuid.index(uuid.startIndex, offsetBy: 8)])"
        batchActionKeys.append(newActionKey)
        prefs.set(batchActionKeys, forKey: self.batchKey(modeDirection: modeDirection, actionDirection: actionDirection))
        prefs.synchronize()

        batchActions.assemble(modeDirection: self.selectedModeDirection)
        
        return newActionKey
    }
    
    func removeBatchAction(for batchActionKey: String, silent: Bool = false, actionDirection: TTModeDirection? = nil) {
        let prefs = UserDefaults.standard
        let batchActionKeys = self.batchActionKeys(modeDirection: nil, actionDirection: actionDirection)
        var newBatchActionKeys: [String] = []
        
        for key in batchActionKeys {
            if key != batchActionKey {
                newBatchActionKeys.append(key)
            } else {
                print(" ---> Removing from \(batchActionKeys.count) batch actions in \(String(describing: actionDirection?.rawValue)): \(key)")
                
            }
        }
        
        prefs.set(newBatchActionKeys, forKey: self.batchKey(actionDirection: actionDirection))
        prefs.synchronize()
        
        if !silent {
            batchActions.assemble(modeDirection: self.selectedModeDirection)
            self.didChangeValue(forKey: "inspectingModeDirection")
        }
    }
    
    func batchActionKeys(modeDirection: TTModeDirection? = nil, actionDirection: TTModeDirection? = nil) -> [String] {
        let prefs = UserDefaults.standard
        var batchActionKeys: [String] = []
        
        if let batchActionsPrefs = prefs.object(forKey: self.batchKey(modeDirection: modeDirection, actionDirection: actionDirection)) as? [String] {
            batchActionKeys = batchActionsPrefs
        }
        
        return batchActionKeys
    }
    
    func batchKey(modeDirection: TTModeDirection? = nil, actionDirection: TTModeDirection? = nil) -> String {
        let modeDirectionName = self.directionName(modeDirection ?? selectedModeDirection)
        let actionDirectionName = self.directionName(actionDirection ?? inspectingModeDirection)
        let batchKey = "TT:mode:\(modeDirectionName):action:\(actionDirectionName):batchactions"
        
        print(" ---> batchKey: \(batchKey)")
        return batchKey
    }
    
    // MARK: Changing modes, actions, batch actions
    
    func changeDirection(_ direction: TTModeDirection, toMode modeClassName: String) {
        let prefs = UserDefaults.standard
        let directionName = self.directionName(direction)
        let prefKey = "TT:\(self.modeRoot()):\(directionName)"
        
        prefs.set(modeClassName, forKey: prefKey)
        prefs.synchronize()
        
        self.setupModes()
        self.activateModes()
        if buttonAppMode() == .TwelveButtons {
            self.activateOneAppMode(direction)
        }
    }
    
    func changeDirection(_ direction: TTModeDirection, toAction actionClassName: String) {
        selectedMode.changeDirection(direction, toAction:actionClassName)
    }
    
    // MARK: Direction helpers
    
    func modeInDirection(_ direction: TTModeDirection) -> (TTMode) {
        switch direction {
        case .north:
            return self.northMode
        case .east:
            return self.eastMode
        case .west:
            return self.westMode
        case .south:
            return self.southMode
        case .single:
            return self.singleMode
        case .double:
            return self.doubleMode
        case .hold:
            return self.holdMode
        default:
            return self.northMode
        }
    }
    
    func directionName(_ direction: TTModeDirection) -> String {
        switch direction {
        case .north:
            return "north"
        case .east:
            return "east"
        case .west:
            return "west"
        case .south:
            return "south"
        case .single:
            return "single"
        case .double:
            return "double"
        case .hold:
            return "hold"
        default:
            return ""
        }
    }
    
    func momentName(_ moment: TTButtonMoment) -> String {
        switch moment {
        case .button_MOMENT_PRESSUP:
            return "single"
        case .button_MOMENT_PRESSDOWN:
            return "down"
        case .button_MOMENT_DOUBLE:
            return "double"
        case .button_MOMENT_HELD:
            return "hold"
        default:
            return ""
        }
    }
    
    func toggleInspectingModeDirection(_ direction: TTModeDirection) {
        if self.inspectingModeDirection == direction {
            if self.openedModeChangeMenu {
                self.openedModeChangeMenu = false
            }
            if self.openedActionChangeMenu {
                self.openedActionChangeMenu = false
            }
            if self.openedAddActionChangeMenu {
                self.openedAddActionChangeMenu = false
            }
            self.inspectingModeDirection = .no_DIRECTION
            if buttonAppMode() == .TwelveButtons {
                self.activateModes()
            }
        } else {
            self.inspectingModeDirection = direction
            if buttonAppMode() == .TwelveButtons {
                self.activateOneAppMode(direction)
            }
        }
        
        let modeName = self.selectedMode.nameOfClass
        let actionName = self.selectedMode.actionNameInDirection(self.inspectingModeDirection)
        appDelegate().modeMap.recordUsage(additionalParams: ["moment": "tap:inspect-action:\(modeName):\(actionName)"])
    }
    
    func toggleOpenedActionChangeMenu() {
        self.availableActions = type(of: selectedMode).actions()
        self.openedActionChangeMenu = !self.openedActionChangeMenu
    }

    // MARK: Device info
    
    func userId() -> String {
        var uuid: NSUUID!
        let prefs = UserDefaults.standard
        
        if let uuidString = NSUbiquitousKeyValueStore.default.string(forKey: TTModeIftttConstants.kIftttUserIdKey) {
            uuid = NSUUID(uuidString: uuidString)
            
            prefs.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            prefs.synchronize()
        } else if let uuidString = prefs.string(forKey: TTModeIftttConstants.kIftttUserIdKey) {
            uuid = NSUUID(uuidString: uuidString)
            
            NSUbiquitousKeyValueStore.default.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        } else {
            uuid = NSUUID()
            
            prefs.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            prefs.synchronize()
            
            NSUbiquitousKeyValueStore.default.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttUserIdKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        
        return uuid.uuidString
    }
    
    func deviceId() -> String {
        var uuid: NSUUID!
        let prefs = UserDefaults.standard
        
        if let uuidString = prefs.string(forKey: TTModeIftttConstants.kIftttDeviceIdKey) {
            uuid = NSUUID(uuidString: uuidString)
        } else {
            uuid = NSUUID()
            
            print(" ---> Generating new device ID: \(uuid.uuidString)")
                
            prefs.set(uuid.uuidString, forKey: TTModeIftttConstants.kIftttDeviceIdKey)
            prefs.synchronize()
        }
        
        return uuid.uuidString
    }

    // Mark: Button App Modes
    
    func switchButtonAppMode(_ buttonAppMode: TTButtonAppMode) {
        let prefs = UserDefaults.standard
        
        prefs.set(buttonAppMode.rawValue, forKey: "TT:buttonAppMode")
        prefs.synchronize()
        
        switch buttonAppMode {
        case .SixteenButtons:
            self.selectedModeDirection = .north
        case .TwelveButtons:
            self.selectedModeDirection = .single
        }

        self.setupModes()
        self.activateModes()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
