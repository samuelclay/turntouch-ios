//
//  TTModeKasaOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import UIKit

class TTModeKasaOptions: TTOptionsDetailViewController, TTModeKasaDelegate {

    var modeKasa: TTModeKasa!
    var connectViewController: TTModeKasaConnect?
    var connectingViewController: TTModeKasaConnecting?
    var connectedViewController: TTModeKasaConnected?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog(" ---> KasaOptions: viewDidLoad, mode = \(String(describing: mode))")

        self.modeKasa = (self.mode as! TTModeKasa)
        self.modeKasa.delegate = self
        self.view.clipsToBounds = true

        NSLog(" ---> KasaOptions: delegate set, kasaState = \(TTModeKasa.kasaState)")

        // Show the appropriate view immediately
        self.changeState(TTModeKasa.kasaState, mode: self.modeKasa)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NSLog(" ---> KasaOptions: viewWillAppear, kasaState = \(TTModeKasa.kasaState)")
        // Refresh the view in case state changed
        self.changeState(TTModeKasa.kasaState, mode: self.modeKasa)
    }

    // MARK: - State Changes

    func changeState(_ state: TTKasaState, mode: TTModeKasa) {
        // Ensure UI updates happen on main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.changeState(state, mode: mode)
            }
            return
        }

        NSLog(" ---> KasaOptions: changeState to \(state)")

        switch state {
        case .disconnected:
            NSLog(" ---> KasaOptions: showing disconnected view")
            self.drawConnectViewController()
        case .connecting:
            NSLog(" ---> KasaOptions: showing connecting view")
            self.drawConnectingViewController()
        case .connected:
            NSLog(" ---> KasaOptions: showing connected view, devices = \(TTModeKasa.foundDevices.count)")
            self.drawConnectedViewController()
        }
    }

    // MARK: - View Controllers

    func clearViewControllers() {
        if self.connectViewController != nil {
            self.connectViewController!.view.removeFromSuperview()
            self.connectViewController = nil
        }
        if self.connectingViewController != nil {
            self.connectingViewController!.view.removeFromSuperview()
            self.connectingViewController = nil
        }
        if self.connectedViewController != nil {
            self.connectedViewController!.view.removeFromSuperview()
            self.connectedViewController = nil
        }
    }

    func drawViewController(_ viewController: TTOptionsDetailViewController) {
        self.view.removeConstraints(self.view.constraints)
        self.view.addSubview(viewController.view)

        guard let view = viewController.view else {
            NSLog(" ---> KasaOptions: ERROR - view controller view is nil")
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1.0, constant: 0))

        self.view.layoutIfNeeded()
//        appDelegate().mainViewController.adjustOptionsHeight(nil)
    }

    func drawConnectViewController() {
        self.clearViewControllers()
        self.connectViewController = TTModeKasaConnect(nibName: "TTModeKasaConnect", bundle: Bundle.main)
        self.connectViewController!.modeKasa = self.modeKasa
        self.drawViewController(self.connectViewController!)
    }

    func drawConnectingViewController() {
        self.clearViewControllers()
        self.connectingViewController = TTModeKasaConnecting(nibName: "TTModeKasaConnecting", bundle: Bundle.main)
        self.connectingViewController!.modeKasa = self.modeKasa
        self.drawViewController(self.connectingViewController!)
    }

    func drawConnectedViewController() {
        self.clearViewControllers()
        self.connectedViewController = TTModeKasaConnected(nibName: "TTModeKasaConnected", bundle: Bundle.main)
        self.connectedViewController!.modeKasa = self.modeKasa
        self.drawViewController(self.connectedViewController!)
    }

    // MARK: - Discovery Status

    func discoveryStatusUpdate(_ status: String) {
        // Ensure UI updates happen on main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.discoveryStatusUpdate(status)
            }
            return
        }

        NSLog(" ---> KasaOptions: discoveryStatusUpdate: \(status)")
        self.connectingViewController?.updateStatus(status)
    }
}
