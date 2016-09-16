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
//    let iconView: UIImageView!
    
    
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
        if diamondType == .interactive {
            titleLabel.textColor = UIColor(hex: 0x404A60)
        } else if diamondType == .hud {
            titleLabel.textColor = UIColor(hex: 0xFFFFFF)
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
            toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal,
            toItem: self, attribute: .height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal,
            toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let actionString = appDelegate().modeMap.selectedMode.titleInDirection(labelDirection,
                                                                               buttonMoment: .button_MOMENT_PRESSUP)
        titleLabel.text = actionString
    }
    
    func setMode(_ mode: TTMode) {
        diamondMode = mode

        self.setNeedsDisplay()
    }
    
}
