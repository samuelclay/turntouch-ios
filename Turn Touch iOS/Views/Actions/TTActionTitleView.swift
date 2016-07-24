//
//  TTActionTitleView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTActionTitleView: UIView {
    
    @IBOutlet var changeButton = UIButton(type: UIButtonType.System) as UIButton!
    var modeImage: UIImage = UIImage()
    var modeTitle: String = ""
    var titleLabel: UILabel = UILabel()
    var diamondView: TTDiamondView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
//        self.contentMode = UIViewContentMode.Redraw;
        
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setTitle("Change", forState: UIControlState.Normal)
        changeButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        changeButton.titleLabel!.textColor = UIColor(hex: 0xA0A0A0)
        changeButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByClipping
        changeButton.addTarget(self, action: #selector(self.pressChange), forControlEvents: .TouchUpInside)
        self.addSubview(changeButton)
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .Trailing, relatedBy: .Equal,
            toItem: self, attribute: .Trailing, multiplier: 1.0, constant: -24))
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        diamondView = TTDiamondView(frame: CGRect.zero, diamondType: .Mode)
        diamondView.ignoreSelectedMode = true
        diamondView.ignoreActiveMode = true
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Leading, relatedBy: .Equal,
            toItem: self, attribute: .Leading, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.3*24))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 24))
        
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal,
            toItem: diamondView, attribute: .Trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "inspectingModeDirection" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        if appDelegate().modeMap.openedActionChangeMenu {
            changeButton.setTitle("Done", forState: .Normal)
        } else {
            changeButton.setTitle("Change", forState: .Normal)
        }
        
        let direction = appDelegate().modeMap.inspectingModeDirection
        if direction != .NO_DIRECTION {
            titleLabel.text = appDelegate().modeMap.selectedMode.titleInDirection(direction, buttonMoment: .BUTTON_MOMENT_PRESSUP)
        }
        diamondView.overrideActiveDirection = appDelegate().modeMap.inspectingModeDirection
        diamondView.setNeedsDisplay()
        
        super.drawRect(rect)
        self.drawBackground()
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        UIColor(hex: 0xFFFFFF).set()
        CGContextFillRect(context, self.bounds);
    }
    
    // MARK: Actions
    
    func pressChange(sender: UIButton!) {
        appDelegate().modeMap.openedActionChangeMenu = !appDelegate().modeMap.openedActionChangeMenu
        self.setNeedsDisplay()
    }

}
