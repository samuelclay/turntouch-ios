//
//  TTModeNestOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 1/3/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit
import NestSDK

class TTModeNestOptions: TTOptionsDetailViewController, TTModeNestDelegate {    
    
    var modeNest: TTModeNest!
    var connectViewController: TTModeNestConnect?
    var connectingViewController: TTModeNestConnecting?
    var connectedViewController: TTModeNestConnected?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modeNest = self.mode as! TTModeNest
        self.modeNest.delegate = self
        
        self.changeState(TTModeNest.nestState, mode: self.modeNest)
    }
    
    func changeState(_ state: TTNestState, mode: TTModeNest) {
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
        self.connectViewController = TTModeNestConnect(nibName: "TTModeNestConnect", bundle: Bundle.main)
        self.connectViewController!.mode = self.mode
        self.connectViewController!.modeNest = self.modeNest
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeNestConnecting(nibName: "TTModeNestConnecting", bundle: Bundle.main)
        self.connectingViewController!.mode = self.mode
        self.connectingViewController!.modeNest = self.modeNest
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeNestConnected(nibName: "TTModeNestConnected", bundle: Bundle.main)
        self.connectedViewController!.mode = self.mode
        self.connectedViewController!.modeNest = self.modeNest
        self.drawViewController(self.connectedViewController!)
    }
    
}
