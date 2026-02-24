//
//  TTModeGoveeConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeGoveeConnected: TTOptionsDetailViewController {

    var modeGovee: TTModeGovee!

    @IBOutlet var deviceCountLabel: UILabel!
    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var apiKeyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false

        updateDeviceCount()
        updateApiKeyButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDeviceCount()
        updateApiKeyButton()
    }

    private func updateDeviceCount() {
        let count = TTModeGovee.foundDevices.count
        if count == 0 {
            deviceCountLabel.text = "No Govee devices found"
        } else if count == 1 {
            deviceCountLabel.text = "1 Govee device found"
        } else {
            deviceCountLabel.text = "\(count) Govee devices found"
        }
    }

    private func updateApiKeyButton() {
        if TTModeGovee.hasApiKey() {
            apiKeyButton.setTitle("Update API Key", for: .normal)
        } else {
            apiKeyButton.setTitle("Enter API Key", for: .normal)
        }
    }

    @IBAction func refreshDevices(_ sender: UIButton) {
        modeGovee.refreshDevices()
    }

    @IBAction func changeApiKey(_ sender: UIButton) {
        let alert = UIAlertController(title: "Govee API Key",
                                      message: "Enter your Govee API key (from Govee Home App > Settings > My Profile > Apply for API Key)",
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "API Key"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            if let key = TTModeGovee.loadApiKey() {
                textField.text = key
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let apiKey = alert.textFields?[0].text,
                  !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            let trimmedKey = apiKey.trimmingCharacters(in: .whitespaces)
            TTModeGovee.saveApiKey(trimmedKey)
            TTModeGovee.apiClient.setApiKey(trimmedKey)
            self?.modeGovee.refreshDevices()
            self?.updateApiKeyButton()
        })

        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {
            topVC.present(alert, animated: true)
        }
    }
}
