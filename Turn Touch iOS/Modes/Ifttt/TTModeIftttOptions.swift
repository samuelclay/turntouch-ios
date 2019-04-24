//
//  TTModeIftttOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 1/3/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeIftttOptions: TTOptionsDetailViewController, TTModeIftttDelegate {    
    
    var modeIfttt: TTModeIfttt!
    var connectViewController: TTModeIftttConnect?
    var connectingViewController: TTModeIftttConnecting?
    var connectedViewController: TTModeIftttConnected?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modeIfttt = (self.mode as! TTModeIfttt)
        self.modeIfttt.delegate = self
        
        self.changeState(TTModeIfttt.IftttState, mode: self.modeIfttt)
    }
    
    func changeState(_ state: TTIftttState, mode: TTModeIfttt) {
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
        guard let view = viewController.view else {
            return
        }
        
        self.view.removeConstraints(self.view.constraints)
        self.view.addSubview(viewController.view)
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1.0, constant: 0))
        
        self.view.layoutIfNeeded()
        //        appDelegate().mainViewController.adjustOptionsHeight(nil)
    }
    
    func drawConnectViewController() {
        self.clearViewConnectrollers()
        self.connectViewController = TTModeIftttConnect(nibName: "TTModeIftttConnect", bundle: Bundle.main)
        self.connectViewController!.mode = self.mode
        self.connectViewController!.modeIfttt = self.modeIfttt
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeIftttConnecting(nibName: "TTModeIftttConnecting", bundle: Bundle.main)
        self.connectingViewController!.mode = self.mode
        self.connectingViewController!.modeIfttt = self.modeIfttt
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeIftttConnected(nibName: "TTModeIftttConnected", bundle: Bundle.main)
        self.connectedViewController!.mode = self.mode
        self.connectedViewController!.modeIfttt = self.modeIfttt
        self.drawViewController(self.connectedViewController!)
    }
    
}
