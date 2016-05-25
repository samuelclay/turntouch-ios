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
    case NO_DIRECTION = 0
    case NORTH = 1
    case EAST  = 2
    case WEST = 3
    case SOUTH = 4
    case INFO = 5
}

enum TTButtonMoment: Int {
    case BUTTON_MOMENT_OFF = 0
    case BUTTON_MOMENT_PRESSDOWN = 1
    case BUTTON_MOMENT_PRESSUP = 2
    case BUTTON_MOMENT_HELD = 3
    case BUTTON_MOMENT_DOUBLE = 4
}
