//
//  TTModeGoveeConnect.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeGoveeConnect: TTOptionsDetailViewController {

    var modeGovee: TTModeGovee!

    @IBOutlet var apiKeyField: UITextField!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var instructionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false

        if let existingKey = TTModeGovee.loadApiKey() {
            apiKeyField.text = existingKey
        }
    }

    @IBAction func connectToGovee(_ sender: UIButton) {
        guard let apiKey = apiKeyField.text, !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        TTModeGovee.saveApiKey(apiKey.trimmingCharacters(in: .whitespaces))
        TTModeGovee.apiClient.setApiKey(apiKey.trimmingCharacters(in: .whitespaces))
        modeGovee.beginConnectingToGovee()
    }
}
