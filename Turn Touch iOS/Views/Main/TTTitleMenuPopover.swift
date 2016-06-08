//
//  TTTitleMenuPopover.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTTitleMenuPopover: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let CellReuseIdentifier = "TTTitleMenuCell"
    let tableView = UITableView()
    let menuOptions = [
        "Add a new remote",
        "Settings",
        "How it works",
        "Contact support",
        "About Turn Touch"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerClass(TTTitleMenuCell.self, forCellReuseIdentifier: CellReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top,
            relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Leading,
            relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Width,
            relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Height,
            relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1.0, constant: 0))
    }
    
    // MARK: Table View Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 32
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier, forIndexPath: indexPath) as! TTTitleMenuCell

        cell.textLabel?.text = menuOptions[indexPath.row]
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            appDelegate().mainViewController.showPairingModal()
        default:
            break
        }
    }
}
