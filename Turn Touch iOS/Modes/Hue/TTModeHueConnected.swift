//
//  TTModeHueConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueConnected: TTOptionsDetailViewController, TTModeHueSceneDelegate {
    
    var modeHue: TTModeHue!
    @IBOutlet var lightsLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var spinner: TTPairingSpinner!
    @IBOutlet var reloadScenesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.countLights()

        self.modeHue = appDelegate().modeMap.selectedMode as! TTModeHue
        self.modeHue.sceneDelegate = self
        
        self.sceneUploadProgress()
    }

    @IBAction func selectOtherBridge(_ sender: UIButton) {        
        self.modeHue.findBridges()
    }
    
    @IBAction func reloadScenes(_ sender: UIButton) {
        self.modeHue.ensureScenes(force: true)
    }
    
    func countLights() {
        let cache = TTModeHue.hueSdk.resourceCache
        if let scenes = cache?.scenes,
            let lights = cache?.lights,
            let rooms = cache?.groups {
            let roomStr = rooms.count == 1 ? "1 room" : "\(rooms.count) rooms"
            let lightsStr = lights.count == 1 ? "1 light" : "\(lights.count) lights"
            let sceneStr = scenes.count == 1 ? "1 scene" : "\(scenes.count) scenes"
            lightsLabel.text = "\(roomStr), \(lightsStr), \(sceneStr)"
        } else {
            lightsLabel.text = "Loading scenes..."
        }
    }
    
    func sceneUploadProgress() {
        let progress = self.modeHue.sceneUploadProgress
        // return
        if progress >= 0 {
            spinner.isHidden = false
//            progressView.isHidden = false
//            reloadScenesButton.isHidden = true
//            progressView.setProgress(progress, animated: true)
        } else {
            spinner.isHidden = true
//            progressView.isHidden = true
            reloadScenesButton.isHidden = false
        }
    }

}
