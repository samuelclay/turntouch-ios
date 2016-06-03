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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.drawBackground()
        
        titleLabel.text = appDelegate().modeMap.selectedMode.subtitle()
        
        imageView.image = UIImage(named:appDelegate().modeMap.selectedMode.imageName())
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        UIColor(hex: 0xFBFBFD).set()
        CGContextFillRect(context, self.bounds);
    }
}
