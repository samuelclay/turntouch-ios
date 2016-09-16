//
//  TTModeHueRandomOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/22/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueRandomOptions: TTOptionsDetailViewController {
    
    @IBOutlet var segRandomColors: UISegmentedControl!
    @IBOutlet var segRandomBrightness: UISegmentedControl!
    @IBOutlet var segRandomSaturation: UISegmentedControl!
    @IBOutlet var doubleSegRandomColors: UISegmentedControl!
    @IBOutlet var doubleSegRandomBrightness: UISegmentedControl!
    @IBOutlet var doubleSegRandomSaturation: UISegmentedControl!
    
    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeHueRandomOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inspectingDirection = appDelegate().modeMap.inspectingModeDirection
        
        segRandomColors.selectedSegmentIndex = self.action.optionValue(TTModeHueConstants.kRandomColors, direction: inspectingDirection) as! Int
        segRandomBrightness.selectedSegmentIndex = self.action.optionValue(TTModeHueConstants.kRandomBrightness, direction: inspectingDirection) as! Int
        segRandomSaturation.selectedSegmentIndex = self.action.optionValue(TTModeHueConstants.kRandomSaturation, direction: inspectingDirection) as! Int
        
        doubleSegRandomColors.selectedSegmentIndex = self.action.optionValue(TTModeHueConstants.kDoubleTapRandomColors, direction: inspectingDirection) as! Int
        doubleSegRandomBrightness.selectedSegmentIndex = self.action.optionValue(TTModeHueConstants.kDoubleTapRandomBrightness, direction: inspectingDirection) as! Int
        doubleSegRandomSaturation.selectedSegmentIndex = self.action.optionValue(TTModeHueConstants.kDoubleTapRandomSaturation, direction: inspectingDirection) as! Int
    }
    
    @IBAction func changeRandomColors(_ sender: UISegmentedControl) {
        self.action.changeActionOption(TTModeHueConstants.kRandomColors,
                                       to: NSNumber(value: segRandomColors.selectedSegmentIndex as Int))
        self.action.changeActionOption(TTModeHueConstants.kDoubleTapRandomColors,
                                       to: NSNumber(value: doubleSegRandomColors.selectedSegmentIndex as Int))
    }
    
    @IBAction func changeRandomBrightness(_ sender: UISegmentedControl) {
        self.action.changeActionOption(TTModeHueConstants.kRandomBrightness,
                                       to: NSNumber(value: segRandomBrightness.selectedSegmentIndex as Int))
        self.action.changeActionOption(TTModeHueConstants.kDoubleTapRandomBrightness,
                                       to: NSNumber(value: doubleSegRandomBrightness.selectedSegmentIndex as Int))
    }
    
    @IBAction func changeRandomSaturation(_ sender: UISegmentedControl) {
        self.action.changeActionOption(TTModeHueConstants.kRandomSaturation,
                                       to: NSNumber(value: segRandomSaturation.selectedSegmentIndex as Int))
        self.action.changeActionOption(TTModeHueConstants.kDoubleTapRandomSaturation,
                                       to: NSNumber(value: doubleSegRandomSaturation.selectedSegmentIndex as Int))
    }
}
