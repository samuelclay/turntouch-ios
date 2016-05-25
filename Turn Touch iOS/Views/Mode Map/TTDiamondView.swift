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

let SPACING_PCT: CGFloat = 0.015

class TTDiamondView: UIView {
    
    var highlighted = false
    var northPathTop = UIBezierPath()
    var northPathBottom = UIBezierPath()
    var eastPathTop = UIBezierPath()
    var eastPathBottom = UIBezierPath()
    var westPathTop = UIBezierPath()
    var westPathBottom = UIBezierPath()
    var southPathTop = UIBezierPath()
    var southPathBottom = UIBezierPath()
    
    var diamondType: TTDiamondType = .DIAMOND_TYPE_MODE
    var size: CGFloat = 144
    var overrideSelectedDirection: TTModeDirection = .NO_DIRECTION
    var overrideActiveDirection: TTModeDirection = .NO_DIRECTION
    var ignoreSelectedMode = false
    var ignoreActiveMode = false
    var showOutline = false
    var connected = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            self.setNeedsDisplay()
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
        let spacing: CGFloat = SPACING_PCT * width
        
//        northPathTop = UIBezierPath()
//        northPathBottom = UIBezierPath()
        northPathTop.lineJoinStyle = CGLineJoin.Miter
        northPathBottom.lineJoinStyle = CGLineJoin.Miter
        northPathTop.moveToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 3 / 4 + spacing))
        northPathTop.addLineToPoint(CGPointMake(width / 2, height))
        northPathTop.addLineToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 3 / 4 + spacing))
        northPathBottom.moveToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 3 / 4 + spacing))
        northPathBottom.addLineToPoint(CGPointMake(width / 2, height / 2 + spacing * 2))
        northPathBottom.addLineToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 3 / 4 + spacing))
        
//        eastPathTop = UIBezierPath()
//        eastPathBottom = uiBezierPath()
        eastPathTop.lineJoinStyle = CGLineJoin.Miter
        eastPathBottom.lineJoinStyle = CGLineJoin.Miter
        eastPathTop.moveToPoint(CGPointMake(width * 1 / 2 + 1.3 * spacing * 2, height * 1 / 2))
        eastPathTop.addLineToPoint(CGPointMake(width * 3 / 4 + 1.3 * spacing, height * 3 / 4 - spacing))
        eastPathTop.addLineToPoint(CGPointMake(width, height * 1 / 2))
        eastPathBottom.moveToPoint(CGPointMake(width, height * 1 / 2))
        eastPathBottom.addLineToPoint(CGPointMake(width * 3 / 4 + 1.3 * spacing, height * 1 / 4 + spacing))
        eastPathBottom.addLineToPoint(CGPointMake(width * 1 / 2 + 1.3 * spacing * 2, height * 1 / 2))
        
//        westPathTop = UIBezierPath()
//        westPathBottom = UIBezierPath()
        westPathTop.lineJoinStyle = CGLineJoin.Miter
        westPathBottom.lineJoinStyle = CGLineJoin.Miter
        westPathTop.moveToPoint(CGPointMake(width * 1 / 2 - 1.3 * spacing * 2, height * 1 / 2))
        westPathTop.addLineToPoint(CGPointMake(width * 1 / 4 - 1.3 * spacing, height * 3 / 4 - spacing))
        westPathTop.addLineToPoint(CGPointMake(0, height * 1 / 2))
        westPathBottom.moveToPoint(CGPointMake(0, height * 1 / 2))
        westPathBottom.addLineToPoint(CGPointMake(width * 1 / 4 - 1.3 * spacing, height * 1 / 4 + spacing))
        westPathBottom.addLineToPoint(CGPointMake(width * 1 / 2 - 1.3 * spacing * 2, height * 1 / 2))
        
//        southPathTop = UIBezierPath()
//        southPathBottom = UIBezierPath()
        southPathTop.lineJoinStyle = CGLineJoin.Miter
        southPathBottom.lineJoinStyle = CGLineJoin.Miter
        southPathTop.moveToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 1 / 4 - spacing))
        southPathTop.addLineToPoint(CGPointMake(width * 1 / 2, height * 1 / 2 - spacing * 2))
        southPathTop.addLineToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 1 / 4 - spacing))
        southPathBottom.moveToPoint(CGPointMake(width * 1 / 4 + 1.3 * spacing, height * 1 / 4 - spacing))
        southPathBottom.addLineToPoint(CGPointMake(width * 1 / 2, 0))
        southPathBottom.addLineToPoint(CGPointMake(width * 3 / 4 - 1.3 * spacing, height * 1 / 4 - spacing))
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
            let isSelectedDirection: Bool = selectedModeDirection == direction
            let isActiveDirection: Bool = activeModeDirection == direction
            if diamondType != .DIAMOND_TYPE_INTERACTIVE {
                isInspectingDirection = false
            }
//            if diamondType == .DIAMOND_TYPE_PAIRING {
//                isSelectedDirection = appD.bluetoothMonitor.buttonTimer.isDirectionPaired(direction)
//            }
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
            
            if path == northPathTop {
                path.appendPath(northPathBottom)
            }
            if path == eastPathTop {
                path.appendPath(eastPathBottom)
            }
            if path == westPathTop {
                path.appendPath(westPathBottom)
            }
            if path == southPathTop {
                path.appendPath(southPathBottom)
            }
            if !showOutline {
                modeColor!.setFill()
                if !bottomHalf {
                    path.fill()
                }
            } else {
                path.lineWidth = isInspectingDirection ? 3.0 : 1.0
                modeColor!.setStroke()
                path.stroke()
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
                    path.fill()
                }
            }
        }

    }
    
}
