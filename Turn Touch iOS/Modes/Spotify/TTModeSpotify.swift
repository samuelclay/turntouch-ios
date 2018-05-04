//
//  TTModeSpotify.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/3/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import Foundation
import ReachabilitySwift

struct TTModeSpotifyConstants {
    static let kSpotifyAccessToken = "spotifyAccessToken"
    static let jumpVolume = "jumpVolume"
}

enum TTSpotifyState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeSpotifyDelegate {
    func changeState(_ state: TTSpotifyState, mode: TTModeSpotify)
}

class TTModeSpotifyAppDelegate : NSObject, SPTAppRemoteDelegate {
    
    static var recentSpotify: TTModeSpotify?
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        TTModeSpotify.appRemote = appRemote
        TTModeSpotifyAppDelegate.recentSpotify?.didEstablishConnection()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        TTModeSpotifyAppDelegate.recentSpotify?.cancelConnectingToSpotify()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        TTModeSpotifyAppDelegate.recentSpotify?.cancelConnectingToSpotify()
    }
    
}

class TTModeSpotify : TTMode, SPTAppRemotePlayerStateDelegate {

    static var reachability: Reachability!
    var delegate: TTModeSpotifyDelegate!
    static var spotifyState = TTSpotifyState.disconnected
    static var spotifyAppRemoteDelegate = TTModeSpotifyAppDelegate()
    static var appRemote: SPTAppRemote = {
        let connectionParams = SPTAppRemoteConnectionParams(clientIdentifier: "a459d5bab5b04ed5ae41f79f9174ab1b",
                                                            redirectURI: "turntouch://callback/",
                                                            name: "Turn Touch",
                                                            accessToken: nil,
                                                            defaultImageSize: CGSize.zero,
                                                            imageFormat: .any)
        let appRemote = SPTAppRemote(connectionParameters: connectionParams, logLevel: .debug)
        appRemote.delegate = TTModeSpotify.spotifyAppRemoteDelegate
        return appRemote
    }()
    class var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: TTModeSpotifyConstants.kSpotifyAccessToken)
        }
        set {
            let prefs = UserDefaults.standard
            
            prefs.set(newValue, forKey: TTModeSpotifyConstants.kSpotifyAccessToken)
            prefs.synchronize()
        }
    }
    
    required init() {
        super.init()
        
        self.watchReachability()
    }
   
    override class func title() -> String {
        return "Spotify"
    }
    
    override class func subtitle() -> String {
        return "Control Spotify music"
    }
    
    override class func imageName() -> String {
        return "mode_spotify.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeSpotifyVolumeUp",
                "TTModeSpotifyVolumeDown",
                "TTModeSpotifyVolumeMute",
                "TTModeSpotifyVolumeJump",
                "TTModeSpotifyPlayPause",
                "TTModeSpotifyPlay",
                "TTModeSpotifyPause",
                "TTModeSpotifyNextTrack",
                "TTModeSpotifyPreviousTrack",
        ]
    }
    
    override func shouldUseModeOptionsFor(_ action: String) -> Bool {
        if action == "TTModeSpotifyVolumeJump" {
            return false
        }
        
        return true
    }
    
    // MARK: Action titles
    
    func titleTTModeSpotifyVolumeUp() -> String {
        return "Volume up"
    }
    
    func titleTTModeSpotifyVolumeDown() -> String {
        return "Volume down"
    }
    
    func titleTTModeSpotifyVolumeMute() -> String {
        return "Mute"
    }
    
    func titleTTModeSpotifyVolumeJump() -> String {
        return "Jump to volume"
    }
    
    func titleTTModeSpotifyPlayPause() -> String {
        return "Play/pause"
    }
    
    func titleTTModeSpotifyPlay() -> String {
        return "Play"
    }
    
    func titleTTModeSpotifyPause() -> String {
        return "Pause"
    }
    
    func titleTTModeSpotifyNextTrack() -> String {
        return "Next track"
    }
    
    func titleTTModeSpotifyPreviousTrack() -> String {
        return "Previous track"
    }
    
    
    // MARK: Action images
    
    func imageTTModeSpotifyVolumeUp() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeSpotifyVolumeDown() -> String {
        return "music_volume_down.png"
    }
    
    func imageTTModeSpotifyVolumeMute() -> String {
        return "music_volume_mute.png"
    }
    
    func imageTTModeSpotifyVolumeJump() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeSpotifyPlayPause() -> String {
        return "music_play_pause.png"
    }
    
    func imageTTModeSpotifyPlay() -> String {
        return "music_play.png"
    }
    
    func imageTTModeSpotifyPause() -> String {
        return "music_pause.png"
    }
    
    func imageTTModeSpotifyNextTrack() -> String {
        return "music_ff.png"
    }
    
    func imageTTModeSpotifyPreviousTrack() -> String {
        return "music_rewind.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeSpotifyVolumeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModeSpotifyNextTrack"
    }
    
    override func defaultWest() -> String {
        return "TTModeSpotifyPlayPause"
    }
    
    override func defaultSouth() -> String {
        return "TTModeSpotifyVolumeDown"
    }
    
    // MARK: Action methods
    
    override func activate() {
        TTModeSpotify.accessToken = UserDefaults.standard.string(forKey: TTModeSpotifyConstants.kSpotifyAccessToken)

        if !TTModeSpotify.appRemote.isConnected {
            self.beginConnectingToSpotify()
        } else {
            TTModeSpotify.spotifyState = .connected
        }
        delegate?.changeState(TTModeSpotify.spotifyState, mode: self)
    }
    
    override func deactivate() {
        
    }
    
    func adjustVolume(volume: Int, left: Int) {
        if left == 0 {
            return
        }
        let adjust = left > 0 ? 1 : -1
//        device.setVolume(volume + adjust, mergeRequests: true, completion: { (speakers, error) in
//            print(" ---> Turned volume: \(volume)+\(adjust) (\(String(describing: error)), \(String(describing: speakers))")
//            self.adjustVolume(device: device, volume: volume+adjust, left: left - adjust)
//        })
    }
    
    func runTTModeSpotifyVolumeUp() {
//        if let device = self.selectedDevice() {
//            device.getVolume(TimeInterval(60*60), completion: { (volume, speakers, error) in
//                self.adjustVolume(device: device, volume: volume, left: 2)
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func runTTModeSpotifyVolumeDown() {
//        if let device = self.selectedDevice() {
//            device.getVolume(TimeInterval(60*60), completion: { (volume, speakers, error) in
//                self.adjustVolume(device: device, volume: volume, left: -2)
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func runTTModeSpotifyVolumeMute() {
//        if let device = self.selectedDevice() {
//            device.getMute({ (mute, speakers, error) in
//                device.setMute(!mute, completion: { (speakers, error) in
//                    print(" ---> Muted volume: \(mute) (\(String(describing: error)), \(String(describing: speakers))")
//                })
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func runTTModeSpotifyVolumeJump() {
//        if let device = self.selectedDevice() {
//            let jump = self.action.optionValue(TTModeSpotifyConstants.jumpVolume) as! Int
//            device.setVolume(jump, mergeRequests: true, completion: { (speakers, error) in
//
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func runTTModeSpotifyPlayPause() {
        if !TTModeSpotify.appRemote.authorizeAndPlayURI("") {
            self.beginConnectingToSpotify()
        } else {
            print(" ---> Toggled Spotify ")
        }
//        if let device = self.selectedDevice(coordinator: true) {
//            device.togglePlayback({ (playing, speakers, error) in
//                print(" ---> Toggled Spotify playback \(playing): \(String(describing: speakers)) \(String(describing: error))")
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func doubleRunTTModeSpotifyPlayPause() {
        self.runTTModeSpotifyPreviousTrack()
    }
    
    func runTTModeSpotifyPlay() {
//        if let device = self.selectedDevice(coordinator: true) {
//            device.playbackStatus({ (playing, body, error) in
//                if !playing {
//                    device.togglePlayback({ (playing, body, errors) in
//                        print(" ---> Paused Spotify playback \(playing): \(String(describing: body)) \(String(describing: error))")
//                        if !playing {
//                            device.togglePlayback({ (playing, body, errors) in
//                                print(" ---> Paused Spotify playback twice \(playing): \(String(describing: body)) \(String(describing: error))")
//                            })
//                        }
//                    })
//                }
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func doubleRunTTModeSpotifyPlay() {
        self.runTTModeSpotifyPreviousTrack()
    }
    
    func runTTModeSpotifyPause() {
//        if let device = self.selectedDevice(coordinator: true) {
//            device.playbackStatus({ (playing, body, error) in
//                if playing {
//                    device.togglePlayback({ (playing, body, errors) in
//                        print(" ---> Paused Spotify playback \(playing): \(String(describing: body)) \(String(describing: error))")
//                    })
//                }
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func doubleRunTTModeSpotifyPause() {
        self.runTTModeSpotifyPreviousTrack()
    }
    
    func runTTModeSpotifyNextTrack() {
//        if let device = self.selectedDevice(coordinator: true) {
//            device.next({ (body, error) in
//                print((" ---> Next track: \(String(describing: body)) \(String(describing: error))"))
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    func runTTModeSpotifyPreviousTrack() {
//        if let device = self.selectedDevice(coordinator: true) {
//            device.previous({ (body, error) in
//                print((" ---> Previous track: \(String(describing: body)) \(String(describing: error))"))
//
//                // Spotify pauses when going to the preview track for some reason
//                self.runTTModeSpotifyPlay()
//            })
//        } else {
//            self.beginConnectingToSpotify()
//        }
    }
    
    // Spotify Connection
    
    func beginConnectingToSpotify(ensureConnection : Bool = false) {
        TTModeSpotifyAppDelegate.recentSpotify = self

        if TTModeSpotify.spotifyState == .connecting {
            print(" ---> Already connecting to Spotify...")
            return
        }
        
        TTModeSpotify.spotifyState = .connecting
        delegate?.changeState(TTModeSpotify.spotifyState, mode: self)
        
        if !TTModeSpotify.appRemote.isConnected && ensureConnection {
            TTModeSpotify.appRemote.authorizeAndPlayURI("")
        } else {
            TTModeSpotify.appRemote.connect()
        }
    }
    
    func didEstablishConnection() {
        TTModeSpotify.spotifyState = .connected
        delegate?.changeState(TTModeSpotify.spotifyState, mode: self)        
    }
    
    func cancelConnectingToSpotify(error: String? = nil) {
        TTModeSpotify.spotifyState = .disconnected
        delegate?.changeState(TTModeSpotify.spotifyState, mode: self)
    }
    
    // MARK: Reachability
    
    func watchReachability() {
        if TTModeSpotify.reachability != nil {
            return
        }
        
        TTModeSpotify.reachability = Reachability()
        
        TTModeSpotify.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if TTModeSpotify.spotifyState != .connected {
                    print(" ---> Reachable, re-connecting to Spotify...")
                    self.beginConnectingToSpotify()
                }
            }
        }
        
        TTModeSpotify.reachability.whenUnreachable = { reachability in
            if TTModeSpotify.spotifyState != .connected {
                print(" ---> Unreachable, not connected")
            }
        }
        
        do {
            try TTModeSpotify.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    // MARK: Spotify Protocol

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
    }
    
}

