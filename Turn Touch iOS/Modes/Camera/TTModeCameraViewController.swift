//
//  TTModeCameraViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeCameraViewController: UIViewController {
    
    var modeCamera: TTModeCamera!
    var camera: LLSimpleCamera! = nil
    var errorLabel: UILabel!
    var snapButton: UIButton!
    var closeButton: UIButton!
    var switchButton: UIButton!
    var flashButton: UIButton!
    var segmentedControl: UISegmentedControl!
    let snapButtonSize: CGFloat = 272
    var diamondView: TTActionDiamondView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        camera.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        camera = LLSimpleCamera(quality: AVCaptureSessionPresetHigh,
                                position: LLCameraPositionRear,
                                videoEnabled: false)
        camera.attachToViewController(self, withFrame: self.view.frame)
        camera.fixOrientationAfterCapture = true
        self.view.addConstraint(NSLayoutConstraint(item: camera.view, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: camera.view, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: camera.view, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: camera.view, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        
        camera.onDeviceChange = {
            (cam: LLSimpleCamera!, device: AVCaptureDevice!) in
            print(" camera device change")
            if cam.isFlashAvailable() {
                self.flashButton.hidden = false
                
                if cam.flash == LLCameraFlashOff {
                    self.flashButton.selected = false
                } else {
                    self.flashButton.selected = true
                }
            } else {
                self.flashButton.hidden = true
            }
        }
        
        camera.onError = {
            (cam: LLSimpleCamera!, error: NSError!) in
            print(" camera error: \(error)")
            
            if error.domain == LLSimpleCameraErrorDomain {
                if error.code == Int(LLSimpleCameraErrorCodeCameraPermission.rawValue) ||
                    error.code == Int(LLSimpleCameraErrorCodeMicrophonePermission.rawValue) {
                    if self.errorLabel != nil {
                        self.errorLabel.removeFromSuperview()
                    }
                    
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.text = "Please give Turn Touch permission to use the camera. Go to Settings > Camera"
                    label.numberOfLines = 2
                    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    label.font = UIFont(name: "Effra", size: 13)
                    label.textColor = UIColor.whiteColor()
                    label.textAlignment = .Center
                    self.view.addSubview(label)
                    self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
                    self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0))
                }
            }
        }
        
        diamondView = TTActionDiamondView(diamondType: .HUD)
        self.view.addSubview(diamondView)
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: snapButtonSize))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.3*snapButtonSize))
        
        flashButton = UIButton(type: .System)
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.tintColor = UIColor.whiteColor()
        flashButton.setImage(UIImage(named: "camera-flash.png"), forState: .Normal)
        flashButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        flashButton.addTarget(self, action: #selector(flashButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(flashButton)
        self.view.addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 24))
        self.view.addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 46))
        
        
        closeButton = UIButton(type: .System)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.setImage(UIImage(named: "cancel.png"), forState: .Normal)
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(closeButton)
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: -24))
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44))
        
        
        if LLSimpleCamera.isFrontCameraAvailable() && LLSimpleCamera.isRearCameraAvailable() {
            switchButton = UIButton(type: .System)
            switchButton.translatesAutoresizingMaskIntoConstraints = false
            switchButton.tintColor = UIColor.whiteColor()
            switchButton.setImage(UIImage(named: "camera-switch.png"), forState: .Normal)
            switchButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            
            switchButton.addTarget(self, action: #selector(switchButtonPressed(_:)), forControlEvents: .TouchUpInside)
            self.view.addSubview(switchButton)
            self.view.addConstraint(NSLayoutConstraint(item: switchButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: switchButton, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: switchButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 42))
            self.view.addConstraint(NSLayoutConstraint(item: switchButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 49))
        }
        
        segmentedControl = UISegmentedControl(items: ["Photo", "Video"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.whiteColor()
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), forControlEvents: .ValueChanged)
//        self.view.addSubview(segmentedControl)
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 24))
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: -24))
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32))
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 120))
        
    }

    // MARK: Camera controls
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    func segmentedControlChanged(control: UISegmentedControl) {
        print("Photo to video to photo")
    }
    
    func switchPhotoVideo() {
        if segmentedControl.selectedSegmentIndex == 0 {
            segmentedControl.selectedSegmentIndex = 1
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
    }
    
    func switchView() {
        self.switchButtonPressed(switchButton)
    }
    
    func switchButtonPressed(button: UIButton) {
        camera.togglePosition()
    }
    
    func applicationDocumentsDirectory() -> NSURL? {
        return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last
    }
    
    func flashButtonPressed(button: UIButton) {
        if camera.flash == LLCameraFlashOff {
            let done = camera.updateFlashMode(LLCameraFlashOn)
            if done {
                flashButton.selected = true
                flashButton.tintColor = UIColor.yellowColor()
            }
        } else {
            let done = camera.updateFlashMode(LLCameraFlashOff)
            if done {
                flashButton.selected = false
                flashButton.tintColor = UIColor.whiteColor()
            }
        }
    }
    
    func closeButtonPressed(button: UIButton) {
        self.modeCamera.closeCamera()
    }
    
    func shoot() {
        if segmentedControl.selectedSegmentIndex == 0 {
            camera.capture({ (cam: LLSimpleCamera!, image: UIImage!, metadata: [NSObject : AnyObject]!, error: NSError!) in
                if error == nil {
                    print("image: \(image) - \(metadata)")
                } else {
                    print("capture error: \(error)")
                }
            }, exactSeenImage: true)
        } else {
            if !camera.recording {
                segmentedControl.hidden = true
                flashButton.hidden = true
                switchButton.hidden = true
                
//                snapButton.layer.borderColor = UIColor.redColor().CGColor
//                snapButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
                
                let outputURL = self.applicationDocumentsDirectory()?.URLByAppendingPathComponent("test1").URLByAppendingPathExtension("mov")
                camera.startRecordingWithOutputUrl(outputURL, didRecord: { (cam: LLSimpleCamera!, outputFileUrl: NSURL!, error: NSError!) in
                    print("recorded video: \(outputFileUrl)")
                })
            } else {
                segmentedControl.hidden = false
                flashButton.hidden = false
                switchButton.hidden = false
                
//                snapButton.layer.borderColor = UIColor.whiteColor().CGColor
//                snapButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                
                camera.stopRecording()
            }
        }
    }
    
}
