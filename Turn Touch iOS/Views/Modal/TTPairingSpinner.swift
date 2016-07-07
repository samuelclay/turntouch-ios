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
    override func drawRect(rect: CGRect) {
        self.layer.sublayers = nil
        
        for i in 0 ..< 2 {
            let circle: CALayer = CALayer()
            circle.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
            circle.backgroundColor = UIColor(hex: 0x0000FF).CGColor
            circle.anchorPoint = CGPointMake(0.5, 0.5)
            circle.opacity = 0.6
            circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5
            circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)

            let anim: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
            anim.removedOnCompletion = false
            anim.repeatCount = 10000
            anim.duration = 2.0
            anim.beginTime = spinnerBeginTime - (1.0 * Double(i))
            anim.keyTimes = [0.0, 0.5, 1.0]
            anim.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                    CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                    CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            anim.values = [NSValue(CATransform3D: CATransform3DMakeScale(0.0, 0.0, 0.0)),
                           NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 0.0)),
                           NSValue(CATransform3D: CATransform3DMakeScale(0.0, 0.0, 0.0))]
            self.layer.addSublayer(circle)
            circle.addAnimation(anim, forKey: "transform")
        }
    }

}
