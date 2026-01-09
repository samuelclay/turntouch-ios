//
//  TTModeKasaDeviceSwitchOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import UIKit

class TTModeKasaDeviceSwitchOptions: TTOptionsDetailViewController,
                                      UITableViewDelegate,
                                      UITableViewDataSource,
                                      TTModeKasaDelegate,
                                      TTTitleMenuDelegate {

    var modeKasa: TTModeKasa!
    var menuHeight: Int = 42

    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var settingsButton: [UIButton]!
    @IBOutlet var devicesTable: UITableView!
    @IBOutlet var noticeLabel: UILabel!
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        modeKasa = mode as? TTModeKasa
        modeKasa.delegate = self

        spinner.forEach { $0.isHidden = true }
        settingsButton.forEach { $0.isHidden = false }

        devicesTable.rowHeight = UITableView.automaticDimension
        devicesTable.estimatedRowHeight = 44
        devicesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        devicesTable.allowsMultipleSelection = true

        selectDevices()
    }

    func redrawTable() {
        devicesTable.reloadData()
        devicesTable.layoutIfNeeded()
        tableHeightConstraint.constant = devicesTable.contentSize.height
    }

    // MARK: - Kasa Delegate

    func changeState(_ state: TTKasaState, mode: TTModeKasa) {
        if state == .connected {
            spinner.forEach { $0.isHidden = true }
            settingsButton.forEach { $0.isHidden = false }
        }
        selectDevices()
    }

    func discoveryStatusUpdate(_ status: String) {
        // Update the notice label with discovery status
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.discoveryStatusUpdate(status)
            }
            return
        }
        noticeLabel.text = status
    }

    func selectDevices() {
        modeKasa.ensureDevicesSelected()

        if TTModeKasa.foundDevices.isEmpty {
            if TTModeKasa.kasaState == .connecting {
                noticeLabel.text = "Searching for Kasa devices..."
                noticeLabel.textColor = UIColor.darkGray
                spinner.forEach { $0.isHidden = false }
                settingsButton.forEach { $0.isHidden = true }
                spinner.forEach { $0.startAnimating() }
            } else {
                noticeLabel.text = "No Kasa devices found"
                noticeLabel.textColor = UIColor.lightGray
                spinner.forEach { $0.isHidden = true }
                settingsButton.forEach { $0.isHidden = false }
            }
            noticeLabel.isHidden = false
        } else {
            noticeLabel.isHidden = true
        }

        redrawTable()
    }

    // MARK: - Actions

    @IBAction func settings(_ sender: UIButton) {
        appDelegate().mainViewController.toggleModeOptionsMenu(sender, delegate: self)
    }

    // MARK: - Menu Delegate

    func menuOptions() -> [[String: String]] {
        var options: [[String: String]] = [
            ["title": "Search for new devices...", "image": "search"],
            ["title": "Remove all and search...", "image": "remove"]
        ]

        if TTModeKasa.foundDevices.contains(where: { $0.protocolType == .klap }) {
            options.append(["title": "Enter TP-Link credentials...", "image": "settings"])
        }

        return options
    }

    func selectMenuOption(_ row: Int) {
        switch row {
        case 0:
            refreshDevices()
        case 1:
            purgeDevices()
        case 2:
            enterCredentials()
        default:
            break
        }
        appDelegate().mainViewController.closeModeOptionsMenu()
    }

    @IBAction func refreshDevices() {
        spinner.forEach { $0.isHidden = false }
        settingsButton.forEach { $0.isHidden = true }
        spinner.forEach { $0.startAnimating() }

        modeKasa.refreshDevices()
    }

    func purgeDevices() {
        modeKasa.resetKnownDevices()
        selectDevices()
        refreshDevices()
    }

    func enterCredentials() {
        let alert = UIAlertController(title: "TP-Link Credentials",
                                      message: "Enter your TP-Link/Kasa cloud account credentials",
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            if let creds = TTModeKasa.loadCredentials() {
                textField.text = creds.username
            }
        }

        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let username = alert.textFields?[0].text,
                  let password = alert.textFields?[1].text,
                  !username.isEmpty, !password.isEmpty else {
                return
            }

            TTModeKasa.saveCredentials(username: username, password: password)
            self?.modeKasa.refreshDevices()
        })

        present(alert, animated: true)
    }

    // MARK: - TableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TTModeKasa.foundDevices.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = TTModeKasa.foundDevices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.selectionStyle = .blue

        // Device name with protocol indicator
        var name = device.deviceName ?? "Unknown Device"
        if device.protocolType == .klap {
            if device.needsAuthentication && !device.isAuthenticated {
                name += " ⚠️ (needs auth)"
            } else {
                name += " 🔐"
            }
        }
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = device.location()

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let device = TTModeKasa.foundDevices[indexPath.row]
        let selectedIds = action.optionValue(KasaConstants.kKasaSelectedSerials) as? [String] ?? []

        let deviceId = device.deviceId ?? device.macAddress ?? ""
        let isSelected = selectedIds.contains(deviceId)

        if isSelected {
            cell.accessoryType = .checkmark
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
            cell.setSelected(false, animated: false)
        }
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }

        updateSelectedDevices(tableView)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }

        updateSelectedDevices(tableView)
    }

    private func updateSelectedDevices(_ tableView: UITableView) {
        var selectedIds: [String] = []

        if let selectedPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedPaths {
                let device = TTModeKasa.foundDevices[indexPath.row]
                if let id = device.deviceId ?? device.macAddress {
                    selectedIds.append(id)
                }
            }
        }

        action.changeActionOption(KasaConstants.kKasaSelectedSerials, to: selectedIds)
    }
}
