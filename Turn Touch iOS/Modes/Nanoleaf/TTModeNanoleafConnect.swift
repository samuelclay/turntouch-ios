//
//  TTModeNanoleafConnect.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNanoleafConnect: TTOptionsDetailViewController {

    var modeNanoleaf: TTModeNanoleaf!
    @IBOutlet var progressMessage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }

    func setStoppedWithMessage(_ message: String?) {
        self.progressMessage.text = message ?? "Connect to Nanoleaf..."
    }

    @IBAction func searchForDevice(_ sender: UIButton) {
        self.progressMessage.text = "Searching for Nanoleaf..."
        self.modeNanoleaf.findDevices()
    }
}
