//
//  WidgetExtensionViewController.swift
//  Widget Extension
//
//  Created by David Sinclair on 2020-04-28.
//  Copyright © 2020 Turn Touch. All rights reserved.
//

import UIKit
import NotificationCenter

enum WidgetError: String, Error {
    case noErrorsImplementedYet
}

class WidgetExtensionViewController: UIViewController, NCWidgetProviding {
    var stackView = UIStackView()
    var modeTabsView = UIStackView()
    var modeTabs: [TTModeTab] = []
    var modeTabsConstraint: NSLayoutConstraint!
    var actionDiamondView: TTActionDiamondView
    var actionDiamondWidthConstraint: NSLayoutConstraint!
    var actionDiamondHeightConstraint: NSLayoutConstraint!
    
    /// An error to display instead of the controls, or `nil` if the controls should be displayed.
    var error: WidgetError?
    
    struct Constant {
        static let defaultCompactHeight: CGFloat = 110
        static let modeTabsHeight: CGFloat = 92
        static let actionDiamondCompactWidth: CGFloat = 180
        static let actionDiamondExpandedHeight: CGFloat = 270
    }
    
    required init?(coder: NSCoder) {
        appDelegate().prepare()
        actionDiamondView = TTActionDiamondView(diamondType: .interactive)
        
        super.init(coder: coder)
    }
    
    deinit {
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedAddActionChangeMenu")
                appDelegate().modeMap.removeObserver(self, forKeyPath: "selectedModeDirection")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        //        appDelegate().modeMap.removeObserver(self, forKeyPath: "tempMode")
        //        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "nicknamedConnectedCount")
        //        appDelegate().bluetoothMonitor.removeObserver(self, forKeyPath: "pairedDevicesCount")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        registerAsObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        extensionContext?.widgetLargestAvailableDisplayMode = error == nil ? .expanded : .compact
        
        layoutStackview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.noData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            // The compact view is a fixed size.
            preferredContentSize = maxSize
        case .expanded:
            let height: CGFloat = Constant.modeTabsHeight + Constant.actionDiamondExpandedHeight
            
            preferredContentSize = CGSize(width: maxSize.width, height: min(height, maxSize.height))
        @unknown default:
            preconditionFailure("Unexpected value for activeDisplayMode.")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] (UIViewControllerTransitionCoordinatorContext) in
            guard let self = self else {
                return
            }
            
            self.stackView.alignment = self.isCompact ? .center : .fill
            self.applyConstraints()
        }, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        applyConstraints()
    }
}

/// Helpers.
extension WidgetExtensionViewController {
    var isCompact: Bool {
        return extensionContext?.widgetActiveDisplayMode == NCWidgetDisplayMode.compact
    }
    
    func layoutStackview() {
        modeTabsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.constraints.forEach { stackView.removeConstraint($0) }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = isCompact ? .center : .fill
        stackView.spacing = 0
        //        stackView.contentMode = .ScaleToFill
        let guide = self.view.safeAreaLayoutGuide
        self.view.addSubview(stackView)
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width,
                                                   relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(stackView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom,
                                                   relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .left,
                                                   relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .right,
                                                   relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0))
        
        if appDelegate().modeMap.buttonAppMode() == .SixteenButtons {
            modeTabs = [
                TTModeTab(modeDirection:.north),
                TTModeTab(modeDirection:.east),
                TTModeTab(modeDirection:.west),
                TTModeTab(modeDirection:.south),
            ]
        } else {
            modeTabs = [
                TTModeTab(modeDirection: .single),
                TTModeTab(modeDirection: .double),
                TTModeTab(modeDirection: .hold)
            ]
        }
        for view in modeTabs {
            modeTabsView.addArrangedSubview(view)
        }
        modeTabsView.axis = .horizontal
        modeTabsView.distribution = .fillEqually
        modeTabsView.alignment = .fill
        modeTabsView.spacing = 0
        modeTabsView.contentMode = .scaleToFill
        stackView.addArrangedSubview(modeTabsView);
        stackView.addArrangedSubview(actionDiamondView)
        
        modeTabsConstraint = NSLayoutConstraint(item: modeTabsView, attribute: .height, relatedBy: .equal,
                                                toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Constant.modeTabsHeight)
        stackView.addConstraint(modeTabsConstraint)
        
        actionDiamondWidthConstraint = NSLayoutConstraint(item: actionDiamondView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        actionDiamondHeightConstraint = NSLayoutConstraint(item: actionDiamondView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Constant.actionDiamondExpandedHeight)
        stackView.addConstraint(actionDiamondWidthConstraint)
        stackView.addConstraint(actionDiamondHeightConstraint)
        
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
    
    func applyConstraints() {
        guard let context = extensionContext else {
            return
        }
        
        let maxSize = context.widgetMaximumSize(for: .compact)
        
        if isCompact {
            modeTabsView.isHidden = true
            actionDiamondWidthConstraint.constant = Constant.actionDiamondCompactWidth
            actionDiamondHeightConstraint.constant = maxSize.height
        } else {
            modeTabsView.isHidden = false
            actionDiamondWidthConstraint.constant = maxSize.width
            actionDiamondHeightConstraint.constant = Constant.actionDiamondExpandedHeight
        }
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "openedAddActionChangeMenu", options: [], context: nil)
                appDelegate().modeMap.addObserver(self, forKeyPath: "selectedModeDirection", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        //        appDelegate().modeMap.addObserver(self, forKeyPath: "tempMode", options: [], context: nil)
        //        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "nicknamedConnectedCount", options: [], context: nil)
        //        appDelegate().bluetoothMonitor.addObserver(self, forKeyPath: "pairedDevicesCount", options: [], context: nil)
    }
}
