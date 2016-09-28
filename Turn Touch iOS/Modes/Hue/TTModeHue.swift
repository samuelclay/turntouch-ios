//
//  TTModeHue.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import ReachabilitySwift

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

struct TTModeHueConstants {
    static let kRandomColors: String = "randomColors"
    static let kRandomBrightness: String = "randomBrightness"
    static let kRandomSaturation: String = "randomSaturation"
    static let kDoubleTapRandomColors: String = "doubleTapRandomColors"
    static let kDoubleTapRandomBrightness: String = "doubleTapRandomBrightness"
    static let kDoubleTapRandomSaturation: String = "doubleTapRandomSaturation"
    static let kHueScene: String = "hueScene"
    static let kDoubleTapHueScene: String = "doubleTapHueScene"
    static let kHueDuration: String = "hueDuration"
    static let kHueDoubleTapDuration: String = "hueDoubleTapDuration"
    static let kHueRecentBridgeId: String = "hueRecentBridgeId"
    static let kHueRecentBridgeIp: String = "hueRecentBridgeIp"
    static let kHueFoundBridges: String = "hueFoundBridges"
}

protocol TTModeHueDelegate {
    func changeState(_ hueState: TTHueState, mode: TTModeHue, message: Any?)
}

class TTModeHue: TTMode {
    
    var phHueSdk: PHHueSDK!
    var hueState: TTHueState = TTHueState.notConnected
    var bridgeSearch: PHBridgeSearching!
    var delegate: TTModeHueDelegate?
    var foundBridges: [String: String] = [:]
    var bridgeToken: Int = 0
    var bridgesTried: [String] = []
    let reachability = Reachability()!

    required init() {
        super.init()
        
        self.initializeHue()
        self.watchReachability()
    }
    
    deinit {
        self.disableLocalHeartbeat()
        phHueSdk.stop()
    }
    
    override func activate() {
        
    }
    
    func initializeHue(_ force: Bool = false) {
        if phHueSdk != nil && !force {
            return;
        }
        
        phHueSdk = PHHueSDK()
        phHueSdk.startUp()
        phHueSdk.enableLogging(false)
        
        bridgesTried = []
        
        if let notificationManager = PHNotificationManager.default() {
            
            // The SDK will send the following notifications in response to events:
            //
            // - LOCAL_CONNECTION_NOTIFICATION
            // This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
            //
            // - NO_LOCAL_CONNECTION_NOTIFICATION
            // This notification will notify that there is no connection with the bridge
            //
            // - NO_LOCAL_AUTHENTICATION_NOTIFICATION
            // This notification will notify that there is no authentication against the bridge
            notificationManager.register(self, with: #selector(self.localConnection) , forNotification: LOCAL_CONNECTION_NOTIFICATION)
            notificationManager.register(self, with: #selector(self.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
            notificationManager.register(self, with: #selector(self.notAuthenticated), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION)
            
            notificationManager.register(self, with: #selector(self.authenticationSuccess), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
            notificationManager.register(self, with: #selector(self.authenticationFailed), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
            notificationManager.register(self, with: #selector(self.noLocalConnection), forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
            notificationManager.register(self, with: #selector(self.noLocalBridge), forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
            notificationManager.register(self, with: #selector(self.buttonNotPressed(notification:)), forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
        }
        
        hueState = .connecting
        self.delegate?.changeState(hueState, mode:self, message:"Connecting...")
        
        // The local heartbeat is a regular timer event in the SDK. Once enabled the SDK regular collects the current state of resources managed by the bridge into the Bridge Resources Cache
        self.enableLocalHeartbeat()
    }
    
    func watchReachability() {
        reachability.whenReachable = { reachability in
            print(" ---> Reachable")
            DispatchQueue.main.async {
                if self.hueState != .connected {
                    self.bridgesTried = []
                    self.searchForBridgeLocal()
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            print(" ---> Unreachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
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
    
    func runScene(sceneName: String, direction: TTModeDirection, doubleTap: Bool, defaultIdentifier: String) {
        if !phHueSdk.localConnected() {
            self.searchForBridgeLocal()
            return
        }
        
        let bridgeSendAPI = PHBridgeSendAPI()
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        var defaultScene: PHScene?
        var sceneIdentifier: String? = self.action.optionValue(doubleTap ? TTModeHueConstants.kDoubleTapHueScene : TTModeHueConstants.kHueScene, direction: direction) as? String
        var scenes: Array<Dictionary<String, String>> = []
        for (_, value) in (cache?.scenes)! {
            let scene = value as! PHScene
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
        
        bridgeSendAPI.activateScene(withIdentifier: sceneIdentifier, onGroup: "0") { (errors: [Any]?) in
            print(" Scene change: \(sceneIdentifier) (\(errors))")
        }
    }
    
    func runTTModeHueSceneEarlyEvening(direction: TTModeDirection) {
        self.runScene(sceneName: "TTModeHueSceneEarlyEvening", direction: direction, doubleTap: false, defaultIdentifier: "TT-ee-1")
    }
    
    func doubleRunTTModeHueSceneEarlyEvening(direction: TTModeDirection) {
        self.runScene(sceneName: "TTModeHueSceneEarlyEvening", direction: direction, doubleTap: true, defaultIdentifier: "TT-ee-2")
    }
    
    func runTTModeHueSceneLateEvening(direction: TTModeDirection) {
        self.runScene(sceneName: "TTModeHueSceneLateEvening", direction: direction, doubleTap: false, defaultIdentifier: "TT-le-1")
    }
    
    func doubleRunTTModeHueSceneLateEvening(direction: TTModeDirection) {
        self.runScene(sceneName: "TTModeHueSceneLateEvening", direction: direction, doubleTap: true, defaultIdentifier: "TT-le-2")
    }
    
    func runTTModeHueOff(direction: TTModeDirection) {
        //    NSLog(@"Running scene off... %d", direction);
        self.runTTModeHueSleep(direction: direction, duration: 1)
    }
    
    func runTTModeHueSleep(directionNumber: NSNumber) {
        let direction = TTModeDirection(rawValue: directionNumber.intValue)
        let sceneDuration: Int = self.action.mode.actionOptionValue(TTModeHueConstants.kHueDuration, actionName: "TTModeHueSleep", direction: direction!) as! Int
        self.runTTModeHueSleep(direction: direction!, duration: sceneDuration)
    }
    
    func doubleRunTTModeHueSleep(direction: TTModeDirection) {
        //    NSLog(@"Running scene off... %d", direction);
        let sceneDuration: Int = self.action.mode.actionOptionValue(TTModeHueConstants.kHueDoubleTapDuration, actionName: "TTModeHueSleep", direction: direction) as! Int
        self.runTTModeHueSleep(direction: direction, duration: sceneDuration)
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
    
    func runTTModeHueSleep(direction: TTModeDirection, duration sceneDuration: Int) {
        if !phHueSdk.localConnected() {
            self.searchForBridgeLocal()
            return
        }

        //    NSLog(@"Running scene off... %d", direction);
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        let sceneTransition = sceneDuration * 10
        
        if cache?.lights == nil {
            print(" ---> Not running sleep, no lights found")
            return
        }
        
        for (_, value) in (cache?.lights)! {
            let light = value as! PHLight
            let lightState = PHLightState()
            lightState.on = NSNumber(value: false)
            lightState.alert = PHLightAlertMode.init(0)
            lightState.transitionTime = NSNumber(value: sceneTransition)
            lightState.brightness = NSNumber(value: 0)
            
            DispatchQueue.main.async {
                bridgeSendAPI.updateLightState(forId: light.identifier, with: lightState, completionHandler: {(errors) in
                    print(" ---> Sleep light in \(sceneTransition): \(errors)")
                })
            }
        }
    }
    
    func runTTModeHueRandom(direction: TTModeDirection) {
        self.runTTModeHueRandom(direction: direction, doubleTap: false)
    }
    
    func doubleRunTTModeHueRandom(direction: TTModeDirection) {
        self.runTTModeHueRandom(direction: direction, doubleTap: true)
    }
    
    func runTTModeHueRandom(direction: TTModeDirection, doubleTap: Bool) {
        if !phHueSdk.localConnected() {
            self.searchForBridgeLocal()
            return
        }

        //    NSLog(@"Running scene off... %d", direction);
        let cache: PHBridgeResourcesCache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI: PHBridgeSendAPI = PHBridgeSendAPI()
        let randomColors = TTHueRandomColors(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomColors : TTModeHueConstants.kRandomColors), direction: direction) as! Int))
        let randomBrightnesses = TTHueRandomBrightness(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomBrightness : TTModeHueConstants.kRandomBrightness), direction: direction) as! Int))
        let randomSaturation = TTHueRandomSaturation(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomSaturation : TTModeHueConstants.kRandomSaturation), direction: direction) as! Int))
        let randomColor: Int = Int(arc4random_uniform(MAX_HUE))
        
        if cache.lights == nil {
            print(" ---> Not running random, no lights found")
            return
        }
        
        for (_, value) in cache.lights {
            let light = value as! PHLight
            let lightState = PHLightState()
            
            if (randomColors == .allSame) || (randomColors == .someDifferent && arc4random() % 10 > 5) {
                lightState.hue = randomColor as NSNumber!
            } else {
                lightState.hue = Int(arc4random() % MAX_HUE) as NSNumber!
            }
            
            if randomBrightnesses == .low {
                lightState.brightness = Int(arc4random() % 100) as NSNumber!
            } else if randomBrightnesses == .varied {
                lightState.brightness = Int(arc4random() % MAX_BRIGHTNESS) as NSNumber!
            } else if randomBrightnesses == .high {
                lightState.brightness = Int(254) as NSNumber!
            }
            
            if randomSaturation == .low {
                lightState.saturation = Int(174) as NSNumber!
            } else if randomSaturation == .varied {
                lightState.saturation = Int(254 - Int(arc4random_uniform(80))) as NSNumber!
            } else if randomSaturation == .high {
                lightState.saturation = Int(254) as NSNumber!
            }
            
            DispatchQueue.main.async {
                bridgeSendAPI.updateLightState(forId: light.identifier, with: lightState, completionHandler: {(errors) in
                    
                })
            }
        }
    }
    
    // MARK: Hue Init
    
    /**
     Notification receiver for successful local connection
     */
    func localConnection() {
        // Check current connection state
        self.checkConnectionState()
    }
    /**
     Notification receiver for failed local connection
     */
    func noLocalConnection() {
        // Check current connection state
        self.checkConnectionState()
    }
    
    /**
     Notification receiver for failed local authentication
     */
    func notAuthenticated() {
        self.perform(#selector(self.doAuthentication), with: nil, afterDelay: 0.5)
    }

    /**
     Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
     */
    func checkConnectionState() {
        if !phHueSdk.localConnected() {
//            self.showNoConnectionDialog()
            self.searchForBridgeLocal()
        } else {
            // One of the connections is made, remove popups and loading views
            if hueState != .connected {
                hueState = .connected
                self.delegate?.changeState(hueState, mode: self, message: nil)
                self.saveRecentBridge()
                self.ensureScenes(force: true)
            } else {
                self.ensureScenes()
            }
        }
    }
    
    /**
     Shows the first no connection alert
     */
    func showNoConnectionDialog() {
        NSLog("Connection to bridge lost!")
        hueState = .notConnected
        self.delegate?.changeState(hueState, mode: self, message: "Connection to Hue bridge lost")
    }
    /**
     Shows the no bridges found alert
     */
    
    func showNoBridgesFoundDialog() {
        // Insert retry logic here
        NSLog("Could not find bridge!")
        hueState = .notConnected
        self.delegate?.changeState(hueState, mode: self, message: "Could not find any Hue bridges")
    }
    /**
     Shows the not authenticated alert
     */
    
    func showNotAuthenticatedDialog() {
        hueState = .notConnected
        self.delegate?.changeState(hueState, mode: self, message: "Pushlink button not pressed within 30 seconds")
        NSLog("Pushlink button not pressed within 30 sec!")
    }
    /**
     Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
     */
    
    func searchForBridgeLocal(reset: Bool = false) {
        // In case if in pushlink loop
        phHueSdk.cancelPushLinkAuthentication()

        // Stop heartbeats
        self.disableLocalHeartbeat()
        // Start search
        hueState = .connecting
        self.delegate?.changeState(hueState, mode: self, message: "Searching for a Hue bridge...")
        
        // Add dispatch_once token
        let prefs = UserDefaults.standard
        var recentBridgeId = prefs.string(forKey: TTModeHueConstants.kHueRecentBridgeId)
        var recentBridgeIp = prefs.string(forKey: TTModeHueConstants.kHueRecentBridgeIp)
        if recentBridgeIp == nil {
            let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
            recentBridgeIp = cache?.bridgeConfiguration?.ipaddress
            recentBridgeId = cache?.bridgeConfiguration?.bridgeId
        }
        if (reset || recentBridgeIp != nil) {
            if recentBridgeIp == nil || bridgesTried.contains(recentBridgeIp!) {
//                // If can't connect to a specific bridge, take it off recent prefs.
//                prefs.removeObject(forKey: TTModeHueConstants.kHueRecentBridgeId)
//                prefs.removeObject(forKey: TTModeHueConstants.kHueRecentBridgeIp)
//                prefs.synchronize()

                if let foundBridges = prefs.array(forKey: TTModeHueConstants.kHueFoundBridges) as? [[String: String]] {
                    for foundBridge: [String: String] in foundBridges {
                        if !bridgesTried.contains(foundBridge["ipAddress"]!) {
                            print(" ---> Attempting connect to different Hue: \(foundBridge["ipAddress"]!)")
                            self.bridgeSelectedWithIpAddress(ipAddress: foundBridge["ipAddress"]!, andBridgeId: foundBridge["bridgeId"]!)
                            return
                        }
                    }
                }
            } else {
                print(" ---> Attempting connect to Hue: \(recentBridgeIp!)")
                self.bridgeSelectedWithIpAddress(ipAddress: recentBridgeIp!, andBridgeId: recentBridgeId!)
                return
            }
        }
        
        if self.bridgeToken == 0 {
            self.bridgeToken = 1
            print(" ---> No Hue bridge found, searching for bridges...")
            self.bridgeSearch = PHBridgeSearching(upnpSearch: true, andPortalSearch: true, andIpAdressSearch: true)
            self.bridgeSearch.startSearch(completionHandler: { (bridgesFound: [AnyHashable : Any]?) in
                /***************************************************
                 The search is complete, check whether we found a bridge
                 *****************************************************/
                // Check for results
                self.bridgesTried = []
                
                if let bridgeCount = bridgesFound?.count, bridgeCount > 0 {
                    self.hueState = .bridgeSelect
                    self.delegate?.changeState(self.hueState, mode: self, message: bridgesFound)
                } else {
                    /***************************************************
                     No bridge was found was found. Tell the user and offer to retry..
                     *****************************************************/
                    // No bridges were found, show this to the user
                    self.showNoBridgesFoundDialog()
                    self.delayReconnectToFoundBridges()
                }
                
                self.bridgeToken = 0
            })
        }
    }
    
    func delayReconnectToFoundBridges() {
        let prefs = UserDefaults.standard
        let foundBridges = prefs.array(forKey: TTModeHueConstants.kHueFoundBridges) as? [[String: String]]
        
        if let bridgeCount = foundBridges?.count, bridgeCount > 0 {
            // Try again if bridges known
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10), execute: {
                if self.hueState != .connected {
                    self.searchForBridgeLocal()
                }
            })
        }
    }
    
    func bridgeSelectedWithIpAddress(ipAddress: String, andBridgeId bridgeId: String) {
        print(" ---> Selected bridge: \(ipAddress) - \(bridgeId)")
        let prefs = UserDefaults.standard
        
        prefs.set(bridgeId, forKey: TTModeHueConstants.kHueRecentBridgeId)
        prefs.set(ipAddress, forKey: TTModeHueConstants.kHueRecentBridgeIp)
        prefs.synchronize()
        
        bridgesTried.append(ipAddress)
        
        hueState = .connecting
        self.delegate?.changeState(hueState, mode: self, message: "Connecting to Hue bridge...")
        phHueSdk.setBridgeToUseWithId(bridgeId, ipAddress: ipAddress)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.enableLocalHeartbeat()
        }
    }
    
    func saveRecentBridge() {
        bridgesTried = []
        
        let prefs = UserDefaults.standard
        if let recentBridgeId = prefs.object(forKey: TTModeHueConstants.kHueRecentBridgeId),
            let recentBridgeIp = prefs.object(forKey: TTModeHueConstants.kHueRecentBridgeIp) {
            var foundBridges = prefs.array(forKey: TTModeHueConstants.kHueFoundBridges) as? [[String: String]] ?? []
            let saved = foundBridges.contains(where: { (foundBridge) -> Bool in
                foundBridge["ipAddress"] == recentBridgeIp as? String
            })
            if !saved {
                foundBridges.append(["ipAddress": recentBridgeIp as! String, "bridgeId": recentBridgeId as! String])
                print(" ---> Saving new bridge: \(foundBridges)")
                prefs.set(foundBridges, forKey: TTModeHueConstants.kHueFoundBridges)
                prefs.synchronize()
            }
        }

    }
    
    /**
     Starts the local heartbeat with a 10 second interval
     */
    func enableLocalHeartbeat() {
        /***************************************************
         The heartbeat processing collects data from the bridge
         so now try to see if we have a bridge already connected
         *****************************************************/
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        if cache?.bridgeConfiguration?.ipaddress != nil {
            // Enable heartbeat with interval of 10 seconds
            phHueSdk.enableLocalConnection()
        } else {
            // Automaticly start searching for bridges
            self.searchForBridgeLocal()
        }
    }
    
    /**
     Stops the local heartbeat
     */
    func disableLocalHeartbeat() {
        phHueSdk.disableLocalConnection()
    }
    
    /**
     Start the local authentication process
     */
    func doAuthentication() {
        // Disable heartbeats
        self.disableLocalHeartbeat()

        /***************************************************
         To be certain that we own this bridge we must manually
         push link it. Here we display the view to do this.
         *****************************************************/
        hueState = .pushlink
        self.delegate?.changeState(hueState, mode: self, message: nil)
        
        /***************************************************
         Start the push linking process.
         *****************************************************/
        // Start pushlinking when the interface is shown
        self.startPushLinking()
    }
    
    func startPushLinking() {
        /***************************************************
         Set up the notifications for push linkng
         *****************************************************/
        // Register for notifications about pushlinking
//        let phNotificationMgr: PHNotificationManager = PHNotificationManager.defaultManager()
//        phNotificationMgr.deregisterObjectForAllNotifications(self)
//        phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationSuccess),
//                                         forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
//        phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationFailed),
//                                         forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
//        phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalConnection),
//                                         forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
//        phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalBridge),
//                                         forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
//        phNotificationMgr.registerObject(self, withSelector: #selector(self.buttonNotPressed(_:)),
//                                         forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
        // Call to the hue SDK to start pushlinking process
        /***************************************************
         Call the SDK to start Push linking.
         The notifications sent by the SDK will confirm success
         or failure of push linking
         *****************************************************/
        phHueSdk.startPushlinkAuthentication()
    }
    /**
     Notification receiver which is called when the pushlinking was successful
     */
    
    func authenticationSuccess() {
        /***************************************************
         The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
         was received. We have confirmed the bridge.
         De-register for notifications and call
         pushLinkSuccess on the delegate
         *****************************************************/
        // Deregister for all notifications
//        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
        hueState = .connected
        self.delegate?.changeState(hueState, mode: self, message: nil)
        self.saveRecentBridge()
        self.disableLocalHeartbeat()
        // Start local heartbeat
        self.perform(#selector(self.enableLocalHeartbeat), with: nil, afterDelay: 1)
    }
    /**
     Notification receiver which is called when the pushlinking failed because the time limit was reached
     */
    
    func authenticationFailed() {
        // Deregister for all notifications
//        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
        // Inform delegate
        self.pushlinkFailed(error: PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_TIME_LIMIT_REACHED.rawValue), userInfo: [
            NSLocalizedDescriptionKey : "Authentication failed: time limit reached."
        ]))
    }
    /**
     Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
     */
    
    func noLocalBridge() {
        print(" No local bridge!!")
        // Deregister for all notifications
//        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
        // Inform delegate
        self.pushlinkFailed(error: PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_NO_LOCAL_BRIDGE.rawValue), userInfo: [
            NSLocalizedDescriptionKey : "Authentication failed: No local bridge found."
        ]))
    }
    /**
     This method is called when the pushlinking is still ongoing but no button was pressed yet.
     @param notification The notification which contains the pushlinking percentage which has passed.
     */
    
    func buttonNotPressed(notification: NSNotification) {
        // Update status bar with percentage from notification
        var dict = notification.userInfo!
        let progressPercentage: Int = (dict["progressPercentage"] as! Int)
        hueState = .pushlink
        self.delegate?.changeState(hueState, mode: self, message: progressPercentage)
    }
    
    /**
     Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
     */
    
    func pushlinkFailed(error: PHError) {
        phHueSdk.cancelPushLinkAuthentication()
        // Check which error occured
        if error.code == Int(PUSHLINK_NO_CONNECTION.rawValue) {
            // No local connection to bridge
            self.noLocalConnection()
            // Start local heartbeat (to see when connection comes back)
            self.perform(#selector(self.enableLocalHeartbeat), with: nil, afterDelay: 1)
        }
        else {
            // Retry:
            // self.doAuthentication()
            
            // Bridge button not pressed in time
            self.disableLocalHeartbeat()
            self.showNotAuthenticatedDialog()
            self.searchForBridgeLocal()
        }
    }
    
    func ensureScenes(force: Bool = false) {
        let bridgeSendAPI = PHBridgeSendAPI()
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        
        if cache?.scenes == nil || cache?.lights == nil {
            print(" ---> Scenes not ready yet")
            return
        }
        
        // Collect scene ids to check against
        let scenes: [NSObject : AnyObject] = cache!.scenes as [NSObject : AnyObject]
        var foundScenes: [String] = []
        for value in scenes.values {
            let scene = value as! PHScene
            foundScenes.append(scene.identifier)
        }
        
        // Scene: All Lights Off
        if !foundScenes.contains("TT-all-off") || force {
            let scene: PHScene = PHScene()
            scene.name = "All Lights Off"
            scene.identifier = "TT-all-off"
            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
                print("Hue:SceneOff scene: \(errors)")
                for (_, value) in (cache?.lights)! {
                    let light = value as! PHLight
                    let lightState: PHLightState = light.lightState
                    lightState.on = NSNumber(booleanLiteral: true)
                    lightState.alert = PHLightAlertMode.init(0)
                    bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
                        print("Hue:SceneOff light: \(errors)")
                        self.delegate?.changeState(self.hueState, mode: self, message: nil)
                    })
                }
            })
        }
        
        if !foundScenes.contains("TT-loop") || force {
            let scene: PHScene = PHScene()
            scene.name = "Color loop"
            scene.identifier = "TT-loop"
            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
//                print("Hue:Loop scene: \(errors)")
                for (_, value) in (cache?.lights)! {
                    let light = value as! PHLight
                    let lightState: PHLightState = PHLightState()
                    lightState.on = NSNumber(booleanLiteral: true)
                    lightState.alert = PHLightAlertMode.init(0)
                    lightState.effect = EFFECT_COLORLOOP
                    bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
//                        print("Hue:Loop light: \(errors)")
                        self.delegate?.changeState(self.hueState, mode: self, message: nil)
                    })
                }
            })
        }
        
        if !foundScenes.contains("TT-ee-1") || force {
            let scene: PHScene = PHScene()
            scene.name = "Early Evening"
            scene.identifier = "TT-ee-1"
            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
//                print("Hue:EE1 scene: \(errors)")
                for (_, value) in (cache?.lights)! {
                    let light = value as! PHLight
                    let lightState = PHLightState()
                    lightState.on = NSNumber(booleanLiteral: true)
                    lightState.alert = PHLightAlertMode.init(0)
                    let point = PHUtilities.calculateXY(UIColor(red: 235/255.0, green: 206/255.0, blue: 146/255.0, alpha: 1), forModel: light.modelNumber)
                    lightState.x = NSNumber(value: Float(point.x))
                    lightState.y = NSNumber(value: Float(point.y))
                    lightState.brightness = NSNumber(value: Int(MAX_BRIGHTNESS))
                    lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
                    bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
//                        print("Hue:EE1 scene: \(errors)")
                        self.delegate?.changeState(self.hueState, mode: self, message: nil)
                    })
                }
            })
        }
        
        if !foundScenes.contains("TT-ee-2") || force {
            let scene: PHScene = PHScene()
            scene.name = "Early Evening 2"
            scene.identifier = "TT-ee-2"
            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
//                print("Hue:EE2 scene: \(errors)")
                if let lights = cache?.lights {
                    for (i, (key: _, value: value)) in lights.enumerated() {
                        let light = value as! PHLight
                        let lightState = PHLightState()
                        lightState.on = NSNumber(booleanLiteral: true)
                        lightState.alert = PHLightAlertMode.init(0)
                        var point = PHUtilities.calculateXY(UIColor(red: 245/255.0, green: 176/255.0, blue: 116/255.0, alpha: 1), forModel: light.modelNumber)
                        if i % 3 == 2 {
                            point = PHUtilities.calculateXY(UIColor(red: 44/255.0, green: 56/255.0, blue: 225/255.0, alpha: 1), forModel: light.modelNumber)
                        }
                        lightState.x = NSNumber(value: Float(point.x))
                        lightState.y = NSNumber(value: Float(point.y))
                        lightState.brightness = NSNumber(value: 200)
                        lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
                        bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
    //                        print("Hue:EE2 scene: \(errors)")
                            self.delegate?.changeState(self.hueState, mode: self, message: nil)
                        })
                    }
                }
            })
        }
        
        if !foundScenes.contains("TT-le-1") || force {
            let scene: PHScene = PHScene()
            scene.name = "Late Evening"
            scene.identifier = "TT-le-1"
            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
//                print("Hue:LE1 scene: \(errors)")
                if let lights = cache?.lights {
                    for (_, value) in lights {
                        let light = value as! PHLight
                        let lightState = PHLightState()
                        lightState.on = NSNumber(booleanLiteral: true)
                        lightState.alert = PHLightAlertMode.init(0)
                        let point = PHUtilities.calculateXY(UIColor(red: 95/255.0, green: 76/255.0, blue: 36/255.0, alpha: 1), forModel: light.modelNumber)
                        lightState.x = NSNumber(value: Float(point.x))
                        lightState.y = NSNumber(value: Float(point.y))
                        lightState.brightness = NSNumber(value: Int(Double(MAX_BRIGHTNESS)*(6/10.0)))
                        lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
                        bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
    //                        print("Hue:LE1 scene: \(errors)")
                            self.delegate?.changeState(self.hueState, mode: self, message: nil)
                        })
                    }
                }
            })
        }
        
        if !foundScenes.contains("TT-le-2") || force {
            let scene: PHScene = PHScene()
            scene.name = "Late Evening 2"
            scene.identifier = "TT-le-2"
            scene.lightIdentifiers = cache?.lights.map { (_, value) in (value as! PHLight).identifier! }
            bridgeSendAPI.saveScene(withCurrentLightStates: scene, completionHandler: {(errors) in
//                print("Hue:LE2 scene: \(errors)")
                if let lights = cache?.lights {
                    for (i, (key: _, value: value)) in lights.enumerated() {
                        let light = value as! PHLight
                        let lightState = PHLightState()
                        lightState.on = NSNumber(value: true)
                        lightState.alert = PHLightAlertMode.init(0)
                        var point = PHUtilities.calculateXY(UIColor(red: 145/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1), forModel: light.modelNumber)
                        lightState.brightness = NSNumber(value: Int(Double(MAX_BRIGHTNESS)*(6/10.0)))
                        if i % 3 == 2 {
                            point = PHUtilities.calculateXY(UIColor(red: 134/255.0, green: 56/255.0, blue: 205/255.0, alpha: 1), forModel: light.modelNumber)
                            lightState.brightness = NSNumber(value: Int(Double(MAX_BRIGHTNESS)*(8/10.0)))
                        }
                        lightState.x = NSNumber(value: Float(point.x))
                        lightState.y = NSNumber(value: Float(point.y))
                        lightState.saturation = NSNumber(value: Int(MAX_BRIGHTNESS))
                        bridgeSendAPI.save(lightState, forLightIdentifier: light.identifier, inSceneWithIdentifier: scene.identifier, completionHandler: {(errors) in
    //                        print("Hue:LE2 scene: \(errors)")
                            self.delegate?.changeState(self.hueState, mode: self, message: nil)
                        })
                    }
                }
            })
        }
        
    }
}
