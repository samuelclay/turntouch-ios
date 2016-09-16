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
        self.view.isUserInteractionEnabled = true
        
        self.updateModal()
    }
    
    init(ftuxPage: TTFTUXPage) {
        self.ftuxPage = ftuxPage
        super.init(nibName: "TTModalButton", bundle: nil)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.isUserInteractionEnabled = true
        
        self.updateModal()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPairingState(_ state: TTPairingState) {
        self.modalPairing = state
        
        self.view.setNeedsDisplay()
    }
    
    func updateModal() {
        if modalPairing != nil {
            switch modalPairing! {
            case .intro:
                buttonLabel.text = "Pair remote"
                backgroundView.backgroundColor = UIColor(hex: 0x4383C0)
            case .success:
                buttonLabel.text = "Show me how it works"
                backgroundView.backgroundColor = UIColor(hex: 0x2FB789)
            case .failure:
                buttonLabel.text = "Try again"
                backgroundView.backgroundColor = UIColor(hex: 0xFFCA44)
            default:
                break
            }
        } else if ftuxPage != nil {
            switch ftuxPage! {
            case .hud:
                buttonLabel.text = "That's all there is to it"
                backgroundView.backgroundColor = UIColor(hex: 0x434340)
            default:
                buttonLabel.text = "Continue"
                backgroundView.backgroundColor = UIColor(hex: 0x4383C0)
            }
        }
    }
    
    // MARK: Touch events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if (touches.first != nil) {
            if modalPairing != nil {
                switch modalPairing! {
                case .intro:
                    backgroundView.backgroundColor = UIColor(hex: 0x396C9A)
                case .success:
                    backgroundView.backgroundColor = UIColor(hex: 0x36A07A)
                case .failure:
                    backgroundView.backgroundColor = UIColor(hex: 0xE4B449)
                default:
                    break
                }
            } else if ftuxPage != nil {
                switch ftuxPage! {
                case .hud:
                    backgroundView.backgroundColor = UIColor(hex: 0x333330)
                default:
                    backgroundView.backgroundColor = UIColor(hex: 0x396C9A)
                }
            }
        }
        
        self.view.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if (touches.first != nil) {
            self.updateModal()
            
            if modalPairing != nil {
                switch modalPairing! {
                case .intro:
                    appDelegate().mainViewController.switchPairingModal(.searching)
                case .success:
                    appDelegate().mainViewController.switchFtuxModal(.intro)
                case .failure:
                    appDelegate().mainViewController.switchPairingModal(.searching)
                default:
                    break
                }
            } else if ftuxPage != nil {
                switch ftuxPage! {
                case .intro:
                    appDelegate().mainViewController.switchFtuxModal(.actions)
                case .actions:
                    appDelegate().mainViewController.switchFtuxModal(.modes)
                case .modes:
                    appDelegate().mainViewController.switchFtuxModal(.batchActions)
                case .batchActions:
                    appDelegate().mainViewController.switchFtuxModal(.hud)
                case .hud:
                    appDelegate().mainViewController.closeFtuxModal()
                }
            }
        }
        
        self.view.setNeedsDisplay()
    }

}
