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
    let diamondSize: CGFloat = 272
    var diamondView: TTActionDiamondView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        camera.start()
        self.modeCamera.cameraState = .cameraActive
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        guard let cameraView = camera.view else {
            return
        }
        
        camera = LLSimpleCamera(quality: AVCaptureSession.Preset.high.rawValue,
                                position: LLCameraPositionRear,
                                videoEnabled: false)
        camera.attach(to: self, withFrame: self.view.frame)
        camera.fixOrientationAfterCapture = true
        self.view.addConstraint(NSLayoutConstraint(item: cameraView, attribute: .width,
            relatedBy: .equal, toItem: self.view, attribute: .width,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cameraView, attribute: .height,
            relatedBy: .equal, toItem: self.view, attribute: .height,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cameraView, attribute: .top,
            relatedBy: .equal, toItem: self.view, attribute: .top,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cameraView, attribute: .left,
            relatedBy: .equal, toItem: self.view, attribute: .left,
            multiplier: 1.0, constant: 0))
    
        camera.onDeviceChange = {
            (cam: LLSimpleCamera?, device: AVCaptureDevice?) in
            print(" camera device change")
            if (cam?.isFlashAvailable())! {
                self.flashButton.isHidden = false
                
                if cam?.flash == LLCameraFlashOff {
                    self.flashButton.isSelected = false
                } else {
                    self.flashButton.isSelected = true
                }
            } else {
                self.flashButton.isHidden = true
            }
        }
        
        camera.onError = { (cam, error) -> Void in
            print(" camera error: \(String(describing: error))")
            
            if let camError = error as NSError? {
                if camError.domain == LLSimpleCameraErrorDomain {
                    if camError.code == Int(LLSimpleCameraErrorCodeCameraPermission.rawValue) ||
                        camError.code == Int(LLSimpleCameraErrorCodeMicrophonePermission.rawValue) {
                        if self.errorLabel != nil {
                            self.errorLabel.removeFromSuperview()
                        }
                        
                        let label = UILabel()
                        label.translatesAutoresizingMaskIntoConstraints = false
                        label.text = "Please give Turn Touch permission to use the camera. Go to Settings > Camera"
                        label.numberOfLines = 2
                        label.lineBreakMode = NSLineBreakMode.byWordWrapping
                        label.font = UIFont(name: "Effra", size: 13)
                        label.textColor = UIColor.white
                        label.textAlignment = .center
                        self.view.addSubview(label)
                        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX,
                            relatedBy: .equal, toItem: self.view, attribute: .centerX,
                            multiplier: 1.0, constant: 0))
                        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY,
                            relatedBy: .equal, toItem: self.view, attribute: .centerY,
                            multiplier: 1.0, constant: 0))
                    }
                }
            }
            
            return ()
        }
        
        diamondView = TTActionDiamondView(diamondType: .hud)
        self.view.addSubview(diamondView)
        
        guard let diamondView = diamondView else {
            return
        }
        
        let guide = self.view.safeAreaLayoutGuide
        
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerX,
            relatedBy: .equal, toItem: self.view, attribute: .centerX,
            multiplier: 1.0, constant: 0))
        self.view.addConstraint(guide.bottomAnchor.constraint(equalToSystemSpacingBelow: diamondView.bottomAnchor, multiplier: 1.0))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .height,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: diamondSize))
        self.view.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .width,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: 1.3*diamondSize))
        
        flashButton = UIButton(type: .system)
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.tintColor = UIColor.white
        flashButton.setImage(UIImage(named: "camera-flash.png"), for: UIControl.State())
        flashButton.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        flashButton.addTarget(self, action: #selector(flashButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(flashButton)
        
        guard let flashButton = flashButton else {
            return
        }
        
        self.view.addConstraint(NSLayoutConstraint(item: flashButton, attribute: .left,
            relatedBy: .equal, toItem: self.view, attribute: .left,
            multiplier: 1.0, constant: 24))
        self.view.addConstraint(guide.bottomAnchor.constraint(equalToSystemSpacingBelow: flashButton.bottomAnchor, multiplier: 1.0))
        self.view.addConstraint(NSLayoutConstraint(item: flashButton, attribute: .height,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: flashButton, attribute: .width,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: 46))
        
        
        closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = UIColor.white
        closeButton.setImage(UIImage(named: "cancel.png"), for: UIControl.State())
        closeButton.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        guard let closeButton = closeButton else {
            return
        }
        
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .right,
            relatedBy: .equal, toItem: self.view, attribute: .right,
            multiplier: 1.0, constant: -24))
        self.view.addConstraint(guide.bottomAnchor.constraint(equalToSystemSpacingBelow: closeButton.bottomAnchor, multiplier: 1.0))
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .height,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .width,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: 44))
        
        
        if LLSimpleCamera.isFrontCameraAvailable() && LLSimpleCamera.isRearCameraAvailable() {
            switchButton = UIButton(type: .system)
            switchButton.translatesAutoresizingMaskIntoConstraints = false
            switchButton.tintColor = UIColor.white
            switchButton.setImage(UIImage(named: "camera-switch.png"), for: UIControl.State())
            switchButton.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
            
            guard let switchButton = switchButton else {
                return
            }
            
            switchButton.addTarget(self, action: #selector(switchButtonPressed(_:)), for: .touchUpInside)
            self.view.addSubview(switchButton)
            self.view.addConstraint(NSLayoutConstraint(item: switchButton, attribute: .centerX,
                relatedBy: .equal, toItem: self.view, attribute: .centerX,
                multiplier: 1.0, constant: 0))
            self.view.addConstraint(guide.bottomAnchor.constraint(equalToSystemSpacingBelow: switchButton.bottomAnchor, multiplier: 1.0))
            self.view.addConstraint(NSLayoutConstraint(item: switchButton, attribute: .height,
                relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                multiplier: 1.0, constant: 42))
            self.view.addConstraint(NSLayoutConstraint(item: switchButton, attribute: .width,
                relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, 
                multiplier: 1.0, constant: 49))
        }
        
        segmentedControl = UISegmentedControl(items: ["Photo", "Video"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
//        self.view.addSubview(segmentedControl)
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 24))
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: -24))
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 32))
//        self.view.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 120))
        
    }

    // MARK: Camera controls
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    @objc func segmentedControlChanged(_ control: UISegmentedControl) {
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
    
    @objc func switchButtonPressed(_ button: UIButton) {
        camera.togglePosition()
    }
    
    func applicationDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
    }
    
    @objc func flashButtonPressed(_ button: UIButton) {
        if camera.flash == LLCameraFlashOff {
            let done = camera.updateFlashMode(LLCameraFlashOn)
            if done {
                flashButton.isSelected = true
                flashButton.tintColor = UIColor.yellow
            }
        } else {
            let done = camera.updateFlashMode(LLCameraFlashOff)
            if done {
                flashButton.isSelected = false
                flashButton.tintColor = UIColor.white
            }
        }
    }
    
    @objc func closeButtonPressed(_ button: UIButton) {
        self.modeCamera.closeCamera()
    }
    
    func shoot() {
        if segmentedControl.selectedSegmentIndex == 0 {
            camera.capture({ (cam, image, metadata, error) -> Void in
                if error == nil {
                    print("image: \(String(describing: image)) - \(String(describing: metadata))")
                    self.modeCamera.cameraState = .imageReview
                    let reviewViewController = TTModeCameraReviewViewController(image: image!)
                    self.present(reviewViewController, animated: false, completion: nil)
                } else {
                    print("capture error: \(String(describing: error))")
                }
                return ()
            }, exactSeenImage: true)
        } else {
            if !camera.isRecording {
                segmentedControl.isHidden = true
                flashButton.isHidden = true
                switchButton.isHidden = true
                
//                snapButton.layer.borderColor = UIColor.redColor().CGColor
//                snapButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
                
                let outputURL = self.applicationDocumentsDirectory()?.appendingPathComponent("test1").appendingPathExtension("mov")
                camera.startRecording(withOutputUrl: outputURL, didRecord: { (cam, outputFileUrl, error) -> Void in
                    print("recorded video: \(String(describing: outputFileUrl))")
                    return ()
                })
            } else {
                segmentedControl.isHidden = false
                flashButton.isHidden = false
                switchButton.isHidden = false
                
//                snapButton.layer.borderColor = UIColor.whiteColor().CGColor
//                snapButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                
                camera.stopRecording()
            }
        }
    }
    
}
