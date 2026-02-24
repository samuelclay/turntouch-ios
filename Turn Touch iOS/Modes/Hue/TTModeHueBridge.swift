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
    var bridgesFound: [DiscoveredBridge] = []
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    let height: CGFloat = 64

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.allowsSelection = true

        tableHeightConstraint.constant = CGFloat(self.bridgesFound.count * Int(height))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setBridges(TTModeHue.foundBridges)
    }

    override func viewDidAppear(_ animated: Bool) {
        appDelegate().mainViewController.scrollToBottom()
    }

    func setBridges(_ foundBridges: [DiscoveredBridge]) {
        self.bridgesFound = foundBridges

        self.label.text = "Please select a Hue bridge"

        print(" ---> Found hue bridges: \(self.bridgesFound)")
        self.tableView.reloadData()

        tableHeightConstraint.constant = CGFloat(self.bridgesFound.count * Int(height))
        appDelegate().mainViewController.scrollView.layoutSubviews()

        if self.bridgesFound.count == 1 {
            // Select first bridge if there's only one
            let bridge = self.bridgesFound[0]
            self.modeHue.bridgeSelected(bridge)
        }
    }

    @IBAction func performRefresh(_ sender: UIButton?) {
        self.modeHue.findBridges()
        self.label.text = "Searching for Hue bridges..."
    }

    // MARK: Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bridgesFound.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TTTitleMenuCell(style: .subtitle, reuseIdentifier: nil)

        let bridge = self.bridgesFound[(indexPath as NSIndexPath).row%self.bridgesFound.count]
        cell.textLabel?.text = "\(bridge.friendlyName ?? "Hue Bridge")"
        cell.textLabel?.font = UIFont(name: "Effra", size: 18)

        cell.detailTextLabel?.text = "\(bridge.modelName)"
        cell.detailTextLabel?.font = UIFont(name: "Effra", size: 15)

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .gray

        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bridge = self.bridgesFound[(indexPath as NSIndexPath).row%self.bridgesFound.count]

        self.modeHue.bridgeSelected(bridge)
    }
}
