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
                
        nextButton = TTModalButton(pairingState: pairingState)
        self.view.addSubview(nextButton.view)
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        

        if pairingState == .success || pairingState == .failure {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .done,
                                              target: self, action: #selector(self.close))
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closePairingModal()
        appDelegate().bluetoothMonitor.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch pairingState {
        case .intro:
            self.navigationItem.title = ""
            self.heroImage?.image = UIImage(named: "modal_remote_hero")
            self.titleLabel?.text = "Welcome to Turn Touch"
            self.subtitleLabel?.text = "Beautiful control"
        case .success:
//            self.navigationItem.title = "Success!"
            self.heroImage?.image = UIImage(named: "modal_remote_paired")
            self.titleLabel?.text = "That worked perfectly"
            self.subtitleLabel?.text = "Your remote has been paired"
        case .failure:
//            self.navigationItem.title = "Could not find any remotes..."
            self.heroImage?.image = UIImage(named: "modal_remote_failed")
            self.titleLabel?.text = "Uh Oh..."
            self.subtitleLabel?.text = "No remotes could be found"
        default:
            break
        }
        
        self.nextButton?.setPairingState(pairingState)
    }
}
