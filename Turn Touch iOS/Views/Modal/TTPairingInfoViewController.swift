//
//  TTPairingInfoViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/6/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTPairingInfoViewController: UIViewController {
    
    var pairingState: TTPairingState
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var subtitleLabel: UILabel?
    @IBOutlet var heroImage: UIImageView?
    var nextButton: TTModalButton!
    
    init(pairingState: TTPairingState) {
        self.pairingState = pairingState
        super.init(nibName: "TTPairingInfoViewController", bundle: nil)
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        nextButton = TTModalButton(pairingState: pairingState)
        self.view.addSubview(nextButton.view)
        
        guard let nextButtonView = nextButton.view else {
            return
        }
        
        self.view.addConstraint(NSLayoutConstraint(item: nextButtonView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButtonView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButtonView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButtonView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        

        if pairingState == .success || pairingState == .failure {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .done,
                                              target: self, action: #selector(self.close))
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closePairingModal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch pairingState {
        case .intro:
            self.navigationItem.title = ""
            self.heroImage?.image = UIImage(named: "modal_remote_hero")
            self.titleLabel?.text = TTText("Welcome to Turn Touch")
            self.subtitleLabel?.text = TTText("Beautiful control")
        case .success:
//            self.navigationItem.title = "Success!"
            self.heroImage?.image = UIImage(named: "modal_remote_paired")
            self.titleLabel?.text = TTText("That worked perfectly")
            self.subtitleLabel?.text = TTText("Your remote has been paired")
        case .failure:
//            self.navigationItem.title = "Could not find any remotes..."
            self.heroImage?.image = UIImage(named: "modal_remote_failed")
            self.titleLabel?.text = TTText("Uh Oh...")
            self.subtitleLabel?.text = TTText("No remotes could be found")
        default:
            break
        }
        
        self.nextButton?.setPairingState(pairingState)
        
        self.checkBluetoothState()
    }
    
    func checkBluetoothState() {
        switch appDelegate().bluetoothMonitor.manager.state {
        case .poweredOn:
            return
        case .unsupported:
            self.subtitleLabel?.text = TTText("This device doesn't support Bluetooth Low Energy.")
        case .unauthorized:
            self.subtitleLabel?.text = TTText("Turn Touch is not authorized to use Bluetooth Low Energy.")
        case .poweredOff:
            self.subtitleLabel?.text = TTText("Bluetooth is currently powered off.")
        default:
            self.subtitleLabel?.text = TTText("Bluetooth is powered off or isn't responding.")
        }
    }
}
