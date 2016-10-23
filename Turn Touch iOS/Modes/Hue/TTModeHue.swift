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
let MAX_BRIGHTNESS: UInt32 = 255
let DEBUG_HUE = false

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
    
    func runScene(sceneName: String, doubleTap: Bool, defaultIdentifier: String) {
        if TTModeHue.hueState != .connected {
            self.connectToBridge()
            return
        }
        
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        let cache = TTModeHue.hueSdk.resourceCache
        var defaultScene: PartialScene?
        var sceneIdentifier: String? = self.action.optionValue(doubleTap ? TTModeHueConstants.kDoubleTapHueScene : TTModeHueConstants.kHueScene) as? String
        let roomIdentifier: String? = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String
        var scenes: Array<Dictionary<String, String>> = []
        for (_, scene) in (cache?.scenes)! {
            if scene.identifier == defaultIdentifier {
                defaultScene = scene
            }
            scenes.append(["name": scene.name, "identifier": scene.identifier])
        }
        
        scenes = scenes.sorted { $0["name"]! < $1["name"]! }
        
        if sceneIdentifier == nil || sceneIdentifier!.characters.count == 0 {
            if let _defaultScene = defaultScene {
                sceneIdentifier = _defaultScene.identifier
            } else {
                sceneIdentifier = scenes[0]["identifier"] // Last resort
            }
        }
        
        bridgeSendAPI.recallSceneWithIdentifier(sceneIdentifier!, inGroupWithIdentifier: roomIdentifier ?? "0") { (errors: [Error]?) in
            print(" ---> Scene change: \(sceneIdentifier ?? "no identifier") (\(errors))")
        }
    }
    
    func runTTModeHueSceneEarlyEvening() {
        self.runScene(sceneName: "TTModeHueSceneEarlyEvening", doubleTap: false, defaultIdentifier: "TT-ee-1")
    }
    
    func doubleRunTTModeHueSceneEarlyEvening() {
        self.runScene(sceneName: "TTModeHueSceneEarlyEvening", doubleTap: true, defaultIdentifier: "TT-ee-2")
    }
    
    func runTTModeHueSceneLateEvening() {
        self.runScene(sceneName: "TTModeHueSceneLateEvening", doubleTap: false, defaultIdentifier: "TT-le-1")
    }
    
    func doubleRunTTModeHueSceneLateEvening() {
        self.runScene(sceneName: "TTModeHueSceneLateEvening", doubleTap: true, defaultIdentifier: "TT-le-2")
    }
    
    func runTTModeHueSceneMorning() {
        self.runScene(sceneName: "TTModeHueSceneMorning", doubleTap: false, defaultIdentifier: "TT-mo-1")
    }
    
    func doubleRunTTModeHueSceneMorning() {
        self.runScene(sceneName: "TTModeHueSceneMorning", doubleTap: true, defaultIdentifier: "TT-mo-2")
    }
    
    func runTTModeHueSceneNightLight() {
        self.runScene(sceneName: "TTModeHueSceneNightLight", doubleTap: false, defaultIdentifier: "TT-nl-1")
    }
    
    func doubleRunTTModeHueSceneNightLight() {
        self.runScene(sceneName: "TTModeHueSceneNightLight", doubleTap: true, defaultIdentifier: "TT-nl-2")
    }
    
    func runTTModeHueSceneCustom() {
        self.runScene(sceneName: "TTModeHueSceneCustom", doubleTap: false, defaultIdentifier: "TT-ee-1")
    }
    
    func doubleRunTTModeHueSceneCustom() {
        self.runScene(sceneName: "TTModeHueSceneCustom", doubleTap: true, defaultIdentifier: "TT-le-2")
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
//            let lightState = PHLightState()
//            lightState.on = NSNumber(value: false)
//            lightState.alert = PHLightAlertMode.init(0)
//            lightState.transitionTime = NSNumber(value: sceneTransition)
//            lightState.brightness = NSNumber(value: 0)
//            
//            DispatchQueue.main.async {
//                bridgeSendAPI.updateLightState(forId: light.identifier, with: lightState, completionHandler: {(errors) in
//                    print(" ---> Sleep light in \(sceneTransition): \(errors)")
//                })
//            }
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
//            let lightState = PHLightState()
//            
//            if (randomColors == .allSame) || (randomColors == .someDifferent && arc4random() % 10 > 5) {
//                lightState.hue = randomColor as NSNumber!
//            } else {
//                lightState.hue = Int(arc4random() % MAX_HUE) as NSNumber!
//            }
//            
//            if randomBrightnesses == .low {
//                lightState.brightness = Int(arc4random() % 100) as NSNumber!
//            } else if randomBrightnesses == .varied {
//                lightState.brightness = Int(arc4random() % MAX_BRIGHTNESS) as NSNumber!
//            } else if randomBrightnesses == .high {
//                lightState.brightness = Int(254) as NSNumber!
//            }
//            
//            if randomSaturation == .low {
//                lightState.saturation = Int(174) as NSNumber!
//            } else if randomSaturation == .varied {
//                lightState.saturation = Int(254 - Int(arc4random_uniform(80))) as NSNumber!
//            } else if randomSaturation == .high {
//                lightState.saturation = Int(254) as NSNumber!
//            }
//            
//            DispatchQueue.main.async {
//                bridgeSendAPI.updateLightState(forId: light.identifier, with: lightState, completionHandler: {(errors) in
//                    
//                })
//            }
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
            self.updateHueConfig()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.startHueHeartbeat(username: username)
            }
        }
    }
    
    func updateHueConfig() {
        self.delegate?.changeState(TTModeHue.hueState, mode: self, message: nil)
        self.ensureScenes()
        self.ensureRooms()
    }
    
    func receiveHeartbeat() {
        let cache = TTModeHue.hueSdk.resourceCache
        
        self.updateHueConfig()
        
        var waitingOn: [String] = []
        if cache?.scenes == nil {
            waitingOn.append("scenes")
        }
        if cache?.groups == nil {
            waitingOn.append("groups")
        }
        if cache?.bridgeConfiguration == nil {
            waitingOn.append("config")
        }
        if cache?.lights == nil {
            waitingOn.append("lights")
        }
        
        if waitingOn.count == 0 {
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
    
//    /**
//     Notification receiver for successful local connection
//     */
//    func localConnection() {
//        // Check current connection state
//        self.checkConnectionState()
//    }
//    /**
//     Notification receiver for failed local connection
//     */
//    func noLocalConnection() {
//        // Check current connection state
//        self.checkConnectionState()
//    }
//    
//    /**
//     Notification receiver for failed local authentication
//     */
//    func notAuthenticated() {
//        self.perform(#selector(self.doAuthentication), with: nil, afterDelay: 0.5)
//    }
//
//    /**
//     Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
//     */
//    func checkConnectionState() {
//        if !TTModeHue.phHueSdk.localConnected() {
////            self.showNoConnectionDialog()
//            self.searchForBridgeLocal()
//        } else {
//            // One of the connections is made, remove popups and loading views
//            if hueState != .connected {
//                hueState = .connected
//                self.delegate?.changeState(hueState, mode: self, message: nil)
//                self.saveRecentBridge()
//                self.ensureScenes()
//                self.ensureRooms()
//            }
//        }
//    }
//    
//    /**
//     Shows the first no connection alert
//     */
//    func showNoConnectionDialog() {
//        NSLog("Connection to bridge lost!")
//        hueState = .notConnected
//        self.delegate?.changeState(hueState, mode: self, message: "Connection to Hue bridge lost")
//    }
//    /**
//     Shows the no bridges found alert
//     */
//    
//    func showNoBridgesFoundDialog() {
//        // Insert retry logic here
//        NSLog("Could not find bridge!")
//        hueState = .notConnected
//        self.delegate?.changeState(hueState, mode: self, message: "Could not find any Hue bridges")
//    }
//    /**
//     Shows the not authenticated alert
//     */
//    
//    func showNotAuthenticatedDialog() {
//        hueState = .notConnected
//        self.delegate?.changeState(hueState, mode: self, message: "Pushlink button not pressed within 30 seconds")
//        NSLog("Pushlink button not pressed within 30 sec!")
//    }
//    /**
//     Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
//     */
//    
//    func searchForBridgeLocal(reset: Bool = false) {
//        // In case if in pushlink loop
//        TTModeHue.phHueSdk.cancelPushLinkAuthentication()
//
//        // Stop heartbeats
//        self.disableLocalHeartbeat()
//        // Start search
//        hueState = .connecting
//        self.delegate?.changeState(hueState, mode: self, message: "Searching for a Hue bridge...")
//        
//        // Add dispatch_once token
//        let prefs = UserDefaults.standard
//        var recentBridgeId = prefs.string(forKey: TTModeHueConstants.kHueRecentBridgeId)
//        var recentBridgeIp = prefs.string(forKey: TTModeHueConstants.kHueRecentBridgeIp)
//        if recentBridgeIp == nil {
//            let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
//            recentBridgeIp = cache?.bridgeConfiguration?.ipaddress
//            recentBridgeId = cache?.bridgeConfiguration?.bridgeId
//        }
//        if (reset || recentBridgeIp != nil) {
//            if recentBridgeIp == nil || bridgesTried.contains(recentBridgeIp!) {
////                // If can't connect to a specific bridge, take it off recent prefs.
////                prefs.removeObject(forKey: TTModeHueConstants.kHueRecentBridgeId)
////                prefs.removeObject(forKey: TTModeHueConstants.kHueRecentBridgeIp)
////                prefs.synchronize()
//
//                if let foundBridges = prefs.array(forKey: TTModeHueConstants.kHueFoundBridges) as? [[String: String]] {
//                    for foundBridge: [String: String] in foundBridges {
//                        if !bridgesTried.contains(foundBridge["ipAddress"]!) {
//                            print(" ---> Attempting connect to different Hue: \(foundBridge["ipAddress"]!)")
//                            self.bridgeSelectedWithIpAddress(ipAddress: foundBridge["ipAddress"]!, andBridgeId: foundBridge["bridgeId"]!)
//                            return
//                        }
//                    }
//                }
//            } else {
//                print(" ---> Attempting connect to Hue: \(recentBridgeIp!)")
//                self.bridgeSelectedWithIpAddress(ipAddress: recentBridgeIp!, andBridgeId: recentBridgeId!)
//                return
//            }
//        }
//        
//        if self.bridgeToken == 0 {
//            self.bridgeToken = 1
//            print(" ---> No Hue bridge found, searching for bridges...")
//            self.bridgeSearch = PHBridgeSearching(upnpSearch: true, andPortalSearch: true, andIpAddressSearch: true)
//            self.bridgeSearch.startSearch(completionHandler: { (bridgesFound: [AnyHashable : Any]?) in
//                /***************************************************
//                 The search is complete, check whether we found a bridge
//                 *****************************************************/
//                // Check for results
//                self.bridgesTried = []
//                
//                if let bridgeCount = bridgesFound?.count, bridgeCount > 0 {
//                    self.hueState = .bridgeSelect
//                    self.delegate?.changeState(self.hueState, mode: self, message: bridgesFound)
//                } else {
//                    /***************************************************
//                     No bridge was found was found. Tell the user and offer to retry..
//                     *****************************************************/
//                    // No bridges were found, show this to the user
//                    self.showNoBridgesFoundDialog()
//                    self.delayReconnectToFoundBridges()
//                }
//                
//                self.bridgeToken = 0
//            })
//        }
//    }
//    
//    func delayReconnectToFoundBridges() {
//        let prefs = UserDefaults.standard
//        let foundBridges = prefs.array(forKey: TTModeHueConstants.kHueFoundBridges) as? [[String: String]]
//        
//        if let bridgeCount = foundBridges?.count, bridgeCount > 0 {
//            // Try again if bridges known
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10), execute: {
//                if self.hueState != .connected {
//                    self.searchForBridgeLocal()
//                }
//            })
//        }
//    }
//    
//    func bridgeSelectedWithIpAddress(ipAddress: String, andBridgeId bridgeId: String) {
//        print(" ---> Selected bridge: \(ipAddress) - \(bridgeId)")
//        let prefs = UserDefaults.standard
//        
//        prefs.set(bridgeId, forKey: TTModeHueConstants.kHueRecentBridgeId)
//        prefs.set(ipAddress, forKey: TTModeHueConstants.kHueRecentBridgeIp)
//        prefs.synchronize()
//        
//        bridgesTried.append(ipAddress)
//        
//        hueState = .connecting
//        self.delegate?.changeState(hueState, mode: self, message: "Connecting to Hue bridge...")
//        TTModeHue.phHueSdk.setBridgeToUseWithId(bridgeId, ipAddress: ipAddress)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.enableLocalHeartbeat()
//        }
//    }
//    
//    func saveRecentBridge() {
//        bridgesTried = []
//        
//        let prefs = UserDefaults.standard
//        if let recentBridgeId = prefs.object(forKey: TTModeHueConstants.kHueRecentBridgeId),
//            let recentBridgeIp = prefs.object(forKey: TTModeHueConstants.kHueRecentBridgeIp) {
//            var foundBridges = prefs.array(forKey: TTModeHueConstants.kHueFoundBridges) as? [[String: String]] ?? []
//            let saved = foundBridges.contains(where: { (foundBridge) -> Bool in
//                foundBridge["ipAddress"] == recentBridgeIp as? String
//            })
//            if !saved {
//                foundBridges.append(["ipAddress": recentBridgeIp as! String, "bridgeId": recentBridgeId as! String])
//                print(" ---> Saving new bridge: \(foundBridges)")
//                prefs.set(foundBridges, forKey: TTModeHueConstants.kHueFoundBridges)
//                prefs.synchronize()
//            }
//        }
//
//    }
//    
//    /**
//     Starts the local heartbeat with a 10 second interval
//     */
//    func enableLocalHeartbeat() {
//        /***************************************************
//         The heartbeat processing collects data from the bridge
//         so now try to see if we have a bridge already connected
//         *****************************************************/
//        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
//        if cache?.bridgeConfiguration?.ipaddress != nil {
//            // Enable heartbeat with interval of 10 seconds
//            TTModeHue.phHueSdk.enableLocalConnection()
//        } else {
//            // Automaticly start searching for bridges
//            self.searchForBridgeLocal()
//        }
//    }
//    
//    /**
//     Stops the local heartbeat
//     */
//    func disableLocalHeartbeat() {
//        TTModeHue.phHueSdk.disableLocalConnection()
//    }
//    
//    /**
//     Start the local authentication process
//     */
//    func doAuthentication() {
//        // Disable heartbeats
//        self.disableLocalHeartbeat()
//
//        /***************************************************
//         To be certain that we own this bridge we must manually
//         push link it. Here we display the view to do this.
//         *****************************************************/
//        hueState = .pushlink
//        self.delegate?.changeState(hueState, mode: self, message: nil)
//        
//        /***************************************************
//         Start the push linking process.
//         *****************************************************/
//        // Start pushlinking when the interface is shown
//        self.startPushLinking()
//    }
//    
//    func startPushLinking() {
//        /***************************************************
//         Set up the notifications for push linkng
//         *****************************************************/
//        // Register for notifications about pushlinking
////        let phNotificationMgr: PHNotificationManager = PHNotificationManager.defaultManager()
////        phNotificationMgr.deregisterObjectForAllNotifications(self)
////        phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationSuccess),
////                                         forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
////        phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationFailed),
////                                         forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
////        phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalConnection),
////                                         forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
////        phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalBridge),
////                                         forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
////        phNotificationMgr.registerObject(self, withSelector: #selector(self.buttonNotPressed(_:)),
////                                         forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
//        // Call to the hue SDK to start pushlinking process
//        /***************************************************
//         Call the SDK to start Push linking.
//         The notifications sent by the SDK will confirm success
//         or failure of push linking
//         *****************************************************/
//        TTModeHue.phHueSdk.startPushlinkAuthentication()
//    }
//    /**
//     Notification receiver which is called when the pushlinking was successful
//     */
//    
//    func authenticationSuccess() {
//        /***************************************************
//         The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
//         was received. We have confirmed the bridge.
//         De-register for notifications and call
//         pushLinkSuccess on the delegate
//         *****************************************************/
//        // Deregister for all notifications
////        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
//        hueState = .connected
//        self.delegate?.changeState(hueState, mode: self, message: nil)
//        self.saveRecentBridge()
//        self.disableLocalHeartbeat()
//        // Start local heartbeat
//        self.perform(#selector(self.enableLocalHeartbeat), with: nil, afterDelay: 1)
//    }
//    /**
//     Notification receiver which is called when the pushlinking failed because the time limit was reached
//     */
//    
//    func authenticationFailed() {
//        // Deregister for all notifications
////        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
//        // Inform delegate
//        self.pushlinkFailed(error: PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_TIME_LIMIT_REACHED.rawValue), userInfo: [
//            NSLocalizedDescriptionKey : "Authentication failed: time limit reached."
//        ]))
//    }
//    /**
//     Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
//     */
//    
//    func noLocalBridge() {
//        print(" No local bridge!!")
//        // Deregister for all notifications
////        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
//        // Inform delegate
//        self.pushlinkFailed(error: PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_NO_LOCAL_BRIDGE.rawValue), userInfo: [
//            NSLocalizedDescriptionKey : "Authentication failed: No local bridge found."
//        ]))
//    }
//    /**
//     This method is called when the pushlinking is still ongoing but no button was pressed yet.
//     @param notification The notification which contains the pushlinking percentage which has passed.
//     */
//    
//    func buttonNotPressed(notification: NSNotification) {
//        // Update status bar with percentage from notification
//        var dict = notification.userInfo!
//        let progressPercentage: Int = (dict["progressPercentage"] as! Int)
//        hueState = .pushlink
//        self.delegate?.changeState(hueState, mode: self, message: progressPercentage)
//    }
//    
//    /**
//     Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
//     */
//    
//    func pushlinkFailed(error: PHError) {
//        TTModeHue.phHueSdk.cancelPushLinkAuthentication()
//        // Check which error occured
//        if error.code == Int(PUSHLINK_NO_CONNECTION.rawValue) {
//            // No local connection to bridge
//            self.noLocalConnection()
//            // Start local heartbeat (to see when connection comes back)
//            self.perform(#selector(self.enableLocalHeartbeat), with: nil, afterDelay: 1)
//        }
//        else {
//            // Retry:
//            // self.doAuthentication()
//            
//            // Bridge button not pressed in time
//            self.disableLocalHeartbeat()
//            self.showNotAuthenticatedDialog()
//            self.searchForBridgeLocal()
//        }
//    }

    // MARK: - Scenes and Rooms
    
    func ensureScenes(force: Bool = false) {
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        let cache = TTModeHue.hueSdk.resourceCache
        
        guard let scenes = cache?.scenes, let lights = cache?.lights else {
            print(" ---> Scenes/lights not ready yet")
            return
        }
        
        // Collect scene ids to check against
        var foundScenes: [String] = []
        for (_, scene) in scenes {
            foundScenes.append(scene.identifier)
        }
        
//        // Scene: All Lights Off
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
//        
//        if !foundScenes.contains("TT-ee-1") || force {
//            let scene: PHScene = PHScene()
//            scene.name = "Early Evening"
//            scene.identifier = "TT-ee-1"
//            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
//            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
////                print("Hue:EE1 scene: \(errors)")
//                for (_, value) in (cache?.lights)! {
//                    let light = value as! PHLight
//                    let lightState = PHLightState()
//                    lightState.on = NSNumber(booleanLiteral: true)
//                    lightState.alert = PHLightAlertMode.init(0)
//                    let point = PHUtilities.calculateXY(UIColor(red: 235/255.0, green: 206/255.0, blue: 146/255.0, alpha: 1), forModel: light.modelNumber)
//                    lightState.x = NSNumber(value: Float(point.x))
//                    lightState.y = NSNumber(value: Float(point.y))
//                    lightState.brightness = NSNumber(value: Int(MAX_BRIGHTNESS))
//                    lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
//                    bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
////                        print("Hue:EE1 scene: \(errors)")
//                        self.delegate?.changeState(self.hueState, mode: self, message: nil)
//                    })
//                }
//            })
//        }
//        
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
        
        // Cycle through action and batch actions, ensuring all have a room, single tap scene, and double tap, adding batch actions for rooms that aren't used
        let actionName = self.actionNameInDirection(direction)
        var actionRoom = self.actionOptionValue(TTModeHueConstants.kHueRoom, actionName: actionName, direction: direction) as? String
        let actionScene = self.actionOptionValue(TTModeHueConstants.kHueScene, actionName: actionName, direction: direction) as? String
        let actionDouble = self.actionOptionValue(TTModeHueConstants.kDoubleTapHueScene, actionName: actionName, direction: direction) as? String
        var seenRooms: [String] = self.actionOptionValue(TTModeHueConstants.kHueSeenRooms, actionName: actionName, direction: direction) as? [String] ?? []

        var unseenRooms: [Group] = []
        if let rooms = cache?.groups {
            for (_, room) in rooms {
                if !seenRooms.contains(room.identifier) {
                    unseenRooms.append(room)
                }
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
                    if let room = cache?.groups.first(where: { $1.identifier == roomIdentifier }) {
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

        // Assign default scenes for action
        if actionScene == nil && actionRoom != nil {
            if let scene = self.sceneDefault(actionName: actionName, singleTap: true) {
                self.changeActionOption(TTModeHueConstants.kHueScene, to: "\(scene)-room-\(actionRoom!)", direction: direction)
            }
        }
    
        if actionDouble == nil && actionRoom != nil {
            if let scene = self.sceneDefault(actionName: actionName, doubleTap: true) {
                self.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: "\(scene)-room-\(actionRoom!)", direction: direction)
            }
        }
        
        // Assign default scenes for batch actions
        for batchAction in appDelegate().modeMap.batchActions.batchActions(in: direction) {
            if let roomIdentifier = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kHueRoom, direction: direction) as? String {
                let singleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kHueScene, direction: direction) as? String
                if singleScene == nil {
                    if let defaultScene = self.sceneDefault(actionName: actionName, singleTap: true) {
                        self.changeActionOption(TTModeHueConstants.kHueScene, to: "\(defaultScene)-room-\(roomIdentifier)", direction: direction)
                    }
                }
                
                let doubleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kDoubleTapHueScene, direction: direction) as? String
                if doubleScene == nil {
                    if let defaultScene = self.sceneDefault(actionName: actionName, doubleTap: true) {
                        self.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: "\(defaultScene)-room-\(roomIdentifier)", direction: direction)
                    }
                }
            }
        }
    }
    
    func sceneDefault(actionName: String, singleTap: Bool = false, doubleTap: Bool = false) -> String? {
        var scene: String?
        switch actionName {
        case "TTModeHueSceneEarlyEvening":
            scene = doubleTap ? "TT-ee-2" : "TT-ee-1"
        case "TTModeHueSceneLateEvening":
            scene = doubleTap ? "TT-le-2" : "TT-le-1"
        case "TTModeHueSceneMorning":
            scene = doubleTap ? "TT-mo-2" : "TT-mo-1"
        case "TTModeHueSceneNightLight":
            scene = doubleTap ? "TT-nl-2" : "TT-nl-1"
        default: break
        }
        
        return scene
    }
    
}
