//
//  TTModeMusic.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import MediaPlayer

class TTModeMusic: TTMode {
    
    let ITUNES_VOLUME_CHANGE: Float = 0.06
    var observing = false
    var lastVolume: Float!
    
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
        return ["TTModeMusicVolumeUp",
                "TTModeMusicVolumeDown",
                "TTModeMusicVolumeJump",
                "TTModeMusicVolumeMute",
        "TTModeMusicPlayPause",
        "TTModeMusicPlay",
        "TTModeMusicPause",
        "TTModeMusicNextTrack"]
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
        if !observing {
            try! AVAudioSession.sharedInstance().setActive(true)
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.New, context: nil)
            MPMusicPlayerController.systemMusicPlayer().addObserver(self, forKeyPath: "nowPlayingItem", options: .New, context: nil)
            MPMusicPlayerController.systemMusicPlayer().beginGeneratingPlaybackNotifications()
            observing = true
        }
    }
    
    override func deactivate() {
        if observing {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
            MPMusicPlayerController.systemMusicPlayer().removeObserver(self, forKeyPath: "nowPlayingItem")
            observing = false
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "outputVolume" {
            print(" Volume: \(AVAudioSession.sharedInstance().outputVolume)")
        } else if keyPath == "nowPlayingInfo" {
            print(" Now playing info: \(MPMusicPlayerController.systemMusicPlayer().nowPlayingItem)")
        }
    }
    
    // MARK: Actions
    
    var volumeSlider: UISlider {
        get {
            return (MPVolumeView().subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as! UISlider)
        }
    }
    
    func runTTModeMusicVolumeUp() {
        if lastVolume == nil {
            lastVolume = AVAudioSession.sharedInstance().outputVolume
        }
        lastVolume = min(1, lastVolume + ITUNES_VOLUME_CHANGE)
        volumeSlider.setValue(lastVolume, animated: false)
        
    }
    
    func runTTModeMusicVolumeDown() {
        if lastVolume == nil {
            lastVolume = AVAudioSession.sharedInstance().outputVolume
        }
        lastVolume = max(0, lastVolume - ITUNES_VOLUME_CHANGE)
        volumeSlider.setValue(lastVolume, animated: false)
    }
    
    func runTTModeMusicPlayPause() {
        if MPMusicPlayerController.systemMusicPlayer().playbackState == .Playing {
            MPMusicPlayerController.systemMusicPlayer().pause()
        } else {
            MPMusicPlayerController.systemMusicPlayer().play()
        }
    }
    
    func runTTModeMusicPlay() {
        MPMusicPlayerController.systemMusicPlayer().play()
    }
    
    func runTTModeMusicPause() {
        MPMusicPlayerController.systemMusicPlayer().pause()
    }
    
    func runTTModeMusicNextTrack() {
        MPMusicPlayerController.systemMusicPlayer().skipToNextItem()
    }
    
    func doubleRunTTModeMusicNextTrack() {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem
        let originalAlbum = nowPlaying?.albumTitle
        var currentAlbum: String!
        
        for _ in 0..<30 {
            MPMusicPlayerController.systemMusicPlayer().skipToNextItem()
            currentAlbum = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem?.albumTitle
            if currentAlbum != originalAlbum {
                break
            }
        }
    }
}
