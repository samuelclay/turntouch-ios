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
    
    init(frame: CGRect, ftuxPage: TTFTUXPage) {
        super.init(frame: frame)
        
        self.ftuxPage = ftuxPage
        
        imageView.
        self.addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal,
            toItem: self, attribute: .Top, multiplier: 1.0, constant: 48))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal,
            toItem: self, attribute: .Height, multiplier: 1.0, constant: 256))
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal,
            toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))

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
