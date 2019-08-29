//
//  TTModeMusic.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import MediaPlayer

struct TTModeMusicConstants {
    static let jumpVolume = "jumpVolume"
}

class TTModeMusic: TTMode {
    
    override class func title() -> String {
        return "Music"
    }
    
    override class func subtitle() -> String {
        return "Control your music"
    }
    
    override class func imageName() -> String {
        return "mode_music.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeMusicVolumeUp",
                "TTModeMusicVolumeDown",
                "TTModeMusicVolumeJump",
                "TTModeMusicVolumeMute",
        "TTModeMusicPlayPause",
        "TTModeMusicPlay",
        "TTModeMusicPause",
        "TTModeMusicNextTrack",
        "TTModeMusicPreviousTrack"]
    }
    
    func titleTTModeMusicVolumeUp() -> String {
        return "Volume up"
    }
    
    func titleTTModeMusicVolumeDown() -> String {
        return "Volume down"
    }
    
    func titleTTModeMusicVolumeMute() -> String {
        return "Mute music"
    }
    
    func titleTTModeMusicVolumeJump() -> String {
        return "Jump to volume"
    }
    
    func titleTTModeMusicPlayPause() -> String {
        return "Play/pause"
    }
    
    func titleTTModeMusicPlay() -> String {
        return "Play music"
    }
    
    func titleTTModeMusicPause() -> String {
        return "Pause music"
    }
    
    func titleTTModeMusicNextTrack() -> String {
        return "Next track"
    }
    
    func titleTTModeMusicPreviousTrack() -> String {
        return "Previous track"
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
    
    func imageTTModeMusicPlayPause() -> String {
        return "music_play_pause.png"
    }
    
    func imageTTModeMusicPlay() -> String {
        return "music_play.png"
    }
    
    func imageTTModeMusicPause() -> String {
        return "music_pause.png"
    }
    
    func imageTTModeMusicNextTrack() -> String {
        return "music_ff.png"
    }

    func imageTTModeMusicPreviousTrack() -> String {
        return "music_rewind.png"
    }

    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeMusicVolumeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModeMusicNextTrack"
    }
    
    override func defaultWest() -> String {
        return "TTModeMusicPlayPause"
    }
    
    override func defaultSouth() -> String {
        return "TTModeMusicVolumeDown"
    }
    
    // MARK: Initialize
    
    override func activate() {
        TTModeMusicSession.shared.activate()
    }
    
    deinit {
    }
    
    override func deactivate() {
    }
    
    // MARK: Actions
    
    func runTTModeMusicVolumeUp() {
        TTModeMusicSession.shared.volume(adjustment: .up)
        print(" ---> Volume up: \(String(describing: TTModeMusicSession.shared.volume))")
    }
    
    func runTTModeMusicVolumeDown() {
        TTModeMusicSession.shared.volume(adjustment: .down)
        print(" ---> Volume down: \(String(describing: TTModeMusicSession.shared.volume))")
    }
    
    func runTTModeMusicPlayPause() {
        if TTModeMusicSession.shared.player.playbackState == .playing {
            TTModeMusicSession.shared.player.pause()
        } else {
            TTModeMusicSession.shared.player.prepareToPlay()
            TTModeMusicSession.shared.player.play()
        }
    }
    
    func doubleRunTTModeMusicPlayPause() {
        self.runTTModeMusicPreviousTrack()
    }
    
    func runTTModeMusicPlay() {
        TTModeMusicSession.shared.player.prepareToPlay()
        TTModeMusicSession.shared.player.play()
    }
    
    func runTTModeMusicPause() {
        TTModeMusicSession.shared.player.pause()
    }
    
    func runTTModeMusicNextTrack() {
        TTModeMusicSession.shared.player.skipToNextItem()
        self.runTTModeMusicPlay()
    }
    
    func doubleRunTTModeMusicNextTrack() {
        let nowPlaying = TTModeMusicSession.shared.player.nowPlayingItem
        let originalAlbum = nowPlaying?.albumTitle
        var currentAlbum: String!
        
        for _ in 0..<30 {
            TTModeMusicSession.shared.player.skipToNextItem()
            currentAlbum = TTModeMusicSession.shared.player.nowPlayingItem?.albumTitle
            if currentAlbum != originalAlbum {
                break
            }
        }
    }
    
    func runTTModeMusicPreviousTrack() {
        TTModeMusicSession.shared.player.skipToPreviousItem()
        self.runTTModeMusicPlay()
    }
    
    func runTTModeMusicVolumeMute() {
        TTModeMusicSession.shared.volume(adjustment: .toggleMute)
    }
    
    func runTTModeMusicVolumeJump() {
        if let jump = self.action.optionValue(TTModeMusicConstants.jumpVolume) as? Int {
            TTModeMusicSession.shared.volume = Float(jump) / 100
        }
    }
}
