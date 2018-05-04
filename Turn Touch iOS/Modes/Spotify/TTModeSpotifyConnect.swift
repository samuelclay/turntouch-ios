//
//  TTModeSpotifyConnect.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeSpotifyConnect: TTOptionsDetailViewController {
    
    var modeSpotify: TTModeSpotify!
    @IBOutlet var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func beginConnect(_ sender: UIButton) {
        self.modeSpotify.beginConnectingToSpotify(ensureConnection: true)
    }

}
