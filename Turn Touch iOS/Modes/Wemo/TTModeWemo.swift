//
//  TTModeWemo.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreFoundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


struct TTModeWemoConstants {
    static let kWemoDeviceLocation = "wemoDeviceLocation"
    static let kWemoFoundDevices = "wemoFoundDevices"
    static let kWemoSeenDevices = "wemoSeenDevices"
}

enum TTWemoState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeWemoDelegate {
    func changeState(_ state: TTWemoState, mode: TTModeWemo)
}

class TTModeWemo: TTMode, TTModeWemoMulticastDelegate, TTModeWemoDeviceDelegate {
    
    var delegate: TTModeWemoDelegate?
    static var wemoState = TTWemoState.disconnected
    static var multicastServer = TTModeWemoMulticastServer()
    static var foundDevices: [TTModeWemoDevice] = []
    static var recentlyFoundDevices: [TTModeWemoDevice] = []
    
    required init() {
        super.init()
        
        TTModeWemo.multicastServer.delegate = self
        
        if TTModeWemo.foundDevices.count == 0 {
            self.assembleFoundDevices()
        } else {
            self.cleanDeviceBatchActions()
        }
        
        if TTModeWemo.foundDevices.count == 0 {
            TTModeWemo.wemoState = .connecting
            self.beginConnectingToWemo()
        } else {
            TTModeWemo.wemoState = .connected
        }
        delegate?.changeState(TTModeWemo.wemoState, mode: self)
    }
    
    func resetKnownDevices() {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: TTModeWemoConstants.kWemoFoundDevices)
        prefs.synchronize()
    }
    
    func assembleFoundDevices() {
        let prefs = UserDefaults.standard
        TTModeWemo.foundDevices = []

        if let foundDevices = prefs.array(forKey: TTModeWemoConstants.kWemoFoundDevices) as? [[String: AnyObject]] {
            for device in foundDevices {
                let newDevice = self.foundDevice([:], host: device["ipaddress"] as! String, port: device["port"] as! Int, name: device["name"] as! String?, live: false)
                print(" ---> Loading wemo: \(newDevice.deviceName!) (\(newDevice.location()))")
            }
        }
        
        self.cleanDeviceBatchActions()
    }
    
    override class func title() -> String {
        return "Wemo"
    }
    
    override class func subtitle() -> String {
        return "Smart power meter and outlet"
    }
    
    override class func imageName() -> String {
        return "mode_wemo.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeWemoDeviceStart",
                "TTModeWemoDeviceOff",
                "TTModeWemoDeviceToggle"]
    }
    
    // MARK: Action titles
    
    func titleTTModeWemoDeviceStart() -> String {
        return "Turn on"
    }
    
    func titleTTModeWemoDeviceOff() -> String {
        return "Turn off"
    }
    
    func titleTTModeWemoDeviceToggle() -> String {
        return "Toggle device"
    }
    
    // MARK: Action images
    
    func imageTTModeWemoDeviceStart() -> String {
        return "next_story.png"
    }
    
    func imageTTModeWemoDeviceOff() -> String {
        return "next_site.png"
    }
    
    func imageTTModeWemoDeviceToggle() -> String {
        return "previous_story.png"
    }
    
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeWemoDeviceStart"
    }
    
    override func defaultEast() -> String {
        return "TTModeWemoDeviceToggle"
    }
    
    override func defaultWest() -> String {
        return "TTModeWemoDeviceToggle"
    }
    
    override func defaultSouth() -> String {
        return "TTModeWemoDeviceOff"
    }
    
    // MARK: Action methods
    
    override func activate() {
        delegate?.changeState(TTModeWemo.wemoState, mode: self)
        
        self.ensureDevicesSelected()
    }
    
    override func deactivate() {
        TTModeWemo.multicastServer.deactivate()
    }
    
    func runTTModeWemoDeviceStart(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.intValue)!) {
            device.changeDeviceState(.on)
        }
    }
    
    func runTTModeWemoDeviceOff(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.intValue)!) {
            device.changeDeviceState(.off)
        }
    }
    
    func runTTModeWemoDeviceToggle(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.intValue)!) {
            device.requestDeviceState {
                if device.deviceState == TTModeWemoDeviceState.on {
                    device.changeDeviceState(.off)
                } else {
                    device.changeDeviceState(.on)
                }
            }
        }
    }
    
    // MARK: Wemo devices
    
    func selectedDevice(_ direction: TTModeDirection) -> TTModeWemoDevice? {
        if TTModeWemo.foundDevices.count == 0 {
            return nil
        }
        
        if let deviceLocation = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocation) as! String? {
            for foundDevice in TTModeWemo.foundDevices {
                if foundDevice.location() == deviceLocation {
                    return foundDevice
                }
            }
        }
        
        let wemoDevice = TTModeWemo.foundDevices[0]
        
        // Store the chosen wemo device so that it is used consistently
        self.action.changeActionOption(TTModeWemoConstants.kWemoDeviceLocation, to: wemoDevice.location())
        
        return wemoDevice
    }
    
    func refreshDevices() {
        TTModeWemo.recentlyFoundDevices = []
        self.beginConnectingToWemo()
    }

    func beginConnectingToWemo() {
        TTModeWemo.wemoState = .connecting
        delegate?.changeState(TTModeWemo.wemoState, mode: self)
        
        TTModeWemo.multicastServer.delegate = self
        TTModeWemo.multicastServer.beginBroadcast()
    }
    
    func cancelConnectingToWemo() {
        TTModeWemo.wemoState = .connected
        delegate?.changeState(TTModeWemo.wemoState, mode: self)
        
        TTModeWemo.multicastServer.deactivate()
    }
    
    // MARK: Multicast delegate
    
    func foundDevice(_ headers: [String: String], host ipAddress: String, port: Int, name: String?, live: Bool) -> TTModeWemoDevice {
        let newDevice = TTModeWemoDevice(ipAddress: ipAddress, port: port)
        newDevice.delegate = self
        if name != nil {
            newDevice.deviceName = name!
        } else {
            newDevice.deviceName = newDevice.location()
        }
        
        for device in TTModeWemo.foundDevices {
            if device.isEqualToDevice(newDevice) {
                // Already found
                return device
            }
        }
        for device in TTModeWemo.recentlyFoundDevices {
            if device.isEqualToDevice(newDevice) {
                return device
            }
        }
        
        TTModeWemo.foundDevices.append(newDevice)
        TTModeWemo.recentlyFoundDevices.append(newDevice)

        newDevice.requestDeviceInfo()
        
        return newDevice
    }
    
    func finishScanning() {
        TTModeWemo.wemoState = .connected
        delegate?.changeState(TTModeWemo.wemoState, mode: self)
    }
    
    // MARK: Device delegate
    
    func deviceReady(_ device: TTModeWemoDevice) {
        let prefs = UserDefaults.standard

        TTModeWemo.foundDevices = TTModeWemo.foundDevices.sorted {
            (a, b) -> Bool in
            return a.deviceName?.lowercased() < b.deviceName?.lowercased()
        }
        
        var foundDevices: [[String: Any]] = []
        var foundIps: [String] = []
        for device in TTModeWemo.foundDevices {
            if device.deviceName == nil {
                continue
            }
            if !foundIps.contains(device.location()) {
                foundIps.append(device.location())
            } else {
                continue
            }
            foundDevices.append(["ipaddress": device.ipAddress, "port": device.port, "name": device.deviceName])
        }
        prefs.set(foundDevices, forKey: TTModeWemoConstants.kWemoFoundDevices)
        prefs.synchronize()

        TTModeWemo.wemoState = .connected
        delegate?.changeState(TTModeWemo.wemoState, mode: self)
        
        self.ensureDevicesSelected()
    }
    
    // MARK: Device selection
    
    func ensureDevicesSelected() {
        let sameMode = appDelegate().modeMap.modeInDirection(self.modeDirection).nameOfClass == self.nameOfClass
        if !sameMode {
            return
        }
        if TTModeWemo.foundDevices.count == 0 {
            return
        }
        
        for direction: TTModeDirection in [.north, .east, .west, .south] {
            let actionName = self.actionNameInDirection(direction)
            var seenDevices: [String] = self.actionOptionValue(TTModeWemoConstants.kWemoSeenDevices,
                                                               actionName: actionName,
                                                               direction: direction) as? [String] ?? []
            let actionDevice = self.actionOptionValue(TTModeWemoConstants.kWemoDeviceLocation,
                                                      actionName: actionName,
                                                      direction: direction) as? String
   
            // Sanity check actual action options for devices so as to not repeat
            if let actionDevice = actionDevice {
                if !seenDevices.contains(actionDevice) {
                    seenDevices.append(actionDevice)
                }
            }
            for batchAction in appDelegate().modeMap.batchActions.batchActions(in: direction) {
                if let deviceLocation = self.batchActionOptionValue(batchAction,
                                                                    optionName: TTModeWemoConstants.kWemoDeviceLocation,
                                                                    direction: direction) as? String {
                    if !seenDevices.contains(deviceLocation) {
                        print(" ---> Already have device \(deviceLocation) in batch action")
                        seenDevices.append(deviceLocation)
                    }
                }
            }

            
            var unseenDevices: [TTModeWemoDevice] = []
            for device in TTModeWemo.foundDevices {
                if !seenDevices.contains(device.location()) {
                    unseenDevices.append(device)
                }
            }
            
            if unseenDevices.count == 0 {
                return
            }
            
            // If the current action has no device set and is a Wemo action, set the device
            if actionDevice == nil {
                let unseenDevice = unseenDevices[0]
                print(" ---> Setting action for wemo device \(unseenDevice) to \(actionName)")
                self.changeActionOption(TTModeWemoConstants.kWemoDeviceLocation, to: unseenDevice.location(),
                                        direction: direction)
                seenDevices.append(unseenDevice.location())
                unseenDevices.remove(at: 0)
            }
            
            // Add the rest as batch actions
            if unseenDevices.count >= 1 {
                for unseenDevice in unseenDevices {
                    print(" ---> Adding batch action for wemo device \(unseenDevice) to \(actionName)")
                    let batchActionKey = appDelegate().modeMap.addBatchAction(modeDirection: self.modeDirection,
                                                                              actionDirection: direction,
                                                                              modeClassName: self.nameOfClass,
                                                                              actionName: actionName)
                    seenDevices.append(unseenDevice.location())
                    self.changeBatchActionOption(batchActionKey,
                                                 optionName: TTModeWemoConstants.kWemoDeviceLocation,
                                                 to: unseenDevice.location(),
                                                 direction: self.modeDirection,
                                                 actionDirection: direction)
                    appDelegate().mainViewController.adjustBatchActions()
                }
            }

            self.changeActionOption(TTModeWemoConstants.kWemoSeenDevices, to: seenDevices, direction: direction)
        }

    }
    
    func cleanDeviceBatchActions() {
        for direction: TTModeDirection in [.north, .east, .west, .south] {
            self.cleanDeviceBatchActions(in: direction)
        }
    }
    
    func cleanDeviceBatchActions(in direction: TTModeDirection) {
        let batchActions = appDelegate().modeMap.selectedModeBatchActions(in: direction)
        var removed = false
        var seenDevices: [String] = []
        
        for batchAction in batchActions {
            let deviceSelected = batchAction.optionValue(TTModeWemoConstants.kWemoDeviceLocation) as? String

            if deviceSelected == nil || seenDevices.contains(deviceSelected!) {
                print(" ---> Removing batch action due to unselected wemo: \(batchAction.batchActionKey!)")
                appDelegate().modeMap.removeBatchAction(for: batchAction.batchActionKey!, silent: true, actionDirection: batchAction.direction)
                appDelegate().mainViewController.batchActionsStackView.hideBatchAction(batchActionKey: batchAction.batchActionKey!)
                removed = true
            } else {
                seenDevices.append(deviceSelected!)
            }
        }
        
        if removed {
            // appDelegate().modeMap.batchActions.assemble()
        }
    }
    
}
