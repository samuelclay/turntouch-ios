//
//  TTModeSpotifyOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeSpotifyOptions: TTOptionsDetailViewController, TTModeSpotifyDelegate {
    
    var modeSpotify: TTModeSpotify!
    var connectViewController: TTModeSpotifyConnect?
    var connectingViewController: TTModeSpotifyConnecting?
    var connectedViewController: TTModeSpotifyConnected?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modeSpotify = (self.mode as! TTModeSpotify)
        self.modeSpotify.delegate = self
        
        self.changeState(TTModeSpotify.spotifyState, mode: self.modeSpotify)
    }
    
    func changeState(_ state: TTSpotifyState, mode: TTModeSpotify) {
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
        self.connectViewController = TTModeSpotifyConnect(nibName: "TTModeSpotifyConnect", bundle: Bundle.main)
        self.connectViewController!.mode = self.mode
        self.connectViewController!.modeSpotify = self.modeSpotify
        self.drawViewController(self.connectViewController!)
    }
    
    func drawConnectingViewController() {
        self.clearViewConnectrollers()
        self.connectingViewController = TTModeSpotifyConnecting(nibName: "TTModeSpotifyConnecting", bundle: Bundle.main)
        self.connectingViewController!.mode = self.mode
        self.connectingViewController!.modeSpotify = self.modeSpotify
        self.drawViewController(self.connectingViewController!)
    }
    
    func drawConnectedViewController() {
        self.clearViewConnectrollers()
        self.connectedViewController = TTModeSpotifyConnected(nibName: "TTModeSpotifyConnected", bundle: Bundle.main)
        self.connectedViewController!.mode = self.mode
        self.connectedViewController!.modeSpotify = self.modeSpotify
        self.drawViewController(self.connectedViewController!)
    }

    
}
