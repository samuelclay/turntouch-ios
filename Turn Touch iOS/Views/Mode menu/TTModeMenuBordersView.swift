//
//  TTModeMenuBordersView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/1/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeMenuBordersView: UIView {

    var BUTTON_MARGIN: CGFloat = 12
    var hideBorder = false
    var hideShadow = false
    let borderStyle: TTMenuType = TTMenuType.MENU_MODE

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if !hideBorder && !hideShadow {
            self.drawShadowTop()
            if CGRectGetHeight(self.bounds) > 36 {
                self.drawShadowBottom()
            }
        } else {
            if borderStyle == TTMenuType.MENU_ADD_MODE || borderStyle == TTMenuType.MENU_ADD_ACTION {
                UIColor(hex: 0xFFFFFF).set()
            } else {
                UIColor(hex: 0xF5F6F8).set()
            }
            let border = UIBezierPath()
            border.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds)))
            border.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds)))
            border.lineWidth = 2.0
            border.stroke()
        }
        
        if (borderStyle == .MENU_ADD_MODE || borderStyle == .MENU_ADD_ACTION) && !hideBorder {
            let border = UIBezierPath()
            border.moveToPoint(CGPointMake(CGRectGetMinX(self.bounds) + BUTTON_MARGIN, CGRectGetMinY(self.bounds)))
            border.addLineToPoint(CGPointMake(CGRectGetMaxX(self.bounds) - BUTTON_MARGIN, CGRectGetMinY(self.bounds)))
            border.lineWidth = 2.0
            UIColor(hex: 0xC2CBCE).set()
            border.stroke()
        }
    }
    
    func drawShadowBottom() {
        var rect: CGRect = self.bounds
        let lineRect: CGRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 1.0)
        rect.size.height = 8
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let context = UIGraphicsGetCurrentContext()
        CGContextClipToRect(context, self.bounds)
//        CGContextClipToMask(context, rect, self.maskForRectBottom(self.bounds))
        let num_locations: size_t = 2
        let locations: [CGFloat] = [0.0, 1.0]
        let components: [CGFloat] = [
            0.315, 0.371, 0.450, 0.1,  // Bottom color
            0.315, 0.371, 0.450, 0.0  // Top color
        ]
        let myGradient: CGGradientRef = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations)!
        let myStartPoint: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
        let myEndPoint: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, CGGradientDrawingOptions(rawValue: 0))
        CGContextSetRGBFillColor(context, 0.315, 0.371, 0.450, 0.2)
        CGContextFillRect(context, lineRect)
//        CGColorSpaceRelease(colorSpace)
    }
    
    func maskForRectTop() -> CGImageRef {
        let height: CGFloat = CGFloat(fminf(Float(CGRectGetHeight(self.bounds)), 8))
        var size: CGSize = self.bounds.size
        size.height = height
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let context = UIGraphicsGetCurrentContext()
        CGContextClipToRect(context, self.bounds)
        let rect: CGRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let num_locations: size_t = 3
        let locations: [CGFloat] = [0.0, 0.5, 1.0]
        let components: [CGFloat] = [
            1.0, 1.0, 1.0, 1.0,  // Start color
            0.0, 0.0, 0.0, 1.0,  // Middle color
            1.0, 1.0, 1.0, 1.0,  // End color
        ]
        
        let myGradient: CGGradientRef = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations)!
        let myStartPoint: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
        let myEndPoint: CGPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, CGGradientDrawingOptions(rawValue: 0))
        let theImage: CGImageRef = CGBitmapContextCreateImage(context)!
        let theMask: CGImageRef = CGImageMaskCreate(CGImageGetWidth(theImage), CGImageGetHeight(theImage), CGImageGetBitsPerComponent(theImage), CGImageGetBitsPerPixel(theImage), CGImageGetBytesPerRow(theImage), CGImageGetDataProvider(theImage), nil, true)!
//        CGColorSpaceRelease(colorSpace)
//        CGContextRelease(context)
        return theMask
    }
    
    func drawShadowTop() {
//        NSGraphicsContext.saveGraphicsState()
        var rect: CGRect = self.bounds
        rect.origin.y = rect.size.height - 8
        rect.size.height = 8
        let lineRect: CGRect = CGRectMake(rect.origin.x, CGRectGetHeight(self.bounds) - 1, rect.size.width, 1.0)
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let context = UIGraphicsGetCurrentContext()
        CGContextClipToRect(context, self.bounds)
        CGContextClipToMask(context, rect, self.maskForRectTop())
        let num_locations: size_t = 2
        let locations: [CGFloat] = [0.0, 1.0]
        let components: [CGFloat] = [
            0.315, 0.371, 0.450, 0.0,  // Bottom color
            0.315, 0.371, 0.450, 0.1  // Top color
        ]
        
        let myGradient: CGGradientRef = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations)!
        let myStartPoint: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
        let myEndPoint: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
        //    if (height >= 8) {
        CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, CGGradientDrawingOptions(rawValue: 0))
        //    }
        CGContextSetRGBFillColor(context, 0.315, 0.371, 0.450, 0.2)
        CGContextFillRect(context, lineRect)
//        CGColorSpaceRelease(colorSpace)
//        NSGraphicsContext.restoreGraphicsState()
    }
}
