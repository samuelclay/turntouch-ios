//
//  TTMainViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTModalState {
    case app
    case ftux
    case pairing
    case devices
    case about
    case support
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
    var modeMenuView: TTModeMenuContainer = TTModeMenuContainer(menuType: TTMenuType.menu_MODE)
    var modeMenuConstaint: NSLayoutConstraint!
    var actionDiamondView = TTActionDiamondView(diamondType: .interactive)
    var actionDiamondConstraint: NSLayoutConstraint!
    var actionMenuView: TTModeMenuContainer = TTModeMenuContainer(menuType: TTMenuType.menu_ACTION)
    var actionMenuConstaint: NSLayoutConstraint!
    var actionTitleView = TTActionTitleView()
    var actionTitleConstraint: NSLayoutConstraint!
    var deviceTitlesView = TTDeviceTitlesView()
    var deviceTitlesConstraint: NSLayoutConstraint!
    var optionsView = TTOptionsView()
    var optionsConstraint: NSLayoutConstraint!
    var batchActionsStackView = TTBatchActionStackView()
    var addActionMenu = TTModeMenuContainer(menuType: TTMenuType.menu_ADD_MODE)
    var addActionButtonView = TTAddActionButtonView()
    var addActionMenuConstraint: NSLayoutConstraint!
    var addActionButtonConstraint: NSLayoutConstraint!
    
    let titleMenu = TTTitleMenuPopover()
    let deviceMenu = TTTitleMenuPopover()

    var modalState: TTModalState?
    var pairingViewController: TTPairingViewController?
    var pairingInfoViewController: TTPairingInfoViewController?
    var ftuxViewController: TTFTUXViewController?
    var modalNavController: UINavigationController!
    
    

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.backgroundColor = UIColor.white
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
//        stackView.contentMode = .ScaleToFill
        self.view.addSubview(stackView)
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width,
            relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .top,
            relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom,
            relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .left,
            relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .right,
            relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0))
        
        
        stackView.addArrangedSubview(titleBarView)
        titleBarConstraint = NSLayoutConstraint(item: titleBarView, attribute: .height,
                                                relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                                multiplier: 1.0, constant: 44)
        stackView.addConstraint(titleBarConstraint)
        
        modeTabs = [
            TTModeTab(modeDirection:.north),
            TTModeTab(modeDirection:.east),
            TTModeTab(modeDirection:.west),
            TTModeTab(modeDirection:.south),
        ]
        modeTabsView = UIStackView(arrangedSubviews: modeTabs)
        modeTabsView.axis = .horizontal
        modeTabsView.distribution = .fillEqually
        modeTabsView.alignment = .fill
        modeTabsView.spacing = 0
        modeTabsView.contentMode = .scaleToFill
        stackView.addArrangedSubview(modeTabsView);
        
        modeTabsConstraint = NSLayoutConstraint(item: modeTabsView, attribute: .height, relatedBy: .equal,
                                                toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 92.0)
        stackView.addConstraint(modeTabsConstraint)
        
        stackView.addArrangedSubview(modeTitleView)
        modeTitleConstraint = NSLayoutConstraint(item: modeTitleView, attribute: .height, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64)
        stackView.addConstraint(modeTitleConstraint)
        
        stackView.addArrangedSubview(modeMenuView)
        modeMenuConstaint = NSLayoutConstraint(item: modeMenuView, attribute: .height, relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        stackView.addConstraint(modeMenuConstaint)

        scrollStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollStackView.axis = .vertical
        scrollStackView.distribution = .fill
        scrollStackView.alignment = .fill
        scrollStackView.spacing = 0
        scrollStackView.addArrangedSubview(actionDiamondView)
        actionDiamondConstraint = NSLayoutConstraint(item: actionDiamondView, attribute: .height, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 270)
        scrollStackView.addConstraint(actionDiamondConstraint)

        scrollStackView.addArrangedSubview(actionMenuView)
        actionMenuConstaint = NSLayoutConstraint(item: actionMenuView, attribute: .height, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        scrollStackView.addConstraint(actionMenuConstaint)

        actionTitleView.alpha = 0
        scrollStackView.addArrangedSubview(actionTitleView)
        actionTitleConstraint = NSLayoutConstraint(item: actionTitleView, attribute: .height, relatedBy: .equal,
                                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        scrollStackView.addConstraint(actionTitleConstraint)
        
        optionsView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        scrollStackView.addArrangedSubview(optionsView)
        optionsConstraint = NSLayoutConstraint(item: optionsView, attribute: .height, relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute,
                                               multiplier: 1.0, constant: 0)
//        scrollStackView.addConstraint(optionsConstraint)
        
        batchActionsStackView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        scrollStackView.addArrangedSubview(batchActionsStackView)
        
        addActionMenuConstraint = NSLayoutConstraint(item: addActionMenu, attribute: .height, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute,
                                                     multiplier: 1.0, constant: 0)
        scrollStackView.addArrangedSubview(addActionMenu)
        scrollStackView.addConstraint(addActionMenuConstraint)
        
        addActionButtonView.isHidden = true
        scrollStackView.addArrangedSubview(addActionButtonView)
        
        scrollView.setContentHuggingPriority(100, for: UILayoutConstraintAxis.vertical)
        scrollView.alwaysBounceVertical = true
        scrollView.insertSubview(scrollStackView, at: 0)
        scrollView.backgroundColor = UIColor(hex: 0xF5F6F8)
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .top,
                                                    relatedBy: .equal, toItem: scrollView, attribute: .top,
                                                    multiplier: 1.0, constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .leading,
                                                    relatedBy: .equal, toItem: scrollView, attribute: .leading,
                                                    multiplier: 1.0, constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .trailing,
                                                    relatedBy: .equal, toItem: scrollView, attribute: .trailing,
                                                    multiplier: 1.0, constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .width,
                                                    relatedBy: .equal, toItem: scrollView, attribute: .width,
                                                    multiplier: 1.0, constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .bottom,
                                                    relatedBy: .equal, toItem: scrollView, attribute: .bottom,
                                                    multiplier: 1.0, constant: 0.0))
        stackView.addArrangedSubview(scrollView)
        stackView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .leading,
                                                   relatedBy: .equal, toItem: stackView, attribute: .leading,
                                                   multiplier: 1.0, constant: 0.0))
        stackView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .trailing,
                                                   relatedBy: .equal, toItem: stackView, attribute: .trailing,
                                                   multiplier: 1.0, constant: 0.0))
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        stackView.addArrangedSubview(deviceTitlesView)
        deviceTitlesConstraint = NSLayoutConstraint(item: deviceTitlesView, attribute: .height,
                                                    relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                                    multiplier: 1.0, constant: 0)
//        stackView.addConstraint(deviceTitlesConstraint)

        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact {
            titleBarConstraint.constant = 28
            modeTabsConstraint.constant = 70
            modeTitleConstraint.constant = 48
        } else {
            titleBarConstraint.constant = 44
            modeTabsConstraint.constant = 92
            modeTitleConstraint.constant = 64
        }
        
        if self.traitCollection.horizontalSizeClass == .compact {
            actionDiamondConstraint.constant = 270
        } else {
            actionDiamondConstraint.constant = 420
        }
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedAddActionChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedMode", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "tempMode", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "nicknamedConnectedCount", options: [], context: nil)
        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "pairedDevicesCount", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "openedModeChangeMenu" {
            self.toggleModeMenu()
        } else if keyPath == "openedActionChangeMenu" {
            self.toggleActionMenu()
        } else if keyPath == "openedAddActionChangeMenu" {
            self.toggleAddActionMenu()
        } else if keyPath == "selectedMode" {
            self.resetPosition()
        } else if keyPath == "inspectingModeDirection" {
            self.toggleActionView()
            self.toggleAddActionMenu()
            self.toggleAddActionButtonView()
            self.adjustBatchActions()
        } else if keyPath == "nicknamedConnectedCount" {
            self.adjustDeviceTitles()
        } else if keyPath == "pairedDevicesCount" {
            self.adjustDeviceTitles()
        } else if keyPath == "tempMode" {
            self.adjustBatchActions()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedAddActionChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedMode")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "tempMode")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "nicknamedConnectedCount")
        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "pairedDevicesCount")
    }
    
    // MARK: Drawing
    
    func toggleModeMenu() {
        self.modeMenuConstaint.constant = appDelegate().modeMap.openedModeChangeMenu ? modeMenuView.MENU_HEIGHT : 1
        UIView.animate(withDuration: 0.42, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    func toggleActionMenu() {
        self.actionMenuConstaint.constant = appDelegate().modeMap.openedActionChangeMenu ? modeMenuView.MENU_HEIGHT : 1
        UIView.animate(withDuration: 0.42, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func toggleAddActionMenu() {
        self.addActionMenuConstraint.constant = appDelegate().modeMap.openedAddActionChangeMenu ? modeMenuView.MENU_HEIGHT : 1
        UIView.animate(withDuration: 0.42, animations: {
            self.view.layoutIfNeeded()
        })
        
        if appDelegate().modeMap.openedAddActionChangeMenu {
            self.scrollToBottom()
        }
    }
    
    func toggleAddActionButtonView() {
        if appDelegate().modeMap.inspectingModeDirection != .no_DIRECTION {
            addActionButtonView.isHidden = false
        } else {
            addActionButtonView.isHidden = true
        }
    }
    
    func toggleActionView() {
        actionTitleConstraint.constant = appDelegate().modeMap.inspectingModeDirection == .no_DIRECTION ? 0 : 48
        
        UIView.animate(withDuration: 0.24, animations: {
            self.view.layoutIfNeeded()
            self.actionTitleView.alpha = appDelegate().modeMap.inspectingModeDirection == .no_DIRECTION ? 0 : 1
        }) 
    }
    
    func scrollToBottom() {
        let contentHeight = self.scrollView.contentSize.height
        let scrollHeight = self.scrollView.bounds.size.height
        
        if contentHeight > scrollHeight {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: contentHeight - scrollHeight), animated: true)
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
    
    func adjustBatchActions() {
        batchActionsStackView.assemble()
    }
    
    func resetPosition() {
        if let modeMap = appDelegate().modeMap {
        
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
        
        modeTabsView.setNeedsDisplay()
    }
    
    // MARK: Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    // MARK: Options
    
    func adjustOptionsHeight(_ optionsDetailView: UIView?) {
        if optionsConstraint == nil {
            return
        }
        
//        stackView.removeConstraint(optionsConstraint)
        
        
        if optionsDetailView == nil {
            optionsConstraint = NSLayoutConstraint(item: optionsView, attribute: .height,
                                                   relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                                   multiplier: 1.0, constant: 0)
//            stackView.addConstraint(optionsConstraint)
        } else {
            optionsConstraint = NSLayoutConstraint(item: optionsView, attribute: .height,
                                                   relatedBy: .equal, toItem: optionsDetailView, attribute: .height,
                                                   multiplier: 1.0, constant: 0)
//            stackView.addConstraint(optionsConstraint)
        }
        UIView.animate(withDuration: 0.42, animations: {
            self.stackView.setNeedsUpdateConstraints()
            self.stackView.updateConstraintsIfNeeded()
            self.stackView.setNeedsLayout()
        }) 
    }
    
    // MARK: Modals and menus
    
    func adaptivePresentationStyle(for controller: UIPresentationController)
        -> UIModalPresentationStyle {
        return .none
    }
    
    func toggleTitleMenu(_ sender: UIButton) {
        titleMenu.delegate = titleBarView
        titleMenu.modalPresentationStyle = .popover
        titleMenu.preferredContentSize = CGSize(width: 204,
                                                height: 32 * titleMenu.delegate.menuOptions().count)
        if let popoverViewController = titleMenu.popoverPresentationController {
            popoverViewController.permittedArrowDirections = .up
            popoverViewController.delegate = self
            popoverViewController.sourceView = sender
            popoverViewController.sourceRect = CGRect(x: -8, y: 0,
                                                      width: sender.frame.width,
                                                      height: sender.frame.height)
        }
        self.present(titleMenu, animated: true, completion: nil)
    }
    
    func toggleDeviceMenu(_ sender: UIButton, deviceTitleView: TTDeviceTitleView, device: TTDevice) {
        deviceMenu.delegate = deviceTitleView
        deviceMenu.modalPresentationStyle = .popover
        deviceMenu.preferredContentSize = CGSize(width: 204,
                                                height: 32 * deviceMenu.delegate.menuOptions().count)
        let popoverViewController = deviceMenu.popoverPresentationController
        popoverViewController!.permittedArrowDirections = .down
        popoverViewController!.delegate = self
        popoverViewController!.sourceView = sender
        popoverViewController!.sourceRect = CGRect(x: -8, y: 0,
                                                   width: sender.frame.width,
                                                   height: sender.frame.height)
        self.present(deviceMenu, animated: true, completion: nil)
    }
    
    func closeDeviceMenu() {
        deviceMenu.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Modals
    
    func switchModal(_ modalState: TTModalState) {
        self.modalState = modalState
        switch modalState {
        case .pairing:
            self.showPairingModal()
        default:
            break
        }
    }
    
    func showPairingModal() {
        if modalNavController != nil {
            print(" ---> Don't show pairing modal, already showing it")
            return
        }
        
        titleMenu.dismiss(animated: true , completion: nil)
        pairingViewController = TTPairingViewController(pairingState: .searching)
        pairingInfoViewController = TTPairingInfoViewController(pairingState: .intro)
        
        let anyPaired = appDelegate().bluetoothMonitor.foundDevices.totalPairedCount() > 0
        modalNavController = UINavigationController(rootViewController: anyPaired ? pairingViewController! : pairingInfoViewController!)
        modalNavController.modalPresentationStyle = .formSheet
        self.present(modalNavController, animated: true, completion: nil)
    }
    
    func switchPairingModal(_ pairingState: TTPairingState) {
        if pairingState == .searching && modalNavController.visibleViewController == pairingViewController {
            pairingViewController?.changedDeviceCount()
        } else if pairingState == .searching && pairingViewController?.pairingState == .failure {
            modalNavController.popViewController(animated: true)
        } else {
            modalNavController.pushViewController(pairingState == .searching ? pairingViewController! : pairingInfoViewController!, animated: true)
        }
    }
    
    func closePairingModal() {
        modalNavController.dismiss(animated: true, completion: nil)
        modalNavController = nil
    }
    
    func showFtuxModal() {
        if modalNavController != nil {
            print(" ---> Don't show FTUX, already showing modal")
            return
        }
        
        titleMenu.dismiss(animated: true, completion: nil)
        ftuxViewController = TTFTUXViewController()
        modalNavController = UINavigationController(rootViewController: ftuxViewController!)
        modalNavController.modalPresentationStyle = .formSheet
        self.present(modalNavController, animated: true, completion: nil)
    }
    
    func switchFtuxModal(_ ftuxPage: TTFTUXPage) {
        if modalNavController.visibleViewController != ftuxViewController {
            ftuxViewController = TTFTUXViewController()
            modalNavController.pushViewController(ftuxViewController!, animated: true)
        } else {
            ftuxViewController?.setPage(ftuxPage)
        }
    }
    
    func closeFtuxModal() {
        modalNavController.dismiss(animated: true, completion: nil)
        modalNavController = nil
    }

}
