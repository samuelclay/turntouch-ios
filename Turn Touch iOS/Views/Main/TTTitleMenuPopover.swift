//
//  TTTitleMenuPopover.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

protocol TTTitleMenuDelegate {
    func menuOptions() -> [[String: String]]
    func selectMenuOption(_ row: Int)
    var menuHeight: Int { get }
}

class TTTitleMenuPopover: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let CellReuseIdentifier = "TTTitleMenuCell"
    let tableView = UITableView()
    var delegate: TTTitleMenuDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TTTitleMenuCell.self, forCellReuseIdentifier: CellReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .top,
            relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .leading,
            relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .width,
            relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .height,
            relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.menuOptions().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(delegate.menuHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier, for: indexPath) as! TTTitleMenuCell

        cell.textLabel?.text = delegate.menuOptions()[(indexPath as NSIndexPath).row]["title"]
        cell.imageView?.image = UIImage(named: delegate.menuOptions()[(indexPath as NSIndexPath).row]["image"] ?? "alarm_snooze")
        
        let itemSize:CGSize = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, self.traitCollection.displayScale)
        let imageRect : CGRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell.imageView!.image?.draw(in: imageRect)
        cell.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate.selectMenuOption((indexPath as NSIndexPath).row)
    }
}
