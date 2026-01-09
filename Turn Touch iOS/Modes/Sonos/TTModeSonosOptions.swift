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

        self.modeSonos = (self.mode as! TTModeSonos)
        self.modeSonos.delegate = self

        // Must call here, not in viewWillAppear - these VCs aren't added via addChild
        // so viewWillAppear is never called
        self.changeState(TTModeSonos.sonosState, mode: self.modeSonos)
    }

    func changeState(_ state: TTSonosState, mode: TTModeSonos) {
        // Ensure UI updates happen on main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.changeState(state, mode: mode)
            }
            return
        }

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

        // Don't remove all constraints - clearViewConnectrollers already removed the old subview
        // and its constraints will be cleaned up automatically
        self.view.addSubview(viewController.view)
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .leadingMargin, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailingMargin, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)) // Shouldn't be needed
        
        self.view.layoutIfNeeded()
//        appDelegate().mainViewController.adjustOptionsHeight(nil)
    }
    
    func drawConnectViewController() {
        self.clearViewConnectrollers()
        self.connectViewController = TTModeSonosConnect(nibName: "TTModeSonosConnect", bundle: Bundle.main)
        self.connectViewController!.mode = self.mode
        self.connectViewController!.modeSonos = self.modeSonos
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeSonosConnecting(nibName: "TTModeSonosConnecting", bundle: Bundle.main)
        self.connectingViewController!.mode = self.mode
        self.connectingViewController!.modeSonos = self.modeSonos
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeSonosConnected(nibName: "TTModeSonosConnected", bundle: Bundle.main)
        self.connectedViewController!.mode = self.mode
        self.connectedViewController!.modeSonos = self.modeSonos
        self.drawViewController(self.connectedViewController!)
    }

    
}
