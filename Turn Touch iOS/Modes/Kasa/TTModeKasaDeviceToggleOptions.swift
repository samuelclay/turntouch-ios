//
//  TTModeKasaDeviceToggleOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import UIKit

class TTModeKasaDeviceToggleOptions: TTModeKasaDeviceSwitchOptions {

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeKasaDeviceSwitchOptions", bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
