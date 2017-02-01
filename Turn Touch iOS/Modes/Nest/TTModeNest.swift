//
//  TTModeNest.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import ReachabilitySwift
import NestSDK

struct TTModeNestConstants {
    static let kNestThermostatIdentifier = "nestThermostatIdentifier"
    static let kNestSetTemperature = "nestSetTemperature"
    static let kNestSetTemperatureMode = "nestSetTemperatureMode"
}

enum TTNestState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeNestDelegate {
    func changeState(_ state: TTNestState, mode: TTModeNest)
}


class TTModeNest: TTMode, NestSDKAuthorizationViewControllerDelegate {
    
    static var reachability: Reachability!
    var delegate: TTModeNestDelegate!
    static var nestState = TTNestState.disconnected
    
    static var dataManager: NestSDKDataManager = NestSDKDataManager()
    static var deviceObserverHandles: Array<NestSDKObserverHandle> = []
    static var structuresObserverHandle: NestSDKObserverHandle = 0
    static var thermostats: [String: NestSDKThermostat] = [:]

    required init() {
        super.init()
        
        self.watchReachability()
    }
    
    override class func title() -> String {
        return "Nest"
    }
    
    override class func subtitle() -> String {
        return "Smart learning thermostat"
    }
    
    override class func imageName() -> String {
        return "mode_nest.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeNestRaiseTemp",
                "TTModeNestLowerTemp",
                "TTModeNestSetTemp",
        ]
    }
    
    // MARK: Action titles
    
    func titleTTModeNestRaiseTemp() -> String {
        return "Raise temp"
    }
    
    func titleTTModeNestLowerTemp() -> String {
        return "Lower temp"
    }
    
    func titleTTModeNestSetTemp() -> String {
        return "Set temp"
    }
    
    // MARK: Action images
    
    func imageTTModeNestRaiseTemp() -> String {
        return "Volume up"
    }
    
    func imageTTModeNestLowerTemp() -> String {
        return "Volume down"
    }
    
    func imageTTModeNestSetTemp() -> String {
        return "Mute"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeNestRaiseTemp"
    }
    
    override func defaultEast() -> String {
        return "TTModeNestSetTemp"
    }
    
    override func defaultWest() -> String {
        return "TTModeNestSetTemp"
    }
    
    override func defaultSouth() -> String {
        return "TTModeNestLowerTemp"
    }
    
    // MARK: Action methods
    
    override func activate() {
        NestSDKApplicationDelegate.sharedInstance().application(nil, didFinishLaunchingWithOptions: nil)
        
        if (NestSDKAccessToken.current() != nil) {
            observeStructures()
        }
    }
    
    override func deactivate() {
            removeObservers()
    }
    
    
    func runTTModeNestRaiseTemp() {
        
    }
    
    func runTTModeNestLowerTemp() {
        
    }
    
    func runTTModeNestSetTemp() {
        
    }
    
    // MARK: Nest devices
    
//    func foundDevices() -> [String] {
//        var devices = TTModeNest.dataManager.thermostat(withId: <#T##String!#>, block: <#T##NestSDKThermostatUpdateHandler!##NestSDKThermostatUpdateHandler!##(NestSDKThermostat?, Error?) -> Void#>)
//        if devices.count == 0 {
//            devices = self.cachedDevices()
//        }
//        
//        devices = devices.sorted {
//            (a, b) -> Bool in
//            return a.name < b.name
//        }
//        
//        return devices
//    }
//    
//    func selectedDevice() -> SonosController? {
//        var devices = self.foundDevices()
//        if devices.count == 0 {
//            return nil
//        }
//        
//        if let deviceId = self.action.mode.modeOptionValue(TTModeSonosConstants.kSonosDeviceId,
//                                                           modeDirection: appDelegate().modeMap.selectedModeDirection) as? String {
//            for foundDevice: SonosController in devices {
//                if foundDevice.uuid == deviceId {
//                    return foundDevice
//                }
//            }
//        }
//        
//        
//        return devices[0]
//    }
//    
//    func cachedDevices() -> [SonosController] {
//        var cachedDevices: [SonosController] = []
//        let prefs = UserDefaults.standard
//        guard let devices = prefs.array(forKey: TTModeSonosConstants.kSonosCachedDevices) as? [[String: String]] else {
//            return []
//        }
//        
//        for device in devices {
//            let cachedDevice = SonosController(ip: device["ip"]!, port: Int32(device["port"]!)!)
//            cachedDevice.group = device["group"]!
//            //            cachedDevice.isCoordinator = device["isCoordinator"] as! Bool
//            cachedDevice.name = device["name"]!
//            cachedDevice.uuid = device["uuid"]!
//            cachedDevices.append(cachedDevice)
//            print(" ---> Loading cached sonos: \(cachedDevice)")
//        }
//        
//        return cachedDevices
//    }
//    
//    func cacheDevices(_ devices: [SonosController]?) {
//        var cachedDevices: [[String: String]] = []
//        guard let devices = devices else {
//            return
//        }
//        
//        for device in devices {
//            var cachedDevice: [String: String] = [:]
//            cachedDevice["ip"] = device.ip
//            cachedDevice["group"] = device.group
//            //            cachedDevice["isCoordinator"] = device.isCoordinator
//            cachedDevice["name"] = device.name
//            cachedDevice["port"] = String(device.port)
//            cachedDevice["uuid"] = device.uuid
//            cachedDevices.append(cachedDevice)
//        }
//        
//        let prefs = UserDefaults.standard
//        prefs.set(cachedDevices, forKey: TTModeSonosConstants.kSonosCachedDevices)
//        prefs.synchronize()
//    }
    
    // MARK: Nest Reachability
    
    func watchReachability() {
        if TTModeNest.reachability != nil {
            return
        }
        
        TTModeNest.reachability = Reachability()
        
        TTModeNest.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if TTModeNest.nestState != .connected {
                    print(" ---> Reachable, re-connecting to Nest...")
                    self.observeStructures()
                }
            }
        }
        
        TTModeNest.reachability.whenUnreachable = { reachability in
            if TTModeNest.nestState != .connected {
                print(" ---> Unreachable, not connected")
            }
        }
        
        do {
            try TTModeNest.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func beginConnectingToNest() {
        if TTModeNest.nestState == .connecting {
            print(" ---> Already connecting to Nest...")
            return
        }
        
        TTModeNest.nestState = .connecting
        delegate?.changeState(TTModeNest.nestState, mode: self)
    }
    
    func cancelConnectingToNest() {
        TTModeNest.nestState = .disconnected
        delegate?.changeState(TTModeNest.nestState, mode: self)
    }
    
    func nestReady() {
        TTModeNest.nestState = .connected
        delegate?.changeState(TTModeNest.nestState, mode: self)
        self.observeStructures()
    }
    
    // MARK: Device delegate
    
    func viewControllerDidCancel(_ viewController: NestSDKAuthorizationViewController!) {
        print(" ---> Nest did cancel")
        self.cancelConnectingToNest()
    }
    
    func viewController(_ viewController: NestSDKAuthorizationViewController!, didFailWithError error: Error!) {
        print(" ---> Nest did fail: \(error)")
        self.cancelConnectingToNest()
    }
    
    func viewController(_ viewController: NestSDKAuthorizationViewController!, didReceiveAuthorizationCode authorizationCode: String!) {
        print(" ---> Nest Authorization: \(authorizationCode)")
        self.nestReady()
    }
    
    // MARK: - Nest Structures
    
    func observeStructures() {
        // Clean up previous observers
        self.removeObservers()
        
        // Start observing structures
        TTModeNest.structuresObserverHandle = TTModeNest.dataManager.observeStructures({
            structuresArray, error in
            
            self.logMessage("Structures updated!")
            
            // Structure may change while observing, so remove all current device observers and then set all new ones
            self.removeDevicesObservers()
            
            // Iterate through all structures and set observers for all devices
            for structure in structuresArray as! [NestSDKStructure] {
                self.logMessage("Found structure: \(structure.name ?? "[no name]")")
                
                self.observeThermostatsWithinStructure(structure)
            }
        })
    }
    
    func observeThermostatsWithinStructure(_ structure: NestSDKStructure) {
        guard let thermostats = structure.thermostats else {
            print(" ---> No thermostats yet")
            return
        }
        
        for thermostatId in thermostats as! [String] {
            let handle = TTModeNest.dataManager.observeThermostat(withId: thermostatId, block: {
                thermostat, error in
                
                if (error != nil) {
                    self.logMessage("Error observing thermostat: \(error)")
                    return
                }
                if let thermostat = thermostat {
                    self.logMessage("Thermostat \(thermostat.name) updated, temperature now: \(thermostat.ambientTemperatureF)°F")
                    TTModeNest.thermostats[thermostatId] = thermostat
                    self.delegate.changeState(TTNestState.connected, mode: self)
                }
            })
            
            TTModeNest.deviceObserverHandles.append(handle)
        }
    }
    
    func removeObservers() {
        removeDevicesObservers();
        removeStructuresObservers();
    }
    
    func removeDevicesObservers() {
        for (_, handle) in TTModeNest.deviceObserverHandles.enumerated() {
            TTModeNest.dataManager.removeObserver(withHandle: handle);
        }
        
        TTModeNest.deviceObserverHandles.removeAll()
    }
    
    func removeStructuresObservers() {
        TTModeNest.dataManager.removeObserver(withHandle: TTModeNest.structuresObserverHandle)
    }
    
    func logMessage(_ message: String) {
        print(" ---> Nest API: \(message)")
    }
    
    // MARK: NestSDKConnectWithNestButtonDelegate
    func connectWithNestButton(connectWithNestButton: NestSDKConnectWithNestButton!, didAuthorizeWithResult result: NestSDKAuthorizationManagerAuthorizationResult!, error: NSError!) {
        if (error != nil) {
            print("Process error: \(error)")
            
        } else if (result.isCancelled) {
            print("Cancelled")
            
        } else {
            print("Authorized!")
            
            observeStructures()
        }
    }
    
    func connectWithNestButtonDidUnauthorize(connectWithNestButton: NestSDKConnectWithNestButton!) {
        removeObservers()
    }
    
}
