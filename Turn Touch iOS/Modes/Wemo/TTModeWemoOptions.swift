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
        
        self.changeState(TTModeWemo.wemoState, mode: self.modeWemo)
    }
    
    func changeState(_ state: TTWemoState, mode: TTModeWemo) {
        switch state {
        case .disconnected:
            self.drawConnectViewController()
        case .connecting:
            self.drawConnectingViewController()
        case .connected:
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
    
    func drawViewController(_ viewController: TTOptionsDetailViewController) {
        self.view.removeConstraints(self.view.constraints)
        self.view.addSubview(viewController.view)
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        
        self.view.layoutIfNeeded()
//        appDelegate().mainViewController.adjustOptionsHeight(nil)
    }
    
    func drawConnectViewController() {
        self.clearViewConnectrollers()
        self.connectViewController = TTModeWemoConnect(nibName: "TTModeWemoConnect", bundle: Bundle.main)
        self.connectViewController!.modeWemo = self.modeWemo
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeWemoConnecting(nibName: "TTModeWemoConnecting", bundle: Bundle.main)
        self.connectingViewController!.modeWemo = self.modeWemo
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeWemoConnected(nibName: "TTModeWemoConnected", bundle: Bundle.main)
        self.connectedViewController!.modeWemo = self.modeWemo
        self.drawViewController(self.connectedViewController!)
    }

    
}
