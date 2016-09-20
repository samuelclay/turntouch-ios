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
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = UIColor.blue
        
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        let image = UIImage(named: "yoga_background.jpg")
        backgroundImageView = UIImageView(image: image)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(backgroundImageView)
        self.view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .width,
                                                   relatedBy: .equal, toItem: self.view, attribute: .width,
                                                   multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .height,
                                                   relatedBy: .equal, toItem: self.view, attribute: .height,
                                                   multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .top,
                                                   relatedBy: .equal, toItem: self.view, attribute: .top,
                                                   multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .left,
                                                   relatedBy: .equal, toItem: self.view, attribute: .left,
                                                   multiplier: 1.0, constant: 0))

//        backgroundImageView.addSubview(visualEffectView)
//        backgroundImageView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .width,
//                                                   relatedBy: .equal, toItem: backgroundImageView, attribute: .width,
//                                                   multiplier: 1.0, constant: 0))
//        backgroundImageView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .height,
//                                                   relatedBy: .equal, toItem: backgroundImageView, attribute: .height,
//                                                   multiplier: 1.0, constant: 0))
//        backgroundImageView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .top,
//                                                   relatedBy: .equal, toItem: backgroundImageView, attribute: .top,
//                                                   multiplier: 1.0, constant: 0))
//        backgroundImageView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: .left,
//                                                   relatedBy: .equal, toItem: backgroundImageView, attribute: .left,
//                                                   multiplier: 1.0, constant: 0))
}

    override var prefersStatusBarHidden : Bool {
        return true
    }

    // MARK: Actions
    
    func advance(to position: Int) {
        
    }
}
