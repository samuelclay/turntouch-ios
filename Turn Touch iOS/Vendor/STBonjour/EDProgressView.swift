//
//  EDProgressView.swift
//  STBonjour
//
//  Created by Eric Dolecki on 6/16/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import UIKit

public class EDProgressView {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var hint: UILabel!
    
    public class var shared: EDProgressView {
        struct Static {
            static let instance: EDProgressView = EDProgressView()
        }
        return Static.instance
    }
    
    public func showProgressView(view: UIView)
    {
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.4)
        
        hint = UILabel(frame: CGRect(x: 0, y: 8, width: 100, height: 15))
        hint.textAlignment = .Center
        hint.textColor = UIColor.whiteColor()
        hint.font = UIFont(name: "AvenirNext-Regular", size: 11.0)
        hint.text = "Searching..."
        
        progressView.frame = CGRectMake(0, 0, 100, 100)
        progressView.center = view.center
        progressView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        progressView.addSubview(hint)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
