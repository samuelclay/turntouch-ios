//
//  WidgetExtensionViewController.swift
//  Widget Extension
//
//  Created by David Sinclair on 2020-04-28.
//  Copyright © 2020 Turn Touch. All rights reserved.
//

import UIKit
import NotificationCenter

class WidgetExtensionViewController: UIViewController, NCWidgetProviding {
    var stackView = UIStackView()
    var modeTabsView = UIStackView()
//    var modeTabs: [TTModeTab] = []
//    var modeTabsConstraint: NSLayoutConstraint!
//    var actionDiamondView = TTActionDiamondView(diamondType: .interactive)
//    var actionDiamondConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.backgroundColor = UIColor.white
        
        self.layoutStackview()
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layoutStackview() {
//        modeTabsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        stackView.constraints.forEach { stackView.removeConstraint($0) }
//
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        stackView.distribution = .fill
//        stackView.alignment = .fill
//        stackView.spacing = 0
//        //        stackView.contentMode = .ScaleToFill
//        let guide = self.view.safeAreaLayoutGuide
//        self.view.addSubview(stackView)
//        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width,
//                                                   relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0))
//        self.view.addConstraint(stackView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0))
//        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom,
//                                                   relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
//        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .left,
//                                                   relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0))
//        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .right,
//                                                   relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0))
//
//        if appDelegate().modeMap.buttonAppMode() == .SixteenButtons {
//            modeTabs = [
//                TTModeTab(modeDirection:.north),
//                TTModeTab(modeDirection:.east),
//                TTModeTab(modeDirection:.west),
//                TTModeTab(modeDirection:.south),
//            ]
//        } else {
//            modeTabs = [
//                TTModeTab(modeDirection: .single),
//                TTModeTab(modeDirection: .double),
//                TTModeTab(modeDirection: .hold)
//            ]
//        }
//        for view in modeTabs {
//            modeTabsView.addArrangedSubview(view)
//        }
//        modeTabsView.axis = .horizontal
//        modeTabsView.distribution = .fillEqually
//        modeTabsView.alignment = .fill
//        modeTabsView.spacing = 0
//        modeTabsView.contentMode = .scaleToFill
//        stackView.addArrangedSubview(modeTabsView);
//
//        modeTabsConstraint = NSLayoutConstraint(item: modeTabsView, attribute: .height, relatedBy: .equal,
//                                                toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 92.0)
//        stackView.addConstraint(modeTabsConstraint)
//
//        actionDiamondConstraint = NSLayoutConstraint(item: actionDiamondView, attribute: .height, relatedBy: .equal,
//                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 420)
//        stackView.addConstraint(actionDiamondConstraint)
//        stackView.addArrangedSubview(actionDiamondView)
        
        //        if appDelegate().modeMap.buttonAppMode() == .TwelveButtons, let modeTitleView = modeTitleView {
        //            modeTitleView.alpha = 0
        //            scrollStackView.addArrangedSubview(modeTitleView)
        //            modeTitleConstraint = NSLayoutConstraint(item: modeTitleView, attribute: .height, relatedBy: .equal,
        //                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        //            scrollStackView.addConstraint(modeTitleConstraint)
        //
        //            scrollStackView.addArrangedSubview(modeMenuView)
        //            modeMenuConstaint = NSLayoutConstraint(item: modeMenuView, attribute: .height, relatedBy: .equal,
        //                                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        //            scrollStackView.addConstraint(modeMenuConstaint)
        //        }
        //
        //        scrollStackView.addArrangedSubview(actionMenuView)
        //        actionMenuConstaint = NSLayoutConstraint(item: actionMenuView, attribute: .height, relatedBy: .equal,
        //                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        //        scrollStackView.addConstraint(actionMenuConstaint)
        //
        //        actionTitleView.alpha = 0
        //        scrollStackView.addArrangedSubview(actionTitleView)
        //        actionTitleConstraint = NSLayoutConstraint(item: actionTitleView, attribute: .height, relatedBy: .equal,
        //                                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        //        scrollStackView.addConstraint(actionTitleConstraint)
        //
        //        optionsView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        //        scrollStackView.addArrangedSubview(optionsView)
        //        optionsConstraint = NSLayoutConstraint(item: optionsView, attribute: .height, relatedBy: .equal,
        //                                               toItem: nil, attribute: .notAnAttribute,
        //                                               multiplier: 1.0, constant: 0)
        //        //        scrollStackView.addConstraint(optionsConstraint)
        //
        //        batchActionsStackView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        //        scrollStackView.addArrangedSubview(batchActionsStackView)
        //
        //        addActionMenuConstraint = NSLayoutConstraint(item: addActionMenu, attribute: .height, relatedBy: .equal,
        //                                                     toItem: nil, attribute: .notAnAttribute,
        //                                                     multiplier: 1.0, constant: 0)
        //        scrollStackView.addArrangedSubview(addActionMenu)
        //        scrollStackView.addConstraint(addActionMenuConstraint)
        //
        //        addActionButtonConstraint = NSLayoutConstraint(item: addActionButtonView, attribute: .height, relatedBy: .equal,
        //                                                       toItem: nil, attribute: .notAnAttribute,
        //                                                       multiplier: 1.0, constant: 0)
        //        scrollStackView.addArrangedSubview(addActionButtonView)
        //        scrollStackView.addConstraint(addActionButtonConstraint)
        //
        //        scrollView.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.vertical)
        //        scrollView.alwaysBounceVertical = true
        //        scrollView.insertSubview(scrollStackView, at: 0)
        //        scrollView.backgroundColor = UIColor(hex: 0xF5F6F8)
        //        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .top,
        //                                                    relatedBy: .equal, toItem: scrollView, attribute: .top,
        //                                                    multiplier: 1.0, constant: 0.0))
        //        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .leading,
        //                                                    relatedBy: .equal, toItem: scrollView, attribute: .leading,
        //                                                    multiplier: 1.0, constant: 0.0))
        //        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .trailing,
        //                                                    relatedBy: .equal, toItem: scrollView, attribute: .trailing,
        //                                                    multiplier: 1.0, constant: 0.0))
        //        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .width,
        //                                                    relatedBy: .equal, toItem: scrollView, attribute: .width,
        //                                                    multiplier: 1.0, constant: 0.0))
        //        scrollView.addConstraint(NSLayoutConstraint(item: scrollStackView, attribute: .bottom,
        //                                                    relatedBy: .equal, toItem: scrollView, attribute: .bottom,
        //                                                    multiplier: 1.0, constant: 0.0))
        //        stackView.addArrangedSubview(scrollView)
        //        stackView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .leading,
        //                                                   relatedBy: .equal, toItem: stackView, attribute: .leading,
        //                                                   multiplier: 1.0, constant: 0.0))
        //        stackView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .trailing,
        //                                                   relatedBy: .equal, toItem: stackView, attribute: .trailing,
        //                                                   multiplier: 1.0, constant: 0.0))
        //        scrollView.setNeedsLayout()
        //        scrollView.layoutIfNeeded()
        
        self.applyConstraints()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.applyConstraints()
    }
    
    func applyConstraints() {
//        let buttonAppMode = appDelegate().modeMap.buttonAppMode()
//
//        if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact {
//            titleBarConstraint.constant = 28
//            modeTabsConstraint.constant = 70
//            switch buttonAppMode {
//            case .SixteenButtons:
//                modeTitleConstraint.constant = 48
//            case .TwelveButtons:
//                modeTitleConstraint.constant = 0
//            }
//        } else {
//            titleBarConstraint.constant = 44
//            modeTabsConstraint.constant = 92
//            switch buttonAppMode {
//            case .SixteenButtons:
//                modeTitleConstraint.constant = 64
//            case .TwelveButtons:
//                modeTitleConstraint.constant = 0
//            }
//        }
//
//        if self.traitCollection.horizontalSizeClass == .compact {
//            actionDiamondConstraint.constant = 270
//        } else {
//            actionDiamondConstraint.constant = 420
//        }
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "openedAddActionChangeMenu", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "tempMode", options: [], context: nil)
        //        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "nicknamedConnectedCount", options: [], context: nil)
        //        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "pairedDevicesCount", options: [], context: nil)
    }
    
    deinit {
//        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedAddActionChangeMenu")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "tempMode")
        //        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "nicknamedConnectedCount")
        //        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "pairedDevicesCount")
    }
}
