//
//  TTDiamondView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTDiamondType: Int {
    case interactive
    case mode
    case hud
    case pairing
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
    
    var diamondType: TTDiamondType = .mode
    var overrideSelectedDirection: TTModeDirection = .no_DIRECTION
    var overrideActiveDirection: TTModeDirection = .no_DIRECTION
    @IBInspectable var ignoreSelectedMode: Bool = false
    var ignoreActiveMode = false
    var showOutline = false
    var connected = false
    
    @IBInspectable var diamondTypeAdapter: Int {
        get {
            return self.diamondType.rawValue
        }
        set (diamondTypeIndex) {
            self.diamondType = TTDiamondType(rawValue: diamondTypeIndex) ?? .hud
        }
    }
    @IBInspectable var overrideSelectedDirectionAdapter: Int {
        get {
            return self.overrideSelectedDirection.rawValue
        }
        set (index) {
            self.overrideSelectedDirection = TTModeDirection(rawValue: index) ?? .no_DIRECTION
        }
    }
    
    override func awakeFromNib() {
        self.registerAsObserver()
        
        self.contentMode = .redraw
    }
    
    init(frame: CGRect, diamondType: TTDiamondType) {
        self.diamondType = diamondType
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        
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
//         Throws an exception for "message sent to deallocated instance"
//        if diamondType == .DIAMOND_TYPE_PAIRING {
//            appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "pairedDevicesCount", options: [], context: nil)
//            appDelegate().bluetoothMonitor.buttonTimer.addObserver(self, forKeyPath: "pairingActivatedCount", options: [], context: nil)
//        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "activeModeDirection")
//         Throws an exception for "message sent to deallocated instance"
//        if diamondType == .DIAMOND_TYPE_PAIRING {
//            appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "pairedDevicesCount")
//            appDelegate().bluetoothMonitor.buttonTimer.removeObserver(self, forKeyPath: "pairingActivatedCount")
//        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "inspectingModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "activeModeDirection" {
            if diamondType == .pairing {
                DispatchQueue.main.async(execute: { 
                    self.setNeedsDisplay()
                })
            } else {
                self.setNeedsDisplay()
            }
        } else if keyPath == "pairedDevicesCount" {
            self.setNeedsDisplay()
        } else if keyPath == "pairingActivatedCount" {
            self.setNeedsDisplay()
        }

    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.drawPaths()
        self.colorPaths()
    }
    
    func drawPaths() {
        let width: CGFloat = self.bounds.width
        let height: CGFloat = self.bounds.height
        let spacing: CGFloat = SPACING_PCT * height
        northPathTop = UIBezierPath()
        northPathBottom = UIBezierPath()
        eastPathTop = UIBezierPath()
        eastPathBottom = UIBezierPath()
        westPathTop = UIBezierPath()
        westPathBottom = UIBezierPath()
        southPathTop = UIBezierPath()
        southPathBottom = UIBezierPath()
        
        northPathTop.lineJoinStyle = CGLineJoin.miter
        northPathBottom.lineJoinStyle = CGLineJoin.miter
        northPathBottom.move(to: CGPoint(x: width * 3 / 4 - 1.3 * spacing, y: height * 1 / 4 - spacing))
        northPathBottom.addLine(to: CGPoint(x: width * 1 / 2, y: height * 1 / 2 - spacing * 2))
        northPathBottom.addLine(to: CGPoint(x: width * 1 / 4 + 1.3 * spacing, y: height * 1 / 4 - spacing))
        northPathTop.move(to: CGPoint(x: width * 1 / 4 + 1.3 * spacing, y: height * 1 / 4 - spacing))
        northPathTop.addLine(to: CGPoint(x: width * 1 / 2, y: 0))
        northPathTop.addLine(to: CGPoint(x: width * 3 / 4 - 1.3 * spacing, y: height * 1 / 4 - spacing))

        eastPathTop.lineJoinStyle = CGLineJoin.miter
        eastPathBottom.lineJoinStyle = CGLineJoin.miter
        eastPathBottom.move(to: CGPoint(x: width * 1 / 2 + 1.3 * spacing * 2, y: height * 1 / 2))
        eastPathBottom.addLine(to: CGPoint(x: width * 3 / 4 + 1.3 * spacing, y: height * 3 / 4 - spacing))
        eastPathBottom.addLine(to: CGPoint(x: width, y: height * 1 / 2))
        eastPathTop.move(to: CGPoint(x: width, y: height * 1 / 2))
        eastPathTop.addLine(to: CGPoint(x: width * 3 / 4 + 1.3 * spacing, y: height * 1 / 4 + spacing))
        eastPathTop.addLine(to: CGPoint(x: width * 1 / 2 + 1.3 * spacing * 2, y: height * 1 / 2))
        
        westPathTop.lineJoinStyle = CGLineJoin.miter
        westPathBottom.lineJoinStyle = CGLineJoin.miter
        westPathBottom.move(to: CGPoint(x: width * 1 / 2 - 1.3 * spacing * 2, y: height * 1 / 2))
        westPathBottom.addLine(to: CGPoint(x: width * 1 / 4 - 1.3 * spacing, y: height * 3 / 4 - spacing))
        westPathBottom.addLine(to: CGPoint(x: 0, y: height * 1 / 2))
        westPathTop.move(to: CGPoint(x: 0, y: height * 1 / 2))
        westPathTop.addLine(to: CGPoint(x: width * 1 / 4 - 1.3 * spacing, y: height * 1 / 4 + spacing))
        westPathTop.addLine(to: CGPoint(x: width * 1 / 2 - 1.3 * spacing * 2, y: height * 1 / 2))
        
        southPathTop.lineJoinStyle = CGLineJoin.miter
        southPathBottom.lineJoinStyle = CGLineJoin.miter
        southPathBottom.move(to: CGPoint(x: width * 1 / 4 + 1.3 * spacing, y: height * 3 / 4 + spacing))
        southPathBottom.addLine(to: CGPoint(x: width / 2, y: height))
        southPathBottom.addLine(to: CGPoint(x: width * 3 / 4 - 1.3 * spacing, y: height * 3 / 4 + spacing))
        southPathTop.move(to: CGPoint(x: width * 3 / 4 - 1.3 * spacing, y: height * 3 / 4 + spacing))
        southPathTop.addLine(to: CGPoint(x: width / 2, y: height / 2 + spacing * 2))
        southPathTop.addLine(to: CGPoint(x: width * 1 / 4 + 1.3 * spacing, y: height * 3 / 4 + spacing))
    }
    
    func colorPaths() {
        let appD = appDelegate()
        let activeModeDirection: TTModeDirection = (ignoreActiveMode || diamondType == .interactive) ? overrideActiveDirection : appD.modeMap.activeModeDirection
        let selectedModeDirection: TTModeDirection = ignoreSelectedMode ? overrideSelectedDirection : appD.modeMap.selectedModeDirection
        let inspectingModeDirection: TTModeDirection = appD.modeMap.inspectingModeDirection
        let hoverModeDirection: TTModeDirection = appD.modeMap.hoverModeDirection
        for path: UIBezierPath in [northPathTop, northPathBottom, eastPathTop, eastPathBottom, westPathTop, westPathBottom, southPathTop, southPathBottom] {
            var direction: TTModeDirection = .no_DIRECTION
            let bottomHalf: Bool = [northPathBottom, eastPathBottom, westPathBottom, southPathBottom].contains(path)
            if path.isEqual(northPathTop) || path.isEqual(northPathBottom) {
                direction = .north
            }
            else if path.isEqual(eastPathTop) || path.isEqual(eastPathBottom) {
                direction = .east
            }
            else if path.isEqual(westPathTop) || path.isEqual(westPathBottom) {
                direction = .west
            }
            else if path.isEqual(southPathTop) || path.isEqual(southPathBottom) {
                direction = .south
            }
            
            let isHoveringDirection: Bool = hoverModeDirection == direction
            var isInspectingDirection: Bool = inspectingModeDirection == direction
            var isSelectedDirection: Bool = selectedModeDirection == direction
            let isActiveDirection: Bool = activeModeDirection == direction
            if diamondType != .interactive {
                isInspectingDirection = false
            }
            if diamondType == .pairing {
                isSelectedDirection = appD.bluetoothMonitor.buttonTimer.isDirectionPaired(direction)
            }
            // Fill in the color as a stroke or fill
            var modeColor: UIColor?
            if diamondType == .hud {
                let alpha: Double = 0.5
                modeColor = UIColor(hex: 0xFFFFFF, alpha: alpha)
            }
            else if diamondType == .interactive {
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
            else if diamondType == .mode || diamondType == .pairing {
                if isActiveDirection {
                    let alpha: Double = 0.5
                    modeColor = UIColor(hex: 0x303033, alpha: alpha)
                }
                else if isSelectedDirection {
                    if diamondType == .pairing || appD.modeMap.selectedModeDirection == direction {
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
            combinedPath.append(path)
            if path == northPathTop {
                combinedPath.append(northPathBottom)
            }
            if path == eastPathTop {
                combinedPath.append(eastPathBottom)
            }
            if path == westPathTop {
                combinedPath.append(westPathBottom)
            }
            if path == southPathTop {
                combinedPath.append(southPathBottom)
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
            
            if diamondType == .interactive {
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact {
            self.setNeedsDisplay()
        } else {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Events

    
    // NOTE: None of these work for some reason. The tap area is tiny and in the center of the diamond.
    //       You can find this functionality in TTActionDiamondView.
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if diamondType != .interactive {
            return
        }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            if northPathTop.contains(location) || northPathBottom.contains(location) {
                overrideActiveDirection = .north
            } else if eastPathTop.contains(location) || eastPathBottom.contains(location) {
                overrideActiveDirection = .east
            } else if westPathTop.contains(location) || westPathBottom.contains(location) {
                overrideActiveDirection = .west
            } else if southPathTop.contains(location) || southPathBottom.contains(location) {
                overrideActiveDirection = .south
            }
        }
        
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if diamondType != .interactive {
            return
        }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            if northPathTop.contains(location) || northPathBottom.contains(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.north)
            } else if eastPathTop.contains(location) || eastPathBottom.contains(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.east)
            } else if westPathTop.contains(location) || westPathBottom.contains(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.west)
            } else if southPathTop.contains(location) || southPathBottom.contains(location) {
                appDelegate().modeMap.toggleInspectingModeDirection(.south)
            }
            overrideActiveDirection = .no_DIRECTION
        }
        
        self.setNeedsDisplay()
    }
    
}
