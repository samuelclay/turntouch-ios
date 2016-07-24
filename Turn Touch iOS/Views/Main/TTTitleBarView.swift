//
//  TTTitleBarView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

let CORNER_RADIUS: CGFloat = 8.0
let SETTINGS_ICON_SIZE: CGFloat = 22.0

class TTTitleBarView: UIView, TTTitleMenuDelegate {
    @IBInspectable var startColor: UIColor = UIColor.whiteColor()
    @IBInspectable var endColor: UIColor = UIColor(hex: 0xE7E7E7)

    let titleImageView: UIImageView = UIImageView()
    let settingsButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .Redraw
        
        titleImageView.image = UIImage(named: "title")
        titleImageView.contentMode = .ScaleAspectFit
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleImageView)
        
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        let settingsImage = UIImage(named: "settings")
        settingsButton.setImage(settingsImage, forState: UIControlState.Normal)
        settingsButton.imageEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(self.pressSettings(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(settingsButton)
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE+20))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE+40))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.Right, relatedBy: .Equal,
            toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.drawBackground()
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
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
    
    // MARK: Events
    
    func pressSettings(sender: UIButton!) {
        appDelegate().mainViewController.toggleTitleMenu(sender)
    }
    
    // MARK: Menu Delegate
    
    func menuOptions() -> [[String : String]] {
        return [
            ["title": "Add a new remote"],
            ["title": "Settings"],
            ["title": "How it works"],
            ["title": "Contact support"],
            ["title": "About Turn Touch"],
        ]
    }
    
    func selectMenuOption(row: Int) {
        switch row {
        case 0:
            appDelegate().mainViewController.showPairingModal()
        case 2:
            appDelegate().mainViewController.showFtuxModal()
        default:
            break
        }
    }
}
