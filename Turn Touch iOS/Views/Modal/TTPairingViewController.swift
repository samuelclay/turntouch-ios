//
//  TTPairingViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum TTPairingState {
    case intro
    case searching
    case pairing
    case success
    case failure
    case failureExplainer
}

class TTPairingViewController: UIViewController, TTBluetoothMonitorDelegate {
    
    let secondsToPair = 30
    @IBOutlet var diamondView: TTDiamondView!
    @IBOutlet var spinnerScanning: TTPairingSpinner!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var countdownIndicator: UIProgressView!
    var searchingTimer: Timer?
    var countdownTimer: Timer?
    var pairingState: TTPairingState!
    
    init(pairingState: TTPairingState) {
        super.init(nibName: "TTPairingViewController", bundle: nil)
        self.pairingState = pairingState
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                          target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "Pairing a new remote"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closePairingModal()
        appDelegate().bluetoothMonitor.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.changePairingState(.searching)
    }
    
    func changePairingState(_ state: TTPairingState) {
        pairingState = state
    
        if state == .searching {
            appDelegate().bluetoothMonitor.delegate = self
            appDelegate().bluetoothMonitor.scanUnknown()
            self.changedDeviceCount()
        } else if state == .pairing {
            self.changedDeviceCount()
        } else if state == .failure && self.navigationController?.visibleViewController == self {
            let pairingInfoViewController = TTPairingInfoViewController(pairingState: .failure)
            self.navigationController?.pushViewController(pairingInfoViewController, animated: true)
        } else if state == .success {
            let pairingInfoViewController = TTPairingInfoViewController(pairingState: .success)
            self.navigationController?.pushViewController(pairingInfoViewController, animated: true)
        }
    }
    
    func changedDeviceCount() {
        let connected = appDelegate().bluetoothMonitor.unpairedDevicesCount?.intValue > 0
        let connecting = appDelegate().bluetoothMonitor.unpairedConnectingCount?.intValue > 0
        countdownIndicator.setProgress(0, animated: false)

        if !connected && !connecting {
            countdownIndicator.isHidden = true
            spinnerScanning.isHidden = false
            let runner = RunLoop.current
            searchingTimer?.invalidate()
            searchingTimer = Timer.scheduledTimer(timeInterval: 20, target: self,
                                                                    selector: #selector(searchingFailure),
                                                                    userInfo: nil, repeats: false)
            runner.add(searchingTimer!, forMode: RunLoopMode.commonModes)
            
            spinnerScanning.setNeedsDisplay()
            titleLabel.text = "Pairing your Turn Touch"
            subtitleLabel.text = "Searching for remotes..."
            countdownTimer?.invalidate()
            countdownTimer = nil
        } else if connecting && !connected {
            countdownIndicator.isHidden = true
            spinnerScanning.isHidden = false
            titleLabel.text = "Pairing your Turn Touch"
            subtitleLabel.text = "Connecting..."
            searchingTimer?.invalidate()
        } else if connected {
            countdownIndicator.isHidden = false
            countdownIndicator.progress = 0
            spinnerScanning.isHidden = true
            titleLabel.text = "Pairing your Turn Touch"
            subtitleLabel.text = "Press all four buttons to connect"
            searchingTimer?.invalidate()
            self.updateCountdown()
        }
    }
    
    // MARK: Countdown timer
    
    func updateCountdown() {
        let minusOneSecond = countdownIndicator.progress + 1/Float(secondsToPair)
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.countdownIndicator.setProgress(minusOneSecond, animated: true)
        })
        
        print(" ---> Countdown: \(countdownIndicator.progress)")
        if minusOneSecond > 1 {
            appDelegate().bluetoothMonitor.disconnectUnpairedDevices()
            self.changePairingState(.failure)
            countdownTimer?.invalidate()
            countdownTimer = nil
        } else {
            let runner = RunLoop.current
            countdownTimer?.invalidate()
            countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                                                    selector: #selector(updateCountdown),
                                                                    userInfo: nil, repeats: false)
            runner.add(countdownTimer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    func searchingFailure() {
        searchingTimer?.invalidate()
        self.changePairingState(.failure)
    }
    
    func pairingSuccess() {
        self.changePairingState(.success)
    }
}
