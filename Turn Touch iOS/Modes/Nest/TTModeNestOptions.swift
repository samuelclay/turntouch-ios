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
        
        self.modeNest = (self.mode as! TTModeNest)
        TTModeNest.delegates.add(delegate: self)
        
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
    
    func updateThermostat(_ thermostat: NestSDKThermostat) {
        let isCelsius = thermostat.temperatureScale == .C
        let scale = isCelsius ? "C" : "F"
        let ambient = isCelsius ? "\(thermostat.ambientTemperatureC)°\(scale)" :
                                  "\(thermostat.ambientTemperatureF)°\(scale)"
        var target: String
        if thermostat.hvacMode == .heatCool {
            let targetLow = isCelsius ? "\(thermostat.targetTemperatureLowC)" : "\(thermostat.targetTemperatureLowF)"
            let targetHigh = isCelsius ? "\(thermostat.targetTemperatureHighC)" : "\(thermostat.targetTemperatureHighF)"
            target = "\(targetLow)°\(scale) - \(targetHigh)°\(scale)"
        } else {
            let targetTemp = isCelsius ? "\(thermostat.targetTemperatureC)" : "\(thermostat.targetTemperatureF)"
            target = "\(targetTemp)°\(scale)"
        }
        self.connectedViewController?.labelAmbient.text = ambient
        self.connectedViewController?.labelTarget.text = target
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
