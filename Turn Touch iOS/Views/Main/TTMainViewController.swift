//
//  TTMainViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTMainViewController: UIViewController {
    
    @IBOutlet var stackView: UIStackView!
    var titleBarView: TTTitleBarView = TTTitleBarView()
    var modeTabsView: UIStackView!
    var modeTabs: [TTModeTab] = []
    var titleBarConstraint: NSLayoutConstraint!
    var modeTabsConstraint: NSLayoutConstraint!
    var modeTitleView: TTModeTitleView = TTModeTitleView()
    var modeTitleConstraint = NSLayoutConstraint()
    var modeMenuView: TTModeMenuContainer = TTModeMenuContainer(menuType: TTMenuType.MENU_MODE)
    var modeMenuConstaint: NSLayoutConstraint!
    var actionDiamondView = TTActionDiamondView()
    var actionMenuView: TTModeMenuContainer = TTModeMenuContainer(menuType: TTMenuType.MENU_ACTION)
    var actionMenuConstaint: NSLayoutConstraint!
    var actionTitleView = TTActionTitleView()
    var actionTitleConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.userInteractionEnabled = true
        stackView.userInteractionEnabled = true
        
        stackView.addArrangedSubview(titleBarView)
        titleBarConstraint = NSLayoutConstraint(item: titleBarView, attribute: .Height,
                                                relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                                multiplier: 1.0, constant: 44)
        stackView.addConstraint(titleBarConstraint)
        
        modeTabs = [
            TTModeTab(modeDirection:.NORTH),
            TTModeTab(modeDirection:.EAST),
            TTModeTab(modeDirection:.WEST),
            TTModeTab(modeDirection:.SOUTH),
        ]
        modeTabsView = UIStackView(arrangedSubviews: modeTabs)
        modeTabsView.axis = .Horizontal
        modeTabsView.distribution = .FillEqually
        modeTabsView.alignment = .Fill
        modeTabsView.spacing = 0
        stackView.addArrangedSubview(modeTabsView);
        
        modeTabsConstraint = NSLayoutConstraint(item: modeTabsView, attribute: .Height, relatedBy: .Equal,
                                                toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 92.0)
        stackView.addConstraint(modeTabsConstraint)
        
        stackView.addArrangedSubview(modeTitleView)
        modeTitleConstraint = NSLayoutConstraint(item: modeTitleView, attribute: .Height, relatedBy: .Equal,
                                                 toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 64)
        stackView.addConstraint(modeTitleConstraint)
        
        stackView.addArrangedSubview(modeMenuView)
        modeMenuConstaint = NSLayoutConstraint(item: modeMenuView, attribute: .Height, relatedBy: .Equal,
                                               toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0)
        stackView.addConstraint(modeMenuConstaint)
        
        stackView.addArrangedSubview(actionDiamondView)
        stackView.addConstraint(NSLayoutConstraint(item: actionDiamondView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 270))

        stackView.addArrangedSubview(actionMenuView)
        actionMenuConstaint = NSLayoutConstraint(item: actionMenuView, attribute: .Height, relatedBy: .Equal,
                                                 toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0)
        stackView.addConstraint(actionMenuConstaint)

        stackView.addArrangedSubview(actionTitleView)
        actionTitleConstraint = NSLayoutConstraint(item: actionTitleView, attribute: .Top, relatedBy: .Equal,
                                                   toItem: actionMenuView, attribute: .Bottom, multiplier: 1.0, constant: -48)
        stackView.addConstraint(actionTitleConstraint)
        stackView.addConstraint(NSLayoutConstraint(item: actionTitleView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 48))
        
        actionDiamondView.layer.zPosition = 2.0
        actionTitleView.layer.zPosition = 1.0

        self.registerAsObserver()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            titleBarConstraint.constant = 28
            modeTabsConstraint.constant = 70
            modeTitleConstraint.constant = 48
        } else {
            titleBarConstraint.constant = 44
            modeTabsConstraint.constant = 92
            modeTitleConstraint.constant = 64
        }
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedMode", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "openedModeChangeMenu" {
            self.toggleModeMenu()
        } else if keyPath == "openedActionChangeMenu" {
            self.toggleActionMenu()
        } else if keyPath == "selectedMode" {
            self.resetPosition()
        } else if keyPath == "inspectingModeDirection" {
            self.toggleActionView()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedMode")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
    }
    
    // MARK: Drawing
    
    func toggleModeMenu() {
        self.modeMenuConstaint.constant = appDelegate().modeMap.openedModeChangeMenu ? modeMenuView.MENU_HEIGHT : 1
        UIView.animateWithDuration(0.42) {
            self.view.layoutIfNeeded()
        }
    }
    
    func toggleActionMenu() {
        self.actionMenuConstaint.constant = appDelegate().modeMap.openedActionChangeMenu ? modeMenuView.MENU_HEIGHT : 1
        UIView.animateWithDuration(0.42) {
            self.view.layoutIfNeeded()
        }
    }
    
    func toggleActionView() {
        actionTitleConstraint.constant = appDelegate().modeMap.inspectingModeDirection == .NO_DIRECTION ? -48 : 0
        
        UIView.animateWithDuration(0.24) {
            self.view.layoutIfNeeded()
        }
    }
    
    func resetPosition() {
        let modeMap = appDelegate().modeMap
        
        modeMap.reset()
        
        if modeMap.openedModeChangeMenu {
            modeMap.openedModeChangeMenu = false
        }
        if modeMap.openedActionChangeMenu {
            modeMap.openedActionChangeMenu = false
        }
        if modeMap.openedAddActionChangeMenu {
            modeMap.openedAddActionChangeMenu = false
        }
    }
    
    // MARK: Events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    }
}
