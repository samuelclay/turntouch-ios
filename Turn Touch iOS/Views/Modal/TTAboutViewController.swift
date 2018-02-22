//
//  TTAboutViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import Foundation

class TTAboutViewController: UIViewController {
    
    required init() {
        super.init(nibName: "TTAboutViewController", bundle: Bundle.main)

        let closeButton = UIBarButtonItem(barButtonSystemItem: .done,
                                          target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "About Turn Touch"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeModal()
    }
    
}
