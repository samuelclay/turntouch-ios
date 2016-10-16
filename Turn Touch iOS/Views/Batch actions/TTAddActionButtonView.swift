//
//  TTAddActionButtonView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTAddActionButtonView: UIView {

    @IBOutlet var addButton: UIButton! = UIButton(type: UIButtonType.system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIViewContentMode.redraw;
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(named: "button_plus"), for: .normal)
        addButton.setTitle("Add new action", for: UIControlState.normal)
        addButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        addButton.titleLabel!.textColor = UIColor(hex: 0xA0A0A0)
        addButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        addButton.addTarget(self, action: #selector(self.showAddActionMenu), for: .touchUpInside)
        self.addSubview(addButton)
        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .top, relatedBy: .equal,
                                              toItem: self, attribute: .top, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .bottom, relatedBy: .equal,
                                              toItem: self, attribute: .bottom, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: addButton, attribute: .centerX, relatedBy: .equal,
                                              toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        
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
    
    func showAddActionMenu(_ sender: UIButton!) {
        addButton.setTitle("Cancel", for: .normal)
        addButton.setImage(UIImage(named: "button_x"), for: .normal)
        addButton.removeTarget(self, action: #selector(self.showAddActionMenu(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(self.hideAddActionMenu(_:)), for: .touchUpInside)

        appDelegate().modeMap.openedAddActionChangeMenu = true
    }

    func hideAddActionMenu(_ sender: UIButton!) {
        addButton.setTitle("Add new action", for: .normal)
        addButton.setImage(UIImage(named: "button_plus"), for: .normal)
        addButton.removeTarget(self, action: #selector(self.hideAddActionMenu(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(self.showAddActionMenu(_:)), for: .touchUpInside)
        
        appDelegate().modeMap.openedAddActionChangeMenu = false
    }

}
