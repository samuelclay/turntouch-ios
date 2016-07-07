//
//  TTModalButton.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/6/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModalButton: UIView {

    var buttonLabel: UILabel!
    var chevronImage: UIImageView!
    var modalPairing: TTPairingState?
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        
    }
    
    func setPairingState(state: TTPairingState) {
        self.modalPairing = state
        
        self.setNeedsDisplay()
    }

}
