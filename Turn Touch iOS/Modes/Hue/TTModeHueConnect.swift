//
//  TTModeHueConnect.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueConnect: TTOptionsDetailViewController {

    var modeHue: TTModeHue!
    @IBOutlet var progressMessage: UILabel!
    @IBOutlet var progressIndicator: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setStoppedWithMessage(message: String?) {
        var m = message
        if message == nil {
            m = "Connect to Hue..."
        }
        self.progressMessage.text = m
    }
    
    func setLoadingWithMessage(message: String?) {
        self.progressMessage.text = message
    }
    
    @IBAction func searchForBridge(sender: UIButton) {
        self.setLoadingWithMessage("Searching for Hue...")
        self.modeHue.searchForBridgeLocal()
    }
}
