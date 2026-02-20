//
//  TTModeGoveeConnecting.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeGoveeConnecting: TTOptionsDetailViewController {

    var modeGovee: TTModeGovee!

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false

        spinner.startAnimating()
        updateStatus("Fetching Govee devices...")
    }

    func updateStatus(_ status: String) {
        statusLabel?.text = status
        NSLog(" ---> GoveeConnecting: \(status)")
    }

    @IBAction func cancelFetch(_ sender: UIButton) {
        modeGovee.cancelConnectingToGovee()
    }
}
