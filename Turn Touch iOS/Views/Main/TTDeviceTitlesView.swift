//
//  TTDeviceTitlesView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/12/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTDeviceTitlesView: UIStackView {
    
    
    init() {
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .Vertical
        self.distribution = .FillEqually
        self.alignment = .Fill
        self.spacing = 0
        
        self.registerAsObserver()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedMode", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "nicknamedConnectedCount", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "pairedDevicesCount", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        dispatch_async(dispatch_get_main_queue()) { 
            if keyPath == "nicknamedConnectedCount" {
                self.assembleDeviceTitles()
            } else if keyPath == "pairedDevicesCount" {
                self.assembleDeviceTitles()
            }
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedMode")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "nicknamedConnectedCount")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "pairedDevicesCount")
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    func assembleDeviceTitles() {
        var deviceTitleConstraints: [NSLayoutConstraint] = []
        let devices = appDelegate().bluetoothMonitor.foundDevices.nicknamedConnected()
        
        self.removeConstraints(self.constraints)
        for subview in self.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for device: TTDevice in devices {
            let deviceView = TTDeviceTitleView(device: device)
            self.addArrangedSubview(deviceView)
            deviceTitleConstraints.append(NSLayoutConstraint(item: deviceView, attribute: .Height,
                relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
            deviceTitleConstraints.append(NSLayoutConstraint(item: deviceView, attribute: .Width,
                relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
            deviceTitleConstraints.append(NSLayoutConstraint(item: deviceView, attribute: .Leading,
                relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0))
        }
        
        self.addConstraints(deviceTitleConstraints)
    }
    
}
