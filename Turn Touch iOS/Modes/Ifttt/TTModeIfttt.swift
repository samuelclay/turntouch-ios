//
//  TTModeIfttt.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import ReachabilitySwift

struct TTModeIftttConstants {
    static let kIftttThermostatIdentifier = "IftttThermostatIdentifier"
}

enum TTIftttState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeIftttDelegate {
    func changeState(_ state: TTIftttState, mode: TTModeIfttt)
}


class TTModeIfttt: TTMode {
    
    static var reachability: Reachability!
    var delegate: TTModeIftttDelegate!
    static var IftttState = TTIftttState.disconnected
    
    required init() {
        super.init()
        
        self.watchReachability()
    }
    
    override class func title() -> String {
        return "IFTTT"
    }
    
    override class func subtitle() -> String {
        return "Buttons for If This Then That"
    }
    
    override class func imageName() -> String {
        return "mode_Ifttt.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeIftttTriggerAction",
        ]
    }
    
    // MARK: Action titles
    
    func titleTTModeIftttTriggerAction() -> String {
        return "Trigger action"
    }
    
    // MARK: Action images
    
    func imageTTModeIftttTriggerAction() -> String {
        return "trigger"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    override func defaultEast() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    override func defaultWest() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    override func defaultSouth() -> String {
        return "TTModeIftttTriggerAction"
    }
    
    // MARK: Action methods
    
    override func activate() {

    }
    
    override func deactivate() {

    }
    
    
    func runTTModeIftttTriggerAction() {

    }
    
    // MARK: Ifttt Reachability
    
    func watchReachability() {
        if TTModeIfttt.reachability != nil {
            return
        }
        
        TTModeIfttt.reachability = Reachability()
        
        TTModeIfttt.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if TTModeIfttt.IftttState != .connected {
                    print(" ---> Reachable, re-connecting to Ifttt...")
                    self.beginConnectingToIfttt()
                }
            }
        }
        
        TTModeIfttt.reachability.whenUnreachable = { reachability in
            if TTModeIfttt.IftttState != .connected {
                print(" ---> Unreachable, not connected")
            }
        }
        
        do {
            try TTModeIfttt.reachability.startNotifier()
        } catch {
            print("Unable to start Ifttt notifier")
        }
    }
    
    func beginConnectingToIfttt() {
        if TTModeIfttt.IftttState == .connecting {
            print(" ---> Already connecting to Ifttt...")
            return
        }
        
        TTModeIfttt.IftttState = .connecting
        delegate?.changeState(TTModeIfttt.IftttState, mode: self)
    }
    
    func authorizeIfttt() {

    }
    
    func cancelConnectingToIfttt() {
            TTModeIfttt.IftttState = .disconnected
            delegate?.changeState(TTModeIfttt.IftttState, mode: self)
    }
    
    func IftttReady() {
        TTModeIfttt.IftttState = .connected
        delegate?.changeState(TTModeIfttt.IftttState, mode: self)
    }
    
    func logMessage(_ message: String) {
        print(" ---> Ifttt API: \(message)")
    }
    
}
