//
//  TTModeGoveeOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeGoveeOptions: TTOptionsDetailViewController, TTModeGoveeDelegate {

    var modeGovee: TTModeGovee!
    var connectViewController: TTModeGoveeConnect?
    var connectingViewController: TTModeGoveeConnecting?
    var connectedViewController: TTModeGoveeConnected?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog(" ---> GoveeOptions: viewDidLoad, mode = \(String(describing: mode))")

        self.modeGovee = (self.mode as! TTModeGovee)
        self.modeGovee.delegate = self
        self.view.clipsToBounds = true

        NSLog(" ---> GoveeOptions: delegate set, goveeState = \(TTModeGovee.goveeState)")

        self.changeState(TTModeGovee.goveeState, mode: self.modeGovee)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NSLog(" ---> GoveeOptions: viewWillAppear, goveeState = \(TTModeGovee.goveeState)")
        self.changeState(TTModeGovee.goveeState, mode: self.modeGovee)
    }

    // MARK: - State Changes

    func changeState(_ state: TTGoveeState, mode: TTModeGovee) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.changeState(state, mode: mode)
            }
            return
        }

        NSLog(" ---> GoveeOptions: changeState to \(state)")

        switch state {
        case .disconnected:
            NSLog(" ---> GoveeOptions: showing disconnected view")
            self.drawConnectViewController()
        case .connecting:
            NSLog(" ---> GoveeOptions: showing connecting view")
            self.drawConnectingViewController()
        case .connected:
            NSLog(" ---> GoveeOptions: showing connected view, devices = \(TTModeGovee.foundDevices.count)")
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
            NSLog(" ---> GoveeOptions: ERROR - view controller view is nil")
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))

        self.view.layoutIfNeeded()
    }

    func drawConnectViewController() {
        self.clearViewControllers()
        self.connectViewController = TTModeGoveeConnect(nibName: "TTModeGoveeConnect", bundle: Bundle.main)
        self.connectViewController!.modeGovee = self.modeGovee
        self.drawViewController(self.connectViewController!)
    }

    func drawConnectingViewController() {
        self.clearViewControllers()
        self.connectingViewController = TTModeGoveeConnecting(nibName: "TTModeGoveeConnecting", bundle: Bundle.main)
        self.connectingViewController!.modeGovee = self.modeGovee
        self.drawViewController(self.connectingViewController!)
    }

    func drawConnectedViewController() {
        self.clearViewControllers()
        self.connectedViewController = TTModeGoveeConnected(nibName: "TTModeGoveeConnected", bundle: Bundle.main)
        self.connectedViewController!.modeGovee = self.modeGovee
        self.drawViewController(self.connectedViewController!)
    }

    // MARK: - Fetch Status

    func fetchStatusUpdate(_ status: String) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.fetchStatusUpdate(status)
            }
            return
        }

        NSLog(" ---> GoveeOptions: fetchStatusUpdate: \(status)")
        self.connectingViewController?.updateStatus(status)
    }
}
