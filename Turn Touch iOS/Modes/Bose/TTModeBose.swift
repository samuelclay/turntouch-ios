//
//  TTModeBose.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/3/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import Foundation
import Reachability
import MediaPlayer

struct TTModeBoseConstants {
    static let jumpVolume = "jumpVolume"
    static let kBoseSelectedSerials = "boseSelectedSerials"
    static let kBoseFoundDevices = "boseFoundDevicesV2"
    static let kBoseSeenDevices = "boseSeenDevicesV2"
}

enum TTBoseState {
    case disconnected
    case connecting
    case connected
}

enum TTBoseConnectNextAction {
    case play
    case pause
    case playPause
    case nextTrack
    case previousTrack
}

protocol TTModeBoseDelegate {
    func changeState(_ state: TTBoseState, mode: TTModeBose)
}

class TTModeBose : TTMode, TTModeBoseMulticastDelegate, TTModeBoseDeviceDelegate {

    var lastVolume: Float?
    let ITUNES_VOLUME_CHANGE: Float = 0.06

    var delegate: TTModeBoseDelegate?
    static var boseState = TTBoseState.disconnected
    static var multicastServer = TTModeBoseMulticastServer()
    static var foundDevices: [TTModeBoseDevice] = []
    static var failedDevices: [TTModeBoseDevice] = []
    static var recentlyFoundDevices: [TTModeBoseDevice] = []

    required init() {
        super.init()
        
        TTModeBose.multicastServer.delegate = self
        
        if TTModeBose.foundDevices.count == 0 {
            self.assembleFoundDevices()
        }
        
        if TTModeBose.foundDevices.count == 0 {
            TTModeBose.boseState = .connecting
            self.beginConnectingToBose()
        } else {
            TTModeBose.boseState = .connected
        }
        delegate?.changeState(TTModeBose.boseState, mode: self)
    }
    
    func resetKnownDevices() {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: TTModeBoseConstants.kBoseFoundDevices)
        prefs.synchronize()
        
        self.assembleFoundDevices()
    }
    
    func assembleFoundDevices() {
        let prefs = UserDefaults.standard
        TTModeBose.foundDevices = []
        
        if let foundDevices = prefs.array(forKey: TTModeBoseConstants.kBoseFoundDevices) as? [[String: AnyObject]] {
            for device in foundDevices {
                let newDevice = self.foundDevice([:], host: device["ipaddress"] as! String,
                                                 port: device["port"] as! Int,
                                                 setupUrl: device["setupUrl"] as! String,
                                                 name: device["name"] as! String?,
                                                 serialNumber: device["serialNumber"] as! String?,
                                                 macAddress: device["macAddress"] as! String?,
                                                 live: false)
                print(" ---> Loading Bose: \(newDevice.deviceName!) (\(newDevice.location()))")
            }
        }
    }
   
    override class func title() -> String {
        return "Bose"
    }
    
    override class func subtitle() -> String {
        return "Control Bose speakers"
    }
    
    override class func imageName() -> String {
        return "mode_bose.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeBoseVolumeUp",
                "TTModeBoseVolumeDown",
                "TTModeBoseVolumeMute",
                "TTModeBoseVolumeJump",
                "TTModeBosePlayPause",
                "TTModeBosePlay",
                "TTModeBosePause",
                "TTModeBoseNextTrack",
                "TTModeBosePreviousTrack",
        ]
    }
    
    override func shouldUseModeOptionsFor(_ action: String) -> Bool {
        if action == "TTModeBoseVolumeJump" {
            return false
        }
        
        return true
    }
    
    // MARK: Action titles
    
    func titleTTModeBoseVolumeUp() -> String {
        return "Volume up"
    }
    
    func titleTTModeBoseVolumeDown() -> String {
        return "Volume down"
    }
    
    func titleTTModeBoseVolumeMute() -> String {
        return "Mute"
    }
    
    func titleTTModeBoseVolumeJump() -> String {
        return "Jump to volume"
    }
    
    func titleTTModeBosePlayPause() -> String {
        return "Play/pause"
    }
    
    func titleTTModeBosePlay() -> String {
        return "Play"
    }
    
    func titleTTModeBosePause() -> String {
        return "Pause"
    }
    
    func titleTTModeBoseNextTrack() -> String {
        return "Next track"
    }
    
    func titleTTModeBosePreviousTrack() -> String {
        return "Previous track"
    }
    
    
    // MARK: Action images
    
    func imageTTModeBoseVolumeUp() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeBoseVolumeDown() -> String {
        return "music_volume_down.png"
    }
    
    func imageTTModeBoseVolumeMute() -> String {
        return "music_volume_mute.png"
    }
    
    func imageTTModeBoseVolumeJump() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeBosePlayPause() -> String {
        return "music_play_pause.png"
    }
    
    func imageTTModeBosePlay() -> String {
        return "music_play.png"
    }
    
    func imageTTModeBosePause() -> String {
        return "music_pause.png"
    }
    
    func imageTTModeBoseNextTrack() -> String {
        return "music_ff.png"
    }
    
    func imageTTModeBosePreviousTrack() -> String {
        return "music_rewind.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeBoseVolumeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModeBoseNextTrack"
    }
    
    override func defaultWest() -> String {
        return "TTModeBosePlayPause"
    }
    
    override func defaultSouth() -> String {
        return "TTModeBoseVolumeDown"
    }
    
    // MARK: Action methods
    
    override func activate() {
        delegate?.changeState(TTModeBose.boseState, mode: self)
    }
    
    override func deactivate() {
        TTModeBose.multicastServer.deactivate()
    }
    
    var volumeSlider: UISlider {
        get {
            return (MPVolumeView().subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as! UISlider)
        }
    }
    
    func adjustVolume(volume: Int) {
        if volume == 0 && volumeSlider.value != 0 {
            lastVolume = volumeSlider.value
            volumeSlider.setValue(0, animated: false)
        } else {
            if lastVolume == nil {
                lastVolume = AVAudioSession.sharedInstance().outputVolume
            }
            lastVolume = min(1, lastVolume! + (Float(volume) * ITUNES_VOLUME_CHANGE))
            volumeSlider.setValue(lastVolume!, animated: false)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            lastVolume = AVAudioSession.sharedInstance().outputVolume
        } else if keyPath == "nowPlayingInfo" {
            print(" Now playing info: \(String(describing: keyPath))")
        }
    }
    
    func runTTModeBoseVolumeUp() {
        self.adjustVolume(volume: 1)
    }
    
    func runTTModeBoseVolumeDown() {
        self.adjustVolume(volume: -1)
    }
    
    func runTTModeBoseVolumeMute() {
        self.adjustVolume(volume: 0)
    }
    
    func runTTModeBoseVolumeJump() {
//        if let device = self.selectedDevice() {
//            let jump = self.action.optionValue(TTModeBoseConstants.jumpVolume) as! Int
//            device.setVolume(jump, mergeRequests: true, completion: { (speakers, error) in
//
//            })
//        } else {
//            self.beginConnectingToBose()
//        }
    }
    
    func runTTModeBosePlayPause(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.pressSpeakerButton(.play_pause)
        }
    }
    
    func doubleRunTTModeBosePlayPause(direction: NSNumber) {
        self.runTTModeBosePreviousTrack(direction: direction)
    }
    
    func runTTModeBosePlay(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.pressSpeakerButton(.play)
        }
    }
    
    func doubleRunTTModeBosePlay(direction: NSNumber) {
        self.runTTModeBosePreviousTrack(direction: direction)
    }
    
    func runTTModeBosePause(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.pressSpeakerButton(.pause)
        }
    }
    
    func doubleRunTTModeBosePause(direction: NSNumber) {
        self.runTTModeBosePreviousTrack(direction: direction)
    }
    
    func runTTModeBoseNextTrack(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.pressSpeakerButton(.next_track)
        }
    }
    
    func runTTModeBosePreviousTrack(direction: NSNumber) {
        let devices = self.selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.pressSpeakerButton(.previous_track)
        }
    }
    
    // MARK: Bose devices
    
    func selectedDevices(_ direction: TTModeDirection) -> [TTModeBoseDevice] {
        self.ensureDevicesSelected()
        var devices: [TTModeBoseDevice] = []
        
        if TTModeBose.foundDevices.count == 0 {
            return devices
        }
        
        if let selectedSerials = self.action.optionValue(TTModeBoseConstants.kBoseSelectedSerials) as? [String] {
            for foundDevice in TTModeBose.foundDevices {
                if selectedSerials.contains(foundDevice.serialNumber!) {
                    devices.append(foundDevice)
                }
            }
        }
        
        return devices
    }
    
    func refreshDevices() {
        TTModeBose.recentlyFoundDevices = []
        self.beginConnectingToBose()
    }
    
    // Bose Connection
    
    func beginConnectingToBose(ensureConnection : Bool = false) {
        TTModeBose.boseState = .connecting
        delegate?.changeState(TTModeBose.boseState, mode: self)
        
        TTModeBose.multicastServer.delegate = self
        TTModeBose.multicastServer.beginBroadcast()
    }
    
    func cancelConnectingToBose(error: String? = nil) {
        TTModeBose.boseState = .connected
        delegate?.changeState(TTModeBose.boseState, mode: self)
        
        TTModeBose.multicastServer.deactivate()
    }
    
    // MARK: Multicast delegate
    
    func foundDevice(_ headers: [String: String], host ipAddress: String, port: Int, setupUrl: String, name: String?, serialNumber: String?, macAddress: String?, live: Bool) -> TTModeBoseDevice {
        let newDevice = TTModeBoseDevice(ipAddress: ipAddress, port: port, setupUrl: setupUrl)
        newDevice.delegate = self
        
        if let name = name {
            newDevice.deviceName = name
        }
        if let serialNumber = serialNumber {
            newDevice.serialNumber = serialNumber
        }
        if let macAddress = macAddress {
            newDevice.macAddress = macAddress
        }
        
        for device in TTModeBose.foundDevices {
            if device.isEqualToDevice(newDevice) {
                // Already found
                return device
            }
        }
        for device in TTModeBose.recentlyFoundDevices {
            if device.isEqualToDevice(newDevice) {
                //                return device
            }
        }
        
        if newDevice.deviceName != nil && newDevice.serialNumber != nil {
            TTModeBose.foundDevices.append(newDevice)
        }
        TTModeBose.recentlyFoundDevices.append(newDevice)
        
        newDevice.requestDeviceInfo()
        
        return newDevice
    }
    
    func finishScanning() {
        TTModeBose.boseState = .connected
        delegate?.changeState(TTModeBose.boseState, mode: self)
    }
    
    // MARK: Device delegate
    
    func deviceReady(_ device: TTModeBoseDevice) {
        var replaceDevice: TTModeBoseDevice? = nil
        for foundDevice in TTModeBose.foundDevices {
            if foundDevice.isSameAddress(device) {
                return
            } else if foundDevice.isEqualToDevice(device) &&
                foundDevice.isSameDeviceDifferentLocation(device) {
                // Bose device changed IPs (very Bose), so correct all references and
                // store new IP in place of old
                replaceDevice = foundDevice
                break
            }
        }
        
        if let foundDevice = replaceDevice {
            // Change device to new location
            print(" ---> Re-assigning Bose device from \(foundDevice.location()) to \(device.location())")
            foundDevice.ipAddress = device.ipAddress
            foundDevice.port = device.port
        } else {
            TTModeBose.foundDevices.append(device)
        }
        
        self.storeFoundDevices()
        
        TTModeBose.boseState = .connected
        delegate?.changeState(TTModeBose.boseState, mode: self)
    }
    
    func storeFoundDevices() {
        TTModeBose.foundDevices = TTModeBose.foundDevices.sorted {
            (a, b) -> Bool in
            return a.description.lowercased() < b.description.lowercased()
        }
        
        var foundDevices: [[String: Any]] = []
        var foundSerials: [String] = []
        for device in TTModeBose.foundDevices {
            if device.deviceName == nil {
                continue
            }
            if let serialNumber = device.serialNumber {
                if !foundSerials.contains(serialNumber) {
                    foundSerials.append(serialNumber)
                } else {
                    continue
                }
            } else {
                continue
            }
            
            for (index, failedDevices) in TTModeBose.failedDevices.enumerated() {
                if failedDevices.isSameDeviceDifferentLocation(device) {
                    TTModeBose.failedDevices.remove(at: index)
                    break;
                }
            }
            
            foundDevices.append(["ipaddress": device.ipAddress, "port": device.port, "setupUrl": device.setupUrl,
                                 "name": device.deviceName!,
                                 "serialNumber": device.serialNumber!,
                                 "macAddress": device.macAddress!])
        }
        
        let prefs = UserDefaults.standard
        prefs.set(foundDevices, forKey: TTModeBoseConstants.kBoseFoundDevices)
        prefs.synchronize()
    }
    
    func deviceFailed(_ device: TTModeBoseDevice) {
        print(" ---> Bose device failed, searching for new IP...")
        
        if TTModeBose.failedDevices.contains(device) {
            print(" ---> Bose device already failed, ignoring.")
            return
        }
        
        DispatchQueue.main.async {
            appDelegate().modeMap.recordUsageMoment("boseDeviceFailed")
            TTModeBose.failedDevices.append(device)
            self.refreshDevices()
        }
    }
    
    // MARK: Device selection
    
    func ensureDevicesSelected() {
        //        let sameMode = appDelegate().modeMap.modeInDirection(self.modeDirection).nameOfClass == self.nameOfClass
        //        if !sameMode {
        //            return
        //        }
        if TTModeBose.foundDevices.count == 0 {
            return
        }
        let selectedSerials = self.action.optionValue(TTModeBoseConstants.kBoseSelectedSerials) as? [String]
        if let selectedSerials = selectedSerials {
            if selectedSerials.count > 0 {
                return;
            }
        }
        
        // Nothing selected, so select everything
        let serialNumbers = TTModeBose.foundDevices.map { (device) -> String in
            return device.serialNumber!
        }
        self.action.changeActionOption(TTModeBoseConstants.kBoseSelectedSerials, to: serialNumbers)
    }

    
}

