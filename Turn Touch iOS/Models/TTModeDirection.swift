//
//  TTModeDirection.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

@objc
enum TTModeDirection: Int {
    case no_DIRECTION = 0
    case north = 1
    case east  = 2
    case west = 3
    case south = 4
    case info = 5
}

enum TTButtonMoment: Int {
    case button_MOMENT_OFF = 0
    case button_MOMENT_PRESSDOWN = 1
    case button_MOMENT_PRESSUP = 2
    case button_MOMENT_HELD = 3
    case button_MOMENT_DOUBLE = 4
}
