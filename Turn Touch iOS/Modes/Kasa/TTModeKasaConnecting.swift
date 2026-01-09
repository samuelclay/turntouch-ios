//
//  TTModeKasaConnecting.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import UIKit

class TTModeKasaConnecting: TTOptionsDetailViewController {

    var modeKasa: TTModeKasa!

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false

        spinner.startAnimating()
        updateStatus("Starting discovery...")
    }

    func updateStatus(_ status: String) {
        statusLabel?.text = status
        NSLog(" ---> KasaConnecting: \(status)")
    }

    @IBAction func cancelSearch(_ sender: UIButton) {
        modeKasa.cancelConnectingToKasa()
    }
}
