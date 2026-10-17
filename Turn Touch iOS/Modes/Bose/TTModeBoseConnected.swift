//
//  TTModeBoseConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeBoseConnected: TTOptionsDetailViewController {
    
    var modeBose: TTModeBose!
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
        
        let count = TTModeBose.foundDevices.count
        let deviceCount = count == 1 ? "speaker" : "speakers"
        if count > 0 {
            connectedLabel.text = TTText("Connected to {0} Bose {1}", count, deviceCount)
        } else {
            connectedLabel.text = TTText("No Bose speakers found")
        }
    }
    
    @IBAction func scanForDevices(sender: UIButton) {
        modeBose.beginConnectingToBose()
    }
}
