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
    var connectViewController: TTModeHueConnect? = TTModeHueConnect()
    var connectingViewController: TTModeHueConnecting? = TTModeHueConnecting()
    var connectedViewController: TTModeHueConnected? = TTModeHueConnected()
    var pushlinkViewController: TTModeHuePushlink? = TTModeHuePushlink()
    var bridgeViewController: TTModeHueBridge? = TTModeHueBridge()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modeHue = appDelegate().modeMap.selectedMode as! TTModeHue
        self.modeHue.delegate = self
        self.view.clipsToBounds = true

        if self.modeHue.hueState == .NotConnected {
            self.modeHue.hueState = .Connecting
        }
        self.changeState(self.modeHue.hueState, mode: self.modeHue, message: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    func changeState(hueState: TTHueState, mode: TTModeHue, message: AnyObject?) {
        print(" ---> Changing hue state: \(hueState) - \(message)")
        switch hueState {
        case .NotConnected:
            self.drawConnectViewController()
            self.connectViewController?.setStoppedWithMessage(message as? String)
        case .Connecting:
            self.drawConnectingViewController()
            self.connectingViewController?.setConnectingWithMessage(message as? String)
        case .BridgeSelect:
            self.drawBridgeViewController()
            if message != nil {
                self.modeHue.foundBridges = message as! [String: String]
            }
            self.bridgeViewController?.setBridges(self.modeHue.foundBridges)
        case .Pushlink:
            self.drawPushlinkViewController()
            self.pushlinkViewController?.setProgress(message as? Int)
        case .Connected:
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
    
    func drawViewController(viewController: TTOptionsDetailViewController) {
        self.view.removeConstraints(self.view.constraints)
        self.view.addSubview(viewController.view)
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        
        self.view.layoutIfNeeded()
        appDelegate().mainViewController.adjustOptionsHeight(nil)
    }
    
    func drawConnectViewController() {
        self.clearViewConnectrollers()
        self.connectViewController = TTModeHueConnect(nibName: "TTModeHueConnect", bundle: NSBundle.mainBundle())
        self.connectViewController!.modeHue = self.modeHue
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeHueConnecting(nibName: "TTModeHueConnecting", bundle: NSBundle.mainBundle())
        self.connectingViewController!.modeHue = self.modeHue
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeHueConnected(nibName: "TTModeHueConnected", bundle: NSBundle.mainBundle())
        self.connectedViewController!.modeHue = self.modeHue
        self.drawViewController(self.connectedViewController!)
    }
    
    func drawPushlinkViewController() {
        self.clearViewConnectrollers()
        self.pushlinkViewController = TTModeHuePushlink(nibName: "TTModeHuePushlink", bundle: NSBundle.mainBundle())
        self.pushlinkViewController!.modeHue = self.modeHue
        self.drawViewController(self.pushlinkViewController!)
    }
    
    func drawBridgeViewController() {
        self.clearViewConnectrollers()
        self.bridgeViewController = TTModeHueBridge(nibName: "TTModeHueBridge", bundle: NSBundle.mainBundle())
        self.bridgeViewController!.modeHue = self.modeHue
        self.drawViewController(self.bridgeViewController!)
    }
}
