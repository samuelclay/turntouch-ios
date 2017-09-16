//
//  TTModeHomeKitTriggerActionOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 9/15/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHomeKitTriggerActionOptions: TTOptionsDetailViewController {

    var modeHomeKit: TTModeHomeKit!

    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var settingsButton: [UIButton]!
    @IBOutlet var devicesTable: UITableView!
    @IBOutlet var noticeLabel: UILabel!
    
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeHomeKitTriggerActionOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeHomeKit = self.action.mode as! TTModeHomeKit

        spinner.forEach({ $0.isHidden = true })
        settingsButton.forEach({ $0.isHidden = false })
        
        self.devicesTable.rowHeight = UITableViewAutomaticDimension
        self.devicesTable.estimatedRowHeight = 2
        self.devicesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.selectDevices()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    func selectDevices() {
        
    }
    
    func redrawTable() {
        self.devicesTable.reloadData()
        self.devicesTable.layoutIfNeeded()
        tableHeightConstraint.constant = self.devicesTable.contentSize.height
    }

}
