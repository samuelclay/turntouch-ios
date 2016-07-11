//
//  TTModeWemo.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreFoundation

struct TTModeWemoConstants {
    static let kWemoDeviceLocation = "wemoDeviceLocation"
}

enum TTWemoState {
    case Disconnected
    case Connecting
    case Connected
}

protocol TTModeWemoDelegate {
    func changeState(state: TTWemoState, mode: TTModeWemo)
}

class TTModeWemo: TTMode, TTModeWemoMulticastDelegate, TTModeWemoDeviceDelegate {
    
    var delegate: TTModeWemoDelegate!
    var wemoState = TTWemoState.Disconnected
    static var multicastServer = TTModeWemoMulticastServer()
    static var foundDevices: [TTModeWemoDevice] = []
    
    required init() {
        super.init()
        
        TTModeWemo.multicastServer.delegate = self
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
        return ["TTModeWemoDeviceOn",
                "TTModeWemoDeviceOff",
                "TTModeWemoDeviceToggle"]
    }
    
    // MARK: Action titles
    
    func titleTTModeWemoDeviceOn() -> String {
        return "Turn on"
    }
    
    func titleTTModeWemoDeviceOff() -> String {
        return "Turn off"
    }
    
    func titleTTModeWemoDeviceToggle() -> String {
        return "Toggle device"
    }
    
    // MARK: Action images
    
    func imageTTModeWemoDeviceOn() -> String {
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
        return "TTModeWemoDeviceOn"
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
        if TTModeWemo.foundDevices.count == 0 {
            wemoState = .Connecting
            self.beginConnectingToWemo()
        } else {
            wemoState = .Connected
        }
        delegate?.changeState(wemoState, mode: self)
    }
    
    override func deactivate() {
        TTModeWemo.multicastServer.deactivate()
    }
    
    func runTTModeWemoDeviceOn(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.integerValue)!) {
            device.changeDeviceState(.On)
        }
    }
    
    func runTTModeWemoDeviceOff(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.integerValue)!) {
            device.changeDeviceState(.Off)
        }
    }
    
    func runTTModeWemoDeviceToggle(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.integerValue)!) {
            device.requestDeviceState {
                if device.deviceState == TTModeWemoDeviceState.On {
                    device.changeDeviceState(.Off)
                } else {
                    device.changeDeviceState(.On)
                }
            }
        }
    }
    
    // MARK: Wemo devices
    
    func selectedDevice(direction: TTModeDirection) -> TTModeWemoDevice? {
        if TTModeWemo.foundDevices.count == 0 {
            return nil
        }
        
        if let deviceLocation = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocation, direction: direction) as! String? {
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
    
    func beginConnectingToWemo() {
        wemoState = .Connecting
        delegate?.changeState(wemoState, mode: self)
        
        TTModeWemo.multicastServer.beginBroadcast()
    }
    
    func cancelConnectingToWemo() {
        wemoState = .Disconnected
        delegate?.changeState(wemoState, mode: self)
    }
    
    // MARK: Multicast delegate
    
    func foundDevice(headers: NSDictionary, host ipAddress: String, port: Int) {
        var alreadyFound = false
        
        let newDevice = TTModeWemoDevice(ipAddress: ipAddress, port: port)
        newDevice.delegate = self
        
        for device in TTModeWemo.foundDevices {
            if device.isEqualToDevice(newDevice) {
                alreadyFound = true
                break
            }
        }
        
        if alreadyFound {
            return
        }
        
        TTModeWemo.foundDevices.append(newDevice)

        newDevice.requestDeviceInfo()
    }
    
    // MARK: Device delegate
    
    func deviceReady(device: TTModeWemoDevice) {
        TTModeWemo.foundDevices = TTModeWemo.foundDevices.sort {
            (a, b) -> Bool in
            return a.deviceName?.lowercaseString < b.deviceName?.lowercaseString
        }
        
        wemoState = .Connected
        delegate?.changeState(wemoState, mode: self)
    }
}
