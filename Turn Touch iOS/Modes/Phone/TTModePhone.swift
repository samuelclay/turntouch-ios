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
    
    static var volumeMuted: Float?
    static var modeMusic = TTModeMusic()
    
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
        
        TTModePhone.modeMusic.activate()
    }
    
    func volumeSlider() -> UISlider? {
        let volumeSlider = (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)
        
        return volumeSlider
    }
    
    func currentVolume() -> Float? {
        let audioSession = AVAudioSession.sharedInstance()
        var volume: Float?
        do {
            try audioSession.setActive(true)
            volume = audioSession.outputVolume
        } catch {
            print("Error Setting Up Audio Session")
        }
        
        return volume
    }
    
    func runTTModePhoneVolumeUp() {
        TTModePhone.modeMusic.runTTModeMusicVolumeUp()
    }
    
    func runTTModePhoneVolumeDown() {
        TTModePhone.modeMusic.runTTModeMusicVolumeDown()
    }
    
    func runTTModePhoneVolumeMute() {
        TTModePhone.modeMusic.runTTModeMusicVolumeMute()
    }
    
    func runTTModePhoneVolumeJump() {
        let jump = self.action.optionValue(TTModePhoneConstants.jumpVolume) as! Int
        
        TTModePhone.modeMusic.setVolume(Float(jump)/100)
    }
}
