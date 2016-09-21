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
        let pose = self.modeYoga.poses[0]
        yogaPoseImage.image = UIImage(named: "\(pose["file"]!).png")
        yogaName.text = pose["name"]
        yogaLang.text = pose["lang"]
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    // MARK: Actions
    
    func advance(to position: Int, pose: [String:String]!, direction: Int) {
        let duration: TimeInterval = 1.0
        let poseFilename = "\(pose["file"]!).png"

        yogaPoseImage.layer.removeAllAnimations()
        yogaName.layer.removeAllAnimations()
        yogaLang.layer.removeAllAnimations()

        UIView.transition(with: self.yogaPoseImage, duration: duration,
                          options: [.transitionCrossDissolve, .beginFromCurrentState, .curveEaseOut],
                          animations: {
            self.yogaPoseImage.image = UIImage(named: poseFilename)!
        })
        
        UIView.animate(withDuration: TimeInterval(duration/3.0), delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.yogaName.alpha = 0
            self.yogaLang.alpha = 0
        }) { (finished) in
            if !finished { return }
            self.yogaName.text = pose["name"]
            self.yogaLang.text = pose["lang"]
            UIView.animate(withDuration: TimeInterval(duration/3.0), delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                self.yogaName.alpha = 1
                self.yogaLang.alpha = 1
            })
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        yogaPoseImage.layoutIfNeeded()
    }
}
