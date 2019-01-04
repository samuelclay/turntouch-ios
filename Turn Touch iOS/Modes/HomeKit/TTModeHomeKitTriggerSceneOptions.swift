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
        
        self.homesTable.rowHeight = UITableView.automaticDimension
        self.homesTable.estimatedRowHeight = 2
        self.homesTable.register(UITableViewCell.self, forCellReuseIdentifier: "homesCell")
        
        self.scenesTable.rowHeight = UITableView.automaticDimension
        self.scenesTable.estimatedRowHeight = 2
        self.scenesTable.register(UITableViewCell.self, forCellReuseIdentifier: "scenesCell")
        
        self.selectDevices()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    @IBAction func refresh(_ sender: UIButton) {
        spinner.forEach({ $0.isHidden = false })
        spinner.forEach { $0.startAnimating() }
        refreshButton.forEach({ $0.isHidden = true })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.modeHomeKit.activate()
        }
    }
    
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
        modeHomeKit.ensureHomeSelected()
        modeHomeKit.ensureSceneSelected()
        
        self.redrawTable()
        
        appDelegate().mainViewController.actionDiamondView.redraw()
        appDelegate().mainViewController.actionTitleView.setNeedsDisplay()
    }
    
    func redrawTable() {
        self.homesTable.reloadData()
        self.homesTable.layoutIfNeeded()

        self.scenesTable.reloadData()
        self.scenesTable.layoutIfNeeded()
        
        homesTableHeightConstraint.constant = max(44, self.homesTable.contentSize.height)
        scenesTableHeightConstraint.constant = max(44, self.scenesTable.contentSize.height)
    }
    
    
    // MARK: TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == homesTable {
            return modeHomeKit.homeManager.homes.count
        } else if tableView == scenesTable {
            if let home = modeHomeKit.selectedHome() {
                let scenes = home.actionSets
                if scenes.count > 0 {
                    return scenes.count
                } else {
                    scenesNoticeLabel.text = "No scenes found..."
                    return 0
                }
            } else {
                scenesNoticeLabel.text = ""
                return 0
            }
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
            if let home = modeHomeKit.selectedHome() {
                let scene = home.actionSets[indexPath.row]
                cell.textLabel?.text = scene.name
                cell.detailTextLabel?.text = "\(scene.actions.count) actions" + (scene.actions.count==1 ? "":"s")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == homesTable {
            let home = modeHomeKit.homeManager.homes[indexPath.row]
            let homeSelected = self.action.optionValue(TTModeHomeKitConstants.kHomeKitHomeIdentifier) as? String
            
            if homeSelected == home.uniqueIdentifier.uuidString {
                cell.accessoryType = .checkmark
                cell.setSelected(true, animated: false)
                self.homesTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                cell.accessoryType = .none
                cell.setSelected(false, animated: false)
            }
        } else if tableView == scenesTable {
            if let home = modeHomeKit.selectedHome() {
                let sceneSelected = self.action.optionValue(TTModeHomeKitConstants.kHomeKitSceneIdentifier) as? String
                let scene = home.actionSets[indexPath.row]
                
                if sceneSelected == scene.uniqueIdentifier.uuidString {
                    cell.accessoryType = .checkmark
                    cell.setSelected(true, animated: false)
                    self.scenesTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                } else {
                    cell.accessoryType = .none
                    cell.setSelected(false, animated: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        if tableView == homesTable {
            let selectedIdentifier = modeHomeKit.homeManager.homes[indexPath.row].uniqueIdentifier.uuidString

            self.action.changeActionOption(TTModeHomeKitConstants.kHomeKitHomeIdentifier, to: selectedIdentifier)
            self.selectDevices()
        } else if tableView == scenesTable {
            if let home = modeHomeKit.selectedHome() {
                let selectedIdentifier = home.actionSets[indexPath.row].uniqueIdentifier.uuidString
                
                self.action.changeActionOption(TTModeHomeKitConstants.kHomeKitSceneIdentifier, to: selectedIdentifier)
                self.selectDevices()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectDevices()
    }
    
}
