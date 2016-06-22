//
//  TTModeHueSleepOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/22/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueSleepOptions: TTOptionsDetailViewController {
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var doubleDurationLabel: UILabel!
    @IBOutlet var durationSlider: UISlider!
    @IBOutlet var doubleDurationSlider: UISlider!
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "TTModeHueSleepOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sceneDuration: Int = self.action.mode.actionOptionValue(TTModeHueConstants.kHueDuration,
                                                                    actionName: "TTModeHueSleep",
                                                                    direction: appDelegate().modeMap.inspectingModeDirection) as! Int
        durationSlider.value = Float(sceneDuration)
        self.updateSliderLabel(false)
        
        let doubleSceneDuration: Int = self.action.mode.actionOptionValue(TTModeHueConstants.kHueDoubleTapDuration,
                                                                          actionName: "TTModeHueSleep",
                                                                          direction: appDelegate().modeMap.inspectingModeDirection) as! Int
        doubleDurationSlider.value = Float(doubleSceneDuration)
        self.updateSliderLabel(true)
    }
    
    @IBAction func changeDuration(sender: UISlider) {
        let duration = Int(durationSlider.value)
        self.action.mode.changeActionOption(TTModeHueConstants.kHueDuration, to: NSNumber(integer: duration))
        self.updateSliderLabel(false)
        
        let doubleDuration = Int(doubleDurationSlider.value)
        self.action.mode.changeActionOption(TTModeHueConstants.kHueDoubleTapDuration, to: NSNumber(integer: doubleDuration))
        self.updateSliderLabel(true)
    }
    
    func updateSliderLabel(doubleTap: Bool) {
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
