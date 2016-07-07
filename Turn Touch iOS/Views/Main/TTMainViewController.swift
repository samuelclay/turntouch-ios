//
//  TTMainViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTModalState {
    case App
    case FTUX
    case Pairing
    case Devices
    case About
    case Support
}

class TTMainViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var stackView = UIStackView()
    var scrollStackView = UIStackView()
    var scrollView = UIScrollView()
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
    var actionDiamondConstraint: NSLayoutConstraint!
    var actionMenuView: TTModeMenuContainer = TTModeMenuContainer(menuType: TTMenuType.MENU_ACTION)
    var actionMenuConstaint: NSLayoutConstraint!
    var actionTitleView = TTActionTitleView()
    var actionTitleConstraint: NSLayoutConstraint!
    var deviceTitlesView = TTDeviceTitlesView()
    var deviceTitlesConstraint: NSLayoutConstraint!
    var optionsView = TTOptionsView()
    var optionsConstraint: NSLayoutConstraint!
    
    let titleMenu = TTTitleMenuPopover()
    let deviceMenu = TTTitleMenuPopover()

    var modal: TTModalState?
    var pairingViewController: TTPairingViewController?
    var pairingInfoViewController: TTPairingInfoViewController?
    var pairingNavController: UINavigationController!
    
    

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.userInteractionEnabled = true
        self.view.backgroundColor = UIColor.whiteColor()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        stackView.distribution = .Fill
        stackView.alignment = .Fill
        stackView.spacing = 0
        stackView.contentMode = .ScaleToFill
        self.view.addSubview(stackView)
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .Width,
            relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .Top,
            relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .Bottom,
            relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .Leading,
            relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .Trailing,
            relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        
        
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
        modeTabsView.contentMode = .ScaleToFill
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

        scrollStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollStackView.axis = .Vertical
        scrollStackView.distribution = .Fill
        scrollStackView.alignment = .Fill
        scrollStackView.spacing = 0
        scrollStackView.contentMode = .ScaleToFill
        scrollStackView.addArrangedSubview(actionDiamondView)
        actionDiamondConstraint = NSLayoutConstraint(item: actionDiamondView, attribute: .Height, relatedBy: .Equal,
                                                     toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 270)
        scrollStackView.addConstraint(actionDiamondConstraint)

        scrollStackView.addArrangedSubview(actionMenuView)
        actionMenuConstaint = NSLayoutConstraint(item: actionMenuView, attribute: .Height, relatedBy: .Equal,
                                                 toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0)
        scrollStackView.addConstraint(actionMenuConstaint)

        actionTitleView.alpha = 0
        scrollStackView.addArrangedSubview(actionTitleView)
        actionTitleConstraint = NSLayoutConstraint(item: actionTitleView, attribute: .Height, relatedBy: .Equal,
                                                   toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
        scrollStackView.addConstraint(actionTitleConstraint)
        
//        actionDiamondView.layer.zPosition = 2.0
//        actionTitleView.layer.zPosition = 1.0
        
        optionsView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        scrollStackView.addArrangedSubview(optionsView)
        optionsConstraint = NSLayoutConstraint(item: optionsView, attribute: .Height, relatedBy: .Equal,
                                               toItem: nil, attribute: .NotAnAttribute,
                                               multiplier: 1.0, constant: 0)
//        scrollStackView.addConstraint(optionsConstraint)
        
        scrollView.setContentHuggingPriority(100, forAxis: UILayoutConstraintAxis.Vertical)
        scrollView.alwaysBounceVertical = true
        scrollView.insertSubview(scrollStackView, atIndex: 0)
        scrollView.backgroundColor = UIColor(hex: 0xF5F6F8)
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1.0, constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        stackView.addArrangedSubview(scrollView)
        stackView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: stackView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        stackView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: stackView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        stackView.addArrangedSubview(deviceTitlesView)
        deviceTitlesConstraint = NSLayoutConstraint(item: deviceTitlesView, attribute: .Height, relatedBy: .Equal,
                                                    toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
//        stackView.addConstraint(deviceTitlesConstraint)

        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = scrollStackView.frame.size
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
        
        if self.traitCollection.horizontalSizeClass == .Compact {
            actionDiamondConstraint.constant = 270
        } else {
            actionDiamondConstraint.constant = 420
        }
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedMode", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "nicknamedConnectedCount", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "pairedDevicesCount", options: [], context: nil)
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
        } else if keyPath == "nicknamedConnectedCount" {
            self.adjustDeviceTitles()
        } else if keyPath == "pairedDevicesCount" {
            self.adjustDeviceTitles()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedMode")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "nicknamedConnectedCount")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "pairedDevicesCount")
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
        actionTitleConstraint.constant = appDelegate().modeMap.inspectingModeDirection == .NO_DIRECTION ? 0 : 48
        
        UIView.animateWithDuration(0.24) {
            self.view.layoutIfNeeded()
            self.actionTitleView.alpha = appDelegate().modeMap.inspectingModeDirection == .NO_DIRECTION ? 0 : 1
        }
    }
    
    func adjustDeviceTitles() {
//        dispatch_async(dispatch_get_main_queue()) { 
//            let devices = appDelegate().bluetoothMonitor.foundDevices.nicknamedConnected()
//            
//            UIView.animateWithDuration(0.42) {
//                self.deviceTitlesConstraint.constant = CGFloat(40 * devices.count)
//            }
//        }
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
        
        modeTabsView.setNeedsDisplay()
    }
    
    // MARK: Events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    }
    
    // MARK: Options
    
    func adjustOptionsHeight(optionsDetailView: UIView?) {
        if optionsConstraint == nil {
            return
        }
        
//        stackView.removeConstraint(optionsConstraint)
        
        
        if optionsDetailView == nil {
            optionsConstraint = NSLayoutConstraint(item: optionsView, attribute: .Height, relatedBy: .Equal,
                                                   toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
//            stackView.addConstraint(optionsConstraint)
        } else {
            optionsConstraint = NSLayoutConstraint(item: optionsView, attribute: .Height, relatedBy: .Equal,
                                                   toItem: optionsDetailView, attribute: .Height, multiplier: 1.0, constant: 0)
//            stackView.addConstraint(optionsConstraint)
        }
        UIView.animateWithDuration(0.42) {
            self.stackView.setNeedsUpdateConstraints()
            self.stackView.updateConstraintsIfNeeded()
            self.stackView.setNeedsLayout()
        }
    }
    
    // MARK: Modals and menus
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController)
        -> UIModalPresentationStyle {
        return .None
    }
    
    func toggleTitleMenu(sender: UIButton) {
        titleMenu.delegate = titleBarView
        titleMenu.modalPresentationStyle = .Popover
        titleMenu.preferredContentSize = CGSize(width: 204,
                                                height: 32 * titleMenu.delegate.menuOptions().count)
        if let popoverViewController = titleMenu.popoverPresentationController {
            popoverViewController.permittedArrowDirections = .Up
            popoverViewController.delegate = self
            popoverViewController.sourceView = sender
            popoverViewController.sourceRect = CGRect(x: -8, y: 0,
                                                      width: CGRectGetWidth(sender.frame),
                                                      height: CGRectGetHeight(sender.frame))
        }
        self.presentViewController(titleMenu, animated: true, completion: nil)
    }
    
    func toggleDeviceMenu(sender: UIButton, deviceTitleView: TTDeviceTitleView, device: TTDevice) {
        deviceMenu.delegate = deviceTitleView
        deviceMenu.modalPresentationStyle = .Popover
        deviceMenu.preferredContentSize = CGSize(width: 204,
                                                height: 32 * deviceMenu.delegate.menuOptions().count)
        let popoverViewController = deviceMenu.popoverPresentationController
        popoverViewController!.permittedArrowDirections = .Down
        popoverViewController!.delegate = self
        popoverViewController!.sourceView = sender
        popoverViewController!.sourceRect = CGRect(x: -8, y: 0,
                                                   width: CGRectGetWidth(sender.frame),
                                                   height: CGRectGetHeight(sender.frame))
        self.presentViewController(deviceMenu, animated: true, completion: nil)
    }
    
    func closeDeviceMenu() {
        deviceMenu.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Modals
    
    func switchModal(modal: TTModalState) {
        self.modal = modal
        switch modal {
        case .Pairing:
            self.showPairingModal()
        default:
            break
        }
    }
    
    func showPairingModal() {
        titleMenu.dismissViewControllerAnimated(true , completion: nil)
        pairingViewController = TTPairingViewController(pairingState: .Searching)
        pairingInfoViewController = TTPairingInfoViewController(pairingState: .Intro)
        
        let anyPaired = appDelegate().bluetoothMonitor.foundDevices.totalPairedCount() > 0
        pairingNavController = UINavigationController(rootViewController: anyPaired ? pairingViewController! : pairingInfoViewController!)
        pairingNavController.modalPresentationStyle = .FullScreen
        self.presentViewController(pairingNavController, animated: true, completion: nil)
    }
    
    func closePairingModal() {
        pairingNavController.dismissViewControllerAnimated(true, completion: nil)
    }
}
