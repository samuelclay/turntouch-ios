//
//  TTModeHomeKitTriggerSceneOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 9/15/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHomeKitTriggerSceneOptions: TTOptionsDetailViewController, TTModeHomeKitDelegate, UITableViewDelegate, UITableViewDataSource {

    var modeHomeKit: TTModeHomeKit!

    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    @IBOutlet var homesTable: UITableView!
    @IBOutlet var scenesTable: UITableView!
    @IBOutlet var homesNoticeLabel: UILabel!
    @IBOutlet var scenesNoticeLabel: UILabel!
    
    @IBOutlet var homesTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var scenesTableHeightConstraint: NSLayoutConstraint!
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeHomeKitTriggerSceneOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeHomeKit = self.action.mode as! TTModeHomeKit
        modeHomeKit.delegate = self
        
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })
        
        self.homesTable.rowHeight = UITableViewAutomaticDimension
        self.homesTable.estimatedRowHeight = 2
        self.homesTable.register(UITableViewCell.self, forCellReuseIdentifier: "homesCell")
        
        self.scenesTable.rowHeight = UITableViewAutomaticDimension
        self.scenesTable.estimatedRowHeight = 2
        self.scenesTable.register(UITableViewCell.self, forCellReuseIdentifier: "scenesCell")
        
        self.selectDevices()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    func changeState(_ state: TTHomeKitState, mode: TTModeHomeKit) {
        if state == .connected {
            spinner.forEach({ $0.isHidden = true })
            refreshButton.forEach({ $0.isHidden = false })
        } else if state == .connecting {
            spinner.forEach({ $0.isHidden = true })
            refreshButton.forEach({ $0.isHidden = false })
            homesNoticeLabel.text = "Searching for homes..."
        }
        
        self.selectDevices()
    }
    
    func selectDevices() {
        
    }
    
    func redrawTable() {
        self.homesTable.reloadData()
        self.homesTable.layoutIfNeeded()

        self.scenesTable.reloadData()
        self.scenesTable.layoutIfNeeded()
        
        homesTableHeightConstraint.constant = self.homesTable.contentSize.height
        scenesTableHeightConstraint.constant = self.scenesTable.contentSize.height
    }
    
    
    // MARK: TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == homesTable {
            return modeHomeKit.homeManager.homes.count
        } else if tableView == scenesTable {
            return 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = tableView == homesTable ? "homesCell" : "scenesCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.selectionStyle = .blue
        
        if tableView == homesTable {
            let home = modeHomeKit.homeManager.homes[indexPath.row]
            cell.textLabel?.text = home.name
            cell.detailTextLabel?.text = "\(home.actionSets.count) scene" + (home.actionSets.count==1 ? "":"s") + " in \(home.rooms.count) room" + (home.rooms.count==1 ? "":"s")
        } else if tableView == scenesTable {
//            cell.textLabel?.text = cellDevice.deviceName
//            cell.detailTextLabel?.text = cellDevice.location()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == homesTable {
            let home = modeHomeKit.homeManager.homes[indexPath.row]
            let cellDevice = TTModeWemo.foundDevices[indexPath.row]
            let devicesSelected = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String]
        } else if tableView == scenesTable {
            
        }
//        
//        if let devicesSelected = devicesSelected, devicesSelected.contains(cellDevice.location()) {
//            cell.accessoryType = .checkmark
//            cell.setSelected(true, animated: false)
//            self.devicesTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//        } else {
//            cell.accessoryType = .none
//            cell.setSelected(false, animated: false)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        let selectedIdentifier = TTModeWemo.foundDevices[indexPath.row].location()
        
        var devicesSelected = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String]
        if devicesSelected == nil {
            devicesSelected = [selectedIdentifier]
        } else if !devicesSelected!.contains(selectedIdentifier) {
            devicesSelected!.append(selectedIdentifier)
        }
        
        self.action.changeActionOption(TTModeWemoConstants.kWemoDeviceLocations, to: devicesSelected!)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        let selectedIdentifier = TTModeWemo.foundDevices[indexPath.row].location()
        
        var devicesSelected = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocations) as? [String]
        if devicesSelected == nil {
            devicesSelected = [selectedIdentifier]
        } else if devicesSelected!.contains(selectedIdentifier) {
            devicesSelected!.remove(at: devicesSelected!.index(of: selectedIdentifier)!)
        }
        
        self.action.changeActionOption(TTModeWemoConstants.kWemoDeviceLocations, to: devicesSelected!)
    }


}
