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
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        

        if pairingState == .Success || pairingState == .Failure {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .Done,
                                              target: self, action: #selector(self.close))
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closePairingModal()
        appDelegate().bluetoothMonitor.delegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        switch pairingState {
        case .Intro:
            self.navigationItem.title = ""
            self.heroImage?.image = UIImage(named: "modal_remote_hero")
            self.titleLabel?.text = "Welcome to Turn Touch"
            self.subtitleLabel?.text = "Four buttons of beautiful control"
        case .Success:
//            self.navigationItem.title = "Success!"
            self.heroImage?.image = UIImage(named: "modal_remote_paired")
            self.titleLabel?.text = "That worked perfectly"
            self.subtitleLabel?.text = "Your remote has been paired"
        case .Failure:
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
