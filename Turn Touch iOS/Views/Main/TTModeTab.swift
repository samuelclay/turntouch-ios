//
//  TTModeTab.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

let DIAMOND_SIZE: CGFloat = 24.0

class TTModeTab: UIView {

    @IBInspectable var startColor: UIColor = UIColor.whiteColor()
    @IBInspectable var endColor: UIColor = UIColor(hex: 0xE7E7E7)
    
    var mode: TTMode = TTMode()
    var modeDirection: TTModeDirection = .NO_DIRECTION
    var modeTitle: String = ""
    var highlighted: Bool = false
    var titleLabel: UILabel = UILabel()
    var diamondView: TTDiamondView = TTDiamondView()
    
    init(modeDirection: TTModeDirection) {
        self.modeDirection = modeDirection
        let font = UIFont(name: "Effra", size: 13)
        self.titleLabel.font = font
        self.titleLabel.shadowOffset = CGSizeMake(0, 0.5)
        self.titleLabel.shadowColor = UIColor.whiteColor()
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame:CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIViewContentMode.Redraw;
        
        self.addSubview(self.titleLabel)
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Bottom, relatedBy: .Equal,
            toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -12))

        diamondView.overrideSelectedDirection = self.modeDirection
        diamondView.ignoreSelectedMode = true
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: -DIAMOND_SIZE/2))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: DIAMOND_SIZE*1.3))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: DIAMOND_SIZE))
        
        self.setupMode()
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupMode() {
        switch modeDirection {
        case .NORTH:
            self.mode = appDelegate().modeMap.northMode
        case .EAST:
            self.mode = appDelegate().modeMap.eastMode
        case .WEST:
            self.mode = appDelegate().modeMap.westMode
        case .SOUTH:
            self.mode = appDelegate().modeMap.southMode
        default:
            break
        }
        
        self.modeTitle = self.mode.title()
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: .Initial, context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "activeModeDirection", options: .Initial, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            self.setupMode()
            self.setNeedsDisplay()
        } else if keyPath == "activeModeDirection" {
            if appDelegate().modeMap.selectedModeDirection == modeDirection {
                diamondView.ignoreSelectedMode = false
                diamondView.ignoreActiveMode = false
//                self.setupMode()
                diamondView.setNeedsDisplay()
            } else {
                diamondView.ignoreSelectedMode = true
                diamondView.ignoreActiveMode = true
            }
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "activeModeDirection")
    }
    // MARK: Drawing

    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        
        self.drawBackground()
        self.drawBorders()
        
        let textColor = (appDelegate().modeMap.selectedModeDirection != self.modeDirection && !self.highlighted) ?
            UIColor(hex: 0x808388) : UIColor(hex: 0x404A60)
        self.titleLabel.textColor = textColor
        self.titleLabel.text = self.modeTitle.uppercaseString
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
            if self.highlighted {
                CGContextSetRGBFillColor(context, 0, 0, 0, 0.025);
                CGContextFillRect(context, self.bounds)
            }
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
        line.lineWidth = 1.0
        UIColor(hex: 0xC2CBCE).set()
        
        // Left border
        if self.modeDirection != .NORTH {
            line.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds)))
            line.addLineToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds)))
            line.stroke()
        }
        
        // Right border
        if self.modeDirection != .SOUTH {
            line.moveToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds)))
            line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)))
            line.stroke()
        }
        
        // Top border
        line.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds)))
        line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds)))
        line.stroke()
    }
    
    func drawInactiveBorder() {
        let line = UIBezierPath()
        let activeDirection = appDelegate().modeMap.selectedModeDirection
        line.lineWidth = 1.0
        UIColor(hex: 0xC2CBCE).set()
        
        // Right border
        if (self.modeDirection == .NORTH && activeDirection == .EAST) ||
            (self.modeDirection == .EAST && activeDirection == .WEST) ||
            (self.modeDirection == .WEST && activeDirection == .SOUTH) ||
            (self.modeDirection == .SOUTH) {
            
        } else {
            line.moveToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 24))
            line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - 24))
            line.stroke()
        }
        
        // Bottom border
        line.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds)))
        line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)))
        line.stroke()
        
        // Top border
        line.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds)))
        line.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds)))
        line.stroke()
    }
    
    // MARK: Actions
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.highlighted = true
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first {
            self.highlighted = CGRectContainsPoint(self.bounds, touch.locationInView(self))
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.highlighted = false
        self.setNeedsDisplay()
        super.touchesEnded(touches, withEvent: event)

        if let touch = touches.first {
            if CGRectContainsPoint(self.bounds, touch.locationInView(self)) {
                self.switchMode()
            }
        }
    }
    
    func switchMode() {
        appDelegate().modeMap.switchMode(self.modeDirection)
    }
}
