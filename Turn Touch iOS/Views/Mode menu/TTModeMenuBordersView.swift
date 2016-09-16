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
    let borderStyle: TTMenuType = TTMenuType.menu_MODE

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if !hideBorder && !hideShadow {
            self.drawShadowTop(rect)
            if rect.height > 36 {
                self.drawShadowBottom(rect)
            }
        } else {
            if borderStyle == TTMenuType.menu_ADD_MODE || borderStyle == TTMenuType.menu_ADD_ACTION {
                UIColor(hex: 0xFFFFFF).set()
            } else {
                UIColor(hex: 0xF5F6F8).set()
            }
            let border = UIBezierPath()
            border.move(to: CGPoint(x: rect.minX, y: rect.minY))
            border.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            border.lineWidth = 2.0
            border.stroke()
        }
        
        if (borderStyle == .menu_ADD_MODE || borderStyle == .menu_ADD_ACTION) && !hideBorder {
            let border = UIBezierPath()
            border.move(to: CGPoint(x: rect.minX + BUTTON_MARGIN, y: rect.minY))
            border.addLine(to: CGPoint(x: rect.maxX - BUTTON_MARGIN, y: rect.minY))
            border.lineWidth = 2.0
            UIColor(hex: 0xC2CBCE).set()
            border.stroke()
        }
    }
    
    func maskForRectBottom(_ rect: CGRect) -> CGImage {
        var maskRect = rect
        maskRect.size.height = CGFloat(fminf(Float(rect.height), 8))
        maskRect.origin.y = rect.height - 8
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.clip(to: maskRect)
        let num_locations: size_t = 3
        let locations: [CGFloat] = [0.0, 0.5, 1.0]
        let components: [CGFloat] = [
            1.0, 1.0, 1.0, 1.0,  // Start color
            0.0, 0.0, 0.0, 1.0,  // Middle color
            1.0, 1.0, 1.0, 1.0,  // End color
        ]
        let myGradient: CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: num_locations)!
        let myStartPoint: CGPoint = CGPoint(x: maskRect.minX, y: maskRect.maxY)
        let myEndPoint: CGPoint = CGPoint(x: maskRect.maxX, y: maskRect.maxY)
        context?.drawLinearGradient(myGradient, start: myStartPoint, end: myEndPoint, options: CGGradientDrawingOptions(rawValue: 0))
        let theImage: CGImage = context!.makeImage()!
        let theMask: CGImage = CGImage(maskWidth: theImage.width, height: theImage.height, bitsPerComponent: theImage.bitsPerComponent, bitsPerPixel: theImage.bitsPerPixel, bytesPerRow: theImage.bytesPerRow, provider: theImage.dataProvider!, decode: nil, shouldInterpolate: true)!

        return theMask
    }
    
    func drawShadowBottom(_ originalRect: CGRect) {
        var rect = originalRect
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let lineRect: CGRect = CGRect(x: rect.origin.x, y: rect.height - 1, width: rect.size.width, height: 1.0)
        rect.origin.y = rect.size.height - 8
        rect.size.height = 8
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        context?.clip(to: rect)
        context?.clip(to: rect, mask: self.maskForRectBottom(rect))
        let num_locations: size_t = 2
        let locations: [CGFloat] = [0.0, 1.0]
        let components: [CGFloat] = [
            0.315, 0.371, 0.450, 0.1,  // Bottom color
            0.315, 0.371, 0.450, 0.0  // Top color
        ]
        let myGradient: CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: num_locations)!
        let myStartPoint: CGPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let myEndPoint: CGPoint = CGPoint(x: rect.minX, y: rect.minY)
        context?.drawLinearGradient(myGradient, start: myStartPoint, end: myEndPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context?.setFillColor(red: 0.315, green: 0.371, blue: 0.450, alpha: 0.2)
        context?.fill(lineRect)
        context?.restoreGState()
    }
    
    func maskForRectTop(_ rect: CGRect) -> CGImage {
        var size: CGSize = rect.size
        size.height = CGFloat(fminf(Float(rect.height), 8))
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.clip(to: rect)
        let maskRect: CGRect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        let num_locations: size_t = 3
        let locations: [CGFloat] = [0.0, 0.5, 1.0]
        let components: [CGFloat] = [
            1.0, 1.0, 1.0, 1.0,  // Start color
            0.0, 0.0, 0.0, 1.0,  // Middle color
            1.0, 1.0, 1.0, 1.0,  // End color
        ]
        
        let myGradient: CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: num_locations)!
        let myStartPoint: CGPoint = CGPoint(x: maskRect.minX, y: maskRect.minY)
        let myEndPoint: CGPoint = CGPoint(x: maskRect.maxX, y: maskRect.minY)
        context?.drawLinearGradient(myGradient, start: myStartPoint, end: myEndPoint, options: CGGradientDrawingOptions(rawValue: 0))
        let theImage: CGImage = context!.makeImage()!
        let theMask: CGImage = CGImage(maskWidth: theImage.width, height: theImage.height, bitsPerComponent: theImage.bitsPerComponent, bitsPerPixel: theImage.bitsPerPixel, bytesPerRow: theImage.bytesPerRow, provider: theImage.dataProvider!, decode: nil, shouldInterpolate: true)!

        return theMask
    }
    
    func drawShadowTop(_ originalRect: CGRect) {
        var rect = originalRect
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        rect.origin.y = 0
        rect.size.height = 8
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        context?.clip(to: rect)
        context?.clip(to: rect, mask: self.maskForRectTop(rect))
        let num_locations: size_t = 2
        let locations: [CGFloat] = [0.0, 1.0]
        let components: [CGFloat] = [
            0.315, 0.371, 0.450, 0.0,  // Bottom color
            0.315, 0.371, 0.450, 0.1  // Top color
        ]
        
        let myGradient: CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: num_locations)!
        let myStartPoint: CGPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let myEndPoint: CGPoint = CGPoint(x: rect.minX, y: rect.minY)
        //    if (height >= 8) {
        context?.drawLinearGradient(myGradient, start: myStartPoint, end: myEndPoint, options: CGGradientDrawingOptions(rawValue: 0))
        //    }

        let lineRect: CGRect = CGRect(x: rect.origin.x, y: 0, width: rect.size.width, height: 1.0)
        context?.setFillColor(red: 0.315, green: 0.371, blue: 0.450, alpha: 0.2)
        context?.fill(lineRect)
        context?.restoreGState()
    }
}
