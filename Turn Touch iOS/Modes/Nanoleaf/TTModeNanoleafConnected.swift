//
//  TTModeNanoleafConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNanoleafConnected: TTOptionsDetailViewController {

    var modeNanoleaf: TTModeNanoleaf!
    @IBOutlet var effectsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.countEffects()
    }

    @IBAction func selectOtherDevice(_ sender: UIButton) {
        self.modeNanoleaf.findDevices()
    }

    func countEffects() {
        let name = TTModeNanoleaf.deviceName ?? "Nanoleaf"
        let effectCount = TTModeNanoleaf.cachedEffects.count
        let effectStr = effectCount == 1 ? "1 effect" : "\(effectCount) effects"
        effectsLabel.text = "\(name) - \(effectStr)"
    }
}
