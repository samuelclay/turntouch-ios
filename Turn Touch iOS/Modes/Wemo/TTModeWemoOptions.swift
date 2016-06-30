//
//  TTModeWemoOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeWemoOptions: TTOptionsDetailViewController, TTModeWemoDelegate {
    
    var modeWemo: TTModeWemo!
    var connectViewController: TTModeWemoConnect? = TTModeWemoConnect()
    var connectingViewController: TTModeWemoConnecting? = TTModeWemoConnecting()
    var connectedViewController: TTModeWemoConnected? = TTModeWemoConnected()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modeWemo = self.mode as! TTModeWemo
        self.modeWemo.delegate = self
        
        self.changeState(self.modeWemo.wemoState, mode: self.modeWemo)
    }
    
    func changeState(state: TTWemoState, mode: TTModeWemo) {
        switch state {
        case .Disconnected:
            self.drawConnectViewController()
        case .Connecting:
            self.drawConnectingViewController()
        case .Connected:
            self.drawConnectedViewController()
        }
    }
    
    // MARK: View connectrollers
    
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
    }
    
    func drawViewController(viewController: TTOptionsDetailViewController) {
        self.view.removeConstraints(self.view.constraints)
        self.view.addSubview(viewController.view)
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        
        self.view.layoutIfNeeded()
//        appDelegate().mainViewController.adjustOptionsHeight(nil)
    }
    
    func drawConnectViewController() {
        self.clearViewConnectrollers()
        self.connectViewController = TTModeWemoConnect(nibName: "TTModeWemoConnect", bundle: NSBundle.mainBundle())
        self.connectViewController!.modeWemo = self.modeWemo
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeWemoConnecting(nibName: "TTModeWemoConnecting", bundle: NSBundle.mainBundle())
        self.connectingViewController!.modeWemo = self.modeWemo
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeWemoConnected(nibName: "TTModeWemoConnected", bundle: NSBundle.mainBundle())
        self.connectedViewController!.modeWemo = self.modeWemo
        self.drawViewController(self.connectedViewController!)
    }

    
}
