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
    func updateThermostat(_ thermostat: NestSDKThermostat)
}


class TTModeNest: TTMode, NestSDKAuthorizationViewControllerDelegate {
    
    static var reachability: Reachability!
    static var delegates: MulticastDelegate<TTModeNestDelegate?> = MulticastDelegate<TTModeNestDelegate?>()
    static var nestState = TTNestState.disconnected
    
    static var dataManager: NestSDKDataManager = NestSDKDataManager()
    static var deviceObserverHandles: Array<NestSDKObserverHandle> = []
    static var structuresObserverHandle: NestSDKObserverHandle = 0
    static var thermostats: [String: NestSDKThermostat] = [:]
    static var structures: [String: NestSDKStructure] = [:]

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
        return "temperature_up"
    }
    
    func imageTTModeNestLowerTemp() -> String {
        return "temperature_down"
    }
    
    func imageTTModeNestSetTemp() -> String {
        return "temperature"
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
        self.changeTemperature(direction: 1)
    }
    
    func runTTModeNestLowerTemp() {
        self.changeTemperature(direction: -1)
    }
    
    func changeTemperature(direction: Int) {
        guard let thermostat = self.selectedThermostat() else {
            print(" ---> No Nest thermostat! Can't change temperature")
            return
        }
        
        if thermostat.hvacMode == .heatCool {
            if direction > 0 {
                thermostat.targetTemperatureHighF += 1;
                thermostat.targetTemperatureLowF += 1;
            } else {
                thermostat.targetTemperatureHighF -= 1;
                thermostat.targetTemperatureLowF -= 1;
            }
        } else {
            if direction > 0 {
                thermostat.targetTemperatureF += 1;
            } else {
                thermostat.targetTemperatureF -= 1;
            }
        }
        
        TTModeNest.dataManager.setThermostat(thermostat) { (thermostat, error) in
            if error != nil {
                self.logMessage("Error while updating thermostat \(String(describing: thermostat)): \(String(describing: error))")
                return
            }
            
            self.logMessage("Updated thermostat")
        }
    }
    
    func runTTModeNestSetTemp() {
        
    }
    
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
                    self.beginConnectingToNest()
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
            print("Unable to start Nest notifier")
        }
    }
    
    func beginConnectingToNest() {
        if TTModeNest.nestState == .connecting {
            print(" ---> Already connecting to Nest...")
            return
        }
        
        TTModeNest.nestState = .connecting
        TTModeNest.delegates.invoke { (delegate) in
            delegate?.changeState(TTModeNest.nestState, mode: self)
        }
    }
    
    func authorizeNest() {
        let authorizationManager = NestSDKAuthorizationManager()
        authorizationManager.authorizeWithNestAccount(from: appDelegate().mainViewController, handler: {
            result, error in
            
            DispatchQueue.main.async {
                if error != nil {
                    print("Process error: \(String(describing: error))")
                    self.cancelConnectingToNest()
                } else if result != nil && (result?.isCancelled)! {
                    print("Cancelled")
                    self.cancelConnectingToNest()
                } else {
                    print("Authorized!")
                    self.nestReady()
                    
                }
            }
        })
    }
    
    func cancelConnectingToNest() {
        if (NestSDKAccessToken.current() != nil) {
            self.observeStructures()
        } else {
            TTModeNest.nestState = .disconnected
            TTModeNest.delegates.invoke { (delegate) in
                delegate?.changeState(TTModeNest.nestState, mode: self)
            }
        }
    }
    
    func nestReady() {
        TTModeNest.nestState = .connected
        TTModeNest.delegates.invoke { (delegate) in
            delegate?.changeState(TTModeNest.nestState, mode: self)
        }
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
                
                TTModeNest.structures[structure.structureId] = structure
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
                    self.logMessage("Error observing thermostat: \(String(describing: error))")
                    return
                }
                if let thermostat = thermostat {
                    self.logMessage("Thermostat \(thermostat.name) updated, temperature now: \(thermostat.ambientTemperatureF)°F")
                    TTModeNest.thermostats[thermostatId] = thermostat
                    TTModeNest.delegates.invoke { (delegate) in
                        delegate?.changeState(TTNestState.connected, mode: self)
                        delegate?.updateThermostat(thermostat)
                    }
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
    
    func selectedThermostat() -> NestSDKThermostat? {
        if let deviceSelected = self.modeOptionValue(TTModeNestConstants.kNestThermostatIdentifier) as? String {
            let thermostat = TTModeNest.thermostats[deviceSelected]
            return thermostat
        } else if TTModeNest.thermostats.count >= 1 {
            let thermostat = TTModeNest.thermostats.first?.value
            return thermostat
        }
        
        return nil
    }
    
}
