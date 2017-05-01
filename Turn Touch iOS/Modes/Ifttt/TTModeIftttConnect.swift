//
//  TTModeIftttConnect.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 1/3/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeIftttConnect: TTOptionsDetailViewController {
    
    var modeIfttt: TTModeIfttt!
    @IBOutlet var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func beginConnect(_ sender: UIButton) {
        self.modeIfttt.beginConnectingToIfttt()
    }

}
