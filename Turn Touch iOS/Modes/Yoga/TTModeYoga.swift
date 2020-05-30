//
//  TTModeYoga.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 9/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeYoga: TTMode {

    static var yogaActive = false
    #if !WIDGET
    var yogaViewController: TTModeYogaViewController!
    var yogaNavController: UINavigationController!
    #endif
//    var yogaState: TTModeCameraState = .cameraInactive
    var yogaPosition = 0
    let poses = [
        ["name": "Extended triangle pose",
         "file": "yoga_position_1",
         "lang": "Utthita Trikonasana",
         "desc": "A standing yoga pose that tones the legs, reduces stress, and increases stability.",
         "from": "The word \"Trikonasana\" comes from the Sanskrit words \"tri\", meaning \"three\", \"kona\", meaning \"angle\", and \"asana\", meaning \"pose\"."],
        ["name": "Tree pose",
         "file": "yoga_position_2",
         "lang": "Vriksasana",
         "desc": "The asana emphasizes alignment of the head, spine and hips.",
         "from": "The name comes from the Sanskrit words vriksa, meaning \"tree\", and asana, meaning \"pose\"."],
        ["name": "Warrioir I pose",
         "file": "yoga_position_3",
         "lang": "Virabhadrasana I",
         "desc": ""],
        ["name": "Cat pose",
         "file": "yoga_position_4",
         "lang": "Marjariasana",
         "desc": ""],
        ["name": "Boat pose",
         "file": "yoga_position_5",
         "lang": "Navasana",
         "desc": ""],
        ["name": "Low lunge pose",
         "file": "yoga_position_6",
         "lang": "Ashva Sanchalanasana",
         "desc": ""],
        ["name": "Warrior II pose",
         "file": "yoga_position_7",
         "lang": "Virabhadrasana II",
         "desc": ""],
        ["name": "Bow pose",
         "file": "yoga_position_8",
         "lang": "Dhanurasana",
         "desc": ""],
        ["name": "Plow pose",
         "file": "yoga_position_9",
         "lang": "Halasana",
         "desc": ""],
        ["name": "Cobra pose",
         "file": "yoga_position_10",
         "lang": "Bhujangasana",
         "desc": ""],
        ["name": "Downward-facing dog pose",
         "file": "yoga_position_11",
         "lang": "Adho Mukha Shvanasana",
         "desc": ""],
        ["name": "Chair pose",
         "file": "yoga_position_12",
         "lang": "Utkatasana",
         "desc": ""],
        ["name": "Child's pose",
         "file": "yoga_position_13",
         "lang": "Balasana",
         "desc": ""],
        ["name": "Vajra pose",
         "file": "yoga_position_14",
         "lang": "Vajrasana",
         "desc": ""],
        ["name": "Seated forward bend",
         "file": "yoga_position_15",
         "lang": "Paschimottanasana",
         "desc": ""],
        ["name": "Uttanasana pose with clasped hands",
         "file": "yoga_position_16",
         "lang": "Uttanasana",
         "desc": ""],
    ]
    
    required init() {
        super.init()
        
        #if !WIDGET
        yogaViewController = TTModeYogaViewController(nibName: "TTModeYogaViewController", bundle: nil)
//        yogaViewController.modalTransitionStyle = .crossDissolve
//        yogaViewController.modalPresentationStyle = .fullScreen
        yogaViewController.modeYoga = self
        yogaNavController = UINavigationController(rootViewController: yogaViewController)
        yogaNavController.modalTransitionStyle = .crossDissolve
        yogaNavController.modalPresentationStyle = .fullScreen
        #endif
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
        TTModeYoga.yogaActive = false
    }
    
    func closeYoga() {
        #if !WIDGET
        appDelegate().mainViewController.dismiss(animated: true) {
            TTModeYoga.yogaActive = false
        }
        #endif
    }
    
    func ensureYoga() -> Bool {
        #if WIDGET
        return false
        #else
        var yogaAlreadyShowing = true
        
        if !TTModeYoga.yogaActive {
            yogaAlreadyShowing = false
            TTModeYoga.yogaActive = true
            appDelegate().mainViewController.present(yogaNavController,
                                                     animated: true) {
            }
        }
        
        return yogaAlreadyShowing
        #endif
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
        #if WIDGET
        appDelegate().runInApp(action: "TTModeYogaNext")
        #else
        self.advanceYogaPosition(by: 1)
        #endif
    }
    
    func runTTModeYogaPrevious() {
        #if WIDGET
        appDelegate().runInApp(action: "TTModeYogaPrevious")
        #else
        self.advanceYogaPosition(by: -1)
        #endif
    }
    
    #if !WIDGET
    func advanceYogaPosition(by increment: Int) {
        if !self.ensureYoga() {
            return
        }
        
        yogaPosition += increment
        if yogaPosition < 0 {
            yogaPosition = poses.count-1
        } else if yogaPosition >= poses.count {
            yogaPosition = 0
        }
        
        yogaViewController.advance(to: yogaPosition, pose: poses[yogaPosition], direction: increment)
    }
    #endif
}
