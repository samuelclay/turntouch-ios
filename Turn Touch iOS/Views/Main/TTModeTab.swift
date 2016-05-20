//
//  TTModeTab.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 5/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeTab: UIView {
    
    var modeDirection: TTModeDirection = .NO_DIRECTION
    var modeTitle: NSString = ""
    var modeAttributes: NSDictionary = [:]
    var textSize: CGRect
    var highlighted: Bool
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        
        setupMode()
        setupTitleAttributes()
    }
    
    func setupMode() {
        switch modeDirection {
        case .NORTH:
            break
            // itemMode = appDelegate.modeMap.northMode
        default:
            break
        }
    }
    
    func setupTitleAttributes() {
        self.modeTitle = "Test"
        self.modeAttributes = [
            NSShadowAttributeName: {
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.whiteColor()
                shadow.shadowOffset = CGSizeMake(0, -1)
                shadow.shadowBlurRadius = 0
                return shadow
            }(),
            
        ]
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        
        
    }

}
