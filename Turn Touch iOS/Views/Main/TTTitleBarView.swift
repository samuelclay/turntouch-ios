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
    var menuHeight: Int = 42
    
    @IBInspectable var startColor: UIColor = UIColor.white
    @IBInspectable var endColor: UIColor = UIColor(hex: 0xE7E7E7)

    let titleImageView = UIImageView()
    
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
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        let settingsImage = UIImage(named: "settings")
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(settingsImage, for: UIControl.State())
        settingsButton.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(self.pressSettings(_:)), for: .touchUpInside)
        self.addSubview(settingsButton)
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE+20))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: SETTINGS_ICON_SIZE+40))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: .trailingMargin, relatedBy: .equal,
            toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: settingsButton, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: .equal,
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
            ["title": "Switch button mode",
             "image": "switch_mode"],
            ["title": "Setup geofence",
             "image": "geofence"],
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
            appDelegate().mainViewController.showSwitchButtonModeModal()
        case 3:
            appDelegate().mainViewController.showGeofencingModal()
        case 4:
            appDelegate().mainViewController.showFtuxModal()
        case 5:
            appDelegate().mainViewController.showSupportModal()
        case 6:
            appDelegate().mainViewController.showAboutModal()
        default:
            break
        }
    }
}
