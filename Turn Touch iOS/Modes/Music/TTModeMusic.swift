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
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
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
        if !observing {
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: [], context: nil)
            musicPlayer.addObserver(self, forKeyPath: "nowPlayingItem", options: [], context: nil)
            musicPlayer.beginGeneratingPlaybackNotifications()
            observing = true
        }
    }
    
    override func deactivate() {
        if observing {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
            musicPlayer.removeObserver(self, forKeyPath: "nowPlayingItem")
            observing = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
//            print(" Volume: \(AVAudioSession.sharedInstance().outputVolume) \(change!["new"]) \(object)")
            if AVAudioSession.sharedInstance().outputVolume != lastVolume {
                lastVolume = AVAudioSession.sharedInstance().outputVolume
            }
        } else if keyPath == "nowPlayingInfo" {
            print(" Now playing info: \(String(describing: musicPlayer.nowPlayingItem))")
        }
    }
    
    // MARK: Actions
    
    var volumeSlider: UISlider {
        get {
            return (MPVolumeView().subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as! UISlider)
        }
    }
    
    func runTTModeMusicVolumeUp() {
//        if lastVolume == nil {
            lastVolume = AVAudioSession.sharedInstance().outputVolume
//        }
        lastVolume = min(1, lastVolume + ITUNES_VOLUME_CHANGE)
        volumeSlider.setValue(lastVolume, animated: false)
        
    }
    
    func runTTModeMusicVolumeDown() {
//        if lastVolume == nil {
            lastVolume = AVAudioSession.sharedInstance().outputVolume
//        }
        lastVolume = max(0, lastVolume - ITUNES_VOLUME_CHANGE)
        volumeSlider.setValue(lastVolume, animated: false)
    }
    
    func runTTModeMusicPlayPause() {
        if musicPlayer.playbackState == .playing {
            musicPlayer.pause()
        } else {
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        }
    }
    
    func doubleRunTTModeMusicPlayPause() {
        musicPlayer.skipToPreviousItem()
    }
    
    func runTTModeMusicPlay() {
        musicPlayer.prepareToPlay()
        musicPlayer.play()
    }
    
    func runTTModeMusicPause() {
        musicPlayer.pause()
    }
    
    func runTTModeMusicNextTrack() {
        musicPlayer.skipToNextItem()
    }
    
    func doubleRunTTModeMusicNextTrack() {
        let nowPlaying = musicPlayer.nowPlayingItem
        let originalAlbum = nowPlaying?.albumTitle
        var currentAlbum: String!
        
        for _ in 0..<30 {
            musicPlayer.skipToNextItem()
            currentAlbum = musicPlayer.nowPlayingItem?.albumTitle
            if currentAlbum != originalAlbum {
                break
            }
        }
    }
    
    func runTTModeMusicPreviousTrack() {
        musicPlayer.skipToPreviousItem()
    }
}
