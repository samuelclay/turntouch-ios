//
//  TTModalButton.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/6/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModalButton: UIViewController {

    @IBOutlet var buttonLabel: UILabel!
    @IBOutlet var chevronImage: UIImageView!
    @IBOutlet var backgroundView: UIView!
    var modalPairing: TTPairingState
    
    init(pairingState: TTPairingState) {
        self.modalPairing = pairingState
        super.init(nibName: "TTModalButton", bundle: nil)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.userInteractionEnabled = true

        self.updateModal()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPairingState(state: TTPairingState) {
        self.modalPairing = state
        
        self.view.setNeedsDisplay()
    }
    
    func updateModal() {
        switch modalPairing {
        case .Intro:
            buttonLabel.text = "Pair remote"
            backgroundView.backgroundColor = UIColor(hex: 0x4383C0)
        case .Searching:
            buttonLabel.text = "Searching"
            backgroundView.backgroundColor = UIColor(hex: 0xEFF1F3)
        case .Success:
            buttonLabel.text = "Show me how it works"
            backgroundView.backgroundColor = UIColor(hex: 0x2FB789)
        case .Failure:
            buttonLabel.text = "Try again"
            backgroundView.backgroundColor = UIColor(hex: 0xFFCA44)
        default:
            break
        }
    }
    
    // MARK: Touch events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if (touches.first != nil) {
            if modalPairing == .Intro {
                backgroundView.backgroundColor = UIColor(hex: 0x396C9A)
            } else if modalPairing == .Success {
                backgroundView.backgroundColor = UIColor(hex: 0x36A07A)
            } else if modalPairing == .Failure {
                backgroundView.backgroundColor = UIColor(hex: 0xE4B449)
            }
        }
        
        self.view.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        if (touches.first != nil) {
            self.updateModal()
            
            if modalPairing == .Intro {
                appDelegate().mainViewController.switchPairingModal(.Searching)
            } else if modalPairing == .Success {
                appDelegate().mainViewController.switchPairingModal(.Searching)
            } else if modalPairing == .Failure {
                appDelegate().mainViewController.switchPairingModal(.Searching)
            }
        }
        
        self.view.setNeedsDisplay()
    }

}
