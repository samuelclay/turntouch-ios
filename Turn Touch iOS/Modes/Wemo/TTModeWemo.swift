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
    static let kWemoDeviceLocations = "wemoDeviceLocations"
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
        
        self.assembleFoundDevices()
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
    
    @objc func titleTTModeWemoDeviceToggle() -> String {
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
    }
    
    override func deactivate() {
        TTModeWemo.multicastServer.deactivate()
    }
    
    func runTTModeWemoDeviceStart(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.changeDeviceState(.on)
        }
    }
    
    func runTTModeWemoDeviceOff(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.changeDeviceState(.off)
        }
    }
    
    func runTTModeWemoDeviceToggle(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
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
    
    func selectedDevices(_ direction: TTModeDirection) -> [TTModeWemoDevice] {
        self.ensureDevicesSelected()
        var devices: [TTModeWemoDevice] = []
        
        if TTModeWemo.foundDevices.count == 0 {
            return devices
        }
        
        if let deviceLocations = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String] {
            for foundDevice in TTModeWemo.foundDevices {
                if deviceLocations.contains(foundDevice.location()) {
                    devices.append(foundDevice)
                }
            }
        }
        
        return devices
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
    }
    
    // MARK: Device selection
    
    func ensureDevicesSelected() {
//        let sameMode = appDelegate().modeMap.modeInDirection(self.modeDirection).nameOfClass == self.nameOfClass
//        if !sameMode {
//            return
//        }
        if TTModeWemo.foundDevices.count == 0 {
            return
        }
        let deviceLocations = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String]
        if let deviceLocations = deviceLocations {
            if deviceLocations.count > 0 {
                return;
            }
        }
        
        // Nothing selected, so select everything
        let locations = TTModeWemo.foundDevices.map { (device) -> String in
            return device.location()
        }
        self.action.changeActionOption(TTModeWemoConstants.kWemoDeviceLocations, to: locations)
    }

}
