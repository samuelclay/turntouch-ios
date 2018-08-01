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
        self.axis = .vertical
        self.distribution = .fillEqually
        self.alignment = .fill
        self.spacing = 0
        
        self.registerAsObserver()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "nicknamedConnectedCount", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "pairedDevicesCount", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "knownDevicesCount", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async { 
            if keyPath == "nicknamedConnectedCount" {
                self.assembleDeviceTitles()
            } else if keyPath == "pairedDevicesCount" {
                self.assembleDeviceTitles()
            } else if keyPath == "knownDevicesCount" {
                self.assembleDeviceTitles()
            }
        }
    }
    
    deinit {
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "nicknamedConnectedCount")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "pairedDevicesCount")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "knownDevicesCount")
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func assembleDeviceTitles() {
        var deviceTitleConstraints: [NSLayoutConstraint] = []
        let devices = appDelegate().bluetoothMonitor.foundDevices.devices
        
//        print(" ---> Assembling device titles: \(devices)")

        self.removeConstraints(self.constraints)
        for subview in self.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for device: TTDevice in devices {
            let deviceView = TTDeviceTitleView(device: device)
            self.addArrangedSubview(deviceView)
            deviceTitleConstraints.append(NSLayoutConstraint(item: deviceView, attribute: .height,
                relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44))
            deviceTitleConstraints.append(NSLayoutConstraint(item: deviceView, attribute: .width,
                relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
            deviceTitleConstraints.append(NSLayoutConstraint(item: deviceView, attribute: .leading,
                relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        }
        
        self.addConstraints(deviceTitleConstraints)
    }
    
}
