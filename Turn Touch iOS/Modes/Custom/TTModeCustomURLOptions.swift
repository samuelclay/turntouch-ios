//
//  TTModeCustomURLOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/11/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeCustomURLOptions: TTOptionsDetailViewController, UITextFieldDelegate {

    var modeCustom: TTModeCustom!
    @IBOutlet var singleUrl: UITextField!
    @IBOutlet var doubleUrl: UITextField!
    @IBOutlet var singleLabel: UILabel!
    @IBOutlet var doubleLabel: UILabel!
    @IBOutlet var singleRefresh: UIButton!
    @IBOutlet var doubleRefresh: UIButton!
    @IBOutlet var singleSpinner: UIActivityIndicatorView!
    @IBOutlet var doubleSpinner: UIActivityIndicatorView!
    @IBOutlet var singleImage: UIImageView!
    @IBOutlet var doubleImage: UIImageView!
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeCustomURLOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modeCustom = self.mode as! TTModeCustom
        
        let singleUrlString = self.action.optionValue(TTModeCustomConstants.singleCustomUrl)
        let doubleUrlString = self.action.optionValue(TTModeCustomConstants.doubleCustomUrl)
        
        singleUrl.text = singleUrlString as? String
        doubleUrl.text = doubleUrlString as? String
        
        singleSpinner.hidesWhenStopped = true
        doubleSpinner.hidesWhenStopped = true
        
        singleSpinner.stopAnimating()
        doubleSpinner.stopAnimating()
        
        let singleLastSuccess = self.action.optionValue(TTModeCustomConstants.singleLastSuccess) as? Bool
        let doubleLastSuccess = self.action.optionValue(TTModeCustomConstants.doubleLastSuccess) as? Bool
        
        if let lastSuccess = singleLastSuccess {
            singleImage.isHidden = false
            if lastSuccess {
                singleImage.image = UIImage(named: "modal_success.png")
            } else {
                singleImage.image = UIImage(named: "modal_failure.png")
            }
        } else {
            singleImage.isHidden = true
        }
        if let lastSuccess = doubleLastSuccess {
            doubleImage.isHidden = false
            if lastSuccess {
                doubleImage.image = UIImage(named: "modal_success.png")
            } else {
                doubleImage.image = UIImage(named: "modal_failure.png")
            }
        } else {
            doubleImage.isHidden = true
        }
        
        let singleHitCount = self.action.optionValue(TTModeCustomConstants.singleHitCount) as? Int ?? 0
        if singleHitCount == 1 {
            singleLabel.text = "Hit 1 time"
            singleLabel.textColor = UIColor.black
        } else if singleHitCount > 1 {
            singleLabel.text = "Hit \(singleHitCount) times"
            singleLabel.textColor = UIColor.black
        } else {
            singleLabel.text = "Not yet hit"
            singleLabel.textColor = UIColor.lightGray
        }

        let doubleHitCount = self.action.optionValue(TTModeCustomConstants.doubleHitCount) as? Int ?? 0
        if doubleHitCount == 1 {
            doubleLabel.text = "Hit 1 time"
            doubleLabel.textColor = UIColor.black
        } else if doubleHitCount > 1 {
            doubleLabel.text = "Hit \(doubleHitCount) times"
            doubleLabel.textColor = UIColor.black
        } else {
            doubleLabel.text = "Not yet hit"
            doubleLabel.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func changeUrl(_ sender: UITextField) {
        let originalSingleUrl = self.action.optionValue(TTModeCustomConstants.singleCustomUrl) as? String
        let originalDoubleUrl = self.action.optionValue(TTModeCustomConstants.doubleCustomUrl) as? String
        
        if originalSingleUrl == nil || originalSingleUrl != singleUrl.text {
            self.action.changeActionOption(TTModeCustomConstants.singleCustomUrl, to: singleUrl.text!)
            self.action.changeActionOption(TTModeCustomConstants.singleHitCount, to: 0)
            self.action.changeActionOption(TTModeCustomConstants.singleLastSuccess, to: false)
        }
        if originalDoubleUrl == nil || originalDoubleUrl != doubleUrl.text {
            self.action.changeActionOption(TTModeCustomConstants.doubleCustomUrl, to: doubleUrl.text!)
            self.action.changeActionOption(TTModeCustomConstants.doubleHitCount, to: 0)
            self.action.changeActionOption(TTModeCustomConstants.doubleLastSuccess, to: false)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        appDelegate().mainViewController.scrollToBottom()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.changeUrl(textField)
        self.view.endEditing(true)
        
        return true
    }
    
    @IBAction func hitRefreshSingle(_ sender: UIButton) {
        singleSpinner.startAnimating()
        singleRefresh.isHidden = true

        self.modeCustom.runTTModeCustomURL()
    }
    
    @IBAction func hitRefreshDouble(_ sender: UIButton) {
        doubleSpinner.startAnimating()
        doubleRefresh.isHidden = true
        
        self.modeCustom.doubleRunTTModeCustomURL()
    }

}
