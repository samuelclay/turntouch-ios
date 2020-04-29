//
//  UIView+nib.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/6/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

public extension UIView {
    @nonobjc class func fromNib(_ nibNameOrNil: String? = nil) -> Self {
        return fromNib(nibNameOrNil, type: self)
    }
    
    @nonobjc class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromNib(nibNameOrNil, type: T.self)
        return v!
    }
    
    @nonobjc class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = nibName
        }
        let nibViews = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        for v in nibViews! {
            if let tog = v as? T {
                view = tog
            }
        }
        return view
    }
    
    @nonobjc class var nibName: String {
        let name = "\(self)".components(separatedBy: ".").first ?? ""
        return name
    }
    @nonobjc class var nib: UINib? {
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return UINib(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }
}
