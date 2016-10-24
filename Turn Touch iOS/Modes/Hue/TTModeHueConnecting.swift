//
//  TTModeHueConnecting.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueConnecting: TTOptionsDetailViewController {
    
    @IBOutlet var progressMessage: UILabel!
    
    var modeHue: TTModeHue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        appDelegate().mainViewController.scrollToBottom()
    }

    func setConnectingWithMessage(_ message: String?) {
        var m = message
        if message == nil {
            m = "Connecting to Hue..."
        }
        
        self.progressMessage.text = m
    }

}
