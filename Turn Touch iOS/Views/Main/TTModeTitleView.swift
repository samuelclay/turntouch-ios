//
//  TTModeTitleView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeTitleView: UIView {

    @IBOutlet var changeButton = UIButton(type: UIButtonType.System) as UIButton!
    var modeImage: UIImage = UIImage()
    var modeTitle: String = ""
    var titleLabel: UILabel = UILabel()
    var modeImageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = UIViewContentMode.Redraw;
        self.backgroundColor = UIColor.clearColor()
        
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
        
        modeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(modeImageView)
        self.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .Leading, relatedBy: .Equal,
            toItem: self, attribute: .Leading, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        modeImageView.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32))
        modeImageView.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32))
        
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal,
            toItem: modeImageView, attribute: .Trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal,
            toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "openedModeChangeMenu" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        if appDelegate().modeMap.openedModeChangeMenu {
            changeButton.setTitle("Done", forState: .Normal)
        } else {
            changeButton.setTitle("Change", forState: .Normal)
        }
        
        titleLabel.text = appDelegate().modeMap.selectedMode.subtitle()
        modeImageView.image = UIImage(named:appDelegate().modeMap.selectedMode.imageName())
        
        super.drawRect(rect)
    }
    
    // MARK: Actions
    
    func pressChange(sender: UIButton!) {
        appDelegate().modeMap.openedModeChangeMenu = !appDelegate().modeMap.openedModeChangeMenu
        appDelegate().modeMap.inspectingModeDirection = .NO_DIRECTION
        self.setNeedsDisplay()
    }

}
