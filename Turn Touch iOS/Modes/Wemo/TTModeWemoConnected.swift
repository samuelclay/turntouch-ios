//
//  TTModeWemoConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeWemoConnected: TTOptionsDetailViewController {
    
    var modeWemo: TTModeWemo!
    @IBOutlet var connectedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.updateConnected()
    }
    
    func updateConnected(message: String? = nil) {
        if message != nil {
            connectedLabel.text = message
            return
        }
        
        let count = TTModeWemo.foundDevices.count
        let deviceCount = count == 1 ? "device" : "devices"
        if count > 0 {
            connectedLabel.text = "Connected to \(count) Wemo \(deviceCount)"
        } else {
            connectedLabel.text = "No Wemo devices found"
        }
    }
    
    @IBAction func scanForDevices(sender: UIButton) {
        modeWemo.beginConnectingToWemo()
    }
}
