//
//  TTModeDoubleOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/30/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import UIKit

struct TTModeDoubleConstants {
    static let TTModeDoubleEnabled = "TTModeDoubleEnabled"
}

class TTModeDoubleOptions: TTOptionsDetailViewController {

    @IBOutlet var doubleTapSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doubleTapSwitch.isOn = self.mode.modeOptionValue(TTModeDoubleConstants.TTModeDoubleEnabled) as! Bool
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func changeDoubleTapSwitch(_ sender: Any) {
        self.mode.changeModeOption(TTModeDoubleConstants.TTModeDoubleEnabled, to: doubleTapSwitch.isOn)
    }
}
