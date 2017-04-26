//
//  NSObject+Class.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/3/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

public extension NSObject{
    @nonobjc public class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    @nonobjc public var nameOfClass: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
