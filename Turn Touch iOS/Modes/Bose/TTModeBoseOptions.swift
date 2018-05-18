//
//  TTModeBoseOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeBoseOptions: TTOptionsDetailViewController, TTModeBoseDelegate {
    
    var modeBose: TTModeBose!
    var connectViewController: TTModeBoseConnect?
    var connectingViewController: TTModeBoseConnecting?
    var connectedViewController: TTModeBoseConnected?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modeBose = self.mode as! TTModeBose
        self.modeBose.delegate = self
        
        self.changeState(TTModeBose.boseState, mode: self.modeBose)
    }
    
    func changeState(_ state: TTBoseState, mode: TTModeBose) {
        switch state {
        case .disconnected:
            self.drawConnectViewController()
        case .connecting:
            self.drawConnectingViewController()
        case .connected:
            self.drawConnectedViewController()
        }
    }
    
    func presentError(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
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
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: viewController.view, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1.0, constant: 0))
        
        self.view.layoutIfNeeded()
//        appDelegate().mainViewController.adjustOptionsHeight(nil)
    }
    
    func drawConnectViewController() {
        self.clearViewConnectrollers()
        self.connectViewController = TTModeBoseConnect(nibName: "TTModeBoseConnect", bundle: Bundle.main)
        self.connectViewController!.mode = self.mode
        self.connectViewController!.modeBose = self.modeBose
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeBoseConnecting(nibName: "TTModeBoseConnecting", bundle: Bundle.main)
        self.connectingViewController!.mode = self.mode
        self.connectingViewController!.modeBose = self.modeBose
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeBoseConnected(nibName: "TTModeBoseConnected", bundle: Bundle.main)
        self.connectedViewController!.mode = self.mode
        self.connectedViewController!.modeBose = self.modeBose
        self.drawViewController(self.connectedViewController!)
    }

    
}
