//
//  TTModeWemoConnect.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeWemoConnect: TTOptionsDetailViewController {
    
    var modeWemo: TTModeWemo!
    @IBOutlet var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func beginConnect(_ sender: UIButton) {
        self.modeWemo.beginConnectingToWemo()
    }

}
