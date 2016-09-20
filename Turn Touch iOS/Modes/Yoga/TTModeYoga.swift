//
//  TTModeYoga.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 9/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeYoga: TTMode {

    var yogaActive = false
    var yogaViewController = TTModeYogaViewController()
    var yogaNavController: UINavigationController!
//    var yogaState: TTModeCameraState = .cameraInactive
    var yogaPosition = 0
    let MAX_YOGA_POSITIONS = 20
    
    required init() {
        super.init()
        
        yogaNavController = UINavigationController(rootViewController: yogaViewController)
        yogaNavController.modalPresentationStyle = .fullScreen
        yogaViewController.modeYoga = self
    }
    
    override class func title() -> String {
        return "Yoga"
    }
    
    override class func subtitle() -> String {
        return "Practice yoga and movement"
    }
    
    override class func imageName() -> String {
        return "mode_meditation.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeYogaTimeUp",
                "TTModeYogaTimeDown",
                "TTModeYogaNext",
                "TTModeYogaPrevious"]
    }
    
    func titleTTModeYogaTimeUp() -> String {
        return "More time"
    }
    
    func titleTTModeYogaTimeDown() -> String {
        return "Less time"
    }
    
    func titleTTModeYogaNext() -> String {
        return "Next"
    }
    
    func titleTTModeYogaPrevious() -> String {
        return "Previous"
    }
    
    // MARK: Action images
    
    func imageTTModeYogaTimeUp() -> String {
        return ""
    }
    
    func imageTTModeYogaTimeDown() -> String {
        return ""
    }
    
    func imageTTModeYogaNext() -> String {
        return ""
    }
    
    func imageTTModeYogaPrevious() -> String {
        return ""
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeYogaTimeUp"
    }
    
    override func defaultEast() -> String {
        return "TTModeYogaNext"
    }
    
    override func defaultWest() -> String {
        return "TTModeYogaPrevious"
    }
    
    override func defaultSouth() -> String {
        return "TTModeYogaTimeDown"
    }
    
    
    // MARK: Action methods
    
    override func activate() {
        if appDelegate().modeMap.selectedMode.modeChangeType == .remoteButton {
            _ = self.ensureYoga()
        }
    }
    
    override func deactivate() {
        self.closeYoga()
        yogaActive = false
    }
    
    func closeYoga() {
        appDelegate().mainViewController.dismiss(animated: true) {
            self.yogaActive = false
        }
    }
    
    func ensureYoga() -> Bool {
        var yogaAlreadyShowing = true
        
        if !self.yogaActive {
            yogaAlreadyShowing = false
            self.yogaActive = true
            appDelegate().mainViewController.present(yogaNavController,
                                                     animated: true) {
            }
        }
        
        return yogaAlreadyShowing
    }
    
    func runTTModeYogaTimeUp() {
        if !self.ensureYoga() {
            return
        }
        
    }
    
    func runTTModeYogaTimeDown() {
        if !self.ensureYoga() {
            return
        }
        
    }
    
    func runTTModeYogaNext() {
        self.advanceYogaPosition(by: 1)
    }
    
    func runTTModeYogaPrevious() {
        self.advanceYogaPosition(by: -1)
    }
    
    func advanceYogaPosition(by increment: Int) {
        if !self.ensureYoga() {
            return
        }
        
        yogaPosition += increment
        if yogaPosition < 0 {
            yogaPosition = MAX_YOGA_POSITIONS-1
        } else if yogaPosition >= MAX_YOGA_POSITIONS {
            yogaPosition = 0
        }
        
        yogaViewController.advance(to: yogaPosition)
    }
    

}
