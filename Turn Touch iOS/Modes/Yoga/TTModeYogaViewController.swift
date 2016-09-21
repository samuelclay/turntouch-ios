//
//  TTModeYogaViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 9/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeYogaViewController: UIViewController {

    var modeYoga: TTModeYoga!
    var backgroundImageView: UIImageView!
    @IBOutlet var yogaPoseImage: UIImageView!
    @IBOutlet var yogaName: UILabel!
    @IBOutlet var yogaLang: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = UIColor.blue
//        self.view.clipsToBounds = true
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    // MARK: Actions
    
    func advance(to position: Int) {
        
    }
}
