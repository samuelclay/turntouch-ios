//
//  TTModeNanoleafSleepOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNanoleafSleepOptions: TTOptionsDetailViewController {

    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var doubleDurationLabel: UILabel!
    @IBOutlet var durationSlider: UISlider!
    @IBOutlet var doubleDurationSlider: UISlider!

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeNanoleafSleepOptions", bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let sceneDuration: Int = self.action.optionValue(TTModeNanoleafConstants.kNanoleafDuration) as! Int
        durationSlider.value = Float(sceneDuration)
        self.updateSliderLabel(false)

        let doubleSceneDuration: Int = self.action.optionValue(TTModeNanoleafConstants.kNanoleafDoubleTapDuration) as! Int
        doubleDurationSlider.value = Float(doubleSceneDuration)
        self.updateSliderLabel(true)
    }

    @IBAction func changeDuration(_ sender: UISlider) {
        let duration = Int(durationSlider.value)
        self.action.changeActionOption(TTModeNanoleafConstants.kNanoleafDuration, to: NSNumber(value: duration as Int))
        self.updateSliderLabel(false)

        let doubleDuration = Int(doubleDurationSlider.value)
        self.action.changeActionOption(TTModeNanoleafConstants.kNanoleafDoubleTapDuration, to: NSNumber(value: doubleDuration as Int))
        self.updateSliderLabel(true)
    }

    func updateSliderLabel(_ doubleTap: Bool) {
        let duration = Int(doubleTap ? doubleDurationSlider.value : durationSlider.value)

        var durationString: String!
        switch duration {
        case 0:
            durationString = "Immediate"
        case 1:
            durationString = "1 second"
        case 1..<60:
            durationString = "\(duration) seconds"
        case 60..<60*2:
            durationString = "1 minute"
        default:
            durationString = "\(duration/60) minutes"
        }

        if doubleTap {
            doubleDurationLabel.text = durationString
        } else {
            durationLabel.text = durationString
        }
    }
}
