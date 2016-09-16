//
//  TTModeSonos.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
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
    
    var delegate: TTModeSonosDelegate!
    var sonosState = TTSonosState.disconnected
    var sonosManager = SonosManager.sharedInstance()
    
    required init() {
        super.init()
        
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
                "TTModeSonosPlayPause",
                "TTModeSonosPlay",
                "TTModeSonosPause",
                "TTModeSonosNextTrack",
                "TTModeSonosPreviousTrack",
        ]
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
        return "Volume up"
    }
    
    func imageTTModeSonosVolumeDown() -> String {
        return "Volume down"
    }
    
    func imageTTModeSonosVolumeMute() -> String {
        return "Mute"
    }
    
    func imageTTModeSonosPlayPause() -> String {
        return "Play/pause"
    }
    
    func imageTTModeSonosPlay() -> String {
        return "Play"
    }
    
    func imageTTModeSonosPause() -> String {
        return "Pause"
    }
    
    func imageTTModeSonosNextTrack() -> String {
        return "Next track"
    }
    
    func imageTTModeSonosPreviousTrack() -> String {
        return "Previous track"
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
            sonosState = .connecting
            self.beginConnectingToSonos()
        } else {
            sonosState = .connected
        }
        delegate.changeState(sonosState, mode: self)
    }
    
    override func deactivate() {

    }
    
    
    func runTTModeSonosVolumeUp() {
        if let device = self.selectedDevice() {
            device.getVolume(TimeInterval(60*60), completion: { (volume, speakers, error) in
                device.setVolume(volume + 6, mergeRequests: true, completion: { (speakers, error) in
                    print(" ---> Turned volume: \(volume)+6 (\(error), \(speakers)")
                })
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosVolumeDown() {
        if let device = self.selectedDevice() {
            device.getVolume(TimeInterval(60*60), completion: { (volume, speakers, error) in
                device.setVolume(volume - 6, mergeRequests: true, completion: { (speakers, error) in
                    print(" ---> Turned volume: \(volume)-6 (\(error), \(speakers)")
                })
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosVolumeMute() {
        if let device = self.selectedDevice() {
            device.getMute({ (mute, speakers, error) in
                device.setMute(!mute, completion: { (speakers, error) in
                    print(" ---> Muted volume: \(mute) (\(error), \(speakers)")
                })
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosPlayPause() {
        if let device = self.selectedDevice() {
            device.togglePlayback({ (playing, speakers, error) in
                print(" ---> Toggled sonos playback \(playing): \(speakers) \(error)")
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosPlay() {
        if let device = self.selectedDevice() {
            device.playbackStatus({ (playing, body, error) in
                if !playing {
                    device.togglePlayback({ (playing, body, errors) in
                        print(" ---> Paused sonos playback \(playing): \(body) \(error)")
                    })
                }
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosPause() {
        if let device = self.selectedDevice() {
            device.playbackStatus({ (playing, body, error) in
                if playing {
                    device.togglePlayback({ (playing, body, errors) in
                        print(" ---> Paused sonos playback \(playing): \(body) \(error)")
                    })
                }
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosNextTrack() {
        if let device = self.selectedDevice() {
            device.next({ (body, error) in
                print((" ---> Next track: \(body) \(error)"))
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    func runTTModeSonosPreviousTrack() {
        if let device = self.selectedDevice() {
            device.previous({ (body, error) in
                print((" ---> Previous track: \(body) \(error)"))
            })
        } else {
            self.beginConnectingToSonos()
        }
    }
    
    // MARK: Sonos devices
    
    func foundDevices() -> [SonosController] {
        var devices = sonosManager?.allDevices() as! [SonosController]
        
        devices = devices.sorted {
            (a, b) -> Bool in
            return a.name < b.name
        }
        
        return devices
    }
    
    func selectedDevice() -> SonosController? {
        var devices = self.foundDevices()
        if devices.count == 0 {
            return nil
        }
        
        if let deviceId = self.action.mode.modeOptionValue(TTModeSonosConstants.kSonosDeviceId, modeDirection: appDelegate().modeMap.selectedModeDirection) as! String? {
            for foundDevice: SonosController in devices {
                if foundDevice.uuid == deviceId {
                    return foundDevice
                }
            }
        }
        
        
        return devices[0]
    }
    
    func beginConnectingToSonos() {
        sonosState = .connecting
        delegate.changeState(sonosState, mode: self)
        
        sonosManager?.discoverControllers {
            DispatchQueue.main.async(execute: {
                let devices = self.foundDevices()
                for device in devices {
                    self.deviceReady(device)
                }
                if devices.count == 0 {
                    self.cancelConnectingToSonos()
                }
            })
        }
    }
    
    func cancelConnectingToSonos() {
        sonosState = .disconnected
        delegate.changeState(sonosState, mode: self)
    }
    
    // MARK: Device delegate
    
    func deviceReady(_ device: SonosController) {
        sonosState = .connected
        delegate.changeState(sonosState, mode: self)
    }
}
