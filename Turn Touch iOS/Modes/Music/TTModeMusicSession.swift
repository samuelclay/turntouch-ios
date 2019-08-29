//
//  TTModeMusicSession.swift
//  Turn Touch iOS
//
//  Created by David Sinclair on 2019-08-29.
//  Copyright © 2019 Turn Touch. All rights reserved.
//

import UIKit
import MediaPlayer

class TTModeMusicSession: NSObject {
    /// Singleton shared instance.
    static let shared = TTModeMusicSession()
    
    /// Private init to prevent others constructing a new instance.
    private override init() {
        lastVolume = 0.5
        muteVolume = 0.5
        containerView = UIView()
        volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        containerView.addSubview(volumeView)
        
        super.init()
        
        lastVolume = audio.outputVolume
        
        audio.addObserver(self, forKeyPath: "outputVolume", options: [], context: nil)
        player.addObserver(self, forKeyPath: "nowPlayingItem", options: [], context: nil)
        player.beginGeneratingPlaybackNotifications()
    }
    
    /// Make the audio session active.
    func activate() {
        try? audio.setActive(true)
    }
    
    var player: MPMusicPlayerController {
        return MPMusicPlayerController.systemMusicPlayer
    }
    
    private var audio: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    
    private var containerView: UIView
    private var volumeView: MPVolumeView
    
    private var volumeSlider: UISlider? {
        return (volumeView.subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as? UISlider)
    }
    
    var volume: Float {
        get {
            return lastVolume
        }
        set {
            lastVolume = newValue
            volumeSlider?.setValue(newValue, animated: false)
        }
    }
    
    let ITUNES_VOLUME_CHANGE: Float = 0.06
    
    enum Adjustment {
        case up
        case down
        case toggleMute
    }
    
    func volume(adjustment: Adjustment) {
        switch adjustment {
        case .up:
            volume = min(1, volume + ITUNES_VOLUME_CHANGE)
        case .down:
            volume = max(0, volume - ITUNES_VOLUME_CHANGE)
        case .toggleMute:
            muted.toggle()
        }
    }
    
    private var lastVolume: Float
    private var muteVolume: Float
    
    var muted: Bool {
        get {
            return volume == 0
        }
        set {
            if newValue {
                if volume != 0 {
                    muteVolume = volume
                }
                volume = 0
            } else {
                volume = muteVolume
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            let volume = audio.outputVolume
            if volume != lastVolume {
                lastVolume = volume
            }
            print(" Observing output volume: \(volume) \(String(describing: change?[.newKey]))")
        } else if keyPath == "nowPlayingInfo" {
            print(" Observing now playing info: \(String(describing: player.nowPlayingItem))")
        }
    }
}
