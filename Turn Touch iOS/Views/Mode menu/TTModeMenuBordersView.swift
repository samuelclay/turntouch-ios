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
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if !hideBorder && !hideShadow {
            self.drawShadowTop(rect)
            if CGRectGetHeight(rect) > 36 {
//                self.drawShadowBottom(rect)
            }
        } else {
            if borderStyle == TTMenuType.MENU_ADD_MODE || borderStyle == TTMenuType.MENU_ADD_ACTION {
                UIColor(hex: 0xFFFFFF).set()
            } else {
                UIColor(hex: 0xF5F6F8).set()
            }
            let border = UIBezierPath()
            border.moveToPoint(CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)))
            border.addLineToPoint(CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)))
            border.lineWidth = 2.0
            border.stroke()
        }
        
        if (borderStyle == .MENU_ADD_MODE || borderStyle == .MENU_ADD_ACTION) && !hideBorder {
            let border = UIBezierPath()
            border.moveToPoint(CGPointMake(CGRectGetMinX(rect) + BUTTON_MARGIN, CGRectGetMinY(rect)))
            border.addLineToPoint(CGPointMake(CGRectGetMaxX(rect) - BUTTON_MARGIN, CGRectGetMinY(rect)))
            border.lineWidth = 2.0
            UIColor(hex: 0xC2CBCE).set()
            border.stroke()
        }
    }
    
    func maskForRectBottom(rect: CGRect) -> CGImageRef {
        var maskRect = rect
        maskRect.size.height = CGFloat(fminf(Float(CGRectGetHeight(rect)), 8))
        maskRect.origin.y = CGRectGetMaxY(rect) - 8
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let context = UIGraphicsGetCurrentContext()
        CGContextClipToRect(context, maskRect)
        let num_locations: size_t = 3
        let locations: [CGFloat] = [0.0, 0.5, 1.0]
        let components: [CGFloat] = [
            1.0, 1.0, 1.0, 1.0,  // Start color
            0.0, 0.0, 0.0, 1.0,  // Middle color
            1.0, 1.0, 1.0, 1.0,  // End color
        ]
        let myGradient: CGGradientRef = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations)!
        let myStartPoint: CGPoint = CGPointMake(CGRectGetMinX(maskRect), CGRectGetMaxY(maskRect))
        let myEndPoint: CGPoint = CGPointMake(CGRectGetMaxX(maskRect), CGRectGetMaxY(maskRect))
        CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, CGGradientDrawingOptions(rawValue: 0))
        let theImage: CGImageRef = CGBitmapContextCreateImage(context)!
        let theMask: CGImageRef = CGImageMaskCreate(CGImageGetWidth(theImage), CGImageGetHeight(theImage), CGImageGetBitsPerComponent(theImage), CGImageGetBitsPerPixel(theImage), CGImageGetBytesPerRow(theImage), CGImageGetDataProvider(theImage), nil, true)!
//        CGColorSpaceRelease(colorSpace)
//        CGContextRelease(context)
        return theMask
    }
    
    func drawShadowBottom(originalRect: CGRect) {
        var rect = originalRect
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        let lineRect: CGRect = CGRectMake(rect.origin.x, CGRectGetHeight(rect) - 1, rect.size.width, 1.0)
        rect.origin.y = rect.size.height - 8
        rect.size.height = 8
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        CGContextClipToRect(context, rect)
//        CGContextClipToMask(context, rect, self.maskForRectBottom(rect))
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
        CGContextRestoreGState(context)
    }
    
    func maskForRectTop(rect: CGRect) -> CGImageRef {
        var size: CGSize = rect.size
        size.height = CGFloat(fminf(Float(CGRectGetHeight(rect)), 8))
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(nil, Int(rect.size.width), Int(rect.size.height), 8, 0, colorSpace, bitmapInfo.rawValue)
        CGContextClipToRect(context, rect)
        let maskRect: CGRect = CGRectMake(0.0, 0.0, size.width, size.height)
        let num_locations: size_t = 3
        let locations: [CGFloat] = [0.0, 0.5, 1.0]
        let components: [CGFloat] = [
            1.0, 1.0, 1.0, 1.0,  // Start color
            0.0, 0.0, 0.0, 1.0,  // Middle color
            1.0, 1.0, 1.0, 1.0,  // End color
        ]
        
        let myGradient: CGGradientRef = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations)!
        let myStartPoint: CGPoint = CGPointMake(CGRectGetMinX(maskRect), CGRectGetMinY(maskRect))
        let myEndPoint: CGPoint = CGPointMake(CGRectGetMaxX(maskRect), CGRectGetMinY(maskRect))
        CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, CGGradientDrawingOptions(rawValue: 0))
        let theImage: CGImageRef = CGBitmapContextCreateImage(context)!
        let theMask: CGImageRef = CGImageMaskCreate(CGImageGetWidth(theImage), CGImageGetHeight(theImage), CGImageGetBitsPerComponent(theImage), CGImageGetBitsPerPixel(theImage), CGImageGetBytesPerRow(theImage), CGImageGetDataProvider(theImage), nil, true)!
//        CGColorSpaceRelease(colorSpace)
//        CGContextRelease(context)
        return theMask
    }
    
    func drawShadowTop(originalRect: CGRect) {
        var rect = originalRect
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        rect.origin.y = 0
        rect.size.height = 8
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        CGContextClipToRect(context, rect)
        CGContextClipToMask(context, rect, self.maskForRectTop(rect))
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

        let lineRect: CGRect = CGRectMake(rect.origin.x, 0, rect.size.width, 1.0)
        CGContextSetRGBFillColor(context, 0.315, 0.371, 0.450, 0.2)
        CGContextFillRect(context, lineRect)
//        CGColorSpaceRelease(colorSpace)
        CGContextRestoreGState(context)
    }
}
