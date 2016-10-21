//
//  TTModeHueSceneEarlyEveningOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/16/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueSceneEarlyEveningOptions: TTModeHueSceneOptions {

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeHueSceneOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let modeHue = self.mode as! TTModeHue
        modeHue.ensureRoomSelected(in: self.action.direction)
        
        super.viewDidLoad()
    }
}
