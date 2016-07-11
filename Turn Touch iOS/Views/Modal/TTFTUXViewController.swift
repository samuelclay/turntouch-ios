//
//  TTFTUXViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTFTUXViewController: UIViewController, EAIntroDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let page1 = EAIntroPage()
        page1.title = "Page the one"
        page1.titleFont = UIFont(name: "Effra", size: 20)
        
        let intro = EAIntroView(frame: self.view.bounds, andPages: [page1])
        intro.delegate = self
        
        intro.showInView(self.view)
    }

}
