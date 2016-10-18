//
//  TTBatchActionStackView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTBatchActionStackView: UIStackView {
    
    var tempHeaderConstraint: NSLayoutConstraint!
    var actionOptionsViewControllers: [TTOptionsDetailViewController] = []
    var actionViews: [String: [UIView]] = [:]
    var actionConstraints: [String: NSLayoutConstraint] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = 0
        self.clipsToBounds = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assemble() {
        let tempHeaderView: TTBatchActionHeaderView
        self.removeConstraints(self.constraints)
        for subview in self.arrangedSubviews {
            subview.removeFromSuperview()
        }
        actionOptionsViewControllers.removeAll()
        actionOptionsViewControllers = []
        actionViews = [:]
        actionConstraints = [:]
        let batchActions = appDelegate().modeMap.selectedModeBatchActions(in: appDelegate().modeMap.inspectingModeDirection)
        
        for batchAction in batchActions {
            let batchActionHeaderView = TTBatchActionHeaderView(batchAction: batchAction)
            self.addArrangedSubview(batchActionHeaderView)

            let constraint = NSLayoutConstraint(item: batchActionHeaderView, attribute: .height,
                                                relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                                multiplier: 1.0, constant: 44)
            self.addConstraint(constraint)
            actionConstraints[batchAction.batchActionKey!] = constraint
            
            let actionOptionsViewControllerName = "Turn_Touch_iOS.\(batchAction.actionName!)Options"
            let actionOptionsClass: AnyClass? = NSClassFromString(actionOptionsViewControllerName)
            var actionOptionsViewController: TTOptionsDetailViewController
            if actionOptionsClass == nil {
                actionOptionsViewController = TTOptionsDetailViewController()
                actionOptionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
            } else {
                actionOptionsViewController = (actionOptionsClass as! TTOptionsDetailViewController.Type).init(nibName: actionOptionsViewControllerName, bundle: Bundle.main)
            }
            
            actionOptionsViewController.menuType = TTMenuType.menu_ACTION
            actionOptionsViewController.action = batchAction
            actionOptionsViewController.mode = batchAction.mode
            self.addArrangedSubview(actionOptionsViewController.view)
            actionOptionsViewControllers.append(actionOptionsViewController) // Cache so it doesn't lose reference in xib
            actionViews[batchAction.batchActionKey!] = [batchActionHeaderView,
                                                        actionOptionsViewController.view]
            
        }
        
        // tempMode on bottom
        if appDelegate().modeMap.tempMode != nil {
            tempHeaderView = TTBatchActionHeaderView(tempMode: appDelegate().modeMap.tempMode)
            self.addArrangedSubview(tempHeaderView)

            self.addConstraint(NSLayoutConstraint(item: tempHeaderView, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute,
                                                  multiplier: 1.0, constant: 44))
        }
    }
    
    func hideBatchAction(batchActionKey: String) {
        for (key, views) in actionViews {
            if key == batchActionKey {
                UIView.animate(withDuration: 0.42, animations: {
                    for view in views {
                        view.alpha = 0
                        view.isHidden = true
                    }
                })
            }
        }
        for (key, constraint) in actionConstraints {
            if key == batchActionKey {
                UIView.animate(withDuration: 0.42, animations: {
//                    constraint.constant = 0
                })
            }
        }
    }
    
}
