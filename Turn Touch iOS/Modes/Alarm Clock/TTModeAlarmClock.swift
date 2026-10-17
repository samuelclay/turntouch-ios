//
//  TTModeAlarmClock.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeAlarmClock: TTMode {

    override class func title() -> String {
        return TTText("Alarm")
    }
    
    override class func subtitle() -> String {
        return TTText("Wake up on time to music")
    }
    
    override class func imageName() -> String {
        return "mode_alarm.png"
    }
}
