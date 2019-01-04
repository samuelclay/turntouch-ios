//
//  TTDeviceTitleView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/12/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary

class TTDeviceTitleView: UIView, TTTitleMenuDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate, UIAlertViewDelegate {
    
    var menuHeight: Int = 42
    var device: TTDevice!
    var titleLabel: UILabel = UILabel()
    var stateLabel: UILabel = UILabel()
    var deviceImageView: UIImageView = UIImageView()
    var dfuProgress: UIProgressView = UIProgressView()
    var dfuSpinner: TTPairingSpinner = TTPairingSpinner()
    var upgradeButton: UIButton = UIButton()
    @IBOutlet var settingsButton: UIButton! = UIButton(type: UIButton.ButtonType.system)
    fileprivate var dfuController: DFUServiceController?

    init(device: TTDevice) {
        super.init(frame: CGRect.zero)
        
        self.device = device
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIView.ContentMode.redraw;
        self.backgroundColor = UIColor(hex: 0xF5F6F8)

        deviceImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(deviceImageView)
        self.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .leadingMargin, relatedBy: .equal,
            toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        deviceImageView.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32))
        deviceImageView.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32))
        
        
        titleLabel.font = UIFont(name: "Effra", size: 15)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal,
            toItem: deviceImageView, attribute: .trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))

        
        let settingsImage = UIImage(named: "settings")
        settingsButton.setImage(settingsImage, for: UIControl.State())
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(self.pressSettings(_:)), for: .touchUpInside)
        self.addSubview(settingsButton)
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .trailingMargin, relatedBy: .equal,
            toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: -18))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        stateLabel.isHidden = true
        stateLabel.font = UIFont(name: "Effra", size: 15)
        stateLabel.textColor = UIColor(hex: 0x808AA0)
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.textAlignment = .right
        self.addSubview(stateLabel)
        self.addConstraint(NSLayoutConstraint(item: stateLabel, attribute: .right, relatedBy: .equal,
            toItem: settingsButton, attribute: .left, multiplier: 1.0, constant: -12))
        self.addConstraint(NSLayoutConstraint(item: stateLabel, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
 
        let latestVersion = UserDefaults.standard.integer(forKey: "TT:firmware:version")
        upgradeButton.isHidden = false
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.titleLabel!.textAlignment = .right
        upgradeButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        upgradeButton.setTitleColor(upgradeButton.tintColor, for: .normal)
        upgradeButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        upgradeButton.setTitle("Upgrade to v\(latestVersion)", for: .normal)
        upgradeButton.addTarget(self, action: #selector(self.pressUpgrade(_:)), for: .touchUpInside)
        self.addSubview(upgradeButton)
        self.addConstraint(NSLayoutConstraint(item: upgradeButton, attribute: .right, relatedBy: .equal,
                                              toItem: settingsButton, attribute: .left, multiplier: 1.0, constant: -12))
        self.addConstraint(NSLayoutConstraint(item: upgradeButton, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        dfuProgress.isHidden = false
        dfuProgress.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dfuProgress)
        self.addConstraint(NSLayoutConstraint(item: dfuProgress, attribute: .right, relatedBy: .equal,
                                              toItem: settingsButton, attribute: .left, multiplier: 1.0, constant: -12))
        self.addConstraint(NSLayoutConstraint(item: dfuProgress, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: dfuProgress, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60))
        
        dfuSpinner.isHidden = false
        dfuSpinner.translatesAutoresizingMaskIntoConstraints = false
        dfuSpinner.backgroundColor = UIColor.clear
        self.addSubview(dfuSpinner)
        self.addConstraint(NSLayoutConstraint(item: dfuSpinner, attribute: .right, relatedBy: .equal,
                                              toItem: dfuProgress, attribute: .left, multiplier: 1.0, constant: -12))
        self.addConstraint(NSLayoutConstraint(item: dfuSpinner, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: dfuSpinner, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16))
        self.addConstraint(NSLayoutConstraint(item: dfuSpinner, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16))
        
        self.registerAsObserver()
        self.updateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        device.addObserver(self, forKeyPath: "isFirmwareOld", options: [], context: nil)
        device.addObserver(self, forKeyPath: "inDFU", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            if keyPath == "selectedModeDirection" {
                self.setNeedsDisplay()
            } else if keyPath == "openedModeChangeMenu" {
                self.setNeedsDisplay()
            } else if keyPath == "isFirmwareOld" {
                self.updateLayout()
                self.setNeedsDisplay()
            } else if keyPath == "inDFU" {
                self.updateLayout()
                self.setNeedsDisplay()
            }
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        device.removeObserver(self, forKeyPath: "isFirmwareOld")
        device.removeObserver(self, forKeyPath: "inDFU")
    }

    // MARK: Drawing

    override func draw(_ rect: CGRect) {
        deviceImageView.image = UIImage(named:"remote_graphic")
        titleLabel.text = device.nickname
        titleLabel.sizeToFit()
        stateLabel.text = device.stateLabel()
        
        super.draw(rect)
        
        self.drawBorder()
    }
    
    func updateLayout() {
        if device.isFirmwareOld && !device.inDFU {
            dfuSpinner.isHidden = true
            dfuProgress.isHidden = true
            stateLabel.isHidden = true
            upgradeButton.isHidden = false
            self.backgroundColor = UIColor(hex: 0xFAFCE0)
        } else if device.inDFU {
            dfuProgress.isHidden = false
            dfuSpinner.isHidden = false
            stateLabel.isHidden = true
            upgradeButton.isHidden = true
            self.backgroundColor = UIColor(hex: 0xFAFCE0)
        } else {
            dfuSpinner.isHidden = true
            dfuProgress.isHidden = true
            stateLabel.isHidden = false
            upgradeButton.isHidden = true
            self.backgroundColor = UIColor(hex: 0xF5F6F8)
        }
        
        dfuSpinner.setNeedsDisplay()
    }
    
    func drawBorder() {
        let line = UIBezierPath()
        line.lineWidth = 1.0
        UIColor(hex: 0xC2CBCE).set()
        
        // Top border
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        line.stroke()
    }
    
    // MARK: Actions
    
    @objc func pressSettings(_ sender: UIButton!) {
        appDelegate().mainViewController.toggleDeviceMenu(sender, deviceTitleView: self, device: device)
    }
    
    @objc func pressUpgrade(_ sendor: UIButton!) {
        startDFUProcess()
    }
    
    // MARK: Menu Delegate
    
    func menuOptions() -> [[String : String]] {
        return [
            ["title": device.batteryPct != nil ? "Battery: \(device.batteryPct!)%" : "> Not connected",
             "image": "battery"],
            ["title": device.firmwareVersion != nil ? "Firmware: v\(device.firmwareVersion!)" : "—",
             "image": "versions"],
            ["title": "Rename remote",
             "image": "rename"],
            ["title": "Forget this remote",
             "image": "remove"],
        ]
    }
    
    func selectMenuOption(_ row: Int) {
        switch row {
        case 1:
            startDFUProcess()
        case 2:
            showRenameDevice()
        case 3:
            appDelegate().bluetoothMonitor.forgetDevice(device)
        default:
            break
        }
        appDelegate().mainViewController.closeDeviceMenu()
    }
    
    func showRenameDevice() {
        
        let renameAlert = UIAlertController(title: "Rename remote", message: nil, preferredStyle: .alert)
        let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { (action) in
            let newNickname = renameAlert.textFields![0].text!
            print(" ---> New nickname: \(newNickname)")
            
            appDelegate().bluetoothMonitor.writeNicknameToDevice(self.device, nickname: newNickname)
        })

        renameAlert.addTextField { (textfield) in
            if let nickname = self.device.nickname {
                textfield.text = "\(nickname)"
            }
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textfield, queue: OperationQueue.main) { (notification) in
                renameAction.isEnabled = textfield.text != ""
            }
        }
        renameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        renameAlert.addAction(renameAction)
        appDelegate().mainViewController.closeDeviceMenu()
        appDelegate().mainViewController.present(renameAlert, animated: true, completion: nil)
    }
    
    // MARK: - DFU
    
    
    func startDFUProcess() {
        guard device.peripheral != nil else {
            print(" ---> No DFU peripheral was set")
            return
        }
        
        let dfuInitiator = DFUServiceInitiator(centralManager: appDelegate().bluetoothMonitor.manager,
                                               target: device.peripheral)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        
        // This enables the experimental Buttonless DFU feature from SDK 12.
        // Please, read the field documentation before use.
        dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        
        let latestFirmware = String(format: "%02d", UserDefaults.standard.integer(forKey: "TT:firmware:version"))
        let fileUrl = Bundle.main.url(forResource: "nrf51_\(latestFirmware)", withExtension: "zip", subdirectory: "DFU")!
        let selectedFirmware = DFUFirmware(urlToZipFile: fileUrl)

        dfuController = dfuInitiator.with(firmware: selectedFirmware!).start()
        appDelegate().mainViewController.closeDeviceMenu()
        
        device.inDFU = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(45)) {
            if self.device.inDFU && self.device.state == .device_STATE_CONNECTED {
                print(" ---> Error, took too long for DFU, aborting... \(self.device)")
                _ = self.dfuController?.abort()
            }
        }
    }
    
    
    //MARK: DFUServiceDelegate
    
    func dfuStateDidChange(to state:DFUState) {
//        switch state {
//        case .completed, .disconnecting, .aborted:
//            self.dfuActivityIndicator.stopAnimating()
//            self.dfuUploadProgressView.setProgress(0, animated: true)
//            self.stopProcessButton.isEnabled = false
//        default:
//            self.stopProcessButton.isEnabled = true
//        }
//        
//        self.dfuStatusLabel.text = state.description()
        print("Changed state to: \(state.description())")
        
        // Forget the controller when DFU is done
        if state == .completed || state == .aborted {
            print(" ---> Returning Bluetooth Monitor")
            dfuController = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { 
                appDelegate().bluetoothMonitor.manager.delegate = appDelegate().bluetoothMonitor
                appDelegate().bluetoothMonitor.disconnectDevice(self.device)
                appDelegate().bluetoothMonitor.scanKnown()
            })
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
//        self.dfuStatusLabel.text = "Error \(error.rawValue): \(message)"
//        self.dfuActivityIndicator.stopAnimating()
//        self.dfuUploadProgressView.setProgress(0, animated: true)
        print("Error \(error.rawValue): \(message)")
        
        self.startDFUProcess()
    }
    
    //MARK: DFUProgressDelegate
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
//        self.dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
//        self.dfuUploadStatus.text = String(format: "Part: %d/%d\nSpeed: %.1f KB/s\nAverage Speed: %.1f KB/s",
//                                           part, totalParts, currentSpeedBytesPerSecond/1024, avgSpeedBytesPerSecond/1024)
        print(" ---> Progress: \(progress)%")
        
        dfuProgress.setProgress(Float(progress)/100, animated: true)
    }
    
    //MARK: LoggerDelegate
    
    func logWith(_ level:LogLevel, message:String) {
        print("\(level.name()): \(message)")
    }

}
