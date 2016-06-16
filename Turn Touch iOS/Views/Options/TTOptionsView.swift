//
//  TTOptionsView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTOptionsView: UIView {

    var modeOptionsViewController: TTOptionsDetailViewController!
    var actionOptionsViewController: TTOptionsDetailViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.clipsToBounds = true
        self.clearOptionDetailViews()
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
//        appDelegate().modeMap.addObserver(self, forKeyPath: "activeModeDirection", options: [], context: nil)
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
//        appDelegate().modeMap.removeObserver(self, forKeyPath: "activeModeDirection")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedModeDirection" {
            self.drawModeOptions()
        } else if keyPath == "inspectingModeDirection" {
            self.redrawOptions()
//        } else if keyPath == "activeModeDirection" {
//            self.setNeedsDisplay()
        }
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
//        let context = UIGraphicsGetCurrentContext()
//        UIColor(hex: 0xFFFFFF).set()
//        CGContextFillRect(context, self.bounds);

    }
    
    func redrawOptions() {
        if appDelegate().modeMap.inspectingModeDirection == .NO_DIRECTION {
            self.drawModeOptions()
        } else {
            self.drawActionOptions()
        }
    }
    
    func clearOptionDetailViews() {
        self.removeConstraints(self.constraints)

        if modeOptionsViewController != nil {
            modeOptionsViewController.view.removeFromSuperview()
            modeOptionsViewController = nil
        }
        
        if actionOptionsViewController != nil {
            actionOptionsViewController.view.removeFromSuperview()
            actionOptionsViewController = nil
        }
        
    }
    
    func drawModeOptions() {
        self.clearOptionDetailViews()
        
        let modeName = appDelegate().modeMap.selectedMode.nameOfClass
        let modeOptionsViewControllerName = "Turn_Touch_iOS.\(modeName)Options"
        let modeOptionsClass: AnyClass? = NSClassFromString(modeOptionsViewControllerName)
        if modeOptionsClass == nil {
            modeOptionsViewController = TTOptionsDetailViewController()
            modeOptionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        } else {
            modeOptionsViewController = (modeOptionsClass as! TTOptionsDetailViewController.Type).init(nibName: "\(modeName)Options", bundle: nil)
        }
        
        modeOptionsViewController.mode = appDelegate().modeMap.selectedMode
        modeOptionsViewController.menuType = TTMenuType.MENU_MODE
        self.addSubview(modeOptionsViewController.view)
        
        self.addConstraint(NSLayoutConstraint(item: modeOptionsViewController.view, attribute: .Top,
            relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: modeOptionsViewController.view, attribute: .Leading,
            relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: modeOptionsViewController.view, attribute: .Width,
            relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Height,
            relatedBy: .Equal, toItem: modeOptionsViewController.view, attribute: .Height, multiplier: 1.0, constant: 0))
        
        appDelegate().mainViewController.adjustOptionsHeight(modeOptionsViewController.view)
    }
    
    func drawActionOptions() {
        self.clearOptionDetailViews()
        
        let actionName = appDelegate().modeMap.selectedMode.actionNameInDirection(appDelegate().modeMap.inspectingModeDirection)
        let actionOptionsViewControllerName = "Turn_Touch_iOS.\(actionName)Options"
        let actionOptionsClass: AnyClass? = NSClassFromString(actionOptionsViewControllerName)
        if actionOptionsClass == nil {
            actionOptionsViewController = TTOptionsDetailViewController()
            actionOptionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        } else {
            actionOptionsViewController = (actionOptionsClass as! TTOptionsDetailViewController.Type).init(nibName: actionOptionsViewControllerName, bundle: nil)
        }
        
        actionOptionsViewController.menuType = TTMenuType.MENU_ACTION
        actionOptionsViewController.action = TTAction(actionName: actionName!)
        actionOptionsViewController.mode = appDelegate().modeMap.selectedMode
        actionOptionsViewController.mode.action=actionOptionsViewController.action
        actionOptionsViewController.action.mode = appDelegate().modeMap.selectedMode // To parallel batch actions
        self.addSubview(actionOptionsViewController.view)
        
        self.addConstraint(NSLayoutConstraint(item: actionOptionsViewController.view, attribute: .Top,
            relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: actionOptionsViewController.view, attribute: .Leading,
            relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: actionOptionsViewController.view, attribute: .Width,
            relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        
        appDelegate().mainViewController.adjustOptionsHeight(actionOptionsViewController.view)
    }
    
}
