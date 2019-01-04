//
//  TTModeSpotifyConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeSpotifyConnected: TTOptionsDetailViewController, TTModeSpotifyDelegate {
    
    var modeSpotify: TTModeSpotify!
    
    var pickerVC: TTPickerViewController!
    var popoverController: UIPopoverPresentationController?
    var textField: UITextField!
    var presented = false
    
    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    //    @IBOutlet var doublePicker: UITextField!
    
    var devices: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.modeSpotify = (self.mode as! TTModeSpotify)
        self.modeSpotify.delegate = self
        //        doublePicker.delegate = self
        
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })
    }
    
    @IBAction func refreshDevices(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        refreshButton.forEach({ $0.isHidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }
        
        self.modeSpotify.beginConnectingToSpotify()
    }
    
    func changeState(_ state: TTSpotifyState, mode: TTModeSpotify) {
        if state == .connected {
            spinner.forEach({ $0.isHidden = true })
            refreshButton.forEach({ $0.isHidden = false })
        }
    }
    
    func presentError(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
