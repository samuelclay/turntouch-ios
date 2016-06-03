//
//  TTModeMenuCell.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/1/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeMenuCell: UICollectionViewCell {
    
    var titleLabel = UILabel()
    var imageView = UIImageView()
    var menuType = TTMenuType.MENU_MODE
    var modeName = ""
    var actionName = ""
    var activeMode: TTMode!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal,
            toItem: self, attribute: .Leading, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal,
            toItem: self, attribute: .Height, multiplier: 0.5, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Height, multiplier: 0.5, constant: 0))
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x808388)
        titleLabel.shadowOffset = CGSizeMake(0, 0.5)
        titleLabel.shadowColor = UIColor.whiteColor()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal,
            toItem: imageView, attribute: .Trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
    }
    
    // MARK: Drawing
    
    override func prepareForReuse() {
        let className = "Turn_Touch_iOS.\(modeName)"
        let activeModeType = NSClassFromString(className) as! TTMode.Type
        activeMode = activeModeType.init()
    }

    override func drawRect(rect: CGRect) {
        if activeMode == nil {
            self.prepareForReuse()
        }

        super.drawRect(rect)
        
        selected = activeMode >!< appDelegate().modeMap.selectedMode
        self.drawBackground()
        
        titleLabel.textColor = highlighted || selected ? UIColor(hex: 0x404A60) : UIColor(hex: 0x808388)
        titleLabel.text = activeMode.title().uppercaseString
        
        imageView.image = UIImage(named:activeMode.imageName())
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        if selected {
            UIColor(hex: 0xE3EDF6).set()
        } else if highlighted {
            UIColor(hex: 0xF6F6F9).set()
        } else {
            UIColor(hex: 0xFBFBFD).set()
        }
        CGContextFillRect(context, self.bounds);
    }
    
    // MARK: Touches
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        highlighted = true
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            highlighted = CGRectContainsPoint(self.bounds, touch.locationInView(self))
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        highlighted = false
        if let touch = touches.first {
            if CGRectContainsPoint(self.bounds, touch.locationInView(self)) {
                if menuType == .MENU_MODE {
                    appDelegate().modeMap.changeDirection(appDelegate().modeMap.selectedModeDirection, toMode:modeName)
                }
            }
        }
        self.setNeedsDisplay()
    }
}
