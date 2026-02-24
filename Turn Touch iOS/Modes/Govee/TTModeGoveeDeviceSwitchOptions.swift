//
//  TTModeGoveeDeviceSwitchOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeGoveeDeviceSwitchOptions: TTOptionsDetailViewController,
                                      UITableViewDelegate,
                                      UITableViewDataSource,
                                      TTModeGoveeDelegate,
                                      TTTitleMenuDelegate {

    var modeGovee: TTModeGovee!
    var menuHeight: Int = 42

    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var settingsButton: [UIButton]!
    @IBOutlet var devicesTable: UITableView!
    @IBOutlet var noticeLabel: UILabel!
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        modeGovee = mode as? TTModeGovee
        modeGovee.delegate = self

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

    // MARK: - Govee Delegate

    func changeState(_ state: TTGoveeState, mode: TTModeGovee) {
        if state == .connected {
            spinner.forEach { $0.isHidden = true }
            settingsButton.forEach { $0.isHidden = false }
        }
        selectDevices()
    }

    func fetchStatusUpdate(_ status: String) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.fetchStatusUpdate(status)
            }
            return
        }
        noticeLabel.text = status
    }

    func selectDevices() {
        modeGovee.ensureDevicesSelected()

        if TTModeGovee.foundDevices.isEmpty {
            if TTModeGovee.goveeState == .connecting {
                noticeLabel.text = "Fetching Govee devices..."
                noticeLabel.textColor = UIColor.darkGray
                spinner.forEach { $0.isHidden = false }
                settingsButton.forEach { $0.isHidden = true }
                spinner.forEach { $0.startAnimating() }
            } else {
                noticeLabel.text = "No Govee devices found"
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
        return [
            ["title": "Refresh devices...", "image": "search"],
            ["title": "Remove all and refresh...", "image": "remove"],
            ["title": "Change API key...", "image": "settings"]
        ]
    }

    func selectMenuOption(_ row: Int) {
        switch row {
        case 0:
            refreshDevices()
        case 1:
            purgeDevices()
        case 2:
            changeApiKey()
        default:
            break
        }
        appDelegate().mainViewController.closeModeOptionsMenu()
    }

    @IBAction func refreshDevices() {
        spinner.forEach { $0.isHidden = false }
        settingsButton.forEach { $0.isHidden = true }
        spinner.forEach { $0.startAnimating() }

        modeGovee.refreshDevices()
    }

    func purgeDevices() {
        modeGovee.resetKnownDevices()
        selectDevices()
        refreshDevices()
    }

    func changeApiKey() {
        let alert = UIAlertController(title: "Govee API Key",
                                      message: "Enter your Govee API key",
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "API Key"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            if let key = TTModeGovee.loadApiKey() {
                textField.text = key
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let apiKey = alert.textFields?[0].text,
                  !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            let trimmedKey = apiKey.trimmingCharacters(in: .whitespaces)
            TTModeGovee.saveApiKey(trimmedKey)
            TTModeGovee.apiClient.setApiKey(trimmedKey)
            self?.modeGovee.refreshDevices()
        })

        present(alert, animated: true)
    }

    // MARK: - TableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TTModeGovee.foundDevices.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = TTModeGovee.foundDevices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.selectionStyle = .blue
        cell.textLabel?.text = device.deviceName
        cell.detailTextLabel?.text = device.sku

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let device = TTModeGovee.foundDevices[indexPath.row]
        let selectedIds = action.optionValue(GoveeConstants.kGoveeSelectedDevices) as? [String] ?? []

        let isSelected = selectedIds.contains(device.deviceId)

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
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        updateSelectedDevices(tableView)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        updateSelectedDevices(tableView)
    }

    private func updateSelectedDevices(_ tableView: UITableView) {
        var selectedIds: [String] = []

        if let selectedPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedPaths {
                let device = TTModeGovee.foundDevices[indexPath.row]
                selectedIds.append(device.deviceId)
            }
        }

        action.changeActionOption(GoveeConstants.kGoveeSelectedDevices, to: selectedIds)
    }
}
