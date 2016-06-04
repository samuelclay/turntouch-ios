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
//    let iconView: UIImageView!
    let titleLabel = UILabel()
    
    
    init(inDirection: TTModeDirection) {
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false

        labelDirection = inDirection
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        titleLabel.text = appDelegate().modeMap.selectedMode.titleInDirection(labelDirection,
                                                                              buttonMoment: .BUTTON_MOMENT_PRESSUP)
    }
    
    func setMode(mode: TTMode) {
        diamondMode = mode
    }
}
