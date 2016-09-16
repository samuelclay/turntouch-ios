//
//  TTPairingSpinner.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import QuartzCore

class TTPairingSpinner: UIView {
    
    var spinnerBeginTime: CFTimeInterval!
    
    override func awakeFromNib() {
        spinnerBeginTime = CACurrentMediaTime();
    }
    override func draw(_ rect: CGRect) {
        self.layer.sublayers = nil
        
        for i in 0 ..< 2 {
            let circle: CALayer = CALayer()
            circle.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            circle.backgroundColor = UIColor(hex: 0x0000FF).cgColor
            circle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            circle.opacity = 0.6
            circle.cornerRadius = circle.bounds.height * 0.5
            circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)

            let anim: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
            anim.isRemovedOnCompletion = false
            anim.repeatCount = 10000
            anim.duration = 2.0
            anim.beginTime = spinnerBeginTime - (1.0 * Double(i))
            anim.keyTimes = [0.0, 0.5, 1.0]
            anim.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                    CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                    CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            anim.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.0, 0.0, 0.0)),
                           NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 0.0)),
                           NSValue(caTransform3D: CATransform3DMakeScale(0.0, 0.0, 0.0))]
            self.layer.addSublayer(circle)
            circle.add(anim, forKey: "transform")
        }
    }

}
