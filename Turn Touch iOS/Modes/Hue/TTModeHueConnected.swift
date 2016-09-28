//
//  TTModeHueConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueConnected: TTOptionsDetailViewController {
    
    var modeHue: TTModeHue!
    @IBOutlet var lightsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.countLights()
    }

    @IBAction func selectOtherBridge(_ sender: UIButton) {        
        self.modeHue.searchForBridgeLocal(reset: true)
    }
    
    @IBAction func reloadScenes(_ sender: UIButton) {
        self.modeHue.ensureScenes(force: true)
    }
    
    func countLights() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        if let scenes = cache?.scenes,
            let lights = cache?.lights {
            let lightsStr = lights.count == 1 ? "1 light" : "\(lights.count) lights"
            let sceneStr = scenes.count == 1 ? "1 scene" : "\(scenes.count) scenes"
            lightsLabel.text = "\(lightsStr), \(sceneStr)"
        } else {
            lightsLabel.text = "Loading scenes..."
        }
    }

}
