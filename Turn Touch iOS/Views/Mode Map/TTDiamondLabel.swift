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
    var labelDirection = TTModeDirection.NO_DIRECTION
    var titleLabel: UILabel!
//    let iconView: UIImageView!
    
    
    init(inDirection: TTModeDirection) {
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.userInteractionEnabled = false
        
        labelDirection = inDirection
        diamondMode = appDelegate().modeMap.selectedMode
        
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .Center
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal,
            toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal,
            toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal,
            toItem: self, attribute: .Height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let actionString = appDelegate().modeMap.selectedMode.titleInDirection(labelDirection,
                                                                               buttonMoment: .BUTTON_MOMENT_PRESSUP)
        titleLabel.text = actionString
    }
    
    func setMode(mode: TTMode) {
        diamondMode = mode

        self.setNeedsDisplay()
    }
    
}
