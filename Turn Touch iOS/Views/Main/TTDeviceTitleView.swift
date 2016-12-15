//
//  TTDeviceTitleView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/12/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTDeviceTitleView: UIView, TTTitleMenuDelegate {

    var device: TTDevice!
    var titleLabel: UILabel = UILabel()
    var stateLabel: UILabel = UILabel()
    var deviceImageView: UIImageView = UIImageView()
    @IBOutlet var settingsButton: UIButton! = UIButton(type: UIButtonType.system)

    init(device: TTDevice) {
        super.init(frame: CGRect.zero)
        
        self.device = device
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIViewContentMode.redraw;
        self.backgroundColor = UIColor(hex: 0xF5F6F8)
        
        deviceImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(deviceImageView)
        self.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .leading, relatedBy: .equal,
            toItem: self, attribute: .leading, multiplier: 1.0, constant: 24))
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
        settingsButton.setImage(settingsImage, for: UIControlState())
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(self.pressSettings(_:)), for: .touchUpInside)
        self.addSubview(settingsButton)
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.right, relatedBy: .equal,
            toItem: self, attribute: .right, multiplier: 1.0, constant: -18))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        stateLabel.font = UIFont(name: "Effra", size: 15)
        stateLabel.textColor = UIColor(hex: 0x808AA0)
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.textAlignment = .right
        self.addSubview(stateLabel)
        self.addConstraint(NSLayoutConstraint(item: stateLabel, attribute: .right, relatedBy: .equal,
            toItem: settingsButton, attribute: .left, multiplier: 1.0, constant: -12))
        self.addConstraint(NSLayoutConstraint(item: stateLabel, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))

        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "openedModeChangeMenu" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
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
    
    func pressSettings(_ sender: UIButton!) {
        appDelegate().mainViewController.toggleDeviceMenu(sender, deviceTitleView: self, device: device)
    }
    
    // MARK: Menu Delegate
    
    func menuOptions() -> [[String : String]] {
        return [
            ["title": device.batteryPct != nil ? "Battery: \(device.batteryPct!)%" : "> Not connected"],
            ["title": device.firmwareVersion != nil ? "Firmware: v\(device.firmwareVersion!)" : "—"],
            ["title": "Rename remote"],
            ["title": "Forget this remote"],
        ]
    }
    
    func selectMenuOption(_ row: Int) {
        switch row {
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
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textfield, queue: OperationQueue.main) { (notification) in
                renameAction.isEnabled = textfield.text != ""
            }
        }
        renameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        renameAlert.addAction(renameAction)
        appDelegate().mainViewController.closeDeviceMenu()
        appDelegate().mainViewController.present(renameAlert, animated: true, completion: nil)
    }
}
