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
    var deviceImageView: UIImageView = UIImageView()
    @IBOutlet var settingsButton = UIButton(type: UIButtonType.System) as UIButton!

    init(device: TTDevice) {
        super.init(frame: CGRect.zero)
        
        self.device = device
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIViewContentMode.Redraw;
        self.backgroundColor = UIColor(hex: 0xF5F6F8)
        
        deviceImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(deviceImageView)
        self.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .Leading, relatedBy: .Equal,
            toItem: self, attribute: .Leading, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        deviceImageView.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32))
        deviceImageView.addConstraint(NSLayoutConstraint(item: deviceImageView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32))
        
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal,
            toItem: deviceImageView, attribute: .Trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))

        
        let settingsImage = UIImage(named: "settings")
        settingsButton.setImage(settingsImage, forState: UIControlState.Normal)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(self.pressSettings(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(settingsButton)
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.Right, relatedBy: .Equal,
            toItem: self, attribute: .Right, multiplier: 1.0, constant: -18))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
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

    override func drawRect(rect: CGRect) {
        deviceImageView.image = UIImage(named:"remote_graphic")
        titleLabel.text = device.nickname
        
        super.drawRect(rect)
        
        self.drawBorder()
    }
    
    func drawBorder() {
        let line = UIBezierPath()
        line.lineWidth = 1.0
        UIColor(hex: 0xC2CBCE).set()
        
        // Top border
        line.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds)))
        line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds)))
        line.stroke()
    }
    
    // MARK: Actions
    
    func pressSettings(sender: UIButton!) {
        appDelegate().mainViewController.toggleDeviceMenu(sender, deviceTitleView: self, device: device)
    }
    
    // MARK: Menu Delegate
    
    func menuOptions() -> [[String : String]] {
        return [
            ["title": "Battery: "],
            ["title": "Rename remote"],
            ["title": "Forget this remote"],
        ]
    }
    
    func selectMenuOption(row: Int) {
        switch row {
        case 2:
            appDelegate().bluetoothMonitor.disconnectDevice(device)
        default:
            break
        }
        appDelegate().mainViewController.closeDeviceMenu()
    }
}
