//
//  TTModeHueCycleScenesOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 8/10/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueCycleScenesOptions: TTModeHuePicker, UITableViewDelegate, UITableViewDataSource {

    var modeHue: TTModeHue!
    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    @IBOutlet var scenesTable: UITableView!

    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeHueCycleScenesOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        modeHue = self.mode as! TTModeHue

        self.scenesTable.rowHeight = UITableViewAutomaticDimension
        self.scenesTable.estimatedRowHeight = 2
        self.scenesTable.register(UITableViewCell.self, forCellReuseIdentifier: "sceneCell")

        super.viewDidLoad()

        self.drawScenes()
    }
    
    override func drawScenes() {
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })

        super.drawScenes()
        
        if scenes.count == 0 {
            return
        }
        
        self.redrawTable()
    }

    func redrawTable() {
        self.scenesTable.reloadData()
        self.scenesTable.layoutIfNeeded()
        tableHeightConstraint.constant = self.scenesTable.contentSize.height
    }

    @IBAction func refreshScenes(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        refreshButton.forEach({ $0.isHidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }
        
        modeHue = self.mode as! TTModeHue
        
        modeHue.updateScenes()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.drawScenes()
        }
    }
    
    
    // MARK: TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellScene = scenes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "sceneCell", for: indexPath)
        cell.selectionStyle = .blue
        
        cell.textLabel?.text = cellScene["name"]
        cell.detailTextLabel?.text = cellScene["identifier"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellScene = scenes[indexPath.row]
        let scenesSelected = self.action.optionValue(TTModeHueConstants.kCycleScenes) as? [String]
        let sceneIdentifier = cellScene["identifier"]!
        
        if let scenesSelected = scenesSelected, scenesSelected.contains(sceneIdentifier) {
            cell.accessoryType = .checkmark
            cell.setSelected(true, animated: false)
            self.scenesTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
            cell.setSelected(false, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        var selectedCycleScenes: [String] = []
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        
        if let selectedIdentifier = scenes[indexPath.row]["identifier"] {
            if let scenesSelected = self.action.optionValue(TTModeHueConstants.kCycleScenes) as? [String] {
                for scene in scenesSelected {
                    if scene != selectedIdentifier {
                        selectedCycleScenes.append(scene)
                    }
                }
            }
            selectedCycleScenes.append(selectedIdentifier)
        }
        
        self.action.changeActionOption(TTModeHueConstants.kCycleScenes, to: selectedCycleScenes)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")
        var selectedCycleScenes: [String] = []
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        
        if let selectedIdentifier = scenes[indexPath.row]["identifier"],
            let scenesSelected = self.action.optionValue(TTModeHueConstants.kCycleScenes) as? [String] {
            for scene in scenesSelected {
                if scene != selectedIdentifier {
                    selectedCycleScenes.append(scene)
                }
            }
            
        }
        
        self.action.changeActionOption(TTModeHueConstants.kCycleScenes, to: selectedCycleScenes)
    }
    
}
