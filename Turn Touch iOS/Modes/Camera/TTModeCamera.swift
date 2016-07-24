//
//  TTModeCamera.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeCamera: TTMode {
    
    var cameraActive = false
    var cameraViewController = TTModeCameraViewController()
    var cameraNavController: UINavigationController!
    
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
        return "Take photo"
    }
    
    func titleTTModeCameraSwitchPhotoVideo() -> String {
        return "Switch photo/video"
    }
    
    func titleTTModeCameraSwitchView() -> String {
        return "Flip front/back"
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

    }
    
    override func deactivate() {
        self.closeCamera()
    }
    
    func closeCamera() {
        appDelegate().mainViewController.dismissViewControllerAnimated(true) {
            self.cameraActive = false
        }
    }
    
    func ensureCamera() -> Bool {
        var cameraAlreadyShowing = true
        
        if !cameraActive {
            cameraAlreadyShowing = false
            appDelegate().mainViewController.presentViewController(cameraNavController, animated: true) {
                self.cameraActive = true
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
