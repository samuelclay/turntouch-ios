//
//  TTModeIftttTriggerActionOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 4/27/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeIftttTriggerActionOptions: TTOptionsDetailViewController {

    var modeIfttt: TTModeIfttt!

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeIftttTriggerActionOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        modeIfttt = self.action.mode as! TTModeIfttt
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openRecipe(sender: UIControl) {
        modeIfttt.registerTriggers {
            self.modeIfttt.openRecipe(actionDirection: self.action.direction)
        }
    }

}
