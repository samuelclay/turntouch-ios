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
    let northLabel = TTDiamondLabel(inDirection: .NORTH)
    let eastLabel = TTDiamondLabel(inDirection: .EAST)
    let westLabel = TTDiamondLabel(inDirection: .WEST)
    let southLabel = TTDiamondLabel(inDirection: .SOUTH)
    var widthRegularConstraint: NSLayoutConstraint!
    var widthCompactConstraint: NSLayoutConstraint!
    var heightRegularConstraint: NSLayoutConstraint!
    var heightCompactConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = true

        self.registerAsObserver()
        
        diamondView = TTDiamondView(frame: frame)
        diamondView.showOutline = true
        diamondView.ignoreSelectedMode = true
        diamondView.diamondType = TTDiamondType.DIAMOND_TYPE_INTERACTIVE
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        heightRegularConstraint = NSLayoutConstraint(item: diamondView, attribute: .Height, relatedBy: .Equal,
                                                     toItem: self, attribute: .Height, multiplier: 0.8, constant: 0)
        heightCompactConstraint = NSLayoutConstraint(item: diamondView, attribute: .Height, relatedBy: .Equal,
                                                     toItem: self, attribute: .Height, multiplier: 0.9, constant: 0)
        widthRegularConstraint = NSLayoutConstraint(item: diamondView, attribute: .Width, relatedBy: .Equal,
                                                    toItem: nil, attribute: .NotAnAttribute,
                                                    multiplier: 1.0, constant: 525)
        widthCompactConstraint = NSLayoutConstraint(item: diamondView, attribute: .Width, relatedBy: .Equal,
                                                    toItem: self, attribute: .Width, multiplier: 0.8, constant: 0)
        
        self.addSubview(northLabel)
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .CenterX, relatedBy: .Equal,
            toItem: diamondView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .Top, relatedBy: .Equal,
            toItem: diamondView, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .Height, relatedBy: .Equal,
            toItem: diamondView, attribute: .Height, multiplier: 0.47, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: northLabel, attribute: .Width, relatedBy: .Equal,
            toItem: diamondView, attribute: .Width, multiplier: 1.0, constant: 0))
        
        self.addSubview(eastLabel)
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .Right, relatedBy: .Equal,
            toItem: diamondView, attribute: .Right, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: diamondView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .Height, relatedBy: .Equal,
            toItem: diamondView, attribute: .Height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: eastLabel, attribute: .Width, relatedBy: .Equal,
            toItem: diamondView, attribute: .Width, multiplier: 0.47, constant: 0))
        
        self.addSubview(westLabel)
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .Left, relatedBy: .Equal,
            toItem: diamondView, attribute: .Left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: diamondView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .Height, relatedBy: .Equal,
            toItem: diamondView, attribute: .Height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: westLabel, attribute: .Width, relatedBy: .Equal,
            toItem: diamondView, attribute: .Width, multiplier: 0.47, constant: 0))
        
        self.addSubview(southLabel)
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .CenterX, relatedBy: .Equal,
            toItem: diamondView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .Bottom, relatedBy: .Equal,
            toItem: diamondView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .Height, relatedBy: .Equal,
            toItem: diamondView, attribute: .Height, multiplier: 0.47, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: southLabel, attribute: .Width, relatedBy: .Equal,
            toItem: diamondView, attribute: .Width, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            self.setMode(appDelegate().modeMap.selectedMode)
            self.setNeedsLayout()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
    }
    
    // MARK: Drawing

    func setMode(mode: TTMode) {
        diamondMode = mode
        self.setNeedsLayout()

        northLabel.setMode(mode)
        eastLabel.setMode(mode)
        westLabel.setMode(mode)
        southLabel.setMode(mode)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    func updateLayout() {
        if self.traitCollection.horizontalSizeClass == .Compact {
            self.removeConstraint(widthRegularConstraint)
            self.addConstraint(widthCompactConstraint)
        } else {
            self.removeConstraint(widthCompactConstraint)
            self.addConstraint(widthRegularConstraint)
        }
        if self.traitCollection.verticalSizeClass == .Compact {
            self.removeConstraint(heightRegularConstraint)
            self.addConstraint(heightCompactConstraint)
        } else {
            self.removeConstraint(heightCompactConstraint)
            self.addConstraint(heightRegularConstraint)
        }
        
        self.layoutIfNeeded()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            self.updateLayout()
        } else {
            self.updateLayout()
        }
    }
    
}
