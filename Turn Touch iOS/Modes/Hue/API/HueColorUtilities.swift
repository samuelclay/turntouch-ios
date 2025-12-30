//
//  HueColorUtilities.swift
//  Turn Touch iOS
//
//  Color conversion utilities for Hue lights
//  Adapted from SwiftyHue's Utilities.swift
//

import Foundation
import CoreGraphics
import UIKit

/// Utilities for converting between UIColor and Hue's CIE 1931 XY color space
struct HueColorUtilities {

    private static let cptRED = 0
    private static let cptGREEN = 1
    private static let cptBLUE = 2

    // MARK: - Public Methods

    /// Generates the color for the given XY values.
    /// When the exact values cannot be represented, it will return the closest match.
    ///
    /// - Parameters:
    ///   - xy: The xy point of the color in CIE 1931 color space
    ///   - model: Model ID of the lamp (e.g., "LCT001"). Used to calculate the color gamut.
    /// - Returns: The UIColor representation
    static func colorFromXY(_ xy: CGPoint, forModel model: String?) -> UIColor {
        var xy = xy
        let colorPoints = colorPointsForModel(model)
        let inReachOfLamps = checkPointInLampsReach(xy, withColorPoints: colorPoints)

        if !inReachOfLamps {
            // The colour is out of reach - find the closest colour we can produce
            let pAB = getClosestPointToPoints(
                point1: getPointFromValue(colorPoints[cptRED]),
                point2: getPointFromValue(colorPoints[cptGREEN]),
                point3: xy
            )
            let pAC = getClosestPointToPoints(
                point1: getPointFromValue(colorPoints[cptBLUE]),
                point2: getPointFromValue(colorPoints[cptRED]),
                point3: xy
            )
            let pBC = getClosestPointToPoints(
                point1: getPointFromValue(colorPoints[cptGREEN]),
                point2: getPointFromValue(colorPoints[cptBLUE]),
                point3: xy
            )

            let dAB = getDistanceBetweenTwoPoints(point1: xy, point2: pAB)
            let dAC = getDistanceBetweenTwoPoints(point1: xy, point2: pAC)
            let dBC = getDistanceBetweenTwoPoints(point1: xy, point2: pBC)

            var lowest = dAB
            var closestPoint = pAB

            if dAC < lowest {
                lowest = dAC
                closestPoint = pAC
            }
            if dBC < lowest {
                closestPoint = pBC
            }

            xy.x = closestPoint.x
            xy.y = closestPoint.y
        }

        let x = xy.x
        let y = xy.y
        let z = 1.0 - x - y

        let Y: CGFloat = 1.0
        let X = (Y / y) * x
        let Z = (Y / y) * z

        // sRGB D65 conversion
        var r = X * 1.656492 - Y * 0.354851 - Z * 0.255038
        var g = -X * 0.707196 + Y * 1.655397 + Z * 0.036152
        var b = X * 0.051713 - Y * 0.121364 + Z * 1.011530

        if r > b && r > g && r > 1.0 {
            g = g / r
            b = b / r
            r = 1.0
        } else if g > b && g > r && g > 1.0 {
            r = r / g
            b = b / g
            g = 1.0
        } else if b > r && b > g && b > 1.0 {
            r = r / b
            g = g / b
            b = 1.0
        }

        // Apply gamma correction
        r = r <= 0.0031308 ? 12.92 * r : (1.0 + 0.055) * pow(r, 1.0 / 2.4) - 0.055
        g = g <= 0.0031308 ? 12.92 * g : (1.0 + 0.055) * pow(g, 1.0 / 2.4) - 0.055
        b = b <= 0.0031308 ? 12.92 * b : (1.0 + 0.055) * pow(b, 1.0 / 2.4) - 0.055

        if r > b && r > g {
            if r > 1.0 {
                g = g / r
                b = b / r
                r = 1.0
            }
        } else if g > b && g > r {
            if g > 1.0 {
                r = r / g
                b = b / g
                g = 1.0
            }
        } else if b > r && b > g {
            if b > 1.0 {
                r = r / b
                g = g / b
                b = 1.0
            }
        }

        // Clamp values to valid range
        r = max(0, min(1, r))
        g = max(0, min(1, g))
        b = max(0, min(1, b))

        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    /// Generates a point with x and y value that represents the given color
    ///
    /// - Parameters:
    ///   - color: The UIColor to convert
    ///   - model: Model ID of the lamp (e.g., "LCT001"). Used to calculate the color gamut.
    /// - Returns: The xy color point in CIE 1931 color space
    static func calculateXY(_ color: UIColor, forModel model: String?) -> CGPoint {
        var redOrBlackComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0

        color.getRed(&redOrBlackComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)

        let cgColor = color.cgColor
        let numberOfComponents = cgColor.numberOfComponents

        // Default to white
        var red: CGFloat = 1.0
        var green: CGFloat = 1.0
        var blue: CGFloat = 1.0

        if numberOfComponents == 4 {
            // Full color
            red = redOrBlackComponent
            green = greenComponent
            blue = blueComponent
        } else if numberOfComponents == 2 {
            // Greyscale color
            red = redOrBlackComponent
            green = redOrBlackComponent
            blue = redOrBlackComponent
        }

        // Apply gamma correction
        let r = (red > 0.04045) ? pow((red + 0.055) / 1.055, 2.4) : (red / 12.92)
        let g = (green > 0.04045) ? pow((green + 0.055) / 1.055, 2.4) : (green / 12.92)
        let b = (blue > 0.04045) ? pow((blue + 0.055) / 1.055, 2.4) : (blue / 12.92)

        // Wide gamut conversion D65
        let X = r * 0.664511 + g * 0.154324 + b * 0.162028
        let Y = r * 0.283881 + g * 0.668433 + b * 0.047685
        let Z = r * 0.000088 + g * 0.072310 + b * 0.986039

        var cx = X / (X + Y + Z)
        var cy = Y / (X + Y + Z)

        if cx.isNaN { cx = 0.0 }
        if cy.isNaN { cy = 0.0 }

        // Check if the given XY value is within the colour reach of our lamps
        let xyPoint = CGPoint(x: cx, y: cy)
        let colorPoints = colorPointsForModel(model)
        let inReachOfLamps = checkPointInLampsReach(xyPoint, withColorPoints: colorPoints)

        if !inReachOfLamps {
            // The colour is out of reach - find the closest colour we can produce
            let pAB = getClosestPointToPoints(
                point1: getPointFromValue(colorPoints[cptRED]),
                point2: getPointFromValue(colorPoints[cptGREEN]),
                point3: xyPoint
            )
            let pAC = getClosestPointToPoints(
                point1: getPointFromValue(colorPoints[cptBLUE]),
                point2: getPointFromValue(colorPoints[cptRED]),
                point3: xyPoint
            )
            let pBC = getClosestPointToPoints(
                point1: getPointFromValue(colorPoints[cptGREEN]),
                point2: getPointFromValue(colorPoints[cptBLUE]),
                point3: xyPoint
            )

            let dAB = getDistanceBetweenTwoPoints(point1: xyPoint, point2: pAB)
            let dAC = getDistanceBetweenTwoPoints(point1: xyPoint, point2: pAC)
            let dBC = getDistanceBetweenTwoPoints(point1: xyPoint, point2: pBC)

            var lowest = dAB
            var closestPoint = pAB

            if dAC < lowest {
                lowest = dAC
                closestPoint = pAC
            }
            if dBC < lowest {
                closestPoint = pBC
            }

            cx = closestPoint.x
            cy = closestPoint.y
        }

        return CGPoint(x: cx, y: cy)
    }

    /// Convert brightness from API v1 scale (0-254) to API v2 scale (0.0-100.0)
    static func brightnessV1ToV2(_ v1Brightness: Int) -> Double {
        return Double(v1Brightness) / 254.0 * 100.0
    }

    /// Convert brightness from API v2 scale (0.0-100.0) to API v1 scale (0-254)
    static func brightnessV2ToV1(_ v2Brightness: Double) -> Int {
        return Int(v2Brightness / 100.0 * 254.0)
    }

    /// Convert hue from API v1 scale (0-65535) to xy color space
    /// - Parameters:
    ///   - hue: Hue value in API v1 scale (0-65535)
    ///   - saturation: Saturation value (0-254)
    ///   - brightness: Brightness value (0-254)
    /// - Returns: xy point in CIE 1931 color space
    static func xyFromHueSaturation(hue: Int, saturation: Int, brightness: Int, model: String?) -> CGPoint {
        let h = CGFloat(hue) / 65535.0
        let s = CGFloat(saturation) / 254.0
        let b = CGFloat(brightness) / 254.0

        let color = UIColor(hue: h, saturation: s, brightness: b, alpha: 1.0)
        return calculateXY(color, forModel: model)
    }

    // MARK: - Private Methods

    /// Generates the colorPoint values for the light model and the matching gamut.
    private static func colorPointsForModel(_ model: String?) -> [NSValue] {
        var colorPoints = [NSValue]()

        // Gamut A: Older Hue bulbs
        let gamutA = ["LLC001", "LLC005", "LLC006", "LLC007", "LLC011", "LLC012", "LLC013", "LST001"]

        // Gamut B: Hue A19, BR30, GU10
        let gamutB = ["LCT001", "LCT007", "LCT002", "LCT003", "LCT010", "LCT011", "LCT012", "LCT014", "LCT015", "LCT016"]

        // Gamut C: Hue Go, LightStrips Plus, newer bulbs
        let gamutC = ["LLC020", "LST002", "LCT024", "LCA001", "LCA002", "LCA003"]

        if let model = model {
            if gamutA.contains(model) {
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.703, y: 0.296)))  // Red
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.214, y: 0.709)))  // Green
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.139, y: 0.081)))  // Blue
            } else if gamutB.contains(model) {
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.674, y: 0.322)))  // Red
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.408, y: 0.517)))  // Green
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.168, y: 0.041)))  // Blue
            } else if gamutC.contains(model) {
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.692, y: 0.308)))  // Red
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.17, y: 0.7)))     // Green
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.153, y: 0.048)))  // Blue
            } else {
                // Default: wide gamut triangle
                colorPoints.append(getValueFromPoint(CGPoint(x: 1.0, y: 0.0)))      // Red
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.0, y: 1.0)))      // Green
                colorPoints.append(getValueFromPoint(CGPoint(x: 0.0, y: 0.0)))      // Blue
            }
        } else {
            // Default: wide gamut triangle
            colorPoints.append(getValueFromPoint(CGPoint(x: 1.0, y: 0.0)))      // Red
            colorPoints.append(getValueFromPoint(CGPoint(x: 0.0, y: 1.0)))      // Green
            colorPoints.append(getValueFromPoint(CGPoint(x: 0.0, y: 0.0)))      // Blue
        }

        return colorPoints
    }

    /// Calculates crossProduct of two 2D vectors / points.
    private static func crossProduct(point1 p1: CGPoint, point2 p2: CGPoint) -> CGFloat {
        return p1.x * p2.y - p1.y * p2.x
    }

    /// Find the closest point on a line. This point will be within reach of the lamp.
    private static func getClosestPointToPoints(point1 A: CGPoint, point2 B: CGPoint, point3 P: CGPoint) -> CGPoint {
        let AP = CGPoint(x: P.x - A.x, y: P.y - A.y)
        let AB = CGPoint(x: B.x - A.x, y: B.y - A.y)
        let ab2 = AB.x * AB.x + AB.y * AB.y
        let ap_ab = AP.x * AB.x + AP.y * AB.y

        var t = ap_ab / ab2

        if t < 0.0 {
            t = 0.0
        } else if t > 1.0 {
            t = 1.0
        }

        return CGPoint(x: A.x + AB.x * t, y: A.y + AB.y * t)
    }

    /// Find the distance between two points.
    private static func getDistanceBetweenTwoPoints(point1 p1: CGPoint, point2 p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Check if the given XY value is within the reach of the lamps.
    private static func checkPointInLampsReach(_ p: CGPoint, withColorPoints colorPoints: [NSValue]) -> Bool {
        let red = getPointFromValue(colorPoints[cptRED])
        let green = getPointFromValue(colorPoints[cptGREEN])
        let blue = getPointFromValue(colorPoints[cptBLUE])

        let v1 = CGPoint(x: green.x - red.x, y: green.y - red.y)
        let v2 = CGPoint(x: blue.x - red.x, y: blue.y - red.y)
        let q = CGPoint(x: p.x - red.x, y: p.y - red.y)

        let s = crossProduct(point1: q, point2: v2) / crossProduct(point1: v1, point2: v2)
        let t = crossProduct(point1: v1, point2: q) / crossProduct(point1: v1, point2: v2)

        return (s >= 0.0) && (t >= 0.0) && (s + t <= 1.0)
    }

    private static func getPointFromValue(_ value: NSValue) -> CGPoint {
        return value.cgPointValue
    }

    private static func getValueFromPoint(_ point: CGPoint) -> NSValue {
        return NSValue(cgPoint: point)
    }
}

// MARK: - Color Presets

extension HueColorUtilities {
    /// Predefined colors used by Turn Touch scenes
    struct Presets {
        static let earlyEvening = UIColor(red: 0xEB/255.0, green: 0xCE/255.0, blue: 0x92/255.0, alpha: 1.0)  // #EBCe92
        static let lateEveningMain = UIColor(red: 0x5F/255.0, green: 0x4C/255.0, blue: 0x24/255.0, alpha: 1.0)  // #5F4C24
        static let lateEveningAccent = UIColor(red: 0x85/255.0, green: 0x38/255.0, blue: 0xCD/255.0, alpha: 1.0)  // #8538CD
        static let morningMain = UIColor(red: 0x91/255.0, green: 0x4C/255.0, blue: 0x10/255.0, alpha: 1.0)  // #914C10
        static let midnightOilBlue = UIColor(red: 0x0F/255.0, green: 0x38/255.0, blue: 0xC8/255.0, alpha: 1.0)  // #0F38C8
        static let midnightOilTeal = UIColor(red: 0x0E/255.0, green: 0x9C/255.0, blue: 0xC8/255.0, alpha: 1.0)  // #0E9CC8
    }
}
