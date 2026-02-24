//
//  TTModeNanoleafOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNanoleafOptions: TTOptionsDetailViewController, TTModeNanoleafDelegate {

    var modeNanoleaf: TTModeNanoleaf!
    var connectViewController: TTModeNanoleafConnect?
    var connectingViewController: TTModeNanoleafConnecting?
    var connectedViewController: TTModeNanoleafConnected?
    var pushlinkViewController: TTModeNanoleafPushlink?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.modeNanoleaf = (self.mode as! TTModeNanoleaf)
        TTModeNanoleaf.delegates.add(delegate: self)
        self.view.clipsToBounds = true

        if TTModeNanoleaf.nanoleafState == .notConnected {
            self.modeNanoleaf.connectToDevice(reset: true)
        } else {
            self.changeState(TTModeNanoleaf.nanoleafState, mode: self.modeNanoleaf, message: nil)
        }
    }

    func changeState(_ state: TTNanoleafState, mode: TTModeNanoleaf, message: Any?) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.changeState(state, mode: mode, message: message)
            }
            return
        }

        print(" ---> Changing nanoleaf state: \(state) - \(message ?? "")")

        switch state {
        case .notConnected:
            self.drawConnectViewController()
            self.connectViewController?.setStoppedWithMessage(message as? String)
        case .connecting:
            self.drawConnectingViewController()
            self.connectingViewController?.setConnectingWithMessage(message as? String)
        case .pushlink:
            self.drawPushlinkViewController()
            self.pushlinkViewController?.setProgress(message as? Int)
        case .connected:
            self.drawConnectedViewController()
        }
    }

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
        if self.pushlinkViewController != nil {
            self.pushlinkViewController!.view.removeFromSuperview()
            self.pushlinkViewController = nil
        }
    }

    func drawViewController(_ viewController: TTOptionsDetailViewController) {
        self.view.removeConstraints(self.view.constraints)
        self.view.addSubview(viewController.view)

        guard let view = viewController.view else {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0))

        self.view.layoutIfNeeded()
        appDelegate().mainViewController.adjustOptionsHeight(view)
    }

    func drawConnectViewController() {
        self.clearViewControllers()
        self.connectViewController = TTModeNanoleafConnect(nibName: "TTModeNanoleafConnect", bundle: Bundle.main)
        self.connectViewController!.modeNanoleaf = self.modeNanoleaf
        self.drawViewController(self.connectViewController!)
    }

    func drawConnectingViewController() {
        self.clearViewControllers()
        self.connectingViewController = TTModeNanoleafConnecting(nibName: "TTModeNanoleafConnecting", bundle: Bundle.main)
        self.connectingViewController!.modeNanoleaf = self.modeNanoleaf
        self.drawViewController(self.connectingViewController!)
    }

    func drawConnectedViewController() {
        self.clearViewControllers()
        self.connectedViewController = TTModeNanoleafConnected(nibName: "TTModeNanoleafConnected", bundle: Bundle.main)
        self.connectedViewController!.modeNanoleaf = self.modeNanoleaf
        self.drawViewController(self.connectedViewController!)
    }

    func drawPushlinkViewController() {
        self.clearViewControllers()
        self.pushlinkViewController = TTModeNanoleafPushlink(nibName: "TTModeNanoleafPushlink", bundle: Bundle.main)
        self.pushlinkViewController!.modeNanoleaf = self.modeNanoleaf
        self.drawViewController(self.pushlinkViewController!)
    }
}
