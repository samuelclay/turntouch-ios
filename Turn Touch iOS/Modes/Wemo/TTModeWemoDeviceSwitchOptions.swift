//
//  TTModeWemoSwitchOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeWemoDeviceSwitchOptions: TTOptionsDetailViewController, UITableViewDelegate, UITableViewDataSource, TTModeWemoDelegate {
    
    var modeWemo: TTModeWemo!
    
    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var settingsButton: [UIButton]!
    @IBOutlet var devicesTable: UITableView!
    @IBOutlet var noticeLabel: UILabel!
    
    var devices: [[String: String]] = []
    var selectedDevices: [String] = []
    
    @IBOutlet var tableHeightConstaint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modeWemo = self.mode as! TTModeWemo
        self.modeWemo.delegate = self
        
        spinner.forEach({ $0.isHidden = true })
        settingsButton.forEach({ $0.isHidden = false })
        
        self.devicesTable.rowHeight = UITableViewAutomaticDimension
        self.devicesTable.estimatedRowHeight = 2
        
        self.selectDevices()
        
        self.devicesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.devicesTable.layoutIfNeeded()
        tableHeightConstaint.constant = self.devicesTable.contentSize.height
    }
    
    func selectDevices() {
        devices = []
        _ = self.modeWemo.selectedDevices(self.action.direction)
        let devicesSelected = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String]
        
        for device in TTModeWemo.foundDevices {
            devices.append(["name": device.deviceName, "identifier": device.location()])
            if let devicesSelected = devicesSelected,
                devicesSelected.contains(device.location()) {
                selectedDevices.append(device.location())
            }
        }
        
        if devices.count == 0 {
            noticeLabel.isHidden = false
            noticeLabel.text = "No WeMo devices found"
            noticeLabel.textColor = UIColor.lightGray
        } else {
            noticeLabel.isHidden = true
        }
    }
    
    @IBAction func refreshDevices(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        settingsButton.forEach({ $0.isHidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }
        
        if devices.count == 0 {
            noticeLabel.isHidden = false
            noticeLabel.text = "Searching for WeMo devices..."
            noticeLabel.textColor = UIColor.darkGray
        }

        self.modeWemo.refreshDevices()
    }
    
    func changeState(_ state: TTWemoState, mode: TTModeWemo) {
        if state == .connected {
            spinner.forEach({ $0.isHidden = true })
            settingsButton.forEach({ $0.isHidden = false })
        }
        self.selectDevices()
    }
    
    // MARK: TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDevice = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .blue
        
        cell.textLabel?.text = cellDevice["name"]!
        cell.detailTextLabel?.text = cellDevice["identifier"]!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellDevice = devices[indexPath.row]
        
        if selectedDevices.contains(cellDevice["identifier"]!) {
            cell.accessoryType = .checkmark
            cell.setSelected(true, animated: false)
            self.devicesTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
            cell.setSelected(false, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        let selectedIdentifier = devices[indexPath.row]["identifier"]!
        
        var locations = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String]
        if locations == nil {
            locations = [selectedIdentifier]
        } else if !locations!.contains(selectedIdentifier) {
            locations!.append(selectedIdentifier)
        }
        
        self.action.changeActionOption(TTModeWemoConstants.kWemoDeviceLocations, to: locations!)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        let selectedIdentifier = devices[indexPath.row]["identifier"]!
        
        var locations = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String]
        if locations == nil {
            locations = [selectedIdentifier]
        } else if locations!.contains(selectedIdentifier) {
            locations!.remove(at: locations!.index(of: selectedIdentifier)!)
        }
        
        self.action.changeActionOption(TTModeWemoConstants.kWemoDeviceLocations, to: locations!)
    }
    
}
