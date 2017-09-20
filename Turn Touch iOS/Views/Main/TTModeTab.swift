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

    @IBInspectable var startColor: UIColor = UIColor.white
    @IBInspectable var endColor: UIColor = UIColor(hex: 0xE7E7E7)
    
    var mode: TTMode = TTMode()
    var modeDirection: TTModeDirection = .no_DIRECTION
    var modeTitle: String = ""
    var highlighted: Bool = false
    var titleLabel: UILabel = UILabel()
    var diamondView = TTDiamondView(frame: CGRect.zero, diamondType: .mode)
    
    init(modeDirection: TTModeDirection) {
        self.modeDirection = modeDirection
        let font = UIFont(name: "Effra", size: 13)
        self.titleLabel.font = font
        self.titleLabel.shadowOffset = CGSize(width: 0, height: 0.5)
        self.titleLabel.shadowColor = UIColor.white
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame:CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIViewContentMode.redraw;
        
        self.addSubview(self.titleLabel)
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal,
            toItem: self, attribute: .bottom, multiplier: 1.0, constant: -12))

        diamondView.overrideSelectedDirection = self.modeDirection
        diamondView.ignoreSelectedMode = true
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: -DIAMOND_SIZE/2))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: DIAMOND_SIZE*1.3))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: DIAMOND_SIZE))
        
        self.setupMode()
        self.registerAsObserver()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                               action: #selector(self.longPressed))
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupMode() {
        switch modeDirection {
        case .north:
            self.mode = appDelegate().modeMap.northMode
        case .east:
            self.mode = appDelegate().modeMap.eastMode
        case .west:
            self.mode = appDelegate().modeMap.westMode
        case .south:
            self.mode = appDelegate().modeMap.southMode
        default:
            break
        }
        
        self.modeTitle = type(of: self.mode).title()
    }
    
    override class var requiresConstraintBasedLayout : Bool {
        return true
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: .initial, context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "activeModeDirection", options: .initial, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            self.setupMode()
        }
        if keyPath == "activeModeDirection" || keyPath == "selectedModeDirection" {
            if appDelegate().modeMap.selectedModeDirection == modeDirection {
                diamondView.ignoreSelectedMode = false
                diamondView.ignoreActiveMode = false
            } else {
                diamondView.ignoreSelectedMode = true
                diamondView.ignoreActiveMode = true
            }
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "activeModeDirection")
    }
    
    // MARK: Drawing

    override func draw(_ rect: CGRect) {
        super.draw(rect);
        
        self.drawBackground()
        self.drawBorders()
        
        let textColor = (appDelegate().modeMap.selectedModeDirection != self.modeDirection && !self.highlighted) ?
            UIColor(hex: 0x808388) : UIColor(hex: 0x404A60)
        self.titleLabel.textColor = textColor
        self.titleLabel.text = self.modeTitle.uppercased()
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        if appDelegate().modeMap.selectedModeDirection == self.modeDirection {
            UIColor(hex: 0xFFFFFF).set()
            context?.fill(self.bounds);
        } else {
            let colors = [startColor.cgColor, endColor.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations:[CGFloat] = [0.0, 1.0]
            let gradient = CGGradient(colorsSpace: colorSpace,
                                                      colors: colors as CFArray,
                                                      locations: colorLocations)
            let startPoint = CGPoint.zero
            let endPoint = CGPoint(x:0, y:self.bounds.height)

            context?.drawLinearGradient(gradient!, 
                                        start: startPoint, 
                                        end: endPoint,
                                        options: [])
            if self.highlighted {
                context?.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.025);
                context?.fill(self.bounds)
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
        if self.modeDirection != .north {
            line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
            line.addLine(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
            line.stroke()
        }
        
        // Right border
        if self.modeDirection != .south {
            line.move(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
            line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
            line.stroke()
        }
        
        // Top border
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        line.stroke()
    }
    
    func drawInactiveBorder() {
        let line = UIBezierPath()
        let activeDirection = appDelegate().modeMap.selectedModeDirection
        line.lineWidth = 1.0
        UIColor(hex: 0xC2CBCE).set()
        
        // Right border
        if (self.modeDirection == .north && activeDirection == .east) ||
            (self.modeDirection == .east && activeDirection == .west) ||
            (self.modeDirection == .west && activeDirection == .south) ||
            (self.modeDirection == .south) {
            
        } else {
            line.move(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY + 24))
            line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY - 24))
            line.stroke()
        }
        
        // Bottom border
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        line.stroke()
        
        // Top border
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        line.stroke()
    }
    
    // MARK: Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.highlighted = true
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            self.highlighted = self.bounds.contains(touch.location(in: self))
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.highlighted = false
        self.setNeedsDisplay()
        super.touchesEnded(touches, with: event)

        if let touch = touches.first {
            if self.bounds.contains(touch.location(in: self)) {
                self.switchMode()
            }
        }
    }
    
    func switchMode() {
        appDelegate().modeMap.switchMode(self.modeDirection, modeChangeType: .modeTab)
        
        let selectedMode = appDelegate().modeMap.selectedMode.nameOfClass
        appDelegate().modeMap.recordUsage(additionalParams: ["moment": "tap:mode-tab:\(selectedMode)"])
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            if appDelegate().modeMap.selectedModeDirection != self.modeDirection {
                appDelegate().modeMap.switchMode(self.modeDirection, modeChangeType: .modeTab)
            }
            appDelegate().mainViewController.modeTitleView.pressChange(nil)

            let selectedMode = appDelegate().modeMap.selectedMode.nameOfClass
            appDelegate().modeMap.recordUsage(additionalParams: ["moment": "long-press:mode-tab:\(selectedMode)"])
        }
    }
}
