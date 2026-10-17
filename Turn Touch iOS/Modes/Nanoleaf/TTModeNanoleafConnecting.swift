//
//  TTModeNanoleafConnecting.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNanoleafConnecting: TTOptionsDetailViewController {

    var modeNanoleaf: TTModeNanoleaf!
    @IBOutlet var progressMessage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }

    func setConnectingWithMessage(_ message: String?) {
        self.progressMessage.text = message ?? TTText("Connecting to Nanoleaf...")
    }
}
