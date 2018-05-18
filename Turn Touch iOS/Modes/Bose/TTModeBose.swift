//
//  TTModeBose.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/3/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import Foundation
import ReachabilitySwift
import MediaPlayer

struct TTModeBoseConstants {
    static let kBoseAccessToken = "BoseAccessToken"
    static let jumpVolume = "jumpVolume"
    static let kBoseFoundDevices = "boseFoundDevicesV2"
    static let kBoseSeenDevices = "boseSeenDevicesV2"
}

enum TTBoseState {
    case disconnected
    case connecting
    case connected
}

enum TTBoseConnectNextAction {
    case play
    case pause
    case playPause
    case nextTrack
    case previousTrack
}

protocol TTModeBoseDelegate {
    func changeState(_ state: TTBoseState, mode: TTModeBose)
    func presentError(alert: UIAlertController)
}

class TTModeBose : TTMode {

    static var reachability: Reachability!
    var musicPlayer: MPMusicPlayerController!
    var observing = false
    var lastVolume: Float?
    let ITUNES_VOLUME_CHANGE: Float = 0.06
    static var nextAction: TTBoseConnectNextAction?

    var delegate: TTModeBoseDelegate!
    static var BoseState = TTBoseState.disconnected
    static var BoseAppRemoteDelegate = TTModeBoseAppDelegate()
    static var appRemote: SPTAppRemote = {
        let connectionParams = SPTAppRemoteConnectionParams(clientIdentifier: "a459d5bab5b04ed5ae41f79f9174ab1b",
                                                            redirectURI: "turntouch://callback/",
                                                            name: "Turn Touch",
                                                            accessToken: TTModeBose.accessToken,
                                                            defaultImageSize: CGSize.zero,
                                                            imageFormat: .any)
        let appRemote = SPTAppRemote(connectionParameters: connectionParams, logLevel: .debug)
        appRemote.delegate = TTModeBose.BoseAppRemoteDelegate
        return appRemote
    }()
    
    class var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: TTModeBoseConstants.kBoseAccessToken)
        }
        set {
            let prefs = UserDefaults.standard
            
            prefs.set(newValue, forKey: TTModeBoseConstants.kBoseAccessToken)
            prefs.synchronize()
        }
    }
    
    required init() {
        super.init()
        
        self.watchReachability()
    }
   
    override class func title() -> String {
        return "Bose"
    }
    
    override class func subtitle() -> String {
        return "Control Bose music"
    }
    
    override class func imageName() -> String {
        return "mode_Bose.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeBoseVolumeUp",
                "TTModeBoseVolumeDown",
                "TTModeBoseVolumeMute",
                "TTModeBoseVolumeJump",
                "TTModeBosePlayPause",
                "TTModeBosePlay",
                "TTModeBosePause",
                "TTModeBoseNextTrack",
                "TTModeBosePreviousTrack",
        ]
    }
    
    override func shouldUseModeOptionsFor(_ action: String) -> Bool {
        if action == "TTModeBoseVolumeJump" {
            return false
        }
        
        return true
    }
    
    // MARK: Action titles
    
    func titleTTModeBoseVolumeUp() -> String {
        return "Volume up"
    }
    
    func titleTTModeBoseVolumeDown() -> String {
        return "Volume down"
    }
    
    func titleTTModeBoseVolumeMute() -> String {
        return "Mute"
    }
    
    func titleTTModeBoseVolumeJump() -> String {
        return "Jump to volume"
    }
    
    func titleTTModeBosePlayPause() -> String {
        return "Play/pause"
    }
    
    func titleTTModeBosePlay() -> String {
        return "Play"
    }
    
    func titleTTModeBosePause() -> String {
        return "Pause"
    }
    
    func titleTTModeBoseNextTrack() -> String {
        return "Next track"
    }
    
    func titleTTModeBosePreviousTrack() -> String {
        return "Previous track"
    }
    
    
    // MARK: Action images
    
    func imageTTModeBoseVolumeUp() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeBoseVolumeDown() -> String {
        return "music_volume_down.png"
    }
    
    func imageTTModeBoseVolumeMute() -> String {
        return "music_volume_mute.png"
    }
    
    func imageTTModeBoseVolumeJump() -> String {
        return "music_volume_up.png"
    }
    
    func imageTTModeBosePlayPause() -> String {
        return "music_play_pause.png"
    }
    
    func imageTTModeBosePlay() -> String {
        return "music_play.png"
    }
    
    func imageTTModeBosePause() -> String {
        return "music_pause.png"
    }
    
    func imageTTModeBoseNextTrack() -> String {
        return "music_ff.png"
    }
    
    func imageTTModeBosePreviousTrack() -> String {
        return "music_rewind.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeBoseVolumeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModeBoseNextTrack"
    }
    
    override func defaultWest() -> String {
        return "TTModeBosePlayPause"
    }
    
    override func defaultSouth() -> String {
        return "TTModeBoseVolumeDown"
    }
    
    // MARK: Action methods
    
    override func activate() {
        if musicPlayer == nil {
            musicPlayer = MPMusicPlayerController.systemMusicPlayer
        }
        
        if !observing {
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: [], context: nil)
            musicPlayer.addObserver(self, forKeyPath: "nowPlayingItem", options: [], context: nil)
            musicPlayer.beginGeneratingPlaybackNotifications()
            observing = true
        }
        
        TTModeBose.accessToken = UserDefaults.standard.string(forKey: TTModeBoseConstants.kBoseAccessToken)

        if !TTModeBose.appRemote.isConnected {
            self.beginConnectingToBose()
        } else {
            TTModeBose.BoseState = .connected
        }
        delegate?.changeState(TTModeBose.BoseState, mode: self)
        
        TTModeBose.appRemote.playerAPI?.delegate = self
    }
    
    override func deactivate() {
        if observing {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
            musicPlayer.removeObserver(self, forKeyPath: "nowPlayingItem")
            observing = false
        }
    }
    
    var volumeSlider: UISlider {
        get {
            return (MPVolumeView().subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as! UISlider)
        }
    }
    
    func adjustVolume(volume: Int) {
        if volume == 0 && volumeSlider.value != 0 {
            lastVolume = volumeSlider.value
            volumeSlider.setValue(0, animated: false)
        } else {
            if lastVolume == nil {
                lastVolume = AVAudioSession.sharedInstance().outputVolume
            }
            lastVolume = min(1, lastVolume! + (Float(volume) * ITUNES_VOLUME_CHANGE))
            volumeSlider.setValue(lastVolume!, animated: false)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            lastVolume = AVAudioSession.sharedInstance().outputVolume
        } else if keyPath == "nowPlayingInfo" {
            print(" Now playing info: \(String(describing: musicPlayer.nowPlayingItem))")
        }
    }
    
    func runTTModeBoseVolumeUp() {
        self.adjustVolume(volume: 1)
    }
    
    func runTTModeBoseVolumeDown() {
        self.adjustVolume(volume: -1)
    }
    
    func runTTModeBoseVolumeMute() {
        self.adjustVolume(volume: 0)
    }
    
    func runTTModeBoseVolumeJump() {
//        if let device = self.selectedDevice() {
//            let jump = self.action.optionValue(TTModeBoseConstants.jumpVolume) as! Int
//            device.setVolume(jump, mergeRequests: true, completion: { (speakers, error) in
//
//            })
//        } else {
//            self.beginConnectingToBose()
//        }
    }
    
    func runTTModeBosePlayPause() {
        print(" ---> Toggled Bose ")
        if !TTModeBose.appRemote.isConnected {
            self.beginConnectingToBose()
            TTModeBose.nextAction = .playPause
        } else {
            TTModeBose.appRemote.playerAPI?.getPlayerState({ (result, error) in
                if let result = result {
                    let playerState = result as! SPTAppRemotePlayerState
                    if playerState.isPaused {
                        TTModeBose.appRemote.playerAPI?.resume(self.defaultCallback)
                    } else {
                        TTModeBose.appRemote.playerAPI?.pause(self.defaultCallback)
                    }
                }
                if error != nil {
                    self.beginConnectingToBose()
                    TTModeBose.nextAction = .playPause
                }
            })
        }
    }
    
    func doubleRunTTModeBosePlayPause() {
        self.runTTModeBosePreviousTrack()
    }
    
    func runTTModeBosePlay() {

    }
    
    func doubleRunTTModeBosePlay() {
        self.runTTModeBosePreviousTrack()
    }
    
    func runTTModeBosePause() {
    }
    
    func doubleRunTTModeBosePause() {
        self.runTTModeBosePreviousTrack()
    }
    
    func runTTModeBoseNextTrack() {
        if !TTModeBose.appRemote.isConnected {
            self.beginConnectingToBose()
            TTModeBose.nextAction = .nextTrack
        }
        
        TTModeBose.appRemote.playerAPI?.getPlayerState({ (result, error) in
            if let _ = result {
                TTModeBose.appRemote.playerAPI?.skip(toNext: self.defaultCallback)
            }
            if error != nil {
                self.beginConnectingToBose()
                TTModeBose.nextAction = .nextTrack
            }
        })

    }
    
    func runTTModeBosePreviousTrack() {
        if !TTModeBose.appRemote.isConnected {
            self.beginConnectingToBose()
            TTModeBose.nextAction = .previousTrack
        }

        TTModeBose.appRemote.playerAPI?.getPlayerState({ (result, error) in
            if let _ = result {
                TTModeBose.appRemote.playerAPI?.skip(toPrevious: self.defaultCallback)
            }
            if error != nil {
                self.beginConnectingToBose()
                TTModeBose.nextAction = .previousTrack
            }
        })
    }
    
    // Bose Connection
    
    func beginConnectingToBose(ensureConnection : Bool = false) {
        DispatchQueue.main.async {
            TTModeBoseAppDelegate.recentBose = self
            
            TTModeBose.BoseState = .connecting
            self.delegate?.changeState(TTModeBose.BoseState, mode: self)

            if !TTModeBose.appRemote.isConnected && ensureConnection {
                TTModeBose.appRemote.authorizeAndPlayURI("")
            } else {
                TTModeBose.appRemote.connect()
            }
        }
        
    }
    
    func didEstablishConnection() {
        TTModeBose.BoseState = .connected
        delegate?.changeState(TTModeBose.BoseState, mode: self)
        
        if !TTModeBose.appRemote.isConnected {
            TTModeBose.appRemote.connect()
        }
        
        if let nextAction = TTModeBose.nextAction {
            switch nextAction {
            case .playPause:
                self.runTTModeBosePlayPause()
            case .nextTrack:
                self.runTTModeBoseNextTrack()
            case .previousTrack:
                self.runTTModeBosePreviousTrack()
            default:
                self.runTTModeBosePlayPause()
            }
            TTModeBose.nextAction = nil
        }
    }
    
    func cancelConnectingToBose(error: String? = nil) {
        TTModeBose.BoseState = .disconnected
        delegate?.changeState(TTModeBose.BoseState, mode: self)
    }
    
    // MARK: Reachability
    
    func watchReachability() {
        if TTModeBose.reachability != nil {
            return
        }
        
        TTModeBose.reachability = Reachability()
        
        TTModeBose.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if TTModeBose.BoseState != .connected {
                    print(" ---> Reachable, re-connecting to Bose...")
                    self.beginConnectingToBose()
                }
            }
        }
        
        TTModeBose.reachability.whenUnreachable = { reachability in
            if TTModeBose.BoseState != .connected {
                print(" ---> Unreachable, not connected")
            }
        }
        
        do {
            try TTModeBose.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    // MARK: Bose Protocol

    
    fileprivate var playerState: SPTAppRemotePlayerState?
    fileprivate var subscribedToPlayerState: Bool = false
    
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[unowned self] _, error in
                if let error = error {
//                    self.displayError()
                    self.cancelConnectingToBose(error: error.localizedDescription)
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
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.delegate?.presentError(alert: alert)
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
    }
    
}

