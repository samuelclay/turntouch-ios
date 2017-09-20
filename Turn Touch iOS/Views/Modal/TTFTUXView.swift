//
//  TTFTUXView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/13/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTFTUXView: UIView {
    
    var ftuxPage: TTFTUXPage
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var imageView = UIImageView()
    
    init(ftuxPage: TTFTUXPage) {
        self.ftuxPage = ftuxPage
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let spacerTop = UIView()
        spacerTop.isHidden = true
        spacerTop.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spacerTop)
        self.addConstraint(NSLayoutConstraint(item: spacerTop, attribute: .centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: spacerTop, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1.0, constant: 36))
        self.addConstraint(NSLayoutConstraint(item: spacerTop, attribute: .width, relatedBy: .equal,
            toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal,
            toItem: spacerTop, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal,
            toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        
        let spacerBottom = UIView()
        spacerBottom.isHidden = true
        spacerBottom.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spacerBottom)
        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .top, relatedBy: .equal,
                                              toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: 36))
        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .width, relatedBy: .equal,
                                              toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .centerX, relatedBy: .equal,
                                              toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .height, relatedBy: .equal,
//            toItem: spacerBottom, attribute: .height, multiplier: 1.0, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .height, relatedBy: .equal,
//            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48))

        titleLabel.font = UIFont(name: "Effra", size: 22)
        titleLabel.textColor = UIColor(hex: 0x7A797A)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
            toItem: spacerBottom, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal,
                                              toItem: self, attribute: .width, multiplier: 0.8, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal,
//            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48))
        
        subtitleLabel.font = UIFont(name: "Effra", size: 16)
        subtitleLabel.textColor = UIColor(hex: 0xB5BCC0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 3
        self.addSubview(subtitleLabel)
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal,
            toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .centerX, relatedBy: .equal,
            toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .width, relatedBy: .equal,
            toItem: self, attribute: .width, multiplier: 0.75, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .height, relatedBy: .equal,
//            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48))
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .bottom, relatedBy: .equal,
            toItem: self, attribute: .bottom, multiplier: 1.0, constant: -24))
        
        subtitleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: UILayoutPriority.RawValue(Int(UILayoutPriority.defaultHigh.rawValue)+1)), for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: UILayoutPriority.RawValue(Int(UILayoutPriority.defaultHigh.rawValue)+1)), for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        
        self.assemble()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assemble() {
        switch ftuxPage {
        case .intro:
            imageView.image = UIImage(named: "modal_ftux_action")
            titleLabel.text = "Here's how it works"
            subtitleLabel.text = "Your remote has four buttons"
        case .actions:
            imageView.image = UIImage(named: "modal_ftux_doubletap")
            titleLabel.text = "Each button performs an action"
            subtitleLabel.text = "Like changing the lights, playing music, or turning up the volume"
        case .modes:
            imageView.image = UIImage(named: "modal_ftux_mode")
            titleLabel.text = "Press and hold to change apps"
            subtitleLabel.text = "Four apps × four buttons per app\n= sixteen different actions"
        case .batchActions:
            imageView.image = UIImage(named: "modal_ftux_change_action")
            titleLabel.text = "Each button can do multiple actions"
            subtitleLabel.text = "There are batch actions and double-tap actions, all configurable in this app"
        case .hud:
            imageView.image = UIImage(named: "modal_ftux_change_mode")
            titleLabel.text = "Press all four buttons for the HUD"
            subtitleLabel.text = "The Heads-Up Display (HUD) shows what each button does and gives you access to even more actions and apps"
        }
    }
}
