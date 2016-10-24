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

//        let bridgeSendAPI = TTModeHue.hueSdk.bridgeSendAPI
//        bridgeSendApi.getAllScenes { (dictionary, errors) in
//            self.drawScenes()
//        }
    }
    
}
