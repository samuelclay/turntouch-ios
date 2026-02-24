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
        self.view.clipsToBounds = true

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
