//
//  TTDiamondLabel.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTDiamondLabel: UIView {
    
    var diamondMode: TTMode!
    var diamondType: TTDiamondType!
    var labelDirection = TTModeDirection.no_DIRECTION
    var titleLabel: UILabel!
    var iconView = UIImageView()
    
    init(inDirection: TTModeDirection, diamondType: TTDiamondType = .interactive) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = false
        
        self.diamondType = diamondType
        labelDirection = inDirection
        diamondMode = appDelegate().modeMap.selectedMode
        
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        
        guard let titleLabel = titleLabel else {
            return
        }
        
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
            toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal,
            toItem: self, attribute: .height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal,
            toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        
        iconView.image = UIImage(named: "title")
        iconView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(iconView)
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerX, relatedBy: .equal,
                                              toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: -24))
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18))
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if diamondType == .interactive {
            titleLabel.textColor = UIColor(hex: 0x404A60)
        } else if diamondType == .hud {
            titleLabel.textColor = UIColor(hex: 0xFFFFFF)
        }
        
        #if WIDGET
        if appDelegate().mainViewController.isCompact {
            titleLabel.font = UIFont(name: "Effra", size: 9)
        } else {
            titleLabel.font = UIFont(name: "Effra", size: 13)
        }
        #endif
        
        let actionString = appDelegate().modeMap.selectedMode.titleInDirection(labelDirection,
                                                                               buttonMoment: .button_MOMENT_PRESSUP)
        titleLabel.text = actionString
        
        if appDelegate().modeMap.buttonAppMode() == .SixteenButtons {
            iconView.isHidden = true
        } else {
            let imageName = type(of: appDelegate().modeMap.modeInDirection(labelDirection)).imageName()
            if imageName != "" {
                iconView.image = UIImage(named: imageName)
                iconView.isHidden = false
            }
        }
    }
    
    func setMode(_ mode: TTMode) {
        diamondMode = mode

        self.setNeedsDisplay()
    }
    
}
