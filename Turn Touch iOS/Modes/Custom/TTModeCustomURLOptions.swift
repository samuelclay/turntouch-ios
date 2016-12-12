//
//  TTModeCustomURLOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/11/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeCustomURLOptions: TTOptionsDetailViewController, UITextFieldDelegate {

    @IBOutlet var singleUrl: UITextField!
    @IBOutlet var doubleUrl: UITextField!
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeCustomURLOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleUrlString = self.action.optionValue(TTModeCustomConstants.customUrl)
        let doubleUrlString = self.action.optionValue(TTModeCustomConstants.doubleCustomUrl)
        
        singleUrl.text = singleUrlString as? String
        doubleUrl.text = doubleUrlString as? String
    }
    
    @IBAction func changeUrl(_ sender: UITextField) {
        self.action.changeActionOption(TTModeCustomConstants.customUrl, to: singleUrl.text!)
        self.action.changeActionOption(TTModeCustomConstants.doubleCustomUrl, to: doubleUrl.text!)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        appDelegate().mainViewController.scrollToBottom()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.changeUrl(textField)
        self.view.endEditing(true)
        
        return true
    }
}
