//
//  TTModeHue.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import Reachability

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

let MAX_HUE = 65535
let MAX_BRIGHTNESS = 255
let MAX_BRIGHTNESS_V2: Double = 100.0
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
    static let kCycleScenes: String = "cycleScenes"
}

protocol TTModeHueDelegate {
    func changeState(_ hueState: TTHueState, mode: TTModeHue, message: Any?)
}

protocol TTModeHueSceneDelegate {
    func sceneUploadProgress()
}

class TTModeHue: TTMode, HueBridgeDiscoveryDelegate, HueBridgeAuthenticatorDelegate, HueEventStreamDelegate {

    // New API layer
    static var hueClient: HueAPIClient?
    static var resourceCache: HueResourceCache?
    static var eventStream: HueEventStream?
    static var bridgeDiscovery: HueBridgeDiscovery?
    static var bridgeAuthenticator: HueBridgeAuthenticator?

    static var reachability: Reachability!
    static var hueState: TTHueState = TTHueState.notConnected
    static var createdScenes: [String] = []
    static var sceneQueue: OperationQueue = OperationQueue()
    static var sceneSemaphore = DispatchSemaphore(value: 1)
    static var sceneCacheSemaphore = DispatchSemaphore(value: 0)
    static var sceneCreateQueue = DispatchQueue(label: "TT:hueSceneCreate", attributes: .concurrent)
    static var sceneCreateGroup = DispatchGroup()
    static var sceneDeletionSemaphore = DispatchSemaphore(value: 1)
    static var lightSemaphore = DispatchSemaphore(value: 1)
    static var waitingOnScenes: Bool = false
    static var ensuringScenes: Bool = false
    static var latestBridge: DiscoveredBridge?
    static var delegates: MulticastDelegate<TTModeHueDelegate?> = MulticastDelegate<TTModeHueDelegate?>()
    static var sceneDelegates: MulticastDelegate<TTModeHueSceneDelegate?> = MulticastDelegate<TTModeHueSceneDelegate?>()
    static var bridgesTried: [String] = []
    static var foundBridges: [DiscoveredBridge] = []
    static var foundScenes: [String] = []
    static var sceneUploadProgress: Float = -1
    static var cycleScene: Int = 0

    required init() {
        super.init()

        TTModeHue.sceneQueue.maxConcurrentOperationCount = 1

        self.initializeHue()
        self.watchReachability()
    }

    override func activate() {
        self.removeObservers()
        // Listen for event stream updates
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUpdate(_:)), name: HueEventStream.Notifications.lightsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUpdate(_:)), name: HueEventStream.Notifications.scenesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUpdate(_:)), name: HueEventStream.Notifications.groupsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUpdate(_:)), name: HueEventStream.Notifications.configUpdated, object: nil)
    }

    override func deactivate() {
        self.removeObservers()
    }

    func initializeHue(_ force: Bool = false) {
        if TTModeHue.hueClient != nil && !force {
            return
        }

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
        return ["TTModeHueRaiseBrightness",
                "TTModeHueLowerBrightness",
                "TTModeHueShiftColorLeft",
                "TTModeHueShiftColorRight",
                "TTModeHueRandom",
                "TTModeHueCycleScenes",
                "TTModeHueSceneCustom",
                "TTModeHueSceneEarlyEvening",
                "TTModeHueSceneLateEvening",
                "TTModeHueSceneMorning",
                "TTModeHueSceneMidnightOil",
                "TTModeHueSceneColorLoop",
                "TTModeHueSleep",
                "TTModeHueSceneLightsOff"]
    }

    override func shouldUseModeOptionsFor(_ action: String) -> Bool {
        let connected = TTModeHue.hueState == .connected
        if !connected {
            return true
        }

        return false
    }

    func titleTTModeHueRaiseBrightness() -> String {
        return "Raise brightness"
    }

    func titleTTModeHueLowerBrightness() -> String {
        return "Lower brightness"
    }

    func titleTTModeHueShiftColorLeft() -> String {
        return "Shift color left"
    }

    func titleTTModeHueShiftColorRight() -> String {
        return "Shift color right"
    }

    func titleTTModeHueCycleScenes() -> String {
        return "Cycle scenes"
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
        return self.titleTTModeHueSceneCustom(direction: NSNumber(integerLiteral: TTModeDirection.no_DIRECTION.rawValue))
    }

    func titleTTModeHueSceneCustom(direction: NSNumber) -> String {
        let direction = TTModeDirection(rawValue: direction.intValue)!
        if direction != .no_DIRECTION {
            let actionName = self.actionNameInDirection(direction)
            let sceneIdentifier = self.actionOptionValue(TTModeHueConstants.kHueScene,
                                                         actionName: actionName, direction: direction) as? String
            if let scenes = TTModeHue.resourceCache?.scenes {
                for (_, scene) in scenes {
                    if scene.id == sceneIdentifier {
                        return scene.metadata.name
                    }
                }
            }
        }

        return "Trigger scene"
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

    func imageTTModeHueCycleScenes() -> String {
        return "hue_cycle.png"
    }

    func imageTTModeHueSleep() -> String {
        return "hue_sleep.png"
    }

    func imageTTModeHueRandom() -> String {
        return "hue_random.png"
    }

    func imageTTModeHueRaiseBrightness() -> String {
        return "hue_brightness_up.png"
    }

    func imageTTModeHueLowerBrightness() -> String {
        return "hue_brightness_down.png"
    }

    func imageTTModeHueShiftColorLeft() -> String {
        return "hue_shift_left.png"
    }

    func imageTTModeHueShiftColorRight() -> String {
        return "hue_shift_right.png"
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

    func runScene(sceneName: String, doubleTap: Bool, sceneIdentifier: String? = nil) {
        if TTModeHue.hueState != .connected {
            self.connectToBridge()
        }

        guard let client = TTModeHue.hueClient else {
            print(" ---> No Hue client available")
            return
        }

        var sceneId = sceneIdentifier
        if sceneId == nil {
            sceneId = self.action.optionValue(doubleTap ? TTModeHueConstants.kDoubleTapHueScene : TTModeHueConstants.kHueScene) as? String
        }

        guard let sceneIdentifier = sceneId else {
            print(" ---> No scene identifier found for \(sceneName)")
            return
        }

        Task {
            do {
                try await client.recallScene(sceneIdentifier)
                print(" ---> Scene change: \(sceneName), \(sceneIdentifier)")
            } catch {
                print(" ---> Scene change error: \(error)")
                if error.localizedDescription.contains("scene") {
                    self.ensureScenes()
                }
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
        let sceneDuration: Int = self.action.optionValue(TTModeHueConstants.kHueDoubleTapDuration) as! Int
        self.runTTModeHueSleep(duration: sceneDuration)
    }

    func runTTModeHueSleep(duration sceneDuration: Int) {
        if TTModeHue.hueState != .connected {
            self.connectToBridge()
            return
        }

        guard let client = TTModeHue.hueClient,
              let cache = TTModeHue.resourceCache else {
            print(" ---> Not running sleep, no client or cache")
            return
        }

        let transitionMs = sceneDuration * 1000  // API v2 uses milliseconds
        let roomIdentifier = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String

        let lights = cache.lights
        if lights.isEmpty {
            print(" ---> Not running sleep, no lights found")
            return
        }

        let roomLights = self.roomLights(for: roomIdentifier)

        Task {
            for (lightId, _) in lights {
                if roomIdentifier != nil && roomLights?.contains(lightId) == false {
                    continue
                }

                do {
                    try await client.updateLight(lightId, on: false, brightness: 0, transitionMs: transitionMs)
                    print(" ---> Sleep light in \(transitionMs)ms")
                } catch {
                    print(" ---> Sleep light error: \(error)")
                }
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

        guard let client = TTModeHue.hueClient,
              let cache = TTModeHue.resourceCache else {
            print(" ---> Not running random, no client or cache")
            return
        }

        let randomColors = TTHueRandomColors(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomColors : TTModeHueConstants.kRandomColors)) as! Int))
        let randomBrightnesses = TTHueRandomBrightness(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomBrightness : TTModeHueConstants.kRandomBrightness)) as! Int))
        let randomSaturation = TTHueRandomSaturation(rawValue: (self.action.optionValue((doubleTap ?
            TTModeHueConstants.kDoubleTapRandomSaturation : TTModeHueConstants.kRandomSaturation)) as! Int))
        let randomHue: Int = Int(arc4random_uniform(UInt32(MAX_HUE)))
        let randomHue2: Int = Int(arc4random_uniform(UInt32(MAX_HUE)))
        let roomIdentifier = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String

        let lights = cache.lights
        if lights.isEmpty {
            print(" ---> Not running random, no lights found")
            return
        }

        let roomLights = self.roomLights(for: roomIdentifier)

        Task {
            for (lightId, light) in lights {
                if roomIdentifier != nil && roomLights?.contains(lightId) == false {
                    continue
                }

                // Calculate hue value
                var hue: Int
                if randomColors == .allSame {
                    hue = randomHue
                } else if randomColors == .someDifferent {
                    hue = [randomHue, randomHue2].randomElement()!
                } else {
                    hue = Int(arc4random() % UInt32(MAX_HUE))
                }

                // Calculate brightness (convert to 0-100 scale for API v2)
                var brightness: Double
                if randomBrightnesses == .low {
                    brightness = Double(arc4random() % 100) / 255.0 * 100.0
                } else if randomBrightnesses == .varied {
                    brightness = Double(arc4random() % UInt32(MAX_BRIGHTNESS)) / 255.0 * 100.0
                } else {
                    brightness = 100.0
                }

                // Calculate saturation
                var saturation: Int
                if randomSaturation == .low {
                    saturation = 174
                } else if randomSaturation == .varied {
                    saturation = MAX_BRIGHTNESS - Int(arc4random_uniform(80))
                } else {
                    saturation = MAX_BRIGHTNESS
                }

                // Convert hue/saturation to xy color space
                let h = CGFloat(hue) / CGFloat(MAX_HUE)
                let s = CGFloat(saturation) / 254.0
                let color = UIColor(hue: h, saturation: s, brightness: 1.0, alpha: 1.0)
                let modelId = light.metadata?.archetype
                let xy = HueColorUtilities.calculateXY(color, forModel: modelId)

                do {
                    try await client.updateLight(lightId, on: true, brightness: brightness, xy: (Double(xy.x), Double(xy.y)))
                    print(" ---> Finished random for light \(lightId)")
                } catch {
                    print(" ---> Random light error: \(error)")
                }
            }
        }
    }

    func roomLights(for roomIdentifier: String?) -> [String]? {
        guard let cache = TTModeHue.resourceCache else { return nil }

        var roomLights: [String]? = []

        if let roomIdentifier = roomIdentifier {
            if roomIdentifier == "all" || roomIdentifier == "" || roomIdentifier == "0" {
                roomLights = Array(cache.lights.keys)
            } else {
                if let room = cache.rooms[roomIdentifier] {
                    roomLights = room.children.filter { $0.rtype == "device" || $0.rtype == "light" }.map { $0.rid }
                }
            }
        }

        return roomLights
    }

    func runTTModeHueRaiseBrightness() {
        self.changeBrightness(amount: 10.0)  // 10% in API v2 scale
    }

    func doubleRunTTModeHueRaiseBrightness() {
        self.changeBrightness(amount: 20.0)
    }

    func runTTModeHueLowerBrightness() {
        self.changeBrightness(amount: -10.0)
    }

    func doubleRunTTModeHueLowerBrightness() {
        self.changeBrightness(amount: -20.0)
    }

    func changeBrightness(amount: Double) {
        guard let client = TTModeHue.hueClient else { return }

        Task {
            do {
                let lights = try await client.fetchLights()
                let roomIdentifier = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String ?? "all"
                let roomLights = self.roomLights(for: roomIdentifier)

                // Check if all lights are the same color
                var sameColor = true
                var lastHue: Double = 0
                for light in lights {
                    if roomLights?.contains(light.id) == false {
                        continue
                    }

                    if let xy = light.color?.xy {
                        let hue = Double(xy.x) * 1000
                        if lastHue == 0 {
                            lastHue = hue
                        } else if abs(hue - lastHue) > 25 {
                            sameColor = false
                            break
                        }
                    }
                }

                if sameColor {
                    // Update all lights in the room at once using grouped_light
                    if let groupedLights = TTModeHue.resourceCache?.groupedLights {
                        // Find the grouped light for this room
                        for (groupId, _) in groupedLights {
                            let currentBrightness = lights.first?.dimming?.brightness ?? 50.0
                            let newBrightness = max(0, min(100, currentBrightness + amount))
                            try await client.updateGroupedLight(groupId, on: true, brightness: newBrightness)
                            print(" ---> Hue brightness same color complete: \(newBrightness)")
                            break
                        }
                    }
                } else {
                    // Update each light individually
                    for light in lights {
                        if roomLights?.contains(light.id) == false {
                            continue
                        }

                        let currentBrightness = light.dimming?.brightness ?? 50.0
                        let newBrightness = max(0, min(100, currentBrightness + amount))

                        try await client.updateLight(light.id, on: true, brightness: newBrightness)
                        print(" ---> Hue brightness complete: \(newBrightness)")
                    }
                }
            } catch {
                print(" ---> Brightness change error: \(error)")
            }
        }
    }

    func runTTModeHueShiftColorLeft() {
        self.shiftColor(amount: -0.05)
    }

    func doubleRunTTModeHueShiftColorLeft() {
        self.shiftColor(amount: -0.1)
    }

    func runTTModeHueShiftColorRight() {
        self.shiftColor(amount: 0.05)
    }

    func doubleRunTTModeHueShiftColorRight() {
        self.shiftColor(amount: 0.1)
    }

    func shiftColor(amount: Double) {
        guard let client = TTModeHue.hueClient else { return }

        Task {
            do {
                let lights = try await client.fetchLights()
                let roomIdentifier = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String ?? "all"
                let roomLights = self.roomLights(for: roomIdentifier)

                for light in lights {
                    if roomLights?.contains(light.id) == false {
                        continue
                    }

                    guard let currentXY = light.color?.xy else { continue }

                    // Shift the x value (hue shift in xy space)
                    var newX = currentXY.x + amount
                    if newX < 0 { newX = 1.0 + newX }
                    if newX > 1.0 { newX = newX - 1.0 }

                    try await client.updateLight(light.id, on: true, xy: (newX, currentXY.y))
                    print(" ---> Hue color shift complete: (\(newX), \(currentXY.y))")
                }
            } catch {
                print(" ---> Color shift error: \(error)")
            }
        }
    }

    func runTTModeHueCycleScenes() {
        guard let scenes = self.action.optionValue(TTModeHueConstants.kCycleScenes) as? [String],
            scenes.count > 0 else {
            return
        }

        let scene = scenes[TTModeHue.cycleScene % scenes.count]

        self.runScene(sceneName: scene, doubleTap: false, sceneIdentifier: scene)
        TTModeHue.cycleScene += 1
    }

    // MARK: - Hue Bridge

    func connectToBridge(reset: Bool = false, reauthenticate: Bool = false) {
        if TTModeHue.hueState == .connecting {
            return
        }

        TTModeHue.hueState = .connecting
        TTModeHue.delegates.invoke { (delegate) in
            delegate?.changeState(TTModeHue.hueState, mode: self, message: "Connecting to Hue...")
        }

        if reset {
            TTModeHue.bridgesTried = []
        }

        let prefs = UserDefaults.standard
        let savedBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]] ?? []

        var bridgeUntried = false
        for savedBridge in savedBridges {
            guard let serialNumber = savedBridge["serialNumber"],
                  let ip = savedBridge["ip"] else { continue }

            if TTModeHue.bridgesTried.contains(serialNumber) {
                continue
            }

            let bridge = DiscoveredBridge(
                id: serialNumber,
                internalipaddress: ip,
                port: nil
            )

            bridgeUntried = true
            TTModeHue.latestBridge = bridge
            TTModeHue.bridgesTried.append(serialNumber)

            if DEBUG_HUE {
                print(" ---> Connecting to bridge: \(savedBridge)")
            }

            if let username = savedBridge["username"], reauthenticate == false {
                self.authenticateBridge(username: username)
            } else {
                // New bridge hasn't been pushlinked yet
                TTModeHue.bridgeAuthenticator = HueBridgeAuthenticator()
                TTModeHue.bridgeAuthenticator?.delegate = self
                TTModeHue.bridgeAuthenticator?.startAuthentication(bridgeIP: ip, bridgeId: serialNumber)
            }

            break
        }

        if !bridgeUntried {
            self.findBridges()
        }
    }

    private static var discoveryTimeoutWork: DispatchWorkItem?

    func findBridges() {
        TTModeHue.hueState = .connecting
        TTModeHue.delegates.invoke { (delegate) in
            delegate?.changeState(TTModeHue.hueState, mode: self, message: "Searching for a Hue bridge...")
        }

        // Cancel any existing timeout
        TTModeHue.discoveryTimeoutWork?.cancel()

        TTModeHue.bridgeDiscovery = HueBridgeDiscovery()
        TTModeHue.bridgeDiscovery?.delegate = self
        TTModeHue.bridgeDiscovery?.startDiscovery()

        // Set a 15-second timeout for discovery
        let timeoutWork = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // Only trigger timeout if still in connecting state
            if TTModeHue.hueState == .connecting {
                print(" ---> Bridge discovery timed out")
                TTModeHue.bridgeDiscovery?.cancelDiscovery()
                self.showNoBridgesFoundDialog()
            }
        }
        TTModeHue.discoveryTimeoutWork = timeoutWork
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: timeoutWork)
    }

    func watchReachability() {
        if TTModeHue.reachability != nil {
            return
        }

        TTModeHue.reachability = Reachability()

        TTModeHue.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                print("[HUE-DIAG] Reachability changed: reachable, state=\(TTModeHue.hueState)")
                if TTModeHue.hueState != .connected {
                    print("[HUE-DIAG] Reconnecting due to reachability change")
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

    // MARK: - HueBridgeDiscoveryDelegate

    func bridgeDiscoveryStarted() {
        if DEBUG_HUE {
            print(" ---> Bridge discovery started")
        }
    }

    func bridgeDiscoveryFinished(bridges: [DiscoveredBridge]) {
        // Cancel the discovery timeout
        TTModeHue.discoveryTimeoutWork?.cancel()
        TTModeHue.discoveryTimeoutWork = nil

        if bridges.count > 0 {
            TTModeHue.hueState = .bridgeSelect
            TTModeHue.foundBridges = bridges
            TTModeHue.delegates.invoke { (delegate) in
                delegate?.changeState(TTModeHue.hueState, mode: self, message: nil)
            }
        } else {
            self.showNoBridgesFoundDialog()
        }
    }

    func bridgeDiscoveryError(_ error: HueBridgeDiscoveryError) {
        // Cancel the discovery timeout
        TTModeHue.discoveryTimeoutWork?.cancel()
        TTModeHue.discoveryTimeoutWork = nil

        print(" ---> Bridge discovery error: \(error)")

        if case .rateLimited = error {
            TTModeHue.hueState = .notConnected
            TTModeHue.delegates.invoke { (delegate) in
                delegate?.changeState(TTModeHue.hueState, mode: self, message: "Philips Hue is rate-limiting requests. Please wait a moment and try again.")
            }
        } else if case .networkError(let underlyingError) = error {
            TTModeHue.hueState = .notConnected
            TTModeHue.delegates.invoke { (delegate) in
                delegate?.changeState(TTModeHue.hueState, mode: self, message: "Network error: \(underlyingError.localizedDescription)")
            }
        } else {
            self.showNoBridgesFoundDialog()
        }
    }

    func bridgeSelected(_ bridge: DiscoveredBridge) {
        print(" ---> Selected bridge: \(bridge)")
        let prefs = UserDefaults.standard

        TTModeHue.latestBridge = bridge
        self.saveRecentBridge()
        prefs.synchronize()

        self.connectToBridge(reset: true, reauthenticate: true)
    }

    func delayReconnectToFoundBridges() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10), execute: {
            if TTModeHue.hueState != .connected {
                self.connectToBridge(reset: true)
            }
        })
    }

    func showNoConnectionDialog() {
        print("[HUE-DIAG] showNoConnectionDialog called, current state=\(TTModeHue.hueState)")
        NSLog(" ---> Connection to bridge lost")

        // Try to connect to the next saved bridge before giving up
        let prefs = UserDefaults.standard
        let savedBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]] ?? []

        var hasUntriedBridge = false
        for savedBridge in savedBridges {
            guard let serialNumber = savedBridge["serialNumber"] else { continue }
            if !TTModeHue.bridgesTried.contains(serialNumber) {
                hasUntriedBridge = true
                break
            }
        }

        if hasUntriedBridge {
            print(" ---> Trying next saved bridge...")
            // Don't reset bridgesTried, just try the next one
            self.connectToBridge(reset: false)
        } else {
            // No more saved bridges to try, fall back to discovery
            print(" ---> No more saved bridges, starting discovery...")
            TTModeHue.hueState = .notConnected
            TTModeHue.delegates.invoke { (delegate) in
                delegate?.changeState(TTModeHue.hueState, mode: self, message: "Connection to Hue bridge lost. Searching...")
            }
            // Give UI time to update then start discovery
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.findBridges()
            }
        }
    }

    func showNoBridgesFoundDialog() {
        NSLog(" ---> Could not find bridge")
        TTModeHue.hueState = .notConnected
        TTModeHue.delegates.invoke { (delegate) in
            delegate?.changeState(TTModeHue.hueState, mode: self, message: "Could not find any Hue bridges")
        }
    }

    // MARK: - HueBridgeAuthenticatorDelegate

    func authenticationStarted() {
        if DEBUG_HUE {
            print(" ---> Authentication started")
        }
    }

    func authenticationProgress(remainingSeconds: Int) {
        TTModeHue.hueState = .pushlink
        let progress = Int(Double(remainingSeconds) * (100.0/30.0))
        TTModeHue.delegates.invoke { (delegate) in
            delegate?.changeState(TTModeHue.hueState, mode: self, message: progress)
        }
    }

    func authenticationSucceeded(result: HueAuthResult) {
        self.authenticateBridge(username: result.applicationKey)
    }

    func authenticationFailed(error: HueBridgeAuthenticatorError) {
        print(" ---> Authentication failed: \(error)")

        if case .timeout = error {
            // Remove server from saved servers so it isn't automatically reconnected
            if let bridge = TTModeHue.latestBridge {
                self.removeSavedBridge(serialNumber: bridge.id)
            }

            TTModeHue.hueState = .notConnected
            TTModeHue.delegates.invoke { (delegate) in
                delegate?.changeState(TTModeHue.hueState, mode: self, message: "Pushlink button not pressed within 30 seconds")
            }
        } else {
            self.connectToBridge(reset: true)
        }
    }

    func authenticateBridge(username: String) {
        guard let bridge = TTModeHue.latestBridge else {
            print(" ---> No bridge to authenticate")
            return
        }

        if TTModeHue.hueState != .connected {
            TTModeHue.hueState = .connected
            self.saveRecentBridge(username: username)
            print("[HUE-DIAG] State -> .connected, saved bridge")

            // Initialize the API client
            TTModeHue.hueClient = HueAPIClient(bridgeIP: bridge.internalipaddress, applicationKey: username)

            // Fetch initial resources (forced to bypass debounce)
            self.fetchResources(force: true)

            // Start SSE event stream for real-time updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("[HUE-DIAG] Starting event stream, waitingOnScenes=\(TTModeHue.waitingOnScenes)")
                self.startEventStream(username: username)
                print("[HUE-DIAG] After startEventStream, waitingOnScenes=\(TTModeHue.waitingOnScenes)")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                print("[HUE-DIAG] Watchdog fired: waitingOnScenes=\(TTModeHue.waitingOnScenes), state=\(TTModeHue.hueState)")
                // If no resources fetched, consider disconnected
                if TTModeHue.waitingOnScenes && TTModeHue.hueState == .connected {
                    print("[HUE-DIAG] WATCHDOG RESET: Resetting to .notConnected because resources not fetched in 10s")
                    TTModeHue.hueState = .notConnected
                    self.findBridges()
                    appDelegate().mainViewController.optionsView.redrawOptions()
                }
            }
        } else {
            print("[HUE-DIAG] authenticateBridge skipped, already .connected")
        }
    }

    private static var lastFetchTime: Date?
    private static var fetchDebounceInterval: TimeInterval = 5.0  // Minimum seconds between fetches
    private static var isFetching = false

    func fetchResources(force: Bool = false) {
        guard let client = TTModeHue.hueClient else { return }

        // Debounce: Don't fetch if we just fetched recently (unless forced)
        if !force, let lastFetch = TTModeHue.lastFetchTime {
            let elapsed = Date().timeIntervalSince(lastFetch)
            if elapsed < TTModeHue.fetchDebounceInterval {
                if DEBUG_HUE {
                    print(" ---> Skipping fetch, last fetch was \(String(format: "%.1f", elapsed))s ago")
                }
                return
            }
        }

        // Don't start another fetch if one is in progress
        guard !TTModeHue.isFetching else {
            if DEBUG_HUE {
                print(" ---> Skipping fetch, already fetching")
            }
            return
        }

        TTModeHue.isFetching = true
        TTModeHue.waitingOnScenes = true
        TTModeHue.lastFetchTime = Date()

        Task {
            do {
                let cache = try await client.fetchAllResources()
                await MainActor.run {
                    TTModeHue.resourceCache = cache
                    TTModeHue.waitingOnScenes = false
                    TTModeHue.isFetching = false
                    print("[HUE-DIAG] fetchResources SUCCESS: \(cache.lights.count) lights, \(cache.rooms.count) rooms, \(cache.scenes.count) scenes, waitingOnScenes=false")
                    self.updateHueConfig()
                }
            } catch {
                print("[HUE-DIAG] fetchResources FAILED: \(error)")
                await MainActor.run {
                    TTModeHue.isFetching = false

                    // Check if this is a rate limit error (429)
                    if case HueAPIClientError.httpError(let statusCode, _) = error, statusCode == 429 {
                        print("[HUE-DIAG] Rate limited (429), will retry later")
                    } else {
                        print("[HUE-DIAG] Calling showNoConnectionDialog from fetchResources failure")
                        self.showNoConnectionDialog()
                    }
                }
            }
        }
    }

    func updateHueConfig() {
        TTModeHue.delegates.invoke { (delegate) in
            delegate?.changeState(TTModeHue.hueState, mode: self, message: nil)
        }
        self.ensureScenes()
        self.ensureScenesSelected()
    }

    @objc func receiveUpdate(_ notification: NSNotification?) {
        guard let notification = notification else { return }

        if notification.name == HueEventStream.Notifications.scenesUpdated {
            if TTModeHue.waitingOnScenes {
                TTModeHue.waitingOnScenes = false
                TTModeHue.sceneCacheSemaphore.signal()
            }
        }

        // Refresh cache when updates come in
        self.fetchResources()
    }

    func saveRecentBridge(username: String? = nil) {
        let prefs = UserDefaults.standard

        guard let latestBridge = TTModeHue.latestBridge else {
            print(" ---> ERROR: No latest bridge? How did we get here?")
            return
        }
        TTModeHue.bridgesTried = []

        var previouslyFoundBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]] ?? []
        var oldIndex: Int = -1
        var oldBridge: [String: String]?
        for (i, bridge) in previouslyFoundBridges.enumerated() {
            if bridge["serialNumber"] == latestBridge.id {
                oldIndex = i
                oldBridge = bridge
            }
        }

        if oldIndex != -1 {
            previouslyFoundBridges.remove(at: oldIndex)
        }
        var newBridge = ["ip": latestBridge.internalipaddress,
                         "deviceType": "Hue Bridge",
                         "friendlyName": latestBridge.friendlyName ?? "Hue Bridge",
                         "modelDescription": "Philips Hue Bridge",
                         "modelName": latestBridge.modelName,
                         "serialNumber": latestBridge.id,
                         "UDN": "uuid:\(latestBridge.id)"]
        if username != nil {
            newBridge["username"] = username
        } else if let username = oldBridge?["username"] {
            newBridge["username"] = username
        }
        previouslyFoundBridges.insert(newBridge, at: 0)

        prefs.set(previouslyFoundBridges, forKey: TTModeHueConstants.kHueSavedBridges)
        prefs.synchronize()

        if DEBUG_HUE {
            print(" ---> Saved bridges (username: \(String(describing: username))): \(previouslyFoundBridges)")
        }
    }

    func removeSavedBridge(serialNumber: String) {
        let prefs = UserDefaults.standard

        var previouslyFoundBridges = prefs.array(forKey: TTModeHueConstants.kHueSavedBridges) as? [[String: String]] ?? []
        previouslyFoundBridges = previouslyFoundBridges.filter({ (bridge) -> Bool in
            bridge["serialNumber"] != serialNumber
        })

        prefs.set(previouslyFoundBridges, forKey: TTModeHueConstants.kHueSavedBridges)
        prefs.synchronize()

        print(" ---> Removed bridge \(serialNumber): \(previouslyFoundBridges)")
    }

    func startEventStream(username: String) {
        guard let bridge = TTModeHue.latestBridge else {
            print(" ---> Error: No latest bridge...")
            return
        }

        TTModeHue.eventStream = HueEventStream(bridgeIP: bridge.internalipaddress, applicationKey: username)
        TTModeHue.eventStream?.delegate = self
        TTModeHue.eventStream?.connect()
    }

    // MARK: - HueEventStreamDelegate

    func eventStreamConnected() {
        if DEBUG_HUE {
            print(" ---> Event stream connected")
        }
    }

    func eventStreamDisconnected(error: Error?) {
        print(" ---> Event stream disconnected: \(error?.localizedDescription ?? "unknown")")
    }

    func eventStreamReceivedUpdate(lights: [HueLight]) {
        // Update cache with new light states
        for light in lights {
            TTModeHue.resourceCache?.lights[light.id] = light
        }

        // Post notification
        NotificationCenter.default.post(
            name: HueEventStream.Notifications.lightsUpdated,
            object: self,
            userInfo: ["lights": lights]
        )
    }

    func eventStreamReceivedUpdate(scenes: [HueScene]) {
        for scene in scenes {
            TTModeHue.resourceCache?.scenes[scene.id] = scene
        }

        NotificationCenter.default.post(
            name: HueEventStream.Notifications.scenesUpdated,
            object: self,
            userInfo: ["scenes": scenes]
        )
    }

    func eventStreamReceivedUpdate(rooms: [HueRoom]) {
        for room in rooms {
            TTModeHue.resourceCache?.rooms[room.id] = room
        }

        NotificationCenter.default.post(
            name: HueEventStream.Notifications.roomsUpdated,
            object: self,
            userInfo: ["rooms": rooms]
        )
    }

    // MARK: - Scenes and Rooms

    func ensureScenes(force: Bool = false) {
        guard let cache = TTModeHue.resourceCache,
              !cache.scenes.isEmpty,
              !cache.lights.isEmpty else {
            print(" ---> Scenes/lights not ready yet for scene creation")
            return
        }

        DispatchQueue.global().async {
            if TTModeHue.ensuringScenes {
                print(" ---> Already ensuring scenes...")
                return
            }
            TTModeHue.ensuringScenes = true

            if force {
                self.deleteScenes()

                if case .timedOut = TTModeHue.sceneCacheSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10)) {
                    print(" ---> Waited too long for deleted scenes to come back")
                }

                print(" ---> Done deleting, now creating scenes...")
            }

            guard let cache = TTModeHue.resourceCache else {
                print(" ---> Error with cache...")
                TTModeHue.ensuringScenes = false
                return
            }

            // Collect scene ids to check against
            TTModeHue.foundScenes = []
            if !force {
                for (sceneId, _) in cache.scenes {
                    TTModeHue.foundScenes.append(sceneId)
                }
            }

            DispatchQueue.main.async {
                TTModeHue.sceneUploadProgress = 0
                TTModeHue.sceneDelegates.invoke { (sceneDelegate) in
                    sceneDelegate?.sceneUploadProgress()
                }
            }

            self.ensureScene(sceneName: "TTModeHueSceneEarlyEvening", moment: .button_MOMENT_PRESSUP) { (light: HueLight, index: Int) in
                let color = UIColor(red: 235/255.0, green: 206/255.0, blue: 146/255.0, alpha: 1)
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: 100.0, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneEarlyEvening", moment: .button_MOMENT_DOUBLE) { (light: HueLight, index: Int) in
                var color = UIColor(red: 245/255.0, green: 176/255.0, blue: 116/255.0, alpha: 1)
                if index % 3 == 2 {
                    color = UIColor(red: 44/255.0, green: 56/255.0, blue: 225/255.0, alpha: 1)
                }
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: 78.0, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneLateEvening", moment: .button_MOMENT_PRESSUP) { (light: HueLight, index: Int) in
                let color = UIColor(red: 95/255.0, green: 76/255.0, blue: 36/255.0, alpha: 1)
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: 60.0, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneLateEvening", moment: .button_MOMENT_DOUBLE) { (light: HueLight, index: Int) in
                var color = UIColor(red: 145/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1)
                var brightness = 60.0
                if index % 3 == 1 {
                    color = UIColor(red: 134/255.0, green: 56/255.0, blue: 205/255.0, alpha: 1)
                    brightness = 80.0
                }
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: brightness, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneMorning", moment: .button_MOMENT_PRESSUP) { (light: HueLight, index: Int) in
                var color = UIColor(red: 145/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1)
                var brightness = 20.0
                if index % 3 == 1 {
                    color = UIColor(red: 144/255.0, green: 56/255.0, blue: 20/255.0, alpha: 1)
                    brightness = 50.0
                }
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: brightness, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneMorning", moment: .button_MOMENT_DOUBLE) { (light: HueLight, index: Int) in
                var color = UIColor(red: 195/255.0, green: 76/255.0, blue: 16/255.0, alpha: 1)
                var brightness = 40.0
                if index % 3 == 1 {
                    color = UIColor(red: 134/255.0, green: 76/255.0, blue: 26/255.0, alpha: 1)
                    brightness = 60.0
                }
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: brightness, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneMidnightOil", moment: .button_MOMENT_PRESSUP) { (light: HueLight, index: Int) in
                var color = UIColor(red: 145/255.0, green: 176/255.0, blue: 165/255.0, alpha: 1)
                var brightness = 20.0
                if index % 3 == 1 {
                    color = UIColor(red: 14/255.0, green: 56/255.0, blue: 200/255.0, alpha: 1)
                    brightness = 10.0
                }
                if index % 6 == 2 {
                    color = UIColor(red: 14/255.0, green: 156/255.0, blue: 200/255.0, alpha: 1)
                    brightness = 30.0
                }
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: brightness, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneMidnightOil", moment: .button_MOMENT_DOUBLE) { (light: HueLight, index: Int) in
                var color = UIColor(red: 145/255.0, green: 76/255.0, blue: 65/255.0, alpha: 1)
                var brightness = 20.0
                if index % 3 == 2 {
                    color = UIColor(red: 14/255.0, green: 26/255.0, blue: 240/255.0, alpha: 1)
                    brightness = 30.0
                }
                if index % 6 == 1 {
                    color = UIColor(red: 140/255.0, green: 16/255.0, blue: 20/255.0, alpha: 1)
                    brightness = 30.0
                }
                let xy = HueColorUtilities.calculateXY(color, forModel: light.metadata?.archetype)
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: HueDimming(brightness: brightness, minDimLevel: nil),
                    color: HueColor(xy: HueXY(x: Double(xy.x), y: Double(xy.y)), gamut: nil, gamutType: nil),
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneLightsOff", moment: .button_MOMENT_PRESSUP) { (light: HueLight, index: Int) in
                return HueSceneActionState(
                    on: HueOnState(on: false),
                    dimming: HueDimming(brightness: 0, minDimLevel: nil),
                    color: nil,
                    colorTemperature: nil,
                    effects: nil,
                    dynamics: nil
                )
            }

            self.ensureScene(sceneName: "TTModeHueSceneColorLoop", moment: .button_MOMENT_PRESSUP) { (light: HueLight, index: Int) in
                return HueSceneActionState(
                    on: HueOnState(on: true),
                    dimming: nil,
                    color: nil,
                    colorTemperature: nil,
                    effects: HueEffects(effect: "prism", effectValues: nil, status: nil, statusValues: nil),
                    dynamics: nil
                )
            }

            TTModeHue.sceneCreateGroup.notify(queue: TTModeHue.sceneCreateQueue, execute: {
                DispatchQueue.main.async {
                    TTModeHue.ensuringScenes = false
                    TTModeHue.sceneUploadProgress = -1
                    TTModeHue.sceneDelegates.invoke { (sceneDelegate) in
                        sceneDelegate?.sceneUploadProgress()
                    }
                }
            })
        }
    }

    /// Get light IDs that belong to a specific room
    func lightIdsForRoom(_ room: HueRoom, cache: HueResourceCache) -> Set<String> {
        var lightIds = Set<String>()
        let deviceIds = Set(room.children.filter { $0.rtype == "device" }.map { $0.rid })
        for device in cache.devices.values {
            if deviceIds.contains(device.id), let lightId = device.lightId {
                lightIds.insert(lightId)
            }
        }
        return lightIds
    }

    func ensureScene(sceneName: String, moment: TTButtonMoment, lightsHandler: @escaping ((_ light: HueLight, _ index: Int) -> (HueSceneActionState))) {
        let createdSceneName = "\(sceneName)-\(moment == .button_MOMENT_PRESSUP ? "single" : "double")"
        if TTModeHue.createdScenes.contains(createdSceneName) {
            return
        }

        guard let client = TTModeHue.hueClient,
              let cache = TTModeHue.resourceCache,
              !cache.lights.isEmpty else {
            return
        }

        TTModeHue.sceneCreateGroup.enter()
        TTModeHue.createdScenes.append(createdSceneName)

        DispatchQueue.global().async {
            let sceneIdentifier = self.sceneForAction(sceneName, moment: moment)
            if let sceneId = sceneIdentifier {
                if TTModeHue.foundScenes.contains(sceneId) {
                    TTModeHue.sceneCreateGroup.leave()
                    return
                }
            }

            if case .timedOut = TTModeHue.sceneSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(30)) {
                print(" ---> Hue room timed out \(String(describing: sceneIdentifier)): \(sceneName)")
            }

            print(" ---> Creating scene \(sceneName)")
            let sceneTitle = self.titleForAction(sceneName, buttonMoment: moment)

            // Find a room to associate the scene with
            guard let (roomId, room) = cache.rooms.first else {
                print(" ---> No rooms found, cannot create scene")
                TTModeHue.sceneCreateGroup.leave()
                TTModeHue.sceneSemaphore.signal()
                return
            }

            // Only include lights that belong to this room
            let roomLightIds = self.lightIdsForRoom(room, cache: cache)

            // Build scene actions only for lights in this room
            var actions: [HueSceneAction] = []
            var index = 0
            for (lightId, light) in cache.lights {
                guard roomLightIds.contains(lightId) else { continue }

                var actionState = lightsHandler(light, index)

                // Strip color action if the light doesn't support color
                if light.color == nil {
                    actionState = HueSceneActionState(
                        on: actionState.on,
                        dimming: actionState.dimming,
                        color: nil,
                        colorTemperature: actionState.colorTemperature,
                        effects: actionState.effects,
                        dynamics: actionState.dynamics
                    )
                }

                // Strip effects if the light doesn't support the requested effect
                if let requestedEffect = actionState.effects?.effect,
                   let supportedEffects = light.effects?.effectValues,
                   !supportedEffects.contains(requestedEffect) {
                    actionState = HueSceneActionState(
                        on: actionState.on,
                        dimming: actionState.dimming,
                        color: actionState.color,
                        colorTemperature: actionState.colorTemperature,
                        effects: nil,
                        dynamics: actionState.dynamics
                    )
                }

                let action = HueSceneAction(
                    target: HueResourceLink(rid: lightId, rtype: "light"),
                    action: actionState
                )
                actions.append(action)
                index += 1
            }

            if actions.isEmpty {
                print(" ---> No lights in room for scene \(sceneTitle)")
                TTModeHue.sceneCreateGroup.leave()
                TTModeHue.sceneSemaphore.signal()
                return
            }

            Task {
                do {
                    let newSceneId = try await client.createScene(name: sceneTitle, roomId: roomId, actions: actions)
                    print(" ---> Created scene \(sceneTitle): \(newSceneId)")

                    await MainActor.run {
                        TTModeHue.sceneUploadProgress = 0.5
                        TTModeHue.sceneDelegates.invoke { (sceneDelegate) in
                            sceneDelegate?.sceneUploadProgress()
                        }
                    }

                    TTModeHue.sceneCreateGroup.leave()
                    TTModeHue.sceneSemaphore.signal()

                    self.updateScenes()

                    await MainActor.run {
                        self.ensureScenesSelected()
                    }
                } catch {
                    print(" ---> Error creating scene \(sceneTitle): \(error)")
                    TTModeHue.sceneCreateGroup.leave()
                    TTModeHue.sceneSemaphore.signal()
                }
            }
        }
    }

    func deleteScenes() {
        guard let client = TTModeHue.hueClient,
              let cache = TTModeHue.resourceCache else {
            print(" ---> Not deleting scenes, no client or cache!")
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
            TTModeHue.sceneUploadProgress = 1
            TTModeHue.sceneDelegates.invoke { (sceneDelegate) in
                sceneDelegate?.sceneUploadProgress()
            }
        }

        var sceneCount = 0
        for (_, scene) in cache.scenes {
            if sceneTitles.contains(scene.metadata.name) {
                sceneCount += 1
            }
        }

        var deleteCount = 0
        for (sceneId, scene) in cache.scenes {
            if sceneTitles.contains(scene.metadata.name) {
                if case .timedOut = TTModeHue.sceneSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10)) {
                    print(" ---> Hue scene removal timed out \(sceneId): \(scene.metadata.name)")
                }

                print(" ---> Removing \(scene.metadata.name) (\(sceneId))")

                Task {
                    do {
                        try await client.deleteScene(sceneId)
                        print(" ---> Removed \(scene.metadata.name) (\(sceneId))")
                        TTModeHue.sceneSemaphore.signal()

                        await MainActor.run {
                            deleteCount += 1
                            TTModeHue.sceneUploadProgress = Float(sceneCount - deleteCount)/Float(sceneCount)
                            TTModeHue.sceneDelegates.invoke { (sceneDelegate) in
                                sceneDelegate?.sceneUploadProgress()
                            }
                        }
                    } catch {
                        print(" ---> Error removing scene: \(error)")
                        TTModeHue.sceneSemaphore.signal()
                    }
                }
            }
        }

        if case .timedOut = TTModeHue.sceneSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10)) {
            print(" ---> Hue scene removals timed out")
        }
        print(" ---> Removed all Hue scenes")

        TTModeHue.sceneSemaphore.signal()
        TTModeHue.createdScenes = []
        TTModeHue.foundScenes = []
        self.updateScenes()
    }

    func updateScenes() {
        print(" ---> Updating scenes...")

        TTModeHue.waitingOnScenes = true
        TTModeHue.foundScenes = []

        // Fetch fresh scene data (forced to bypass debounce since user requested)
        self.fetchResources(force: true)
    }

    func ensureScenesSelected() {
        guard let cache = TTModeHue.resourceCache else {
            print(" ---> Cache not ready yet for scene selection")
            return
        }
        let scenes = cache.scenes
        if scenes.isEmpty {
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

            // Double check that scene is still on bridge
            if actionScene != nil {
                if scenes[actionScene!] == nil {
                    actionScene = nil
                }
            }
            if actionDouble != nil {
                if scenes[actionDouble!] == nil {
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
            let batchActionsModel = appDelegate().modeMap.batchActions
            let batchActions = batchActionsModel.batchActions(in: direction)
            for batchAction in batchActions {
                if !batchAction.actionName.contains("Scene") {
                    continue
                }
                var singleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kHueScene, direction: direction) as? String
                var doubleScene = self.batchActionOptionValue(batchAction, optionName: TTModeHueConstants.kDoubleTapHueScene, direction: direction) as? String

                if singleScene != nil {
                    if scenes[singleScene!] == nil {
                        singleScene = nil
                    }
                }
                if doubleScene != nil {
                    if scenes[doubleScene!] == nil {
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
        guard let cache = TTModeHue.resourceCache else {
            return nil
        }

        for (sceneId, scene) in cache.scenes {
            if scene.metadata.name == sceneTitle {
                print(" ---> \(actionName) \(scene.metadata.name) is \(sceneId)")
                return sceneId
            }
        }

        return nil
    }

}
