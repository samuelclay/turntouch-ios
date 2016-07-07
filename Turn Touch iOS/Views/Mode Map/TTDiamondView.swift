//
//  TTDiamondView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTDiamondType: Int {
    case DIAMOND_TYPE_INTERACTIVE
    case DIAMOND_TYPE_MODE
    case DIAMOND_TYPE_HUD
    case DIAMOND_TYPE_PAIRING
}

let SPACING_PCT: CGFloat = 0.0175

class TTDiamondView: UIView {
    
    var northPathTop: UIBezierPath!
    var northPathBottom: UIBezierPath!
    var eastPathTop: UIBezierPath!
    var eastPathBottom: UIBezierPath!
    var westPathTop: UIBezierPath!
    var westPathBottom: UIBezierPath!
    var southPathTop: UIBezierPath!
    var southPathBottom: UIBezierPath!
    
    var diamondType: TTDiamondType = .DIAMOND_TYPE_MODE
    var overrideSelectedDirection: TTModeDirection = .NO_DIRECTION
    var overrideActiveDirection: TTModeDirection = .NO_DIRECTION
    @IBInspectable var ignoreSelectedMode: Bool = false
    var ignoreActiveMode = false
    var showOutline = false
    var connected = false
    
    @IBInspectable var diamondTypeAdapter: Int {
        get {
            return self.diamondType.rawValue
        }
        set (diamondTypeIndex) {
            self.diamondType = TTDiamondType(rawValue: diamondTypeIndex) ?? .DIAMOND_TYPE_HUD
        }
    }
    @IBInspectable var overrideSelectedDirectionAdapter: Int {
        get {
            return self.overrideSelectedDirection.rawValue
        }
        set (index) {
            self.overrideSelectedDirection = TTModeDirection(rawValue: index) ?? .NO_DIRECTION
        }
    }
    
    override func awakeFromNib() {
        self.registerAsObserver()
        
        self.contentMode = .Redraw
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.userInteractionEnabled = true
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "activeModeDirection", options: [], context: nil)
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "activeModeDirection")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "inspectingModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "activeModeDirection" {
            if diamondType == .DIAMOND_TYPE_PAIRING {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.setNeedsDisplay()
                })
            } else {
                self.setNeedsDisplay()
            }
        }
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.drawPaths()
        if self.diamondType != .DIAMOND_TYPE_HUD {
            self.colorPaths()
        }
    }
    
    func drawPaths() {
        let width: CGFloat = CGRectGetWidth(self.bounds)
        let height: CGFloat = CGRectGetHeight(self.bounds)
        let spacing: CGFloat = SPACING_PCT * height
        northPathTop = UIBezierPath()
        northPathBottom = UIBezierPath()
        eastPathTop = UIBezierPath()
        eastPathBottom = UIBezierPath()
        westPathTop = UIBezierPath()
        westPathBottom = UIBezierPath()
        southPathTop = UIBezierPath()
        southPathBottom = UIBezierPath()
        
        northPathTop.lineJoinStyle = CGLineJoin.Miter
        northPathBottom.lineJoinStyle = CGLineJoin.Miter
        northPathBottom.moveToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 1 / 4 - spacing))
        northPathBottom.addLineToPoint(CGPointMake(width * 1 / 2, height * 1 / 2 - spacing * 2))
        northPathBottom.addLineToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 1 / 4 - spacing))
        northPathTop.moveToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 1 / 4 - spacing))
        northPathTop.addLineToPoint(CGPointMake(width * 1 / 2, 0))
        northPathTop.addLineToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 1 / 4 - spacing))

        eastPathTop.lineJoinStyle = CGLineJoin.Miter
        eastPathBottom.lineJoinStyle = CGLineJoin.Miter
        eastPathBottom.moveToPoint(CGPointMake(width * 1 / 2 + 1.3 * spacing * 2, height * 1 / 2))
        eastPathBottom.addLineToPoint(CGPointMake(width * 3 / 4 + 1.3 * spacing, height * 3 / 4 - spacing))
        eastPathBottom.addLineToPoint(CGPointMake(width, height * 1 / 2))
        eastPathTop.moveToPoint(CGPointMake(width, height * 1 / 2))
        eastPathTop.addLineToPoint(CGPointMake(width * 3 / 4 + 1.3 * spacing, height * 1 / 4 + spacing))
        eastPathTop.addLineToPoint(CGPointMake(width * 1 / 2 + 1.3 * spacing * 2, height * 1 / 2))
        
        westPathTop.lineJoinStyle = CGLineJoin.Miter
        westPathBottom.lineJoinStyle = CGLineJoin.Miter
        westPathBottom.moveToPoint(CGPointMake(width * 1 / 2 - 1.3 * spacing * 2, height * 1 / 2))
        westPathBottom.addLineToPoint(CGPointMake(width * 1 / 4 - 1.3 * spacing, height * 3 / 4 - spacing))
        westPathBottom.addLineToPoint(CGPointMake(0, height * 1 / 2))
        westPathTop.moveToPoint(CGPointMake(0, height * 1 / 2))
        westPathTop.addLineToPoint(CGPointMake(width * 1 / 4 - 1.3 * spacing, height * 1 / 4 + spacing))
        westPathTop.addLineToPoint(CGPointMake(width * 1 / 2 - 1.3 * spacing * 2, height * 1 / 2))
        
        southPathTop.lineJoinStyle = CGLineJoin.Miter
        southPathBottom.lineJoinStyle = CGLineJoin.Miter
        southPathBottom.moveToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 3 / 4 + spacing))
        southPathBottom.addLineToPoint(CGPointMake(width / 2, height))
        southPathBottom.addLineToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 3 / 4 + spacing))
        southPathTop.moveToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 3 / 4 + spacing))
        southPathTop.addLineToPoint(CGPointMake(width / 2, height / 2 + spacing * 2))
        southPathTop.addLineToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 3 / 4 + spacing))
    }
    
    func colorPaths() {
        let appD = appDelegate()
        let activeModeDirection: TTModeDirection = (ignoreActiveMode || diamondType == .DIAMOND_TYPE_INTERACTIVE) ? overrideActiveDirection : appD.modeMap.activeModeDirection
        let selectedModeDirection: TTModeDirection = ignoreSelectedMode ? overrideSelectedDirection : appD.modeMap.selectedModeDirection
        let inspectingModeDirection: TTModeDirection = appD.modeMap.inspectingModeDirection
        let hoverModeDirection: TTModeDirection = appD.modeMap.hoverModeDirection
        for path: UIBezierPath in [northPathTop, northPathBottom, eastPathTop, eastPathBottom, westPathTop, westPathBottom, southPathTop, southPathBottom] {
            var direction: TTModeDirection = .NO_DIRECTION
            let bottomHalf: Bool = [northPathBottom, eastPathBottom, westPathBottom, southPathBottom].containsObject(path)
            if path.isEqual(northPathTop) || path.isEqual(northPathBottom) {
                direction = .NORTH
            }
            else if path.isEqual(eastPathTop) || path.isEqual(eastPathBottom) {
                direction = .EAST
            }
            else if path.isEqual(westPathTop) || path.isEqual(westPathBottom) {
                direction = .WEST
            }
            else if path.isEqual(southPathTop) || path.isEqual(southPathBottom) {
                direction = .SOUTH
            }
            
            let isHoveringDirection: Bool = hoverModeDirection == direction
            var isInspectingDirection: Bool = inspectingModeDirection == direction
            var isSelectedDirection: Bool = selectedModeDirection == direction
            let isActiveDirection: Bool = activeModeDirection == direction
            if diamondType != .DIAMOND_TYPE_INTERACTIVE {
                isInspectingDirection = false
            }
            if diamondType == .DIAMOND_TYPE_PAIRING {
                isSelectedDirection = appD.bluetoothMonitor.buttonTimer.isDirectionPaired(direction)
            }
            // Fill in the color as a stroke or fill
            var modeColor: UIColor?
            if diamondType == .DIAMOND_TYPE_HUD {
                let alpha: Double = 0.9
                modeColor = UIColor(hex: 0xFFFFFF, alpha: alpha)
            }
            else if diamondType == .DIAMOND_TYPE_INTERACTIVE {
                if isActiveDirection {
                    modeColor = UIColor(hex: 0x505AC0)
                }
                else if isHoveringDirection && !isInspectingDirection {
                    modeColor = UIColor(hex: 0xD3D7D9)
                }
                else if isInspectingDirection {
                    modeColor = UIColor(hex: 0x303AA0)
                }
                else {
                    modeColor = UIColor(hex: 0xD3D7D9)
                    if bottomHalf {
                        modeColor = UIColor(hex: 0xC3C7C9)
                    }
                }
            }
            else if diamondType == .DIAMOND_TYPE_MODE || diamondType == .DIAMOND_TYPE_PAIRING {
                if isActiveDirection {
                    let alpha: Double = 0.5
                    modeColor = UIColor(hex: 0x303033, alpha: alpha)
                }
                else if isSelectedDirection {
                    if diamondType == .DIAMOND_TYPE_PAIRING || appD.modeMap.selectedModeDirection == direction {
                        let alpha: Double = 0.8
                        modeColor = UIColor(hex: 0x1555D8, alpha: alpha)
                    }
                    else {
                        let alpha: Double = 0.7
                        modeColor = UIColor(hex: 0x303033, alpha: alpha)
                    }
                }
                else {
                    let alpha: Double = 0.2
                    modeColor = UIColor(hex: 0x606063, alpha: alpha)
                }
            }
            
            let combinedPath = UIBezierPath()
            combinedPath.appendPath(path)
            if path == northPathTop {
                combinedPath.appendPath(northPathBottom)
            }
            if path == eastPathTop {
                combinedPath.appendPath(eastPathBottom)
            }
            if path == westPathTop {
                combinedPath.appendPath(westPathBottom)
            }
            if path == southPathTop {
                combinedPath.appendPath(southPathBottom)
            }
            if !showOutline {
                modeColor!.setFill()
                if !bottomHalf {
                    combinedPath.fill()
                }
            } else {
                combinedPath.lineWidth = isInspectingDirection ? 3.0 : 1.0
                modeColor!.setStroke()
                combinedPath.stroke()
            }
            
            if diamondType == .DIAMOND_TYPE_INTERACTIVE {
                if isActiveDirection {
                    UIColor(hex: 0xFFFFFF).set()
                }
                else if isInspectingDirection || isHoveringDirection {
                    UIColor(hex: 0xFFFFFF).set()
                }
                else {
                    UIColor(hex: 0xFAFBFD).set()
                }
                
                if !bottomHalf {
                    combinedPath.fill()
                }
            }
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            self.setNeedsDisplay()
        } else {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Events

    
    // NOTE: None of these work for some reason. The tap area is tiny and in the center of the diamond.
    //       You can find this functionality in TTActionDiamondView.
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if diamondType != .DIAMOND_TYPE_INTERACTIVE {
            return
        }
        
        if let touch = touches.first {
            let location = touch.locationInView(self)
            if northPathTop.containsPoint(location) || northPathBottom.containsPoint(location) {
                overrideActiveDirection = .NORTH
            } else if eastPathTop.containsPoint(location) || eastPathBottom.containsPoint(location) {
                overrideActiveDirection = .EAST
            } else if westPathTop.containsPoint(location) || westPathBottom.containsPoint(location) {
                overrideActiveDirection = .WEST
            } else if southPathTop.containsPoint(location) || southPathBottom.containsPoint(location) {
                overrideActiveDirection = .SOUTH
            }
        }
        
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        if diamondType != .DIAMOND_TYPE_INTERACTIVE {
            return
        }
        
        if let touch = touches.first {
            let location = touch.locationInView(self)
            if northPathTop.containsPoint(location) || northPathBottom.containsPoint(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.NORTH)
            } else if eastPathTop.containsPoint(location) || eastPathBottom.containsPoint(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.EAST)
            } else if westPathTop.containsPoint(location) || westPathBottom.containsPoint(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.WEST)
            } else if southPathTop.containsPoint(location) || southPathBottom.containsPoint(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.SOUTH)
            }
            overrideActiveDirection = .NO_DIRECTION
        }
        
        self.setNeedsDisplay()
    }
    
}
