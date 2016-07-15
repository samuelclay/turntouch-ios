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
    var modalPairing: TTPairingState?
    var ftuxPage: TTFTUXPage? {
        didSet {
            self.updateModal()
        }
    }
    
    init(pairingState: TTPairingState) {
        self.modalPairing = pairingState
        super.init(nibName: "TTModalButton", bundle: nil)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.userInteractionEnabled = true
        
        self.updateModal()
    }
    
    init(ftuxPage: TTFTUXPage) {
        self.ftuxPage = ftuxPage
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
        if modalPairing != nil {
            switch modalPairing! {
            case .Intro:
                buttonLabel.text = "Pair remote"
                backgroundView.backgroundColor = UIColor(hex: 0x4383C0)
            case .Success:
                buttonLabel.text = "Show me how it works"
                backgroundView.backgroundColor = UIColor(hex: 0x2FB789)
            case .Failure:
                buttonLabel.text = "Try again"
                backgroundView.backgroundColor = UIColor(hex: 0xFFCA44)
            default:
                break
            }
        } else if ftuxPage != nil {
            switch ftuxPage! {
            case .HUD:
                buttonLabel.text = "That's all there is to it"
                backgroundView.backgroundColor = UIColor(hex: 0x434340)
            default:
                buttonLabel.text = "Continue"
                backgroundView.backgroundColor = UIColor(hex: 0x4383C0)
            }
        }
    }
    
    // MARK: Touch events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if (touches.first != nil) {
            if modalPairing != nil {
                switch modalPairing! {
                case .Intro:
                    backgroundView.backgroundColor = UIColor(hex: 0x396C9A)
                case .Success:
                    backgroundView.backgroundColor = UIColor(hex: 0x36A07A)
                case .Failure:
                    backgroundView.backgroundColor = UIColor(hex: 0xE4B449)
                default:
                    break
                }
            } else if ftuxPage != nil {
                switch ftuxPage! {
                case .HUD:
                    backgroundView.backgroundColor = UIColor(hex: 0x333330)
                default:
                    backgroundView.backgroundColor = UIColor(hex: 0x396C9A)
                }
            }
        }
        
        self.view.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        if (touches.first != nil) {
            self.updateModal()
            
            if modalPairing != nil {
                switch modalPairing! {
                case .Intro:
                    appDelegate().mainViewController.switchPairingModal(.Searching)
                case .Success:
                    appDelegate().mainViewController.switchFtuxModal(.Intro)
                case .Failure:
                    appDelegate().mainViewController.switchPairingModal(.Searching)
                default:
                    break
                }
            } else if ftuxPage != nil {
                switch ftuxPage! {
                case .Intro:
                    appDelegate().mainViewController.switchFtuxModal(.Actions)
                case .Actions:
                    appDelegate().mainViewController.switchFtuxModal(.Modes)
                case .Modes:
                    appDelegate().mainViewController.switchFtuxModal(.BatchActions)
                case .BatchActions:
                    appDelegate().mainViewController.switchFtuxModal(.HUD)
                case .HUD:
                    appDelegate().mainViewController.closeFtuxModal()
                }
            }
        }
        
        self.view.setNeedsDisplay()
    }

}
