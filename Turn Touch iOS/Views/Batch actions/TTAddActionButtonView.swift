//
//  TTAddActionButtonView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTAddActionButtonView: UIView {

    @IBOutlet var addButton: UIButton! = UIButton(type: UIButton.ButtonType.system)
    var image: UIImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIView.ContentMode.redraw;
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        
        image = UIImage(named: "button_plus")
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(image, for: .normal)
        addButton.imageView?.contentMode = .scaleAspectFit
        addButton.setTitle("Add new action", for: UIControl.State.normal)
        addButton.imageView!.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        addButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        addButton.titleLabel!.textColor = UIColor(hex: 0xA0A0A0)
        addButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -128, bottom: 0, right: -128)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -212, bottom: 0, right: 0)
        addButton.addTarget(self, action: #selector(self.showAddActionMenu(_:)), for: .touchUpInside)
        addButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        self.addSubview(addButton)
//        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .top, relatedBy: .equal,
//                                              toItem: self.layoutMarginsGuide, attribute: .top, multiplier: 1.0, constant: 24))
//        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .bottom, relatedBy: .equal,
//                                              toItem: self.layoutMarginsGuide, attribute: .bottom, multiplier: 1.0, constant: -24))
        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .centerX, relatedBy: .equal,
                                              toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24))
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "inspectingModeDirection" {
            if appDelegate().modeMap.inspectingModeDirection == .no_DIRECTION {
                self.hideAddActionMenu(nil)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let line = UIBezierPath()
        line.lineWidth = 0.5
        UIColor(hex: 0xC2CBCE).set()
                
        // Top border
        line.move(to: CGPoint(x: self.bounds.minX + 24, y: self.bounds.minY))
        line.addLine(to: CGPoint(x: self.bounds.maxX - 24, y: self.bounds.minY))
        line.stroke()

        // Bottom border
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        line.stroke()
    }
    
    @objc func showAddActionMenu(_ sender: UIButton!) {
        addButton.setTitle("Cancel", for: .normal)
        addButton.setImage(UIImage(named: "button_x"), for: .normal)
        addButton.removeTarget(self, action: #selector(self.showAddActionMenu(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(self.hideAddActionMenu(_:)), for: .touchUpInside)

        appDelegate().modeMap.openedAddActionChangeMenu = true
    }

    @objc func hideAddActionMenu(_ sender: UIButton!) {
        addButton.setTitle("Add new action", for: .normal)
        addButton.setImage(UIImage(named: "button_plus"), for: .normal)
        addButton.removeTarget(self, action: #selector(self.hideAddActionMenu(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(self.showAddActionMenu(_:)), for: .touchUpInside)
        
        if appDelegate().modeMap.tempModeName != nil {
            appDelegate().modeMap.tempModeName = nil
            appDelegate().modeMap.tempMode = nil
        }
        if appDelegate().modeMap.openedAddActionChangeMenu {
            appDelegate().modeMap.openedAddActionChangeMenu = false
        }
    }

}
