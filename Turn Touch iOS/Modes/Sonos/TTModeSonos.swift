//
//  TTModeSonos.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import Reachability

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


struct TTModeSonosConstants {
    static let kSonosDeviceId = "sonosDeviceUUID"
    static let kSonosCachedDevices = "sonosCachedDevices"
    static let jumpVolume = "jumpVolume"
}

enum TTSonosState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeSonosDelegate {
    func changeState(_ state: TTSonosState, mode: TTModeSonos)
}

class TTModeSonos: TTMode {
    
    static var reachability: Reachability!
    var delegate: TTModeSonosDelegate!
    static var sonosState = TTSonosState.disconnected
    static var sonosManager = SonosManager.sharedInstance()

    required init() {
        super.init()

        self.watchReachability()
    }
    
    override class func title() -> String {
        return "Sonos"
    }
    
    override class func subtitle() -> String {
        return "Connected wireless speakers"
    }
    
    override class func imageName() -> String {
        return "mode_sonos.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeSonosVolumeUp",
                "TTModeSonosVolumeDown",
                "TTModeSonosVolumeMute",
                "TTModeSonosVolumeJump",
                "TTModeSonosPlayPause",
                "TTModeSonosPlay",
                "TTModeSonosPause",
                "TTModeSonosNextTrack",
                "TTModeSonosPreviousTrack",
        ]
    }
    
    override func shouldUseModeOptionsFor(_ action: String) -> Bool {
        if action == "TTModeSonosVolumeJump" {
            return false
        }

        return true
    }
    
    // MARK: Action titles
    
    func titleTTModeSonosVolumeUp() -> String {
        return "Volume up"
    }
    
    func titleTTModeSonosVolumeDown() -> String {
        return "Volume down"
    }
    
    func titleTTModeSonosVolumeMute() -> String {
        return "Mute"
    }
    
    func titleTTModeSonosVolumeJump() -> String {
        return "Jump to volume"
    }
    
    func titleTTModeSonosPlayPause() -> String {
        return "Play/pause"
    }
    
    func titleTTModeSonosPlay() -> String {
        return "Play"
    }
    
    func titleTTModeSonosPause() -> String {
        return "Pause"
    }
    
    func titleTTModeSonosNextTrack() -> String {
        return "Next track"
    }
    
    func titleTTModeSonosPreviousTrack() -> String {
        return "Previous track"
    }
    
    
    // MARK: Action images
    
    func imageTTModeSonosVolumeUp() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeSonosVolumeDown() -> String {
        return "music_volume_down.png"
    }
    
    func imageTTModeSonosVolumeMute() -> String {
        return "music_volume_mute.png"
    }
    
    func imageTTModeSonosVolumeJump() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeSonosPlayPause() -> String {
        return "music_play_pause.png"
    }
    
    func imageTTModeSonosPlay() -> String {
        return "music_play.png"
    }
    
    func imageTTModeSonosPause() -> String {
        return "music_pause.png"
    }
    
    func imageTTModeSonosNextTrack() -> String {
        return "music_ff.png"
    }
    
    func imageTTModeSonosPreviousTrack() -> String {
        return "music_rewind.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeSonosVolumeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModeSonosNextTrack"
    }
    
    override func defaultWest() -> String {
        return "TTModeSonosPlayPause"
    }
    
    override func defaultSouth() -> String {
        return "TTModeSonosVolumeDown"
    }
    
    // MARK: Action methods
    
    override func activate() {
        if self.foundDevices().count == 0 {
            self.beginConnectingToSonos()
        } else {
            TTModeSonos.sonosState = .connected
        }
        delegate?.changeState(TTModeSonos.sonosState, mode: self)
    }
    
    override func deactivate() {

    }
    
    func adjustVolume(device: SonosController, volume: Int, left: Int) {
        if left == 0 {
            return
        }
        let adjust = left > 0 ? 1 : -1
        device.setVolume(volume + adjust, mergeRequests: true, completion: { (speakers, error) in
            print(" ---> Turned volume: \(volume)+\(adjust) (\(String(describing: error)), \(String(describing: speakers))")
            self.adjustVolume(device: device, volume: volume+adjust, left: left - adjust)
        })
    }
    
    func runTTModeSonosVolumeUp() {
        if let device = self.selectedDevice() {
            device.getVolume(TimeInterval(60*60), completion: { (volume, speakers, error) in
                self.adjustVolume(device: device, volume: volume, left: 2)
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosVolumeDown() {
        if let device = self.selectedDevice() {
            device.getVolume(TimeInterval(60*60), completion: { (volume, speakers, error) in
                self.adjustVolume(device: device, volume: volume, left: -2)
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosVolumeMute() {
        if let device = self.selectedDevice() {
            device.getMute({ (mute, speakers, error) in
                device.setMute(!mute, completion: { (speakers, error) in
                    print(" ---> Muted volume: \(mute) (\(String(describing: error)), \(String(describing: speakers))")
                })
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosVolumeJump() {
        if let device = self.selectedDevice() {
            let jump = self.action.optionValue(TTModeSonosConstants.jumpVolume) as! Int
            device.setVolume(jump, mergeRequests: true, completion: { (speakers, error) in
                
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosPlayPause() {
        if let device = self.selectedDevice(coordinator: true) {
            device.togglePlayback({ (playing, speakers, error) in
                print(" ---> Toggled sonos playback \(playing): \(String(describing: speakers)) \(String(describing: error))")
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func doubleRunTTModeSonosPlayPause() {
        self.runTTModeSonosPreviousTrack()
    }
    
    func runTTModeSonosPlay() {
        if let device = self.selectedDevice(coordinator: true) {
            device.playbackStatus({ (playing, body, error) in
                if !playing {
                    device.togglePlayback({ (playing, body, errors) in
                        print(" ---> Paused sonos playback \(playing): \(String(describing: body)) \(String(describing: error))")
                        if !playing {
                            device.togglePlayback({ (playing, body, errors) in
                                print(" ---> Paused sonos playback twice \(playing): \(String(describing: body)) \(String(describing: error))")
                            })
                        }
                    })
                }
            })
        } else {
            self.beginConnectingToSonos()
        }
    }

    func doubleRunTTModeSonosPlay() {
        self.runTTModeSonosPreviousTrack()
    }
    
    func runTTModeSonosPause() {
        if let device = self.selectedDevice(coordinator: true) {
            device.playbackStatus({ (playing, body, error) in
                if playing {
                    device.togglePlayback({ (playing, body, errors) in
                        print(" ---> Paused sonos playback \(playing): \(String(describing: body)) \(String(describing: error))")
                    })
                }
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func doubleRunTTModeSonosPause() {
        self.runTTModeSonosPreviousTrack()
    }

    func runTTModeSonosNextTrack() {
        if let device = self.selectedDevice(coordinator: true) {
            device.next({ (body, error) in
                print((" ---> Next track: \(String(describing: body)) \(String(describing: error))"))
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosPreviousTrack() {
        if let device = self.selectedDevice(coordinator: true) {
            device.previous({ (body, error) in
                print((" ---> Previous track: \(String(describing: body)) \(String(describing: error))"))
                
                // Sonos pauses when going to the preview track for some reason
                self.runTTModeSonosPlay()
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    // MARK: Sonos devices
    
    func foundDevices() -> [SonosController] {
        var devices = TTModeSonos.sonosManager?.allDevices() as! [SonosController]
        if devices.count == 0 {
            devices = self.cachedDevices()
        }

        devices = devices.sorted {
            (a, b) -> Bool in
            return a.name < b.name
        }
        
        return devices
    }
    
    func selectedDevice(coordinator: Bool = false) -> SonosController? {
        let devices = self.foundDevices()
        if devices.count == 0 {
            return nil
        }
        
        if let deviceId = self.modeOptionValue(TTModeSonosConstants.kSonosDeviceId) as? String {
            for foundDevice: SonosController in devices {
                if foundDevice.uuid == deviceId {
                    // Find the coordinator in the same group as the device
                    if coordinator && !foundDevice.isCoordinator {
                        for coordinatorDevice: SonosController in devices {
                            if coordinatorDevice.isCoordinator && coordinatorDevice.group == foundDevice.group {
                                return coordinatorDevice
                            }
                        }
                    }
                    
                    return foundDevice
                }
            }
        }
        
        
        return devices[0]
    }
    
    func cachedDevices() -> [SonosController] {
        var cachedDevices: [SonosController] = []
        let prefs = preferences()
        guard let devices = prefs.array(forKey: TTModeSonosConstants.kSonosCachedDevices) as? [[String: Any]] else {
            return []
        }
        
        for device in devices {
            let ip = device["ip"] as! String
            let port = Int32(device["port"] as! String)
            if let port = port {
                let cachedDevice = SonosController(ip: ip, port: port)
            
                cachedDevice.group = device["group"] as? String
                cachedDevice.isCoordinator = device["isCoordinator"] as? Bool ?? true
                cachedDevice.name = device["name"] as? String
                cachedDevice.uuid = device["uuid"] as? String
                cachedDevices.append(cachedDevice)
                print(" ---> Loading cached sonos: \(cachedDevice)")
            }
        }
        
        return cachedDevices
    }
    
    func cacheDevices(_ devices: [SonosController]?) {
        var cachedDevices: [[String: Any]] = []
        guard let devices = devices else {
            return
        }
        
        for device in devices {
            var cachedDevice: [String: Any] = [:]
            cachedDevice["ip"] = device.ip
            cachedDevice["group"] = device.group
            cachedDevice["isCoordinator"] = device.isCoordinator
            cachedDevice["name"] = device.name
            cachedDevice["port"] = String(device.port)
            cachedDevice["uuid"] = device.uuid
            cachedDevices.append(cachedDevice)
        }
        
        let prefs = preferences()
        prefs.set(cachedDevices, forKey: TTModeSonosConstants.kSonosCachedDevices)
        prefs.synchronize()
    }
    
    func beginConnectingToSonos() {
        if TTModeSonos.sonosState == .connecting {
            print(" ---> Already connecting to sonos...")
            return
        }
        
        TTModeSonos.sonosState = .connecting
        delegate?.changeState(TTModeSonos.sonosState, mode: self)
        
        TTModeSonos.sonosManager?.discoverControllers {
            DispatchQueue.main.async(execute: {
                let devices = self.foundDevices()
                for device in devices {
                    self.deviceReady(device)
                }
                self.cacheDevices(devices)
                if devices.count == 0 {
                    self.cancelConnectingToSonos()
                }
            })
        }
    }
    
    func cancelConnectingToSonos() {
        TTModeSonos.sonosState = .connected
        delegate?.changeState(TTModeSonos.sonosState, mode: self)
    }
    
    // MARK: Device delegate
    
    func deviceReady(_ device: SonosController) {
        TTModeSonos.sonosState = .connected
        delegate?.changeState(TTModeSonos.sonosState, mode: self)
    }
    
    // MARK: Reachability
    
    func watchReachability() {
        if TTModeSonos.reachability != nil {
            return
        }
        
        TTModeSonos.reachability = Reachability()
        
        TTModeSonos.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if TTModeSonos.sonosState != .connected {
                    print(" ---> Reachable, re-connecting to Sonos...")
                    self.beginConnectingToSonos()
                }
            }
        }
        
        TTModeSonos.reachability.whenUnreachable = { reachability in
            if TTModeSonos.sonosState != .connected {
                print(" ---> Unreachable, not connected")
            }
        }
        
        do {
            try TTModeSonos.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
}
