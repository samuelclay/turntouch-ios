//
//  TTModePhone.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import MediaPlayer
import UIKit

struct TTModePhoneConstants {
    static let jumpVolume = "jumpVolume"
}

class TTModePhone: TTMode {
    
    override class func title() -> String {
        return "Phone"
    }
    
    override class func subtitle() -> String {
        return "System-level controls"
    }
    
    override class func imageName() -> String {
        return "mode_mac.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModePhoneVolumeUp",
                "TTModePhoneVolumeDown",
                "TTModePhoneVolumeJump",
                "TTModePhoneVolumeMute"]
    }
    
    func titleTTModePhoneVolumeUp() -> String {
        return "Volume up"
    }
    
    func titleTTModePhoneVolumeDown() -> String {
        return "Volume down"
    }
    
    func titleTTModePhoneVolumeMute() -> String {
        return "Mute"
    }
    
    func titleTTModePhoneVolumeJump() -> String {
        return "Jump to volume"
    }
    
    // MARK: Action images
    
    func imageTTModePhoneVolumeUp() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModePhoneVolumeDown() -> String {
        return "music_volume_down.png"
    }
    
    func imageTTModePhoneVolumeMute() -> String {
        return "music_volume_mute.png"
    }
    
    func imageTTModePhoneVolumeJump() -> String {
        return "music_volume_up.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModePhoneVolumeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModePhoneVolumeJump"
    }
    
    override func defaultWest() -> String {
        return "TTModePhoneVolumeMute"
    }
    
    override func defaultSouth() -> String {
        return "TTModePhoneVolumeDown"
    }
    
    // MARK: Actions
    
    override func activate() {
        super.activate()
        
        TTModeMusicSession.shared.activate()
    }
    
    func runTTModePhoneVolumeUp() {
        TTModeMusicSession.shared.volume(adjustment: .up)
    }
    
    func runTTModePhoneVolumeDown() {
        TTModeMusicSession.shared.volume(adjustment: .down)
    }
    
    func runTTModePhoneVolumeMute() {
        TTModeMusicSession.shared.volume(adjustment: .toggleMute)
    }
    
    func runTTModePhoneVolumeJump() {
        if let jump = self.action.optionValue(TTModePhoneConstants.jumpVolume) as? Int {
            TTModeMusicSession.shared.volume = Float(jump) / 100
        }
    }
}
