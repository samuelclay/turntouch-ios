//
//  TTModeCustom.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/11/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

struct TTModeCustomConstants {
    static let customUrl: String = "customUrl"
    static let doubleCustomUrl: String = "doubleCustomUrl"
}

class TTModeCustom: TTMode {
    
    override class func title() -> String {
        return "Custom"
    }
    
    override class func subtitle() -> String {
        return "Hit a website on command"
    }
    
    override class func imageName() -> String {
        return "mode_web.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeCustomURL"]
    }
    
    func titleTTModeCustomURL() -> String {
        return "Custom URL"
    }
    
    // MARK: Action images
    
    func imageTTModeCustomURL() -> String {
        return "music_play.png"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeCustomURL"
    }
    
    override func defaultEast() -> String {
        return "TTModeCustomURL"
    }
    
    override func defaultWest() -> String {
        return "TTModeCustomURL"
    }
    
    override func defaultSouth() -> String {
        return "TTModeCustomURL"
    }
    
    // MARK: Initialize
    
    override func activate() {

    }
    
    override func deactivate() {

    }
    
    // MARK: Actions
    
    func runTTModeCustomURL() {
        guard let customUrlString = self.action.optionValue(TTModeCustomConstants.customUrl) as? String else {
            print(" ---> Error, no URL supplied!")
            return
        }
        
        if let customURL = URL(string: customUrlString) {
            DispatchQueue.global().async {
                do {
                    let urlContents = try String(contentsOf: customURL)
                    print(" ---> URL returned: \(urlContents)")
                } catch {
                    print(" ---> URL threw: \(error)")
                }
            }
        }
    }
    
}
