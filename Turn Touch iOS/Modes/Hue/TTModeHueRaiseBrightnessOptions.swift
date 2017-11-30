//
//  TTModeHueRaiseBrightnessOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 11/29/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueRaiseBrightnessOptions: TTModeHueBrightnessOptions {

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeHueBrightnessOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
