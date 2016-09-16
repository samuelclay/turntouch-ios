//
//  TTModeSonosConnecting.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeSonosConnecting: TTOptionsDetailViewController {

    @IBOutlet var progressMessage: UILabel!
    @IBOutlet var cancelButton: UIButton!
    
    var modeSonos: TTModeSonos!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.clipsToBounds = true
    }
    
    func setConnectingWithMessage(_ message: String?) {
        var m = message
        if message == nil {
            m = "Connecting to Sonos..."
        }
        
        self.progressMessage.text = m
    }

    @IBAction func cancelConnect(_ sender: UIButton) {
        self.modeSonos.cancelConnectingToSonos()
    }

}
