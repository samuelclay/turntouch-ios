//
//  TTModeHueConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueConnected: TTOptionsDetailViewController {
    
    var modeHue: TTModeHue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Do any additional setup after loading the view.
    }

    @IBAction func selectOtherBridge(_ sender: UIButton) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: TTModeHueConstants.kHueRecentBridgeIp)
        prefs.removeObject(forKey: TTModeHueConstants.kHueRecentBridgeId)
        prefs.synchronize()
        
        self.modeHue.searchForBridgeLocal()
    }

}
