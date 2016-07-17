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
        spacerTop.hidden = true
        spacerTop.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spacerTop)
        self.addConstraint(NSLayoutConstraint(item: spacerTop, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: spacerTop, attribute: .Top, relatedBy: .LessThanOrEqual,
            toItem: self, attribute: .Top, multiplier: 1.0, constant: 48))
        self.addConstraint(NSLayoutConstraint(item: spacerTop, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFit
        self.addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal,
            toItem: spacerTop, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 256))
        
        let spacerBottom = UIView()
        spacerBottom.hidden = true
        spacerBottom.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spacerBottom)
        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .Top, relatedBy: .LessThanOrEqual,
            toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .Height, relatedBy: .Equal,
            toItem: spacerBottom, attribute: .Height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: spacerBottom, attribute: .Height, relatedBy: .LessThanOrEqual,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 48))

        titleLabel.font = UIFont(name: "Effra", size: 22)
        titleLabel.textColor = UIColor(hex: 0x7A797A)
        titleLabel.textAlignment = .Center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .LessThanOrEqual,
            toItem: spacerBottom, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .GreaterThanOrEqual,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        
        subtitleLabel.font = UIFont(name: "Effra", size: 16)
        subtitleLabel.textColor = UIColor(hex: 0xB5BCC0)
        subtitleLabel.textAlignment = .Center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 3
        self.addSubview(subtitleLabel)
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .Top, relatedBy: .Equal,
            toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 0.75, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .Height, relatedBy: .GreaterThanOrEqual,
//            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .Bottom, relatedBy: .GreaterThanOrEqual,
            toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -84))
        
        self.assemble()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assemble() {
        switch ftuxPage {
        case .Intro:
            imageView.image = UIImage(named: "modal_ftux_action")
            titleLabel.text = "Here's how it works"
            subtitleLabel.text = "Your remote has four buttons"
        case .Actions:
            imageView.image = UIImage(named: "modal_ftux_doubletap")
            titleLabel.text = "Each button performs an action"
            subtitleLabel.text = "Like changing the lights, playing music, or turning up the volume"
        case .Modes:
            imageView.image = UIImage(named: "modal_ftux_mode")
            titleLabel.text = "Press and hold to change apps"
            subtitleLabel.text = "Four apps × four buttons per app\n= sixteen different actions"
        case .BatchActions:
            imageView.image = UIImage(named: "modal_ftux_change_action")
            titleLabel.text = "Each button can do multiple actions"
            subtitleLabel.text = "There are batch actions and double-tap actions, all configurable in this app"
        case .HUD:
            imageView.image = UIImage(named: "modal_ftux_change_mode")
            titleLabel.text = "Press all four buttons for the HUD"
            subtitleLabel.text = "The Heads-Up Display (HUD) shows what each button does and gives you access to even more actions and apps"
        }
    }
}
