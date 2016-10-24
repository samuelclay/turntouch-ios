//
//  TTModeHue.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SwiftyHue

enum TTHueState: Int {
    case notConnected
    case connecting
    case bridgeSelect
    case pushlink
    case connected
}

enum TTHueRandomColors: Int {
    case allDifferent
    case someDifferent
    case allSame
}

enum TTHueRandomBrightness: Int {
    case low
    case varied
    case high
}

enum TTHueRandomSaturation: Int {
    case low
    case varied
    case high
}

let MAX_HUE: UInt32 = 65535
let MAX_BRIGHTNESS: UInt32 = 254
let DEBUG_HUE = true

struct TTModeHueConstants {
    static let kRandomColors: String = "randomColors"
    static let kRandomBrightness: String = "randomBrightness"
    static let kRandomSaturation: String = "randomSaturation"
    static let kDoubleTapRandomColors: String = "doubleTapRandomColors"
    static let kDoubleTapRandomBrightness: String = "doubleTapRandomBrightness"
    static let kDoubleTapRandomSaturation: String = "doubleTapRandomSaturation"
    static let kHueScene: String = "hueScene"
    static let kHueRoom: String = "hueRoom"
    static let kDoubleTapHueScene: String = "doubleTapHueScene"
    static let kHueDuration: String = "hueDuration"
    static let kHueDoubleTapDuration: String = "hueDoubleTapDuration"
    static let kHueRecentBridgeId: String = "hueRecentBridgeId"
    static let kHueRecentBridgeIp: String = "hueRecentBridgeIp"
    static let kHueSavedBridges: String = "hueSavedBridges"
    static let kHueSeenRooms: String = "hueSeenRooms"
}

protocol TTModeHueDelegate {
    func changeState(_ hueState: TTHueState, mode: TTModeHue, message: Any?)
}

class TTModeHue: TTMode, BridgeFinderDelegate, BridgeAuthenticatorDelegate {
    
//    static var phHueSdk: PHHueSDK!
    static var hueSdk: SwiftyHue!
    static var reachability: Reachability!
    static var hueState: TTHueState = TTHueState.notConnected
    static var sceneCreationCounter: Int = 0
    static var foundScenes: [String] = []
//    var bridgeSearch: PHBridgeSearching!
    var bridgeFinder: BridgeFinder!
    var bridgeAuthenticator: BridgeAuthenticator!
    var latestBridge: HueBridge?
    var delegate: TTModeHueDelegate?
    var bridgeToken: Int = 0
    var bridgesTried: [String] = []
    var foundBridges: [HueBridge] = [] // Only used during bridge choosing

    required init() {
        super.init()
        
        self.initializeHue()
        self.watchReachability()
    }
    
    deinit {
//        self.disableLocalHeartbeat()
//        TTModeHue.phHueSdk.stop()
    }
    
    override func activate() {
        self.removeObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveHeartbeat), name: NSNotification.Name(rawValue: ResourceCacheUpdateNotification.configUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveHeartbeat), name: NSNotification.Name(rawValue: ResourceCacheUpdateNotification.lightsUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveHeartbeat), name: NSNotification.Name(rawValue: ResourceCacheUpdateNotification.scenesUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveHeartbeat), name: NSNotification.Name(rawValue: ResourceCacheUpdateNotification.groupsUpdated.rawValue), object: nil)
    }

    override func deactivate() {
        self.removeObservers()
    }
    
    func initializeHue(_ force: Bool = false) {
        if TTModeHue.hueSdk != nil && !force {
            return;
        }
        
        TTModeHue.hueSdk = SwiftyHue()
//        TTModeHue.phHueSdk = PHHueSDK()
//        TTModeHue.phHueSdk.startUp()
//        TTModeHue.phHueSdk.enableLogging(false)
        
        self.connectToBridge(reset: true)
//        if let notificationManager = PHNotificationManager.default() {
//            
//            // The SDK will send the following notifications in response to events:
//            //
//            // - LOCAL_CONNECTION_NOTIFICATION
//            // This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
//            //
//            // - NO_LOCAL_CONNECTION_NOTIFICATION
//            // This notification will notify that there is no connection with the bridge
//            //
//            // - NO_LOCAL_AUTHENTICATION_NOTIFICATION
//            // This notification will notify that there is no authentication against the bridge
//            notificationManager.register(self, with: #selector(self.localConnection) , forNotification: LOCAL_CONNECTION_NOTIFICATION)
//            notificationManager.register(self, with: #selector(self.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
//            notificationManager.register(self, with: #selector(self.notAuthenticated), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION)
//            
//            notificationManager.register(self, with: #selector(self.authenticationSuccess), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
//            notificationManager.register(self, with: #selector(self.authenticationFailed), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
//            notificationManager.register(self, with: #selector(self.noLocalConnection), forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
//            notificationManager.register(self, with: #selector(self.noLocalBridge), forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
//            notificationManager.register(self, with: #selector(self.buttonNotPressed(notification:)), forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
//        }
        
        TTModeHue.hueState = .connecting
        self.delegate?.changeState(TTModeHue.hueState, mode:self, message:"Connecting...")
        
        // The local heartbeat is a regular timer event in the SDK. Once enabled the SDK regular collects the current state of resources managed by the bridge into the Bridge Resources Cache
//        self.enableLocalHeartbeat()
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Mode
    
    override class func title() -> String {
        return "Hue"
    }
    
    override class func subtitle() -> String {
        return "Lights and scenes"
    }
    
    override class func imageName() -> String {
        return "mode_hue.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeHueSceneEarlyEvening",
                "TTModeHueSceneLateEvening",
                "TTModeHueSceneMorning",
                "TTModeHueSceneNightLight",
                "TTModeHueSceneCustom",
                "TTModeHueSleep",
                "TTModeHueOff",
                "TTModeHueRandom"]
    }
    
    func titleTTModeHueSceneEarlyEvening() -> String {
        return "Early evening"
    }
    
    func doubleTitleTTModeHueSceneEarlyEvening() -> String {
        return "Early evening 2"
    }
    
    func titleTTModeHueSceneLateEvening() -> String {
        return "Late evening"
    }
    
    func doubleTitleTTModeHueSceneLateEvening() -> String {
        return "Late evening 2"
    }
    
    func titleTTModeHueSceneMorning() -> String {
        return "Morning"
    }
    
    func doubleTitleTTModeHueSceneMorning() -> String {
        return "Morning 2"
    }
    
    func titleTTModeHueSceneNightLight() -> String {
        return "Night light"
    }
    
    func doubleTitleTTModeHueSceneNightLight() -> String {
        return "Night light 2"
    }
    
    func titleTTModeHueSceneCustom() -> String {
        return "Custom scene"
    }
    
    func doubleTitleTTModeHueSceneCustom() -> String {
        return "Custom scene 2"
    }
    
    func titleTTModeHueSleep() -> String {
        return "Sleep"
    }
    
    func doubleTitleTTModeHueSleep() -> String {
        return "Sleep fast"
    }
    
    func titleTTModeHueOff() -> String {
        return "Lights off"
    }
    
    func titleTTModeHueRandom() -> String {
        return "Random"
    }
    
    func doubleTitleTTModeHueRandom() -> String {
        return "Random 2"
    }
    
    // MARK: Action images
    
    func imageTTModeHueSceneEarlyEvening() -> String {
        return "hue_sunset.png"
    }
    
    func imageTTModeHueSceneLateEvening() -> String {
        return "hue_evening.png"
    }
    
    func imageTTModeHueSceneMorning() -> String {
        return "hue_evening.png"
    }
    
    func imageTTModeHueSceneNightLight() -> String {
        return "hue_evening.png"
    }
    
    func imageTTModeHueSceneCustom() -> String {
        return "hue_evening.png"
    }
    
    func imageTTModeHueSleep() -> String {
        return "hue_sleep.png"
    }
    
    func imageTTModeHueOff() -> String {
        return "hue_sleep.png"
    }
    
    func imageTTModeHueRandom() -> String {
        return "hue_random.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeHueSceneEarlyEvening"
    }
    
    override func defaultEast() -> String {
        return "TTModeHueSceneLateEvening"
    }
    
    override func defaultWest() -> String {
        return "TTModeHueRandom"
    }
    
    override func defaultSouth() -> String {
        return "TTModeHueSleep"
    }
    
    // MARK: Action methods
    
    func runScene(sceneName: String, doubleTap: Bool) {
        if TTModeHue.hueState != .connected {
            self.connectToBridge()
//            return
        }
        
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        let sceneIdentifier: String? = self.action.optionValue(doubleTap ? TTModeHueConstants.kDoubleTapHueScene : TTModeHueConstants.kHueScene) as? String
        let roomIdentifier: String? = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String
        
        if let sceneIdentifier = sceneIdentifier {
            bridgeSendAPI.recallSceneWithIdentifier(sceneIdentifier, inGroupWithIdentifier: roomIdentifier ?? "0") { (errors: [Error]?) in
                print(" ---> Scene change: \(sceneIdentifier) (\(errors))")
            }
        }
    }
    
    func runTTModeHueSceneEarlyEvening() {
        self.runScene(sceneName: "TTModeHueSceneEarlyEvening", doubleTap: false)
    }
    
    func doubleRunTTModeHueSceneEarlyEvening() {
        self.runScene(sceneName: "TTModeHueSceneEarlyEvening", doubleTap: true)
    }
    
    func runTTModeHueSceneLateEvening() {
        self.runScene(sceneName: "TTModeHueSceneLateEvening", doubleTap: false)
    }
    
    func doubleRunTTModeHueSceneLateEvening() {
        self.runScene(sceneName: "TTModeHueSceneLateEvening", doubleTap: true)
    }
    
    func runTTModeHueSceneMorning() {
        self.runScene(sceneName: "TTModeHueSceneMorning", doubleTap: false)
    }
    
    func doubleRunTTModeHueSceneMorning() {
        self.runScene(sceneName: "TTModeHueSceneMorning", doubleTap: true)
    }
    
    func runTTModeHueSceneNightLight() {
        self.runScene(sceneName: "TTModeHueSceneNightLight", doubleTap: false)
    }
    
    func doubleRunTTModeHueSceneNightLight() {
        self.runScene(sceneName: "TTModeHueSceneNightLight", doubleTap: true)
    }
    
    func runTTModeHueSceneCustom() {
        self.runScene(sceneName: "TTModeHueSceneCustom", doubleTap: false)
    }
    
    func doubleRunTTModeHueSceneCustom() {
        self.runScene(sceneName: "TTModeHueSceneCustom", doubleTap: true)
    }
    
    func runTTModeHueOff() {
        //    NSLog(@"Running scene off... %d", direction);
        self.runTTModeHueSleep(duration: 1)
    }
    
    func runTTModeHueSleep() {
        let sceneDuration: Int = self.action.mode.actionOptionValue(TTModeHueConstants.kHueDuration, actionName: "TTModeHueSleep", direction: self.action.direction) as! Int
        self.runTTModeHueSleep(duration: sceneDuration)
    }
    
    func doubleRunTTModeHueSleep() {
        //    NSLog(@"Running scene off... %d", direction);
        let sceneDuration: Int = self.action.mode.actionOptionValue(TTModeHueConstants.kHueDoubleTapDuration, actionName: "TTModeHueSleep", direction: self.action.direction) as! Int
        self.runTTModeHueSleep(duration: sceneDuration)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSceneEarlyEvening() -> NSNumber {
        return NSNumber(value: false)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSceneLateEvening() -> NSNumber {
        return NSNumber(value: false)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSleep() -> NSNumber {
        return NSNumber(value: true)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueRandom() -> NSNumber {
        return NSNumber(value: false)
    }
    
    func runTTModeHueSleep(duration sceneDuration: Int) {
        if TTModeHue.hueState != .connected {
            self.connectToBridge()
            return
        }

        //    NSLog(@"Running scene off... %d", direction);
        let cache = TTModeHue.hueSdk.resourceCache
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        let sceneTransition = sceneDuration * 10
        
        guard let lights = cache?.lights else {
            print(" ---> Not running sleep, no lights found")
            return
        }
        
        for (_, light) in lights {
            var lightState = LightState()
            lightState.on = false
            lightState.brightness = 0
            
            DispatchQueue.main.async {
                bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: lightState, transitionTime: sceneTransition, completionHandler: { (errors) in
                    print(" ---> Sleep light in \(sceneTransition): \(errors)")
                })
            }
        }
    }
    
    func runTTModeHueRandom() {
        self.runTTModeHueRandom(doubleTap: false)
    }
    
    func doubleRunTTModeHueRandom() {
        self.runTTModeHueRandom(doubleTap: true)
    }
    
    func runTTModeHueRandom(doubleTap: Bool) {
        if TTModeHue.hueState != .connected {
            self.connectToBridge()
            return
        }

        //    NSLog(@"Running scene off... %d", direction);
        let cache = TTModeHue.hueSdk.resourceCache
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        let randomColors = TTHueRandomColors(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomColors : TTModeHueConstants.kRandomColors)) as! Int))
        let randomBrightnesses = TTHueRandomBrightness(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomBrightness : TTModeHueConstants.kRandomBrightness)) as! Int))
        let randomSaturation = TTHueRandomSaturation(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomSaturation : TTModeHueConstants.kRandomSaturation)) as! Int))
        let randomColor: Int = Int(arc4random_uniform(MAX_HUE))
        
        guard let lights = cache?.lights else {
            print(" ---> Not running random, no lights found")
            return
        }
        
        for (_, light) in lights {
            var lightState = LightState()
            
            if (randomColors == .allSame) || (randomColors == .someDifferent && arc4random() % 10 > 5) {
                lightState.hue = randomColor
            } else {
                lightState.hue = Int(arc4random() % MAX_HUE)
            }
            
            if randomBrightnesses == .low {
                lightState.brightness = Int(arc4random() % 100)
            } else if randomBrightnesses == .varied {
                lightState.brightness = Int(arc4random() % MAX_BRIGHTNESS)
            } else if randomBrightnesses == .high {
                lightState.brightness = Int(254)
            }
            
            if randomSaturation == .low {
                lightState.saturation = Int(174)
            } else if randomSaturation == .varied {
                lightState.saturation = Int(254 - Int(arc4random_uniform(80)))
            } else if randomSaturation == .high {
                lightState.saturation = Int(254)
            }
            
            DispatchQueue.main.async {
                bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: lightState, completionHandler: { (errors) in
                    print(" ---> Finished random: \(errors)")
                })
            }
        }
    }
    
    // MARK: - Hue Bridge
    
    
    func connectToBridge(reset: Bool = false) {
        TTModeHue.hueState = .connecting
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: "Connecting to Hue...")

        if reset {
            bridgesTried = []
        }
        
        let prefs = UserDefaults.standard
        let savedBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]] ?? []
        
        var bridgeUntried = false
        for savedBridge in savedBridges {
            if bridgesTried.contains(savedBridge["serialNumber"]!) {
                continue
            }
            
            let bridge = HueBridge(ip: savedBridge["ip"]!,
                                   deviceType: savedBridge["deviceType"]!,
                                   friendlyName: savedBridge["friendlyName"]!,
                                   modelDescription: savedBridge["modelDescription"]!,
                                   modelName: savedBridge["modelName"]!,
                                   serialNumber: savedBridge["serialNumber"]!,
                                   UDN: savedBridge["UDN"]!,
                                   icons: [])
            bridgeUntried = true
            latestBridge = bridge
            bridgesTried.append(savedBridge["serialNumber"]!)
            
            if DEBUG_HUE {
                print(" ---> Connecting to bridge: \(savedBridge)")
            }
            if let username = savedBridge["username"] {
                self.authenticateBridge(username: username)
            } else {
                // New bridge hasn't been pushlinked yet
                bridgeAuthenticator = BridgeAuthenticator(bridge: bridge,
                                                          uniqueIdentifier: "TurnTouchHue#\(UIDevice.current.name)",
                                                          pollingInterval: 1,
                                                          timeout: 7)
                bridgeAuthenticator.delegate = self
                bridgeAuthenticator.start()
            }
            
            break
        }
        
        if !bridgeUntried {
            self.findBridges()
        }
    }
    
    func findBridges() {
        TTModeHue.hueState = .connecting
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: "Searching for a Hue bridge...")

        bridgeFinder = BridgeFinder()
        bridgeFinder.delegate = self
        bridgeFinder.start()
    }
    
    func watchReachability() {
        if TTModeHue.reachability != nil {
            return
        }
        
        TTModeHue.reachability = Reachability()
        
        TTModeHue.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if TTModeHue.hueState != .connected {
                    print(" ---> Reachable, re-connecting to Hue...")
                    self.connectToBridge(reset: true)
                }
            }
        }
        
        TTModeHue.reachability.whenUnreachable = { reachability in
            if TTModeHue.hueState != .connected {
                print(" ---> Unreachable, not connected")
            }
        }
        
        do {
            try TTModeHue.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func bridgeFinder(_ finder: BridgeFinder, didFinishWithResult bridges: [HueBridge]) {
        if bridges.count > 0 {
            TTModeHue.hueState = .bridgeSelect
            foundBridges = bridges
            self.delegate?.changeState(TTModeHue.hueState, mode: self, message: nil)
        } else {
            self.showNoBridgesFoundDialog()
        }
    }
    
    func bridgeSelected(_ bridge: HueBridge) {
        print(" ---> Selected bridge: \(bridge)")
        let prefs = UserDefaults.standard

        latestBridge = bridge
        self.saveRecentBridge()
        prefs.synchronize()

        self.connectToBridge(reset: true)
    }

    
    func delayReconnectToFoundBridges() {
//        let prefs = UserDefaults.standard
//        let savedBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]]
//
//        if let bridgeCount = savedBridges?.count, bridgeCount > 0 {
//            // Try again if bridges known
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10), execute: {
                if TTModeHue.hueState != .connected {
                    self.connectToBridge()
                }
            })
//        }
    }

    func showNoConnectionDialog() {
        NSLog(" ---> Connection to bridge lost")
        TTModeHue.hueState = .notConnected
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: "Connection to Hue bridge lost")
    }

    func showNoBridgesFoundDialog() {
        // Insert retry logic here
        NSLog(" ---> Could not find bridge")
        TTModeHue.hueState = .notConnected
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: "Could not find any Hue bridges")
    }

    // MARK: - Hue Authenticator
    
    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFinishAuthentication username: String) {
        self.authenticateBridge(username: username)
    }
    
    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFailWithError error: NSError) {
        self.connectToBridge()
    }
    
    func bridgeAuthenticatorDidTimeout(_ authenticator: BridgeAuthenticator) {
        NSLog(" ---> Pushlink button not pressed within 30 sec")
        
        // Remove server from saved servers so it isn't automatically reconnected
        if let serialNumber = latestBridge?.serialNumber {
            self.removeSavedBridge(serialNumber: serialNumber)
        }
        
        TTModeHue.hueState = .notConnected
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: "Pushlink button not pressed within 30 seconds")
    }
    
    func bridgeAuthenticatorRequiresLinkButtonPress(_ authenticator: BridgeAuthenticator, secondsLeft: TimeInterval) {
        //        var dict = notification.userInfo!
        //        let progressPercentage: Int = (dict["progressPercentage"] as! Int)
        TTModeHue.hueState = .pushlink
        let progress = Int(secondsLeft * (100/30.0))
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: progress)
    }
    
    func authenticateBridge(username: String) {
        if TTModeHue.hueState != .connected {
            TTModeHue.hueState = .connected
            self.saveRecentBridge(username: username)
            self.receiveHeartbeat()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.startHueHeartbeat(username: username)
            }
        }
    }
    
    func updateHueConfig() {
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: nil)
        self.ensureScenes()
        self.ensureRooms()
        self.ensureScenesSelected()
    }
    
    func receiveHeartbeat() {
        let cache = TTModeHue.hueSdk.resourceCache
        
        var waitingOn: [String] = []
        if cache?.scenes == nil || cache?.scenes.count == 0 {
            waitingOn.append("scenes")
        }
        if cache?.groups == nil || cache?.groups.count == 0 {
            waitingOn.append("groups")
        }
        if cache?.bridgeConfiguration == nil {
            waitingOn.append("config")
        }
        if cache?.lights == nil || cache?.lights.count == 0 {
            waitingOn.append("lights")
        }
        
        if waitingOn.count == 0 {
            self.updateHueConfig()

            if DEBUG_HUE {
                print(" ---> Done with heartbeat")
            }
            TTModeHue.hueSdk.stopHeartbeat()
        } else {
            if DEBUG_HUE {
                print(" ---> Still waiting on \(waitingOn.joined(separator: ", "))")
            }
        }
    }
    
    func saveRecentBridge(username: String? = nil) {
        let prefs = UserDefaults.standard
        
        guard let latestBridge = latestBridge else {
            print(" ---> ERROR: No latest bridge? How did we get here?")
            return
        }
        bridgesTried = []
        
        var foundBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]] ?? []
        var oldIndex: Int = -1
        var oldBridge: [String: String]?
        for (i, bridge) in foundBridges.enumerated() {
            if bridge["serialNumber"] == latestBridge.serialNumber {
                oldIndex = i
                oldBridge = bridge
            }
        }
        
        if oldIndex != -1 {
            foundBridges.remove(at: oldIndex)
        }
        var newBridge = ["ip": latestBridge.ip,
                         "deviceType": latestBridge.deviceType,
                         "friendlyName": latestBridge.friendlyName,
                         "modelDescription": latestBridge.modelDescription,
                         "modelName": latestBridge.modelName,
                         "serialNumber": latestBridge.serialNumber,
                         "UDN": latestBridge.UDN]
        if username != nil {
            newBridge["username"] = username
        } else if let username = oldBridge?["username"] {
            newBridge["username"] = username
        }
        foundBridges.insert(newBridge, at: 0)
        
        prefs.set(foundBridges, forKey: TTModeHueConstants.kHueSavedBridges)
        prefs.synchronize()
        
        if DEBUG_HUE {
            print(" ---> Saved bridges (username: \(username)): \(foundBridges)")
        }
    }
    
    func removeSavedBridge(serialNumber: String) {
        let prefs = UserDefaults.standard
        
        var foundBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]] ?? []
        foundBridges = foundBridges.filter({ (bridge) -> Bool in
            bridge["serialNumber"] != serialNumber
        })
        
        prefs.set(foundBridges, forKey: TTModeHueConstants.kHueSavedBridges)
        prefs.synchronize()
        
        print(" ---> Removed bridge \(serialNumber): \(foundBridges)")
    }
    
    func startHueHeartbeat(username: String) {
        guard let latestBridge = latestBridge else {
            print(" ---> Error: No latest bridge...")
            return
        }
        
        let bridgeAccessConfig = BridgeAccessConfig(bridgeId: latestBridge.serialNumber,
                                                    ipAddress: latestBridge.ip,
                                                    username: username)
        
        TTModeHue.hueSdk.setBridgeAccessConfig(bridgeAccessConfig)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .lights)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .groups)
//        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .rules)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .scenes)
//        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .schedules)
//        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .sensors)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .config)
        
        TTModeHue.hueSdk.startHeartbeat()
    }
    
    // MARK: - Scenes and Rooms
    
    func ensureScenes(force: Bool = false) {
        let cache = TTModeHue.hueSdk.resourceCache
        
        guard let scenes = cache?.scenes, let _ = cache?.lights, let _ = cache?.groups else {
            print(" ---> Scenes/lights/rooms not ready yet for scene creation")
            return
        }
        if scenes.count == 0 {
            print(" ---> Scenes not counted yet")
            return
        }
        if TTModeHue.sceneCreationCounter > 0 {
            print(" ---> Not ensuring scenes, already on it")
            return
        }
        
        if force {
            self.deleteScenes()
        }
        
        // Collect scene ids to check against
        TTModeHue.foundScenes = []
        for (_, scene) in scenes {
            TTModeHue.foundScenes.append(scene.identifier)
        }
        
        self.ensureScene(sceneName: "TTModeHueSceneEarlyEvening", moment: .button_MOMENT_PRESSUP, force: force) { (light: Light, index: Int) in
            var lightState = LightState()
            lightState.on = true
            let point = HueUtilities.calculateXY(UIColor(red: 235/255.0, green: 206/255.0, blue: 146/255.0, alpha: 1), forModel: light.modelId)
            lightState.xy = [Float(point.x), Float(point.y)]
            lightState.brightness = Int(MAX_BRIGHTNESS)
            lightState.saturation = Int(MAX_BRIGHTNESS)
            return lightState
        }
        
        self.ensureScene(sceneName: "TTModeHueSceneEarlyEvening", moment: .button_MOMENT_DOUBLE, force: force) { (light: Light, index: Int) in
            var lightState = LightState()
            lightState.on = true
            var point = HueUtilities.calculateXY(UIColor(red: 245/255.0, green: 176/255.0, blue: 116/255.0, alpha: 1), forModel: light.modelId)
            if index % 3 == 2 {
                point = HueUtilities.calculateXY(UIColor(red: 44/255.0, green: 56/255.0, blue: 225/255.0, alpha: 1), forModel: light.modelId)
            }
            lightState.xy = [Float(point.x), Float(point.y)]
            lightState.brightness = Int(200)
            lightState.saturation = Int(MAX_BRIGHTNESS)
            return lightState
        }
        
        self.ensureScene(sceneName: "TTModeHueSceneLateEvening", moment: .button_MOMENT_PRESSUP, force: force) { (light: Light, index: Int) in
            var lightState = LightState()
            lightState.on = true
            let point = HueUtilities.calculateXY(UIColor(red: 95/255.0, green: 76/255.0, blue: 36/255.0, alpha: 1), forModel: light.modelId)
            lightState.xy = [Float(point.x), Float(point.y)]
            lightState.brightness = Int(MAX_BRIGHTNESS)
            lightState.saturation = Int(MAX_BRIGHTNESS)
            return lightState
        }
        
        self.ensureScene(sceneName: "TTModeHueSceneLateEvening", moment: .button_MOMENT_DOUBLE, force: force) { (light: Light, index: Int) in
            var lightState = LightState()
            lightState.on = true
            var point = HueUtilities.calculateXY(UIColor(red: 145/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1), forModel: light.modelId)
            lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(6/10.0))
            if index % 3 == 1 {
                point = HueUtilities.calculateXY(UIColor(red: 134/255.0, green: 56/255.0, blue: 205/255.0, alpha: 1), forModel: light.modelId)
                lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(8/10.0))
            }
            lightState.xy = [Float(point.x), Float(point.y)]
            lightState.saturation = Int(MAX_BRIGHTNESS)
            return lightState
        }
        
//        if !foundScenes.contains("TT-ee-2") || force {
//            let scene: PHScene = PHScene()
//            scene.name = "Early Evening 2"
//            scene.identifier = "TT-ee-2"
//            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
//            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
////                print("Hue:EE2 scene: \(errors)")
//                if let lights = cache?.lights {
//                    for (i, (key: _, value: value)) in lights.enumerated() {
//                        let light = value as! PHLight
//                        let lightState = PHLightState()
//                        lightState.on = NSNumber(booleanLiteral: true)
//                        lightState.alert = PHLightAlertMode.init(0)
//                        var point = PHUtilities.calculateXY(UIColor(red: 245/255.0, green: 176/255.0, blue: 116/255.0, alpha: 1), forModel: light.modelNumber)
//                        if i % 3 == 2 {
//                            point = PHUtilities.calculateXY(UIColor(red: 44/255.0, green: 56/255.0, blue: 225/255.0, alpha: 1), forModel: light.modelNumber)
//                        }
//                        lightState.x = NSNumber(value: Float(point.x))
//                        lightState.y = NSNumber(value: Float(point.y))
//                        lightState.brightness = NSNumber(value: 200)
//                        lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
//                        bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
//    //                        print("Hue:EE2 scene: \(errors)")
//                            self.delegate?.changeState(self.hueState, mode: self, message: nil)
//                        })
//                    }
//                }
//            })
//        }
//        
//        if !foundScenes.contains("TT-le-1") || force {
//            let scene: PHScene = PHScene()
//            scene.name = "Late Evening"
//            scene.identifier = "TT-le-1"
//            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
//            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
////                print("Hue:LE1 scene: \(errors)")
//                if let lights = cache?.lights {
//                    for (_, value) in lights {
//                        let light = value as! PHLight
//                        let lightState = PHLightState()
//                        lightState.on = NSNumber(booleanLiteral: true)
//                        lightState.alert = PHLightAlertMode.init(0)
//                        let point = PHUtilities.calculateXY(UIColor(red: 95/255.0, green: 76/255.0, blue: 36/255.0, alpha: 1), forModel: light.modelNumber)
//                        lightState.x = NSNumber(value: Float(point.x))
//                        lightState.y = NSNumber(value: Float(point.y))
//                        lightState.brightness = NSNumber(value: Int(Double(MAX_BRIGHTNESS)*(6/10.0)))
//                        lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
//                        bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
//    //                        print("Hue:LE1 scene: \(errors)")
//                            self.delegate?.changeState(self.hueState, mode: self, message: nil)
//                        })
//                    }
//                }
//            })
//        }
//        
//        if !foundScenes.contains("TT-le-2") || force {
//            let scene: PHScene = PHScene()
//            scene.name = "Late Evening 2"
//            scene.identifier = "TT-le-2"
//            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
//            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
////                print("Hue:LE2 scene: \(errors)")
//                if let lights = cache?.lights {
//                    for (i, (key: _, value: value)) in lights.enumerated() {
//                        let light = value as! PHLight
//                        let lightState = PHLightState()
//                        lightState.on = NSNumber(value: true)
//                        lightState.alert = PHLightAlertMode.init(0)
//                        var point = PHUtilities.calculateXY(UIColor(red: 145/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1), forModel: light.modelNumber)
//                        lightState.brightness = NSNumber(value: Int(Double(MAX_BRIGHTNESS)*(6/10.0)))
//                        if i % 3 == 2 {
//                            point = PHUtilities.calculateXY(UIColor(red: 134/255.0, green: 56/255.0, blue: 205/255.0, alpha: 1), forModel: light.modelNumber)
//                            lightState.brightness = NSNumber(value: Int(Double(MAX_BRIGHTNESS)*(8/10.0)))
//                        }
//                        lightState.x = NSNumber(value: Float(point.x))
//                        lightState.y = NSNumber(value: Float(point.y))
//                        lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
//                        bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
//    //                        print("Hue:LE2 scene: \(errors)")
//                            self.delegate?.changeState(self.hueState, mode: self, message: nil)
//                        })
//                    }
//                }
//            })
//        }
//
//        if !foundScenes.contains("TT-all-off") || force {
//            let scene = PartialScene(json: <#T##JSON#>)
//            scene.
//            scene.name = "All Lights Off"
//            scene.identifier = "TT-all-off"
//            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
//            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
//                print("Hue:SceneOff scene: \(errors)")
//                for (_, value) in (cache?.lights)! {
//                    let light = value as! PHLight
//                    let lightState: PHLightState = light.lightState
//                    lightState.on = NSNumber(booleanLiteral: true)
//                    lightState.alert = PHLightAlertMode.init(0)
//                    bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
//                        print("Hue:SceneOff light: \(errors)")
//                        self.delegate?.changeState(self.hueState, mode: self, message: nil)
//                    })
//                }
//            })
//        }
//
//        if !foundScenes.contains("TT-loop") || force {
//            let scene: PHScene = PHScene()
//            scene.name = "Color loop"
//            scene.identifier = "TT-loop"
//            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
//            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
////                print("Hue:Loop scene: \(errors)")
//                for (_, value) in (cache?.lights)! {
//                    let light = value as! PHLight
//                    let lightState: PHLightState = PHLightState()
//                    lightState.on = NSNumber(booleanLiteral: true)
//                    lightState.alert = PHLightAlertMode.init(0)
//                    lightState.effect = EFFECT_COLORLOOP
//                    bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
////                        print("Hue:Loop light: \(errors)")
//                        self.delegate?.changeState(self.hueState, mode: self, message: nil)
//                    })
//                }
//            })
//        }

    }
    
    func ensureScene(sceneName: String, moment: TTButtonMoment, force: Bool, lightsHandler: @escaping ((_ light: Light, _ index: Int) -> (LightState))) {
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        let cache = TTModeHue.hueSdk.resourceCache

        guard let lights = cache?.lights, let rooms = cache?.groups else {
            print(" ---> Scenes/lights/rooms not ready yet for scene creation")
            return
        }

        for (_, room) in rooms {
            let sceneIdentifier = self.sceneForAction(sceneName, actionRoom: room.identifier, moment: moment)
            let roomLights = room.lightIdentifiers ?? []
            if sceneIdentifier != nil {
                if TTModeHue.foundScenes.contains(sceneIdentifier!) {
                    if !force {
                        continue
                    }
                }
            } else {
                print(" ---> Scene not found: \(sceneName) [\(roomLights)] \(TTModeHue.foundScenes)")
            }
            
            let sceneTitle = self.titleForAction(sceneName, buttonMoment: moment)
            TTModeHue.sceneCreationCounter += 1
            bridgeSendAPI.createSceneWithName(sceneTitle, includeLightIds: roomLights, completionHandler: { (sceneIdentifier, errors) in
                TTModeHue.sceneCreationCounter -= 1
                guard let sceneIdentifier = sceneIdentifier else {
                    print(" ---> Error: missing scene identifier")
                    return
                }
                print(" ---> Created scene \(sceneTitle): [\(roomLights)] \(sceneIdentifier)")
                
                TTModeHue.hueSdk.stopHeartbeat()
                TTModeHue.hueSdk.startHeartbeat()
                
                for (index, light) in lights.values.enumerated() {
                    if !roomLights.contains(light.identifier) {
                        continue
                    }
                    let lightState = lightsHandler(light, index)
                    bridgeSendAPI.updateLightStateInScene(sceneIdentifier, lightIdentifier: light.identifier, withLightState: lightState, completionHandler: { (errors) in
                        print(" ---> Hue: \(sceneName) scene in room \(sceneIdentifier)/\(light.identifier): \(lightState) \(errors)")
                        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: nil)
                    })
                }
            })
        }
    }
    
    func deleteScenes() {
        let cache = TTModeHue.hueSdk.resourceCache
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        guard let scenes = cache?.scenes else {
            return
        }
        
        var sceneTitles: [String] = []
        let sceneNames = TTModeHue.actions()
        for sceneName in sceneNames {
            let title = self.titleForAction(sceneName, buttonMoment: .button_MOMENT_PRESSUP)
            sceneTitles.append(title)
            let doubleTitle = self.titleForAction(sceneName, buttonMoment: .button_MOMENT_DOUBLE)
            sceneTitles.append(doubleTitle)
        }
        
        for (_, scene) in scenes {
            if sceneTitles.contains(scene.name) {
                bridgeSendAPI.removeSceneWithId(scene.identifier, completionHandler: { (errors) in
                    print(" ---> Removed \(scene.name) (\(scene.identifier)) [\(scene.lightIdentifiers!)])")
                })
            }
        }
    }
    
    func ensureRooms() {
        for direction: TTModeDirection in [.north, .east, .west, .south] {
            self.ensureRoomSelected(in: direction)
        }
    }
    
    func ensureRoomSelected(in direction: TTModeDirection) {
        let sameMode = appDelegate().modeMap.modeInDirection(self.modeDirection).nameOfClass == self.nameOfClass
        if !sameMode {
            return
        }
        
        let cache = TTModeHue.hueSdk.resourceCache
        guard let rooms = cache?.groups else {
            print(" ---> Rooms not ready yet for room creation")
            return
        }
        if rooms.count == 0 {
            print(" ---> Rooms not counted yet for room creation")
            return
        }
        
        // Cycle through action and batch actions, ensuring all have a room, single tap scene, and double tap, adding batch actions for rooms that aren't used
        let actionName = self.actionNameInDirection(direction)
        var actionRoom = self.actionOptionValue(TTModeHueConstants.kHueRoom, actionName: actionName, direction: direction) as? String
        var seenRooms: [String] = self.actionOptionValue(TTModeHueConstants.kHueSeenRooms, actionName: actionName, direction: direction) as? [String] ?? []

        var unseenRooms: [Group] = []
        for (_, room) in rooms {
            if !seenRooms.contains(room.identifier) {
                unseenRooms.append(room)
            }
        }
        
        // If the current action has no room set and is a Hue action, set the room
        if actionRoom == nil && unseenRooms.count > 0 {
            let unseenRoom = unseenRooms[0]
            seenRooms.append(unseenRoom.identifier)
            actionRoom = unseenRoom.identifier
            print(" ---> Setting \(actionName)-\(appDelegate().modeMap.directionName(direction)) room to \(unseenRoom.name)/\(unseenRoom.identifier)")
            self.changeActionOption(TTModeHueConstants.kHueRoom, to: unseenRoom.identifier, direction: direction)
            self.changeActionOption(TTModeHueConstants.kHueSeenRooms, to: seenRooms, direction: direction)
        }
        
        // Sanity check for existing batch actions, ensuring none of them are already using the room
        for batchAction in appDelegate().modeMap.batchActions.batchActions(in: direction) {
            if let roomIdentifier = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kHueRoom, direction: direction) as? String {
                if !seenRooms.contains(roomIdentifier) {
                    if let room = rooms.first(where: { $1.identifier == roomIdentifier }) {
                        print(" ---> Already have room \(room.value.name)/\(room.value.identifier) in batch action")
                        seenRooms.append(room.value.identifier)
                        self.changeActionOption(TTModeHueConstants.kHueSeenRooms, to: seenRooms, direction: direction)
                    }
                }
            }
        }
        
        // Loop through batch actions to determine which rooms aren't yet seen and need batch actions for each unseen room
        for room in unseenRooms {
            if seenRooms.contains(room.identifier) {
                // Skip the room that may have just been added as the main action
                print(" ---> Not adding \(room.identifier) room, already seen")

                continue
            }
            print(" ---> Adding batch action for room \(room.name)/\(room.identifier) to \(actionName)")
            let batchActionKey = appDelegate().modeMap.addBatchAction(modeDirection: self.modeDirection,
                                                                      actionDirection: direction,
                                                                      modeClassName: self.nameOfClass,
                                                                      actionName: actionName)
            seenRooms.append(room.identifier)
            self.changeActionOption(TTModeHueConstants.kHueSeenRooms, to: seenRooms, direction: direction)
            self.changeBatchActionOption(batchActionKey, optionName: TTModeHueConstants.kHueRoom, to: room.identifier,
                                         direction: self.modeDirection, actionDirection: direction)
            appDelegate().mainViewController.adjustBatchActions()
        }
    }
    
    func ensureScenesSelected() {
        for direction: TTModeDirection in [.north, .east, .west, .south] {
            let actionName = self.actionNameInDirection(direction)
            if !actionName.contains("Scene") {
                continue
            }
            guard let actionRoom = self.actionOptionValue(TTModeHueConstants.kHueRoom, actionName: actionName, direction: direction) as? String else {
                print(" ---> ensureScenesSelected not ready yet, no room selected")
                continue
            }
            let actionScene = self.actionOptionValue(TTModeHueConstants.kHueScene, actionName: actionName, direction: direction) as? String
            let actionDouble = self.actionOptionValue(TTModeHueConstants.kDoubleTapHueScene, actionName: actionName, direction: direction) as? String

            // Assign default scenes for action
            if actionScene == nil {
                if let scene = self.sceneForAction(actionName, actionRoom: actionRoom, moment: .button_MOMENT_PRESSUP) {
                    self.changeActionOption(TTModeHueConstants.kHueScene, to: scene, direction: direction)
                }
            }
            
            if actionDouble == nil {
                if let scene = self.sceneForAction(actionName, actionRoom: actionRoom, moment: .button_MOMENT_DOUBLE) {
                    self.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: scene, direction: direction)
                }
            }
            
            // Assign default scenes for batch actions
            for batchAction in appDelegate().modeMap.batchActions.batchActions(in: direction) {
                if !batchAction.actionName.contains("Scene") {
                    continue
                }
                if let roomIdentifier = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kHueRoom, direction: direction) as? String {
                    let singleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kHueScene, direction: direction) as? String
                    if singleScene == nil {
                        if let scene = self.sceneForAction(batchAction.actionName, actionRoom: roomIdentifier, moment: .button_MOMENT_PRESSUP) {
                            self.changeBatchActionOption(batchAction.batchActionKey!, optionName: TTModeHueConstants.kHueScene,
                                                         to: scene, direction: batchAction.mode.modeDirection, actionDirection: direction)
                        }
                    }
                    
                    let doubleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kDoubleTapHueScene, direction: direction) as? String
                    if doubleScene == nil {
                        if let scene = self.sceneForAction(batchAction.actionName, actionRoom: roomIdentifier, moment: .button_MOMENT_DOUBLE) {
                            self.changeBatchActionOption(batchAction.batchActionKey!, optionName: TTModeHueConstants.kDoubleTapHueScene,
                                                         to: scene, direction: batchAction.mode.modeDirection, actionDirection: direction)
                        }
                    }
                }
            }
        }
    }
    
    func sceneForAction(_ actionName: String, actionRoom: String, moment: TTButtonMoment) -> String? {
        let sceneTitle = self.titleForAction(actionName, buttonMoment: moment)
        guard let scenes = TTModeHue.hueSdk.resourceCache?.scenes,
              let rooms = TTModeHue.hueSdk.resourceCache?.groups else {
            return nil
        }
        
        var roomLights: [String]?
        for (_, room) in rooms {
            if room.identifier == actionRoom {
                roomLights = room.lightIdentifiers
            }
        }
        
        for (_, scene) in scenes {
            if let sceneLights = scene.lightIdentifiers,
                let roomLights = roomLights {
                if scene.name == sceneTitle && Set(sceneLights) == Set(roomLights) {
                    return scene.identifier
                }
            }
        }
        
        return nil
    }
    
}
