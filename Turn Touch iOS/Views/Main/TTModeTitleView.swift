//
//  TTModeTitleView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeTitleView: UIView {

    @IBOutlet var changeButton: UIButton! = UIButton(type: UIButton.ButtonType.system)
    var modeImage: UIImage = UIImage()
    var modeTitle: String = ""
    var titleLabel: UILabel = UILabel()
    var modeImageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIView.ContentMode.redraw;
        self.backgroundColor = UIColor.clear
        
        guard let changeButton = changeButton else {
            return
        }
        
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setTitle("Change", for: UIControl.State.normal)
        changeButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        changeButton.titleLabel!.textColor = UIColor(hex: 0xA0A0A0)
        changeButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        changeButton.addTarget(self, action: #selector(self.pressChange), for: .touchUpInside)
        self.addSubview(changeButton)
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .trailingMargin, relatedBy: .equal,
                                              toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: -24))
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        modeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(modeImageView)
        self.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .leadingMargin, relatedBy: .equal,
                                              toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        modeImageView.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32))
        modeImageView.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 32))
        
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal,
            toItem: modeImageView, attribute: .trailing, multiplier: 1.0, constant: 12))
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
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "openedModeChangeMenu" {
            self.setNeedsDisplay()
        } else if keyPath == "inspectingModeDirection" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        if appDelegate().modeMap.openedModeChangeMenu {
            changeButton.setTitle("Done", for: .normal)
        } else {
            changeButton.setTitle("Change", for: .normal)
        }
        
        if appDelegate().modeMap.buttonAppMode() == .SixteenButtons {
            titleLabel.text = type(of: appDelegate().modeMap.selectedMode).subtitle()
            modeImageView.image = UIImage(named:type(of: appDelegate().modeMap.selectedMode).imageName())
        } else {
            let inspectingModeDirection = appDelegate().modeMap.inspectingModeDirection
            titleLabel.text = type(of: appDelegate().modeMap.modeInDirection(inspectingModeDirection)).title()
            modeImageView.image = UIImage(named:type(of: appDelegate().modeMap.modeInDirection(inspectingModeDirection)).imageName())
        }
        
        super.draw(rect)
    }
    
    // MARK: Actions
    
    @objc func pressChange(_ sender: UIButton!) {
        appDelegate().modeMap.openedModeChangeMenu = !appDelegate().modeMap.openedModeChangeMenu
        if appDelegate().modeMap.openedActionChangeMenu {
            appDelegate().modeMap.openedActionChangeMenu = false
        }
        if appDelegate().modeMap.openedAddActionChangeMenu {
            appDelegate().modeMap.openedAddActionChangeMenu = false
        }
        if appDelegate().modeMap.buttonAppMode() == .SixteenButtons {
            appDelegate().modeMap.inspectingModeDirection = .no_DIRECTION
        }

        self.setNeedsDisplay()
    }

}
