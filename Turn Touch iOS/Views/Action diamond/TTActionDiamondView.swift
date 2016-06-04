//
//  TTActionDiamondView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/3/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTActionDiamondView: UIView {
    
    let diamondView = TTDiamondView()
    var diamondMode: TTMode!
    let northLabel = TTDiamondLabel(inDirection: .NORTH)
    let eastLabel = TTDiamondLabel(inDirection: .EAST)
    let westLabel = TTDiamondLabel(inDirection: .WEST)
    let southLabel = TTDiamondLabel(inDirection: .SOUTH)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(hex: 0xF5F6F8)
        
        diamondView.showOutline = true
        diamondView.ignoreSelectedMode = true
        diamondView.diamondType = TTDiamondType.DIAMOND_TYPE_INTERACTIVE
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Height, relatedBy: .Equal,
            toItem: self, attribute: .Height, multiplier: 0.8, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        
        self.addSubview(northLabel)
        self.addSubview(eastLabel)
        self.addSubview(westLabel)
        self.addSubview(southLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        diamondView.frame = self.bounds.insetBy(dx: 24, dy: 24)
    }
    
    func setMode(mode: TTMode) {
        diamondMode = mode
        northLabel.setMode(mode)
        eastLabel.setMode(mode)
        westLabel.setMode(mode)
        southLabel.setMode(mode)
    }
}
