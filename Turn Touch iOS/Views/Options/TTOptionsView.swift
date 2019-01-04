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
        self.contentMode = UIView.ContentMode.top
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedModeDirection" {
            self.drawModeOptions()
        } else if keyPath == "inspectingModeDirection" {
            self.redrawOptions()
//        } else if keyPath == "activeModeDirection" {
//            self.setNeedsDisplay()
        }
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        UIColor(hex: 0xFFFFFF).set()
        context?.fill(self.bounds);
    }
    
    func redrawOptions(forceMode: Bool = false) {
        if appDelegate().modeMap.inspectingModeDirection == .no_DIRECTION || forceMode {
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
        modeOptionsViewController.menuType = TTMenuType.menu_MODE
        modeOptionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(modeOptionsViewController.view)
        
        self.addConstraint(NSLayoutConstraint(item: modeOptionsViewController.view, attribute: .top,
            relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: modeOptionsViewController.view, attribute: .leading,
            relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: modeOptionsViewController.view, attribute: .width,
            relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height,
            relatedBy: .equal, toItem: modeOptionsViewController.view, attribute: .height, multiplier: 1.0, constant: 0))
        
        appDelegate().mainViewController.adjustOptionsHeight(modeOptionsViewController.view)
    }
    
    func drawActionOptions() {
        self.clearOptionDetailViews()
        
        let inspectingModeDirection = appDelegate().modeMap.inspectingModeDirection
        var selectedMode = appDelegate().modeMap.selectedMode
        if appDelegate().modeMap.buttonAppMode() == .TwelveButtons {
            selectedMode = appDelegate().modeMap.modeInDirection(inspectingModeDirection)
        }
        let actionName = selectedMode.actionNameInDirection(inspectingModeDirection)
        var actionOptionsViewControllerName = "Turn_Touch_iOS.\(actionName)Options"
        var actionOptionsClass: AnyClass? = NSClassFromString(actionOptionsViewControllerName)

        if selectedMode.shouldUseModeOptionsFor(actionName) {
            actionOptionsViewControllerName = "\(selectedMode.nameOfClass)Options"
            actionOptionsClass = NSClassFromString("Turn_Touch_iOS.\(actionOptionsViewControllerName)")
        }

        if actionOptionsClass == nil {
            actionOptionsViewController = TTOptionsDetailViewController()
            actionOptionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        } else {
            actionOptionsViewController = (actionOptionsClass as! TTOptionsDetailViewController.Type).init(nibName: actionOptionsViewControllerName, bundle: Bundle.main)
        }
        
        actionOptionsViewController.menuType = TTMenuType.menu_ACTION
        actionOptionsViewController.action = TTAction(actionName: actionName, direction: inspectingModeDirection)
        actionOptionsViewController.mode = selectedMode
        actionOptionsViewController.mode.action = actionOptionsViewController.action
        actionOptionsViewController.action.mode = selectedMode // To parallel batch actions
        actionOptionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(actionOptionsViewController.view)
        
        self.addConstraint(NSLayoutConstraint(item: actionOptionsViewController.view, attribute: .top,
            relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: actionOptionsViewController.view, attribute: .leading,
            relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: actionOptionsViewController.view, attribute: .width,
            relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height,
            relatedBy: .equal, toItem: actionOptionsViewController.view, attribute: .height, multiplier: 1.0, constant: 0))
        
        appDelegate().mainViewController.adjustOptionsHeight(actionOptionsViewController.view)
    }
    
}
