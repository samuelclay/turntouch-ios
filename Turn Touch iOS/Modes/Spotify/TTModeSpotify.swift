//
//  TTModeSpotify.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/3/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import Foundation
import Reachability
import MediaPlayer

struct TTModeSpotifyConstants {
    static let kSpotifyAccessToken = "spotifyAccessToken"
    static let jumpVolume = "jumpVolume"
}

enum TTSpotifyState {
    case disconnected
    case connecting
    case connected
}

enum TTSpotifyConnectNextAction {
    case play
    case pause
    case playPause
    case nextTrack
    case previousTrack
}

protocol TTModeSpotifyDelegate {
    func changeState(_ state: TTSpotifyState, mode: TTModeSpotify)
    func presentError(alert: UIAlertController)
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
    static var nextAction: TTSpotifyConnectNextAction?

    var delegate: TTModeSpotifyDelegate!
    static var spotifyState = TTSpotifyState.disconnected
    static var spotifyAppRemoteDelegate = TTModeSpotifyAppDelegate()
    static var appRemote: SPTAppRemote = {
        let connectionParams = SPTAppRemoteConnectionParams(clientIdentifier: "a459d5bab5b04ed5ae41f79f9174ab1b",
                                                            redirectURI: "turntouch://callback/",
                                                            name: "Turn Touch",
                                                            accessToken: TTModeSpotify.accessToken,
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
        
        TTModeSpotify.appRemote.playerAPI?.delegate = self
        TTModeMusicSession.shared.activate()
    }
    
    override func deactivate() {
    }
    
    func runTTModeSpotifyVolumeUp() {
        TTModeMusicSession.shared.volume(adjustment: .up)
    }
    
    func runTTModeSpotifyVolumeDown() {
        TTModeMusicSession.shared.volume(adjustment: .down)
    }
    
    func runTTModeSpotifyVolumeMute() {
        TTModeMusicSession.shared.volume(adjustment: .toggleMute)
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
        print(" ---> Toggled Spotify ")
        if !TTModeSpotify.appRemote.isConnected {
            self.beginConnectingToSpotify()
            TTModeSpotify.nextAction = .playPause
        } else {
            TTModeSpotify.appRemote.playerAPI?.getPlayerState({ (result, error) in
                if let result = result {
                    let playerState = result as! SPTAppRemotePlayerState
                    if playerState.isPaused {
                        TTModeSpotify.appRemote.playerAPI?.resume(self.defaultCallback)
                    } else {
                        TTModeSpotify.appRemote.playerAPI?.pause(self.defaultCallback)
                    }
                }
                if error != nil {
                    self.beginConnectingToSpotify()
                    TTModeSpotify.nextAction = .playPause
                }
            })
        }
    }
    
    func doubleRunTTModeSpotifyPlayPause() {
        self.runTTModeSpotifyPreviousTrack()
    }
    
    func runTTModeSpotifyPlay() {

    }
    
    func doubleRunTTModeSpotifyPlay() {
        self.runTTModeSpotifyPreviousTrack()
    }
    
    func runTTModeSpotifyPause() {
    }
    
    func doubleRunTTModeSpotifyPause() {
        self.runTTModeSpotifyPreviousTrack()
    }
    
    func runTTModeSpotifyNextTrack() {
        if !TTModeSpotify.appRemote.isConnected {
            self.beginConnectingToSpotify()
            TTModeSpotify.nextAction = .nextTrack
        }
        
        TTModeSpotify.appRemote.playerAPI?.getPlayerState({ (result, error) in
            if let _ = result {
                TTModeSpotify.appRemote.playerAPI?.skip(toNext: self.defaultCallback)
            }
            if error != nil {
                self.beginConnectingToSpotify()
                TTModeSpotify.nextAction = .nextTrack
            }
        })

    }
    
    func runTTModeSpotifyPreviousTrack() {
        if !TTModeSpotify.appRemote.isConnected {
            self.beginConnectingToSpotify()
            TTModeSpotify.nextAction = .previousTrack
        }

        TTModeSpotify.appRemote.playerAPI?.getPlayerState({ (result, error) in
            if let _ = result {
                TTModeSpotify.appRemote.playerAPI?.skip(toPrevious: self.defaultCallback)
            }
            if error != nil {
                self.beginConnectingToSpotify()
                TTModeSpotify.nextAction = .previousTrack
            }
        })
    }
    
    // Spotify Connection
    
    func beginConnectingToSpotify(ensureConnection : Bool = false) {
        DispatchQueue.main.async {
            TTModeSpotifyAppDelegate.recentSpotify = self
            
            TTModeSpotify.spotifyState = .connecting
            self.delegate?.changeState(TTModeSpotify.spotifyState, mode: self)

            if !TTModeSpotify.appRemote.isConnected && ensureConnection {
                TTModeSpotify.appRemote.authorizeAndPlayURI("")
            } else {
                TTModeSpotify.appRemote.connect()
            }
        }
        
    }
    
    func didEstablishConnection() {
        TTModeSpotify.spotifyState = .connected
        delegate?.changeState(TTModeSpotify.spotifyState, mode: self)
        
        if !TTModeSpotify.appRemote.isConnected {
            TTModeSpotify.appRemote.connect()
        }
        
        if let nextAction = TTModeSpotify.nextAction {
            switch nextAction {
            case .playPause:
                self.runTTModeSpotifyPlayPause()
            case .nextTrack:
                self.runTTModeSpotifyNextTrack()
            case .previousTrack:
                self.runTTModeSpotifyPreviousTrack()
            default:
                self.runTTModeSpotifyPlayPause()
            }
            TTModeSpotify.nextAction = nil
        }
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

    
    fileprivate var playerState: SPTAppRemotePlayerState?
    fileprivate var subscribedToPlayerState: Bool = false
    
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[unowned self] _, error in
                if let error = error {
//                    self.displayError()
                    self.cancelConnectingToSpotify(error: error.localizedDescription)
                }
            }
        }
    }
    
    fileprivate func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }
    
    fileprivate func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.delegate?.presentError(alert: alert)
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
    }
    
}

