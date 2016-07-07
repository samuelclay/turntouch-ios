//
//  TTPairingViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTPairingState {
    case Intro
    case Searching
    case Success
    case Failure
    case FailureExplainer
}

class TTPairingViewController: UIViewController, TTBluetoothMonitorDelegate {
    
    @IBOutlet var diamondView: TTDiamondView!
    @IBOutlet var spinnerScanning: TTPairingSpinner!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var countdownIndicator: UIProgressView!
    var searchingTimer: NSTimer?
    var countdownTimer: NSTimer?
    var pairingState: TTPairingState!
    
    init(pairingState: TTPairingState) {
        super.init(nibName: "TTPairingViewController", bundle: nil)
        self.pairingState = pairingState
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                          target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "Pairing a new remote"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closePairingModal()
        appDelegate().bluetoothMonitor.delegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        self.changePairingState(.Searching)
    }
    
    func changePairingState(state: TTPairingState) {
        pairingState = state
    
        if state == .Searching {
            appDelegate().bluetoothMonitor.delegate = self
            appDelegate().bluetoothMonitor.scanUnknown()
            self.changedDeviceCount()
        } else if state == .Failure {
            let pairingInfoViewController = TTPairingInfoViewController(pairingState: .Failure)
            self.navigationController?.pushViewController(pairingInfoViewController, animated: true)
        } else if state == .Success {
            let pairingInfoViewController = TTPairingInfoViewController(pairingState: .Success)
            self.navigationController?.pushViewController(pairingInfoViewController, animated: true)
        }
    }
    
    func changedDeviceCount() {
        let found = appDelegate().bluetoothMonitor.unpairedDevicesCount?.integerValue > 0
        let connected = appDelegate().bluetoothMonitor.nicknamedConnectedCount?.integerValue > 0
        
        if !found {
            countdownIndicator.hidden = true
            spinnerScanning.hidden = false
            let runner = NSRunLoop.currentRunLoop()
            searchingTimer?.invalidate()
            searchingTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(searchingFailure), userInfo: nil, repeats: false)
            runner.addTimer(searchingTimer!, forMode: NSRunLoopCommonModes)
            
            spinnerScanning.setNeedsDisplay()
            titleLabel.text = "Pairing your Turn Touch"
            subtitleLabel.text = "Searching for remotes..."
            countdownTimer?.invalidate()
            countdownTimer = nil
        } else if found && !connected {
            countdownIndicator.hidden = true
            spinnerScanning.hidden = false
            titleLabel.text = "Pairing your Turn Touch"
            subtitleLabel.text = "Connecting..."
            searchingTimer?.invalidate()
        } else if found && connected {
            countdownIndicator.hidden = false
            countdownIndicator.progress = 0
            spinnerScanning.hidden = true
            titleLabel.text = "Pairing your Turn Touch"
            subtitleLabel.text = "Press all four buttons to connect"
            searchingTimer?.invalidate()
            self.updateCountdown()
        }
    }
    
    // MARK: Countdown timer
    
    func updateCountdown() {
        let minusOneSecond = countdownIndicator.progress + 0.1
        countdownIndicator.progress = minusOneSecond
        
        print(" ---> Countdown: \(countdownIndicator.progress)")
        if minusOneSecond >= 1 {
            appDelegate().bluetoothMonitor.disconnectUnpairedDevices()
            self.changePairingState(.Failure)
            countdownTimer?.invalidate()
            countdownTimer = nil
        } else {
            let runner = NSRunLoop.currentRunLoop()
            countdownTimer?.invalidate()
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: false)
            runner.addTimer(countdownTimer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    func searchingFailure() {
        searchingTimer?.invalidate()
        self.changePairingState(.Failure)
    }
    
    func pairingSuccess() {
        self.changePairingState(.Success)
    }
}
