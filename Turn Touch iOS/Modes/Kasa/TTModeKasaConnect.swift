//
//  TTModeKasaConnect.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import UIKit

class TTModeKasaConnect: TTOptionsDetailViewController {

    var modeKasa: TTModeKasa!

    @IBOutlet var searchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }

    @IBAction func searchForDevices(_ sender: UIButton) {
        modeKasa.beginConnectingToKasa()
    }
}
