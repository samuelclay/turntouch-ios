//
//  TTModeHueOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import SwiftyHue

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

        if TTModeHue.hueState == .notConnected {
            TTModeHue.hueState = .connecting
        }
        self.changeState(TTModeHue.hueState, mode: self.modeHue, message: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func changeState(_ hueState: TTHueState, mode: TTModeHue, message: Any?) {
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
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1.0, constant: 0))
        
        self.view.layoutIfNeeded()
        appDelegate().mainViewController.adjustOptionsHeight(nil)
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
