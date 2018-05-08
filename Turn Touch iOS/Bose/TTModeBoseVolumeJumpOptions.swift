//
//  TTModeBoseVolumeJumpOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/12/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeBoseVolumeJumpOptions: TTOptionsDetailViewController {
    
    var modeBose: TTModeBose!
    @IBOutlet var slider: UISlider!
    @IBOutlet var jumpLabel: UILabel!
    
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeBoseVolumeJumpOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeBose = self.mode as! TTModeBose
        let jump = self.action.optionValue(TTModeBoseConstants.jumpVolume) as! Int
        slider.value = Float(jump) / 100
        
        self.updateLabel()
    }
    
    func updateLabel() {
        let jump = self.action.optionValue(TTModeBoseConstants.jumpVolume)
        
        jumpLabel.text = "\(jump!)%"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeSlider(sender: UISlider) {
        let jump = Int(round(slider.value * 100))
        self.action.changeActionOption(TTModeBoseConstants.jumpVolume, to: jump)
        
        self.updateLabel()
    }
    
}

