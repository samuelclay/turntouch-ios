//
//  TTModeNanoleafPushlink.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNanoleafPushlink: TTOptionsDetailViewController {

    var modeNanoleaf: TTModeNanoleaf!
    @IBOutlet var deviceNameLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.text = TTModeNanoleaf.deviceName ?? "Nanoleaf"
    }

    override func viewDidAppear(_ animated: Bool) {
        appDelegate().mainViewController.scrollToBottom()
    }

    func setProgress(_ progressPercentage: Int?) {
        if progressPercentage != nil {
            self.progressView.setProgress(Float(progressPercentage!) / 100, animated: false)
        }
    }
}
