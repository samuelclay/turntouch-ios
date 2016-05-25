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
    var modeTabsView: UIStackView!
    var modeTabs: [TTModeTab] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        stackView.addConstraint(NSLayoutConstraint(item: modeTabsView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: stackView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0))
        stackView.addConstraint(NSLayoutConstraint(item: modeTabsView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 140.0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(animated: Bool) {
        
    }

}
