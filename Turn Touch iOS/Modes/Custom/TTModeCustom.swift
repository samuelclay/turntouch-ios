//
//  TTModeCustom.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/11/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

struct TTModeCustomConstants {
    static let singleCustomUrl: String = "singleCustomUrl"
    static let doubleCustomUrl: String = "doubleCustomUrl"
    static let singleOutput: String = "singleOutput"
    static let doubleOutput: String = "doubleOutput"
    static let singleHitCount: String = "singleHitCount"
    static let doubleHitCount: String = "doubleHitCount"
    static let singleLastSuccess: String = "singleLastSuccess"
    static let doubleLastSuccess: String = "doubleLastSuccess"
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
    
    override func shouldIgnoreSingleBeforeDouble(_ direction: TTModeDirection) -> Bool {
        return true;
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
        let customUrlString = self.action.optionValue(TTModeCustomConstants.singleCustomUrl) as? String
        
        hitUrl(customUrlString) { (urlContents, success) in
            self.action.changeActionOption(TTModeCustomConstants.singleOutput, to: urlContents)
            self.action.changeActionOption(TTModeCustomConstants.singleLastSuccess, to: success)
            
            var hitCount = self.action.optionValue(TTModeCustomConstants.singleHitCount) as? Int ?? 0
            hitCount += 1
            self.action.changeActionOption(TTModeCustomConstants.singleHitCount, to: hitCount)
            DispatchQueue.main.async {
                appDelegate().modeMap.inspectingModeDirection = appDelegate().modeMap.inspectingModeDirection
            }
        }
    }
    
    func doubleRunTTModeCustomURL() {
        let customUrlString = self.action.optionValue(TTModeCustomConstants.doubleCustomUrl) as? String
        
        hitUrl(customUrlString) { (urlContents, success) in
            self.action.changeActionOption(TTModeCustomConstants.doubleOutput, to: urlContents)
            self.action.changeActionOption(TTModeCustomConstants.doubleLastSuccess, to: success)
            
            var hitCount = self.action.optionValue(TTModeCustomConstants.doubleHitCount) as? Int ?? 0
            hitCount += 1
            self.action.changeActionOption(TTModeCustomConstants.doubleHitCount, to: hitCount)
            DispatchQueue.main.async {
                appDelegate().modeMap.inspectingModeDirection = appDelegate().modeMap.inspectingModeDirection
            }
        }
    }
    
    func hitUrl(_ urlString: String?, callback: @escaping (String, Bool) -> Void) {
        guard let customUrlString = urlString else {
            print(" ---> No URL specified")
            callback("No URL specified", false)
            return
        }

        if customUrlString.characters.count == 0 {
            print(" ---> No URL specified")
            callback("No URL specified", false)
            return
        }
        
        if let customURL = URL(string: customUrlString) {
            DispatchQueue.global().async {
                do {
                    let urlContents = try String(contentsOf: customURL)
                    print(" ---> URL returned: \(urlContents.characters.count) bytes")
                    callback(urlContents, true)
                } catch {
                    print(" ---> URL threw: \(error)")
                    callback(error.localizedDescription, false)
                }
            }
        }
    }
}
