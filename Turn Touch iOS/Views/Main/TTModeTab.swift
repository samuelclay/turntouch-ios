//
//  TTModeTab.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

let DIAMOND_SIZE: CGFloat = 22.0

class TTModeTab: UIView {
    
    var modeDirection: TTModeDirection = .NO_DIRECTION
    var modeTitle: NSString = ""
    var modeAttributes: [String: AnyObject] = [:]
    var textSize: CGSize = CGSizeZero
    var highlighted: Bool = false
    
    init(modeDirection: TTModeDirection) {
        self.modeDirection = modeDirection
        super.init(frame:CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false

        setupMode()
        setupTitleAttributes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupMode() {
        switch modeDirection {
        case .NORTH:
            break
            // itemMode = appDelegate.modeMap.northMode
        default:
            break
        }
    }
    
    func setupTitleAttributes() {
        self.modeTitle = "Test"
        self.modeAttributes = [
            UIFontDescriptorNameAttribute: UIFont(name: "Effra", size: 13)!,
            NSShadowAttributeName: {
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.whiteColor()
                shadow.shadowOffset = CGSizeMake(0, -1)
                shadow.shadowBlurRadius = 0
                return shadow
            }(),
        ]
        self.textSize = self.modeTitle.sizeWithAttributes(self.modeAttributes)
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        
        self.setupTitleAttributes()
        self.drawBackground()
        self.drawBorders()
        
        let titleSize: CGSize = self.modeTitle.sizeWithAttributes(self.modeAttributes)
        let titlePoint: CGPoint = CGPointMake(CGRectGetWidth(self.frame)/2 - titleSize.width/2, 18)
        
        self.modeTitle.drawAtPoint(titlePoint, withAttributes: self.modeAttributes)
        
//        let diamondRect = CGRectMake(CGRectGetWidth(self.frame)/2 - (DIAMOND_SIZE * 1.3 / 2),
//                                     CGRectGetHeight(self.frame) - 18 - DIAMOND_SIZE,
//                                     DIAMOND_SIZE * 1.3, DIAMOND_SIZE)
        
    }
    
    func drawBackground() {
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        UIColor.blueColor().setFill()
        CGContextFillRect(context, self.frame)
    }
    
    func drawBorders() {
        
    }

}
