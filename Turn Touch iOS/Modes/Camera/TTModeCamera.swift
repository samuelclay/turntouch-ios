//
//  TTModeCamera.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTModeCameraState {
    case cameraInactive
    case cameraActive
    case imageReview
    case videoReview
}

class TTModeCamera: TTMode {
    
    var cameraViewController = TTModeCameraViewController()
    var cameraNavController: UINavigationController!
    var cameraState: TTModeCameraState = .cameraInactive
    
    required init() {
        super.init()
        
        cameraNavController = UINavigationController(rootViewController: cameraViewController)
        cameraNavController.modalPresentationStyle = .fullScreen
        cameraViewController.modeCamera = self
    }
    
    override class func title() -> String {
        return TTText("Camera")
    }
    
    override class func subtitle() -> String {
        return TTText("Shoot photos and videos")
    }
    
    override class func imageName() -> String {
        return "mode_camera.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeCameraShoot",
                "TTModeCameraSwitchPhotoVideo",
                "TTModeCameraSwitchView",
                "TTModeCameraSwitchFlash",
        ]
    }
    
    // MARK: Action titles
    
    func titleTTModeCameraShoot() -> String {
        switch cameraState {
        case .cameraInactive, .cameraActive:
            return TTText("Take photo")
        case .imageReview:
            return TTText("Save photo")
        case .videoReview:
            return TTText("Save photo")
        }
    }
    
    func titleTTModeCameraSwitchPhotoVideo() -> String {
        switch cameraState {
        case .cameraInactive, .cameraActive:
            return TTText("Switch photo/video")
        case .imageReview:
            return TTText("Retake")
        case .videoReview:
            return TTText("Replay")
        }
    }
    
    func titleTTModeCameraSwitchView() -> String {
        switch cameraState {
        case .cameraInactive, .cameraActive:
            return TTText("Flip front/back")
        case .imageReview:
            return TTText("Save photo")
        case .videoReview:
            return TTText("Save video")
        }
    }
    
    func titleTTModeCameraSwitchFlash() -> String {
        return TTText("Switch flash")
    }
    
    // MARK: Action images
    
    func imageTTModeCameraShoot() -> String {
        return "camera_shoot"
    }
    
    func imageTTModeCameraSwitchPhotoVideo() -> String {
        return "camera_video"
    }
    
    func imageTTModeCameraSwitchView() -> String {
        return "camera_reverse"
    }
    
    func imageTTModeCameraSwitchFlash() -> String {
        return "camera_flash"
    }
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeCameraShoot"
    }
    
    override func defaultEast() -> String {
        return "TTModeCameraSwitchView"
    }
    
    override func defaultWest() -> String {
        return "TTModeCameraSwitchPhotoVideo"
    }
    
    override func defaultSouth() -> String {
        return "TTModeCameraShoot"
    }
    
    // MARK: Action methods
    
    override func activate() {
        if appDelegate().modeMap.selectedMode.modeChangeType == .remoteButton {
            _ = self.ensureCamera()
        }
    }
    
    override func deactivate() {
        self.closeCamera()
    }
    
    func closeCamera() {
        guard cameraState != .cameraInactive else {
            return
        }
        
        appDelegate().mainViewController.dismiss(animated: true) {
            self.cameraState = .cameraInactive
        }
    }
    
    func ensureCamera() -> Bool {
        var cameraAlreadyShowing = true
        
        if cameraState == .cameraInactive {
            cameraAlreadyShowing = false
            appDelegate().mainViewController.present(cameraNavController,
                                                                   animated: true) {
                self.cameraState = .cameraActive
            }
        }
        
        return cameraAlreadyShowing
    }
    
    func runTTModeCameraShoot() {
        if !self.ensureCamera() {
            return
        }
        
        cameraViewController.shoot()
    }
    
    func runTTModeCameraSwitchView() {
        if !self.ensureCamera() {
            return
        }
        
        cameraViewController.switchView()
    }
    
    func runTTModeCameraSwitchPhotoVideo() {
        if !self.ensureCamera() {
            return
        }
        
        cameraViewController.switchPhotoVideo()
    }
}
