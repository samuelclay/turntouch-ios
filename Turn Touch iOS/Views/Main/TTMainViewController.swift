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
    var titleBarConstraint = NSLayoutConstraint()
    var modeTabsConstraint = NSLayoutConstraint()
    var modeTitleView: TTModeTitleView = TTModeTitleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        modeTabsView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(modeTabsView);
        
        modeTabsConstraint = NSLayoutConstraint(item: modeTabsView, attribute: .Height, relatedBy: .Equal,
                                                toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute,
                                                multiplier: 1.0, constant: 92.0)
        stackView.addConstraint(modeTabsConstraint)
        
        stackView.addArrangedSubview(modeTitleView)
        stackView.addConstraint(NSLayoutConstraint(item: modeTitleView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 64))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            titleBarConstraint.constant = 28;
            modeTabsConstraint.constant = 70;
        } else {
            titleBarConstraint.constant = 44;
            modeTabsConstraint.constant = 92;
        }
    }

}
