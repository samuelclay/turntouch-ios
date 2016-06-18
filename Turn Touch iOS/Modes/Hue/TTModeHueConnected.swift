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

    @IBAction func selectOtherBridge(sender: UIButton) {
        self.modeHue.searchForBridgeLocal()
    }

}
