//
//  TTModeMusic.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeMusic: TTMode {

    override func title() -> String {
        return "Music"
    }
    
    override func subtitle() -> String {
        return "Control your music"
    }
    
    override func imageName() -> String {
        return "mode_music.png"
    }
    
    // MARK: Actions
    
    override func actions() -> [String] {
        return ["TTModeMusicVolumeDown",
                "TTModeMusicVolumeUp",
                "TTModeMusicVolumeMute",
                "TTModeMusicVolumeJump"]
    }
    
    func titleTTModeMusicVolumeUp() -> String {
        return "Music volume up"
    }
    
    func titleTTModeMusicVolumeDown() -> String {
        return "Music volume down"
    }
    
    func titleTTModeMusicVolumeMute() -> String {
        return "Mute music"
    }
    
    func titleTTModeMusicVolumeJump() -> String {
        return "Jump to volume"
    }
    
    // MARK: Action images
    
    func imageTTModeMusicVolumeUp() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeMusicVolumeDown() -> String {
        return "music_volume_down.png"
    }
    
    func imageTTModeMusicVolumeMute() -> String {
        return "music_volume_mute.png"
    }
    
    func imageTTModeMusicVolumeJump() -> String {
        return "music_volume_up.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeMusicVolumeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModeMusicVolumeJump"
    }
    
    override func defaultWest() -> String {
        return "TTModeMusicVolumeMute"
    }
    
    override func defaultSouth() -> String {
        return "TTModeMusicVolumeDown"
    }
}
