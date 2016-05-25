//
//  UIColor+hex.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

//
//  UIColor+hex.swift
//
//  Created by Berik Visschers on 05-21.
//  Copyright (c) 2015 Berik Visschers. All rights reserved.
//

import UIKit

extension UIColor {
    // Usage: UIColor(hex: 0xFC0ACE)
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1)
    }
    
    // Usage: UIColor(hex: 0xFC0ACE, alpha: 0.25)
    convenience init(hex: Int, alpha: Double) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: CGFloat(alpha))
    }
}
