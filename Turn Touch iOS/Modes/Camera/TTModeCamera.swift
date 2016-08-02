//
//  TTModeCamera.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTModeCameraState {
    case CameraInactive
    case CameraActive
    case ImageReview
    case VideoReview
}

class TTModeCamera: TTMode {
    
    var cameraActive = false
    var cameraViewController = TTModeCameraViewController()
    var cameraNavController: UINavigationController!
    var cameraState: TTModeCameraState = .CameraInactive
    
    required init() {
        super.init()
        
        cameraNavController = UINavigationController(rootViewController: cameraViewController)
        cameraNavController.modalPresentationStyle = .FullScreen
        cameraViewController.modeCamera = self
    }
    
    override class func title() -> String {
        return "Camera"
    }
    
    override class func subtitle() -> String {
        return "Shoot photos and videos"
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
        case .CameraInactive, .CameraActive:
            return "Take photo"
        case .ImageReview:
            return "Save photo"
        case .VideoReview:
            return "Save photo"
        }
    }
    
    func titleTTModeCameraSwitchPhotoVideo() -> String {
        switch cameraState {
        case .CameraInactive, .CameraActive:
            return "Switch photo/video"
        case .ImageReview:
            return "Retake"
        case .VideoReview:
            return "Replay"
        }
    }
    
    func titleTTModeCameraSwitchView() -> String {
        switch cameraState {
        case .CameraInactive, .CameraActive:
            return "Flip front/back"
        case .ImageReview:
            return "Save photo"
        case .VideoReview:
            return "Save video"
        }
    }
    
    func titleTTModeCameraSwitchFlash() -> String {
        return "Switch flash"
    }
    
    // MARK: Action images
    
    func imageTTModeCameraShoot() -> String {
        return ""
    }
    
    func imageTTModeCameraSwitchPhotoVideo() -> String {
        return ""
    }
    
    func imageTTModeCameraSwitchView() -> String {
        return ""
    }
    
    func imageTTModeCameraSwitchFlash() -> String {
        return ""
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
        if appDelegate().modeMap.selectedMode.modeChangeType == .RemoteButton || true {
            self.ensureCamera()
        }
    }
    
    override func deactivate() {
        self.closeCamera()
        cameraState = .CameraInactive
    }
    
    func closeCamera() {
        appDelegate().mainViewController.dismissViewControllerAnimated(true) {
            self.cameraActive = false
        }
    }
    
    func ensureCamera() -> Bool {
        var cameraAlreadyShowing = true
        
        if cameraState == .CameraInactive {
            cameraAlreadyShowing = false
            appDelegate().mainViewController.presentViewController(cameraNavController,
                                                                   animated: true) {
                self.cameraState = .CameraActive
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
