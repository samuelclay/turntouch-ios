//
//  TTActionTitleView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTActionTitleView: UIView {
    
    @IBOutlet var changeButton: UIButton! = UIButton(type: UIButton.ButtonType.system)
    var modeImage: UIImage = UIImage()
    var modeTitle: String = ""
    var titleLabel: UILabel = UILabel()
    var renameButton: UIButton = UIButton()
    var diamondView: TTDiamondView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
//        self.contentMode = UIViewContentMode.Redraw;
        
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setTitle("Change", for: UIControl.State())
        changeButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        changeButton.titleLabel!.textColor = UIColor(hex: 0xA0A0A0)
        changeButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        changeButton.addTarget(self, action: #selector(self.pressChange), for: .touchUpInside)
        self.addSubview(changeButton)
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .trailingMargin, relatedBy: .equal,
            toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: -24))
        self.addConstraint(NSLayoutConstraint(item: changeButton, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        diamondView = TTDiamondView(frame: CGRect.zero, diamondType: .mode)
        diamondView.ignoreSelectedMode = true
        diamondView.ignoreActiveMode = true
        self.addSubview(diamondView)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .leadingMargin, relatedBy: .equal,
            toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.3*24))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24))
        
        
        titleLabel.font = UIFont(name: "Effra", size: 13)
        titleLabel.textColor = UIColor(hex: 0x404A60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal,
            toItem: diamondView, attribute: .trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
            toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        renameButton.translatesAutoresizingMaskIntoConstraints = false
        renameButton.setImage(UIImage(named: "pencil"), for: .normal)
        renameButton.isHidden = true
        renameButton.addTarget(self, action: #selector(self.pressRename), for: .touchUpInside)
        self.addSubview(renameButton)
        self.addConstraint(NSLayoutConstraint(item: renameButton, attribute: .leading, relatedBy: .equal,
                                              toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: renameButton, attribute: .centerY, relatedBy: .equal,
                                              toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: renameButton, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 18))
        self.addConstraint(NSLayoutConstraint(item: renameButton, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 18))

        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "inspectingModeDirection" {
            self.setNeedsDisplay()
        } else if keyPath == "openedActionChangeMenu" {
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        if appDelegate().modeMap.openedActionChangeMenu {
            changeButton.setTitle("Done", for: UIControl.State())
            renameButton.isHidden = false
        } else {
            changeButton.setTitle("Change", for: UIControl.State())
            renameButton.isHidden = true
        }
        
        let direction = appDelegate().modeMap.inspectingModeDirection
        if direction != .no_DIRECTION {
            titleLabel.text = appDelegate().modeMap.selectedMode.titleInDirection(direction, buttonMoment: .button_MOMENT_PRESSUP)
        }
        diamondView.overrideActiveDirection = appDelegate().modeMap.inspectingModeDirection
        diamondView.setNeedsDisplay()
        
        super.draw(rect)
        self.drawBackground()
    }
    
    func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        UIColor(hex: 0xFFFFFF).set()
        context?.fill(self.bounds);
    }
    
    // MARK: Actions
    
    @objc func pressChange(_ sender: UIButton!) {
        appDelegate().modeMap.toggleOpenedActionChangeMenu()
        if appDelegate().modeMap.openedModeChangeMenu {
            appDelegate().modeMap.openedModeChangeMenu = false
        }
        if appDelegate().modeMap.openedAddActionChangeMenu {
            appDelegate().modeMap.openedAddActionChangeMenu = false
        }
        self.setNeedsDisplay()
    }
    
    @objc func pressRename(_ sender: UIButton!) {
        let direction = appDelegate().modeMap.inspectingModeDirection
        let renameAlert = UIAlertController(title: "Rename action", message: nil, preferredStyle: .alert)
        let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { (action) in
            let newActionTitle = renameAlert.textFields![0].text!
            print(" ---> New action title: \(newActionTitle)")
            
            appDelegate().modeMap.selectedMode.setCustomTitle(newActionTitle, direction: direction)
            appDelegate().mainViewController.actionDiamondView.redraw()
            self.setNeedsDisplay()
        })
        
        renameAlert.addTextField { (textfield) in
            if direction != .no_DIRECTION {
                textfield.text = appDelegate().modeMap.selectedMode.titleInDirection(direction, buttonMoment: .button_MOMENT_PRESSUP)
            }
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textfield, queue: OperationQueue.main) { (notification) in
                renameAction.isEnabled = textfield.text != ""
            }
        }
        renameAlert.addAction(UIAlertAction(title: "Reset to default", style: .cancel, handler: { (action) in
            appDelegate().modeMap.selectedMode.setCustomTitle(nil, direction: direction)
            appDelegate().mainViewController.actionDiamondView.redraw()
            self.setNeedsDisplay()
        }))
        renameAlert.addAction(renameAction)
        appDelegate().mainViewController.present(renameAlert, animated: true, completion: nil)
    }
}
