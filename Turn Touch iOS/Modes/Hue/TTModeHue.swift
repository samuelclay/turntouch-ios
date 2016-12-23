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

protocol TTModeHueSceneDelegate {
    func sceneUploadProgress()
}

class TTModeHue: TTMode, BridgeFinderDelegate, BridgeAuthenticatorDelegate, ResourceCacheHeartbeatProcessorDelegate {
    
//    static var phHueSdk: PHHueSDK!
    static var hueSdk: SwiftyHue!
    static var reachability: Reachability!
    static var hueState: TTHueState = TTHueState.notConnected
    static var createdScenes: [String] = []
    static var foundScenes: [String] = []
    static var sceneQueue: OperationQueue = OperationQueue()
    static var sceneSemaphore = DispatchSemaphore(value: 1)
    static var sceneCacheSemaphore = DispatchSemaphore(value: 0)
    static var sceneDeletionSemaphore = DispatchSemaphore(value: 1)
    static var lightSemaphore = DispatchSemaphore(value: 1)
    static var waitingOnScenes: Bool = false
//    var bridgeSearch: PHBridgeSearching!
    var bridgeFinder: BridgeFinder!
    var bridgeAuthenticator: BridgeAuthenticator!
    var latestBridge: HueBridge?
    var delegate: TTModeHueDelegate?
    var sceneDelegate: TTModeHueSceneDelegate?
    var bridgeToken: Int = 0
    var bridgesTried: [String] = []
    var foundBridges: [HueBridge] = [] // Only used during bridge choosing
    var sceneUploadProgress: Float = -1

    required init() {
        super.init()

        TTModeHue.sceneQueue.maxConcurrentOperationCount = 1
        
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
//        TTModeHue.hueSdk.enableLogging(true)
        
        self.connectToBridge(reset: true)
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
                "TTModeHueSceneMidnightOil",
                "TTModeHueSceneCustom",
                "TTModeHueSceneLightsOff",
                "TTModeHueSceneColorLoop",
                "TTModeHueSleep",
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
    
    func titleTTModeHueSceneMidnightOil() -> String {
        return "Midnight oil"
    }
    
    func doubleTitleTTModeHueSceneMidnightOil() -> String {
        return "Midnight oil 2"
    }
    
    func titleTTModeHueSceneLightsOff() -> String {
        return "Lights off"
    }
    
    func titleTTModeHueSceneColorLoop() -> String {
        return "Color loop"
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
    
    func imageTTModeHueSceneMidnightOil() -> String {
        return "hue_evening.png"
    }
    
    func imageTTModeHueSceneLightsOff() -> String {
        return "hue_sleep.png"
    }
    
    func imageTTModeHueSceneColorLoop() -> String {
        return "hue_random.png"
    }
    
    func imageTTModeHueSceneCustom() -> String {
        return "hue_evening.png"
    }
    
    func imageTTModeHueSleep() -> String {
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
                print(" ---> Scene change: \(sceneName), \(sceneIdentifier) (\(errors))")
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
    
    func runTTModeHueSceneMidnightOil() {
        self.runScene(sceneName: "TTModeHueSceneMidnightOil", doubleTap: false)
    }
    
    func doubleRunTTModeHueSceneMidnightOil() {
        self.runScene(sceneName: "TTModeHueSceneMidnightOil", doubleTap: true)
    }
    
    func runTTModeHueSceneLightsOff() {
        self.runScene(sceneName: "TTModeHueSceneLightsOff", doubleTap: false)
    }
    
    func runTTModeHueSceneColorLoop() {
        self.runScene(sceneName: "TTModeHueSceneColorLoop", doubleTap: false)
    }
    
    func runTTModeHueSceneCustom() {
        self.runScene(sceneName: "TTModeHueSceneCustom", doubleTap: false)
    }
    
    func doubleRunTTModeHueSceneCustom() {
        self.runScene(sceneName: "TTModeHueSceneCustom", doubleTap: true)
    }
    
    func runTTModeHueSleep() {
        let sceneDuration: Int = self.action.optionValue(TTModeHueConstants.kHueDuration) as! Int
        self.runTTModeHueSleep(duration: sceneDuration)
    }
    
    func doubleRunTTModeHueSleep() {
        //    NSLog(@"Running scene off... %d", direction);
        let sceneDuration: Int = self.action.optionValue(TTModeHueConstants.kHueDoubleTapDuration) as! Int
        self.runTTModeHueSleep(duration: sceneDuration)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSceneEarlyEvening() -> NSNumber {
        return NSNumber(value: true)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSceneLateEvening() -> NSNumber {
        return NSNumber(value: true)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSceneMorning() -> NSNumber {
        return NSNumber(value: true)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSceneMidnightOil() -> NSNumber {
        return NSNumber(value: true)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueSleep() -> NSNumber {
        return NSNumber(value: true)
    }
    
    func shouldIgnoreSingleBeforeDoubleTTModeHueRandom() -> NSNumber {
        return NSNumber(value: true)
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
        let roomIdentifier = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String

        guard let lights = cache?.lights else {
            print(" ---> Not running sleep, no lights found")
            return
        }
        
        var roomLights: [String]? = []
        if let rooms = cache?.groups, let roomIdentifier = roomIdentifier {
            for (_, room) in rooms {
                if room.identifier == roomIdentifier {
                    roomLights = room.lightIdentifiers
                    break
                }
            }
        }
        
        for (_, light) in lights {
            if roomIdentifier != nil && roomLights?.contains(light.identifier) == false {
                continue
            }

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
        let roomIdentifier = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String
        
        guard let lights = cache?.lights else {
            print(" ---> Not running random, no lights found")
            return
        }
        
        var roomLights: [String]? = []
        if let rooms = cache?.groups, let roomIdentifier = roomIdentifier {
            for (_, room) in rooms {
                if room.identifier == roomIdentifier {
                    roomLights = room.lightIdentifiers
                    break
                }
            }
        }
        
        for (_, light) in lights {
            if roomIdentifier != nil && roomLights?.contains(light.identifier) == false {
                continue
            }

            var lightState = LightState()
            
            lightState.on = true

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
        if TTModeHue.hueState == .connecting {
            return
        }
        
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
                                                          timeout: 30)
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
//                print(" ---> Done with heartbeat")
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
        
        TTModeHue.hueSdk.setBridgeAccessConfig(bridgeAccessConfig, resourceCacheHeartbeatProcessorDelegate: self)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .lights)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .groups)
//        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .rules)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .scenes)
//        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .schedules)
//        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .sensors)
        TTModeHue.hueSdk.setLocalHeartbeatInterval(10, forResourceType: .config)
        
        TTModeHue.hueSdk.stopHeartbeat()
        TTModeHue.hueSdk.startHeartbeat()
    }
    
    func resourceCacheUpdated(_ resourceCache: BridgeResourcesCache) {
        TTModeHue.hueSdk.resourceCache = resourceCache
        print(" ---> Updated resource cache: \(resourceCache) \(TTModeHue.waitingOnScenes ? "Waiting on scenes, here they are!" : "")")
        if TTModeHue.waitingOnScenes {
            TTModeHue.waitingOnScenes = false
            TTModeHue.sceneCacheSemaphore.signal()
        }
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
        
        DispatchQueue.global().async {
            if force {
                self.deleteScenes()
                
                if case .timedOut = TTModeHue.sceneCacheSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(30)) {
                    print(" ---> Waited too long for deleted scenes to come back")
                }
                
                print(" ---> Done deleting, now creating scenes...")
            }
            
            // Collect scene ids to check against
            TTModeHue.foundScenes = []
            for (_, scene) in scenes {
                TTModeHue.foundScenes.append(scene.identifier)
            }

            DispatchQueue.main.async {
                self.sceneUploadProgress = 0
                self.sceneDelegate?.sceneUploadProgress()
            }

            self.ensureScene(sceneName: "TTModeHueSceneEarlyEvening", moment: .button_MOMENT_PRESSUP) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = true
                let point = HueUtilities.calculateXY(UIColor(red: 235/255.0, green: 206/255.0, blue: 146/255.0, alpha: 1), forModel: light.modelId)
                lightState.xy = [Float(point.x), Float(point.y)]
                lightState.brightness = Int(MAX_BRIGHTNESS)
                lightState.saturation = Int(MAX_BRIGHTNESS)
                return lightState
            }
            
            self.ensureScene(sceneName: "TTModeHueSceneEarlyEvening", moment: .button_MOMENT_DOUBLE) { (light: Light, index: Int) in
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
            
            self.ensureScene(sceneName: "TTModeHueSceneLateEvening", moment: .button_MOMENT_PRESSUP) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = true
                let point = HueUtilities.calculateXY(UIColor(red: 95/255.0, green: 76/255.0, blue: 36/255.0, alpha: 1), forModel: light.modelId)
                lightState.xy = [Float(point.x), Float(point.y)]
                lightState.brightness = Int(MAX_BRIGHTNESS)
                lightState.saturation = Int(MAX_BRIGHTNESS)
                return lightState
            }
            
            self.ensureScene(sceneName: "TTModeHueSceneLateEvening", moment: .button_MOMENT_DOUBLE) { (light: Light, index: Int) in
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
            
            self.ensureScene(sceneName: "TTModeHueSceneMorning", moment: .button_MOMENT_PRESSUP) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = true
                var point = HueUtilities.calculateXY(UIColor(red: 145/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1), forModel: light.modelId)
                lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(2/10.0))
                if index % 3 == 1 {
                    point = HueUtilities.calculateXY(UIColor(red: 144/255.0, green: 56/255.0, blue: 20/255.0, alpha: 1), forModel: light.modelId)
                    lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(5/10.0))
                }
                lightState.xy = [Float(point.x), Float(point.y)]
                lightState.saturation = Int(MAX_BRIGHTNESS / 2)
                return lightState
            }
            
            self.ensureScene(sceneName: "TTModeHueSceneMorning", moment: .button_MOMENT_DOUBLE) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = true
                var point = HueUtilities.calculateXY(UIColor(red: 195/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1), forModel: light.modelId)
                lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(4/10.0))
                if index % 3 == 1 {
                    point = HueUtilities.calculateXY(UIColor(red: 134/255.0, green: 76/255.0, blue: 26/255.0, alpha: 1), forModel: light.modelId)
                    lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(6/10.0))
                }
                lightState.xy = [Float(point.x), Float(point.y)]
                lightState.saturation = Int(MAX_BRIGHTNESS / 2)
                return lightState
            }
            
            self.ensureScene(sceneName: "TTModeHueSceneMidnightOil", moment: .button_MOMENT_PRESSUP) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = true
                var point = HueUtilities.calculateXY(UIColor(red: 145/255.0, green: 176/255.0, blue: 165/255.0, alpha: 1), forModel: light.modelId)
                lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(2/10.0))
                lightState.saturation = Int(MAX_BRIGHTNESS / 2)
                if index % 3 == 1 {
                    point = HueUtilities.calculateXY(UIColor(red: 14/255.0, green: 56/255.0, blue: 200/255.0, alpha: 1), forModel: light.modelId)
                    lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(1/10.0))
                    lightState.saturation = Int(MAX_BRIGHTNESS)
                }
                if index % 6 == 2 {
                    point = HueUtilities.calculateXY(UIColor(red: 14/255.0, green: 156/255.0, blue: 200/255.0, alpha: 1), forModel: light.modelId)
                    lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(3/10.0))
                    lightState.saturation = Int(MAX_BRIGHTNESS)
                }
                lightState.xy = [Float(point.x), Float(point.y)]
                return lightState
            }
            
            self.ensureScene(sceneName: "TTModeHueSceneMidnightOil", moment: .button_MOMENT_DOUBLE) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = true
                var point = HueUtilities.calculateXY(UIColor(red: 145/255.0, green: 76/255.0, blue: 65/255.0, alpha: 1), forModel: light.modelId)
                lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(2/10.0))
                lightState.saturation = Int(MAX_BRIGHTNESS / 2)
                if index % 3 == 2 {
                    point = HueUtilities.calculateXY(UIColor(red: 14/255.0, green: 26/255.0, blue: 240/255.0, alpha: 1), forModel: light.modelId)
                    lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(3/10.0))
                    lightState.saturation = Int(MAX_BRIGHTNESS)
                }
                if index % 6 == 1 {
                    point = HueUtilities.calculateXY(UIColor(red: 140/255.0, green: 16/255.0, blue: 20/255.0, alpha: 1), forModel: light.modelId)
                    lightState.brightness = Int(Double(MAX_BRIGHTNESS)*(3/10.0))
                    lightState.saturation = Int(MAX_BRIGHTNESS)
                }
                lightState.xy = [Float(point.x), Float(point.y)]
                return lightState
            }
            
            self.ensureScene(sceneName: "TTModeHueSceneLightsOff", moment: .button_MOMENT_PRESSUP) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = false
                lightState.brightness = Int(0)
                return lightState
            }
            
            self.ensureScene(sceneName: "TTModeHueSceneColorLoop", moment: .button_MOMENT_PRESSUP) { (light: Light, index: Int) in
                var lightState = LightState()
                lightState.on = true
                lightState.effect = "colorloop"
                return lightState
            }
            
            DispatchQueue.main.async {
                self.sceneUploadProgress = -1
                self.sceneDelegate?.sceneUploadProgress()
            }
        }
    }
    
    func ensureScene(sceneName: String, moment: TTButtonMoment, lightsHandler: @escaping ((_ light: Light, _ index: Int) -> (LightState))) {

        let createdSceneName = "\(sceneName)-\(moment == .button_MOMENT_PRESSUP ? "single" : "double")"
        if TTModeHue.createdScenes.contains(createdSceneName) {
            // print(" ---> Not ensuring scene \(sceneName), just created")
            return
        }

        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        let cache = TTModeHue.hueSdk.resourceCache

        guard let lights = cache?.lights, let _ = cache?.groups else {
            print(" ---> Scenes/lights/rooms not ready yet for scene creation")
            return
        }

        TTModeHue.createdScenes.append(createdSceneName)
        DispatchQueue.global().async {
            let sceneIdentifier = self.sceneForAction(sceneName, moment: moment)
            if sceneIdentifier != nil {
                if TTModeHue.foundScenes.contains(sceneIdentifier!) {
                    return
                }
            } else {
//                    print(" ---> Scene not found: \(sceneName) [\(roomLights)] \(TTModeHue.foundScenes)")
            }
            
            if case .timedOut = TTModeHue.sceneSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(30)) {
                print(" ---> Hue room timed out \(sceneIdentifier): \(sceneName)")
            }

            print(" ---> Creating scene \(sceneName)")
            let sceneTitle = self.titleForAction(sceneName, buttonMoment: moment)
            let lightIdentifiers = cache?.lights.map { (key, light) -> String in
                return light.identifier
            }
            bridgeSendAPI.createSceneWithName(sceneTitle, includeLightIds: lightIdentifiers ?? [], completionHandler: { (sceneIdentifier, errors) in
                guard let sceneIdentifier = sceneIdentifier else {
                    print(" ---> Error: missing scene identifier")
                    return
                }
                print(" ---> Created scene \(sceneTitle): \(sceneIdentifier)")
                DispatchQueue.main.async {
                    self.sceneUploadProgress = 0.5
                    self.sceneDelegate?.sceneUploadProgress()
                }

                DispatchQueue.global().async {
                    for (index, light) in lights.values.enumerated() {
                        if case .timedOut = TTModeHue.lightSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10)) {
                            print(" ---> Hue light timed out \(sceneIdentifier) #\(index): \(sceneName)")
                        }
                        print(" ---> Saving hue light \(sceneIdentifier) #\(index): \(sceneName)")
                        let lightState = lightsHandler(light, index)
                        bridgeSendAPI.updateLightStateInScene(sceneIdentifier, lightIdentifier: light.identifier, withLightState: lightState, completionHandler: { (errors) in
                            print(" ---> Hue light done \(sceneIdentifier) #\(index): \(sceneName) \(errors)")
                            DispatchQueue.main.async {
                                self.sceneUploadProgress = Float(index)/Float(lights.count)
                                self.sceneDelegate?.sceneUploadProgress()
                            }
                            TTModeHue.lightSemaphore.signal()
    //                                self.delegate?.changeState(TTModeHue.hueState, mode: self, message: nil)
                        })
                    }
                    
                    //                print(" ---> All done creating scenes!")
                    //                TTModeHue.hueSdk.stopHeartbeat()
                    //                TTModeHue.hueSdk.startHeartbeat()
                    if case .timedOut = TTModeHue.lightSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(30)) {
                        print(" ---> Hue lights timed out \(sceneIdentifier): \(sceneName)")
                    }
                    
                    TTModeHue.lightSemaphore.signal()
                    TTModeHue.sceneSemaphore.signal()
                    
                    self.updateScenes()
                    
                    if case .timedOut = TTModeHue.sceneCacheSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(30)) {
                        print(" ---> Waited too long for created scenes to come back")
                    }

                    self.ensureScenesSelected()
                    TTModeHue.sceneCacheSemaphore.signal()
                    
                }
            })
        }
    }
    
    func deleteScenes() {
        let cache = TTModeHue.hueSdk.resourceCache
        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
        guard let scenes = cache?.scenes else {
            print(" ---> Not deleting scenes, no scenes found!")
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
        
        DispatchQueue.main.async {
            self.sceneUploadProgress = 1
            self.sceneDelegate?.sceneUploadProgress()
        }
        
        var sceneCount = 0
        for (_, scene) in scenes {
            if sceneTitles.contains(scene.name) {
                sceneCount += 1
            }
        }
        var deleteCount = 0
        for (_, scene) in scenes {
            if sceneTitles.contains(scene.name) {
                if case .timedOut = TTModeHue.sceneSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10)) {
                    print(" ---> Hue scene removal timed out \(scene.identifier): \(scene.name)-\(scene.lightIdentifiers!)")
                }
                print(" ---> Removing \(scene.name) (\(scene.identifier)) [\(scene.lightIdentifiers!)])")
                bridgeSendAPI.removeSceneWithId(scene.identifier, completionHandler: { (errors) in
                    print(" ---> Removed \(scene.name) (\(scene.identifier)) [\(scene.lightIdentifiers!)])")
                    TTModeHue.sceneSemaphore.signal()
                    DispatchQueue.main.async {
                        deleteCount += 1
                        self.sceneUploadProgress = Float(sceneCount - deleteCount)/Float(sceneCount)
                        self.sceneDelegate?.sceneUploadProgress()
                    }
                })
            }
        }
        

        if case .timedOut = TTModeHue.sceneSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10)) {
            print(" ---> Hue scene removals timed out")
        }
        print(" ---> Removed all Hue scenes")
        TTModeHue.sceneSemaphore.signal()
        TTModeHue.createdScenes = []
        self.updateScenes()
    }
    
    func updateScenes() {
        print(" ---> Updating scenes...")

        DispatchQueue.main.sync {
            TTModeHue.hueSdk.removeLocalHeartbeat(forResourceType: .lights)
            TTModeHue.hueSdk.removeLocalHeartbeat(forResourceType: .groups)
            TTModeHue.hueSdk.removeLocalHeartbeat(forResourceType: .config)

            print(" ---> Restarting heartbeat with only scenes")
            TTModeHue.waitingOnScenes = true
            TTModeHue.hueSdk.stopHeartbeat()
            TTModeHue.hueSdk.startHeartbeat()
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
        let cache = TTModeHue.hueSdk.resourceCache
        guard let scenes = cache?.scenes else {
            print(" ---> Scenes not ready yet for scene selection")
            return
        }

        for direction: TTModeDirection in [.north, .east, .west, .south] {
            let actionName = self.actionNameInDirection(direction)
            if !actionName.contains("Scene") {
                continue
            }
            guard let _ = self.actionOptionValue(TTModeHueConstants.kHueRoom, actionName: actionName, direction: direction) as? String else {
                print(" ---> ensureScenesSelected not ready yet, no room selected")
                continue
            }

            var actionScene = self.actionOptionValue(TTModeHueConstants.kHueScene, actionName: actionName, direction: direction) as? String
            var actionDouble = self.actionOptionValue(TTModeHueConstants.kDoubleTapHueScene, actionName: actionName, direction: direction) as? String

            // Double check that scene is still on bridge and corrosponds to selected room
            if actionScene != nil {
                if scenes.values.first(where: { (scene) -> Bool in scene.identifier == actionScene }) == nil {
                    // print(" ---> Scene no longer exists: \(actionScene!) \(actionName), clearing...")
                    actionScene = nil
                }
            }
            if actionDouble != nil {
                if scenes.values.first(where: { (scene) -> Bool in scene.identifier == actionDouble }) == nil {
                    // print(" ---> Scene no longer exists: \(actionDouble!) \(actionName), clearing...")
                    actionDouble = nil
                }
            }

            // Assign default scenes for action
            if actionScene == nil {
                if let scene = self.sceneForAction(actionName, moment: .button_MOMENT_PRESSUP) {
                    self.changeActionOption(TTModeHueConstants.kHueScene, to: scene, direction: direction)
                }
            }
            
            if actionDouble == nil {
                if let scene = self.sceneForAction(actionName, moment: .button_MOMENT_DOUBLE) {
                    self.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: scene, direction: direction)
                }
            }
            
            // Assign default scenes for batch actions
            for batchAction in appDelegate().modeMap.batchActions.batchActions(in: direction) {
                if !batchAction.actionName.contains("Scene") {
                    continue
                }
                var singleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kHueScene, direction: direction) as? String
                var doubleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kDoubleTapHueScene, direction: direction) as? String

                if singleScene != nil {
                    if scenes.values.first(where: { (scene) -> Bool in scene.identifier == singleScene }) == nil {
//                            print(" ---> Scene no longer exists: \(singleScene!) \(actionName), clearing...")
                        singleScene = nil
                    }
                }
                if doubleScene != nil {
                    if scenes.values.first(where: { (scene) -> Bool in scene.identifier == doubleScene }) == nil {
//                            print(" ---> Scene no longer exists: \(doubleScene!) \(actionName), clearing...")
                        doubleScene = nil
                    }
                }

                if singleScene == nil {
                    if let scene = self.sceneForAction(batchAction.actionName, moment: .button_MOMENT_PRESSUP) {
                        self.changeBatchActionOption(batchAction.batchActionKey!, optionName: TTModeHueConstants.kHueScene,
                                                     to: scene, direction: batchAction.mode.modeDirection, actionDirection: direction)
                    }
                }
                
                if doubleScene == nil {
                    if let scene = self.sceneForAction(batchAction.actionName, moment: .button_MOMENT_DOUBLE) {
                        self.changeBatchActionOption(batchAction.batchActionKey!, optionName: TTModeHueConstants.kDoubleTapHueScene,
                                                     to: scene, direction: batchAction.mode.modeDirection, actionDirection: direction)
                    }
                }
            }
        }
    }
    
    func sceneForAction(_ actionName: String, moment: TTButtonMoment) -> String? {
        let sceneTitle = self.titleForAction(actionName, buttonMoment: moment)
        guard let scenes = TTModeHue.hueSdk.resourceCache?.scenes else {
            return nil
        }
        
        for (_, scene) in scenes {
            if scene.name == sceneTitle {
                return scene.identifier
            }
        }
        
        return nil
    }
    
}
