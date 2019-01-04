//
//  TTModeIftttConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 1/3/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeIftttConnected: TTOptionsDetailViewController {
    
    var modeIfttt: TTModeIfttt!
    
    var pickerVC: TTPickerViewController!
    var popoverController: UIPopoverPresentationController?
    var textField: UITextField!
    var presented = false
    
    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    @IBOutlet var labelAmbient: UILabel!
    @IBOutlet var labelTarget: UILabel!
    
    var devices: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.modeIfttt = (self.mode as! TTModeIfttt)
        //        doublePicker.delegate = self
        
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })
        
        self.selectDevice()
    }
    
    func selectDevice() {
        
    }
    
}
