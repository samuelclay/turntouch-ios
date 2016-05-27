//
//  TTModeAlarmClock.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeAlarmClock: TTMode {

    override func title() -> String {
        return "Alarm"
    }
    
    override func subtitle() -> String {
        return "Wake up on time to music"
    }
    
    override func imageName() -> String {
        return "mode_alarm.png"
    }
}
