//
//  TTModeSonosOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeSonosOptions: TTOptionsDetailViewController, TTModeSonosDelegate {
    
    var modeSonos: TTModeSonos!
    var connectViewController: TTModeSonosConnect?
    var connectingViewController: TTModeSonosConnecting?
    var connectedViewController: TTModeSonosConnected?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modeSonos = self.mode as! TTModeSonos
        self.modeSonos.delegate = self
        
        self.changeState(self.modeSonos.sonosState, mode: self.modeSonos)
    }
    
    func changeState(state: TTSonosState, mode: TTModeSonos) {
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
        self.connectViewController = TTModeSonosConnect(nibName: "TTModeSonosConnect", bundle: NSBundle.mainBundle())
        self.connectViewController!.mode = self.mode
        self.connectViewController!.modeSonos = self.modeSonos
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeSonosConnecting(nibName: "TTModeSonosConnecting", bundle: NSBundle.mainBundle())
        self.connectingViewController!.mode = self.mode
        self.connectingViewController!.modeSonos = self.modeSonos
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeSonosConnected(nibName: "TTModeSonosConnected", bundle: NSBundle.mainBundle())
        self.connectedViewController!.mode = self.mode
        self.connectedViewController!.modeSonos = self.modeSonos
        self.drawViewController(self.connectedViewController!)
    }

    
}
