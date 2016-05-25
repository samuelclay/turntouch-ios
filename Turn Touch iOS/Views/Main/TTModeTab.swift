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

    @IBInspectable var startColor: UIColor = UIColor.whiteColor()
    @IBInspectable var endColor: UIColor = UIColor(hex: 0xE7E7E7)
    
    var modeDirection: TTModeDirection = .NO_DIRECTION
    var modeTitle: NSString = ""
    var modeAttributes: [String: AnyObject] = [:]
    var textSize: CGSize = CGSizeZero
    var highlighted: Bool = false
    
    init(modeDirection: TTModeDirection) {
        self.modeDirection = modeDirection
        super.init(frame:CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = UIViewContentMode.Redraw;

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
                shadow.shadowOffset = CGSizeMake(0, 1)
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
        let titlePoint: CGPoint = CGPointMake(CGRectGetWidth(self.frame)/2 - titleSize.width/2,
                                              CGRectGetMaxY(self.frame) - 24)
        
        self.modeTitle.drawAtPoint(titlePoint, withAttributes: self.modeAttributes)
        
//        let diamondRect = CGRectMake(CGRectGetWidth(self.frame)/2 - (DIAMOND_SIZE * 1.3 / 2),
//                                     CGRectGetHeight(self.frame) - 18 - DIAMOND_SIZE,
//                                     DIAMOND_SIZE * 1.3, DIAMOND_SIZE)
        
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        if appDelegate().modeMap.selectedModeDirection == self.modeDirection {
            UIColor(hex: 0xFFFFFF).set()
            CGContextFillRect(context, self.bounds);
        } else {
            let colors = [startColor.CGColor, endColor.CGColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations:[CGFloat] = [0.0, 1.0]
            let gradient = CGGradientCreateWithColors(colorSpace,
                                                      colors,
                                                      colorLocations)
            let startPoint = CGPoint.zero
            let endPoint = CGPoint(x:0, y:self.bounds.height)

            CGContextDrawLinearGradient(context,
                                        gradient, 
                                        startPoint, 
                                        endPoint, 
                                        [])
        }
        
    }
    
    func drawBorders() {
        if appDelegate().modeMap.selectedModeDirection == self.modeDirection {
            self.drawActiveBorder()
        } else {
            self.drawInactiveBorder()
        }
    }
    
    func drawActiveBorder() {
        let line = UIBezierPath()
        
        // Left border
        if self.modeDirection != .NORTH {
            line.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds)))
            line.addLineToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds)))
            line.lineWidth = 1.0
            UIColor(hex: 0xC2CBCE).set()
            line.stroke()
        }
        
        // Right border
        if self.modeDirection != .SOUTH {
            line.moveToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds)))
            line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)))
            line.lineWidth = 1.0
            UIColor(hex: 0xC2CBCE).set()
            line.stroke()
        }
    }
    
    func drawInactiveBorder() {
        let line = UIBezierPath()
        let activeDirection = appDelegate().modeMap.selectedModeDirection
        
        // Right border
        if (self.modeDirection == .NORTH && activeDirection == .EAST) ||
            (self.modeDirection == .EAST && activeDirection == .WEST) ||
            (self.modeDirection == .WEST && activeDirection == .SOUTH) ||
            (self.modeDirection == .SOUTH) {
            
        } else {
            line.moveToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 24))
            line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - 24))
            line.lineWidth = 1.0
            UIColor(hex: 0xC2CBCE).set()
            line.stroke()
        }
        
        // Bottom border
        line.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds)))
        line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)))
        line.lineWidth = 1.0
        UIColor(hex: 0xC2CBCE).set()
        line.stroke()
    }

}
