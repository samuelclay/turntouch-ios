//
//  TTActionDiamondView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/3/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTActionDiamondView: UIView {
    
    var diamondView: TTDiamondView!
    var diamondMode: TTMode!
    var diamondType: TTDiamondType!
    var northLabel: TTDiamondLabel!
    var eastLabel: TTDiamondLabel!
    var westLabel: TTDiamondLabel!
    var southLabel: TTDiamondLabel!
    var widthRegularConstraint: NSLayoutConstraint!
    var widthCompactConstraint: NSLayoutConstraint!
    var heightRegularConstraint: NSLayoutConstraint!
    var heightCompactConstraint: NSLayoutConstraint!
    
    init(diamondType: TTDiamondType) {
        super.init(frame: CGRect.zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        self.diamondType = diamondType
        northLabel = TTDiamondLabel(inDirection: .north, diamondType: diamondType)
        eastLabel = TTDiamondLabel(inDirection: .east, diamondType: diamondType)
        westLabel = TTDiamondLabel(inDirection: .west, diamondType: diamondType)
        southLabel = TTDiamondLabel(inDirection: .south, diamondType: diamondType)
        
        self.registerAsObserver()
        
        diamondView = TTDiamondView(frame: frame, diamondType: diamondType)
        diamondView.setContentCompressionResistancePriority(.required, for: .horizontal)
        if diamondType == .interactive {
            diamondView.showOutline = true
            diamondView.ignoreSelectedMode = true
        }
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        heightRegularConstraint = NSLayoutConstraint(item: diamondView, attribute: .height, relatedBy: .equal,
                                                     toItem: self, attribute: .height, multiplier: 0.8, constant: 0)
        heightCompactConstraint = NSLayoutConstraint(item: diamondView, attribute: .height, relatedBy: .equal,
                                                     toItem: self, attribute: .height, multiplier: 0.9, constant: 0)
        widthRegularConstraint = NSLayoutConstraint(item: diamondView, attribute: .width, relatedBy: .equal,
                                                    toItem: nil, attribute: .notAnAttribute,
                                                    multiplier: 1.0, constant: 525)
        widthRegularConstraint.priority = .defaultHigh
        widthCompactConstraint = NSLayoutConstraint(item: diamondView, attribute: .width, relatedBy: .equal,
                                                    toItem: self, attribute: .width, multiplier: 0.8, constant: 0)
        widthCompactConstraint.priority = .defaultHigh
        let maxWidthConstraint = NSLayoutConstraint(item: diamondView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 420)
        maxWidthConstraint.priority = .required
        self.addConstraint(maxWidthConstraint)
        
        self.addSubview(northLabel)
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .centerX, relatedBy: .equal,
            toItem: diamondView, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .top, relatedBy: .equal,
            toItem: diamondView, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .height, relatedBy: .equal,
            toItem: diamondView, attribute: .height, multiplier: 0.47, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .width, relatedBy: .equal,
            toItem: diamondView, attribute: .width, multiplier: 1.0, constant: 0))
        
        self.addSubview(eastLabel)
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .right, relatedBy: .equal,
            toItem: diamondView, attribute: .right, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .centerY, relatedBy: .equal,
            toItem: diamondView, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .height, relatedBy: .equal,
            toItem: diamondView, attribute: .height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .width, relatedBy: .equal,
            toItem: diamondView, attribute: .width, multiplier: 0.47, constant: 0))
        
        self.addSubview(westLabel)
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .left, relatedBy: .equal,
            toItem: diamondView, attribute: .left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .centerY, relatedBy: .equal,
            toItem: diamondView, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .height, relatedBy: .equal,
            toItem: diamondView, attribute: .height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .width, relatedBy: .equal,
            toItem: diamondView, attribute: .width, multiplier: 0.47, constant: 0))
        
        self.addSubview(southLabel)
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .centerX, relatedBy: .equal,
            toItem: diamondView, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .bottom, relatedBy: .equal,
            toItem: diamondView, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .height, relatedBy: .equal,
            toItem: diamondView, attribute: .height, multiplier: 0.47, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .width, relatedBy: .equal,
            toItem: diamondView, attribute: .width, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            self.setMode(appDelegate().modeMap.selectedMode)
            self.setNeedsLayout()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
    }
    
    // MARK: Drawing

    func setMode(_ mode: TTMode) {
        diamondMode = mode
        self.setNeedsLayout()

        northLabel.setMode(mode)
        eastLabel.setMode(mode)
        westLabel.setMode(mode)
        southLabel.setMode(mode)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func updateLayout() {
        if self.traitCollection.horizontalSizeClass == .compact {
            self.removeConstraint(widthRegularConstraint)
            self.addConstraint(widthCompactConstraint)
        } else {
            self.removeConstraint(widthCompactConstraint)
            self.addConstraint(widthRegularConstraint)
        }
        if self.traitCollection.verticalSizeClass == .compact {
            self.removeConstraint(heightRegularConstraint)
            self.addConstraint(heightCompactConstraint)
        } else {
            self.removeConstraint(heightCompactConstraint)
            self.addConstraint(heightRegularConstraint)
        }
        
        self.layoutIfNeeded()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact {
            self.updateLayout()
        } else {
            self.updateLayout()
        }
    }
    
}
