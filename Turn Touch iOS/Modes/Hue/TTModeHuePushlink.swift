//
//  TTModeHuePushlink.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHuePushlink: TTOptionsDetailViewController {
    
    var modeHue: TTModeHue!
    @IBOutlet var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false

        // Do any additional setup after loading the view.
    }
    
    func setProgress(_ progressPercentage: Int?) {
        if progressPercentage != nil {
            self.progressView.setProgress(Float(progressPercentage!)/100, animated: false)
        }
    }

}
