//
//  TTModeHueBridge.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueBridge: TTOptionsDetailViewController, UITableViewDelegate, UITableViewDataSource {
    
    let CellReuseIdentifier = "TTModeHueBridgeCell"
    var modeHue: TTModeHue!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var label: UILabel!
    var bridgesFound: [String: String] = [:]
    var sortedBridgeKeys: [String] = []
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.allowsSelection = true
        
        tableHeightConstraint.constant = CGFloat(self.bridgesFound.count * 44 * 4)
    }

    func setBridges(_ foundBridges: [String: String]?) {
        if foundBridges != nil {
            self.bridgesFound = foundBridges!
            self.sortedBridgeKeys = self.bridgesFound.keys.sorted()
        }
        self.label.text = "Please select a Hue bridge"
        
        print(" ---> Found hue bridges: \(self.bridgesFound)")
        self.tableView.reloadData()
        
        tableHeightConstraint.constant = CGFloat(self.bridgesFound.count * 44 * 4)
        self.view.layoutIfNeeded()
    }
    
    @IBAction func performRefresh(_ sender: UIButton?) {
        self.modeHue.searchForBridgeLocal()
        self.label.text = "Searching for Hue bridges..."
    }
    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bridgesFound.count * 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TTTitleMenuCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = self.sortedBridgeKeys[(indexPath as NSIndexPath).row%self.sortedBridgeKeys.count]
        cell.detailTextLabel?.text = self.bridgesFound[self.sortedBridgeKeys[(indexPath as NSIndexPath).row%self.sortedBridgeKeys.count]]
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .gray
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bridgeId = self.sortedBridgeKeys[(indexPath as NSIndexPath).row%self.sortedBridgeKeys.count]
        let ipAddress = self.bridgesFound[bridgeId]
        
        self.modeHue.bridgeSelectedWithIpAddress(ipAddress: ipAddress!, andBridgeId: bridgeId)
    }
}
