//
//  TTPairingViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTPairingViewController: UIViewController {
    
    @IBOutlet var diamondView: TTDiamondView!
    @IBOutlet var spinnerScanning: TTPairingSpinner!
    @IBOutlet var labelScanning: UILabel!
    @IBOutlet var countdownIndicator: UIProgressView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                          target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "Pairing"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closePairingModal()
    }
}
