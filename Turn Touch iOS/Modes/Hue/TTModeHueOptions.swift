//
//  TTModeHueOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueOptions: TTOptionsDetailViewController, TTModeHueDelegate {
    
    var modeHue: TTModeHue!
    var connectViewController: TTModeHueConnect?
    var connectingViewController: TTModeHueConnecting?
    var connectedViewController: TTModeHueConnected?
    var pushlinkViewController: TTModeHuePushlink?
    var bridgeViewController: TTModeHueBridge?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modeHue = (self.mode as! TTModeHue)
        TTModeHue.delegates.add(delegate: self)
        self.view.clipsToBounds = true

        // Must call here, not in viewWillAppear - these VCs aren't added via addChild
        // so viewWillAppear is never called
        if TTModeHue.hueState == .notConnected {
            // Actually start the connection process - don't just set the state
            self.modeHue.connectToBridge(reset: true)
        } else {
            self.changeState(TTModeHue.hueState, mode: self.modeHue, message: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func changeState(_ hueState: TTHueState, mode: TTModeHue, message: Any?) {
        // Ensure UI updates happen on main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.changeState(hueState, mode: mode, message: message)
            }
            return
        }

        print(" ---> Changing hue state: \(hueState) - \(message ?? "")")

        switch hueState {
        case .notConnected:
            self.drawConnectViewController()
            self.connectViewController?.setStoppedWithMessage(message as? String)
        case .connecting:
            self.drawConnectingViewController()
            self.connectingViewController?.setConnectingWithMessage(message as? String)
        case .bridgeSelect:
            self.drawBridgeViewController()
        case .pushlink:
            self.drawPushlinkViewController()
            self.pushlinkViewController?.setProgress(message as? Int)
        case .connected:
            self.drawConnectedViewController()
        }
    }
    
    func clearViewConnectrollers() {
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
        if self.bridgeViewController != nil {
            self.bridgeViewController!.view.removeFromSuperview()
            self.bridgeViewController = nil
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
        self.clearViewConnectrollers()
        self.connectViewController = TTModeHueConnect(nibName: "TTModeHueConnect", bundle: Bundle.main)
        self.connectViewController!.modeHue = self.modeHue
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeHueConnecting(nibName: "TTModeHueConnecting", bundle: Bundle.main)
        self.connectingViewController!.modeHue = self.modeHue
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeHueConnected(nibName: "TTModeHueConnected", bundle: Bundle.main)
        self.connectedViewController!.modeHue = self.modeHue
        self.drawViewController(self.connectedViewController!)
    }
    
    func drawPushlinkViewController() {
        self.clearViewConnectrollers()
        self.pushlinkViewController = TTModeHuePushlink(nibName: "TTModeHuePushlink", bundle: Bundle.main)
        self.pushlinkViewController!.modeHue = self.modeHue
        self.drawViewController(self.pushlinkViewController!)
    }
    
    func drawBridgeViewController() {
        self.clearViewConnectrollers()
        self.bridgeViewController = TTModeHueBridge(nibName: "TTModeHueBridge", bundle: Bundle.main)
        self.bridgeViewController!.modeHue = self.modeHue
        self.drawViewController(self.bridgeViewController!)
    }
}
