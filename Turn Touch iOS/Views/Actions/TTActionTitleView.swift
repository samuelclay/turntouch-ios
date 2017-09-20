//
//  TTActionTitleView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTActionTitleView: UIView {
    
    @IBOutlet var changeButton: UIButton! = UIButton(type: UIButtonType.system)
    var modeImage: UIImage = UIImage()
    var modeTitle: String = ""
    var titleLabel: UILabel = UILabel()
    var diamondView: TTDiamondView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
//        self.contentMode = UIViewContentMode.Redraw;
        
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setTitle("Change", for: UIControlState())
        changeButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        changeButton.titleLabel!.textColor = UIColor(hex: 0xA0A0A0)
        changeButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        changeButton.addTarget(self, action: #selector(self.pressChange), for: .touchUpInside)
        self.addSubview(changeButton)
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .trailing, relatedBy: .equal,
            toItem: self, attribute: .trailing, multiplier: 1.0, constant: -24))
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        diamondView = TTDiamondView(frame: CGRect.zero, diamondType: .mode)
        diamondView.ignoreSelectedMode = true
        diamondView.ignoreActiveMode = true
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .leading, relatedBy: .equal,
            toItem: self, attribute: .leading, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.3*24))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24))
        
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal,
            toItem: diamondView, attribute: .trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "inspectingModeDirection" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        if appDelegate().modeMap.openedActionChangeMenu {
            changeButton.setTitle("Done", for: UIControlState())
        } else {
            changeButton.setTitle("Change", for: UIControlState())
        }
        
        let direction = appDelegate().modeMap.inspectingModeDirection
        if direction != .no_DIRECTION {
            titleLabel.text = appDelegate().modeMap.selectedMode.titleInDirection(direction, buttonMoment: .button_MOMENT_PRESSUP)
        }
        diamondView.overrideActiveDirection = appDelegate().modeMap.inspectingModeDirection
        diamondView.setNeedsDisplay()
        
        super.draw(rect)
        self.drawBackground()
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        UIColor(hex: 0xFFFFFF).set()
        context?.fill(self.bounds);
    }
    
    // MARK: Actions
    
    @objc func pressChange(_ sender: UIButton!) {
        appDelegate().modeMap.openedActionChangeMenu = !appDelegate().modeMap.openedActionChangeMenu
        self.setNeedsDisplay()
    }

}
