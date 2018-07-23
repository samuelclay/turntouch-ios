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
    var menuType = TTMenuType.menu_MODE
    var modeName = ""
    var modeClass: TTMode.Type!
    var actionName = ""
    var activeMode: TTMode!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal,
            toItem: self, attribute: .leading, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal,
            toItem: self, attribute: .height, multiplier: 0.5, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
            toItem: self, attribute: .height, multiplier: 0.5, constant: 0))
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x808388)
        titleLabel.shadowOffset = CGSize(width: 0, height: 0.5)
        titleLabel.shadowColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal,
            toItem: imageView, attribute: .trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            activeMode = nil
            self.setNeedsDisplay()
        } else if keyPath == "inspectingModeDirection" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
    }
    
    // MARK: Drawing
    
    override func prepareForReuse() {
        if menuType == .menu_MODE || menuType == .menu_ADD_MODE {
            let className = "Turn_Touch_iOS.\(modeName)"
            modeClass = NSClassFromString(className) as! TTMode.Type
        } else if menuType == .menu_ACTION {
            activeMode = appDelegate().modeMap.selectedMode
        } else if menuType == .menu_ADD_ACTION {
            activeMode = appDelegate().modeMap.tempMode
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if activeMode == nil {
            self.prepareForReuse()
        }
        
        if menuType == .menu_MODE || menuType == .menu_ADD_MODE {
            if menuType == .menu_MODE {
                isSelected = modeClass == type(of: appDelegate().modeMap.selectedMode)
            }
            titleLabel.text = modeClass.title().uppercased()
            let imageName = modeClass.imageName()
            if imageName != "" {
                imageView.image = UIImage(named:imageName)
            }
        } else if menuType == .menu_ACTION || menuType == .menu_ADD_ACTION {
            if activeMode == nil {
                return
            }
            if menuType == .menu_ACTION {
                isSelected = activeMode.actionNameInDirection(appDelegate().modeMap.inspectingModeDirection) == modeName
            }
            let imageName = activeMode.imageNameForAction(modeName)
            if imageName != nil {
                imageView.image = UIImage(named:imageName!)
            }
            titleLabel.text = activeMode.titleForAction(modeName, buttonMoment: .button_MOMENT_PRESSUP).uppercased()
        }

        titleLabel.textColor = isHighlighted || isSelected ? UIColor(hex: 0x404A60) : UIColor(hex: 0x808388)
        self.drawBackground()
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        if isSelected {
            UIColor(hex: 0xE3EDF6).set()
        } else if isHighlighted {
            UIColor(hex: 0xF6F6F9).set()
        } else {
            UIColor(hex: 0xFBFBFD).set()
        }
        context?.fill(self.bounds);
    }
    
    // MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            isHighlighted = false
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
        let selectedMode = appDelegate().modeMap.selectedMode.nameOfClass
        
        if let touch = touches.first {
            if self.bounds.contains(touch.location(in: self)) {
                if menuType == .menu_MODE {
                    appDelegate().modeMap.changeDirection(appDelegate().modeMap.selectedModeDirection, toMode:modeName)
                    
                    appDelegate().modeMap.recordUsage(additionalParams: ["moment": "change:mode:\(selectedMode)"])
                } else if menuType == .menu_ACTION {
                    appDelegate().modeMap.changeDirection(appDelegate().modeMap.inspectingModeDirection, toAction:modeName)
                    // Update the action diamond
                    appDelegate().modeMap.selectedModeDirection = appDelegate().modeMap.selectedModeDirection
                    // Update the mode menu
                    appDelegate().modeMap.inspectingModeDirection = appDelegate().modeMap.inspectingModeDirection
                    
                    let actionName = appDelegate().modeMap.selectedMode.actionNameInDirection(appDelegate().modeMap.inspectingModeDirection)
                    appDelegate().modeMap.recordUsage(additionalParams: ["moment": "change:action:\(selectedMode):\(actionName)"])
                } else if menuType == .menu_ADD_MODE {
                    appDelegate().modeMap.provisionTempMode(name: modeName)
                    appDelegate().mainViewController.scrollToBottom()
                    
                    appDelegate().modeMap.recordUsage(additionalParams: ["moment": "change:add-batch-mode:\(selectedMode)"])
                } else if menuType == .menu_ADD_ACTION {
                    appDelegate().modeMap.addBatchAction(for: modeName)
                    appDelegate().mainViewController.addActionButtonView.hideAddActionMenu(nil)
                    appDelegate().mainViewController.scrollToBottom()
                }
            }
        }
        self.setNeedsDisplay()
    }
}
