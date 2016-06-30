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
        return "Alarm"
    }
    
    override class func subtitle() -> String {
        return "Wake up on time to music"
    }
    
    override class func imageName() -> String {
        return "mode_alarm.png"
    }
}
