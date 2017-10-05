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
    @IBInspectable var startColor: UIColor = UIColor.white
    @IBInspectable var endColor: UIColor = UIColor(hex: 0xE7E7E7)

    let titleImageView: UIImageView = UIImageView()
    let settingsButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .redraw
        
        titleImageView.image = UIImage(named: "title")
        titleImageView.contentMode = .scaleAspectFit
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleImageView)
        
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: NSLayoutAttribute.centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: NSLayoutAttribute.centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        let settingsImage = UIImage(named: "settings")
        settingsButton.setImage(settingsImage, for: UIControlState())
        settingsButton.imageEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(self.pressSettings(_:)), for: .touchUpInside)
        self.addSubview(settingsButton)
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE+20))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE+40))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.right, relatedBy: .equal,
            toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutAttribute.centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.drawBackground()
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
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

    }
    
    // MARK: Events
    
    @objc func pressSettings(_ sender: UIButton!) {
        appDelegate().mainViewController.toggleTitleMenu(sender)
    }
    
    // MARK: Menu Delegate
    
    func menuOptions() -> [[String : String]] {
        return [
            ["title": "Add a new remote",
             "image": "add"],
            ["title": "Settings",
             "image": "preferences"],
            ["title": "How it works",
             "image": "how_it_works"],
            ["title": "Contact support",
             "image": "support"],
            ["title": "About Turn Touch",
             "image": "about"],
        ]
    }
    
    func selectMenuOption(_ row: Int) {
        switch row {
        case 0:
            appDelegate().mainViewController.showPairingModal()
        case 1:
            appDelegate().mainViewController.showSettingsModal()
        case 2:
            appDelegate().mainViewController.showFtuxModal()
        default:
            break
        }
    }
}
