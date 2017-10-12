//
//  TTModePhoneVolumeJumpOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/11/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModePhoneVolumeJumpOptions: TTOptionsDetailViewController {
    
    var modePhone: TTModePhone!
    @IBOutlet var slider: UISlider!
    @IBOutlet var jumpLabel: UILabel!
    
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModePhoneVolumeJumpOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modePhone = self.mode as! TTModePhone
        let jump = self.action.optionValue(TTModePhoneConstants.jumpVolume) as! Int
        slider.value = Float(jump) / 100
        
        self.updateLabel()
    }

    func updateLabel() {
        let jump = self.action.optionValue(TTModePhoneConstants.jumpVolume)
        
        jumpLabel.text = "\(jump!)%"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeSlider(sender: UISlider) {
        let jump = Int(round(slider.value * 100))
        self.action.changeActionOption(TTModePhoneConstants.jumpVolume, to: jump)
        
        self.updateLabel()
    }

}
