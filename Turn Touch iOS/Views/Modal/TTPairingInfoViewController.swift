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
    @IBOutlet var nextButton: TTModalButton?
    
    init(pairingState: TTPairingState) {
        self.pairingState = pairingState
        super.init(nibName: "TTPairingInfoViewController", bundle: nil)
        
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
    }
}
