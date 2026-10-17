//
//  TTModeKasaConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import UIKit

class TTModeKasaConnected: TTOptionsDetailViewController {

    var modeKasa: TTModeKasa!

    @IBOutlet var deviceCountLabel: UILabel!
    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var credentialsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false

        updateDeviceCount()
        updateCredentialsButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDeviceCount()
        updateCredentialsButton()
    }

    private func updateDeviceCount() {
        let count = TTModeKasa.foundDevices.count
        if count == 0 {
            deviceCountLabel.text = TTText("No Kasa devices found")
        } else if count == 1 {
            deviceCountLabel.text = TTText("1 Kasa device found")
        } else {
            deviceCountLabel.text = TTText("{0} Kasa devices found", count)
        }
    }

    private func updateCredentialsButton() {
        let hasKlapDevices = TTModeKasa.foundDevices.contains { $0.protocolType == .klap }
        let hasCredentials = TTModeKasa.hasCredentials()

        credentialsButton.isHidden = !hasKlapDevices

        if hasCredentials {
            credentialsButton.setTitle(TTText("Update TP-Link Credentials"), for: .normal)
        } else {
            credentialsButton.setTitle(TTText("Enter TP-Link Credentials"), for: .normal)
        }
    }

    @IBAction func refreshDevices(_ sender: UIButton) {
        modeKasa.refreshDevices()
    }

    @IBAction func enterCredentials(_ sender: UIButton) {
        let alert = UIAlertController(title: TTText("TP-Link Credentials"),
                                      message: TTText("Enter your TP-Link/Kasa cloud account credentials for newer devices"),
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = TTText("Email")
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            if let creds = TTModeKasa.loadCredentials() {
                textField.text = creds.username
            }
        }

        alert.addTextField { textField in
            textField.placeholder = TTText("Password")
            textField.isSecureTextEntry = true
            if let creds = TTModeKasa.loadCredentials() {
                textField.text = creds.password
            }
        }

        alert.addAction(UIAlertAction(title: TTText("Cancel"), style: .cancel))

        alert.addAction(UIAlertAction(title: TTText("Save"), style: .default) { [weak self] _ in
            guard let username = alert.textFields?[0].text,
                  let password = alert.textFields?[1].text,
                  !username.isEmpty, !password.isEmpty else {
                return
            }

            TTModeKasa.saveCredentials(username: username, password: password)
            self?.modeKasa.refreshDevices()
            self?.updateCredentialsButton()
        })

        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {
            topVC.present(alert, animated: true)
        }
    }
}
