//
//  TTModePhone.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModePhone: TTMode {

    override func title() -> String {
        return "Phone"
    }
    
    override func subtitle() -> String {
        return "System-level controls"
    }
    
    override func imageName() -> String {
        return "mode_mac.png"
    }
}
