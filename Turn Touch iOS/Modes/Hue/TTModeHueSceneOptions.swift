//
//  TTModeHueSceneOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/16/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueSceneOptions: TTModeHuePicker {

//    typealias pickerCallback = (row: Int, forTextField: UITextField) -> ()

    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    var modeHue: TTModeHue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func drawScenes() {
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })

        super.drawScenes()
    }
    
    @IBAction func refreshScenes(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        refreshButton.forEach({ $0.isHidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }
        
        modeHue = self.mode as! TTModeHue
        
        modeHue.updateScenes()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.drawScenes()
        }
    }
    
}
