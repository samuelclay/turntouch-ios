//
//  TTModeIftttConnecting.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 1/3/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeIftttConnecting: TTOptionsDetailViewController {

    @IBOutlet var progressMessage: UILabel!
    @IBOutlet var cancelButton: UIButton!
    
    var modeIfttt: TTModeIfttt!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.clipsToBounds = true
    }
    
    func setConnectingWithMessage(_ message: String?) {
        var m = message
        if message == nil {
            m = "Connecting to Ifttt..."
        }
        
        self.progressMessage.text = m
    }
    
    @IBAction func cancelConnect(_ sender: UIButton) {
        self.modeIfttt.cancelConnectingToIfttt()
    }

}
